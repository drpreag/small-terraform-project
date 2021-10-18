
output "primary_nat_eni" {
  value = aws_network_interface.nat_eni
}

output "primary_lb_eni" {
  value = aws_network_interface.lb_eni
}
