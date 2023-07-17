resource "aws_secretsmanager_secret" "rds_proxy_secretsmanager_secret" {
  name                    = "${var.prefix}-${var.project_name}-${var.env}-rds-proxy-secretsmanager-secret"
  recovery_window_in_days = 0

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-rds-proxy-secretsmanager-secret"
  }
}

resource "aws_secretsmanager_secret_version" "prefix_xxx" {
  secret_id = aws_secretsmanager_secret.rds_proxy_secretsmanager_secret.id

  secret_string = jsonencode({
    username : aws_rds_cluster.prefix_xxx.master_username
    password : aws_rds_cluster.prefix_xxx.master_password
    engine : aws_rds_cluster.prefix_xxx.engine
    host : aws_rds_cluster.prefix_xxx.endpoint
    port : aws_rds_cluster.prefix_xxx.port
    dbInstanceIdentifier : aws_rds_cluster.prefix_xxx.id
  })
}

