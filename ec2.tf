#Create instance required for the project by capturing ami-id dynamically using data query.
resource "aws_instance" "main" {
  count         = length(var.components) #Mandatory
  ami           = var.ami_id #Mandatory
  vpc_security_group_ids = var.sg_ids #Mandatory
  instance_type = var.instance_type #Mandatory
  tags          = merge({Name = "var.components[count.index]-${local.common_name}"}, var.common_tags)
  provisioner "local-exec" {
  command = "echo The server's IP address is ${self.private_ip}"
  on_failure = continue
  }
}
