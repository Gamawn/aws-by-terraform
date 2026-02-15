terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}


provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "learn-vpc"
  }
}

resource "aws_internet_gateway" "igw" { # internet gateway, like entering door
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # any of request goes to IGW
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_subnet" "public_1" { # for web-server
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24" # range of 10.0.1.x IPs
  availability_zone = "eu-north-1a"

  tags = {
    Name = "main-public-1"
  }
}

resource "aws_subnet" "private_1" { # for databases which not allowed to access via global network
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24" # range of 10.0.2.x IPs
  availability_zone = "eu-north-1a"

  tags = {
    Name = "main-private-1"
  }
}

# связываем публичную подсеть route-table
resource "aws_route_table_association" "public_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_1.id
}

# secgroup для HTTP/SSH подлючении
resource "aws_security_group" "web_sg" {
  name        = "allow_web_ssh"
  description = "allow web and ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  # входящий
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # исходящий
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_ssh"
  }
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 init
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  availability_zone = "eu-north-1a"

  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # user_data = "" # some script which install httpd and run's server with some static html
  user_data = file("./install-httpd.sh")
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}
