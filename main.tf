locals {
  alarm_description = <<EOF
  SQS Queue Metrics: https://${var.aws_region}.console.aws.amazon.com/sqs/v2/home?region=${var.aws_region}#/queues/https%3A%2F%2Fsqs.${var.aws_region}.amazonaws.com%2F${var.aws_account_id}%2F${local.queue_name}
EOF
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

resource "aws_cloudwatch_metric_alarm" "backlog" {
  count = module.this.enabled && var.alarm_create ? 1 : 0

  alarm_description   = local.alarm_description
  alarm_name          = "${module.alarm_label.id}-${var.queue_name}-backlog"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = var.alarm_datapoints_to_alarm
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = var.alarm_threshold
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "visible"
    return_data = false

    metric {
      dimensions = {
        QueueName = local.queue_name
      }
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = var.alarm_period
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "incoming"
    return_data = false

    metric {
      dimensions = {
        QueueName = local.queue_name
      }
      metric_name = "NumberOfMessagesSent"
      namespace   = "AWS/SQS"
      period      = var.alarm_period
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "delayed"
    return_data = false

    metric {
      dimensions = {
        QueueName = local.queue_name
      }
      metric_name = "ApproximateNumberOfMessagesDelayed"
      namespace   = "AWS/SQS"
      period      = var.alarm_period
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "deleted"
    return_data = false

    metric {
      dimensions = {
        QueueName = local.queue_name
      }
      metric_name = "NumberOfMessagesDeleted"
      namespace   = "AWS/SQS"
      period      = var.alarm_period
      stat        = "Sum"
    }
  }

  metric_query {
    expression  = "visible - delayed + incoming - (deleted * ${var.alarm_minutes})"
    id          = "backlog"
    label       = "visible - delayed + incoming - (deleted * ${var.alarm_minutes})"
    return_data = true
  }

  alarm_actions = var.alarm_topic_arn != null ? [var.alarm_topic_arn] : []
  ok_actions    = var.alarm_topic_arn != null ? [var.alarm_topic_arn] : []

  tags = module.this.tags
}
