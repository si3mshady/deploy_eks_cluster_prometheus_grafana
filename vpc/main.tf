
data "aws_availability_zones" "available" {}

resource "random_integer" "rand_int" {
  min = 1
  max = 10
}

resource "aws_vpc" "elliott-k8s-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "elliott-k8s-${random_integer.rand_int.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "public_k8_subnets" {

  count = var.public_subnet_count

  cidr_block              = var.public_k8s_subnets[count.index]
  vpc_id                  = aws_vpc.elliott-k8s-vpc.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public-subnet-${count.index}"
  }
}


resource "aws_subnet" "private_k8_subnets" {

  count                   = var.private_subnet_count
  cidr_block              = var.private_k8s_subnets[count.index]
  vpc_id                  = aws_vpc.elliott-k8s-vpc.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.elliott-k8s-vpc.id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.elliott-k8s-vpc.id
  tags = {
    Name = "public_route_table"
  }
}


resource "aws_route_table_association" "public_rt_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_k8_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}



resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.elliott-k8s-vpc.id
  tags = {
    Name = "private_route_table"
  }
}


resource "aws_route" "private_route" {
  count          = var.private_subnet_count
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "private_rt_association" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_k8_subnets.*.id[count.index]
  route_table_id = aws_route_table.private_route_table.id
}





resource "aws_security_group" "public_sg" {

  name   = "public_sg"
  vpc_id = aws_vpc.elliott-k8s-vpc.id
  ingress {
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_security_group" "referenced_sg" {

  name   = "referenced_sg"
  vpc_id = aws_vpc.elliott-k8s-vpc.id
  ingress {
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.public_sg.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




data "aws_ami" "ubuntu" {
  most_recent = true
}

resource "aws_key_pair" "elliot_public_key" {
  key_name   = "el-public-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDboh6RNEjkyjmG2qZe5l+8caS2tQz8L/2n/1XPgdHjrlW7O2bO6tWgqeBz7YLEFocGeNpkUe4Apd+lMT5+6AS/aEUGhxpYYApIcBAASvy0MgMFyyOke7nUBq6yIQa4CKmATFK4MNX/7RpsDsnCjKLSOpcihHeXl3Hr+ROwICYlhH9tOY7G60Rean74wbGGvlppjiCkNB+PJG80ZL8GEhTFpQjQrybeYLETnzux7ARQNkulwTkee2WV2Fex46MVSJi2eiXWlvKIGX/eCfWrLVXQGyXeV7ZmfZ8cOnx6iVVODiFVBHFX7uDyBlGouNrq72ghHKxHBykfC8TPuLgjs6T4lP+ejWocJ4TsnVm8fWMtY0UliNlYU0zm+sSpVsaJV/X9M+kWXksDVuQBgHkNe8WPsHY4ZvmxBmVEKm+/YxCMpUfKumgXUV58dK5MgfUTuKp644T0sXMq9x6jbc8DIEP62ZAZkRvZnO+mKW84+C6RVqv2cQkGg212ON/om7U62DM= elliottarnold@Elliotts-Air.attlocal.net"
}


resource "aws_instance" "web-bastion-public" {
  ami           = "ami-05e18b6e52b45091e"
  instance_type = "t3.micro"
  associate_public_ip_address = true
  
  vpc_security_group_ids = [aws_security_group.public_sg.id, aws_security_group.referenced_sg.id]
  subnet_id = aws_subnet.public_k8_subnets[0].id
  key_name =  aws_key_pair.elliot_public_key.key_name
  tags = {
    Name = "Public-Bastion"
  }


   user_data = <<EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san $(curl http://169.254.169.254/latest/meta-data/public-ipv4)" sh -s -
    EOF
}


# resource "aws_instance" "web-bastion-private" {
#   ami           = "ami-05e18b6e52b45091e"
#   instance_type = "t3.micro"
#   associate_public_ip_address = false
  
#   vpc_security_group_ids = [aws_security_group.public_sg.id, aws_security_group.referenced_sg.id]
#   subnet_id = aws_subnet.private_k8_subnets[0].id
#   key_name =  aws_key_pair.elliot_public_key.key_name
#   tags = {
#     Name = "Private-Instance"
#   }
# }




resource "aws_iam_group_policy" "devops_admin_group" {
  name  = "devops_admin_group_policy"
  group = aws_iam_group.devops_admin_group.name


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group" "devops_admin_group" {
  name = "devops_admin_group"
  
}




resource "aws_iam_role" "eks-admin" {
  name = "eks-admin"


  inline_policy {
    name = "admin_inline_policy"
   policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF



}   
