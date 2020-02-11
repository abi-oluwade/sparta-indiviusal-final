resource "aws_route_table" "db" {
  vpc_id = "${var.vpc_id}"
  tags = {
    Name = "Abi Database Route Table"
  }
}

# Private subnets for the DB
resource "aws_subnet" "db1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region1}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}-db1-subnet"
  }
}

resource "aws_subnet" "db2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.region2}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}-db2-subnet"
  }
}

resource "aws_subnet" "db3" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.region3}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}-db3-subnet"
  }
}

# Database instances
resource "aws_instance" "Abi_DB1" {
  ami = "ami-04430290caa8c0b25"
  subnet_id = "${aws_subnet.db1.id}"
  security_groups = ["${aws_security_group.db.id}"]
  instance_type = "t2.micro"
  availability_zone = "${var.region1}"
  private_ip = "10.0.3.10"
  tags = {
    Name = "Abi-DB1"
  }
  user_data = "${var.user_data}"

}
resource "aws_instance" "Abi_DB2" {
  ami = "ami-04430290caa8c0b25"
  subnet_id = "${aws_subnet.db2.id}"
  security_groups = ["${aws_security_group.db.id}"]
  instance_type = "t2.micro"
  availability_zone = "${var.region2}"
  private_ip = "10.0.4.10"
  tags = {
    Name = "Abi-DB2"
  }
}
resource "aws_instance" "Abi_DB3" {
  ami = "ami-04430290caa8c0b25"
  subnet_id = "${aws_subnet.db3.id}"
  security_groups = ["${aws_security_group.db.id}"]
  instance_type = "t2.micro"
  availability_zone = "${var.region3}"
  private_ip = "10.0.5.10"
  tags = {
    Name = "Abi-DB3"
  }
}

#Route table for the private DB
resource "aws_route_table_association" "db1" {
  subnet_id     = "${aws_subnet.db1.id}"
  route_table_id = "${aws_route_table.db.id}"
}
resource "aws_route_table_association" "db2" {
  subnet_id     = "${aws_subnet.db2.id}"
  route_table_id = "${aws_route_table.db.id}"
}
resource "aws_route_table_association" "db3" {
  subnet_id     = "${aws_subnet.db3.id}"
  route_table_id = "${aws_route_table.db.id}"
}

#Security group for the Database
resource "aws_security_group" "db" {
  name = "${var.name}-db"
  description = "db Security Group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "27017"
    to_port = "27017"
    protocol = "tcp"
    cidr_blocks= ["0.0.0.0/0"]
    security_groups = ["${var.app_sg}"]
  }

  ingress {
    from_port = "1024"
    to_port = "65535"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db"
  }
}

#Nacl for the Database
resource "aws_network_acl" "db" {
  vpc_id = "${var.vpc_id}"

  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 27017
    to_port = 27017
  }

  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  #Empheral ports
  egress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  subnet_ids = ["${aws_subnet.db1.id}","${aws_subnet.db2.id}","${aws_subnet.db3.id}"]

  tags = {
    Name = "${var.name}-db-Nacl"
  }
}
