#########################
## Bastion
#########################
resource "aws_security_group" "bastion" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-bastion"
  vpc_id = var.vpc_id

  ingress {
    description = "allow ssh connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["121.86.25.100/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name      = "${var.prefix}-${var.project_name}-${var.env}-bastion"
  }
}

#########################
## Lambda
#########################
resource "aws_security_group" "lambdas_security_group" {
  name   = "${var.prefix}-${var.project_name}-${var.env}-lambdas-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name      = "${var.prefix}-${var.project_name}-${var.env}-lambdas-security-group"
  }
}


#########################
## RDS
#########################
resource "aws_security_group" "rds_cluster" {
  name_prefix = "${var.prefix}-${var.project_name}-${var.env}-for-rds-cluster-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-for-rds-cluster-sg"
  }
}

resource "aws_security_group" "rds_proxy" {
  name_prefix = "${var.prefix}-${var.project_name}-${var.env}-for-rds-proxy"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.prefix}-${var.project_name}-${var.env}-for-rds-proxy"
  }
}

resource "aws_security_group_rule" "rds_from_rds_proxy" {
  security_group_id        = aws_security_group.rds_cluster.id
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_proxy.id
  depends_on               = [aws_security_group.rds_proxy]
}

resource "aws_security_group_rule" "rds_cluster_from_bastion_server" {
  security_group_id        = aws_security_group.rds_cluster.id
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "rds_proxy_from_bastion_server" {
  security_group_id        = aws_security_group.rds_proxy.id
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "rds_proxy_from_lambdas" {
  security_group_id        = aws_security_group.rds_proxy.id
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambdas_security_group.id
}


