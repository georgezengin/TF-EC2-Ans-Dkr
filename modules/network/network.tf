/* This Terraform deployment creates the following resources:
   VPC, Subnet, Internet Gateway, Default Route, 
   Security Group, SSH Key, and EC2 with userdata script installing Jenkins */

# Create VPC Resources

resource "aws_vpc" "vpc" {
  cidr_block = var.v_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.v_environment}-vpc"
    Environment = "${var.v_environment}"
  }
}

data "aws_availability_zones" "available" {}

#variable "v_vpc_subnets_cidrs" {
#  type    = list(number)
#  default = v_subnet_cidr # list of CIDRs for each subnet, will determine number of subnets to create
#}

resource "aws_subnet" "subnet" {
  count                   = length(var.v_subnet_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.v_subnet_cidr[count.index]}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.v_environment}-public-subnet-${count.index + 1}"
    Environment = "${var.v_environment}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.v_environment}-igw"
    Environment = "${var.v_environment}"
  }
}

resource "aws_default_route_table" "default_route" {
  #vpc_id = aws_vpc.vpc.id
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = var.v_alltraffic_cidr
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "${var.v_environment}-default-route-table"
    Environment = "${var.v_environment}"
  }
}

resource "aws_route_table_association" "route_table_assoc" {
  count          = 1
  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_default_route_table.default_route.id
}

# Obtain User's Local Public IP
data "external" "useripaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}
