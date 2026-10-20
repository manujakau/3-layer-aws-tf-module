# 3-Layer AWS Terraform Modules

A Terraform codebase for AWS container platforms, split into three layers:

1. **Composition**: small root modules, one per component (`network`, `ecr`, `eks`, `ecs`). They are the same for every environment.
2. **Infrastructure modules**: opinionated building blocks (VPC, ECS, EKS…) that apply naming, tagging and policy.
3. **Resource modules**: thin, generic wrappers around raw `aws_*` / `kubernetes_*` resources.

Each layer calls only the layer directly below it. [Terragrunt](https://terragrunt.gruntwork.io/) sits on top: the `live/` tree runs each composition root as a unit with its own state, supplies the per-environment values, and passes outputs between units. To add an environment or region you add a folder under `live/`. No `.tf` code is copied. See [docs/terragrunt-architecture.md](docs/terragrunt-architecture.md) (Option 3).

---

## Table of contents

- [Architecture](#architecture)
  - [Module stack](#module-stack)
  - [Deployed AWS architecture](#deployed-aws-architecture)
- [Repository layout](#repository-layout)
- [The three layers](#the-three-layers)
- [Module catalogue](#module-catalogue)
- [How the modules are wired together](#how-the-modules-are-wired-together)
- [Naming and tagging](#naming-and-tagging)
- [Feature flags](#feature-flags)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Extending the codebase](#extending-the-codebase)
- [CI/CD](#cicd)
- [Known issues](#known-issues)

---

## Architecture

### Module stack

How the Terragrunt units sit on top of the three layers, which module calls which, and how outputs are fed into other modules' inputs.

![3-layer Terraform module stack with Terragrunt](docs/images/module-stack.svg)

- **Top band** is the Terragrunt `live/` tree. Every unit includes `live/root.hcl`, which generates the backend and the AWS provider, and points `terraform.source` at one composition root.
- **Grey arrows** are module calls (`source = "../../…"`) and each unit's `terraform.source`.
- **Orange arrows** are values passed from one module's outputs into another module's inputs. Between units this happens in Terragrunt `dependency` blocks; inside a unit it happens in the composition or infrastructure module (see [wiring](#how-the-modules-are-wired-together)). Infrastructure modules never reference each other directly.
- **Dashed orange arrow** is the one manual handoff: the bucket name from the bootstrap stack, written once into `live/root.hcl`.
- **Dashed boxes** are modules that exist but are switched off in the committed prod inputs.

### Deployed AWS architecture

What the bootstrap stack and the four units create in `eu-central-1` with the committed inputs.

![Deployed AWS architecture](docs/images/aws-architecture.svg)

---

## Repository layout

```text
.
├── bootstrap/remotebackend/eu-central-1/prod/   # S3 + DynamoDB + KMS for remote state (plain Terraform, state via backend.hcl)
│
├── live/                                 # Terragrunt: per-environment values, backend, ordering
│   ├── root.hcl                          #   remote_state (key per unit) + generated provider "aws"
│   └── eu-central-1/
│       ├── region.hcl                    #   region, region_tag
│       └── prod/
│           ├── env.hcl                   #   env, app_name, cluster_name
│           ├── network/terragrunt.hcl    #   → composition/network
│           ├── ecr/terragrunt.hcl        #   → composition/ecr
│           ├── eks/terragrunt.hcl        #   → composition/eks   (dependency: network)
│           └── ecs/terragrunt.hcl        #   → composition/ecs   (dependency: network, ecr)
│
├── composition/                          # LAYER 1: small root modules, no environment folders
│   ├── network/                          #   module "vpc" + module "vpn"
│   ├── ecr/                              #   module "ecr"
│   ├── eks/                              #   module "eks" + aws_caller_identity
│   └── ecs/                              #   module "ecs" (keeps the security-group self-wiring)
│
├── infrastructure_modules/               # LAYER 2: opinionated building blocks
│   ├── remotebackend/                    #   s3 + dynamodb + kms_key, bucket & key policies
│   ├── vpc/                              #   network/vpc + EKS subnet tags
│   ├── vpn/                              #   network/vpn
│   ├── eks/                              #   containers/eks
│   ├── ecr/                              #   containers/ecr
│   └── ecs/                              #   compute/sg (×2) + containers/ecs
│
├── resource_modules/                     # LAYER 3: generic resource wrappers
│   ├── compute/sg/
│   ├── containers/{ecr,ecs,eks}/
│   ├── database/dynamodb/
│   ├── identity/kms_key/
│   ├── network/{vpc,vpn}/
│   └── storage/s3/
│
├── docs/
│   ├── images/                           # architecture diagrams (SVG, rendered in this README)
│   └── diagrams/                         # editable draw.io sources of the same diagrams
├── mise.toml                             # pinned Terraform and Terragrunt versions
└── .github/workflows/main.yml            # Terraform GitHub Actions pipeline (currently commented out)
```

---

## The three layers

| Layer | Path | Responsibility | Knows about the environment? |
|---|---|---|---|
| **Terragrunt** | `live/<region>/<env>/<unit>/` | Generates the backend and AWS provider, holds the real values as `inputs`, orders the units and passes outputs between them. | Yes. This is the only place with real values. |
| **1 · Composition** | `composition/<component>/` | Root module run by one Terragrunt unit. Computes `locals` (tags, names), calls infrastructure modules and wires them together inside the unit. | No. Receives `env`, `region`, `app_name` and values as inputs. |
| **2 · Infrastructure** | `infrastructure_modules/<name>/` | Bundles resource modules into a usable unit. Adds naming conventions, tags, IAM/KMS policies and Kubernetes subnet tags. | Partly. Receives `env`, `app_name`, `region` and `tags` as inputs. |
| **3 · Resource** | `resource_modules/<category>/<name>/` | Wraps raw provider resources. Every resource has a `create_*` toggle via `count` / `for_each`. | No. Fully generic. |

Rules the layout enforces:

- A composition calls **only** infrastructure modules. An infrastructure module calls **only** resource modules.
- Modules never read each other's outputs directly. Values flow up to the composition and back down, or between units through Terragrunt `dependency` blocks (see [wiring](#how-the-modules-are-wired-together)).
- All module sources are relative paths, so the repo has no registry dependency.

---

## Module catalogue

### Infrastructure modules (layer 2)

| Module | Calls | What it adds | Key outputs |
|---|---|---|---|
| `remotebackend` | `storage/s3`, `database/dynamodb`, `identity/kms_key` | Region-coded names, a `random_integer` bucket suffix, an S3 bucket policy and a KMS key policy. Encrypts the bucket with the new CMK and enables versioning. | `s3_id`, `s3_arn`, `dynamodb_id`, `dynamodb_arn`, `s3_kms_arn`, `s3_kms_alias_arn`, `s3_kms_id` |
| `vpc` | `network/vpc` | Subnet tags `Tier` and `kubernetes.io/role/(internal-)elb`, plus `kubernetes.io/cluster/<cluster_name> = shared` so EKS load balancers can find subnets. | `vpc_id`, `vpc_cidr_block`, `public_subnets`, `private_subnets`, `isolate_subnets` (+ `*_cidr_blocks`) |
| `vpn` | `network/vpn` | Pass-through for customer gateways. | `customer_gateway_ids` |
| `eks` | `containers/eks` | Pass-through for cluster settings. | `cluster_id`, `cluster_arn`, `cluster_endpoint`, `cluster_version` |
| `ecr` | `containers/ecr` | Pass-through for the repository. | `ecr_repository_url` |
| `ecs` | `compute/sg` **twice** (`sg_alb`, `sg_service`), `containers/ecs` | An ALB security group, a service security group, and the Fargate service behind an ALB. | `security_group_alb_id`, `service_security_group_id` |

### Resource modules (layer 3)

| Module | Resources |
|---|---|
| `network/vpc` | `aws_vpc`, public / private / isolate `aws_subnet`, `aws_internet_gateway`, `aws_nat_gateway` + `aws_eip`, route tables, routes and associations |
| `network/vpn` | `aws_customer_gateway` (`for_each` over `customer_gateways`) |
| `compute/sg` | `aws_security_group`, ingress and egress `aws_security_group_rule` |
| `containers/ecr` | `aws_ecr_repository` |
| `containers/ecs` | `aws_ecs_cluster`, `aws_ecs_task_definition` (Fargate, 256 CPU / 512 MiB), `aws_ecs_service`, `aws_alb`, `aws_lb_listener` (:80), `aws_lb_target_group` (ip), task execution `aws_iam_role` |
| `containers/eks` | `aws_eks_cluster`, private `aws_eks_node_group`, `aws_iam_openid_connect_provider`, IAM roles / groups / users (admin, developer, read-only), `kubernetes_config_map_v1` (aws-auth), cluster roles / bindings, a namespace, and its own `kubernetes` provider |
| `storage/s3` | `aws_s3_bucket`, ACL, ownership controls, bucket policy, public access block, SSE configuration, versioning, CORS, accelerate |
| `database/dynamodb` | `aws_dynamodb_table` |
| `identity/kms_key` | `aws_kms_key`, `aws_kms_alias` |

---

## How the modules are wired together

Values between units are passed by Terragrunt `dependency` blocks in `live/eu-central-1/prod/<unit>/terragrunt.hcl`. Values inside a unit are wired in that unit's `composition/<component>/main.tf`.

| From | Output | To | Input | Wired in | Why |
|---|---|---|---|---|---|
| `network` unit | `public_subnets` | `eks` unit | `public_subnet_ids` → `cluster_public_subnets` | `live/…/eks/terragrunt.hcl` | Subnets for the EKS control-plane ENIs |
| `network` unit | `private_subnets` | `eks` unit | `private_subnet_ids` → `cluster_private_subnets` | `live/…/eks/terragrunt.hcl` | Subnets for the managed node group |
| `network` unit | `vpc_id` | `ecs` unit | `vpc_id` | `live/…/ecs/terragrunt.hcl` | Security groups and target group |
| `network` unit | `private_subnets` | `ecs` unit | `private_subnet_ids` → `subnets` | `live/…/ecs/terragrunt.hcl` | ALB and Fargate task ENIs (see [Known issues](#known-issues)) |
| `ecr` unit | `ecr_repository_url` | `ecs` unit | `ecr_repository_url` → `ecr_repo_url` | `live/…/ecs/terragrunt.hcl` | Container image for the task definition |
| `module.ecs` | `security_group_alb_id` | `module.ecs` | `sg_service_ingress_rules[0].source_security_group_id`, `alb_seurity_group_id` | `composition/ecs/main.tf` | ALB-only ingress to the service |
| `module.ecs` | `service_security_group_id` | `module.ecs` | `service_security_group_id` | `composition/ecs/main.tf` | Attaches the SG to the ECS service |
| `data.aws_caller_identity` | `account_id` | `module.eks` | `account_id` | `composition/eks/data.tf` | IAM ARNs in the EKS module |
| `local.vpc_tags` / `local.tags` | n/a | every module | `tags` | each root's `locals.tf` / `data.tf` | Consistent tagging |

Each `dependency` block has `mock_outputs` for `init`, `validate` and `plan`, so a fresh environment can be planned before `network` and `ecr` exist. `terragrunt run --all apply` applies `network` and `ecr` first, then `eks` and `ecs`.

**ECS self-reference.** The `ecs` module receives one of its own outputs (`security_group_alb_id`) as an input. This works because Terraform resolves dependencies per resource, not per module. `sg_alb` is created first. Its ID is then used for the `sg_service` ingress rule and the ALB. As a result, the service only accepts traffic from the load balancer. The ID can't come from inputs because it doesn't exist until apply time.

**Cross-stack wiring.** The bootstrap stack is not part of the Terragrunt graph. Its bucket name is written once into `live/root.hcl`, because Terraform needs the backend before `init`. Every unit stores its state in that bucket under `<region>/<env>/<unit>/terraform.tfstate`, with S3-native locking (`use_lockfile = true`).

---

## Naming and tagging

`composition/network/locals.tf` (`ecr` and `eks` compute the same `tags`):

```hcl
locals {
  tags = {
    Environment = var.env       # prod
    Application = var.app_name  # tf-moduler
    Terraform   = true
  }

  vpc_name = "vpc-${var.region_tag}-${var.env}-${var.app_name}"  # vpc-ec1-prod-tf-moduler
  vpc_tags = merge(local.tags, { "VPC-Name" = local.vpc_name })
}
```

`env`, `app_name` and `cluster_name` come from `live/<region>/<env>/env.hcl`. `region` and its short code `region_tag` (`ec1` for `eu-central-1`) come from `live/<region>/region.hcl`. The VPC infrastructure module still maps `region` to a short code itself (`us-east-1 → ue1`, `us-west-1 → uw1`, `eu-west-1 → ew1`, `eu-central-1 → ec1`, `ap-northeast-1 → apne1`), so add a new region there too.

The remote backend builds its names the same way:

| Resource | Pattern |
|---|---|
| S3 bucket | `s3-<region_tag>-<app_name>-<env>-terraform-backend-<1..100>` |
| DynamoDB table | `dynamo-<region_tag>-<app_name>-<env>-terraform-state-lock` |
| KMS alias | `alias/cmk-<region_tag>-<env>-s3-terraform-backend` |

---

## Feature flags

Every module can be switched on or off from the `inputs` in `live/eu-central-1/prod/<unit>/terragrunt.hcl`. Disabled modules create no resources.

| Flag | Prod value | Effect |
|---|---|---|
| `create_vpc` | `true` | VPC, 9 subnets (3 × public / private / isolate), IGW, single NAT gateway |
| `create_vpn` / `create_customer_gateway` | `false` / `false` | Customer gateways from `customer_gateways` (both must be `true`) |
| `create_eks` | `false` | EKS 1.32 cluster, node group, OIDC, IAM and RBAC |
| `create_ecr` | `true` | ECR repository `tf-moduler` |
| `create_sg` | `true` | ALB and service security groups |
| `create_ecs` | `true` | ECS cluster, task definition, service, ALB, target group |

Network values for prod:

| Tier | CIDRs (AZ a / c / b) | Default route |
|---|---|---|
| VPC | `10.1.0.0/16` | n/a |
| Public | `10.1.1.0/24`, `10.1.2.0/24`, `10.1.3.0/24` | Internet gateway |
| Private | `10.1.101.0/24`, `10.1.102.0/24`, `10.1.103.0/24` | Single NAT gateway (AZ a) |
| Isolate | `10.1.105.0/24`, `10.1.106.0/24`, `10.1.107.0/24` | None |

---

## Prerequisites

- **Terraform** `1.16.6` and **Terragrunt** `1.1.6`, pinned in `mise.toml` (`mise install`).
- **AWS credentials** for the target account, e.g. `export AWS_PROFILE=default`. The units get their provider region from `live/root.hcl`. The bootstrap stack sets no provider region, so export `AWS_REGION=eu-central-1` when you apply it. Its `region`, `role_name` and `profile_name` variables are used for naming only.
- **Providers** (installed on `init`; versions locked in each `.terraform.lock.hcl`):

  | Provider | Source | Version | Used by |
  |---|---|---|---|
  | aws | `hashicorp/aws` | `>= 6.33.0` | bootstrap and all units |
  | kubernetes | `hashicorp/kubernetes` | `~> 3.0.1` | `composition/eks` (`containers/eks`) |
  | random | `hashicorp/random` | latest | `infrastructure_modules/remotebackend` |

---

## Deployment

The state bucket has to exist before the units can store state in it. Deploy in this order:

### 1. Bootstrap the remote backend

In a new account the bucket doesn't exist yet, so the first apply uses local state. Comment out `backend "s3" {}` in `providers.tf` for this run:

```bash
cd bootstrap/remotebackend/eu-central-1/prod
terraform init
terraform apply
terraform output -raw s3_terraform_remote_backend_id
```

Then move the bootstrap state into the bucket. Restore `backend "s3" {}`, put the bucket name into [backend.hcl](bootstrap/remotebackend/eu-central-1/prod/backend.hcl), and run:

```bash
terraform init -backend-config=backend.hcl -migrate-state
```

The state then lives at `bootstrap/eu-central-1/prod/terraform.tfstate` in the bucket, which is versioned, and the local `terraform.tfstate` can be deleted. The DynamoDB table this stack creates is not used: every state locks with `use_lockfile = true`.

### 2. Set the bucket in `live/root.hcl`

Put the bucket name from step 1 into `remote_state.config.bucket` in [live/root.hcl](live/root.hcl) and commit it.

### 3. Deploy the units

```bash
cd live/eu-central-1/prod
terragrunt run --all plan
terragrunt run --all apply
```

Terragrunt applies `network` and `ecr` first, then `eks` and `ecs`. To work on one unit, run `terragrunt plan` / `terragrunt apply` in its folder. Don't pass `--backend-bootstrap`: the bucket comes from step 1.

### Tear down

Destroy the units first (`terragrunt run --all destroy` in `live/eu-central-1/prod`; Terragrunt reverses the order), then the bootstrap stack. The state bucket has `force_destroy = false`, so empty it first.

---

## Outputs

### Units (`terragrunt output` in `live/eu-central-1/prod/<unit>`)

| Unit | Outputs |
|---|---|
| `network` | `vpc_id`, `vpc_cidr_block`, `public_subnets`, `private_subnets`, `isolate_subnets`, `*_subnets_cidr_blocks`, `customer_gateway_ids` |
| `eks` | `cluster_id`, `cluster_arn`, `cluster_endpoint`, `cluster_version` |
| `ecr` | `ecr_repository_url` |
| `ecs` | `security_group_alb_id`, `service_security_group_id` |

### `bootstrap/remotebackend/eu-central-1/prod`

| Group | Outputs |
|---|---|
| S3 | `s3_terraform_remote_backend_id`, `s3_terraform_remote_backend_arn` |
| DynamoDB | `dynamodb_terraform_state_lock_id`, `dynamodb_terraform_state_lock_arn` |
| KMS | `s3_kms_terraform_backend_arn`, `s3_kms_terraform_backend_alias_arn`, `s3_kms_terraform_backend_id` |

---

## Extending the codebase

**New environment or region.** Copy a `live/` environment folder and change only the values. No `.tf` files are copied:

```bash
cp -r live/eu-central-1/prod live/eu-central-1/staging
# edit env.hcl (env, app_name, cluster_name) and the unit inputs (CIDRs, names …)
```

The state key comes from the folder path, so the new environment gets its own states. For a new region, add `live/<region>/region.hcl` with `region` and `region_tag`, and make sure the region exists in the VPC module's `region_tag` map.

**New AWS capability.** Build it bottom-up:

1. `resource_modules/<category>/<name>/`: raw resources behind a `create_*` flag, with no environment logic.
2. `infrastructure_modules/<name>/`: call the resource module(s) and add naming, tags and policies.
3. `composition/<component>/`: add the `module` block to an existing root, or create a new root with `main.tf`, typed `variables.tf`, `outputs.tf` and `versions.tf`.
4. `live/<region>/<env>/<unit>/terragrunt.hcl`: for a new root, add a unit with its `inputs` and any `dependency` blocks.

---

## CI/CD

[.github/workflows/main.yml](.github/workflows/main.yml) contains a full pipeline, but it is **commented out**. It still targets the old single-root layout with plain `terraform`, so it has to be rewritten for Terragrunt (`terragrunt run --all plan` / `apply` in `live/`) before it is enabled. As written:

| Trigger | Steps |
|---|---|
| Pull request | `fmt -check` → `init` → `validate` → `plan`, then posts the plan as a PR comment |
| Push to `main` | `fmt -check` → `init` → `validate` → `apply -auto-approve` |

It authenticates through GitHub OIDC and needs these repository secrets: `AWS_ROLE`, `AWS_REGION`, `AWS_BUCKET_NAME`, `AWS_BUCKET_KEY_NAME`.

---

## Known issues

These come from reading the current code. Fix them before relying on the stack in production.

1. **The ALB is not reachable from the internet.** `module.ecs` gets `subnets = var.private_subnet_ids` (the `network` unit's private subnets). `containers/ecs` uses that one list for both the ALB and the service. The ALB is internet-facing (no `internal` flag), but private subnets route `0.0.0.0/0` to the NAT gateway, not the IGW. Add a separate `alb_subnets` input fed from the `network` unit's `public_subnets`. Also note that `assign_public_ip = true` on the service is pointless in private subnets: the public IP has no IGW route.
2. **`eu-central-1` appears twice in the remote backend's `region_tag`.** In [infrastructure_modules/remotebackend/data.tf](infrastructure_modules/remotebackend/data.tf) it is mapped to both `ec1` and `euc1`. Terraform keeps the last one, so backend resources are named `…-euc1-…` while the units use `ec1`. Remove one entry. Changing it on a deployed backend renames, and so replaces, the bucket, table and KMS alias.
3. **Some variable names are misspelled.** `task_famliy` and `alb_seurity_group_id` are misspelled across all three layers. Renaming them is a breaking interface change, so do it in one pass.
4. **`containers/eks` declares its own `kubernetes` provider.** A module that configures a provider can't use `count` / `for_each` / `depends_on` and is awkward to remove. Consider moving the provider into `composition/eks`.
