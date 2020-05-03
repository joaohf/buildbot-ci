
# IAM access key to buildbot worker

resource "aws_iam_access_key" "bb-worker" {
  user = aws_iam_user.bb-worker.name
}

resource "aws_iam_user" "bb-worker" {
  name = "bb-worker"
  path = "/buildbot/worker/"
}

resource "aws_iam_user_policy" "bb-worker" {
  name = "bb-worker"
  user = aws_iam_user.bb-worker.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# IAM role and policy that will be attached to a instance

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = file("assumerolepolicy.json")
}

resource "aws_iam_instance_profile" "worker-profile" {
  name = "test_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_policy" "worker-policy" {
  name        = "worker-policy"
  description = "A worker policy"
  policy      = file("policys3bucket.json")
}

resource "aws_iam_policy_attachment" "worker-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = aws_iam_policy.worker-policy.arn
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet1_cidr_block_range
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone
  tags = {
    "Environment" = var.environment_tag
    "Type"        = "Public"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_key_pair" "ec2key" {
  key_name   = "publicKey"
  public_key = file(var.public_key)
}