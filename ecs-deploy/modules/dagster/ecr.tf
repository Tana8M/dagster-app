#############################################
// ------------ ECR REGISTRY------------- //
############################################

data "aws_ecr_repository" "daemon_dagit" {
  name = "dagster/daemon-dagit"
}

data "aws_ecr_repository" "etl" {
  name = "dagster/etl"
}
