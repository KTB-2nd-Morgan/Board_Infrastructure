variable "application_name" {
  description = "CodeDeploy 애플리케이션 이름"
  type        = string
}

variable "deployment_group_backend_name" {
  description = "CodeDeploy 배포 그룹 이름"
  type        = string
}

variable "service_role_arn" {
  description = "CodeDeploy 배포 그룹에 사용할 서비스 역할 ARN"
  type        = string
}

variable "deployment_config_name" {
  description = "CodeDeploy 배포 구성 이름"
  type        = string
  default     = "CodeDeployDefault.AllAtOnce"
}

variable "ec2_tag_key" {
  description = "배포 대상 인스턴스 태그 키"
  type        = string
}

variable "ec2_tag_value" {
  description = "배포 대상 인스턴스 태그 값"
  type        = string
}

variable "ec2_tag_filter_type" {
  description = "인스턴스 태그 필터 유형 (예: KEY_AND_VALUE)"
  type        = string
  default     = "KEY_AND_VALUE"
}

variable "auto_rollback_enabled" {
  description = "배포 실패 시 자동 롤백 여부"
  type        = bool
  default     = false
}

variable "deployment_option" {
  description = "배포 옵션 (예: WITH_TRAFFIC_CONTROL)"
  type        = string
  default     = "WITHOUT_TRAFFIC_CONTROL"
}

variable "deployment_type" {
  description = "배포 유형 (예: IN_PLACE)"
  type        = string
  default     = "IN_PLACE"
}
