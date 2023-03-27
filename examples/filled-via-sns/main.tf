module "example" {
  source = "../.."

  tenant      = "tenant"
  namespace   = "namespace"
  environment = "environment"
  stage       = "stage"
  name        = "tracing"
  attributes  = ["foo"]

  queue_name                      = "myQueue"
  alarm_create                    = true
  alarm_topic_arn                 = "arn:aws:sns:eu-central-1:123456789123:alarm"
  alarm_minutes                   = 5
  alarm_evaluation_periods        = 3
  alarm_period                    = 60
  principals_with_send_permission = ["*"]
  source_arns                     = ["arn:aws:sns:eu-central-1:123456789123:myTopic"]
}
