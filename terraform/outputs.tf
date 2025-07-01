output "public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.speedtest.public_ip
}

output "instance_id" {
  description = "The ID of the instance"
  value       = aws_instance.speedtest.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.speedtest_sg.id
}
