variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-west-2"
}

variable "vpc_name" {
  description = "VPC name tag"
  default = "Custom VPC"
}

/*variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b84666"
  }
}

variable "project_name" {
  description = "Name of the project"
}*/

variable "VPCCidrBlock" {
  description = "VPC CIDR block"
}

variable "AvailabilityZone1" {
  description = "First availabilty Zone"
}

variable "AvailabilityZone2" {
  description = "Second Availability Zone"
}

variable "PublicSubnetCidrBlock1" {
  description = "First public subnet CIDR"
}

variable "PublicSubnetCidrBlock2" {
  description = "Second public subnet CIDR"
}

variable "PrivateSubnetCidrBlock1" {
  description = "First private subnet CIDR"
}

variable "PrivateSubnetCidrBlock2" {
  description = "Second private subnet CIDR"
}
