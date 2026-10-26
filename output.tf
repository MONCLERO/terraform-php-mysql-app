

output "web_public_ip" {
  description = "Public IP of the Web tier"
  value       = aws_instance.web.public_ip
}

output "app_private_ip" {
  description = "Private IP of the App tier"
  value       = aws_instance.app.private_ip
}

output "db_private_ip" {
  description = "Private IP of the DB tier"
  value       = aws_instance.db.private_ip
}