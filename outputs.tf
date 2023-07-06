# Terraform Outputs
# Net module outputs
output "o_vpc_id" {
  description = "VPC ID"
  value       = module.network.o_vpc_id
}

output "o_subnet_id" {
  description = "Public Subnet ID"
  value = module.network.o_subnet_id
}

output "o_user_local_public_IP" {
  description = "User's local public IP"
  value       = module.network.o_user_local_public_IP
}

output "o_userip" {
  description = "user IP address"
  value = module.network.o_userip
}

output "o_igw_id" {
  description = "IGW id"
  value = module.network.o_igw_id
}

# ec2 module outputs
output "o_ec2_instance_public_IP" {
  description = "EC2 Instance Public IP"
  value       = module.ec2.o_instance_public_ip
}
output "o_ec2_instance_public_dns" {
  description = "EC2 instance Public DNS"
  value       = module.ec2.o_instance_public_dns
}

output "o_ec2_instance_private_ip" {
  description = "EC2 instance Private IP"
  value       = module.ec2.o_instance_private_ip
}

output "o_ec2_instance_private_DNS" {
  description = "EC2 Instance Private IP"
  value       = module.ec2.o_instance_private_dns
}

output "o_ec2_aws_security_group_id" {
  description = "aws_security_group_id"
  value       = module.ec2.o_aws_security_group_id
}

output "o_ec2_remote_access" {
  description = "EC2 Remote Access"
  value       = module.ec2.o_ec2_remote_access
}
