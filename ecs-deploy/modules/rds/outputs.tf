############################################
// ------------ RDS OUTPUTS ------------- //
############################################

output "rds_password" {
  description = "password of the rds instance."
  value       = local.secret
  // maybe add sensitive here.
}

output "rds_hostname" {
  description = "hostname of the rds instance."
  value       = aws_db_instance.pg.address
}