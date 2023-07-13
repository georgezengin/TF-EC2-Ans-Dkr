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
