This is a Terraform/IaC representation of a high-level web application architecture.

The architecture consists of a custom VPC with public and private subnets. A Route 53 hosted zone routes traffic to a CloudFront distribution, which caches and delivers content from an Application Load Balancer (ALB) deployed in the public subnet. The ALB is protected by an AWS WAF, which enforces IP blocking and geo-restrictions.

Traffic reaching the ALB is forwarded to an Auto Scaling Group (ASG) running two EC2 instances in the private subnet, ensuring scalability and availability. The application interacts with an Amazon RDS MySQL instance, secured within the private subnet via VPC endpoints to restrict public access.

An S3 bucket is used for data storage with versioning and server-side encryption enabled, and logging is handled by a separate dedicated bucket. Security groups are configured to control inbound and outbound traffic for the ALB, EC2 instances, and RDS. The architecture also includes an Internet Gateway for public subnet access and appropriate route tables to ensure internal and external connectivity.


AWS Services Used:

- VPC (Virtual Private Cloud)
- Subnets (Public and Private)
- Route 53
- CloudFront
- Application Load Balancer (ALB)
- AWS WAF (Web Application Firewall)
- Auto Scaling Group (ASG)
- EC2 Instances
- Amazon RDS (MySQL)
- S3 (Simple Storage Service)
- VPC Endpoints (S3 and RDS)
- Internet Gateway
- Route Tables
- Security Groups

ARCHITECTURE: 

![Web App Architecture](High-LevelWebArchitecture.png)





