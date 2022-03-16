variable "tags" {}
variable "vpc_config" {}
variable "fargate_app_config" {
  default = {
    taskdefinition_template_file_name = "fargate_httpd_taskdefinition.json.txt"
    container_port                    = 80
    cpu                               = 256
    memory                            = 512
    desired_count                     = 1
  }
}

variable "ec2_app_config" {
  default = {
    taskdefinition_template_file_name = "ec2_httpd_taskdefinition.json.txt"
    container_port                    = 80
    cpu                               = 128
    memory                            = 256
    desired_count                     = 1
  }
}
