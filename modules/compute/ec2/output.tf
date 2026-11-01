output "instance_ids" {
  value = aws_instance.main_ec2[*].id
}

output "private_ips" {
  description = "Private IP addresses of the instances."
  value       = aws_instance.main_ec2[*].private_ip
}

output "security_group_id" {
  description = "Security group of the instances. Other modules (e.g. database) can allow this id."
  value       = aws_security_group.main_ec2.id
}

output "role_arn" {
  description = "ARN of the instance role."
  value       = aws_iam_role.main.arn
}

output "role_name" {
  description = "Name of the instance role. Attach extra policies to it if the workload needs more access."
  value       = aws_iam_role.main.name
}

output "public_ips" {
  value = aws_instance.main_ec2[*].public_ip
}