# terraform-aws-ec2

> **Internal Terraform Module** | Maintained by the Platform Engineering team

A standardized, reusable Terraform module for provisioning AWS EC2 instances across all environments in our infrastructure. This module enforces naming conventions, tagging standards, and approved instance types — ensuring every compute resource deployed in our AWS accounts is consistent, traceable, and cost-accountable.

Designed to be consumed by application teams via their product-level Terraform stacks. Do **not** create EC2 resources directly — use this module.

---

## When to Use This Module

Use this module when your service or component requires:

- One or more EC2 instances as part of a product stack (e.g. API servers, workers, batch processors)
- Consistent resource naming tied to environment and project
- Centrally enforced tagging for cost allocation and ownership tracking


## Quick Start

```hcl
module "app_servers" {
  source = "git::https://github.com/rahul-paladugu/Terraform-modules-aws-ec2.git?ref=v1.0.0"

  components    = ["api", "worker"]
  ami_id        = "ami-0abcdef1234567890"
  instance_type = "t3.small"
  sg_ids        = [aws_security_group.app.id]
  environment   = "prod"
  project       = "payments"

  common_tags = {
    Owner      = "platform-engineering"
    CostCenter = "product-payments"
    ManagedBy  = "terraform"
  }
}
```

This provisions two EC2 instances named:
- `api-prod-payments`
- `worker-prod-payments`

## Requirements

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.3.0` |
| AWS Provider | `>= 4.0` |
| AWS CLI | `>= 2.0` (for local development) |

### IAM Permissions

The AWS IAM role executing this module must have the following permissions:

```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:RunInstances",
    "ec2:DescribeInstances",
    "ec2:TerminateInstances",
    "ec2:CreateTags",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeImages"
  ],
  "Resource": "*"
}
```

---

## Inputs

All inputs are **mandatory** — this module has no optional variables or defaults. Every value must be explicitly set by the consuming stack.

| Name | Type | Description |
|------|------|-------------|
| `components` | `list(string)` | Names of the components to provision. One EC2 instance is created per entry. e.g. `["api", "worker"]` |
| `ami_id` | `string` | AMI ID used to launch all instances. Must be valid in the target AWS region. |
| `instance_type` | `string` | EC2 instance type. Restricted to `t3.micro` or `t3.small` — see approved types below. |
| `sg_ids` | `list(string)` | Security Group IDs to attach to every instance. Must be pre-created outside this module. |
| `environment` | `string` | Deployment environment — `dev`, `staging`, or `prod`. Used in resource naming and tagging. |
| `project` | `string` | Project or product name this infrastructure belongs to. Used in resource naming. |
| `common_tags` | `map(string)` | Tags applied to all instances. Must include `Owner`, `CostCenter`, and `ManagedBy`. |

### Approved Instance Types

Only the following instance types are accepted. Any other value will fail at `terraform plan` with a validation error.

| Instance Type | vCPU | RAM | Recommended For |
|---------------|------|-----|-----------------|
| `t3.micro` | 2 | 1 GiB | Dev and staging only — low-traffic services and feature testing. |
| `t3.small` | 2 | 2 GiB | All environments — use for prod or memory-sensitive workloads. |

> Need a larger instance type? Raise a request via `#platform-engineering` on Slack.

---

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `public_ip` | `list(string)` | Public IP addresses of all provisioned instances, in the same order as `components`. Use index to target a specific instance, e.g. `module.app_servers.public_ip[0]`. Returns empty string if no public IP is assigned. |
| `private_ip` | `list(string)` | Private IP addresses of all provisioned instances within the VPC. Prefer private IPs for internal service-to-service communication. |

**Referencing outputs in your stack:**

```hcl
# Get the private IP of the first component (e.g. "api")
output "api_private_ip" {
  value = module.app_servers.private_ip[0]
}

# Pass all private IPs to another module (e.g. a load balancer)
module "internal_lb" {
  source     = "..."
  target_ips = module.app_servers.private_ip
}
```

---

## Resource Naming Convention

All resources follow our platform naming standard:

```
<component>-<environment>-<project>
```

| Variable | Example Value | Result |
|----------|--------------|--------|
| `component = "api"` | `environment = "prod"` | `api-prod-payments` |
| `component = "worker"` | `environment = "staging"` | `worker-staging-payments` |

This naming is enforced via the `local.common_name` local and the `Name` tag on every instance. Do not override or bypass this.

---

## Tagging Policy

All instances provisioned by this module are tagged with a merged set of:
- The `Name` tag (auto-generated from naming convention)
- All key-value pairs from `common_tags`

**Required tags** (enforced by our AWS Config rules):

| Tag Key | Example Value | Purpose |
|---------|--------------|---------|
| `Owner` | `platform-engineering` | Team responsible for the resource |
| `CostCenter` | `product-payments` | For cost allocation reports |
| `ManagedBy` | `terraform` | Identifies IaC-managed resources |
| `Name` | `api-prod-payments` | Auto-set by this module |

---

## How It Works

```
components = ["api", "worker"]
        │
        ▼
count = length(components) → 2 instances
        │
        ├── aws_instance.main[0] → "api-prod-payments"
        └── aws_instance.main[1] → "worker-prod-payments"
                │
                └── local-exec: logs private_ip to CI/CD output
```

On `terraform apply`, a `local-exec` provisioner runs on each instance and prints its private IP to the pipeline output — useful for quick verification during deployments. Failures are non-blocking (`on_failure = continue`).

---

## File Structure

```
terraform-aws-ec2/
├── ec2.tf          # Core EC2 resource definition with count-based provisioning
├── variables.tf    # All input variable declarations with types and descriptions
├── outputs.tf      # Exposes public_ip and private_ip as lists
├── local.tf        # Builds the common_name local from environment + project
└── README.md       # This file
```

---

## Local Development & Testing

```bash
# Clone the module
git clone https://github.com/rahul-paladugu/Terraform-modules-aws-ec2.git
cd Terraform-modules-aws-ec2

# Initialise Terraform
terraform init

# Validate the module syntax
terraform validate

# Plan with a sample tfvars
terraform plan -var-file="examples/dev.tfvars"
```

Sample `examples/dev.tfvars`:

```hcl
components    = ["api"]
ami_id        = "ami-0abcdef1234567890"
instance_type = "t3.micro"
sg_ids        = ["sg-0abc123"]
environment   = "dev"
project       = "myapp"

common_tags = {
  Owner      = "platform-engineering"
  CostCenter = "product-myapp"
  ManagedBy  = "terraform"
}
```
