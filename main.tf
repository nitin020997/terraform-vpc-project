provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "nitin_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "nitin-vpc"
  }
}

resource "aws_subnet" "nitin_public_subnet" {
  vpc_id                  = aws_vpc.nitin_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone

  tags = {
    Name = "nitin-public-subnet"
  }
}

resource "aws_internet_gateway" "nitin_igw" {
  vpc_id = aws_vpc.nitin_vpc.id

  tags = {
    Name = "nitin-internet-gateway"
  }
}

resource "aws_route_table" "nitin_public_rt" {
  vpc_id = aws_vpc.nitin_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nitin_igw.id
  }

  tags = {
    Name = "nitin-public-route-table"
  }
}

resource "aws_route_table_association" "nitin_public_rt_association" {
  subnet_id      = aws_subnet.nitin_public_subnet.id
  route_table_id = aws_route_table.nitin_public_rt.id
}

resource "aws_security_group" "nitin_ec2_sg" {
  name        = "nitin-ec2-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.nitin_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nitin-ec2-sg"
  }
}

resource "aws_instance" "nitin_ec2" {
  ami                    = "ami-03f4878755434977f" # Ubuntu 22.04 LTS in ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.nitin_public_subnet.id
  vpc_security_group_ids = [aws_security_group.nitin_ec2_sg.id]
  associate_public_ip_address = true
  key_name               = "nitin-keypair" # Must exist in AWS or you’ll need to create this

  tags = {
    Name = "nitin-ec2"
  }
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.nitin_ec2.public_ip
}