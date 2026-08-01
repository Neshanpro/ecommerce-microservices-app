# 🚀 E-Commerce Microservices Platform (AWS EKS & GitOps)
### *Production-Grade Containerization, Infrastructure as Code, and Automated Delivery*

[![AWS EKS](https://img.shields.io/badge/AWS-EKS_v1.31-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform_1.0+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Docker](https://img.shields.io/badge/Container-Distroless-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

---

## 📖 Table of Contents
- [Overview](#-overview)
- [Architecture Topology](#-architecture-topology)
- [Tech Stack](#-tech-stack)
- [Key Technical Features](#-key-technical-features)
  - [Container Optimization](#container-optimization)
  - [Infrastructure as Code (IaC)](#infrastructure-as-code-iac)
  - [Security Hardening](#security-hardening)
  - [GitOps Pipeline](#gitops-pipeline)
  - [Observability](#observability)
- [Project Directory Structure](#-project-directory-structure)
- [Deployment Guide](#-deployment-guide)
  - [Prerequisites](#prerequisites)
  - [1. Infrastructure Provisioning](#1-infrastructure-provisioning)
  - [2. Microservices Deployment](#2-microservices-deployment)
  - [3. GitOps & Monitoring Setup](#3-gitops--monitoring-setup)
- [Teardown & Resource Cleanup](#-teardown--resource-cleanup)
- [Operations & Monitoring](#-operations--monitoring)
- [Cost & Resource Breakdown](#-cost--resource-breakdown)
- [Troubleshooting & Resolved Issues](#-troubleshooting--resolved-issues)

---

## 📌 Overview
This repository contains a cloud-native microservices platform built using components extracted from the **OpenTelemetry Astronomy Shop** demo. The platform is deployed to **AWS EKS** using **Distroless multi-stage builds**, **modular Terraform IaC**, **declarative GitOps with ArgoCD**, and full observability via **Prometheus & Grafana**.

```text
                           ┌──────────────────┐
                           │   Checkout (Go)  │ ──► Port: 5050
                           └────────┬─────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
       ┌────────────────────────┐      ┌────────────────────────┐
       │   Payment (Node.js)    │      │ Recommend (Python)     │
       │   Port: 50051          │      │ Port: 9001             │
       └────────────────────────┘      └────────────────────────┘
```

* **Checkout Service (`Go`)**: Handles transaction orchestration and order processing.
* **Payment Service (`Node.js`)**: Handles payment authorization logic.
* **Recommendation Service (`Python`)**: Provides real-time item recommendations.

---

## 🏗️ Architecture Topology

```text
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    INTERNET                                     │
└───────────────────────────────────────┬─────────────────────────────────────────┘
                                        │
┌───────────────────────────────────────▼─────────────────────────────────────────┐
│                             AWS Region (eu-west-1)                              │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                            VPC (10.0.0.0/16)                              │  │
│  │  ┌───────────────────────────────┐     ┌───────────────────────────────┐  │  │
│  │  │  Public Subnet A (10.0.1.0/24) │     │  Public Subnet B (10.0.2.0/24) │  │  │
│  │  └──────────────┬────────────────┘     └──────────────┬────────────────┘  │  │
│  │                 │ NAT Gateway                         │ NAT Gateway       │  │
│  │  ┌──────────────▼────────────────┐     ┌──────────────▼────────────────┐  │  │
│  │  │ Private Subnet A (10.0.10.0/24)│     │ Private Subnet B (10.0.11.0/24)│  │  │
│  │  └───────────────────────────────┘     └───────────────────────────────┘  │  │
│  │                                                                           │  │
│  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                      AWS EKS Cluster (v1.31)                        │  │  │
│  │  │                                                                     │  │  │
│  │  │  ┌───────────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │ Node Group: 2x m7i-flex.large (Spot Instances)                │  │  │  │
│  │  │  └──────────────────────────────┬────────────────────────────────┘  │  │  │
│  │  │                                 │                                   │  │  │
│  │  │  ┌──────────────────────────────▼────────────────────────────────┐  │  │  │
│  │  │  │ Namespace: ecommerce                                          │  │  │  │
│  │  │  │  ┌──────────────────┐ ┌──────────────────┐ ┌────────────────┐  │  │  │
│  │  │  │  │  Checkout (Go)   │ │ Payment (NodeJS) │ │ Recommend (Py) │  │  │  │
│  │  │  │  │  2 Replicas      │ │ 2 Replicas       │ │ 2 Replicas     │  │  │  │
│  │  │  │  └──────────────────┘ └──────────────────┘ └────────────────┘  │  │  │
│  │  │  └───────────────────────────────────────────────────────────────┘  │  │  │
│  │  │                                                                     │  │  │
│  │  │  ┌───────────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │ GitOps: ArgoCD (Auto-sync with Repository)                    │  │  │  │
│  │  │  ├───────────────────────────────────────────────────────────────┤  │  │  │
│  │  │  │ Monitoring: Prometheus Operator + Grafana                     │  │  │  │
│  │  │  └───────────────────────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │ State Backend: AWS S3 Bucket + DynamoDB Table (Terraform State Lock)       │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Category | Technology | Usage Details |
| :--- | :--- | :--- |
| **Infrastructure as Code** | **Terraform `v1.0+`** | Modular VPC, EKS, and IAM provisioning with S3/DynamoDB remote state |
| **Containerization** | **Docker** | Multi-stage distroless base images |
| **Orchestration** | **AWS EKS `v1.31`** | Kubernetes cluster running managed Spot instances |
| **Continuous Delivery** | **ArgoCD** | Declarative GitOps deployment and automated drift correction |
| **Observability** | **Prometheus & Grafana** | `kube-prometheus-stack` Helm chart |
| **Runtimes** | **Go, Node.js, Python** | Go 1.22, Node.js 20, Python 3.12 |

---

## 📝 Key Technical Features

### Container Optimization
All application images are built using multi-stage compilation and Google Distroless runtime bases to eliminate unnecessary shells and system utilities.

| Microservice | Runtime | Standard Base Size | Distroless Optimized Size | Reduction |
| :--- | :--- | :--- | :--- | :--- |
| **Checkout** | Go | 1.34 GB | **37.2 MB** | **97.2% ⬇️** |
| **Payment** | Node.js | 1.71 GB | **265.0 MB** | **84.5% ⬇️** |
| **Recommendation**| Python | 276.0 MB | **238.0 MB** | **13.8% ⬇️** |

---
<img width="1762" height="46" alt="Screenshot 2026-07-29 044641" src="https://github.com/user-attachments/assets/be0f5c95-ded2-4482-96fc-7175ab6eabf4" />
<img width="1797" height="42" alt="Screenshot 2026-07-29 041845" src="https://github.com/user-attachments/assets/aa0cf688-5c37-472e-8f3c-24c8c38e5e0e" />
<img width="1721" height="85" alt="Screenshot 2026-07-29 040049" src="https://github.com/user-attachments/assets/fba9f321-da0a-41d8-b1cc-8cfed66c421f" />

---

### Infrastructure as Code (IaC)
Modular Terraform configurations manage all underlying AWS resources:
* **Remote Backend**: S3 state bucket paired with DynamoDB state locking.
* **Network Topology**: Multi-AZ VPC configured with 2 public subnets, 2 private subnets, and isolated NAT Gateways.
* **Access Management**: IAM Roles for Service Accounts (IRSA) via OIDC provider.
---

### Security Hardening
Kubernetes deployments apply strict security context parameters at both pod and container levels:
* **Non-Root Context**: Enforced execution under non-root user IDs (`65532` / `10001`).
* **ReadOnly Filesystem**: Root filesystem set to read-only (`readOnlyRootFilesystem: true`).
* **Privilege Elevation**: `allowPrivilegeEscalation: false`.
* **Capabilities Drop**: Dropped all Linux capabilities (`capabilities.drop: ["ALL"]`).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout
  namespace: ecommerce
spec:
  replicas: 2
  template:
    spec:
      serviceAccountName: checkout
      containers:
      - name: checkout
        image: neshandoc/checkout:optimized
        securityContext:
          runAsNonRoot: true
          runAsUser: 65532
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
```

---

### GitOps Pipeline
ArgoCD manages application deployment state continuously from the Git repository.
* **Automatic Sync**: Deployment manifests update upon changes to `main`.
* **Self-Healing**: Out-of-band changes applied manually to the cluster are automatically reconciled back to the Git state.

---

### Observability
Metrics are scraped through Custom Resource Definitions (`ServiceMonitor`) configured to target application ports and exported to Grafana dashboards.

---

## 🔧 Project Directory Structure

```text
ecommerce-microservices-app/
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # Image Build and Continuous Delivery Workflow
├── terraform/
│   ├── remote-backend/           # S3 Bucket and DynamoDB Lock Initialization
│   ├── modules/
│   │   ├── vpc/                  # Multi-AZ VPC Topology
│   │   ├── iam/                  # IAM and OIDC Roles
│   │   └── eks/                  # EKS Control Plane and Spot Node Groups
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
├── kubernetes/
│   ├── namespace.yaml            # Environment Isolation
│   ├── checkout-deployment.yaml  # Go Microservice Manifest
│   ├── payment-deployment.yaml   # NodeJS Microservice Manifest
│   ├── recommendation-deployment.yaml # Python Microservice Manifest
│   └── servicemonitor.yaml       # Prometheus Scrape Targets
├── services/
│   ├── checkout/                 # Source Code and Dockerfile
│   ├── payment/                  # Source Code and Dockerfile
│   └── recommendation/           # Source Code and Dockerfile
├── argocd/
│   └── application.yaml          # ArgoCD App Manifest
└── README.md
```

---

## 🚀 Deployment Guide

### Prerequisites
* **AWS CLI** authenticated with administrative permissions.
* **Terraform** `v1.0+`
* **kubectl** configured locally (`v1.31`)
* **Helm** `v3.0+`
* **Docker Engine**

---

### 1. Infrastructure Provisioning

```bash
# Clone the repository
git clone [https://github.com/Neshanpro/ecommerce-microservices-app.git](https://github.com/Neshanpro/ecommerce-microservices-app.git)
cd ecommerce-microservices-app

# Provision Remote Backend for Terraform (Run once)
cd terraform/remote-backend
terraform init && terraform apply -auto-approve
cd ..

# Provision AWS VPC, IAM, and EKS Cluster
cd terraform/
terraform init
terraform plan
terraform apply -auto-approve
```
<img width="948" height="215" alt="Screenshot 2026-08-01 024628" src="https://github.com/user-attachments/assets/339da130-1703-475e-b311-0cecfdb18f17" />

---

### 2. Microservices Deployment

```bash
# Update kubeconfig context
aws eks update-kubeconfig --region eu-west-1 --name ecommerce-eks

# Deploy applications
kubectl create namespace ecommerce
kubectl apply -f kubernetes/

# Verify status
kubectl get pods -n ecommerce --watch
```
<img width="1883" height="184" alt="Screenshot 2026-07-30 220427" src="https://github.com/user-attachments/assets/29735dbb-9353-49d7-9aff-86403eda8265" />
<img width="1866" height="138" alt="Screenshot 2026-07-30 220825" src="https://github.com/user-attachments/assets/f3a157c1-f6cc-4fa9-abed-c598de28a16a" />
<img width="1473" height="53" alt="Screenshot 2026-07-31 012712" src="https://github.com/user-attachments/assets/139a5cff-ade7-4223-a01b-bfb93311af72" />

---

### 3. GitOps & Monitoring Setup

```bash
# Deploy ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Fetch ArgoCD Admin Password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Register GitOps Application
kubectl apply -f argocd/application.yaml

# Deploy Prometheus and Grafana via Helm
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
    -n monitoring --create-namespace \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

# Expose Grafana UI and get Admin Password
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo
```
<img width="1893" height="185" alt="Screenshot 2026-08-01 011100" src="https://github.com/user-attachments/assets/b94a6494-d1d9-46e7-95ca-9e7582a409c6" />
<img width="1919" height="874" alt="Screenshot 2026-08-01 013538" src="https://github.com/user-attachments/assets/72019fe5-5937-4f62-9d21-06946dd0f8ff" />
<img width="1437" height="450" alt="Screenshot 2026-07-31 153000" src="https://github.com/user-attachments/assets/0dca504e-88de-47a7-a355-45a9829ae909" />
<img width="1880" height="53" alt="Screenshot 2026-08-01 005642" src="https://github.com/user-attachments/assets/e17830e8-7b23-4055-a93d-0dc8382f09be" />
<img width="1908" height="873" alt="Screenshot 2026-08-01 010123" src="https://github.com/user-attachments/assets/f6fd44ec-94ac-4d11-8c0e-69ccbfcbe67b" />
<img width="1919" height="872" alt="Screenshot 2026-08-01 010301" src="https://github.com/user-attachments/assets/112e42d0-ad89-404c-87e0-478a9bb3e9e2" />
<img width="1919" height="873" alt="Screenshot 2026-08-01 010229" src="https://github.com/user-attachments/assets/bed0e363-88cf-4f3b-be69-fcdd2493fdea" />
<img width="1919" height="858" alt="Screenshot 2026-08-01 015850" src="https://github.com/user-attachments/assets/6c9cc073-5997-4e14-a437-30737d9a9852" />

---

## 🧹 Teardown & Resource Cleanup

To avoid unnecessary costs, follow this sequence to tear down all provisioned resources:

```bash
# 1. Delete Kubernetes Applications & Helm Releases
helm uninstall prometheus -n monitoring
kubectl delete -f argocd/application.yaml
kubectl delete -f kubernetes/
kubectl delete namespace ecommerce argocd monitoring

# 2. Wait for Cloud LoadBalancers to clean up (Prevents VPC deletion blockage)
sleep 60

# 3. Destroy Terraform Provisioned Infrastructure
cd terraform/
terraform destroy -auto-approve

# 4. (Optional) Destroy Remote Backend Storage
cd remote-backend/
terraform destroy -auto-approve
```

---

## 📊 Operations & Monitoring

### Service Endpoints
| Component | Protocol | Endpoint | Access / Auth |
| :--- | :--- | :--- | :--- |
| **ArgoCD UI** | `HTTPS` | `<LoadBalancer-External-IP>` | User: `admin` |
| **Grafana UI** | `HTTP` | `<LoadBalancer-External-IP>:80` | User: `admin` |
| **Prometheus** | `HTTP` | `kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090` | Internal Port Forward |

### Essential PromQL Telemetry Queries
```promql
# Track Active Microservice Pods
kube_pod_info{namespace="ecommerce"}

# Track Container Readiness Status
kube_pod_status_ready{namespace="ecommerce"}

# Aggregate CPU Usage Rate
sum(rate(container_cpu_usage_seconds_total{namespace="ecommerce"}[5m])) by (pod)

# Memory Utilization per Pod
sum(container_memory_working_set_bytes{namespace="ecommerce"}) by (pod)
```

---

## 💰 Cost & Resource Breakdown

| Resource Type | Specification | Monthly Runtime Cost (24/7 Baseline) |
| :--- | :--- | :--- |
| **EKS Control Plane** | AWS Managed EKS Cluster | $73.00 |
| **EC2 Worker Nodes** | 2x `m7i-flex.large` (Spot Pricing) | ~$20.00 |
| **NAT Gateways** | 2x NAT Gateways | ~$16.00 |
| **Storage & Data Egress** | EBS Volumes & Network Data | ~$7.00 |
| **Total Estimated Cost** | | **~$116.00 / month** |

---

## 🛠️ Troubleshooting & Resolved Issues

| Issue Observed | Root Cause | Fix Applied |
| :--- | :--- | :--- |
| `ImagePullBackOff` | Container pull failures on private image paths | Migrated images to public container registry |
| OpenTelemetry Warnings | Unreachable telemetry collector endpoint | Set `OTEL_SDK_DISABLED=true` in environment variables |
| ALB Controller Permission Error | Missing IAM OIDC Policy mapping | Attached IRSA policy directly to controller ServiceAccount |
| Metadata Service Timeout | IMDSv2 restriction blocking pod metadata queries | Updated `http_put_response_hop_limit = 2` on Node Group configuration |
