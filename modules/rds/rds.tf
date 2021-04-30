
# RDS Subnet group

resource "aws_db_subnet_group" "dbsubnetg" {
  name       = "${var.vpc_name}-dbsubnetg"
  subnet_ids = var.db_subnet_list
  tags = {
    VpcName = var.vpc_name
    Creator = var.main_tags.Creator
  }
}


# RDS instance (from existing snapshot)

resource "aws_db_instance" "idx-db" {
  instance_class        = "db.t3.medium"
  identifier            = "${var.vpc_name}-db"
  username              = "ixadmin"
  db_subnet_group_name  = aws_db_subnet_group.dbsubnetg.id
  parameter_group_name  = "${var.vpc_name}-parameter-group"
  option_group_name     = "default:mysql-5-7"
  snapshot_identifier   = "${var.vpc_name}-db"
  vpc_security_group_ids = var.vpc_sec_groups
  skip_final_snapshot   = true
  depends_on            = [ aws_db_parameter_group.parameter_group ]
  storage_encrypted     = true
  tags = {
    Name        = "${var.vpc_name}-db"
    Creator     = var.main_tags["Creator"]
    Schedule    = var.main_tags["Schedule"]
    started-by  = var.main_tags["started-by"]
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = "${var.vpc_name}-parameter-group"
  family = "mysql5.7"
  parameter {
    name  = "lower_case_table_names"
    value = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "max_allowed_packet"
    value = "33554432"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "local_infile"
    value = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
    apply_method = "pending-reboot"
  }
}
