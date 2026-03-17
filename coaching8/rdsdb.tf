resource "aws_security_group" "db_sg" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_name}-db-sg"
  description = "RDS Security Group for ${var.project_name}"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_ipv4" {
  count             = var.enable_rds ? 1 : 0
  security_group_id = aws_security_group.db_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_db_instance" "default" {
  count                       = var.enable_rds ? 1 : 0
  allocated_storage           = 5
  identifier                  = "${var.project_name}-rds-mysqldb"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = var.rds_instance_type
  manage_master_user_password = true
  username                    = "admin"
  port                        = 3306
  db_subnet_group_name        = module.vpc.database_subnet_group_name
  vpc_security_group_ids      = [aws_security_group.db_sg[count.index].id]
  skip_final_snapshot         = true
}
