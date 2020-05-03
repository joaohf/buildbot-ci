variable "profile" {
  default = "terraform_iam_user"
}

variable "region" {
  default = "eu-north-1"
}

variable "instance" {
  default = "t3.micro"
}

/*
variable "woker_instance" {
  default = "m5d.large"
}
*/

variable "bb_master_instance_count" {
  default = "1"
}

variable "bb_worker_instance_count" {
  default = "1"
}

variable "public_key" {
  default = "~/.ssh/buildbot.pem.pub"
}

variable "ansible_user" {
  default = "ubuntu"
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

variable "bb_master_private_ip" {
  description = "buildbot master private IP address"
  default     = "10.1.0.10"
}