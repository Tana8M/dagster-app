###########################################
// ------------ VPC OUTPUTS ------------- //
###########################################

output "vpc_id" {
  description = "VPC id."
  value       = aws_vpc.vpc.id
}

// Public subnet ids
output "subnet_public_ids" {
  description = "List of public subnet ids"
  value       = aws_subnet.public.*.id
}

// Private subnet ids
output "subnet_private_ids" {
  description = "List of private subnet ids"
  value       = aws_subnet.private.*.id
}

// Security groups
output "sg_alb" {
  description = "ALB security group id"
  value       = aws_security_group.alb.id
}

output "sg_ecs_tasks" {
  description = "ECS tasks security group id"
  value       = aws_security_group.ecs_tasks.id
}

output "sg_rds" {
  description = "RDS security group id"
  value       = aws_security_group.rds.id
}
