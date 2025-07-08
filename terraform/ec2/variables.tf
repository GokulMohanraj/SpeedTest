variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the existing SSH key pair to use for the EC2 instance"
  type        = string
  default     = "speedtest_key"
  
}

variable "security_group_name" {
  description = "The name of the security group to create"
  type        = string
  default     = "speedtest-sg" 
}