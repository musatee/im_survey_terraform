# network.tf

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = "172.17.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "IM_vpc"
  }
}


# Create public subnet
resource "aws_subnet" "public" {
  cidr_block              = "172.17.10.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true 

  tags = {
    Name = "IM_public-sub"
  }
} 

# Create public_subnet_db_1 ## for postgres subnet groups
resource "aws_subnet" "public_subnet_db_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.17.5.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "IM_subnet_db_1"
  }
} 

# Create public_subnet_db_2 ## for postgres subnet groups
resource "aws_subnet" "public_subnet_db_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.17.6.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "IM_subnet_db_2"
  }
}


# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id 
  tags = {
    Name = "IM_IGW"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
