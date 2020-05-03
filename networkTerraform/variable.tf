# Variables
variable "profile" {
  default = "terraform_iam_user"
}

variable "region" {
  default = "eu-north-1"
}

variable "availability_zone" {
  default = "eu-north-1a"
}

variable "cidr_block_range" {
  description = "The CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "subnet1_cidr_block_range" {
  description = "The CIDR block for public subnet of VPC"
  default     = "10.1.0.0/24"
}

variable "subnet2_cidr_block_range" {
  description = "The CIDR block for private subnet of VPC"
  default     = "10.2.0.0/24"
}

variable "environment_tag" {
  description = "Environment tag"
  default     = ""
}

variable "public_key" {
  default = "~/.ssh/buildbot.pem.pub"
}