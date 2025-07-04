provider "aws" {
  region = var.aws_region
}

# AWS Key Pair
data "aws_key_pair" "existing_key" {
  key_name = var.key_name
}