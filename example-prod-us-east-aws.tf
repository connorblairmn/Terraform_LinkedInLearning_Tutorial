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
    cidr_blocks = ["0.0.0.0/0"]
  }
  //https input from any IP 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  //output to anywhere with any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
  
}
//ngxin instance (create 2)
resource "aws_instance" "prod_web" {
  count = 2
  ami           = "ami-0743f105d738afe6a"
  instance_type = "t2.nano"
  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" : "true"
  }
}
//associate eip and instance 
resource "aws_eip_association" "prod_web" {
  instance_id   = aws_instance.prod_web[0].id
  allocation_id = aws_eip.prod_web.id

}

//elastic IP
resource "aws_eip" "prod_web" {
    //instance = aws_instance.prod_web.id
    tags = {
    "Terraform" : "true"
  }
}

//elastic load balancer 
resource "aws_elb" "prod_web" {
  name           = "prod-web"
  //all instances in prod_web 
  instances      = aws_instance.prod_web[*].id
  subnets        = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
  security_groups= [aws_security_group.prod_web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    "Terraform" : "true"
  }
}


