Here’s a `README.md` template for your Docker container deployment project that explains the setup and deployment process clearly. You can customize it as needed.

---

# Docker Container Deployment for Sample Application

This project automates the deployment of a sample application using Docker and an infrastructure automation tool. The steps below include creating a simple Node.js application, containerizing it with Docker, and deploying it to an Azure VM using Terraform.

## Table of Contents
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Step 1: Set Up the Sample Application](#step-1-set-up-the-sample-application)
- [Step 2: Write the Dockerfile](#step-2-write-the-dockerfile)
- [Step 3: Build and Push Docker Image (Optional)](#step-3-build-and-push-docker-image-optional)
- [Step 4: Deploy the Docker Container using Terraform](#step-4-deploy-the-docker-container-using-terraform)
- [License](#license)

---

## Project Structure

```
sample-app/
├── app.js                # Simple Node.js application code
├── package.json          # Node.js dependencies
├── Dockerfile            # Dockerfile to containerize the application
├── main.tf               # Terraform configuration file for deployment
└── README.md             # Project README file
```

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed and configured
- [Terraform](https://www.terraform.io/downloads.html) installed
- Azure account and access to an Azure Virtual Machine
- (Optional) [Docker Hub account](https://hub.docker.com/) for pushing the Docker image

---

## Step 1: Set Up the Sample Application

The sample application is a simple Node.js server.

1. **Navigate to the project directory**:
   ```bash
   cd sample-app
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Run the application locally**:
   ```bash
   node app.js
   ```
   The application should be accessible at `http://localhost:3000`.

## Step 2: Write the Dockerfile

The Dockerfile provides instructions for containerizing the Node.js application.

```Dockerfile
# Dockerfile

# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```

## Step 3: Build and Push Docker Image (Optional)

1. **Build the Docker image**:
   ```bash
   docker build -t sample-app .
   ```

2. **Test the Docker container locally**:
   ```bash
   docker run -p 3000:3000 sample-app
   ```

3. **Push to Docker Hub (Optional)**:
   If you want to use Docker Hub for hosting the image:

   - Log in to Docker Hub:
     ```bash
     docker login
     ```

   - Tag the image:
     ```bash
     docker tag sample-app <dockerhub-username>/sample-app:latest
     ```

   - Push the image:
     ```bash
     docker push <dockerhub-username>/sample-app:latest
     ```

## Step 4: Deploy the Docker Container using Terraform

Use Terraform to provision a virtual machine on Azure and automate Docker container deployment.

1. **Configure Terraform** (`main.tf`):
   Here’s an example Terraform configuration for deploying the Docker container on an Azure VM.

   ```hcl
   provider "azurerm" {
     features {}
   }

   variable "location" {
     default = "West Europe"
   }

   resource "azurerm_virtual_machine" "vm" {
     # VM configurations here
   }

   resource "null_resource" "docker_deploy" {
     depends_on = [azurerm_virtual_machine.vm]

     provisioner "remote-exec" {
       connection {
         type     = "ssh"
         host     = azurerm_virtual_machine.vm.public_ip_address
         user     = "azureuser"
         private_key = file("~/.ssh/id_rsa")
       }

       inline = [
         "sudo apt-get update",
         "sudo apt-get install -y docker.io",
         "sudo systemctl start docker",
         "sudo systemctl enable docker",
         "sudo docker pull <dockerhub-username>/sample-app:latest",
         "sudo docker run -d -p 3000:3000 <dockerhub-username>/sample-app:latest"
       ]
     }
   }
   ```

   Replace `<dockerhub-username>` with your Docker Hub username if you are pulling the image from Docker Hub.

2. **Apply the Terraform configuration**:
   ```bash
   terraform init
   terraform apply
   ```

3. **Access the application**:
   After deployment, check the public IP of the Azure VM and access the app at `http://<public-ip>:3000`.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

This README covers each step to deploy the Docker containerized sample application on an Azure VM. Let me know if you need further customization for any section!