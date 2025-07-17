resource "aws_instance" "speedtest" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  security_groups = [var.security_group_name]
  tags = {
    Name = "Speedtest-Instance"
  }
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

# IAM Role for EC2 Instance
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3access-instance-profile"
  role = var.role_name 
}