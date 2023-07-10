# Terraform Outputs

output "o_vpc_id" {
  description = "VPC ID"
  value       = "${aws_vpc.vpc.id}"
}

output "o_subnet_id" {
  description = "subnet ID"
  type = list(array)
  value = "${aws_subnet.subnet.*.id}"
}

output "o_user_local_public_IP" {
  description = "User's local public IP"
  value       = "${data.external.useripaddr.result.ip}"
}

output "o_igw_id" {
  description = "IGW id"
  value = "${aws_internet_gateway.internet_gateway.id}"
}

# output "o_userip" {
#   description = "user IP address"
#   value = "${data.external.useripaddr}"
# }

