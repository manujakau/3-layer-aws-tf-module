module "vpn" {
  source = "../../resource_modules/network/vpn"

  create_vpn = var.create_vpn
  create_customer_gateway = var.create_customer_gateway
  name = var.name
  customer_gateways = var.customer_gateways
  tags = var.tags
}