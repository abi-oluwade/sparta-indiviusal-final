output subnet_app_1_id {
  description = "The id of the subnet"
  value = "${aws_subnet.app_1.id}"
}

output subnet_app_2_id {
  description = "The id of the subnet"
  value = "${aws_subnet.app_2.id}"
}

output subnet_app_3_id {
  description = "The id of the subnet"
  value = "${aws_subnet.app_3.id}"
}

output subnet_cidr_block {
  description = "The cidr block of the subnet"
  value = "${aws_subnet.app_1.cidr_block}"
}

output security_group_id {
  description = "The id of the security group"
  value = "${aws_security_group.app.id}"
}
