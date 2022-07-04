variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "region" {
  description = "The Azure location where all resources in this example should be created"
}

################################
# publisher = "SUSE"
# offer     = "sles-sap-12-sp5"
# sku       = "gen2"
# _version   = "latest"
################################
# publisher = "SUSE"
# offer     = "SLES-SAP"
# sku       = "12-sp4-gen2"
# _version   = "latest"
################################
variable "publisher" {
  description = "Publisher of the image used to create VM"
}
variable "offer" {
  description = "Offer of the image used to create VM"
}
variable "sku" {
  description = "SKU of the image used to create VM"
}
variable "_version" {
  description = "Version of the image used to create VM, underscore added to avoid Terraform error"
}

variable "cloudshell_public_ip" {
  description = "This IP added into ssh allow list for bastion VM"
  type = list(string)
  default = ["12.23.56.78/32"]
}