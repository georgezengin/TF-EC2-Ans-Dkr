# Terraform Outputs

# ec2 Outputs

output "o_ec2_remote_access" {
  description = "EC2 Remote Access"
  value       = [ "ssh -i ${local_file.private_key_pem.filename} ec2-user@${aws_instance.jenkins_server.public_ip}" ]
}

output "o_jenkins_GUI_access" {
  description = "Jenkins GUI Remote Access"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "o_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.jenkins_server.id
}

output "o_instance_arn" {
  description = "EC2 instance ARN"
  value       = aws_instance.jenkins_server.arn
}

output "o_instance_public_ip" {
  description = "EC2 instance Public IP"
  value       = aws_instance.jenkins_server.public_ip
}

output "o_instance_public_dns" {
  description = "EC2 instance Public DNS"
  value       = aws_instance.jenkins_server.public_dns
}

output "o_instance_private_ip" {
  description = "EC2 instance Private IP"
  value       = aws_instance.jenkins_server.private_ip
}

output "o_instance_private_dns" {
  description = "EC2 instance Private DNS"
  value       = aws_instance.jenkins_server.private_dns
}

output "o_aws_security_group_id" {
  description = "aws_security_group_id"
  value = aws_security_group.jenkins_security_group.id
}


output "o_user_local_public_IP" {
  description = "User's local public IP"
  value       = data.external.useripaddr.result.ip
}

output "o_user_timezone" {
  description = "detected time zone from the user (for cron triggered events)"
  value       = data.external.user_timezone.result["timeZone"] #var.ec2_timezone
}