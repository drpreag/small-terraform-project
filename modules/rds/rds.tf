# RDS instance

resource "aws_db_instance" "mysql_rds" {
  name                    = "mysqldb"
  identifier              = "${local.vpc_name}-db"
  instance_class          = var.rds_instance_type
  vpc_security_group_ids  = [ var.db_sec_group.id ]
  username                = "root"
  password                = "testroot"
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "5.7"
  db_subnet_group_name    = aws_db_subnet_group.dbsubnetg.id
  parameter_group_name    = aws_db_parameter_group.parameter_group.name
  option_group_name       = "default:mysql-5-7"
  storage_encrypted       = true
  kms_key_id              = data.aws_kms_key.alias.arn
  multi_az                = false
}

resource "aws_db_subnet_group" "dbsubnetg" {
  name                    = "${local.vpc_name}-dbsubnetg"
  subnet_ids              = var.db_subnets_list
}

resource "aws_db_parameter_group" "parameter_group" {
  name                    = "${local.vpc_name}-parameter-group"
  family                  = "mysql5.7"
  parameter {
    name                  = "lower_case_table_names"
    value                 = "1"
    apply_method          = "pending-reboot"
  }
  parameter {
    name                  = "max_allowed_packet"
    value                 = "33554432"
    apply_method          = "pending-reboot"
  }
  parameter {
    name                  = "local_infile"
    value                 = "1"
    apply_method          = "pending-reboot"
  }
  parameter {
    name                  = "log_bin_trust_function_creators"
    value                 = "1"
    apply_method          = "pending-reboot"
  }
}

data "aws_kms_key" "alias" {
  key_id = "alias/${local.vpc_name}"
}