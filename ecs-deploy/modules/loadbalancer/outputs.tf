output "lb_target_group_arn" {
  description = "load balancer target group arn."
  value       = aws_lb_target_group.tg.arn
}

output "lb_dns" {
  description = "dns name of dagit ui."
  value       = aws_lb.lb.dns_name
}

output "alb_arn" {
  description = "application load balancer arn"
  value       = aws_lb.lb.arn
}