module "application-server" {
  source = "../Terraform-AWS-Module"
  ami = var.ami
  instance_type = var.instance_type
  sg_id = var.sg_id
}

output "priv-ip" {
  value = module.application-server.private_ip
}

output "pub-ip" {
  value = module.application-server.public_ip
}

output "inst-id" {
  value = module.application-server.instance_id
}