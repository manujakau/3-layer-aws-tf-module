3-layered approach to Terraform

![Image](https://github.com/user-attachments/assets/2ab601a3-d731-4b54-9ff3-5bcbf1590a28)


Infrastructure Logic Diagram
This diagram illustrates the flow of data from external inputs into the internal logic and between specific infrastructure modules.
graph TD
    subgraph Inputs
        TFVARS[terraform.tfvars] -->|Assigns values to| VARS[variables.tf]
    end

    subgraph Internal Logic
        VARS -->|Input to| LOCALS[locals in data.tf]
        DATA[Data Sources] -->|Account ID| LOCALS
    end

    subgraph Modules
        VARS -->|Configures| VPC[Module: VPC]
        VARS -->|Configures| ECR[Module: ECR]
        LOCALS -->|Tags/Account ID| EKS[Module: EKS]
        LOCALS -->|Tags| ECS[Module: ECS]
        
        VPC -->|vpc_id / subnets| ECS
        VPC -->|subnets| EKS
        ECR -->|repository_url| ECS
        ECS -->|alb_security_group_id| ECS_RULES[Security Group Rules]
    end

    subgraph Outputs
        VPC -->|vpc_id| OUT[outputs.tf]
        EKS -->|cluster_endpoint| OUT
        ECS -->|security_group_id| OUT
    end