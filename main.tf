resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags ={
        Name = var.project_name
        Terraform = true
        Environment = "DEV"
    }
}

resource "aws_vpc" "main"{
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags ={
        Name = var.project_name
        Terraform = true
        Environment = "DEV"
    }

}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    tags ={
        Name = "${var.project_name}-public-subnet"
        Terraform = true
        Environment = "DEV"
    }
}

resource "aws_route_table" "public-route-table" {
vpc_id = aws_vpc.main.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags ={
        Name = "${var.project_name}-public-rt"
        Terraform = true
        Environment = "DEV"
    }

}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.11.0/24"
    tags ={
        Name = "${var.project_name}-private-subnet"
        Terraform = true
        Environment = "DEV"
    }
}

resource "aws_route_table" "private-route-table" {
vpc_id = aws_vpc.main.id


  tags ={
        Name = "${var.project_name}-private-rt"
        Terraform = true
        Environment = "DEV"
    }

}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_subnet" "database-subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.21.0/24"
    tags ={
        Name = "${var.project_name}-database-subnet"
        Terraform = true
        Environment = "DEV"
    }
}

resource "aws_route_table" "database-route-table" {
vpc_id = aws_vpc.main.id


  tags ={
        Name = "database-private-rt"
        Terraform = true
        Environment = "DEV"
    }

}

resource "aws_route_table_association" "database" {
  subnet_id      = aws_subnet.database-subnet.id
  route_table_id = aws_route_table.database-route-table.id
}

resource "aws_eip" "nat" {
  #domain   = "vpc"
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
  #depends_on                = ["aws_route_table.testing"]
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
  #depends_on                = ["aws_route_table.testing"]
}