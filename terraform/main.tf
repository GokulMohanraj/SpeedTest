provider "aws" {
  region = var.aws_region
}

# Key Pair
# Generate a new SSH key pair for EC2 access
# This will save a private key file named "speedtest-key.pem" in your local directory.
# KEEP THIS FILE SECURE!
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "speedtest_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "speedtest_private_key" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${var.key_name}.pem"
  file_permission = "0400"
}

# Security Group
resource "aws_security_group" "speedtest_sg" {
  name        = var.security_group_name
  description = "Security group for Speedtest EC2 instance"
  vpc_id      = data.aws_vpc.default.id # Default VPC
  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  ingress {
    description = "Allow SSH traffic from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# Data source to fetch the default VPC (optional, but good practice)
data "aws_vpc" "default" {
  default = true
}

# EC2 Instance

resource "aws_instance" "speedtest" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.speedtest_key.key_name
  security_groups = [aws_security_group.speedtest_sg.name]
  tags = {
    Name = "Speedtest-Instance"
  }
}

# Data source to fetch the latest Ubuntu AMI

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
  owners      = ["099720109477"] # Canonical's official Ubuntu AMI owner ID
}

terraform {
  backend "s3" {
    bucket         = "bucket-for-speedtest" # Must exist
    key            = "terraform/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-table" # Must exist in AWS
  }
}