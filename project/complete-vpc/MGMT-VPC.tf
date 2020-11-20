module "MGMT-VPC" {
  source = "../../"
  name = "mgmt-vpc"
  cidr = "10.10.0.0/16"

  azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets      = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  database_subnets    = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
  #elasticache_subnets = ["10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24"]
  #redshift_subnets    = ["10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24"]

  #private_subnet_1 = "${module.MGMT-VPC.aws_subnet.private[0].id,0}"

  AMIS = "ami-02bcbb802e03574ba"
  webserver_AMIS = "ami-02bcbb802e03574ba"
  appserver_AMIS = "ami-02bcbb802e03574ba"
  dbserver_AMIS = "ami-02bcbb802e03574ba"
  bastionserver_AMIS = "ami-056f139b85f494248"
  jenkinsserver_AMIS = "ami-0f2b4fc905b0bd1f1"
  nexusserver_AMIS = "ami-0b500ef59d8335eee"
  artifactoryserver_AMIS = "ami-0b500ef59d8335eee"
  splunkserver_AMIS = "ami-0b500ef59d8335eee"
  elkserver_AMIS = "ami-0b500ef59d8335eee"
  sonarqubeserver_AMIS = "ami-0b500ef59d8335eee"
  icingaserver_AMIS = "ami-0b500ef59d8335eee"
  proxyserver_AMIS = "ami-0c55b159cbfafe1f0"
  openvpnserver_AMIS = "ami-0352afdfcf90ad1b5"

  create_database_subnet_group = false
  enable_bastion = true
  enable_jenkins = true
  enable_nexus = false
  enable_sonarqube = false
  enable_artifactory = false
  enable_splunk = false
  enable_elk = false
  enable_proxy = false
  enable_openvpn = false
  enable_icinga = false

  enable_nat_gateway = true
  enable_vpn_gateway = false

  enable_s3_endpoint       = true
  #enable_dynamodb_endpoint = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "service.consul"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}
