# Create Subnets for app
resource "aws_subnet" "app_1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "app_2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "app_3" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1c"
}

# Create security groups
resource "aws_security_group" "app" {
  name = "Application security groups"
  description = "Application access"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
   from_port       = 0
   to_port         = 0
   protocol        = "-1"
   cidr_blocks     = ["0.0.0.0/0"]
  }

 ingress {
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   from_port  = 1024
   to_port    = 65535
  }
}

# Create network ACL
resource "aws_network_acl" "app" {
  vpc_id = "${var.vpc_id}"

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # EPHEMERAL PORTS

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  subnet_ids   = ["${aws_subnet.app_1.id}", "${aws_subnet.app_2.id}", "${aws_subnet.app_3.id}"]

  tags = {
    Name = "${var.name}"
  }
}

# Create public route table
resource "aws_route_table" "app" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.ig_id}"
  }

  tags = {
    Name = "${var.name}-public"
  }
}

# Create public route table associations
resource "aws_route_table_association" "app1" {
  subnet_id      = "${aws_subnet.app_1.id}"
  route_table_id = "${aws_route_table.app.id}"
}

resource "aws_route_table_association" "app2" {
  subnet_id      = "${aws_subnet.app_2.id}"
  route_table_id = "${aws_route_table.app.id}"
}

resource "aws_route_table_association" "app3" {
  subnet_id      = "${aws_subnet.app_3.id}"
  route_table_id = "${aws_route_table.app.id}"
}

# Create Load balancer, target group and listener
resource "aws_lb" "Abi_LB" {
  name               = "${var.name}-app-elb"
  internal           = false
  load_balancer_type = "network"
  subnets = ["${aws_subnet.app_1.id}", "${aws_subnet.app_2.id}", "${aws_subnet.app_3.id}"]
  enable_deletion_protection = false

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_lb_target_group" "Abi_LB_TG" {
  name     = "Abi-Individual-Project-TG"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "Abi_AppL" {
  load_balancer_arn = "${aws_lb.Abi_LB.arn}"
  port = 80
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.Abi_LB_TG.arn}"
  }
}

# Create aws launch config with autoscaling
resource "aws_launch_configuration" "Abi_LaunchConfig" {
  name_prefix   = "${var.name}-app"
  image_id      = "${var.ami_id}"
  user_data = "${var.user_data}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.app.id}"]
}

resource "aws_autoscaling_group" "Abi_AppAutoScaling" {
  name = "Abi-AppAutoScaling"
  vpc_zone_identifier = ["${aws_subnet.app_1.id}", "${aws_subnet.app_2.id}", "${aws_subnet.app_3.id}"]
  desired_capacity = 3
  max_size = 3
  min_size = 3
  launch_configuration = "${aws_launch_configuration.Abi_LaunchConfig.name}"
  target_group_arns = ["${aws_lb_target_group.Abi_LB_TG.arn}"]
}
