provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "terraform-tutorial-bucket-20201015"
  acl    = "private"
}

resource "aws_default_vpc" "default" {}

