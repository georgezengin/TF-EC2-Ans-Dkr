/* This Terraform deployment creates the following resources:
   VPC, Subnet, Internet Gateway, Default Route, 
   Security Group, SSH Key, and EC2 with userdata script installing Jenkins */


module "network" {
  source = "./modules/network"
  # pass project variables from terraform.tfvars
  v_environment       = var.v_environment
  v_instance_type     = var.v_instance_type
  v_aws_region        = var.v_aws_region
  v_avail_zones       = var.v_avail_zones
}

module "ec2" {
  source = "./modules/ec2"
  v_environment       = var.v_environment
  v_instance_type     = var.v_instance_type
  v_aws_region        = var.v_aws_region
  v_avail_zones       = var.v_avail_zones
  v_vpc_id            = module.network.o_vpc_id
  v_public_subnet_id  = module.network.o_subnet_id
  v_ssh_key           = var.v_ssh_key
  v_email_addr_sns    = var.v_email_addr_sns

}


