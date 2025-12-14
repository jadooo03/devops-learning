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
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
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

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "my-eks-nat-eip"
  }
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public-1.id

  tags = {
    Name = "my-eks-nat"
  }

  depends_on = [ aws_internet_gateway.my_igw ]
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.my_eks_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet-1"
    "kubernetes.io/cluster/my-first-eks-cluster"="shared"
    "kubernetes.io/role/internal-elb"="1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.my_eks_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-subnet-2"
    "kubernetes.io/cluster/my-first-eks-cluster"="shared"
    "kubernetes.io/role/internal-elb"="1"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "priv_1_assoc" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv_2_assoc" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}