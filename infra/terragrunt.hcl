remote_state {
  backend = "s3"
  config = {
    bucket         = "bucket-for-speedtest"
    key            = "terraform/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}