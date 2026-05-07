pipeline {
    agent any
    
    environment {
        // The base URL for your AWS ECR
        ECR_REGISTRY = "719484290237.dkr.ecr.eu-west-3.amazonaws.com"
        
        // This MUST match the name you see in the AWS ECR Console
        ECR_REPO_NAME = "my-project" 
        
        // This MUST match the 'metadata: name:' inside your k8s/deployment.yaml
        K8S_DEPLOY_NAME = "demo-app"
        
        REGION       = "eu-west-3"
        CLUSTER_NAME = "demo-cluster"
        AWS_CRED     = "aws-credentials-id" 
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
                    // Using ECR_REPO_NAME to tag the image correctly for AWS
                    sh "docker build -t ${ECR_REGISTRY}/${ECR_REPO_NAME}:${BUILD_NUMBER} ."
                    sh "docker tag ${ECR_REGISTRY}/${ECR_REPO_NAME}:${BUILD_NUMBER} ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest"
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CRED}"]]) {
                    script {
                        sh "aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                        
                        // Pushing to the 'my-project' repository
                        sh "docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:${BUILD_NUMBER}"
                        sh "docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CRED}"]]) {
                    // Update kubeconfig
                    sh "aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}"
                    
                    // Apply manifests from the k8s folder
                    sh "kubectl apply -f k8s/"
                    
                    // Restarting the 'demo-app' deployment to pull the new image
                    sh "kubectl rollout restart deployment/${K8S_DEPLOY_NAME}"
                }
            }
        }
    }

    post {
        always {
            // Clean up credentials on the agent
            sh "docker logout ${ECR_REGISTRY} || true"
        }
    }
}
