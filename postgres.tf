resource "aws_db_subnet_group" "db-subnet-group" {
  name = "im"
  subnet_ids = [aws_subnet.public_subnet_db_1.id, aws_subnet.public_subnet_db_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" { 
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.10"
  instance_class       = "db.t3.micro"
  name                 = var.postgres_DB_NAME
  username             = var.postgres_DB_USER
  password             = var.postgres_DB_PASSWORD 
  identifier           = "im-survey"
  parameter_group_name = "default.postgres11" 
  skip_final_snapshot = true 
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.postgres.id] 
  publicly_accessible = true
  } 