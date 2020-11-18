terraform {
  backend "s3" {
    bucket = "terraform-infra-code-anu-version"
    key = "Rome-dnstest"
  }
}
