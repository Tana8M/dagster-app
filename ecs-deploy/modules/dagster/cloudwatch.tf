################################################
// ------------ CLOUDWATCH LOGS ------------- //
################################################

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.aws_cloudwatch_log_group
  retention_in_days = 90 // Increase if needed
}
