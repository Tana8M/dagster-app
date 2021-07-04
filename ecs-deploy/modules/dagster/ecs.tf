################################################
//-------------- ECS CLUSTER ----------------//
################################################

resource "aws_ecs_cluster" "dagster" {
  // Name must be the same given under ecs_dagster_launch_config.user_data
  name               = var.ecs_dagster_cluster
  capacity_providers = [aws_ecs_capacity_provider.dagster_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.dagster_cp.name
    base              = 1
    weight            = 1
  }
}

####################################################
// ------- Autoscaling capacity provider -------- //
####################################################

locals {
  env = "staging"
}

resource "aws_ecs_capacity_provider" "dagster_cp" {
  name = "${var.infra_role}-cp-${local.env}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.dagster_asg.arn
    managed_termination_protection = var.managed_termination_protection

    managed_scaling {
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
      instance_warmup_period    = 200
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }
}


####################################################
// ------------ ECS TASK DEFINITION ------------- //
####################################################

data "template_file" "task_definition" {
  template = file("${path.module}/task-definition.json")
  vars = {
    "dagit-image"          = "${data.aws_ecr_repository.daemon_dagit.repository_url}:latest"
    "daemon-image"         = "${data.aws_ecr_repository.daemon_dagit.repository_url}:latest"
    "etl-image"            = "${data.aws_ecr_repository.etl.repository_url}:latest"
    "rds-hostname"         = "${var.aws_db_hostname}"
    "rds-password"         = "${var.aws_db_password}"
    "cloudwatch-log-group" = "${var.aws_cloudwatch_log_group}"
  }
}


resource "aws_ecs_task_definition" "dagster_task" {
  family                = "${var.infra_role}-ecs-task"
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.task_execution.arn
  cpu = var.cpu
  memory = var.memory
  network_mode          = "awsvpc"
  container_definitions = data.template_file.task_definition.rendered
  volume {
    name      = "docker_sock"
    host_path = "//var/run/docker.sock"
  }
}

##############################################
// ------------ ECS SERVICES ------------- //
##############################################

resource "aws_ecs_service" "dagster" {
  name            = "${var.infra_role}-ecs-service"
  cluster         = aws_ecs_cluster.dagster.id
  task_definition = aws_ecs_task_definition.dagster_task.arn
  desired_count   = 1
  network_configuration {
    // Must be on private 
    subnets         = var.subnet_private_ids
    security_groups = [var.sg_ecs_tasks]
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "dagit"
    container_port   = var.dagit_container_port
  }
  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  # Ignore task definition when updating infra through tf, to not disturb cicd
  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
