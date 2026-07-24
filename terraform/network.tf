# ------------------------------------------------------------------------------
# Networking
# SignalOps Production Networking
# ------------------------------------------------------------------------------

# Retrieve the available Availability Zones in the configured AWS region.
# This avoids hardcoding "us-east-1a", which is not guaranteed to map
# consistently across AWS accounts.
data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

resource "aws_vpc" "signalops" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "signalops-vpc"
    }
  )
}

# ------------------------------------------------------------------------------
# Public Subnet
# ------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.signalops.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "signalops-public-subnet"
      Tier = "Public"
    }
  )
}

# ------------------------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.signalops.id

  tags = merge(
    local.common_tags,
    {
      Name = "signalops-igw"
    }
  )
}

# ------------------------------------------------------------------------------
# Public Route Table
# ------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.signalops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "signalops-public-rt"
    }
  )
}

# ------------------------------------------------------------------------------
# Route Table Association
# ------------------------------------------------------------------------------

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  depends_on = [
    aws_route_table.public,
    aws_subnet.public
  ]
}
