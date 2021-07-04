###################################################
// ------------ ALB SECURITY GROUP ------------- //
###################################################


resource "aws_security_group" "alb" {
  name        = "dagster-sg-alb-${var.infra_env}"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for application load balancer."

  ingress {
    description      = "Allow HTTP for access to UI."
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = var.ingress_cidr_block
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow HTTPS needed to download the docker image from ECR."
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = var.ingress_cidr_block
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH into server."
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    cidr_blocks      = var.ingress_cidr_block
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

########################################################
// ------------ ECS TASK SECURITY GROUP ------------- //
########################################################


resource "aws_security_group" "ecs_tasks" {
  name        = "dagster-sg-task-${var.infra_env}"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for ecs task definition running dagit."

  ingress {
    protocol         = "tcp"
    from_port        = var.dagit_container_port
    to_port          = var.dagit_container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = [aws_security_group.alb.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


#########################################################
// ------------ POSTGRES SECUIRTY GROUP -------------- //
#########################################################

resource "aws_security_group" "rds" {
  name        = "dagster-sg-postgres-${var.infra_env}"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for RDS containing run logs for dagster."

  ingress {
    description     = "Allow external connection to db."
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_tasks.id] // Dagster can talk to db.
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}