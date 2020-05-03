output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
output "public_subnets" {
  value = ["${aws_subnet.subnet_public.id}"]
}
output "ec2keyName" {
  value = "${aws_key_pair.ec2key.key_name}"
}

output "bb-worker-secret" {
  value = "${aws_iam_access_key.bb-worker.secret}"
}

output "bb-worker-id" {
  value = "${aws_iam_access_key.bb-worker.id}"
}

output "worker_profile" {
  value = "${aws_iam_instance_profile.worker-profile.name}"
}