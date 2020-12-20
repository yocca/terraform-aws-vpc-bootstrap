variable "region" {
  type    = string
}

variable "env" {
  type    = string
}

variable "aws_profile" {
  type    = string
}

variable "name" {
  type    = string
}

variable "main_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_cidr_blocks" {
  type    = list(object({
    zone       = string
    cidr_block = string
  }))

  default = [{
    zone = "a",
    cidr_block = "10.0.1.0/24"
  }, {
    zone = "b",
    cidr_block = "10.0.2.0/24"
  }, {
    zone = "c",
    cidr_block = "10.0.3.0/24"
  }, {
    zone = "d",
    cidr_block = "10.0.4.0/24"
  }]
}

variable "private_cidr_blocks" {
  type    = list(object({
    zone       = string
    cidr_block = string
  }))

  default = [{
    zone = "a",
    cidr_block = "10.0.5.0/24"
  }, {
    zone = "b",
    cidr_block = "10.0.6.0/24"
  }, {
    zone = "c",
    cidr_block = "10.0.7.0/24"
  }, {
    zone = "d",
    cidr_block = "10.0.8.0/24"
  }]
}

