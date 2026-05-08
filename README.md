# AWS EKS Platform — Production-Grade Kubernetes Lab on AWS

[![AWS](https://img.shields.io/badge/AWS-EKS%201.34-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/eks/)
[![Terraform](https://img.shields.io/badge/Terraform-1.9%2B-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Helm](https://img.shields.io/badge/Helm-3.x-0F1689?logo=helm&logoColor=white)](https://helm.sh)
[![Jenkins](https://img.shields.io/badge/Jenkins-LTS%202.541-D24939?logo=jenkins&logoColor=white)](https://jenkins.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Bitnami-336791?logo=postgresql&logoColor=white)](https://postgresql.org)

> A complete production-grade EKS platform on AWS, provisioned end-to-end with Terraform + Helm + Jenkins CI/CD. **10 modular sub-components, ~6,500 lines of IaC, zero-to-production in ~25 minutes.**

---

## TL;DR

- **What**: A real EKS cluster with networking, IAM, addons, storage, database, sample app, and full CI/CD pipeline — all reproducible from clone-to-deploy.
- **Why it matters**: Demonstrates the full Day-1 + Day-2 lifecycle a Platform Engineer owns in production — IAM least-privilege, GitOps, observability-ready, secure-by-default.
- **Stack**: AWS EKS 1.34 · Terraform 1.9 · Helm 3.x · Jenkins LTS · PostgreSQL · ALB Ingress · IRSA · ExternalDNS · ACM · ECR

---

## Architecture

```
                           Internet
                              │
                  ┌───────────▼───────────┐
                  │  Route53 (sub-zone)   │
                  │ *.muoidv.do2602.click │
                  └───────────┬───────────┘
                              │
                  ┌───────────▼───────────┐
                  │   ALB (shared group)  │  443/HTTPS via ACM wildcard
                  └───────────┬───────────┘
                              │
   ┌──────────────────────────┴──────────────────────────┐
   │                    EKS Cluster                       │
   │                  (3-AZ private MNG)                  │
   │                                                       │
   │   ┌────────────┐  ┌──────────────┐  ┌────────────┐   │
   │   │ Sample App │  │   pgAdmin    │  │  Jenkins   │   │
   │   │  (Node.js) │  │              │  │            │   │
   │   └─────┬──────┘  └──────┬───────┘  └──────┬─────┘   │
   │         │                │                 │          │
   │         └────────────────┼─────────────────┘          │
   │                          │                            │
   │                   ┌──────▼───────┐                    │
   │                   │ PostgreSQL   │ (Bitnami chart)    │
   │                   │   (PVC gp3)  │                    │
   │                   └──────────────┘                    │
   └───────────────────────────────────────────────────────┘
                              │
                  ┌───────────▼───────────┐
                  │  ECR + IAM (IRSA)     │
                  │  + S3 backend (TF)    │
                  └───────────────────────┘
```

Architecture source file: [`00-overview/architecture-muoidv.drawio`](00-overview/architecture-muoidv.drawio) (open with [diagrams.net](https://app.diagrams.net))

---

## Components

| # | Component | Tech | Purpose |
|---|---|---|---|
| **00** | [Bootstrap](terraform/00-bootstrap/) | S3 + DynamoDB + KMS | Remote state backend + state locking + encryption |
| **01** | [VPC](terraform/01-vpc/) | VPC, 9 subnets, IGW | 3-AZ networking with public/private/data tier separation |
| **02** | [EKS Cluster](terraform/02-eks/) | EKS 1.34 control plane | Cluster with KMS envelope encryption + audit logging |
| **03** | [EKS Addons](terraform/03-eks-addons/) | vpc-cni, kube-proxy, CoreDNS | Pinned addon versions + Prefix Delegation (max 110 pods/node) |
| **04** | [NAT Gateway](terraform/04-nat/) | Regional NAT (HA) | Egress for private subnets, multi-AZ resilient |
| **05** | [Managed Node Group](terraform/05-mng/) | t3.medium AMI AL2023 | Custom Launch Template + nodeadm MIME multipart |
| **06** | [Load Balancer Controller](terraform/06-lbc/) | aws-load-balancer-controller v3.2 | ALB ingress + IRSA + IngressGroup share pattern |
| **07** | [EBS CSI Driver](terraform/07-ebs-csi/) | EBS CSI v1.59 + gp3 SC | Persistent volumes with KMS-encrypted gp3 default |
| **08** | [PostgreSQL](terraform/08-postgresql/) | Bitnami PG chart | Database with PVC gp3 + Secret-based credentials |
| **09** | [pgAdmin](terraform/09-pgadmin/) | runix/pgadmin4 chart | Web admin UI + ALB Ingress + ACM HTTPS |
| **10** | [CI/CD Pipeline](10-cicd/) | Jenkins + ECR + Helm | Pipeline-as-Code, GitHub webhook → build → push → deploy |

**Companion repo (sample app)**: [`DVM1987/muoidv-sample-app`](https://github.com/DVM1987/muoidv-sample-app) — Node.js source + Dockerfile + Helm chart + Jenkinsfile.

---

## Production Patterns Demonstrated

### Security
- **IRSA (IAM Roles for Service Accounts)** for every controller — zero static AWS keys in cluster
- **Least-privilege RBAC** — per-namespace Roles, no `cluster-admin` for app workloads
- **ECR Tag Immutability** + idempotent re-push pattern (skip if tag exists)
- **KMS envelope encryption** for EKS Secrets + EBS volumes
- **Private-only worker nodes** — no public IP, IGW only via ALB

### Reliability
- **Multi-AZ everything** — 3-AZ subnets, Regional NAT, MNG spread, multi-AZ EBS via volume binding mode `WaitForFirstConsumer`
- **Helm idempotent deployments** — `helm upgrade --install` works for fresh install + update
- **Pipeline retry-safe** — DinD daemon wait loop, ECR idempotent describe-images check

### Operability (GitOps + Pipeline-as-Code)
- **Terraform remote state** in S3 + DynamoDB locking (S3-side encryption with KMS)
- **Helm provider 3.x** with explicit chart version pinning (verify via `helm search repo --versions`)
- **Jenkinsfile in repo** — pipeline definition version-controlled with code, no UI Click-Ops
- **GitHub webhook trigger** — push `main` → auto build → ECR push → Helm deploy → smoke test (~80s e2e)
- **Pinned addon versions** — vpc-cni, kube-proxy, CoreDNS pinned to exact build (no surprise upgrades)

### Cost Awareness
- **Single ALB shared across services** via `alb.ingress.kubernetes.io/group.name` annotation — saves $0.0225/h per ALB avoided
- **gp3 over gp2** as default storage class — 20% cheaper at same baseline IOPS
- **Prefix Delegation** — max 110 pods/t3.medium instead of 17, reducing node count

---

## How to Deploy

> Prerequisites: AWS CLI configured, Terraform 1.9+, kubectl, helm, an AWS account with appropriate permissions.

```bash
# 1. Bootstrap remote state (run once, local backend until S3 exists)
cd terraform/00-bootstrap && terraform init && terraform apply

# 2. Deploy infrastructure layer-by-layer (each depends on previous)
for layer in 01-vpc 02-eks 03-eks-addons 04-nat 05-mng \
             06-lbc 07-ebs-csi 08-postgresql 09-pgadmin; do
  cd ../$layer
  terraform init && terraform apply
done

# 3. Get kubeconfig
aws eks update-kubeconfig --name muoidv-eks --region ap-southeast-1

# 4. (Optional) Install Jenkins for CI/CD
cd ../../10-cicd && helm install jenkins jenkinsci/jenkins \
  -n muoidv-cicd --create-namespace -f jenkins/values.yaml
```

**Total time**: ~25 minutes from zero to running cluster + database + ingress.

---

## Key Lessons (Production Pitfalls Solved)

These are real issues encountered + documented during build — the kind of debugging that separates lab from production:

| Pitfall | Where | Fix |
|---|---|---|
| `apk add aws-cli` in `docker:dind` → libexpat shared lib mismatch | Jenkins pipeline | Split 2 containers: `tools` (alpine/k8s) + `docker` (dind), share via workspace volume |
| Bitnami chart `image: docker.io/bitnami/*` 404 (frozen 2025-08) | PostgreSQL | Override `image.repository: bitnamilegacy/postgresql` |
| Helm provider 2.17 `invalid_reference` on Bitnami chart | Terraform | Upgrade `~> 3.0`, syntax `kubernetes = {}` block→argument |
| EKS coredns Add-on PHẢI deploy AFTER MNG (Deployment needs Ready pods) | EKS Addons | Order: vpc-cni + kube-proxy first → MNG → coredns |
| ECR `tag is immutable` on pipeline rerun | CI/CD | Idempotent `aws ecr describe-images` check before push |
| Cross-NS Helm deploy → `secrets is forbidden` | Jenkins RBAC | Per-NS `Role` + `RoleBinding` (NOT cluster-admin) |
| AL2023 Custom LT must be MIME multipart for nodeadm | MNG | Inline `userdata-mime.tpl` template with proper boundary |
| pgAdmin v9 rejects email domain `.local` | Helm values | Use real domain (lab pattern: `admin@example.com`) |

Full debugging trail in [git log](../../commits/main) and CI build history.

---

## Tech Stack Highlights

| Layer | Tools |
|---|---|
| **IaC** | Terraform 1.9, Helm 3 (provider), Kubernetes (provider) |
| **Cloud** | AWS (EKS, VPC, IAM, ECR, S3, DynamoDB, KMS, Route53, ACM, NAT) |
| **K8s** | EKS 1.34, MNG, IRSA, EBS CSI, ALB Ingress, ExternalDNS |
| **CI/CD** | Jenkins LTS, GitHub Webhooks, ECR, Helm releases |
| **App stack** | Node.js (Express) + PostgreSQL (Bitnami) + pgAdmin |
| **Region** | `ap-southeast-1` (Singapore) |

---

## What This Demonstrates

This repo is the deliverable I built for a **Senior DevOps / Platform Engineer (5+ years)** interview portfolio — covering the full lifecycle from bootstrap to production CI/CD that I'd own as Day-1 to Day-2 platform engineer.

Areas covered:
- ✅ AWS deep dive (VPC, EKS, IAM, IRSA, ALB, KMS, ACM, R53)
- ✅ Terraform module design (10 layers, remote state, separation of concerns)
- ✅ Kubernetes operations (controllers, addons, CSI, Ingress, RBAC)
- ✅ Helm chart customization (values override, provider 3.x, version pinning)
- ✅ CI/CD with Pipeline-as-Code (Jenkinsfile, webhooks, ECR idempotent push, RBAC)
- ✅ Production debugging (8+ documented pitfalls solved)

Next phases (separate repos):
- Observability stack (Prometheus + Grafana + Loki)
- Security hardening (Trivy scan, OPA policies, image signing)
- DR / SRE patterns (Velero backup, RTO/RPO drill, chaos engineering)

---

## Contact

**Author**: dauvanmuoi
**GitHub**: [@DVM1987](https://github.com/DVM1987)
**Email**: dauvanmuoi@gmail.com

Open to opportunities in **Senior DevOps / Platform Engineering** roles.

---

## License

This is a portfolio / educational repository. Code patterns are MIT-licensed; feel free to reuse with attribution.
