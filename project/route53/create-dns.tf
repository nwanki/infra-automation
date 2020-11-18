resource "aws_route53_zone" "main-mgmt" {
  name = "itopstube.com"
  tags = {
    Environment = "mgmt"
  }
}

resource "aws_route53_zone" "dev" {
  name = "dev.itopstube.com"
  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = "${aws_route53_zone.main-mgmt.zone_id}"
  name    = "dev.itopstube.com"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.dev.name_servers.0}",
    "${aws_route53_zone.dev.name_servers.1}",
    "${aws_route53_zone.dev.name_servers.2}",
    "${aws_route53_zone.dev.name_servers.3}",
  ]
}

resource "aws_route53_zone" "uat" {
  name = "uat.itopstube.com"
  tags = {
    Environment = "uat"
  }
}

resource "aws_route53_record" "uat-ns" {
  zone_id = "${aws_route53_zone.main-mgmt.zone_id}"
  name    = "uat.itopstube.com"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.uat.name_servers.0}",
    "${aws_route53_zone.uat.name_servers.1}",
    "${aws_route53_zone.uat.name_servers.2}",
    "${aws_route53_zone.uat.name_servers.3}",
  ]
}

resource "aws_route53_zone" "prod" {
  name = "prod.itopstube.com"
  tags = {
    Environment = "prod"
  }
}

resource "aws_route53_record" "prod-ns" {
  zone_id = "${aws_route53_zone.main-mgmt.zone_id}"
  name    = "prod.itopstube.com"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.prod.name_servers.0}",
    "${aws_route53_zone.prod.name_servers.1}",
    "${aws_route53_zone.prod.name_servers.2}",
    "${aws_route53_zone.prod.name_servers.3}",
  ]
}

