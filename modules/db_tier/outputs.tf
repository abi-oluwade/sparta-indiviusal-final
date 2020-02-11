output "security_group_id" {
  description = "The id of the security group"
  value = "${aws_security_group.db.id}"
}
#
output "db_host1" {
  description = "Assign the IP for db_host"
  value = "${aws_instance.Abi_DB1.private_ip}"
}
output "db_host2" {
  description = "Assign the IP for db_host"
  value = "${aws_instance.Abi_DB2.private_ip}"
}
output "db_host3" {
  description = "Assign the IP for db_host"
  value = "${aws_instance.Abi_DB3.private_ip}"
}
