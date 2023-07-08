# Terraform Providers

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.55.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.0"
    }
#    ansible = {
#      version = "~> 0.0.1"
#      source  = "terraform-ansible.com/ansibleprovider/ansible"
#    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0.0"
    }
  }

  required_version = "~>1.5.2"
}

provider "aws" {
  access_key    = local.l_aws_access_key
  secret_key    = local.l_aws_secret_key
  region        = local.l_aws_region
}
