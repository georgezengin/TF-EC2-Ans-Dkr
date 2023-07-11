# Terraform Outputs

output "o_vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "o_subnet_id" {
  description = "subnet ID"
  value = aws_subnet.subnet.*.id
}

output "o_igw_id" {
  description = "IGW id"
  value = aws_internet_gateway.internet_gateway.id
}
