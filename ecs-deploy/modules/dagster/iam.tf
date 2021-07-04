#######################################
// ---------- ECS ASSUME ROLE ------ //
#######################################

// Assume role gives temp security credentials to create the following ecs-task resources
data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#######################################################
// ---------- ECS TASK POLICY FOR CONTAINERS ------ //
#######################################################

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "DagsterS3LimitedAccess"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListAllMyBuckets",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads"
    ]
    effect = "Allow"
    // Change resources here as required
    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_policy" "task" {
  name   = "DagsterContainerPolicy"
  path   = "/dagster/containeraccess/"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role" "task" {
  name               = "dagster-task-role"
  path               = "/dagster/taskrole/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

// Attach further policies to task role:

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task.arn
}

##################################################
// ---------- ECS TASK EXECUTION ROLE --------- //
##################################################

data "aws_iam_policy_document" "task_execution" {

  statement {

    sid = "GetTokenECR"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {

    sid = "DagsterECRDeploy"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = [
      data.aws_ecr_repository.daemon_dagit.arn,
      data.aws_ecr_repository.etl.arn
    ]
  }

  statement {

    sid = "DagsterLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.log_group.arn}:*"
    ]
  }

  statement {

    sid = "DagsterElasticLoadBalancing"

    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]

    resources = [
      var.lb_target_group_arn,
      var.alb_arn
    ]
  }
}

resource "aws_iam_policy" "task_execution" {
  name   = "DagsterExecutionPolicy"
  path   = "/dagster/executionpolicy/"
  policy = data.aws_iam_policy_document.task_execution.json
}

resource "aws_iam_role" "task_execution" {
  name               = "ecs-dagster-task-execution-role"
  path               = "/dagster/taskexecutionrole/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.task_execution.arn
}

###################################################
// ----------- ECS INSTANCE ROLE --------------- //
###################################################

data "aws_iam_policy_document" "ecs_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "instance_policy" {

  // Merge with policy_document.task_execution

  source_policy_documents = [
    data.aws_iam_policy_document.task_execution.json
  ]

  statement {

    sid = "EC2Describe"

    actions = [
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }

  statement {

    sid = "DagsterECSRegister"

    actions = [
      "ecs:CreateCluster",
      "ecs:ListClusters",
      "ecs:DiscoverPollEndpoint",
      "ecs:RegisterContainerInstance",
      "ecs:DeregisterContainerInstance",
      "ecs:Poll",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "instance_policy" {
  name   = "DagsterInstancePolicy"
  path   = "/dagster/instancepolicy/"
  policy = data.aws_iam_policy_document.instance_policy.json
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs-dagster-instance-role"
  path               = "/dagster/instancerole/"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  path = "/dagster/instanceprofile/"
  role = aws_iam_role.ecs_instance_role.name
}

###################################################
// ----------- ECR PUBLISH AGENT --------------- //
###################################################

resource "aws_iam_user" "ecr_publish" {
  name = "ecr-publish-deploy-dagster"
  path = "/dagster/serviceaccounts/"
}

data "aws_iam_policy_document" "ecr_publish" {
  // Policies attached exclusively to resources involving dagster
  statement {

    sid = "GetTokenECR"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowPushECR"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories"
    ]
    effect = "Allow"
    resources = [
      data.aws_ecr_repository.daemon_dagit.arn,
      data.aws_ecr_repository.etl.arn
    ]
  }
  // Task definition IAM policies do not support resource-level permissions 
  statement {
    sid = "RegisterTaskDefinition"
    actions = [
      "ecs:RegisterTaskDefinition"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "DescribeTaskDefinition"
    actions = [
      "ecs:DescribeTaskDefinition"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "PassRolesInTaskDefinition"
    actions = [
      "iam:PassRole"
    ]
    effect = "Allow"
    resources = [
      aws_iam_role.task.arn,
      aws_iam_role.task_execution.arn
    ]
  }
  statement {
    sid = "DeployService"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    effect = "Allow"
    resources = [
      aws_ecs_service.dagster.cluster,
      aws_ecs_service.dagster.id
    ]
  }
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "DagsterECRPublishDeploy"
  description = "A policy to enable github actions to deploy dagster images to ecr."
  policy      = data.aws_iam_policy_document.ecr_publish.json
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.ecr_publish.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
