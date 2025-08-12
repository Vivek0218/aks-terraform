variable "environment" {}
variable "node_resourcegroup" {}
variable "location" {}
variable "resourcegroup" {}
variable "ari_prefix" {}
variable "aks_version" {}
variable "aks_tier" {
  type        = string
  default     = "Free"
  description = "AKS pricing tier"
}
variable "system_vm_size" {}
variable "aks_cluster_type" {}
variable "aks_vnet_name" {}
variable "aks_vnet_rg_name" {}
variable "aks_vnet_address_prefixes" {}
variable "aks_subnet_address_prefixes" {}
variable "profile" {}
variable "pe_subnet_address_prefixes" {
  default = ""
}
variable "loadBalancerIP" {}
variable "next_hop_ip" {
  default = ""
}
variable "ad_group_with_access" {}
variable "fcx_mtls" {
  type    = string
  default = "false"
}
variable "av_zones" {
  type = list(any)
}
variable "ha_enabled" {}
variable "country" {}
variable "tenant_name" {}
variable "environment_type" {}
variable "owner" {}
variable "expiration_date" {}
variable "cost_center" {}
variable "cost_allocation" {}
variable "env_reference_id" {}
