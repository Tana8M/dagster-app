resource "aws_db_subnet_group" "db_subnet_group" {
  // Use the same public subnet in default vpc and another subnet in another availability zone
  subnet_ids = var.subnet_public_ids
}