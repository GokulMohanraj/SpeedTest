remote_state {
  backend = "s3"
  config = {
    bucket         = "bucket-for-speedtest"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}