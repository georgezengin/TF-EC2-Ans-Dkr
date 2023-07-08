locals {
  current_date     = formatdate("YYYY-MM-DD", timestamp())
  current_time     = formatdate("HH-MM-SS", timestamp())
  state_file_name  = "terraform-${local.current_date}-${local.current_time}.tfstate"

  l_aws_access_key = var.v_aws_access_key != "" ? var.v_aws_access_key : lookup(var.env, "AWS_ACCESS_KEY_ID",     lookup(var.aws_config, "access_key", null))
  l_aws_secret_key = var.v_aws_secret_key != "" ? var.v_aws_secret_key : lookup(var.env, "AWS_SECRET_ACCESS_KEY", lookup(var.aws_config, "secret_key", null))
  l_aws_region     = var.v_aws_region     != "" ? var.v_aws_region     : lookup(var.env, "AWS_REGION",            lookup(var.aws_config, "region", "eu-central-1"))
}


