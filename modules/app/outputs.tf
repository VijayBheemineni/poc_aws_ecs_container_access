output "task_execution_role" {
  value = data.aws_iam_role.ecs_task_execution_role.arn
}

output "task_role" {
  value = aws_iam_role.task_role.arn
}

output "fargate_app_service_task_definition" {
  value = aws_ecs_task_definition.fargate_app_td.arn
}

output "fargate_app_service" {
  value = aws_ecs_service.fargate_ecs_service.name
}

output "ec2_app_service_task_definition" {
  value = aws_ecs_task_definition.ec2_app_td.arn
}

output "ec2_app_service" {
  value = aws_ecs_service.ec2_ecs_service.name
}

