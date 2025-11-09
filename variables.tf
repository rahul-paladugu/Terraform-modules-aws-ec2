variable "ami" {
  default = "ami-09c813fb71547fc4f"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "sg_id" {
  default = ["sg-07ccd5bad18a4e9c6"]
}

variable "tags" {
    default = {
        Name = "Module-Test"
        Environment = "Test"
    }
  
}