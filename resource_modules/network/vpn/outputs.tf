output "customer_gateway_ids" {
  description = "List of IDs of Customer Gateway"
  value       = values(aws_customer_gateway.this)[*].id
}