# Terraform Module — AWS EC2 Instances

A reusable Terraform module for provisioning one or more AWS EC2 instances dynamically based on a list of component names. Instances are named consistently using a combination of the component name, environment, and project — making it easy to manage multi-tier architectures across multiple environments.

---

## Features

- Provision **multiple EC2 instances** in a single module call using a component list
- Consistent **naming convention** using `environment` and `project` locals
- Enforced **instance type validation** (only `t3.micro` or `t3.small` allowed)
- Common **tagging** support for cost allocation and resource tracking
- Built-in **local-exec provisioner** to log the private IP of each instance on creation

---

## Usage

```hcl
module "ec2_instances" {
  source = "./path-to-this-module"

  components    = ["web", "app", "db"]
  ami_id        = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  sg_ids        = ["sg-0abc12345", "sg-0def67890"]
  environment   = "dev"
  project       = "myapp"

  common_tags = {
    Owner   = "devops-team"
    Team    = "platform"
    CostCenter = "engineering"
  }
}
```

This will create **3 EC2 instances** named:
- `web-dev-myapp`
- `app-dev-myapp`
- `db-dev-myapp`

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0 |

---

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

---

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `components` | `list(string)` | ✅ Yes | List of server/component names to be created. Each entry results in one EC2 instance. Example: `["web", "app", "db"]` |
| `ami_id` | `string` | ✅ Yes | The AMI ID used to launch the EC2 instances. Must be valid in the target AWS region. |
| `sg_ids` | `list(string)` | ✅ Yes | List of Security Group IDs to associate with the instances. |
| `instance_type` | `string` | ✅ Yes | EC2 instance type. Allowed values: `t3.micro` or `t3.small`. |
| `common_tags` | `map(string)` | ✅ Yes | Map of tags applied to all EC2 instances. Used for cost allocation and tracking. |
| `environment` | `string` | ✅ Yes | Deployment environment name (e.g., `dev`, `staging`, `prod`). Used in resource naming. |
| `project` | `string` | ✅ Yes | Project name. Combined with `environment` to form a common name used in resource tags. |

---

## Outputs

> This module does not currently define output variables.  
> Consider adding outputs like `instance_ids` and `private_ips` for use in downstream modules.

Suggested outputs to add in `outputs.tf`:

```hcl
output "instance_ids" {
  description = "List of EC2 instance IDs created by this module"
  value       = aws_instance.main[*].id
}

output "private_ips" {
  description = "List of private IP addresses of the created EC2 instances"
  value       = aws_instance.main[*].private_ip
}
```

---

## Resource Naming Convention

This module uses a local value to enforce a consistent naming pattern:

```
<component>-<environment>-<project>
```

For example, with `component = "web"`, `environment = "prod"`, `project = "myapp"`:
```
web-prod-myapp
```

---

## Validation

The `instance_type` variable is validated to only accept the following values:

| Value | Use Case |
|-------|----------|
| `t3.micro` | Development / low-traffic workloads |
| `t3.small` | Staging / moderate workloads |

Any other value will cause Terraform to fail with the error:
```
Please select only either t3.micro or t3.small
```

---

## File Structure

```
.
├── ec2.tf          # EC2 instance resource definition
├── local.tf        # Local values (common_name)
├── variables.tf    # Input variable definitions
└── README.md       # Module documentation
```

---

## Notes

- The `local-exec` provisioner logs each instance's private IP to your local terminal on `terraform apply`. Failures are non-blocking (`on_failure = continue`).
- Ensure the IAM role/user running Terraform has `ec2:RunInstances` and related permissions.
- The AMI ID must exist in the AWS region configured in your provider block.

---

## Author

**Rahul Paladugu**  
GitHub: [rahul-paladugu](https://github.com/rahul-paladugu)

---

## License

This module is open-source and available under the [MIT License](LICENSE).
