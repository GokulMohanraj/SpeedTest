terraform {
  
  source = "../../../modules/ec2"
  
}


inputs = {
    region="ap-south-1"
    environment="prod"
    ami_id        = ""  # Change to a valid AMI ID
    instance_type = "t2.micro"
    instance_name = "dev-ec2-instance"
}