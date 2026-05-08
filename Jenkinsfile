pipeline {
    agent any
    
    environment {
        ECR_REGISTRY  = "719484290237.dkr.ecr.eu-west-3.amazonaws.com"
        ECR_REPO_NAME = "my-project" 
        K8S_DEPLOY_NAME = "demo-app"
        REGION        = "eu-west-3"
        CLUSTER_NAME  = "demo-cluster"
        AWS_CRED      = "aws-credentials-id" 
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
                        sh "docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:${BUILD_NUMBER}"
                        sh "docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CRED}"]]) {
                    sh "aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}"
                    // Inject the exact build number into the manifest before applying
                    sh "sed -i 's|:latest|:${BUILD_NUMBER}|g' k8s/deployment.yaml"
                    sh "kubectl apply -f k8s/"
                    // Wait and confirm rollout succeeded
                    sh "kubectl rollout status deployment/${K8S_DEPLOY_NAME} --timeout=120s"
                }
            }
        }
    }

    post {
        always {
            sh "docker logout ${ECR_REGISTRY} || true"
        }
        success {
            echo "✅ Build ${BUILD_NUMBER} deployed successfully!"
        }
        failure {
            echo "❌ Build ${BUILD_NUMBER} failed!"
        }
    }
}
