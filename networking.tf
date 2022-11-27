locals {
  azs = data.aws_availability_zones.available.names
}

resource "random_id" "random" {
    byte_length = 2
}


resource "aws_vpc" "ozcalisan_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
        Name = "ozcalisan-vpc-${random_id.random.dec}"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_internet_gateway" "ozcalisan-gw" {
  vpc_id = aws_vpc.ozcalisan_vpc.id

  tags = {
    Name = "ozcalisan_${random_id.random.dec}"
  }
}


resource "aws_route_table" "example" {
  vpc_id = aws_vpc.ozcalisan_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ozcalisan-gw.id
  }


  tags = {
    Name = "ozcalisan"
  }
}


resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.ozcalisan_vpc.default_route_table_id
  tags = {
    Name = "private"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}



resource "aws_subnet" "ozcalisan_pub_sub" {
  count = length(local.azs)
  vpc_id     = aws_vpc.ozcalisan_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone = local.azs[count.index]

  tags = {
    Name = "ozcalisan-pub-sub-${count.index + 1}"
  }
}


resource "aws_subnet" "ozcalisan_priv_sub" {
  count = length(local.azs)
  vpc_id     = aws_vpc.ozcalisan_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.azs))
  map_public_ip_on_launch = false
  availability_zone = local.azs[count.index]

  tags = {
    Name = "ozcalisan-priv-sub-${count.index + 1}"
  }
}


resource "aws_route_table_association" "pub_sub_rta" {
  count = length(local.azs)
  subnet_id      = aws_subnet.ozcalisan_pub_sub[count.index].id
  route_table_id = aws_route_table.example.id
}



resource "aws_security_group" "ozcalisan_sg" {
  name        = "public_sg"
  vpc_id      = aws_vpc.ozcalisan_vpc.id
}

resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.access_ip, var.cloud9_ip]
  security_group_id = aws_security_group.ozcalisan_sg.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ozcalisan_sg.id
}