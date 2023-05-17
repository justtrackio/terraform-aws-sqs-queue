locals {
  aws_account_id         = "123456789123"
  aws_region             = "eu-central-1"
  foreign_aws_account_id = "123456789120"
}

module "example" {
  source = "../.."

  tenant      = "tenant"
  namespace   = "namespace"
  environment = "environment"
  stage       = "stage"
  name        = "tracing"
  attributes  = ["foo"]

  aws_account_id                  = local.aws_account_id
  aws_region                      = local.aws_region
  queue_name                      = "myQueue"
  alarm_enabled                   = true
  alarm_topic_arn                 = "arn:aws:sns:eu-central-1:${local.aws_account_id}:alarm"
  alarm_minutes                   = 5
  alarm_evaluation_periods        = 3
  alarm_period                    = 60
  principals_with_send_permission = ["arn:aws:iam::${local.foreign_aws_account_id}:root"]
}
