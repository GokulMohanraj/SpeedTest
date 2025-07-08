provider "aws" {
  region = var.aws_region
}

# AWS Key Pair
data "aws_key_pair" "existing_key" {
  key_name = var.key_name
}

# Security Group
resource "aws_security_group" "speedtest_sg" {
  name        = var.security_group_name
  description = "Security group for Speedtest EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = [
      {
        description = "Allow HTTP traffic"
        from_port   = 80
        to_port     = 80
      },
      {
        description = "Allow NodePort range for Kubernetes"
        from_port   = 30000
        to_port     = 32767
      },
      {
        description = "Allow app port (8081)"
        from_port   = 8081
        to_port     = 8081
      },
      {
        description = "Allow SSH"
        from_port   = 22
        to_port     = 22
      }
    ]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound
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

# IAM Role for EC2 Instance
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3access-instance-profile"
  role = var.role_name 
}


# EC2 Instance

resource "aws_instance" "speedtest" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.existing_key.key_name
  security_groups = [aws_security_group.speedtest_sg.name]
  iam_instance_profile = aws_iam_instance_profile.s3_access_profile.name
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