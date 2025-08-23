resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_security_group" "db" {
  name   = "${var.project}-db-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = toset(var.sg_source_ids)
    content {
      from_port       = var.engine == "postgres" ? 5432 : 3306
      to_port         = var.engine == "postgres" ? 5432 : 3306
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.project}-db"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = 20
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  publicly_accessible    = false
}

output "endpoint" {
  value = aws_db_instance.this.address
}
