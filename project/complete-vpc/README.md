Complete VPC
============

Configuration in this directory creates set of VPC resources which may be sufficient for staging or production environment (look into [simple-vpc](../simple-vpc) for more simplified setup).

There are public, private, database, ElastiCache subnets, NAT Gateways created in each availability zone.

Usage
=====

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
$ ssh -i mgmt-vpc-key centos@3.14.134.57 sudo cat /var/lib/jenkins/secrets/initialAdminPassword 
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
