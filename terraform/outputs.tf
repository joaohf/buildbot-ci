output "vpc-id" {
  value = "${aws_vpc.vpc.id}"
}
output "public-subnets" {
  value = ["${aws_subnet.default.id}"]
}

output "security-groups" {
  value = ["${aws_security_group.worker.id}"]
}

output "bb-master-public-ip" {
  value = "${aws_instance.bb-master.0.public_ip}"
}

output "bb-master-public-dns" {
  value = "${aws_instance.bb-master.0.public_dns}"
}
output "bb-master-private-dns" {
  value = "${aws_instance.bb-master.0.private_dns}"
}
output "bb-master-private-ip" {
  value = "${aws_instance.bb-master.0.private_ip}"
}

output "bb-master-eip-public_ip" {
  value = "${aws_eip.bb-master.public_ip}"
}

output "bb-master-eip-public_dns" {
  value = "${aws_eip.bb-master.public_dns}"
}

output "url-bb-master" {
  value = "http://${aws_eip.bb-master.public_dns}:8010"
}

/*
output "bb-workers-public-dns" {
  value = "${aws_instance.bb-worker.*.public_dns}"
}
output "bb-workers-public-ip" {
  value = "${aws_instance.bb-worker.*.public_ip}"
}
*/