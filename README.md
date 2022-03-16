<!-- BEGIN_TF_DOCS -->
# WARNING
    Terraform code creates the infrastructure required to demo 'ECS Container Access.'The code in this repo is not perfect, and there is still scope to improve.

    Using this code in production environments is not recommended.
## Description
    Terraform code creates the infrastructure required to demo 'ECS Container Access.'

<b> Prerequisites for 'ECS' 'execute-command' login. Terraform code, by default, creates all resources required.</b>
- Use the latest ECS optimized AMI(Agent must be greater than 1.50.2).
- For the ECS EC2 instance, make sure user data contains the below config.
```sh
#!/bin/bash
echo ECS_CLUSTER=your_cluster_name >> /etc/ecs/ecs.config
```
- Fargate Platform version >= '1.4.0'.
- ECS Task has access to AWS IAM 'SSM' actions.
- Enable 'execute command' is enabled on the ECS service.
- 'Session Manager Plugin' is enabled for AWS CLI.

<b>How to get task id and container ids for AWS 'execute-command' and 'SSM'?</b>
    You can use console or AWS CLI to get the required 'task id' and 'container id.' But to make it simple to fetch these details, I had created a simple python script.
    The python script 'ecs_tasks_details.py' can be found 'scripts' folder.

```sh
# Make sure boto3 package is installed.
# Update 'cluster_name' and 'required_container_name'(container you want to log into) in the python script.
python ecs_tasks_details.py 
```
<b>How to log into ECS container.</b><br>
- Fargate :- For Fargate, we can log into the container only using the 'ECS' 'execute-command' option.
- EC2     :- For EC2 containers, we can log into the container using the 'ECS' 'execute-command' or using 'docker exec' on the ec2 instance.

```sh
aws ecs execute-command  --region <REGION> --cluster <CLUSTER_NAME> --task <TASK_ID> --container <CONTAINER_IMAGE_NAME> --command "<COMMAND>" --interactive

# Example
aws ecs execute-command  --region us-east-1 --cluster ecs_container_access --task 0df5f060bcda144f84bff81b31d320d2 --container httpd --command "/bin/sh" --interactive
```

<b>How can we access the ECS container app port.</b>

- AWS SSM :- Using AWS SSM document 'AWS-StartPortForwardingSession,' we can access the container application port through a 'local' port.
```sh
aws ssm start-session --target ecs:<CLUSTER_NAME>_<TASK_ID>_<CONTAINER_ID> --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=<LOCAL_PORT>,portNumber=<CONTAINER_PORT>"

# Example
# Start the SSM Session
aws ssm start-session --target ecs:ecs_container_access_1df5f080bcda544e84bff81b31d317d2_1df5f070bcda544e84bff81b31d317d2-3493804279 --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=8000,portNumber=80"
# Access the container application port
curl http://localhost:<LOCAL_PORT>
```
- SSH Tunnel :- Using SSH Tunnel, we can access the container application port through a 'local' port.
```sh
# Start the tunnel
ssh -i <SSH_KEY> ec2-user@<BASTION_HOST> -L <LOCAL_PORT>:<ECS_EC2_INSTANCE_PRIVATE_IP>:<HOST_PORT>
# Example
ssh -i test_ssh ec2-user@3.1.2.3 -L 8000:10.10.1.155:80
# Access the container application port
curl http://localhost:<LOCAL_PORT>
```

