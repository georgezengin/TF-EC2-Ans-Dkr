# Terraform Variables
# main env name
variable "v_environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "tf-ec2-jnk-ans"
}

# aws region-azs available for the deployment
variable "v_aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
  default     = "eu-central-1"
}

variable "v_avail_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

# VPC Variables
variable "v_vpc_id" { default = "" }
variable "v_public_subnet_id" { default = "" }

variable "v_vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "v_subnet_cidr" {
  description = "Subnet cidr block"
  type        = list(string)
  default     = [ "10.0.0.0/24" ]
}

variable "v_alltraffic_cidr" {
  description = "All traffic CIDR - for sec group"
  type        = string
  default     = "0.0.0.0/0"
}

variable "v_public_access_ssh"{
  description = "Flag to allow public access to EC2s using SSH as opposed to private (from author's public IP)"
  type        = string
  default     = "yes"
}

# EC2 Variables
variable "v_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "v_ssh_key" {
  description = "ssh key name"
  type        = string
  default     = "my-ssh-key"
}

variable "v_ssh_path" {
  description = "ssh key path"
  type        = string
  default     = "" # ~/.ssh
}

variable "v_email_addr_sns" {}

# variable "v_ec2_user_data" {
#   description = "User data shell script for Jenkins EC2"
#   type        = string
#   default     = <<EOF
# #!/bin/bash
# # Install Jenkins and Java 
# sudo wget -O /etc/yum.repos.d/jenkins.repo \
#     https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
# sudo yum upgrade -y
# # Add required dependencies for the jenkins package
# sudo amazon-linux-extras install -y java-openjdk11 
# sudo yum install -y jenkins
# sudo systemctl daemon-reload

# # Start Jenkins
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

# # Firewall Rules
# if [[ $(firewall-cmd --state) = 'running' ]]; then
#     YOURPORT=8080
#     PERM="--permanent"
#     SERV="$PERM --service=jenkins"

#     firewall-cmd $PERM --new-service=jenkins
#     firewall-cmd $SERV --set-short="Jenkins ports"
#     firewall-cmd $SERV --set-description="Jenkins port exceptions"
#     firewall-cmd $SERV --add-port=$YOURPORT/tcp
#     firewall-cmd $PERM --add-service=jenkins
#     firewall-cmd --zone=public --add-service=http --permanent
#     firewall-cmd --reload
# fi
# EOF
# }