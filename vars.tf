variable "tags" {
  default = {
    name              = "poc_ecs_container_access"
    terraform_version = "1.1.7"
    description       = "Proof of concept ECS Container access"
  }
}

variable "vpc_config" {
  default = {
    cidr_block                       = "192.168.1.0/24"
    instance_tenancy                 = "default"
    map_public_ip_on_launch          = true
    enable_dns_support               = true
    enable_dns_hostnames             = true
    assign_generated_ipv6_cidr_block = false
    public_subnets_details = {
      public_subnet_aza = {
        availability_zone = "us-east-1a"
        cidr_block        = "192.168.1.0/26"
        subnet_type       = "public"
      },
      public_subnet_azb = {
        availability_zone = "us-east-1b"
        cidr_block        = "192.168.1.64/26"
        subnet_type       = "public"
      }
    },
    private_subnets_details = {
      private_subnet_aza = {
        availability_zone = "us-east-1a"
        cidr_block        = "192.168.1.128/26"
        subnet_type       = "private"
      },
      private_subnet_azb = {
        availability_zone = "us-east-1b"
        cidr_block        = "192.168.1.192/26"
        subnet_type       = "private"
      }
    }
  }
}

variable "sshkey_config" {
  default = {
    algorithm = "rsa"
    bits      = 2048
  }
}

variable "secretsmanager_config" {
  default = {
    recovery_window_in_days = 0
  }
}

variable "bastion_sg_config" {
  default = {
    security_group_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.1.0.0/16",
        description = "SSH from private ip address network space"
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "3.1.2.4/32",
        description = "SSH from public ip address"
      }
    ]
  }
}

variable "bastion_host_config" {
  default = {
    ami_id        = "ami-0bb273345f0961e90"
    instance_type = "t3.nano"
  }
}

variable "ecs_cluster_config" {
  default = {
    containerInsights = "enabled"
  }
}

variable "launchtemplate_config" {
  default = {
    image_id                             = "ami-0bb273345f0961e90"
    ebs_optimized                        = true
    instance_initiated_shutdown_behavior = "terminate"
    instance_type                        = "t3.nano"
    monitoring                           = true
  }
}

variable "asg_config" {
  default = {
    min_size              = 1
    max_size              = 1
    desired_capacity      = 1
    protect_from_scale_in = true

  }
}

variable "ec2_capacityprovider_config" {
  default = {
    managed_termination_protection = "ENABLED"
    managed_scaling = {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}


