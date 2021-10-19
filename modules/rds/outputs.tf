
output "rds_instance_endpoint" {
    value = split(":", aws_db_instance.mysql_rds.endpoint)[0]
}

output "rds_instance" {
    value = aws_db_instance.mysql_rds
}