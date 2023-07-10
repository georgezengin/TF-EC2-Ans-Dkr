# Terraform Net module outputs

# VPC id - generated on deployment
output "o_vpc_id" {
  description = "VPC ID"
  value       = module.network.o_vpc_id
}

# Subnet ID - generated on deployment
output "o_subnet_id" {
  description = "Public Subnet ID"
  type = list(array)
  value = module.network.o_subnet_id
}

# local User IP - Used to limit SSH access to user (if required by project parameter)
output "o_user_local_public_IP" {
  description = "User's local public IP"
  value       = module.network.o_user_local_public_IP
}

# left for future use - result of API call
# output "o_userip" {
#   description = "user network id json"
#   value = module.network.o_userip
# }

# Internet Gateway ID - generated on deployment
output "o_igw_id" {
  description = "IGW id"
  value = module.network.o_igw_id
}

# ec2 module outputs 
# EC2 public IP - generated on deployment
output "o_ec2_instance_public_IP" {
  description = "EC2 Instance Public IP"
  value       = module.ec2.o_instance_public_ip
}

# EC2 public DNS - generated on deployment
output "o_ec2_instance_public_dns" {
  description = "EC2 instance Public DNS"
  value       = module.ec2.o_instance_public_dns
}

# EC2 private IP - generated on deployment
output "o_ec2_instance_private_ip" {
  description = "EC2 instance Private IP"
  value       = module.ec2.o_instance_private_ip
}

# EC2 private DNS - generated on deployment
output "o_ec2_instance_private_DNS" {
  description = "EC2 Instance Private IP"
  value       = module.ec2.o_instance_private_dns
}

# security group id - generated on deployment
output "o_ec2_aws_security_group_id" {
  description = "aws_security_group_id"
  value       = module.ec2.o_aws_security_group_id
}

# connection command to EC2 instance thru SSH
output "o_ec2_remote_access" {
  description = "EC2 Remote Access"
  value       = module.ec2.o_ec2_remote_access
}

# Jenking GUI URL - generated on deployment
output "o_jenkins_GUI_access" {
  description = "Jenkins GUI Remote Access"
  value       = module.ec2.o_jenkins_GUI_access
}

