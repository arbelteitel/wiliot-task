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

### SG

### Routing Tables

### EKS Cluster

### ECR