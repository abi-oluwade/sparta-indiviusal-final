variable "name" {
  default="Abi-Individual-Project"
  description = "The name of the user"
}

variable "user_data" {
  description = "the user data to provision the instance"
}

variable "vpc_id" {
  description = "the vpc to launch the resource to"
}

variable "ig_id" {
  description = "The internet gateway to attach to route table"
}

variable "cidr_block" {
  default="10.0.0.0/16"
}

variable "ami_id" {
  description = "The app ami"
}

variable "availability_zone" {
  default = "eu-west-1a, eu-west-1b, eu-west-1c"
}
