
output "bastion_sec_group" {
  value = aws_security_group.bastion_sg
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
