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

resource "aws_subnet" "public_1" { # for web-server
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24" # range of 10.0.1.x IPs
  availability_zone = "eu-north-1a"

  tags = {
    Name = "main-public-1"
  }
}

resource "aws_subnet" "private_1" { # for databases which not allowed to access via global network
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24" # range of 10.0.2.x IPs
  availability_zone = "eu-north-1a"

  tags = {
    Name = "main-private-1"
  }
}