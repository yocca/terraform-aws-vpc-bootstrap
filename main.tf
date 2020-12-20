terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

// You can uncomment the below code and enter the s3 bucket in which you'd like to maintain the infrastructure's state
//  backend "s3" {
//    bucket     = ""
//    key        = ""
//    region     = ""
//    profile    = ""
//  }
}

locals {
  tag_name = "${var.env}-${var.name}"
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = local.tag_name
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_cidr_blocks[count.index].cidr_block
  availability_zone = "${var.region}${var.public_cidr_blocks[count.index].zone}"

  tags = {
    Name = "${local.tag_name}-public-${var.private_cidr_blocks[count.index].zone}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_cidr_blocks[count.index].cidr_block
  availability_zone = "${var.region}${var.private_cidr_blocks[count.index].zone}"

  tags = {
    Name = "${local.tag_name}-private-${var.private_cidr_blocks[count.index].zone}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = local.tag_name
  }
}

resource "aws_eip" "eip_ngw" {
  vpc = true

  tags = {
    Name = local.tag_name
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip_ngw.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.tag_name}-public"
  }
}

resource "aws_route_table_association" "route_table_association_public" {
  count          = length(var.public_cidr_blocks)
  route_table_id = aws_route_table.route_table_public.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${local.tag_name}-private"
  }
}

resource "aws_route_table_association" "route_table_association_private" {
  count          = length(var.private_cidr_blocks)
  route_table_id = aws_route_table.route_table_private.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "sg_bastion" {
  name   = "${local.tag_name}-bastion"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tag_name}-bastion"
  }
}

resource "aws_security_group" "sg_public" {
  name   = "${local.tag_name}-public"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tag_name}-public"
  }
}

resource "aws_security_group" "sg_private" {
  name   = "${local.tag_name}-private"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_public.id]
  }

  tags = {
    Name = "${local.tag_name}-private"
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "bastion_sg_id" {
  value = aws_security_group.sg_bastion.id
}

output "public_sg_id" {
  value = aws_security_group.sg_public.id
}

output "private_sg_id" {
  value = aws_security_group.sg_private.id
}


