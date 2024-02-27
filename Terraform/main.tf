provider "aws" {
    region =  "eu-central-1"
    access_key = "AKIARLJUM4GFTVFIYEM4"
    secret_key = "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"
}

### VPC

resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "Arbel Wiliot Project"
 }
}

### Subnets

resource "aws_subnet" "public_subnets" {
 count      = length(var.pub_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.pub_subnet_cidrs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.prv_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.prv_subnet_cidrs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

## internet gateway

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "app internet gateway"
 }
}

### SG

resource "aws_security_group" "sg" {
  name        = "my_sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg"
  }
}

### Routing Tables
resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.main.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "Secound RT"
 }
}

resource "aws_route_table_association" "pub_subnet_asso" {
 count = length(var.pub_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

### EKS Cluster

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "mycluster"
  cluster_version = "1.27"

  create_iam_role = false
  iam_role_arn = "arn:aws:iam::092988563851:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"

  vpc_id                         = aws_vpc.main.id
  subnet_ids                     = aws_subnet.private_subnets[*].id
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

### ECR

resource "aws_ecr_repository" "ECR" {
  name                 = "arbel_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}