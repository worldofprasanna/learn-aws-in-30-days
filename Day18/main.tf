# Terraform Settings
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Provider Settings
provider "aws" {
  region  = "ap-south-1"
}

# 1. Get the VPC information
data "aws_vpc" "my_default_vpc" {
  default = true
}

output "default_vpc_id" {
  value = data.aws_vpc.my_default_vpc.id
}

# 2. Get all the Subnets information for default VPC
data "aws_subnet_ids" "my_available_subnets" {
  vpc_id = data.aws_vpc.my_default_vpc.id
}

output "available_subnet_ids" {
    value = [data.aws_subnet_ids.my_available_subnets.ids]
}

output "my_subnet_for_instance" {
    value = sort(data.aws_subnet_ids.my_available_subnets.ids)[2]
}

# 3. Create the Security Group
resource "aws_security_group" "sg-from-tf" {
  vpc_id = data.aws_vpc.my_default_vpc.id
  name        = "securitygroup-from-tf"
  description = "Allow SSH inbound traffic and all outbound traffic"
  tags = {
    Name = "securitygroup-from-tf"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
}

# 4. Get the AMI ID for our Instance
data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240301"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

output "my_ami_id" {
  value = data.aws_ami.ubuntu.id
}

variable "instance_name" {
  type = string
  description = "Name of the EC2 instance"
  default = "instance-from-tf-default-value"
}

# # 5. Create the EC2 Instance
resource "aws_instance" "my_first_instance" {
  ami           = data.aws_ami.ubuntu.id
  subnet_id = sort(data.aws_subnet_ids.my_available_subnets.ids)[2]
  instance_type = "t2.micro"
  key_name = "prasanna"
  security_groups = [aws_security_group.sg-from-tf.id]
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}

# # Output Section
output "instance_public_ip" {
  description = "This is the Public IP of my EC2 instance"
  value       = aws_instance.my_first_instance.public_ip
}