resource "aws_security_group" "db_sg" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_name}-db-sg"
  description = "RDS Security Group for ${var.project_name}"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_ipv4" {
  count             = var.enable_rds ? 1 : 0
  security_group_id = aws_security_group.db_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "random_password" "db_password" {
  count            = var.enable_rds ? 1 : 0
  length           = 20
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "aws_secretsmanager_secret" "rds-secret" {
  count = var.enable_rds ? 1 : 0
  name  = "${var.project_name}-secret"
}

resource "aws_secretsmanager_secret_version" "rds-secret-version" {
  count     = var.enable_rds ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds-secret[0].id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password[0].result
  })
}

module "db" {
  count   = var.enable_rds ? 1 : 0
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "${var.project_name}-demo-mysql"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.rds_instance_type
  allocated_storage = 5

  db_name             = "demomysql"
  username            = "admin"
  password_wo         = random_password.db_password[0].result
  password_wo_version = 1
  port                = "3306"

  manage_master_user_password = false

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db_sg[0].id]

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = [for id in data.aws_subnets.default.ids : id]

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # parameters = [
  #   {
  #     name  = "character_set_client"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name  = "character_set_server"
  #     value = "utf8mb4"
  #   }
  # ]

  # options = [
  #   {
  #     option_name = "MARIADB_AUDIT_PLUGIN"

  #     option_settings = [
  #       {
  #         name  = "SERVER_AUDIT_EVENTS"
  #         value = "CONNECT"
  #       },
  #       {
  #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #         value = "37"
  #       },
  #     ]
  #   },
  # ]
}
