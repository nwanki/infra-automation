Splunk:
******************************************************

---
Steps to perfrom:
1) Clone the repo
2) cd splunk-terraform
3) ssh-keygen -f mykey
	<------ HIT ENTER
4) Download the Splunk Enterprise tgz file to splunk-playbook/roles/splunk/files/
   cd splunk-playbook/roles/splunk/files/
   wget -O splunk-7.2.4-8a94541dcfac-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.2.4&product=splunk&filename=splunk-7.2.4-8a94541dcfac-Linux-x86_64.tgz&wget=true'
   cd -
5) Manually create your own S3 bucket and update backend.tf
6) terraform init
7) terrafrom plan
8) terrafrom apply
---
