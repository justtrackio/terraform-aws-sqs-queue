variable "alarm_create" {
  type        = bool
  default     = false
  description = "Defines if alarm should be created"
}

variable "alarm_datapoints_to_alarm" {
  type        = number
  description = "The number of datapoints that must be breaching to trigger the alarm."
  default     = null
}

variable "alarm_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
  default     = null
}

variable "alarm_minutes" {
  type        = number
  description = "The backlog minutes"
  default     = null
}

variable "alarm_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied."
  default     = null
}

variable "alarm_threshold" {
  type        = number
  description = "The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models."
  default     = null
}

variable "alarm_topic_arn" {
  type        = string
  description = "ARN of the SNS Topic used for notifying about alarm/ok messages."
  default     = null
}

variable "dead_letter_queue_arn" {
  type        = string
  description = "The dead letter queue arn"
  default     = null
}

variable "delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds."
  default     = null
}

variable "fifo_queue" {
  type        = bool
  description = "Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  default     = null
}

variable "kms_master_key_id" {
  type        = string
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK. For more information, see Key Terms."
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes)."
  default     = null
}

variable "max_receive_count" {
  type        = number
  description = "For the JSON policy to set up the Dead Letter Queue"
  default     = null
}

variable "message_retention_seconds" {
  type        = number
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)."
  default     = null
}

variable "principals_with_send_permission" {
  type        = list(string)
  description = "The principal arns that are allowed to use sqs:SendMessage"
  default     = null
}

variable "queue_name" {
  type        = string
  description = "The name of the queue. Queue names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 80 characters long. For a FIFO (first-in-first-out) queue, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix"
  default     = null
}

variable "sqs_managed_sse_enabled" {
  type        = bool
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys. See Encryption at rest. Terraform will only perform drift detection of its value when present in a configuration."
  default     = true
}

variable "visibility_timeout_seconds" {
  type        = string
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30."
  default     = null
}
