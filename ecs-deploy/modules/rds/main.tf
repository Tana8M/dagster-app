###################################################
// ------------ RDS CONFIGURATIONS ------------- //
###################################################
locals {
  // Read secret to assign pw in RDS
  secret = aws_secretsmanager_secret_version.pg_pw_secret_v.secret_string
}


resource "aws_db_instance" "pg" {
  allocated_storage         = var.rds_allocated_storage
  max_allocated_storage     = var.rds_max_allocated_storage
  engine                    = "postgres"
  engine_version            = var.rds_engine_version
  backup_retention_period   = 3
  multi_az                  = false
  backup_window             = "01:00-02:00"
  maintenance_window        = "sun:03:00-sun:03:30"
  instance_class            = var.rds_instance_type
  port                      = "5432"
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids    = [var.sg_rds]
  skip_final_snapshot       = var.skip_final_snapshot // Change this to true in prod
  final_snapshot_identifier = "data-logs-final"
  publicly_accessible       = true
  name                      = var.rds_db_name
  username                  = var.rds_username
  password                  = local.secret

  tags = {
    Name        = "data"
    Role        = "data-pg"
    Environment = "${var.infra_env}"
    ManagedBy   = "terraform"
  }
}