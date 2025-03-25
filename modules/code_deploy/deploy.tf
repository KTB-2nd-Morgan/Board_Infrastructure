resource "aws_codedeploy_app" "deploy_app_backend" {
  name             = var.application_name
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "deploy_group_backend" {
  app_name              = aws_codedeploy_app.deploy_app_backend.name
  deployment_group_name = var.deployment_group_backend_name
  service_role_arn      = var.service_role_arn

  deployment_config_name = var.deployment_config_name

  ec2_tag_set {
    ec2_tag_filter {
      key   = var.ec2_tag_key
      type  = var.ec2_tag_filter_type
      value = var.ec2_tag_value
    }
  }

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
  }

  deployment_style {
    deployment_option = var.deployment_option
    deployment_type   = var.deployment_type
  }
}
