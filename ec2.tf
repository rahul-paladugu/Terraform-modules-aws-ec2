#Create an instance using this module for your project
resource "aws_instance" "main" {
  count                = length(var.components) #Mandatory
  ami                  = var.ami_id #Mandatory
  subnet_id            = var.subnet_id
  instance_type        = var.instance_type #Mandatory
  iam_instance_profile = var.iam_instance_profile
vpc_security_group_ids = var.sg_ids #Mandatory
  tags                 = merge({Name = "${var.components[count.index]}-${local.common_name}"}, var.common_tags)
}
