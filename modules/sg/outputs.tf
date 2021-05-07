
output "nat_sec_group" {
  value = aws_security_group.nat_sg
}

output "core_sec_group" {
  value = aws_security_group.core_sg
}

output "db_sec_group" {
  value = aws_security_group.db_sg
}

output "lb_sec_group" {
  value = aws_security_group.lb_sg
}
