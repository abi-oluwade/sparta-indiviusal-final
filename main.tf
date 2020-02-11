# Configure the AWS provider
provider "aws" {
  region = "eu-west-1"
}

# Creates a Virtual Private Network (VPC)
resource "aws_vpc" "n_tier" {
  cidr_block = "10.0.0.0/16"
}

# internet gateway
resource "aws_internet_gateway" "app" {
  vpc_id = "${aws_vpc.n_tier.id}"

  tags = {
    Name = "Internet Gateway"
  }
}

data "template_file" "app_init" {
  template = "${file("./scripts/app/setup.sh.tpl")}"
  vars = {
    db_host1 = "${module.db.db_host1}"
    db_host2 = "${module.db.db_host2}"
    db_host3 = "${module.db.db_host3}"
  }
}

data "template_file" "db_init" {
  template = "${file("./scripts/db/setup.sh.tpl")}"
}

# app_tier modules
module "app" {
  source = "./modules/app_tier"
  vpc_id = "${aws_vpc.n_tier.id}"
  user_data = "${data.template_file.app_init.rendered}"
  ig_id = "${aws_internet_gateway.app.id}"
  ami_id = "${var.app_ami}"
}

# db_tier modules
module "db" {
  source = "./modules/db_tier"
  vpc_id = "${aws_vpc.n_tier.id}"
  db_ami_id = "${var.db_ami}"
  app_sg = "${module.app.security_group_id}"
  app_subnet_cidr_block = "${module.app.subnet_cidr_block}"
  ig_id = "${aws_internet_gateway.app.id}"
  user_data = "${data.template_file.db_init.rendered}"
}
