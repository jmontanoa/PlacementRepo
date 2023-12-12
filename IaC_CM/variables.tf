variable "resource_group_name" {
  type = string
}
variable "availability_set_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "subnet1_name" {
  type = string
}

variable "net_cidr" {
  type = string
}

variable "subnet1_cidr" {
  type = string
}

variable "subnet2_name" {
  type = string
}

variable "subnet2_cidr" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "private_ip_name" {
  type = string
}

variable "publicNsg" {
  type = string
}

variable "privateNsg" {
  type = string
}

variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "owner" {
  type = string
}

variable "product" {
  type = string
}

variable "sourceip" {
  type = string
}


variable "vm_username" {
  type = string
}

variable "vm_password" {
  type = string
}

variable "subscription_id" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "tenant_id" {
  type = string
}