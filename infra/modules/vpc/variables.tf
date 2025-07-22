variable "security_group_name" {
  description = "The name of the security group to create"
  type        = string
  default     = "speedtest-sg" 
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}