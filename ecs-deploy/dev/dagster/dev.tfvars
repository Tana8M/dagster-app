# TAGS
infra_env  = "staging"
infra_role = "dagster"
# CLUSTER
ecs_dagster_cluster  = "dagster_ecs"
key_name             = "dagster-key-dev"
dagit_container_port = "3000"
# CLOUDWATCH LOGS
aws_cloudwatch_log_group = "awslogs-dagster"
# AUTOSCALING GROUP
launch_template_instance_type  = "t2.micro"
protect_from_scale_in          = false
managed_termination_protection = "DISABLED"
target_capacity                = 100
# POSTGRES 
rds_instance_type         = "db.t3.micro"
rds_allocated_storage     = 10
rds_max_allocated_storage = 30
rds_engine_version        = "13.1"
rds_db_name               = "dagsterdb"
rds_username              = "user"
skip_final_snapshot       = true