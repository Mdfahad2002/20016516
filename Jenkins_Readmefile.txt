Here's a sample README file for your Jenkins pipeline that you can use for your GitHub repository.

---

# Jenkins CI/CD Pipeline for Azure VM Deployment

This repository contains a Jenkins pipeline script to build, push, and deploy a Dockerized application to an Azure Virtual Machine (VM). The pipeline automates the steps from cloning the source code to deploying the Docker container on an Azure VM.

## Prerequisites

1. **Azure Account and Service Principal:** 
   - Set up a Service Principal on Azure and note the following:
     - `AZURE_SUBSCRIPTION_ID`
     - `AZURE_CLIENT_ID`
     - `AZURE_CLIENT_SECRET`
     - `AZURE_TENANT_ID`

2. **Jenkins Setup:**
   - Jenkins should have the following plugins installed:
     - Docker Pipeline Plugin
     - Azure CLI Plugin
   - Configure Jenkins credentials:
     - `azure-sp-password`: The Azure Service Principal secret.
     - `azure-ssh-key`: The private SSH key for accessing the Azure VM.

3. **Docker Image & Azure VM:** 
   - An Azure VM should be set up with Docker installed, and its SSH key configured for access.
   - Ensure a container registry is set up (Docker Hub, Azure Container Registry, etc.) for pushing the Docker image.

## Pipeline Stages

The pipeline has the following stages:

1. **Clone Repository**: Clones the source code from the specified GitHub repository.
   
2. **Build Docker Image**: Builds a Docker image from the application source and tags it.
   
3. **Push Docker Image**: Pushes the Docker image to a container registry.
   
4. **Deploy to Azure VM**: 
   - Authenticates with Azure.
   - Retrieves the Azure VM’s public IP.
   - SSHs into the VM to pull and run the Docker container.

## Pipeline Script

The `Jenkinsfile` pipeline script:

```groovy
pipeline {
    agent any
    environment {
        AZURE_SUBSCRIPTION_ID = '<AZURE_SUBSCRIPTION_ID>'
        AZURE_CLIENT_ID = '<AZURE_CLIENT_ID>'
        AZURE_CLIENT_SECRET = '<AZURE_CLIENT_SECRET>'
        AZURE_TENANT_ID = '<AZURE_TENANT_ID>'
        RESOURCE_GROUP_NAME = 'example-resources'
        VM_NAME = 'example-vm'
        IMAGE_NAME = '<IMAGE_NAME>'
        PUBLIC_IP = '<PUBLIC_IP>'
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/mouzamali123/node-web-app'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME} ./node-js"
                    sh "docker tag ${IMAGE_NAME}:latest ${PUBLIC_IP}:latest"
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${PUBLIC_IP}:latest"
                }
            }
        }
        stage('Deploy to Azure VM') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'azure-sp-password', variable: 'AZURE_CREDENTIALS')]) {
                        sh '''
                        az login --service-principal -u ${AZURE_CLIENT_ID} -p ${AZURE_CLIENT_SECRET} --tenant ${AZURE_TENANT_ID}
                        az vm list-ip-addresses --name ${VM_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv > public_ip.txt
                        PUBLIC_IP=$(cat public_ip.txt)
                        echo "VM Public IP: $PUBLIC_IP"
                        '''
                    }
                    withCredentials([sshUserPrivateKey(credentialsId: 'azure-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${PUBLIC_IP} <<EOF
                            docker pull ${PUBLIC_IP}:latest
                            docker stop ${IMAGE_NAME} || true
                            docker rm ${IMAGE_NAME} || true
                            docker run -d --name ${IMAGE_NAME} -p 3000:3000 ${PUBLIC_IP}:latest
EOF
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Cleaning up resources...'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

## Usage

1. **Configure Jenkins with the required environment variables and credentials** listed in the `Jenkinsfile`.
2. **Run the pipeline** on Jenkins.
3. Monitor the console output to verify each stage completes as expected.

## Notes

- Adjust the container registry and image names as per your requirements.
- Ensure SSH access to the Azure VM is configured correctly.
- Modify the VM's firewall rules if needed to expose the application.

---

This README provides an overview of the pipeline setup and should guide any users in configuring and running the Jenkins pipeline successfully.