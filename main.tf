terraform {
  required_version = ">= 0.11.11" # introduction of Local Values configuration language feature
}

locals {
  #max_subnet_length = "${max(length(var.private_subnets), length(var.elasticache_subnets), length(var.database_subnets), length(var.redshift_subnets))}"
  max_subnet_length = "${max(length(var.private_subnets), length(var.database_subnets))}"
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = "${var.create_vpc ? 1 : 0}"

  cidr_block           = "${var.cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${merge(var.tags, var.vpc_tags, map("Name", format("%s", var.name)))}"
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = ["${var.dhcp_options_domain_name_servers}"]
  ntp_servers          = ["${var.dhcp_options_ntp_servers}"]
  netbios_name_servers = ["${var.dhcp_options_netbios_name_servers}"]
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(var.tags, var.dhcp_options_tags, map("Name", format("%s", var.name)))}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, var.public_route_table_tags, map("Name", format("%s-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

#################
# Private routes
# There are so many routing tables as the largest amount of subnets of each type (really?)
#################
resource "aws_route_table" "private" {
  count = "${var.create_vpc && local.max_subnet_length > 0 ? local.max_subnet_length : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, var.private_route_table_tags, map("Name", format("%s-private-%s", var.name, element(var.azs, count.index))))}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-public-%s", var.name, element(var.azs, count.index))))}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-private-%s", var.name, element(var.azs, count.index))))}"
}

##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = "${var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.database_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.database_subnet_tags, map("Name", format("%s-db-%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_db_subnet_group" "database" {
  count = "${var.create_vpc && length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0}"

  name        = "${lower(var.name)}"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

##################
# Redshift subnet
##################
#resource "aws_subnet" "redshift" {
#  count = "${var.create_vpc && length(var.redshift_subnets) > 0 ? length(var.redshift_subnets) : 0}"

#  vpc_id            = "${aws_vpc.this.id}"
#  cidr_block        = "${var.redshift_subnets[count.index]}"
#  availability_zone = "${element(var.azs, count.index)}"

#  tags = "${merge(var.tags, var.redshift_subnet_tags, map("Name", format("%s-redshift-%s", var.name, element(var.azs, count.index))))}"
#}

#resource "aws_redshift_subnet_group" "redshift" {
#  count = "${var.create_vpc && length(var.redshift_subnets) > 0 ? 1 : 0}"
#
#  name        = "${var.name}"
#  description = "Redshift subnet group for ${var.name}"
#  subnet_ids  = ["${aws_subnet.redshift.*.id}"]
#
#  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
#}

#####################
# ElastiCache subnet
#####################
#resource "aws_subnet" "elasticache" {
#  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0}"
#
#  vpc_id            = "${aws_vpc.this.id}"
#  cidr_block        = "${var.elasticache_subnets[count.index]}"
#  availability_zone = "${element(var.azs, count.index)}"
#
#  tags = "${merge(var.tags, var.elasticache_subnet_tags, map("Name", format("%s-elasticache-%s", var.name, element(var.azs, count.index))))}"
#}
#
#resource "aws_elasticache_subnet_group" "elasticache" {
#  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? 1 : 0}"
#
#  name        = "${var.name}"
#  description = "ElastiCache subnet group for ${var.name}"
#  subnet_ids  = ["${aws_subnet.elasticache.*.id}"]
#}




