variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

# Gateways #
variable "create_vpn" {
  description = "Controls if VPN should be created"
  default     = false
}

variable "create_customer_gateway" {
  description = "Controls if VPN should be created"
  default     = false
}

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  default     = {}
}