terraform {
  
  source = "../../../modules/vpc"
  
}

inputs = {
  environment = "dev"
  cidr_block  = "0.0.0.0/0"
  vpc_name    = "dev-vpc"
}

/*include {
  path = find_in_parent_folders()

}*/