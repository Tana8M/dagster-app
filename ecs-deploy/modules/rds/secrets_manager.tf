// Access secret credentials for postgres db

// Generating password
resource "random_password" "pg_pw" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "pg_pw_secret" {
  name_prefix = "data_pg"
  tags = {
    Name        = "data-${var.infra_env}"
    Role        = "${var.infra_role}"
    Environment = "${var.infra_env}"
  }
}

resource "aws_secretsmanager_secret_version" "pg_pw_secret_v" {
  secret_id = aws_secretsmanager_secret.pg_pw_secret.id
  // Pass in the newly generated password
  secret_string = random_password.pg_pw.result
}