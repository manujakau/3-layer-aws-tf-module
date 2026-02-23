3-layered approach to Terraform

![Image](https://github.com/user-attachments/assets/2ab601a3-d731-4b54-9ff3-5bcbf1590a28)


### Infrastructure Logic Diagram

This diagram illustrates the flow of data from external inputs into the internal logic and between specific infrastructure modules.

graph TD

    subgraph Inputs [Input Layer]
        TFVARS[terraform.tfvars] -- "Assigns values" --> VARS[variables.tf]
    end

    subgraph Logic [Logic & Data Layer]
        VARS -- "Provides env, app_name, region" --> LOCALS[locals in data.tf]
        CALLER[data.aws_caller_identity] -- "account_id" --> LOCALS
    end

    subgraph Modules [Infrastructure Modules]
        direction TB
        VARS --> VPC[Module: VPC]
        VARS --> VPN[Module: VPN]
        VARS --> ECR[Module: ECR]

        LOCALS -- "tags, vpc_tags" --> VPC
        LOCALS -- "tags" --> VPN
        LOCALS -- "tags, account_id" --> EKS[Module: EKS]
        LOCALS -- "tags" --> ECR
        LOCALS -- "tags" --> ECS[Module: ECS]

        VPC -- "public/private_subnets" --> EKS
        VPC -- "vpc_id, private_subnets" --> ECS
        ECR -- "ecr_repository_url" --> ECS
        
        ECS -- "security_group_alb_id" --> ECS_Rules[ECS Internal Ingress]
    end

    subgraph Results [Output Layer]
        VPC --> OUT[outputs.tf]
        VPN --> OUT
        EKS --> OUT
        ECR --> OUT
        ECS --> OUT
    end


# Terraform Project: Modular Infrastructure Architecture

---

## 1. Project Overview & Purpose

This repository maintains a highly structured and modular Terraform framework designed for the automated provisioning of containerized environments on AWS.

By leveraging a modular pattern, the architecture decouples core infrastructure components — networking, security, and container orchestration (EKS or ECS) — into reusable units.

The primary objective is to facilitate consistent, environment-agnostic deployments (e.g., Production, Staging) while adhering to industry best practices for scalability and security.

This project emphasizes a programmatic approach to infrastructure, ensuring that complex dependencies between networking layers and compute clusters are managed through a well-defined **Chain of Dependencies**.

---

## 2. Prerequisites

Before initiating a deployment, ensure the following technical requirements and provider configurations are met.

### Terraform Requirements

- **Terraform Version:** `>= 1.0`
- **Remote State Management:**  
  This project utilizes a partial backend configuration.  
  Because the backend block contains:

```hcl
backend "s3" {}
```

You must provide a `backend.config` file during initialization to define:

- S3 bucket
- State key
- Region
- (Optional) DynamoDB table for locking

Initialize with:

```bash
terraform init -backend-config=backend.config
```

---

### Required Providers

| Provider   | Source            | Version      | Configuration Aliases |
|------------|------------------|--------------|-----------------------|
| aws        | hashicorp/aws     | >= 6.33.0    | aws.XXX_old           |
| http       | hashicorp/http    | ~> 3.5.0     | N/A                   |
| helm       | hashicorp/helm    | ~> 3.1.1     | N/A                   |
| kubernetes | hashicorp/kubernetes | ~> 3.0.1 | N/A                   |

---

## 3. Architecture & Data Flow

The infrastructure lifecycle follows a rigorous three-stage data flow designed to maintain **DRY (Don't Repeat Yourself)** principles and ensure configuration integrity.

### 1️⃣ Input Phase

Global configuration values are ingested via `terraform.tfvars`.

Key inputs include:

- `region`
- `env`
- `app_name`

---

### 2️⃣ Logic & Transformation Phase

Raw variables are processed within the `locals` block.

To maintain naming consistency across global deployments:

- `vpc_name` is dynamically generated.
- A lookup against the `region_tag` map (defined in `variables.txt`) converts:
  - `eu-central-1` → `ec1`

---

### 3️⃣ Provisioning Phase

Transformed locals and validated variables are passed into infrastructure modules defined in:

```
main.tf
```

---

## 4. Variable Definitions & Logic Transformations

### Input Variables

| Variable   | Description | Value |
|------------|------------|-------|
| region     | AWS region for deployment | eu-central-1 |
| env        | Target deployment environment | prod |
| app_name   | Unique application identifier | tf-moduler |
| cidr       | CIDR block for the VPC (overridden) | 10.1.0.0/16 |

> Note: Although `cidr` has a global default of `0.0.0.0/0`, it is explicitly overridden here.

---

### Local Logic

```hcl
locals {
  account_id = data.aws_caller_identity.current.account_id

  tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }

  ## VPC ##
  vpc_name = "vpc-${var.region_tag[var.region]}-${var.env}-${var.app_name}"

  vpc_tags = merge(
    local.tags,
    tomap({
      "VPC-Name" = local.vpc_name
    })
  )
}
```

### Explanation

- **account_id**  
  Retrieved using `aws_caller_identity` to ensure account context correctness.

- **Standard tags**  
  Base metadata map applied to all resources.

- **Specialized `vpc_tags`**  
  Extends base tags with a unique `VPC-Name`.

- **VPC Naming Strategy**  
  Uses region short-codes to enforce global naming consistency.

---

## 5. Module Interaction & Dependency Mapping

The project implements a **Chain of Dependencies** to ensure stable and logical provisioning.

---

### Networking Foundation

The **VPC module** acts as the primary provider.

Its outputs:
- Public Subnet IDs
- Private Subnet IDs

These are consumed by:
- EKS module
- ECS module

---

### Container Registry Flow

The **ECS module** depends directly on the **ECR module**.

Flow:

```
ECR → Repository URL → ECS Task Definition → Service Deployment
```

---

### Security Group Coupling & Least Privilege

Inside the ECS module:

```hcl
sg_service_ingress_rules → module.ecs.security_group_alb_id
```

#### Advanced Dependency Handling

By referencing its own output:

- Terraform finalizes the ALB Security Group first
- Then creates service ingress rules

#### Principle of Least Privilege

This guarantees:

- ECS service accepts traffic **only** from the ALB
- No broad ingress rules
- Strict layer isolation

---

## 6. Infrastructure Module Descriptions

All modules are sourced from relative paths inside:

```
../../../../infrastructure_modules/
```

---

### VPC Module

**Path:** `vpc`

- Creates 3 subnet tiers:
  - Public
  - Private
  - Isolate
- `single_nat_gateway = true`
- Optimizes cost while enabling private subnet egress

---

### VPN Module

**Path:** `vpn`

- Controlled by `create_vpn`
- Supports:
  - Customer Gateway (CGW)
  - Site-to-site tunnels

---

### EKS Module

**Path:** `eks`

- Kubernetes version: **1.32**
- OIDC root CA thumbprint integration
- Multi-tier subnet integration

---

### ECR Module

**Path:** `ecr`

- Provisions Elastic Container Registry
- Uses standard tagging
- Supports lifecycle management

---

### ECS Module

**Path:** `ecs`

- Deploys containerized service
- Integrates:
  - ALB
  - Target Groups
  - Task Definitions
- Application listens on:

```
container_port = 3000
```

---

## 7. Deployment Instructions

Because of partial backend configuration, deployment requires multiple stages.

### Step 1 – Initialize

```bash
terraform init -backend-config=backend.config
```

### Step 2 – Review Plan

```bash
terraform plan
```

### Step 3 – Apply

```bash
terraform apply
```

---

## 8. Outputs

After successful deployment, the following outputs are exported.

---

### Networking & VPN

- VPC ID  
- Public Subnet IDs  
- Private Subnet IDs  
- Isolate Subnet IDs  
- Customer Gateway IDs  

---

### Compute

- EKS Cluster ARN  
- EKS Cluster Endpoint  
- EKS Version  
- ECR Repository URL  

---

### Security

- ALB Security Group ID  
- ECS Service Security Group ID  

---

# Design Principles

- Modular Architecture  
- DRY Configuration  
- Explicit Dependency Chaining  
- Least Privilege Security  
- Environment Agnostic  
- Reusable Infrastructure Components  

---