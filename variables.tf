variable "components" {
  type        = list(string)
  description = "List of server/component names to be created. Each entry in the list results in one EC2 instance being provisioned. Example: [\"web\", \"app\", \"db\"]"
}

variable "ami_id" {
  type        = string
  description = "The Amazon Machine Image (AMI) ID used to launch the EC2 instances. Must be a valid AMI ID available in the target AWS region. Example: \"ami-0abcdef1234567890\""
}

variable "sg_ids" {
  type        = list(string)
  description = "List of Security Group IDs to associate with the EC2 instances. Controls inbound and outbound traffic rules applied to each instance. Example: [\"sg-0abc123\", \"sg-0def456\"]"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type that determines the compute, memory, and networking capacity. Allowed values are 't3.micro' (for low-traffic/dev environments) and 't3.small' (for slightly higher workloads)."
  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "Please select only either t3.micro or t3.small"
  }
}

variable "subnet_id" {
  type = string
  description = "please provide the subnet_id for the instance"
}

variable "common_tags" {
  type        = map(string)
  description = "A map of common tags to apply to all EC2 instances. Used for cost allocation, resource tracking, and organizational purposes. Example: { Owner = \"devops\", Team = \"platform\" }"
}

variable "environment" {
  type        = string
  description = "The deployment environment name (e.g., 'dev', 'staging', 'prod'). Combined with the project name to form a unique identifier used in resource naming and tagging."
}

variable "project" {
  type        = string
  description = "The name of the project this module is being deployed for. Combined with the environment name to form a unique common name used across resource names and tags. Example: \"myapp\""
}
