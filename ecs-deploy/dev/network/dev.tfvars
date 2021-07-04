# ENVIRONMENT
infra_env = "staging"
# NETWORK
vpc_cidr_block     = "192.168.0.0/24"
private_subnets    = ["192.168.0.0/26", "192.168.0.64/26"]
public_subnets     = ["192.168.0.128/26", "192.168.0.192/26"]
availability_zones = ["eu-west-1a", "eu-west-1b"]
ingress_cidr_block = ["0.0.0.0/0"]