## Issues
- Sometimes code fails when we run the command the 'terraform apply.' Ideally, the infrastructure we can run the 'terraform apply'  again. But due to unknown reasons, this doesn't happen. I am trying to fix this issue. Please run the 'terraform destroy' and the 'terraform apply' again if you face the error.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 4.2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app"></a> [app](#module\_app) | ./modules/app | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | git::https://github.com/VijayBheemineni/terraform_modules_aws_ec2_bastion.git | v0.1.0 |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | git::https://github.com/VijayBheemineni/terraform_modules_aws_ecs_cluster.git | v0.1.5 |
| <a name="module_sshkey"></a> [sshkey](#module\_sshkey) | git::https://github.com/VijayBheemineni/terraform_modules_aws_sshkey.git | v0.1.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/VijayBheemineni/terraform_modules_aws_vpc.git | v0.1.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_config"></a> [asg\_config](#input\_asg\_config) | n/a | `map` | <pre>{<br>  "desired_capacity": 1,<br>  "max_size": 1,<br>  "min_size": 1,<br>  "protect_from_scale_in": true<br>}</pre> | no |
| <a name="input_bastion_host_config"></a> [bastion\_host\_config](#input\_bastion\_host\_config) | n/a | `map` | <pre>{<br>  "ami_id": "ami-0bb273345f0961e90",<br>  "instance_type": "t3.nano"<br>}</pre> | no |
| <a name="input_bastion_sg_config"></a> [bastion\_sg\_config](#input\_bastion\_sg\_config) | n/a | `map` | <pre>{<br>  "security_group_rules": [<br>    {<br>      "cidr_block": "10.1.0.0/16",<br>      "description": "SSH from private ip address network space",<br>      "from_port": 22,<br>      "protocol": "tcp",<br>      "to_port": 22<br>    },<br>    {<br>      "cidr_block": "3.1.2.4/32",<br>      "description": "SSH from public ip address",<br>      "from_port": 22,<br>      "protocol": "tcp",<br>      "to_port": 22<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_ec2_capacityprovider_config"></a> [ec2\_capacityprovider\_config](#input\_ec2\_capacityprovider\_config) | n/a | `map` | <pre>{<br>  "managed_scaling": {<br>    "maximum_scaling_step_size": 1000,<br>    "minimum_scaling_step_size": 1,<br>    "status": "ENABLED",<br>    "target_capacity": 100<br>  },<br>  "managed_termination_protection": "ENABLED"<br>}</pre> | no |
| <a name="input_ecs_cluster_config"></a> [ecs\_cluster\_config](#input\_ecs\_cluster\_config) | n/a | `map` | <pre>{<br>  "containerInsights": "enabled"<br>}</pre> | no |
| <a name="input_launchtemplate_config"></a> [launchtemplate\_config](#input\_launchtemplate\_config) | n/a | `map` | <pre>{<br>  "ebs_optimized": true,<br>  "image_id": "ami-0bb273345f0961e90",<br>  "instance_initiated_shutdown_behavior": "terminate",<br>  "instance_type": "t3.nano",<br>  "monitoring": true<br>}</pre> | no |
| <a name="input_secretsmanager_config"></a> [secretsmanager\_config](#input\_secretsmanager\_config) | n/a | `map` | <pre>{<br>  "recovery_window_in_days": 0<br>}</pre> | no |
| <a name="input_sshkey_config"></a> [sshkey\_config](#input\_sshkey\_config) | n/a | `map` | <pre>{<br>  "algorithm": "rsa",<br>  "bits": 2048<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map` | <pre>{<br>  "description": "Proof of concept ECS Container access",<br>  "name": "poc_ecs_container_access",<br>  "terraform_version": "1.1.7"<br>}</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | n/a | `map` | <pre>{<br>  "assign_generated_ipv6_cidr_block": false,<br>  "cidr_block": "192.168.1.0/24",<br>  "enable_dns_hostnames": true,<br>  "enable_dns_support": true,<br>  "instance_tenancy": "default",<br>  "map_public_ip_on_launch": true,<br>  "private_subnets_details": {<br>    "private_subnet_aza": {<br>      "availability_zone": "us-east-1a",<br>      "cidr_block": "192.168.1.128/26",<br>      "subnet_type": "private"<br>    },<br>    "private_subnet_azb": {<br>      "availability_zone": "us-east-1b",<br>      "cidr_block": "192.168.1.192/26",<br>      "subnet_type": "private"<br>    }<br>  },<br>  "public_subnets_details": {<br>    "public_subnet_aza": {<br>      "availability_zone": "us-east-1a",<br>      "cidr_block": "192.168.1.0/26",<br>      "subnet_type": "public"<br>    },<br>    "public_subnet_azb": {<br>      "availability_zone": "us-east-1b",<br>      "cidr_block": "192.168.1.64/26",<br>      "subnet_type": "public"<br>    }<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
| <a name="output_bastion_sg"></a> [bastion\_sg](#output\_bastion\_sg) | n/a |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | n/a |
| <a name="output_ecs_cluster_ec2_asg_arn"></a> [ecs\_cluster\_ec2\_asg\_arn](#output\_ecs\_cluster\_ec2\_asg\_arn) | n/a |
| <a name="output_ecs_cluster_ec2_capacity_provider_arn"></a> [ecs\_cluster\_ec2\_capacity\_provider\_arn](#output\_ecs\_cluster\_ec2\_capacity\_provider\_arn) | n/a |
| <a name="output_ecs_cluster_ec2_launchtemplate_arn"></a> [ecs\_cluster\_ec2\_launchtemplate\_arn](#output\_ecs\_cluster\_ec2\_launchtemplate\_arn) | n/a |
| <a name="output_ecs_ec2_app_name"></a> [ecs\_ec2\_app\_name](#output\_ecs\_ec2\_app\_name) | n/a |
| <a name="output_ecs_fargate_app_name"></a> [ecs\_fargate\_app\_name](#output\_ecs\_fargate\_app\_name) | n/a |
| <a name="output_ecs_task_execution_role_arn"></a> [ecs\_task\_execution\_role\_arn](#output\_ecs\_task\_execution\_role\_arn) | n/a |
| <a name="output_ecs_task_role_arn"></a> [ecs\_task\_role\_arn](#output\_ecs\_task\_role\_arn) | n/a |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | n/a |
| <a name="output_nat_gws_id"></a> [nat\_gws\_id](#output\_nat\_gws\_id) | n/a |
| <a name="output_private_subnets_id"></a> [private\_subnets\_id](#output\_private\_subnets\_id) | n/a |
| <a name="output_public_subnets_id"></a> [public\_subnets\_id](#output\_public\_subnets\_id) | n/a |
| <a name="output_secret_manager_secret_name"></a> [secret\_manager\_secret\_name](#output\_secret\_manager\_secret\_name) | n/a |
| <a name="output_sshkey_pair_name"></a> [sshkey\_pair\_name](#output\_sshkey\_pair\_name) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->