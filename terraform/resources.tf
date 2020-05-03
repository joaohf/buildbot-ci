resource "aws_key_pair" "demo_key" {
  key_name   = "buildbot"
  public_key = file(var.public_key)
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Environment" = var.environment_tag
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet1_cidr_block_range
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.default]
}

data "aws_ami" "master-ami" {
  filter {
    name   = "state"
    values = ["available"]
  }
  owners = ["self"]

  filter {
    name   = "name"
    values = ["buildbot-master-base-*"]
  }
  filter {
    name   = "tag:Name"
    values = ["Packer-Ansible"]
  }

  most_recent = true
}

resource "aws_instance" "bb-master" {
  count = var.bb_master_instance_count

  ami           = data.aws_ami.master-ami.id
  instance_type = var.instance
  key_name      = aws_key_pair.demo_key.key_name

  subnet_id = aws_subnet.default.id

  private_ip = var.bb_master_private_ip

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.egress.id}",
    "${aws_security_group.ping-ICMP.id}",
    "${aws_security_group.buildbot.id}"
  ]

  tags = {
    Name = "bb-master-${count.index + 1}"
    Type = "master"
  }
}

/*
# A worker instance used to check if buildmaster is working properly
data "aws_ami" "worker-ami" {
  filter {
    name   = "state"
    values = ["available"]
  }
  owners = ["self"]

  filter {
    name   = "name"
    values = ["buildbot-worker-base-*"]
  }
  filter {
    name   = "tag:Name"
    values = ["Packer-Ansible"]
  }

  most_recent = true
}

resource "aws_instance" "bb-worker" {
  count = var.bb_worker_instance_count

  ami           = data.aws_ami.worker-ami.id
  instance_type = var.woker_instance
  key_name      = aws_key_pair.demo_key.key_name

  subnet_id = aws_subnet.default.id

  vpc_security_group_ids = [
    "${aws_security_group.worker.id}"
  ]

  //iam_instance_profile = "test_profile"

  # tmp
#  ephemeral_block_device {
#    device_name  = "/dev/sdg"
#    virtual_name = "ephemeral0"
#  }

  tags = {
    Name     = "bb-worker-${count.index + 1}"
    Batch    = "7AM"
    Location = "Stockholm"
  }
}
*/

resource "aws_eip" "bb-master" {
  vpc = true

  instance                  = aws_instance.bb-master.0.id
  associate_with_private_ip = var.bb_master_private_ip
  depends_on                = [aws_internet_gateway.default]
}

resource "aws_security_group" "ssh" {
  name        = "default-ssh-example"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-example-default-vpc"
  }
}

resource "aws_security_group" "egress" {
  name        = "default-egress-example"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "egress-example-default-vpc"
  }
}

resource "aws_security_group" "ping-ICMP" {
  name        = "default-ping-example"
  description = "Default security group that allows to ping the instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ping-ICMP-example-default-vpc"
  }
}

# Allow buildbot
resource "aws_security_group" "buildbot" {
  name        = "default-buildbot"
  description = "Default security group that allows buildbot"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 8010
    to_port     = 8010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9989
    to_port     = 9989
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "buildbot-example-default-vpc"
  }
}

resource "aws_security_group" "worker" {
  name        = "default-worker-example"
  description = "Security group for worker instances that allows SSH and VPN outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
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
    Name = "ssh-example-default-vpc"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "s3-yocto"
  acl    = "private"

  versioning {
    enabled = false
  }
}