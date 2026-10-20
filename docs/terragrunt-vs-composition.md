# Terragrunt vs. composition directories

> **Update:** the repo has since moved to Terragrunt, using Option 3 in [terragrunt-architecture.md](terragrunt-architecture.md). This page records the original decision.

Do we need Terragrunt, or is the plain `composition/` directory approach enough?

**Short answer:** we don't need Terragrunt yet. The composition approach fits the repo as it is today. Revisit the decision once there are several environments, or once the infra stack is split into several states.

---

## Current state of the repo

- **1 region, 1 environment**: `eu-central-1/prod`.
- **2 stacks**, applied in a fixed order: `composition/remotebackend`, then `composition/infra`.
- **One cross-stack handoff**: the state bucket and lock table names from `remotebackend` go into a git-ignored `backend.config`, which is used to initialise `infra`. This happens once, by hand.
- **All module wiring happens inside one root module**: [`composition/infra/eu-central-1/prod/main.tf`](../composition/infra/eu-central-1/prod/main.tf). For example VPC → EKS/ECS and ECR → ECS. Terraform already orders these from its own dependency graph.

## What Terragrunt would solve

Terragrunt mainly addresses three problems:

1. Repeated backend and provider configuration across root modules.
2. Ordering and passing outputs between **separate** Terraform states (`dependency` blocks, `run-all`).
3. Repeated root-module code across many env/region folders.

None of these is painful at the current size of the repo.

## Where the composition approach starts to hurt

### Adding environments

Every new `composition/infra/<region>/<env>/` folder means copying `main.tf`, `variables.tf` (about 240 lines), `providers.tf`, `outputs.tf` and `data.tf`. Only `terraform.tfvars` and `backend.config` actually differ between environments. With 3 environments × 2 regions there would be six copies of near-identical code that drift apart over time. This is the main cost of the plain composition pattern.

### Splitting the state

VPC, EKS, ECS and ECR currently share one state, so a single apply has a large blast radius. If they are split into separate compositions (for example `network/`, `eks/`, `ecs/`), values have to be passed between them by hand with `terraform_remote_state` or data source lookups, and the stacks have to be applied in the right order. This is where Terragrunt's `dependency` blocks and `run-all` pay off.

## Reducing duplication without Terragrunt

If adding environments is the concern, a lighter option is to keep **one shared root module** and give each environment only its values:

```text
composition/infra/
├── main.tf  variables.tf  providers.tf  outputs.tf  data.tf   # written once
└── envs/
    ├── eu-central-1-prod/   # terraform.tfvars, backend.config
    └── eu-west-1-staging/   # terraform.tfvars, backend.config
```

```bash
terraform -chdir=composition/infra init -reconfigure \
  -backend-config=envs/eu-west-1-staging/backend.config

terraform -chdir=composition/infra apply \
  -var-file=envs/eu-west-1-staging/terraform.tfvars
```

Wrap these commands in a Makefile or a CI matrix. Run by hand, it is easy to apply one environment's `tfvars` against another environment's state.

## Recommendation

| Situation | Approach |
|---|---|
| 1–3 environments, one infra state (today) | **Plain composition directories** (current layout) |
| Many environments/regions, same stack | Composition with a shared root module + per-env `tfvars` / `backend.config` |
| Many environments **and** the state split into several dependent stacks | **Terragrunt** (or Terraform Stacks if using HCP Terraform) |

Adopting Terragrunt does not require removing the composition layer. See [terragrunt-architecture.md](terragrunt-architecture.md) for the two ways it can sit on top of this repo.

---

## Other issues found during the review

These apply whichever approach is chosen. Fix them before copying the composition to new environments, or they will be copied too.

- **No region on the AWS provider.** [`providers.tf`](../composition/infra/eu-central-1/prod/providers.tf) has no default `provider "aws"` block that sets a region. `var.region`, `var.role_name` and `var.profile_name` are declared but never used, so the region currently comes from the shell environment (`AWS_REGION` or the AWS profile). Add `provider "aws" { region = var.region }`, plus the profile or assume-role settings.
- **Leftover provider alias.** `configuration_aliases = [aws.XXX_old]` and the empty `provider "aws" { alias = "XXX_old" }` look like leftovers. `configuration_aliases` only has an effect in child modules, so both can be removed.
- **Unused or duplicate variables.** `application_name` and `app_name` hold the same value. `variable "subnets"` and `variable "sg_service_ingress_rules"` in the composition are declared but never used.
