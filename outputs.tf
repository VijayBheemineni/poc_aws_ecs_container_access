output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_id" {
  value = module.vpc.public_subnets_id
}

output "private_subnets_id" {
  value = module.vpc.private_subnets_id
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "nat_gws_id" {
  value = module.vpc.nat_gws_id
}

output "secret_manager_secret_name" {
  value = module.sshkey.secret_manager_secret_name
}

output "sshkey_pair_name" {
  value = module.sshkey.sshkey_pair_name
}

output "bastion_sg" {
  value = module.bastion.bastion_sg
}

output "bastion_public_ip" {
  value = module.bastion.bastion_host_public_ip
}

output "ecs_cluster_arn" {
  value = module.ecs_cluster.ecs_cluster_arn
}

output "ecs_cluster_ec2_launchtemplate_arn" {
  value = module.ecs_cluster.ecs_cluster_ec2_launchtemplate_arn
}

output "ecs_cluster_ec2_asg_arn" {
  value = module.ecs_cluster.ecs_cluster_ec2_asg_arn
}

output "ecs_cluster_ec2_capacity_provider_arn" {
  value = module.ecs_cluster.ecs_cluster_ec2_capacity_provider_arn
}

output "ecs_task_execution_role_arn" {
  value = module.app.task_execution_role
}

output "ecs_task_role_arn" {
  value = module.app.task_role
}

output "ecs_fargate_app_name" {
  value = module.app.fargate_app_service
}

output "ecs_ec2_app_name" {
  value = module.app.ec2_app_service
}


