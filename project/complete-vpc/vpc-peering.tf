# MGMT to DEV VPC Peering
resource "aws_vpc_peering_connection" "MGMT-to-DEV" {
  peer_vpc_id   = "${module.DEV-VPC.vpc_id}"
  vpc_id        = "${module.MGMT-VPC.vpc_id}"
}

# MGMT to PROD VPC Peering
resource "aws_vpc_peering_connection" "MGMT-to-PROD" {
  peer_vpc_id   = "${module.PROD-VPC.vpc_id}"
  vpc_id        = "${module.MGMT-VPC.vpc_id}"
}