##############
# NAT Gateway
##############
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${var.create_vpc && (var.enable_nat_gateway && !var.reuse_nat_ips) ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  vpc = true

  tags = "${merge(var.tags, map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))))}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.create_vpc && var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(var.tags, map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))))}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.create_vpc && var.enable_nat_gateway ? length(var.private_subnets) : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}




######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  vpc_id       = "${aws_vpc.this.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? length(var.private_subnets) : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

############################
# VPC Endpoint for DynamoDB
############################
#data "aws_vpc_endpoint_service" "dynamodb" {
#  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"
#
#  service = "dynamodb"
#}

#resource "aws_vpc_endpoint" "dynamodb" {
#  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"
#
#  vpc_id       = "${aws_vpc.this.id}"
#  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
#}
#
#resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
#  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? length(var.private_subnets) : 0}"
#
#  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
#  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
#}
#
#resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
#  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? length(var.public_subnets) : 0}"
#
#  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
#  route_table_id  = "${aws_route_table.public.id}"
#}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "database" {
  count = "${var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

#resource "aws_route_table_association" "redshift" {
#  count = "${var.create_vpc && length(var.redshift_subnets) > 0 ? length(var.redshift_subnets) : 0}"
#
#  subnet_id      = "${element(aws_subnet.redshift.*.id, count.index)}"
#  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
#}

#resource "aws_route_table_association" "elasticache" {
#  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0}"
#
#  subnet_id      = "${element(aws_subnet.elasticache.*.id, count.index)}"
#  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
#}

resource "aws_route_table_association" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "this" {
  count = "${var.create_vpc && var.enable_vpn_gateway ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_vpn_gateway_attachment" "this" {
  count = "${var.vpn_gateway_id != "" ? 1 : 0}"

  vpc_id         = "${aws_vpc.this.id}"
  vpn_gateway_id = "${var.vpn_gateway_id}"
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = "${var.create_vpc && var.propagate_public_route_tables_vgw && (var.enable_vpn_gateway  || var.vpn_gateway_id != "") ? 1 : 0}"

  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = "${var.create_vpc && var.propagate_private_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? length(var.private_subnets) : 0}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}

###########
# Defaults
###########
resource "aws_default_vpc" "this" {
  count = "${var.manage_default_vpc ? 1 : 0}"

  enable_dns_support   = "${var.default_vpc_enable_dns_support}"
  enable_dns_hostnames = "${var.default_vpc_enable_dns_hostnames}"
  enable_classiclink   = "${var.default_vpc_enable_classiclink}"

  tags = "${merge(var.tags, var.default_vpc_tags, map("Name", format("%s", var.default_vpc_name)))}"
}

resource "aws_default_route_table" "this" {
  count = "${var.create_vpc ? 1 : 0}"

  default_route_table_id = "${aws_vpc.this.default_route_table_id}"

  tags = "${merge(var.tags, var.default_route_table_tags, map("Name", format("%s-default", var.name)))}"
}

resource "aws_main_route_table_association" "this" {
  count = "${var.create_vpc ? 1 : 0}"

  vpc_id         = "${aws_vpc.this.id}"
  route_table_id = "${aws_default_route_table.this.default_route_table_id}"
}

resource "aws_security_group" "capacitybay-secgrp" {
 name = "capacitybay-secgrp"
 vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = "9000"
    to_port = "9000"
    protocol = "tcp"
    cidr_blocks = [ "10.10.0.0/16" ]
  }
  ingress {
    from_port = "8081"
    to_port = "8081"
    protocol = "tcp"
    cidr_blocks = [ "10.10.0.0/16" ]
  }
  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = [ "10.10.0.0/16" ]
  }
  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = "8200"
    to_port = "8200"
    protocol = "tcp"
    cidr_blocks = [ "10.10.0.0/16" ]
  }
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = [ "10.10.0.0/16" ]
  }
 ingress {
    from_port = "3389"
    to_port = "3389"
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

tags {
    Name = "capacitybay-secgrp"
  }
}

resource "aws_key_pair" "mykey1" {
  key_name = "${var.name}"
  public_key = "${file("${var.name}-key.pub")}"
}

/*
resource "aws_instance" "capacitybay-webtier-1" {
  ami = "${var.webserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = 1
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
tags {
    Name = "capacitybay-webtier-1-AZ1"
  }
}

resource "aws_instance" "capacitybay-application-1" {
  ami = "${var.appserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = 1
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
tags {
    Name = "capacitybay-application-1-AZ1"
  }
}

resource "aws_instance" "capacitybay-db-1" {
  ami = "${var.dbserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = 1
  subnet_id      = "${element(aws_subnet.private.*.id, count.index + 2)}"
tags {
    Name = "capacitybay-DB-1-AZ1"
  }
}


resource "aws_instance" "capacitybay-webtier-2" {
  ami = "${var.webserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = 1
  subnet_id      = "${element(aws_subnet.private.*.id, count.index + 1)}"
tags {
    Name = "capacitybay-webtier-2-AZ2"
  }
}

resource "aws_instance" "capacitybay-application-2" {
  ami = "${var.appserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = 1
  subnet_id      = "${element(aws_subnet.private.*.id, count.index + 1)}"
tags {
    Name = "capacitybay-application-2-AZ2"
  }
}

resource "aws_instance" "capacitybay-db-2" {
  ami = "${var.dbserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = 1
  subnet_id      = "${element(aws_subnet.private.*.id, count.index + 2)}"
tags {
    Name = "capacitybay-DB-2-AZ2"
  }
}

*/

resource "aws_instance" "capacitybay-bastion" {
  ami = "${var.bastionserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_bastion}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
tags {
    Name = "capacitybay-bastion"
  }
}


