output "codedeploy_app_name" {
  description = "CodeDeploy 애플리케이션 이름"
  value       = aws_codedeploy_app.deploy_app_backend.name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy 배포 그룹 이름"
  value       = aws_codedeploy_deployment_group.deploy_group_backend.deployment_group_name
}
