variable "ami" {
        type  = string
}

variable "openvpn_ami" {
        type  = string
}

variable "instance_type" {
        type  = string
        default = "t2.micro" # 1c1m
}

variable "sg_ec2_ids" {
        type  = list
}

variable "ebs_type" {
  type = string
}
variable "instance_ebs_size" {
  type = number
}
variable "instance_subnet_id_nat" {
  description = "NAT 인스턴스에 사용할 서브넷 ID"
  type        = string
}

variable "instance_subnet_id_openvpn" {
  description = "OpenVPN 인스턴스에 사용할 서브넷 ID"
  type        = string
}

variable "associate_public_ip_address" {
        type = bool
        default = false
}

variable "key_name" {
        type = string
}

variable "env" {
        type = string
}