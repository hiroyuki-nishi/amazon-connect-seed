data "aws_ssm_parameter" "db_master_password" {
  name = "/${var.prefix}/${var.project_name}/db/password"
}