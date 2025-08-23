# 🚀 Incident Management Service (Spring Boot)

A Spring Boot project that provides CRUD APIs for managing incidents, useful for DevOps & SRE teams.

## Features
- Create, Update, Delete incidents
- Track severity (LOW, MEDIUM, HIGH)
- Track status (OPEN, IN_PROGRESS, RESOLVED)
- REST API with JSON responses
- In-memory H2 database for testing
- Actuator endpoints for DevOps monitoring

## Run Locally and access the application. 
mvn spring-boot:run

Endpoints
- `POST /api/incidents` → Create incident
  URL: http://localhost:8080/api/incidents
  Body → raw → JSON:
{
  "title": "Database down",
  "severity": "HIGH",
  "status": "OPEN",
  "assignedTo": "DevOps Engineer"
}
 <img width="1433" height="929" alt="image" src="https://github.com/user-attachments/assets/6464c136-6bf1-41e9-b8e8-d68d3917323b" />

- `GET /api/incidents` → List all
   URL: http://localhost:8080/api/incidents
  <img width="1384" height="881" alt="image" src="https://github.com/user-attachments/assets/bf71dc40-88c0-4047-af6f-595271adca83" />

- `GET /api/incidents/{id}` → Get one
URL: http://localhost:8080/api/incidents/1
  <img width="1408" height="919" alt="image" src="https://github.com/user-attachments/assets/fba753f5-137c-4087-a967-daf9350d36d3" />

- `PUT /api/incidents/{id}` → Update
   URL: http://localhost:8080/api/incidents/1
   Body → JSON:
   {
  "title": "Database down",
  "severity": "HIGH",
  "status": "RESOLVED",
  "assignedTo": "DevOps Engineer"
}
  <img width="1424" height="945" alt="image" src="https://github.com/user-attachments/assets/7ec92c84-7cd5-4436-b51e-4d5fb9933d4c" />

- `DELETE /api/incidents/{id}` → Delete
   URL: http://localhost:8080/api/incidents/1
  <img width="1348" height="915" alt="image" src="https://github.com/user-attachments/assets/f4d28477-fb3a-4122-be34-662bd4746bbb" />

  
## Create AWS Infrastructure with Terraform
•Created a VPC with 2 public subnets (ap-south-1a & ap-south-1b).
•Attached an Internet Gateway (IGW).
•Created Route Table with route to IGW.
<img width="1897" height="820" alt="image" src="https://github.com/user-attachments/assets/33b12efb-2109-4ebe-ba67-dfb898e56620" />

•Launched an EC2 Instance (Ubuntu 22.04) in public subnet.

terraform init
terraform plan
terraform apply -auto-approve

2.Connect to EC2 Instance
ssh -i ec2linux.pem ubuntu@<EC2-Public-IP>

3.Install Docker on EC2
sudo apt update -y
sudo apt install docker.io -y sudo systemctl start docker sudo systemctl enable docker sudo usermod -aG docker ubuntu
# Logout & login again to apply docker group changes.

Note: Refer https://github.com/Tini-j-Mercy/cloudops-dashboard-terraform for tf scripts and infra provisioning using terraform. 

## Dockerize the created application 
Step 1: Create Dockerfile and build it 
In your project root, create a Dockerfile:
Run this inside your project directory:
docker build -t myapp:latest .
myapp:latest → local image name.
<img width="1878" height="366" alt="image" src="https://github.com/user-attachments/assets/8ca70dc0-8ce1-4030-9d26-03c369369ac2" />
docker images  -- to list the available images.

Step 2: Run the Container
docker run -d -p 8080:8080 --name myapp-container myapp:latest
-d → detached mode
-p 8080:8080 → maps container port 8080 to host port 8080
Check if running:
docker ps
<img width="1911" height="976" alt="image" src="https://github.com/user-attachments/assets/69daf146-77b2-4b3c-b58a-37a9c81f69f0" />

Step 3: Access in browser or Postman:
👉 http://localhost:8080
<img width="1384" height="881" alt="image" src="https://github.com/user-attachments/assets/bf71dc40-88c0-4047-af6f-595271adca83" />


## Login to Docker Hub
Step 1: docker login
Enter your Docker Hub username and password.

Step 2: Tag the Image for Docker Hub
docker tag myapp:latest yourdockerhubusername/myapp:latest

Step 3: Push the Image to Docker Hub
docker push yourdockerhubusername/myapp:latest
Now the image is available in Docker Hub.

## Deploy Dockerized App on EC2 
Step 1: Connect to EC2
From your local machine:
ssh -i terraform-key2.pem ec2-user@<ec2-public-ip>

Step 2: Login to Docker Hub (inside EC2)
docker login
Enter Docker Hub username & password (or access token if enabled).

Step 3: Pull Image from Docker Hub
docker pull yourdockerhubusername/myapp:latest

Step 4: Run Container on EC2
docker run -d -p 8080:8080 --name myapp-container yourdockerhubusername/myapp:latest

Step 6: Allow Traffic via Security Group
When you created EC2 with Terraform, check its Security Group:
Add inbound rule:
Port 8080 → Source = 0.0.0.0/0 (or your IP for security).

Step 7: Access Application
Now you can hit the application in browser/Postman:
http://<ec2-public-ip>:8080
<img width="1250" height="875" alt="image" src="https://github.com/user-attachments/assets/83297360-e49f-4f12-97db-2ad2ad78df9d" />

####    CREATE ALB and access the application using dns   ###

Step 1: Security Group Setup

Go to EC2 → Security Groups.

Create 2 SGs:

ALB-SG → allow inbound HTTP (80) from 0.0.0.0/0 (internet).

EC2-SG → allow inbound 8080 only from ALB-SG (not the internet).

Attach EC2-SG to your VM instance.
<img width="1886" height="869" alt="image" src="https://github.com/user-attachments/assets/d037a342-c68d-49d6-8ff1-17127d71ac98" />

Step 2 : Create Target Group
Type: Instance (since you’re directly pointing to EC2).
Protocol: HTTP
Port: 8080
Health check path: /actuator/health
Register Target :   Add your EC2 instance to the Target Group.
<img width="1529" height="478" alt="image" src="https://github.com/user-attachments/assets/9dee819f-578a-4c3e-8cdb-267312c87914" />

Step 3:  Create Application Load Balancer (ALB)
Type: Internet-facing
Listeners:
HTTP :80 → Forward to Target Group
Choose subnets (public subnets across at least 2 AZs).
Attach SG that allows port 80.
<img width="1884" height="807" alt="image" src="https://github.com/user-attachments/assets/6c4150bf-25ed-4fff-82d9-14f1bd3e37e3" />

Step 4: Access Application
Now you can hit the application in browser/Postman:
http://<dns-name>/api/incidents
















