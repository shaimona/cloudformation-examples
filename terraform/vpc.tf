# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "${var.VPCCidrBlock}"
  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "private_az1" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "${var.PrivateSubnetCidrBlock1}"
  availability_zone = "${var.aws_region}${var.AvailabilityZone1}"
  tags {
    Name = "private_az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "${var.aws_region}${var.AvailabilityZone2}"
  tags {
    Name = "private_az2"
  }
}

resource "aws_subnet" "public_az1" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "${var.PublicSubnetCidrBlock1}"
  availability_zone = "${var.aws_region}${var.AvailabilityZone1}"
  tags {
    Name = "public_az1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "${var.PublicSubnetCidrBlock2}"
  availability_zone = "${var.aws_region}${var.AvailabilityZone2}"
  tags {
    Name = "public_az_2b"
  }
}

resource "aws_internet_gateway" "terra-igw" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  tags {
    Name = "${var.vpc_name}-igw"
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

resource "aws_route_table_association" "public_az1" {
  subnet_id = "${aws_subnet.public_az1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az2" {
  subnet_id = "${aws_subnet.public_az2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "public" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"
  subnet_ids = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az1.id}"]
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
  subnet_ids = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}"]
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
  subnet_id = "${aws_subnet.public_az1.id}"
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

resource "aws_route_table_association" "private_az1" {
  subnet_id = "${aws_subnet.private_az1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_az2" {
  subnet_id = "${aws_subnet.private_az2.id}"
  route_table_id = "${aws_route_table.private.id}"
}
