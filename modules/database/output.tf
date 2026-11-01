output "address" {
  value = aws_db_instance.db_instance.address
}

output "port" {
  value = aws_db_instance.db_instance.port
}

output "db_name" {
  value = aws_db_instance.db_instance.db_name
}

output "security_group_id" {
  value = aws_security_group.main.id
}
