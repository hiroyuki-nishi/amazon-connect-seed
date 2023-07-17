locals {
  db_master_username = "${var.env}_master_user"
  db_master_password = data.aws_ssm_parameter.db_master_password.value
  cluster_instances = lookup(
    var.workspace_cluster_instances,
    var.env,
    var.workspace_cluster_instances["default"],
  )
}

resource "aws_rds_cluster_parameter_group" "prefix_xxx" {
  name        = "${var.prefix}-${var.project_name}-${var.env}-rds-cluster-pg"
  family      = "aurora-postgresql13"
  description = "RDS default cluster parameter group"

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-rds-cluster-pg"
  }
}

resource "aws_db_parameter_group" "prefix_xxx" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-db-parameter-group"
  family = "aurora-postgresql13"

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-db-parameter-group"
  }
}

/*
  * Aurora Cluster
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
*/
resource "aws_rds_cluster" "prefix_xxx" {
  allow_major_version_upgrade     = true
  apply_immediately               = true
  backup_retention_period         = 7
  cluster_identifier              = "${var.prefix}-${var.project_name}-${var.env}-aurora-postgresql-cluster"
  database_name                   = var.database_name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.prefix_xxx.name
  deletion_protection             = false
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = "13.8"
  master_username                 = local.db_master_username
  master_password                 = local.db_master_password
  port                            = 5432
  preferred_backup_window         = "17:00-18:00"
  preferred_maintenance_window    = "sat:18:00-sat:19:00"
  skip_final_snapshot             = true
  storage_encrypted               = true

  db_subnet_group_name = aws_db_subnet_group.prefix_xxx.name
  vpc_security_group_ids = [
    aws_security_group.rds_cluster.id,
  ]

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-aurora-postgresql-cluster"
  }
}

resource "aws_rds_cluster_instance" "prefix_xxx" {
  count                   = local.cluster_instances
  cluster_identifier      = aws_rds_cluster.prefix_xxx.id
  db_parameter_group_name = aws_db_parameter_group.prefix_xxx.name
  engine                  = "aurora-postgresql"
  engine_version          = "13.8"
  identifier_prefix       = "${var.prefix}-${var.project_name}-${var.env}-"
  instance_class          = "db.t4g.medium"
  monitoring_role_arn     = aws_iam_role.rds_monitoring.arn
  monitoring_interval     = 60

  depends_on = [
    aws_rds_cluster.prefix_xxx
  ]

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-rds-cluster-instance"
  }
}

resource "aws_db_subnet_group" "prefix_xxx" {
  name = "${var.prefix}-${var.project_name}-${var.env}-db-subnet-group"
  subnet_ids = var.vpc_private_subnet_ids

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-db-subnet-group"
  }
}


#########################
## RDS Proxy
#########################
# RDS Proxy
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy
resource "aws_db_proxy" "db_proxy" {
  name                   = "${var.prefix}-${var.project_name}-${var.env}-db-proxy"
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = false
  role_arn               = aws_iam_role.proxy.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]
  vpc_subnet_ids = var.vpc_private_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.rds_proxy_secretsmanager_secret.arn
  }

  depends_on = [
    aws_rds_cluster.prefix_xxx,
    aws_secretsmanager_secret_version.prefix_xxx
  ]

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-db-proxy"
  }
}

resource "aws_db_proxy_default_target_group" "default" {
  db_proxy_name = aws_db_proxy.db_proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "prefix_xxx" {
  db_proxy_name         = aws_db_proxy.db_proxy.name
  db_cluster_identifier = aws_rds_cluster.prefix_xxx.id
  target_group_name     = aws_db_proxy_default_target_group.default.name
}