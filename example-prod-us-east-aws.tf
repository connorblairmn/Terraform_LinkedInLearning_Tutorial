variable "whitelist" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
variable "web_image_id" {
  type = string
  default = "ami-0743f105d738afe6a"
}
variable "web_instance_type" {
  type = string
  default = "t2.micro"
}
variable "web_desired_capacity" {
  type = number 
  default = 1
}
variable "web_max_size" {
  type = number 
  default = 1
}
variable "web_min_size" {
  type = number 
  default = 1
}


provider "aws" {
  profile = "default"
  region  = "us-east-2"
}
//create s3 bucket 
resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "terraform-tutorial-bucket-20201015"
  acl    = "private"
}
//create default vpc
resource "aws_default_vpc" "default" {}
//create subnet in availability zone a
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-2a"
  tags = {
    "Terraform" : "true"
  }
}
//create subnet in availability zone b
resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-2b"
  tags = {
    "Terraform" : "true"
  }
}
//create subnet in availability zone c
resource "aws_default_subnet" "default_az3" {
  availability_zone = "us-east-2c"
  tags = {
    "Terraform" : "true"
  }
}

//create simple security group 
resource "aws_security_group" "prod_web" {
  name       = "prod_web"
  description= "Allow standard http and https ports inbound and everything outbound."
  //http input from any IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist 
  }
  //https input from any IP 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist 
  }
  //output to anywhere with any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist 
  }

  tags = {
    "Terraform" : "true"
  }
  
}

module "web_app" {
  source = "./modules/web_app"

  web_image_id         = var.web_image_id
  web_instance_type    = var.web_instance_type
  web_desired_capacity = var.web_desired_capacity
  web_max_size         = var.web_max_size
  web_min_size         = var.web_min_size
  subnets              = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
  security_groups      = [aws_security_group.prod_web.id]
  web_app              = "prod"
}