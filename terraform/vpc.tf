# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.10.0.0/18"
  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "private_az_2a" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "private_az_1a"
  }
}

resource "aws_subnet" "private_az_2b" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-west-2b"
  tags {
    Name = "private_az_1b"
  }
}

resource "aws_subnet" "private_az_2c" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.3.0/24"
  availability_zone = "us-west-2c"
  tags {
    Name = "private_az_1c"
  }
}

resource "aws_subnet" "public_az_2a" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.4.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "public_az_1a"
  }
}

resource "aws_subnet" "public_az_2b" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.5.0/24"
  availability_zone = "us-west-2b"
  tags {
    Name = "public_az_2b"
  }
}

resource "aws_subnet" "public_az_2c" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.6.0/24"
  availability_zone = "us-west-2c"
  tags {
    Name = "public_az_2c"
  }
}

resource "aws_internet_gateway" "terra-igw" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  tags {
    Name = "terraform-vpc-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra-igw.id}"
  }
  tags {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_route_table_association" "public_az_2a" {
  subnet_id = "${aws_subnet.public_az_2a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az_2b" {
  subnet_id = "${aws_subnet.public_az_2b.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "public_az_2c" {
  subnet_id = "${aws_subnet.public_az_2c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "public" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  subnet_ids = ["${aws_subnet.public_az_2a.id}", "${aws_subnet.public_az_2b.id}", "${aws_subnet.public_az_2c.id}"]
  ingress = {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  egress = {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  subnet_ids = ["${aws_subnet.private_az_2a.id}", "${aws_subnet.private_az_2b.id}", "${aws_subnet.private_az_2c.id}"]
  ingress = {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  egress = {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public_az_2a.id}"
  depends_on = ["aws_internet_gateway.terra-igw"]
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }
  tags = {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_route_table_association" "private_az_2a" {
  subnet_id = "${aws_subnet.private_az_2a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_az_2b" {
  subnet_id = "${aws_subnet.private_az_2b.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private_az_2c" {
  subnet_id = "${aws_subnet.private_az_2c.id}"
  route_table_id = "${aws_route_table.private.id}"
}
