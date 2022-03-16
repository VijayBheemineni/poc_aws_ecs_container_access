terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.2.0"
    }
  }
  required_version = "~> 1.1.7"
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "git::https://github.com/VijayBheemineni/terraform_modules_aws_vpc.git?ref=v0.1.2"
  tags   = var.tags
  vpc    = var.vpc_config
}

module "sshkey" {
  source                = "git::https://github.com/VijayBheemineni/terraform_modules_aws_sshkey.git?ref=v0.1.3"
  tags                  = var.tags
  sshkey_config         = var.sshkey_config
  secretsmanager_config = var.secretsmanager_config
}

locals {
  vpc_config = {
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets_id
    private_subnets = module.vpc.private_subnets_id
  }
  default_bastion_host_config = {
    ssh_key_name = module.sshkey.sshkey_pair_name
  }
  bastion_host_config = merge(
    local.default_bastion_host_config,
    var.bastion_host_config
  )
}

module "bastion" {
  source              = "git::https://github.com/VijayBheemineni/terraform_modules_aws_ec2_bastion.git?ref=v0.1.0"
  tags                = var.tags
  vpc_config          = local.vpc_config
  bastion_sg_config   = var.bastion_sg_config
  bastion_host_config = local.bastion_host_config
  depends_on = [
    module.vpc,
    module.sshkey
  ]
}

locals {
  default_launchtemplate_config = {
    key_name = module.sshkey.sshkey_pair_name
  }
  launchtemplate_config = merge(
    local.default_launchtemplate_config,
    var.launchtemplate_config
  )
}
module "ecs_cluster" {
  source = "git::https://github.com/VijayBheemineni/terraform_modules_aws_ecs_cluster.git?ref=v0.1.5"
  # source = "git::https://github.com/VijayBheemineni/terraform_modules_aws_ecs_cluster.git?ref=main"
  # source                      = "../../terraform_modules_aws_ecs_cluster"
  tags                        = var.tags
  ecs_cluster_config          = var.ecs_cluster_config
  launchtemplate_config       = local.launchtemplate_config
  asg_config                  = var.asg_config
  vpc_config                  = local.vpc_config
  ec2_capacityprovider_config = var.ec2_capacityprovider_config
  depends_on = [
    module.vpc,
    module.sshkey
  ]
}

module "app" {
  source     = "./modules/app"
  tags       = var.tags
  vpc_config = local.vpc_config
  depends_on = [
    module.vpc,
    module.ecs_cluster
  ]
}
