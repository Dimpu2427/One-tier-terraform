provider "aws" {
  region = "us-east-1"
  
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "one-tier-vpc"
  }
  
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "one-tier-subnet"
  }
  
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "one-tier-igw"
  }
  
}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-route-table"
  }
  
}
resource "aws_route_table_association" "ass" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
  
}

resource "aws_security_group" "allow_all" {
  name = "allow all"
  description = "allow all"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "all"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "one-tier-sg"
  }
  
}

resource "aws_instance" "web" {

  ami = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "Helo from Terraform EC2" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-server"
  }            
  
}