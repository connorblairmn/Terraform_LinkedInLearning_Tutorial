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

variable "subnets" {
  type=list(string)
}

variable "security_groups" {
  type=list(string)
}

variable "web_app" {
  type=string
}