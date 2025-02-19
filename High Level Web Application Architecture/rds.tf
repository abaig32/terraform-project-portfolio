resource "aws_db_instance" "rdswebapp_instance" {
    allocated_storage = 20
    storage_type = "standard"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = var.db_username
    password = var.db_password
    skip_final_snapshot = true
}