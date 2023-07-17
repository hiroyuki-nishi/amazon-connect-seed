resource "aws_kinesis_stream" "kinesis_stream_for_amazon_connect" {
  name             = "${var.prefix}-${var.project_name}-${var.env}-kinesis-stream-for-amazon-connect"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
  ]

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-kinesis-stream-for-amazon-connect"
  }
}