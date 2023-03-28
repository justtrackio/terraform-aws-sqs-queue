locals {
  redrive_policy = jsonencode({
    deadLetterTargetArn = var.dead_letter_queue_arn
    maxReceiveCount     = var.max_receive_count
  })
  queue_name = "${module.this.id}-${var.queue_name}"
}

data "aws_iam_policy_document" "sqs_policy" {
  count = module.this.enabled && var.principals_with_send_permission != null ? 1 : 0
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    principals {
      identifiers = var.principals_with_send_permission
      type        = "AWS"
    }
    resources = [try(aws_sqs_queue.kms_encrypted_queue[0].arn, aws_sqs_queue.queue[0].arn)]
    dynamic "condition" {
      for_each = length(var.source_arns) > 0 ? [1] : []
      content {
        test     = "ArnEquals"
        values   = var.source_arns
        variable = "aws:SourceArn"
      }
    }
  }
}

resource "aws_sqs_queue_policy" "policy" {
  count     = module.this.enabled && var.principals_with_send_permission != null ? 1 : 0
  policy    = data.aws_iam_policy_document.sqs_policy[0].json
  queue_url = try(aws_sqs_queue.kms_encrypted_queue[0].url, aws_sqs_queue.queue[0].url)
}

resource "aws_sqs_queue" "kms_encrypted_queue" {
  count = module.this.enabled && var.kms_master_key_id != null ? 1 : 0
  name  = local.queue_name

  fifo_queue                        = var.fifo_queue
  delay_seconds                     = var.delay_seconds
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  redrive_policy                    = var.max_receive_count != null ? local.redrive_policy : null
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  tags = module.this.tags
}

resource "aws_sqs_queue" "queue" {
  count = module.this.enabled && var.kms_master_key_id == null ? 1 : 0
  name  = local.queue_name

  fifo_queue                 = var.fifo_queue
  delay_seconds              = var.delay_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  redrive_policy             = var.max_receive_count != null ? local.redrive_policy : null
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled

  tags = module.this.tags
}
