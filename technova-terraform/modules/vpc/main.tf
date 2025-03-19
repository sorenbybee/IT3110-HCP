resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.project}-${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name        = "${var.project}-${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.project}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  vpc   = true
  
  tags = {
    Name        = "${var.project}-${var.environment}-eip-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = {
    Name        = "${var.project}-${var.environment}-nat-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Route tables for private subnets
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-private-rt-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Department  = "IT"
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
