
output "rds_instance_endpoint" {
    value = split(":", aws_db_instance.idx-db.endpoint)[0]
}