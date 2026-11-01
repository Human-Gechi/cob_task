module "standard" {
  source = "../standard"

  organisation = var.organisation
  project      = var.project
  environment  = var.environment
  team         = var.team
  extra_tags   = var.extra_tags
}

resource "aws_db_subnet_group" "main_subgroup" {
  name       = "${module.standard.name_prefix}-db"
  subnet_ids = var.private_subnet_ids
  tags       = module.standard.tags
}

resource "aws_security_group" "main" {
  name        = "${module.standard.name_prefix}-db"
  description = "Database access"
  vpc_id      = var.vpc_id
  tags        = merge(module.standard.tags, { Name = "${module.standard.name_prefix}-db" })
}

resource "aws_vpc_security_group_ingress_rule" "main_rule" {
  security_group_id            = aws_security_group.main.id
  referenced_security_group_id = var.allowed_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
}

resource "aws_db_instance" "db_instance" {
  identifier     = "${module.standard.name_prefix}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = "cob_admin"

  manage_master_user_password = true

  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.main_subgroup.name
  vpc_security_group_ids = [aws_security_group.main.id]

  storage_encrypted   = true
  publicly_accessible = false

  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_days
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${module.standard.name_prefix}-db-final"

  tags = module.standard.tags
}
