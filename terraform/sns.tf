resource "aws_sns_topic" "disk_monitor" {
  name                                     = "disk-monitor"
  display_name                             = "Disk Monitor Test"
  sqs_success_feedback_sample_rate         = 0
  application_success_feedback_sample_rate = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  policy = jsonencode(
    {
      Id = "__default_policy_ID"
      Statement = [
        {
          Sid    = "Role"
          Effect = "Allow"
          Action = "sns:Publish"
          Principal = {
            AWS = "*"
          }
          Resource = "*"
        }
      ]
      Version = "2008-10-17"
    }
  )
}