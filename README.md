# Jenkins + AWS ECR + EKS CI/CD Demo

A small, end-to-end DevOps practice project that builds a Docker image with Jenkins, pushes it to Amazon ECR, and deploys it to an Amazon EKS cluster using Kubernetes manifests. The application is a simple Nginx container that serves a static HTML page.

## 🌟 Highlights

- **CI/CD with Jenkins** using a declarative pipeline
- **Docker image build & tag** with build number and `latest`
- **Push to Amazon ECR** with AWS credentials binding
- **Deploy to Amazon EKS** using `kubectl apply`
- **Rolling updates** and rollout status verification

## 🧩 Project Architecture

1. **Jenkins** checks out the source code
2. Builds the Docker image from the `Dockerfile`
3. Pushes the image to **Amazon ECR**
4. Updates the Kubernetes deployment image tag
5. Applies manifests to **Amazon EKS** and waits for rollout

## 📁 Repository Structure

```
.
├── Dockerfile
├── Jenkinsfile
└── k8s/
    └── deployment.yaml
```

## ✅ Prerequisites

Make sure you have the following set up before running the pipeline:

- **Jenkins** with the following plugins:
  - Pipeline
  - AWS Credentials
  - Docker Pipeline (optional but recommended)
- **AWS Account** with:
  - An existing **ECR repository**
  - An **EKS cluster**
- **Jenkins credentials**:
  - AWS credentials stored in Jenkins (ID must match `AWS_CRED`)
- **kubectl**, **aws-cli**, and **docker** installed on the Jenkins agent

## ⚙️ Configuration

The pipeline configuration is defined in `Jenkinsfile`.
Update the following variables to match your environment:

- `ECR_REGISTRY`
- `ECR_REPO_NAME`
- `K8S_DEPLOY_NAME`
- `REGION`
- `CLUSTER_NAME`
- `AWS_CRED`

The Kubernetes deployment manifest is in `k8s/deployment.yaml` and expects the image tag to be updated by the pipeline.

## 🚀 Pipeline Stages (Overview)

- **Checkout** – pulls the repository
- **Build Docker Image** – builds and tags the image
- **Push to ECR** – authenticates and pushes image tags
- **Deploy to EKS** – updates kubeconfig, applies manifests, and checks rollout

## 🧪 Local Test (Optional)

You can test the container locally with Docker:

```bash
docker build -t demo-app:local .
docker run -p 8080:80 demo-app:local
```

Then open: `http://localhost:8080`

## 🧹 Cleanup (Optional)

- Delete the Kubernetes deployment and related resources
- Remove ECR images you no longer need
- Remove local Docker images

## 📌 Notes

- The pipeline replaces the image tag in `k8s/deployment.yaml` using `sed` with the Jenkins build number.
- This repo is intentionally minimal to focus on CI/CD flow and AWS + Kubernetes integration.

## 👤 Author

Built as a learning project by a 1337 coding school student, inspired by Nana’s Tech World DevOps bootcamp.

---

If you have feedback or suggestions, feel free to open an issue or reach out!
