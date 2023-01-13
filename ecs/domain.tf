data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

//resource "aws_route53_record" "www" {
//  zone_id = data.aws_route53_zone.hosted_zone.zone_id
//  name    = "www"
//  type    = "CNAME"
//  ttl     = 3600
//
//  weighted_routing_policy {
//    weight = 10
//  }
//
//  set_identifier = "Web-Home"
//  records        = [var.www_cn]
//}

resource "aws_acm_certificate" "elb_cert" {
  domain_name       = "*.${var.hosted_zone_name}"
  validation_method = "DNS"

  tags = {
    Name = "ELBCertificate"
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "elb_cert" {
  for_each = {
    for dvo in aws_acm_certificate.elb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "elb_cert" {
  certificate_arn         = aws_acm_certificate.elb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.elb_cert : record.fqdn]
}