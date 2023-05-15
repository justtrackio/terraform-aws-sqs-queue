output "queue_arn" {
  description = "SQS queue arn"
  value       = try(aws_sqs_queue.queue[0].arn, aws_sqs_queue.kms_encrypted_queue[0].arn, "")
}

output "queue_id" {
  description = "SQS queue id"
  value       = try(aws_sqs_queue.queue[0].id, aws_sqs_queue.kms_encrypted_queue[0].id, "")
}

output "queue_name" {
  description = "SQS queue name"
  value       = try(aws_sqs_queue.queue[0].name, aws_sqs_queue.kms_encrypted_queue[0].name, "")
}
