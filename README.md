3-layered approach to Terraform

![Image](https://github.com/user-attachments/assets/2ab601a3-d731-4b54-9ff3-5bcbf1590a28)


Infrastructure Logic Diagram

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