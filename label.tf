module "alarm_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  label_order = ["stage", "name", "attributes"]
  context     = module.this.context
}
