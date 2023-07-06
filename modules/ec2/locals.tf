locals {
  ami_id = {
    "eu-central-1" = "ami-0fa39983fed2f19c7",
    "eu-north-1" = "ami-0c858d4d1feca5370"
  }

  http_security_group_id = ""

  start_ec2_cron = "cron(0 07 * * ? *)"
  stop_ec2_cron  = "cron(0 19 * * ? *)"
}

