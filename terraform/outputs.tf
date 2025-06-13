output "public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.speedtest.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.speedtest.public_ip}"
}