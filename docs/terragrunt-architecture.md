# Terragrunt architecture options

How Terragrunt could sit on top of the existing composition → infrastructure → resource layers, if we adopt it.

There are two ways to do it:

- **Option 1: wrap the composition.** Keep `composition/`. Terragrunt fills in the backend, generates the AWS provider and runs the same root module. You keep the same state and the same Terraform code.
- **Option 2: Terragrunt units.** Retire `composition/infra`. Each infrastructure module becomes its own Terragrunt unit with its own state, and outputs move between units through `dependency` blocks.

**Short answer:** Terragrunt does not require removing the composition layer. Start with Option 1. Move to Option 2 only when the infra state is split or several environments are added. For whether we need Terragrunt at all, see [terragrunt-vs-composition.md](terragrunt-vs-composition.md).

---

## What each option changes

![Terragrunt options: what changes per layer](images/terragrunt-layers.svg)

Option 1 only replaces the top row: `terraform.tfvars` and the hand-written `backend.config`. In Option 2 the arrow bypasses the composition layer, so every infrastructure module becomes a root module with its own state.

---

## Option 1: wrap the existing composition

![Option 1: Terragrunt wraps the existing composition](images/terragrunt-option1-wrap.svg)

Terragrunt runs inside `composition/infra/eu-central-1/prod`.

- **No `terraform.source`.** Terragrunt runs in place and doesn't copy the folder into `.terragrunt-cache`, so the `../../../../infrastructure_modules/…` paths still resolve.
- **The backend block stays.** `providers.tf` keeps its empty `backend "s3" {}`. Terragrunt's `remote_state` passes the values that `backend.config` holds today.
- **The provider is generated.** `generate "provider"` writes `provider_aws.tf` with the region (and assume-role settings), which fixes the missing region on the AWS provider.
- **The bootstrap stays plain Terraform.** `composition/remotebackend` creates the bucket the backend needs, so it can't use that backend itself.

### Layout

```text
3-layer-aws-tf-module/
├── root.hcl                  # NEW: remote_state + generate "provider"
├── composition/
│   ├── remotebackend/eu-central-1/prod/   # unchanged, plain Terraform, local state
│   └── infra/eu-central-1/prod/
│       ├── terragrunt.hcl    # NEW: include root.hcl
│       ├── main.tf  variables.tf  outputs.tf  data.tf   # unchanged
│       ├── providers.tf      # keep backend "s3" {}; drop the XXX_old alias
│       ├── terraform.tfvars  # unchanged
│       └── backend.config    # DELETE: replaced by root.hcl
├── infrastructure_modules/   # unchanged
└── resource_modules/         # unchanged
```

### What changes

- Backend values move from the git-ignored `backend.config` into the committed `root.hcl`.
- The AWS provider gets a real `region` instead of reading it from the shell.
- Run `terragrunt plan` / `terragrunt apply` in the folder instead of `terraform init -backend-config=backend.config`.
- No state migration. To undo, delete the two `.hcl` files.

### Watch for

- **Duplicate backend block.** Use `remote_state` *without* `generate`, or delete `backend "s3" {}` from `providers.tf`. Otherwise Terraform sees two backend blocks.
- **State key.** Set `key` to the value in today's `backend.config`. A key built with `path_relative_to_include()` would point at a new, empty state.

### Example (illustrative)

```hcl
# root.hcl
remote_state {
  backend = "s3"
  config = {
    bucket       = "s3-ec1-terraform-eks-demo-infra-prod-terraform-backend-<n>"
    key          = "<same key as backend.config>"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true # S3-native locking; or dynamodb_table = "dynamo-ec1-..."
  }
}

generate "provider" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "eu-central-1"
}
EOF
}
```

```hcl
# composition/infra/eu-central-1/prod/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}
# no terraform.source: runs in place; terraform.tfvars is still auto-loaded
```

---

## Option 2: Terragrunt units replace `composition/infra`

![Option 2: Terragrunt units and their dependencies](images/terragrunt-option2-units.svg)

Each infrastructure module becomes a unit with its own state. The wiring that lives in `composition/infra/eu-central-1/prod/main.tf` today becomes `dependency` blocks:

| Unit | Depends on | Reads |
|---|---|---|
| `vpc` | none | |
| `ecr` | none | |
| `vpn` | none (it reads nothing from VPC today) | |
| `eks` | `vpc` | `public_subnets`, `private_subnets` |
| `ecs` | `vpc`, `ecr` | `vpc_id`, `private_subnets`, `ecr_repository_url` |

`terragrunt run --all apply` (`run-all` in older versions) applies the first three units in parallel, then `eks` and `ecs`. An apply on one unit can only affect that unit's resources.

