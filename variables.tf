variable "HUB-IP-CIDR" {
  description = "The IP address to be used for the resource."
  type        = string
  default     = "192.168.0.0/16"
}

variable "username" {
  description = "The name of the VM user"
  type        = string
  default     = "fream"
}

variable "public_key" {
  description = "Public Key for VM user"
  type        = string
  default     = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtbLSKyEb/groe1qYSGWLiAxrqLQVgfyud99BYjb3m6EqESalPpUp5HrOv19Oykvso4M+bkThZ/uvaoQ/9/5Uzy5Z2mkmjIBdh4ajklZHBw7pqMTqQqAy0r8oSgpcDkKIaHx3SbXrsWpP0oE7WW8Ar0kh1sZh/foYeMLvkeZ73pUgZhcm2XZvHkjPXUCU6otP3S4BtcaysfuF4eagS+4Ut15e+kefYYd+1ulhO8ssu+IMkqcPWi7g8jFi0w+e6b2oTqJTutmwzerOeJRoBaJtInesAp8eGf3yduR/fmiaiv7QAuLy4Cs+YICqyf+1DH3PR5jUySaeFHM+F3MZKbBwIQIDAQAB
"
}

variable "SPOKE1-IP-CIDR" {
  description = "The IP address to be used for the resource."
  type        = string
  default     = "10.0.0.0/16"
}

variable "SPOKE2-IP-CIDR" {
  description = "The IP address to be used for the resource."
  type        = string
  default     = "172.16.0.0/16"
}

variable "VM-PRIVATE-IP" {
  description = "The private IP address to be used for the VM."
  type        = string
  default     = "10.0.1.5"
}

variable "FW-IP-CIDR" {
  description = "The private IP address to be used for the Firewall."
  type        = string
  default     = "192.168.2.0/26"
}

variable "FW-MGMT-IP-CIDR" {
  description = "The private IP address to be used for the Firewall."
  type        = string
  default     = "192.168.3.0/26"
}

variable "user_id" {
  description = "User ID for RBAC"
  type        = string
  default     = "ce295710-d58c-484a-b0bb-648764d048c2"
}

locals {
  subnet1_cidr        = cidrsubnet(var.HUB-IP-CIDR, 8, 1)
  subnet2_cidr        = cidrsubnet(var.SPOKE1-IP-CIDR, 8, 1)
  subnet3_cidr        = cidrsubnet(var.SPOKE2-IP-CIDR, 8, 1)
  bastion_subnet_cidr = cidrsubnet(var.HUB-IP-CIDR, 10, 0)
}

locals {
  tags = {
    project = "landing-zone"
    env     = "dev"
    owner   = "fream"
  }
}

variable "source_ip" {
  description = "Public IP allowed through the Key Vault firewall during apply"
  type        = string
}