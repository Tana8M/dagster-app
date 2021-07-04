#####################################################
// ----------- EC2 LAUNCH TEMPLATE --------------- //
#####################################################

data "template_file" "template" {
  // Block permissions from the ec2 instance trickling into the awsvpc task container permissions
  template = <<EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_dagster_cluster} >> /etc/ecs/ecs.config
              echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
              echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
              EOF
}

// Select latest optimized ecs ami 
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_launch_template" "launch_template" {
  name          = "${var.infra_role}-launchtemple-${var.infra_env}"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.launch_template_instance_type
  description   = "Launch template for ec2 server running dagster."
  user_data     = base64encode(data.template_file.template.rendered)
  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile.arn
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_ecs_tasks]
    subnet_id                   = element(var.subnet_private_ids, 0)
    description                 = "Public IP address for server instance."
    delete_on_termination       = true
  }
  tags = {
    Name        = "data-${var.infra_env}-${var.infra_role}"
    Role        = var.infra_role
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}


###################################################
// ----------- AUTOSCALING GROUP --------------- //
###################################################

resource "aws_autoscaling_group" "dagster_asg" {
  name                = "${var.infra_role}-asg-${var.infra_env}"
  vpc_zone_identifier = var.subnet_private_ids

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
  force_delete              = true
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  default_cooldown          = 60

  // This prevents all instances running tasks from being terminated during scale-in
  protect_from_scale_in = var.protect_from_scale_in

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}
