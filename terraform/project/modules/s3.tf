resource "aws_s3_bucket" "xxx_lambda_trigger" {
  bucket        = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger"
  force_destroy = true

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger"
  }
}

resource "aws_s3_bucket_notification" "xxx_lambda_trigger" {
  bucket      = aws_s3_bucket.xxx_lambda_trigger.id
  eventbridge = true
}