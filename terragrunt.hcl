terraform {
  backend "s3" {
    bucket         = "bucket-for-speedtest" # Must exist
    key            = "terraform/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-table" # Must exist in AWS
  }
}