provider "aws" {
  region = "ap-south-1"
}

##########################
### 1. THE NETWORK VPC ###
##########################

resource "aws_vpc" "my_eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-eks-vpc"
    "kubernetes.io/cluster/my-first-eks-cluster"="shared"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_eks_vpc.id
  tags = {
    Name = "my-eks-igw"
  }
}

resource "aws_subnet" "public-1"{
 vpc_id = aws_vpc.my_eks_vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = "ap-south-1a"
 map_public_ip_on_launch = true

 tags = {
   Name = "public-subnet-1"
   "kubernetes.io/role/elb"="1"
 }
}

resource "aws_subnet" "public-2" {
  vpc_id = aws_vpc.my_eks_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
    "kubernetes.io/role/elb"="1"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_eks_vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    aws_internet_gateway = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "pub-1-assc" {
  subnet_id = aws_subnet.public-1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub-2-assc" {
  subnet_id = aws_subnet.public-2.id
  route_table_id = aws_route_table.public_rt.id
}