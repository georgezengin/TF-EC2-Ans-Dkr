#enter here your AWS credentials if you dont have AWSCLI configured
#v_aws_access_key = "XXXXXXXXXXXXXX"
#v_aws_secret_key = "123456789012345678901234567890"

# Project name - used as prefix to provision AWS resources and set in tag Environment
v_environment = "tf-ec2-jnk-ans"

# Set to value wanted for instances
# v_instance_type = "t2.micro"

# Specify project region
v_aws_region = "eu-central-1"

# Specify specific availability zones, must correlate with v_subnet_cidr for subnet creation
v_avail_zones = [ "eu-central-1a" ]

# Specify CIDR block to be used in VPC
v_vpc_cidr     = "10.10.0.0/16"

# Specify CIDR blocks for subnets created in different availability zones
v_subnet_cidr  = ["10.10.1.0/24"]

# Specify the name of the SSH PEM file to generate in order to connect to the EC2 Instance (no extension needed)
v_ssh_key = "tf-ec2-jnk-ans"

# Specify email address for SNS to notify on EC2 change of state (start/stop)
v_email_addr_sns = "test.AWS.IITC.course@gmail.com"
