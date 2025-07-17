data "aws_vpc" "default" {
  default = true
}

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

