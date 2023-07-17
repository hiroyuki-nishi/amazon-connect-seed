#########################
## xxx-lambda-trigger
#########################
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule
resource "aws_cloudwatch_event_rule" "xxx_lambda_trigger_for_s3" {
  name          = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger-for-s3"
  event_pattern = <<EOF
{
  "detail-type": [
    "Object Created"
  ],
  "source": [
    "aws.s3"
  ],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.xxx_lambda_trigger.id}"]
    }
  }
}
EOF

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger-for-s3"
  }
}

resource "aws_cloudwatch_event_target" "xxx_lambda_trigger" {
  rule = aws_cloudwatch_event_rule.xxx_lambda_trigger_for_s3.name
  arn  = aws_lambda_function.xxx_lambda_trigger.arn
}


#########################
## xxx-schedule-trigger
#########################
resource "aws_scheduler_schedule_group" "xxx_schedule_trigger" {
  name = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger"
}

resource "aws_scheduler_schedule" "xxx_schedule_trigger" {
  name                         = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger"
  group_name                   = aws_scheduler_schedule_group.xxx_schedule_trigger.name
  state                        = "ENABLED"
  schedule_expression          = "cron(0/1 9-17 ? * * *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.xxx_schedule_trigger.arn
    role_arn = aws_iam_role.xxx_schedule_for_event_bridge_scheduler.arn
  }
}



