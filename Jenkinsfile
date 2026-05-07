pipeline {
    agent any
    
    environment {
        // Replace with your actual ECR URI (from the ECR console)
        ECR_REGISTRY = "719484290237.dkr.ecr.eu-west-3.amazonaws.com"
        APP_NAME     = "my-project" // The name you gave your ECR repo
        REGION       = "eu-west-3"
        CLUSTER_NAME = "demo-cluster"
        AWS_CRED     = "aws-credentials-id" // The ID you set in Jenkins Credentials
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} ."
                    sh "docker tag ${ECR_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} ${ECR_REGISTRY}/${APP_NAME}:latest"
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CRED}"]]) {
                    sh "aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    sh "docker push ${ECR_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/${APP_NAME}:latest"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CRED}"]]) {
                    // Update kubeconfig so kubectl knows how to talk to your EKS cluster
                    sh "aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}"
                    
                    // Apply your Kubernetes manifests
                    // This assumes you have a folder named 'k8s' with your deployment files
                    sh "kubectl apply -f k8s/"
                    
                    // Optional: Force a rollout restart to pull the 'latest' image
                    sh "kubectl rollout restart deployment/${APP_NAME}"
                }
            }
        }
    }

    post {
        always {
            sh "docker logout ${ECR_REGISTRY}"
        }
    }
}
