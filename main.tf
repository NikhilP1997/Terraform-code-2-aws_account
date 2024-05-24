variable "vpc_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr_1" {}
variable "public_subnet_cidr_2" {}
variable "private_subnet_cidr_1" {}
variable "private_subnet_cidr_2" {}
variable "ec2_instance_type" {}
variable "ec2_ami" {}
variable "key_pair_name" {}
variable "s3_bucket_name" {}

resource "aws_vpc" "main" {
  provider             = aws.account_a
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_1" {
  provider                = aws.account_a
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-1"
  }
}

resource "aws_subnet" "public_2" {
  provider                = aws.account_a
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-2"
  }
}

resource "aws_subnet" "private_1" {
  provider          = aws.account_a
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_1
  availability_zone = "ap-south-1a"
  tags = {
    Name = "${var.vpc_name}-private-1"
  }
}

resource "aws_subnet" "private_2" {
  provider          = aws.account_a
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-private-2"
  }
}

resource "aws_security_group" "ec2_sg" {
  provider    = aws.account_a
  vpc_id      = aws_vpc.main.id
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  provider   = aws.account_a
  key_name   = var.key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "web" {
  provider      = aws.account_a
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public_1.id
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "web-server"
  }
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/private_key.pem"
}

resource "aws_s3_bucket" "secure_bucket" {
  provider = aws.account_b
  bucket   = var.s3_bucket_name

  tags = {
    Name = var.s3_bucket_name
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  provider = aws.account_b
  bucket   = aws_s3_bucket.secure_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "null_resource" "set_private_key_permissions" {
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key.filename}"
  }

  depends_on = [local_file.private_key]
}



  
