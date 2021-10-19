output "vpc" {
  value = aws_vpc.vpc
}

output "igw"{
  value = aws_internet_gateway.igw
}

output "route_table_dmz" {
  value = aws_route_table.dmz
}
output "route_table_core" {
  value = aws_route_table.core
}
output "route_table_db" {
  value = aws_route_table.db
}

# list of route tables, who knows if it will be needed
output "route_tables_list" {
  value = tolist ( [ aws_route_table.dmz, aws_route_table.core, aws_route_table.db ] )
}

output "core_subnets_list" {
  value = tolist ( [for s in aws_subnet.subnet_core : s.id] )
}
output "db_subnets_list" {
  value = tolist ( [for s in aws_subnet.subnet_db : s.id] )
}
output "dmz_subnets_list" {
  value = tolist ( [for s in aws_subnet.subnet_dmz : s.id] )
}
