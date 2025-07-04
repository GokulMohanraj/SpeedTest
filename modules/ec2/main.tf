resource "aws_instance" "speedtest" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.existing_key.key_name
  security_groups = [var.security_group_name]
  tags = {
    Name = "Speedtest-Instance"
  }
}

data "aws_key_pair" "existing_key" {
  key_name = var.key_name
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


