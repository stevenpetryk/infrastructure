provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "steven-vpc"
  }
}

resource "aws_subnet" "subnet_1a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "subnet_1a"
  }
}

resource "aws_subnet" "subnet_1b" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "subnet_1b"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.subnet_1a.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.subnet_1b.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "tardigrade-ig"
  }
}

resource "aws_security_group" "ssh_ingress" {
  name = "ssh_ingress_sg"

  vpc_id = "${aws_vpc.main.id}"

  # HTTPS access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_security_group" "http_ingress" {
  name = "http_ingress_sg"

  vpc_id = "${aws_vpc.main.id}"

  # HTTPS access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_key_pair" "steven" {
  key_name   = "steven-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCV2P6FkSQImNpv9zVmDB+sisuq9q4UOyWjW2UyDsEX2C3tpfmbd/KmBeZrSPri1fabdirJ5v+oY/psggEthk2/RXGyVa0mLzD9uD5QQi1jhR1mxjsck+jgNHSF900toRUtfUak9E/a//ob9dabAUMtDFCOQ5qhpIHGJb4zxblvDlBaNVFH6AiSYXfRZ1a8lfxKmG7kpckkdpsuYD/UKosyfiL9UxqP2RNCrb7Ni/JwVkEysA7bQ/wGiqjCjcA/Fu7yDsrZx9tD1HrmwX5iqPsGtE6n86Kl1QSYudZT6StRk6Vykn+JP8iD9cgpYdzddY23wKkURagA7XGO0fG+2C3ROlcwoYqE/7pod9XmaKcEU+4sL45lREofdxLLoR20fKz1qLADVGBnKQpjqs5vjHIJirmgpKP0DLl5q1qpVX9ExAQrwfT6MtcYHrduhpcJ6D7gk/I+/jgL15YaO5OnEbT9BwkzWevVLjY0NAnK5wA0YxSU87VA0CbFZbmLIexJ5LIAkDCRr/HR1o5BEqsr4lIQATZLhhxSaBmueRQo8EoQbTWr8wXXexIwgHXv5cRNQQrDJnRBUInar6rd171Zlou/DyB1CtspY6KwlEma72hf+V/0GpGYoDJcTzd4gMDw06NzW+tYH8JRcdmJECXdFzusAqt/bC5HO5G952ARQ7LKWQ== petryk.steven@gmail.com"
}