### Layout

```text
3-layer-aws-tf-module/
├── bootstrap/remotebackend/eu-central-1/prod/   # was composition/remotebackend; plain Terraform
├── live/
│   ├── root.hcl              # remote_state (key per unit), generate provider + versions
│   ├── _envcommon/           # optional: shared defaults per module
│   │   └── vpc.hcl  eks.hcl  ecs.hcl  ecr.hcl  vpn.hcl
│   └── eu-central-1/
│       ├── region.hcl        # region, region_tag = "ec1"
│       └── prod/
│           ├── env.hcl       # env = "prod", app_name = "tf-moduler"
│           ├── vpc/terragrunt.hcl
│           ├── vpn/terragrunt.hcl
│           ├── ecr/terragrunt.hcl
│           ├── eks/terragrunt.hcl   # dependency "vpc"
│           └── ecs/terragrunt.hcl   # dependency "vpc", "ecr"
├── composition/infra/        # retired after migration
├── infrastructure_modules/   # each module is now a root; ecs needs a refactor
└── resource_modules/         # unchanged
```

Adding staging means copying `prod/` to `staging/` and editing `env.hcl`. Each unit file is a few lines.

### What changes

- **State.** The single infra state becomes five. Resource addresses lose one level (`module.vpc.module.x` becomes `module.x`), so every resource has to be moved or imported into its new state. This is the main cost of Option 2.
- **Locals.** The composition's `locals` (tags, `vpc_name`, `region_tag`, `account_id`) move into `root.hcl`, `region.hcl` and `env.hcl`. `get_aws_account_id()` replaces the `aws_caller_identity` lookup.
- **Apply.** Run `terragrunt run --all apply` from `live/`, or apply a single unit from its folder.

### Code that has to change

- **ECS self-references.** `main.tf` passes `module.ecs.security_group_alb_id` and `module.ecs.service_security_group_id` back into `module.ecs`. A unit can't read its own outputs, so this wiring has to move inside `infrastructure_modules/ecs` before the split.
- **Providers and versions.** The infrastructure modules declare only `required_version`. `root.hcl` has to generate `required_providers` (aws, kubernetes, helm, http) as well as the provider block.

### Example (illustrative)

```hcl
# live/eu-central-1/prod/ecs/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}//infrastructure_modules/ecs"
}

dependency "vpc" { config_path = "../vpc" }
dependency "ecr" { config_path = "../ecr" }

inputs = {
  vpc_id       = dependency.vpc.outputs.vpc_id
  subnets      = dependency.vpc.outputs.private_subnets
  ecr_repo_url = dependency.ecr.outputs.ecr_repository_url
  # alb / service SG ids are no longer inputs: wired inside the module
}
```

The `//` in `source` tells Terragrunt to copy the whole repo into the cache, so the module's relative paths to `resource_modules/` still work.

---

## Side by side

| | Today | Option 1 · wrap | Option 2 · units |
|---|---|---|---|
| Terraform states | 2: bootstrap + infra | 2, unchanged | bootstrap + 5 units |
| Backend config | git-ignored `backend.config`, written by hand | committed `root.hcl` | committed `root.hcl`, key per unit |
| AWS provider region | from shell env / profile | generated | generated |
| Module wiring | outputs in `main.tf` | same | `dependency` blocks |
| Blast radius of one apply | whole infra stack | whole infra stack | one unit |
| Add an environment | copy 5 `.tf` files | copy the folder; `root.hcl` is shared | copy `prod/`, edit `env.hcl` |
| Changes to `.tf` code | none | none (drop the `XXX_old` alias) | ECS wiring, provider versions |
| State migration | none | none | split into 5 states |
| Undo | n/a | delete two files | hard once states are split |

---

## Things to settle before either option

1. **Pick a locking method.** Terraform 1.10+ supports S3-native locking (`use_lockfile = true`). If we switch, the DynamoDB table in the bootstrap stack isn't needed any more.
2. **Keep the bucket name a fixed value.** Terraform has to know the backend before `init`, so the bucket can't come from a `dependency` output. Bootstrap once, then write the name into `root.hcl`. A `dependency` on the bootstrap stack would only control ordering.
3. **Clean up the providers.** Remove the `XXX_old` alias and the unused `region` / `role_name` / `profile_name` variables, so the generated provider is the only source of the region.
4. **EKS nested provider.** [`resource_modules/containers/eks/11-kube-provider.tf`](../resource_modules/containers/eks/11-kube-provider.tf) declares its own `provider "kubernetes"`. It works in either option, but modules with their own provider blocks can't use `count`, `for_each` or `depends_on`. Move it up to the root before splitting EKS into its own state.
