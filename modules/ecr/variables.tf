variable "name" {
  description = "ECR 저장소 이름"
  type        = string
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "이미지 푸시 시 스캔 여부"
  type        = bool
  default     = true
}

variable "tags" {
  description = "ECR 저장소에 적용할 태그"
  type        = map(string)
  default     = {}
}
