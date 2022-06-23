output "Postgres_endpoint" {
  value = aws_db_instance.default.endpoint
} 

output "ALB_endpoint" {
  value = aws_alb.main.dns_name
}