resource "aws_instance" "capacitybay-jenkins" {
  ami = "${var.jenkinsserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_jenkins}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
tags {
    Name = "capacitybay-jenkins"
  }
  provisioner "local-exec" {
     command = "sleep 120 && echo \"[jenkins-server]\n${aws_instance.capacitybay-jenkins.public_ip} ansible_connection=ssh ansible_ssh_user=centos ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > jenkins-inventory &&  ansible-playbook -i jenkins-inventory ansible-playbooks/jenkins-create.yml "
  }
  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
}


resource "aws_instance" "capacitybay-nexus" {
  ami = "${var.nexusserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_nexus}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  provisioner "local-exec" {
     command = "sleep 120 && echo \"[nexus-server]\n${aws_instance.capacitybay-nexus.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > nexus-inventory &&  ansible-playbook -i nexus-inventory ansible-playbooks/nexus-create.yml"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-nexus"
  }
}

resource "aws_instance" "capacitybay-sonarqube" {
  ami = "${var.sonarqubeserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_sonarqube}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  provisioner "local-exec" {
     command = "sleep 120 && echo \"[sonarqube-server]\n${aws_instance.capacitybay-sonarqube.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > sonarqube-inventory && ansible-playbook -i sonarqube-inventory ansible-playbooks/sonarqube-create.yml"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-sonarqube"
  }
}

resource "aws_instance" "capacitybay-artifactory" {
  ami = "${var.artifactoryserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_artifactory}"    
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  provisioner "local-exec" {
     command = "sleep 120 && echo \"[artifactory-server]\n${aws_instance.capacitybay-artifactory.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > artifactory-inventory && ansible-playbook -i artifactory-inventory ansible-playbooks/artifactory-create.yml"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-artifactory"
  }
}


resource "aws_instance" "capacitybay-proxy" {
  ami = "${var.proxyserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_proxy}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install python -y",
    ]
  }
  provisioner "local-exec" {
     command = "sleep 120 && echo \"[proxy-server]\n${aws_instance.capacitybay-proxy.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > proxy-inventory && ansible-playbook -i proxy-inventory ansible-playbooks/proxy-create.yml"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-proxy"
  }
}

resource "aws_instance" "capacitybay-openvpn" {
  ami = "${var.openvpnserver_AMIS}"
  instance_type = "t2.small"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_openvpn}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
tags {
    Name = "capacitybay-openvpn"
  }
}

resource "aws_instance" "capacitybay-splunk" {
  ami = "${var.splunkserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_splunk}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  provisioner "local-exec" {
     command = "sleep 120 && echo \"[splunk-server]\n${aws_instance.capacitybay-nexus.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > splunk-inventory &&  ansible-playbook -i splunk-inventory ansible-playbooks/splunk-create.yml"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-splunk"
  }
}

resource "aws_instance" "capacitybay-elk" {
  ami = "${var.elkserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_elk}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
   provisioner "local-exec" {
     command = "sleep 120 && echo \"[elk]\n${aws_instance.capacitybay-elk.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > elk-inventory &&  ansible-playbook -i elk-inventory ansible-playbooks/elk-automation/install/elk.yml"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-elk-master"
  }
}

resource "aws_instance" "capacitybay-elk-client" {
  ami = "${var.elkserver_AMIS}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_elk}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
   provisioner "local-exec" {
     command = "sleep 120 && echo \"[elk-client]\n${aws_instance.capacitybay-elk-client.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > elk-client-inventory &&  ansible-playbook -i elk-client-inventory ansible-playbooks/elk-automation/install/elk-client.yml --extra-vars 'elk_server=${aws_instance.capacitybay-elk.public_ip}'"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
tags {
    Name = "capacitybay-elk-client"
  }

}

resource "aws_instance" "capacitybay-icinga" {
  ami = "${var.icingaserver_AMIS}"
  instance_type = "t2.medium"
  vpc_security_group_ids = [ "${aws_security_group.capacitybay-secgrp.id}" ]
  key_name = "${aws_key_pair.mykey1.key_name}"
  count = "${var.enable_icinga}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"

   provisioner "local-exec" {
     command = "sleep 120 && echo \"[monitoring_servers]\n${aws_instance.capacitybay-icinga.public_ip} ansible_connection=ssh ansible_ssh_user=ec2-user ansible_ssh_private_key_file=mgmt-vpc-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'\" > icinga-inventory &&  ansible-playbook -i icinga-inventory ansible-playbooks/icinga-automation/icinga-playbooks/site-icinga.yml"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("mgmt-vpc-key")}"
  }
}

