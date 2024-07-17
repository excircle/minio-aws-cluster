resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = merge(
    local.tag,
    {
      Name = format("%s VPC", var.application_name)
      Purpose = format("%s Cluster VPC", var.application_name)
    }
  )
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tag,
    {
      Name = format("%s IGW", var.application_name)
      Purpose = format("IGW for %s Cluster", var.application_name)
    }
  )
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = merge(
    local.tag,
    {
      Name = format("%s Cluster Public Subnet", var.application_name)
      Purpose = format("%s Cluster Subnet", var.application_name)
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    local.tag,
    {
      Name = format("%s Cluster Route Table", var.application_name)
      Purpose = format("%s Cluster Route Table", var.application_name)
    }
  )
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}