provider "aws" {
  region     = "us-east-1"   # Replace this with your desired AWS region

}
resource "aws_vpc" "wordpress-vpc" {
  cidr_block = "10.0.0.0/16"  # Replace this with the desired CIDR block for your VPC
  tags = {
    Name = "wordpress-vpc"
  }
}
resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  
  tags = {
    Name = "wordpress_igw"
  }
}
# subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  cidr_block              = "10.0.1.0/24"      # Replace this with the desired CIDR block for your subnet
  availability_zone       = "us-east-1a"       # Replace this with the desired availability zone
  map_public_ip_on_launch = true               # Set this to true if you want to auto-assign public IP addresses to instances in this subnet.

  tags = {
    Name = "public_subnet_1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  cidr_block              = "10.0.2.0/24"      # Replace this with the desired CIDR block for your subnet
  availability_zone       = "us-east-1a"       # Replace this with the desired availability zone
  map_public_ip_on_launch = true               # Set this to true if you want to auto-assign public IP addresses to instances in this subnet.

  tags = {
    Name = "public_subnet_2"
  }
}
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  cidr_block              = "10.0.3.0/24"      # Replace this with the desired CIDR block for your subnet
  availability_zone       = "us-east-1a"       # Replace this with the desired availability zone
  map_public_ip_on_launch = true               # Set this to true if you want to auto-assign public IP addresses to instances in this subnet.

  tags = {
    Name = "public_subnet_3"
  }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  cidr_block              = "10.0.4.0/24"      # Replace this with the desired CIDR block for your subnet
  availability_zone       = "us-east-1a"       # Replace this with the desired availability zone

  tags = {
    Name = "private_subnet_1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  cidr_block              = "10.0.5.0/24"      # Replace this with the desired CIDR block for your subnet
  availability_zone       = "us-east-1a"       # Replace this with the desired availability zone

  tags = {
    Name = "private_subnet_2"
  }
}
resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.
  cidr_block              = "10.0.6.0/24"      # Replace this with the desired CIDR block for your subnet
  availability_zone       = "us-east-1a"       # Replace this with the desired availability zone

  tags = {
    Name = "private_subnet_3"
  }
}
resource "aws_route_table" "wordpess-rt" {
  vpc_id = aws_vpc.wordpress-vpc.id  # Replace `aws_vpc.example` with the reference to your VPC resource.

  tags = {
    Name = "wordpess-rt"
  }
}


resource "aws_route_table" "wordpess-rt_nat" {
  vpc_id = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpess-rt_nat"
  }
}

#route tables
resource "aws_route" "public" {
  route_table_id         = aws_route_table.wordpess-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wordpress_igw.id  # Replace `aws_internet_gateway.example` with the reference to your Internet Gateway resource.
}
#route tables to public subnets
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.wordpess-rt.id
}
resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.wordpess-rt.id
}
resource "aws_route_table_association" "public_subnet3_association" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.wordpess-rt.id
}
# NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id  # Replace `aws_subnet.public_subnet` with the reference to your public subnet
}
resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.wordpess-rt_nat.id  
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.wordpess-rt_nat.id
}


#security group
resource "aws_security_group" "wordpress-sg" {
  name        = "wordpress-sg"
  description = "wordpress-sg security group"
  vpc_id      = aws_vpc.wordpress-vpc.id
  # Inbound rules (allow incoming traffic)
  ingress {
    from_port   = var.ingress_ports[0]  # Change this to the desired port
    to_port     = var.ingress_ports[0] # Change this to the desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to limit the IP range if needed
  }
  ingress {
    from_port   = var.ingress_ports[1] # Change this to the desired port
    to_port     = var.ingress_ports[1] # Change this to the desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to limit the IP range if needed
  }
  ingress {
    from_port   = var.ingress_ports[2]  # Change this to the desired port
    to_port     = var.ingress_ports[2] # Change this to the desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to limit the IP range if needed
  }
  # Add more inbound rules if required

  # Outbound rules (allow outgoing traffic)
  egress {
    from_port   = var.ingress_ports[0]  # Change this to the desired port
    to_port     = var.ingress_ports[0]# Change this to the desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to limit the IP range if needed
  }
  egress {
    from_port   = var.ingress_ports[1]  # Change this to the desired port
    to_port     = var.ingress_ports[1]  # Change this to the desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to limit the IP range if needed
  }
  egress {
    from_port   = var.ingress_ports[2]  # Change this to the desired port
    to_port     = var.ingress_ports[2]  # Change this to the desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to limit the IP range if needed
  }
  tags = {
    Name = "wordpess-sg"
  }
  # Add more outbound rules if required
}
variable "ingress_ports" {
  type = list(string)
  default = ["80","443","22"]  
}
# ssh key
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}

resource "local_file" "ssh-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "ssh-key.pem"
}
# ec2 instance
resource "aws_instance" "wordpress-ec2" {
  ami           = var.ami  # Replace with your desired AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  key_name      = "ssh-key"  # Replace with the name of the SSH key-pair created earlier
  security_groups = [aws_security_group.wordpress-sg.id]  # Attach the security group to the instance
  subnet_id     = aws_subnet.public_subnet_1.id

  
  tags = {
    Name = "wordpress-ec2"
  }
}
variable "ami" {
  type = string
  default = "ami-0f9ce67dcf718d332"
}
# Database security group
resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "rds-sg security group"
  vpc_id      = aws_vpc.wordpress-vpc.id
  # Inbound rules (allow incoming traffic)
  ingress {
    from_port   = 3306  # Change this to the desired port
    to_port     = 3306 # Change this to the desired port
    protocol    = "tcp"
    
  }
  egress {
    from_port   = 3306  # Change this to the desired port
    to_port     = 3306  # Change this to the desired port
    protocol    = "tcp"
    
  }
  tags = {
    Name = "rds-sg"
}
}
# traffic between security groups 
  resource "aws_security_group_rule" "allow_inbound_from_source_sg" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp" 
  source_security_group_id = aws_security_group.wordpress-sg.id
  security_group_id = aws_security_group.rds-sg.id
}
