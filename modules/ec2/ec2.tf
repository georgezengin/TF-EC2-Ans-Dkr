/* This Terraform deployment creates the following resources:
    Security Groups,  */

# Obtain User's Local Public IP
data "external" "useripaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

data "external" "user_timezone" {
  program = [
    "bash",
    "-c",
    <<-EOF
      url="https://www.timeapi.io/api/TimeZone/ip?ipAddress="${data.external.useripaddr.result.ip}
      response=$(curl -s "$url")
      timeZone=$(echo "$response" | jq -r '.timeZone')
      echo "{\"timeZone\": \"$timeZone\"}"
    EOF
  ]
}

# Security Group allowed incoming ports
variable "ingressrules" {
  type    = list(number)
  default = [80, 443] #[8080, 22, 80]
}

resource "aws_security_group" "http_web_traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = var.v_public_access_ssh == "yes" ? [ var.v_alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ var.v_alltraffic_cidr ]
  }

  tags = {
    Name        = "${var.v_environment}-jenkins-security-group"
    Environment = "${var.v_environment}"
  }
}

# Create EC2 Security Group and Security Rules (specific for SSH & 8080)
resource "aws_security_group" "jenkins_security_group" {
  name        = "${var.v_environment}-jenkins-security-group"
  description = "SSH/8080 to Jenkins EC2 instance"
  vpc_id      = var.v_vpc_id
  
  ingress {
    description = "SSH/universal"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.v_public_access_ssh == "yes" ? [var.v_alltraffic_cidr] : ["${data.external.useripaddr.result.ip}/32"]
  }

  ingress {
    description = "Jenkins GUI - use public IP or public DNS to port 8080 to access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.v_public_access_ssh == "yes" ? [var.v_alltraffic_cidr] : ["${data.external.useripaddr.result.ip}/32"]
  }

  egress {
    description = "Allow All traffic outbound"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.v_alltraffic_cidr]
  }

  tags = {
    Name        = "${var.v_environment}-jenkins-security-group"
    Environment = "${var.v_environment}"
  }

  lifecycle {
    #ignore_changes = [ingress]
    #create_before_destroy = true
  }
}

# Lookup Amazon Linux Image
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Create SSH Keys for EC2 Remote Access
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "${var.v_ssh_path}${var.v_ssh_key}.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "generated" {
  key_name   = var.v_ssh_key
  public_key = tls_private_key.generated.public_key_openssh
  tags = {
    Name        = "${var.v_environment}-${var.v_ssh_key}"
    Environment = "${var.v_environment}"
  }
}

# Create EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.v_instance_type
  key_name                    = aws_key_pair.generated.key_name
  subnet_id                   = var.v_public_subnet_id[0] #count.index]
  security_groups             = [aws_security_group.jenkins_security_group.id] #,  aws_security_group.http_web_traffic.id ]
  associate_public_ip_address = true

  # iam_instance_profile        = aws_iam_instance_profile.ec2_sns_publish_profile.arn # "ec2_sns_publish_profile"
  # user_data                   =  "${file("./ansible-install.sh")}"
  
  connection {
    user        = "ec2-user"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.host_id #public_ip
    type        = "ssh"
    password    = ""
  }

  #For future reference
  #provisioner "local-exec" {
  #  command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ${self.public_ip}, --private-key ${tls_private_key.generated.private_key.pem} -e 'pub_key=${tls_private_key.generated.private_key.pem}' install-jenkins-java.yml"
  #}

  # provisioner "local-exec" {
  #  command = "ansible-playbook -i ${aws_instance.jenkins_server.public_ip} ${path.module}/install-jenkins.yml"
  #  interpreter = ["/bin/bash", "-c"]
  # }

  provisioner "file" {
    source      = "./_scripts-keys/instance-setup.sh"  # Path to your bash script file
    destination = "/home/ec2-user/instance-setup.sh"
    
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }

  provisioner "file" {
    source      = "./_scripts-keys/install-jenkins.yml"    # yaml file for ansible
    destination = "/home/ec2-user/install-jenkins.yml" 
    
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/instance-setup.sh",
      "mkdir .install-jenkins",
      "mv * .install-jenkins",
      "/home/ec2-user/.install-jenkins/instance-setup.sh 2>&1 | tee /home/ec2-user/.install-jenkins/instance-setup.log"  # Redirect script output to a log file
    ]

    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }
  
  tags = {
    Name        = "${var.v_environment}-jenkins-server"
    Environment = "${var.v_environment}"
  }

  lifecycle {
    ignore_changes = [ security_groups ]
    #create_before_destroy = true
  }
}