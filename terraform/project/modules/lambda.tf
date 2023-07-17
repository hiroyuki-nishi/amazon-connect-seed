#########################
## xxx-lambda-trigger
#########################
data "aws_caller_identity" "current" {}

data "archive_file" "xxx_lambda_trigger" {
  type        = "zip"
  source_file = "../../dist/xxx-lambda-trigger/index.js"
  output_path = "dist/xxx-lambda-trigger.zip"
}

resource "aws_lambda_function" "xxx_lambda_trigger" {
  function_name    = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger"
  filename         = data.archive_file.xxx_lambda_trigger.output_path
  handler          = "index.handler"
  role             = aws_iam_role.xxx_lambda_trigger.arn
  source_code_hash = data.archive_file.xxx_lambda_trigger.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = "180"
  memory_size      = "1024"

  vpc_config {
    security_group_ids = [aws_security_group.lambdas_security_group.id]
    subnet_ids         = var.vpc_private_subnet_ids
  }

  environment {
    variables = {
      env          = var.env
      region       = var.aws_region
      secretId     = aws_secretsmanager_secret.rds_proxy_secretsmanager_secret.name
      host         = aws_db_proxy.db_proxy.endpoint
      databaseName = var.database_name
    }
  }

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger"
  }
}

resource "aws_cloudwatch_log_group" "xxx_lambda_trigger" {
  name              = "/aws/lambda/${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger"
  retention_in_days = 14

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger"
  }
}

resource "aws_lambda_permission" "xxx_lambda_trigger_for_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xxx_lambda_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.xxx_lambda_trigger.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_lambda_permission" "xxx_lambda_trigger_for_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xxx_lambda_trigger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.xxx_lambda_trigger_for_s3.arn
}


#########################
## xxx-schedule-trigger
#########################
data "archive_file" "xxx_schedule_trigger" {
  type        = "zip"
  source_file = "../../dist/xxx-schedule-trigger/index.js"
  output_path = "dist/xxx-schedule-trigger.zip"
}

resource "aws_lambda_function" "xxx_schedule_trigger" {
  function_name                  = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger"
  filename                       = data.archive_file.xxx_schedule_trigger.output_path
  handler                        = "index.handler"
  role                           = aws_iam_role.xxx_schedule_trigger.arn
  source_code_hash               = data.archive_file.xxx_schedule_trigger.output_base64sha256
  runtime                        = "nodejs16.x"
  reserved_concurrent_executions = 1
  timeout                        = "180"

  vpc_config {
    security_group_ids = [aws_security_group.lambdas_security_group.id]
    subnet_ids         = var.vpc_private_subnet_ids
  }

  environment {
    variables = {
      env          = var.env
      region       = var.aws_region
      secretId     = aws_secretsmanager_secret.rds_proxy_secretsmanager_secret.name
      host         = aws_db_proxy.db_proxy.endpoint
      databaseName = var.database_name
      instanceId = lookup(
        var.instance_id,
        var.env,
        var.instance_id["default"],
      )
    }
  }

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger"
  }
}

resource "aws_lambda_permission" "call_cases" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xxx_schedule_trigger.function_name
  principal     = "scheduler.amazonaws.com"
}


resource "aws_cloudwatch_log_group" "xxx_schedule_trigger" {
  name              = "/aws/lambda/${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger"
  retention_in_days = 14

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger"
  }
}


#########################
## xxx-for-firehose
#########################
data "archive_file" "xxx_for_firehose" {
  type        = "zip"
  source_file = "../../dist/xxx-for-firehose/index.js"
  output_path = "dist/xxx-for-firehose.zip"
}

resource "aws_lambda_function" "xxx_for_firehose" {
  function_name    = "${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose"
  filename         = data.archive_file.xxx_for_firehose.output_path
  handler          = "index.handler"
  role             = aws_iam_role.xxx_for_firehose.arn
  source_code_hash = data.archive_file.xxx_for_firehose.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = "180"
  memory_size      = "1024"

  vpc_config {
    security_group_ids = [aws_security_group.lambdas_security_group.id]
    subnet_ids         = var.vpc_private_subnet_ids
  }

  environment {
    variables = {
      env          = var.env
      region       = var.aws_region
      secretId     = aws_secretsmanager_secret.rds_proxy_secretsmanager_secret.name
      host         = aws_db_proxy.db_proxy.endpoint
      databaseName = var.database_name
    }
  }
}

resource "aws_cloudwatch_log_group" "xxx_for_firehose" {
  name              = "/aws/lambda/${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose"
  retention_in_days = 14

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose"
  }
}

resource "aws_lambda_function_event_invoke_config" "xxx_for_firehose" {
  function_name                = aws_lambda_function.xxx_for_firehose.function_name
  maximum_event_age_in_seconds = 180
  maximum_retry_attempts       = 2
}

resource "aws_lambda_event_source_mapping" "xxx_for_firehose_for_kinesis" {
  event_source_arn  = aws_kinesis_stream.kinesis_stream_for_amazon_connect.arn
  function_name     = aws_lambda_function.xxx_for_firehose.arn
  starting_position = "LATEST"

  depends_on = [
    aws_iam_role_policy_attachment.xxx_for_firehose_for_kinesis
  ]
}