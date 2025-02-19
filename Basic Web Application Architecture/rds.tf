resource "aws_db_instance" "myinstance" {
    allocated_storage = 20
    storage_type = "standard"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = "foo"
    password = "foobarbaz"
    skip_final_snapshot = true
}