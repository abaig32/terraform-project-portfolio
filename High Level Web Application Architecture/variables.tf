variable "ec2_instance_type" {
    description = "specify EC2 instance type"
    type = string
    default = "t2.micro"
}

variable "ec2_instance_ami" {
    description = "specify EC2 EMI"
    type = string
    default = "ami-0df8c184d5f6ae949"
}

variable "s3_bucket_name" {
    description = "specify s3 bucket name"
    type = string
    default = "bucket_for_instances"
}

variable "db_username" {
    description = "specify db username"
    type = string
    default = "foo"
}

variable "db_password" {
    description = "specify db password"
    type = string
    default = "foobarbaz"
}

variable "metric_name" {
    description = "specify the metric for cloudwatch waf logging"
    type = string
    default = "waf_logs"
}

variable "alb_ip_sets" {
    description = "specify the ip ranges to block for the WAF"
    type = list(string)
    default = [ "192.168.1.1/32", "203.0.113.0/24" ]
}