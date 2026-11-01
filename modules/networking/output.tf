output "vpc_id" {
  description = "The ID of the VPC created by this module."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block assigned to the VPC."
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs, one per availability zone."
  value       = [for az in local.az_zones : aws_subnet.public_subnet[az].id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs, one per availability zone."
  value       = [for az in local.az_zones : aws_subnet.private_subnet[az].id]
}

output "public_subnet_id_map" {
  description = "Map of public subnet AZ names to subnet IDs."
  value       = { for k, s in aws_subnet.public_subnet : k => s.id }
}

output "private_subnet_id_map" {
  description = "Map of private subnet AZ names to subnet IDs."
  value       = { for k, s in aws_subnet.private_subnet : k => s.id }
}

output "igw_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public[local.az_zones[0]].id
}