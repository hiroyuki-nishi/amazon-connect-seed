#########################
## bastion
#########################
data "aws_iam_policy_document" "assume_bastion" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.prefix}-${var.project_name}-${var.env}-BastionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_bastion.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-BastionRole"
  }
}

data "aws_iam_policy_document" "ssm_manged_instance_core" {
  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "systems_manager" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-systems-manager-policy"
  policy = data.aws_iam_policy_document.ssm_manged_instance_core.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-systems-manager-policy"
  }
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.systems_manager.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.prefix}-${var.project_name}-${var.env}-bastion"
  role = aws_iam_role.bastion.name

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-bastion"
  }
}


#########################
## xxx-lambda-trigger
#########################
data "aws_iam_policy_document" "basic_lambda_assume_policy_document" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "xxx_lambda_trigger" {
  assume_role_policy = data.aws_iam_policy_document.basic_lambda_assume_policy_document.json
  name               = "${var.prefix}-${var.project_name}-${var.env}-TFXXXLambdaRriggerLambdaRole"

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-TFXXXLambdaRriggerLambdaRole"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_lambda_trigger_for_vpc" {
  role       = aws_iam_role.xxx_lambda_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xxx_lambda_trigger_for_s3" {
  role       = aws_iam_role.xxx_lambda_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "xxx_lambda_trigger_for_secret_manager" {
  role       = aws_iam_role.xxx_lambda_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy_document" "xxx_lambda_trigger_for_log_group" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.xxx_lambda_trigger.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "xxx_lambda_trigger_put_log_group" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger-put-log-group"
  policy = data.aws_iam_policy_document.xxx_lambda_trigger_for_log_group.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-lambda-trigger-put-log-group"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_lambda_trigger_put_log_group" {
  role       = aws_iam_role.xxx_lambda_trigger.name
  policy_arn = aws_iam_policy.xxx_lambda_trigger_put_log_group.arn
}


#########################
## xxx-schedule-trigger
#########################
data "aws_iam_policy_document" "xxx_schedule_trigger_put_log_group" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.xxx_schedule_trigger.arn}:*"
    ]
  }
}

resource "aws_iam_role" "xxx_schedule_trigger" {
  assume_role_policy = data.aws_iam_policy_document.basic_lambda_assume_policy_document.json
  name               = "${var.prefix}-${var.project_name}-${var.env}-TFXXXScheduleTriggerRole"

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-TFXXXScheduleTriggerRole"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_schedule_trigger_for_vpc" {
  role       = aws_iam_role.xxx_schedule_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xxx_schedule_trigger_for_s3" {
  role       = aws_iam_role.xxx_schedule_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonConnect_FullAccess"
}

resource "aws_iam_role_policy_attachment" "xxx_schedule_trigger_for_secret_manager" {
  role       = aws_iam_role.xxx_schedule_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


resource "aws_iam_policy" "xxx_schedule_trigger_put_log_group_policy" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger-put-log-group-policy"
  policy = data.aws_iam_policy_document.xxx_schedule_trigger_put_log_group.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-schedule-trigger-put-log-group-policy"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_schedule_trigger_put_log_group" {
  role       = aws_iam_role.xxx_schedule_trigger.name
  policy_arn = aws_iam_policy.xxx_schedule_trigger_put_log_group_policy.arn
}

resource "aws_iam_role" "call_cases_for_event_bridge_scheduler" {
  name               = "${var.prefix}-${var.project_name}-${var.env}-xxx_for_firehose-for-eventbridge-scheduler"
  assume_role_policy = data.aws_iam_policy_document.call_cases_event_bridge_scheduler_assume.json
}

data "aws_iam_policy_document" "call_cases_event_bridge_scheduler_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "xxx_schedule_trigger_event_bridge_scheduler" {
  name   = "${var.prefix}${var.project_name}-${var.env}-xxx-schedule-trigger-event-bridge-scheduler"
  role   = aws_iam_role.call_cases_for_event_bridge_scheduler.name
  policy = data.aws_iam_policy_document.call_cases_event_bridge_scheduler_for_lambda.json
}

data "aws_iam_policy_document" "call_cases_event_bridge_scheduler_for_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      "*",
    ]
  }
}


#########################
## xxx-for-firehose
#########################
resource "aws_iam_role" "xxx_for_firehose" {
  assume_role_policy = data.aws_iam_policy_document.basic_lambda_assume_policy_document.json
  name               = "${var.prefix}-${var.project_name}-${var.env}-TFXxxForFirehoseLambdaRole"

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-TFXxxForFirehoseLambdaRole"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_for_firehose_for_vpc" {
  role       = aws_iam_role.xxx_for_firehose.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xxx_for_firehose_for_secret_manager" {
  role       = aws_iam_role.xxx_for_firehose.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy_document" "xxx_for_firehose_put_log_group_policy_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.xxx_for_firehose.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "xxx_for_firehose_put_log_group_policy" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose-put-log-group-policy"
  policy = data.aws_iam_policy_document.xxx_for_firehose_put_log_group_policy_document.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose-put-log-group-policy"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_for_firehose_put_log_group" {
  role       = aws_iam_role.xxx_for_firehose.name
  policy_arn = aws_iam_policy.xxx_for_firehose_put_log_group_policy.arn
}

resource "aws_iam_policy" "xxx_for_firehose_allow_kinesis" {
  name = "${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose-allow-kinesis"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kinesis:ListShards",
        "kinesis:ListStreams",
        "kinesis:*"
      ],
      "Resource": "arn:aws:kinesis:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "stream:GetRecord",
        "stream:GetShardIterator",
        "stream:DescribeStream",
        "stream:*"
      ],
      "Resource": "arn:aws:stream:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-xxx-for-firehose-allow-kinesis"
  }
}

resource "aws_iam_role_policy_attachment" "xxx_for_firehose_for_kinesis" {
  role       = aws_iam_role.xxx_for_firehose.name
  policy_arn = aws_iam_policy.xxx_for_firehose_allow_kinesis.arn
}


#########################
## RDS
#########################
data "aws_iam_policy_document" "rds_proxy_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "proxy_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager:*:*:*",
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "proxy" {
  name               = "${var.prefix}-${var.project_name}-${var.env}-ProxyRole"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-ProxyRole"
  }
}

data "aws_iam_policy_document" "rds_monitoring_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "proxy" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-proxy"
  role   = aws_iam_role.proxy.id
  policy = data.aws_iam_policy_document.proxy_policy_document.json
}

resource "aws_iam_role" "rds_monitoring" {
  name               = "${var.prefix}-${var.project_name}-${var.env}-rds-monitoring"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_policy.json

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-rds-monitoring"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
