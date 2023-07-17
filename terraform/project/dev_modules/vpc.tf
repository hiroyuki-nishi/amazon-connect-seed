#########################
## VPC
#########################
resource "aws_vpc" "prefix_xxx_dev" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.prefix_xxx_dev.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-public-subnet"
  }
}

resource "aws_subnet" "private_subnet1a" {
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.prefix_xxx_dev.id

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-private-subnet1a"
  }
}

resource "aws_subnet" "private_subnet1c" {
  cidr_block              = "10.0.21.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.prefix_xxx_dev.id

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-private-subnet1c"
  }
}

resource "aws_route_table_association" "private0" {
  subnet_id      = aws_subnet.private_subnet1a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet1c.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "private_to_internet" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.prefix_xxx_dev.id
}

resource "aws_internet_gateway" "prefix_xxx_dev" {
  vpc_id = aws_vpc.prefix_xxx_dev.id

  tags = {
    name      = "${var.prefix}-${var.project_name}-${var.env}-internet-gateway"
  }
}

resource "aws_eip" "prefix_xxx_dev" {
  vpc        = "true"
  depends_on = [aws_internet_gateway.prefix_xxx_dev]

  tags = {
    name      = "${var.prefix}-${var.project_name}-${var.env}-eip"
  }
}

resource "aws_nat_gateway" "prefix_xxx_dev" {
  allocation_id = aws_eip.prefix_xxx_dev.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.prefix_xxx_dev]

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-nat-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.prefix_xxx_dev.id

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association_for_bastion" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "internet_route_for_bastion" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.prefix_xxx_dev.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.prefix_xxx_dev.id

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-private-route-table"
  }
}

#########################
## VPC Endpoint
#########################
resource "aws_vpc_endpoint" "vpc_endpoint_for_lambdas" {
  vpc_id              = aws_vpc.prefix_xxx_dev.id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_subnet1a.id,
    aws_subnet.private_subnet1c.id
  ]

  security_group_ids = [
    var.lambdas_security_group_id
  ]

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-vpc-endpoit-for-lambdas"
  }
}
