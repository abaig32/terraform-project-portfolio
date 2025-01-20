This is a terraform/IaC representation of a simple web application architecture

AWS Services Used:
- Default VPC
- Default Subnets
- Route 53 
    - Primary Zone
    - Alias
- Application Load Balancer
    - Ingress and Outgress Rules
    - Target Groups
    - HTTP Traffic
- 2 Amazon EC2 Instances
    - Security Groups 
    - Ingress Rules
    - HTTP Traffic
- S3 Bucket
    - Versioning Enabled
    - Server Side Encryption
- Amazon RDS MySQL Instance

![Web App Architecture](WebAppArchitecture.png)

Note: 
The domain used for the primary zone "example.com" does not work as I do not own a domain myself. However, with an owned domain the infrastructure will work. 
Also, the ".terraform" file is removed due to files being too large to push to github. Make sure you run "terraform init" to allow the infrastructure to work. 