# VPC
output "MGMT-vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.MGMT-VPC.vpc_id}"
}

# VPC
output "DEV-vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.DEV-VPC.vpc_id}"
}


# VPC
output "PROD-vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.PROD-VPC.vpc_id}"
}

/*
#INSTANCES
output "capacitybay_webinstance_AZ1_private_ip" {
  description = "This is the capacitybay webinstance 1 Private IP"
  value       = "${module.vpc.capacitybay_webinstance_AZ1_private_ip}"
}
output "capacitybay_webinstance_AZ2_private_ip" {
  description = "This is the capacitybay webinstance 2 Private IP"
  value       = "${module.vpc.capacitybay_webinstance_AZ2_private_ip}"
}
output "capacitybay_appinstance_AZ1_private_ip" {
  description = "This is the capacitybay appinstance 1 Private IP"
  value       = "${module.vpc.capacitybay_appinstance_AZ1_private_ip}"
}
output "capacitybay_appinstance_AZ2_private_ip" {
  description = "This is the capacitybay appinstance 2 Private IP"
  value       = "${module.vpc.capacitybay_appinstance_AZ2_private_ip}"
}
output "capacitybay_dbinstance_AZ1_private_ip" {
  description = "This is the capacitybay dbinstance 1 Private IP"
  value       = "${module.vpc.capacitybay_dbinstance_AZ1_private_ip}"
}
output "capacitybay_dbinstance_AZ2_private_ip" {
  description = "This is the capacitybay dbinstance 2 Private IP"
  value       = "${module.vpc.capacitybay_dbinstance_AZ2_private_ip}"
}
#output "capacitybay_adinstance_AZ1_private_ip" {
#  description = "This is the capacitybay AD instance 1 Private IP"
#  value       = "${module.vpc.capacitybay_adinstance_AZ1_private_ip}"
#}
#output "capacitybay_adinstance_AZ2_private_ip" {
#  description = "This is the capacitybay AD instance 2 Private IP"
#  value       = "${module.vpc.capacitybay_adinstance_AZ2_private_ip}"
#}
output "capacitybay_bastion_public_ip" {
  description = "This is the capacitybay Bastion Public IP"
  value       = "${module.vpc.capacitybay_bastion_public_ip}"
}


# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc.public_subnets}"]
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = ["${module.vpc.database_subnets}"]
}

#output "elasticache_subnets" {
#  description = "List of IDs of elasticache subnets"
#  value       = ["${module.vpc.elasticache_subnets}"]
#}

#output "redshift_subnets" {
#  description = "List of IDs of redshift subnets"
#  value       = ["${module.vpc.redshift_subnets}"]
#}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${module.vpc.nat_public_ips}"]
}


*/

