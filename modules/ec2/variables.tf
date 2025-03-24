variable "ami" {
        type  = string
        default = "ami-062cddb9d94dcf95d" #AL 2023
}

variable "openvpn_ami" {
        type  = string
        default = "ami-09a093fa2e3bfca5a" #OpenVPN
  
}

variable "instance_type" {
        type  = string
        default = "t2.micro" # 1c1m
}

variable "sg_ec2_ids" {
        type  = list
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