# Kubernetes Cluster Deployment with Terraform and EKS

This repository contains Terraform code to provision an AWS VPC, EKS cluster, and associated resources. It also provides Kubernetes manifests for deploying an application container (hosted in an ECR repository) and exposing it via a LoadBalancer. 

# Description

This project is the deployment of an EKS cluster with an ECR image of a to-do list web application.

I used HTML, CSS, and JavaScript to create a simple web application of a to-do list that is interactive and offers full functionality. 

I then created a docker image of this application and pushed it to ECR (Elastic Container Registry)

Then I used Terraform to provision an EKS cluster that used the ECR image within its own VPC and other associated resources 

# Prerequisite Resources

- **AWS CLI:** Installed and configured with credentials that have sufficient permissions.
- **Terraform:** Installed (version 1.0+ recommended).
- **kubectl:** Installed.
- **Docker:** Installed (to build and push your image).
- **AWS ECR Repository:** Created (or the Terraform code can be extended to create one).
- **Git:** To clone this repository.

# Structure of the Repository

- `provider.tf` – Configures the AWS provider and Terraform settings.
- `vpc.tf` – Creates a VPC with public and private subnets, NAT gateway, etc.
- `variables.tf` – Defines variables (e.g., VPC CIDR, region, Kubernetes version).
- `security-groups.tf` – Creates security groups for worker nodes.
- `ekscluster.tf` – Provisions an EKS cluster and managed node group using the EKS module.
- `outputs.tf` – Outputs useful information (cluster endpoint, cluster name, etc.).
- `deployment.yaml` – Kubernetes Deployment manifest for your application.
- `service.yaml` – Kubernetes Service manifest to expose your application via a LoadBalancer.

# Setup and Deployment Steps 

### 1. Clone the Repo

```git clone <https://github.com/abaig32/terraform-project-portfolio.git>```

```cd "Kubernetes Cluster Deployment" ```

### 2. Initialize, Plan, and Apply Terraform Infrastructure (CLI Instructions)

```terraform init --upgrade```

```terraform plan -out=tfplan```

```terraform apply "tfplan"```

### 3. Update KubeConfig (CLI Instructions)

```aws eks update-kubeconfig --name todolist-cluster --region us-east-1```

### 4. Create Access Entry from AWS Console

Enter your AWS Management Console and navigate to the Elastic Kubernetes Services page

Click on your cluster under the name "todolist-cluster"

Navigate to the "access" tab and create an access entry for your iam user with the following roles: 

AmazonEKSAdminPolicy, AmazonEKSClusterAdminPolicy

This will give you permissions to interact with the cluster 

### 5. Validate Cluster

Use this command to see your pods and clusters respectively to make sure they are running and healthy 

```kubectl get pods```

```kubectl get nodes```

### 6. Apply deployment.yaml (CLI Instructions)

This allows your worker nodes to pull the image from ECR 

```kubectl apply -f deployment.yaml```

### 7. Apply service.yaml and get external-ip (CLI Instructions)

This exposes your cluster to a load balancer so you can access the site 

```kubectl apply -f service.yaml```

This command allows you to see the external-ip of your load balancer so you can connect to the cluster. Make sure to give it a few minutes before entering the ip into your web browser. 

```kubectl get svc todolist-app-service```

### 8. Connect to the Cluster 

Lastly, use the external-ip from the previous command and enter it into your web browser

You should see the to-do list app! 