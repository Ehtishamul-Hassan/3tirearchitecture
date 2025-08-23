# AWS 3‑Tier with CloudFront + WAF + Nginx Reverse Proxy + Public & Internal ALBs (Terraform Skeleton)

This is a **starter skeleton** you can adapt. It creates the main building blocks:
- VPC with **2 public** and **6 private** subnets (across 2 AZs)
- **VPC Endpoints** (Gateway + Interface) for private egress
- **Nginx reverse proxy** in public subnets behind a **public ALB** (CloudFront origin)
- **Public ALB** (receives from Nginx) → **Frontend ASG/ECS**
- **Internal ALB** between Frontend and Backend
- **Backend ASG/ECS**
- **RDS (Multi‑AZ)** + Subnet group
- **CloudFront** in front + **WAF** with managed rules

> This is a skeleton: many values are intentionally variables/defaults. Wire in your AMIs, container/task defs, TLS certs, etc.

## Quick Start
```bash
cd env/dev
cp example.tfvars terraform.tfvars
# Update values in terraform.tfvars
terraform init
terraform plan
terraform apply
```
