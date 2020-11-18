AWS VPC Terraform module
========================

Usage
=====

To run this example you need to execute:

```bash
$ cd project/complete-vpc
```

Configure AWSCLI:
```bash
$ aws configure
region: us-east-2
```

Terraform Commands:
```bash
$ terraform init
$ terraform plan
$ terraform apply
$ ssh -i mgmt-vpc-key centos@3.14.134.57 sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.



Build the jenkins pipeline project https://github.com/nwanki/javaprojrepo.git



Terraform version
-----------------

Terraform version 0.11.14 is required for this module to work.

Project
--------

* [Complete VPC]



