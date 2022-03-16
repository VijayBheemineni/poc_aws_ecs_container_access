data "aws_iam_policy" "ssm_full_access" {
  name = "AmazonSSMFullAccess"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = join("_", [var.tags.name, "ecs_task_execution_role"])
}

data "aws_ecs_cluster" "ecs-cluster" {
  cluster_name = var.tags.name
}

data "aws_security_group" "ecs_workers_sg" {
  name = join("_", [var.tags.name, "ecs_ec2_instances"])
}

/*
  Below blocks create ECS Task Role
*/
resource "aws_iam_role" "task_role" {
  name               = join("_", [var.tags.name, "task_role"])
  assume_role_policy = file("${path.module}/policies/taskrole_trust_policy.json")
}

resource "aws_iam_role_policy_attachment" "ssm_full_access_attachment" {
  role       = aws_iam_role.task_role.id
  policy_arn = data.aws_iam_policy.ssm_full_access.arn
}

/*
  Below blocks create Fargate Service
*/
data "template_file" "fargate_app_tmpl" {
  template = file("${path.module}/templates/${var.fargate_app_config.taskdefinition_template_file_name}")

  vars = {
    name          = var.tags.name
    containerPort = var.fargate_app_config.container_port
  }
}

resource "aws_ecs_task_definition" "fargate_app_td" {
  family                   = join("_", [var.tags.name, "fargate_app"])
  container_definitions    = data.template_file.fargate_app_tmpl.rendered
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_app_config.cpu
  memory                   = var.fargate_app_config.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
}

resource "aws_ecs_service" "fargate_ecs_service" {
  name            = join("_", [var.tags.name, "fargate"])
  cluster         = data.aws_ecs_cluster.ecs-cluster.arn
  desired_count   = var.fargate_app_config.desired_count
  task_definition = aws_ecs_task_definition.fargate_app_td.arn
  network_configuration {
    subnets         = var.vpc_config.private_subnets
    security_groups = [data.aws_security_group.ecs_workers_sg.id]
  }
  enable_execute_command = true
}

/*
  Below blocks create ECS EC2 Service
*/
data "template_file" "ec2_app_tmpl" {
  template = file("${path.module}/templates/${var.ec2_app_config.taskdefinition_template_file_name}")
  vars = {
    name          = var.tags.name
    containerPort = var.ec2_app_config.container_port
  }
}
resource "aws_ecs_task_definition" "ec2_app_td" {
  family                   = join("_", [var.tags.name, "ec2_app"])
  container_definitions    = data.template_file.fargate_app_tmpl.rendered
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.ec2_app_config.cpu
  memory                   = var.ec2_app_config.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
}

resource "aws_ecs_service" "ec2_ecs_service" {
  name                   = join("_", [var.tags.name, "ec2"])
  cluster                = data.aws_ecs_cluster.ecs-cluster.arn
  desired_count          = var.ec2_app_config.desired_count
  task_definition        = aws_ecs_task_definition.ec2_app_td.arn
  enable_execute_command = true
  capacity_provider_strategy {
    capacity_provider = var.tags.name
    weight            = 1
  }
}


