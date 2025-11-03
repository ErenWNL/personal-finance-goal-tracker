# AWS Services Integration Guide for Personal Finance Goal Tracker

## Overview
This guide provides recommendations for integrating AWS services into the Personal Finance Goal Tracker microservices architecture. It includes both actual AWS services and open-source self-hosted alternatives (no signup required).

---

## Table of Contents
1. [Top 4 Recommended Open-Source Alternatives](#top-4-recommended-open-source-alternatives)
2. [AWS Services for Production Deployment](#aws-services-for-production-deployment)
3. [Implementation Architecture](#implementation-architecture)
4. [Cost Comparison](#cost-comparison)
5. [Migration Path](#migration-path)

---

## Top 4 Recommended Open-Source Alternatives

### 1. MinIO (AWS S3 Alternative)

**Purpose:** S3-compatible object storage

**Use Cases in Your Project:**
- Store transaction receipts and invoices
- Save goal images and motivation photos
- User profile picture storage
- CSV exports and financial reports
- Backup and archival storage

**Why Choose MinIO:**
- 100% S3-compatible API
- Drop-in replacement for AWS S3 SDKs
- Self-hosted, no signup required
- Runs in Docker with your existing infrastructure
- Open-source (AGPL)

**Integration Points:**
```
Frontend → API Gateway → Service → MinIO
Goal Service: Store goal images
Finance Service: Store transaction receipts
Profile Service: Store profile pictures
```

**Deployment:**
- Docker container or Kubernetes StatefulSet
- Requires persistent storage volume
- Easy to scale horizontally

**GitHub:** https://github.com/minio/minio

**Cost:** Free (only pay for storage hardware)

---

### 2. Apache Kafka (AWS SNS/SQS Alternative)

**Purpose:** Event streaming and message queue system

**Use Cases in Your Project:**
- **Event-driven notifications:**
  - Transaction created → Trigger insight calculation
  - Goal completed → Send user notification
  - Spending alert triggered → Notify via email/SMS

- **Asynchronous processing:**
  - Decouple insight generation from transaction creation
  - Process analytics in background
  - Queue recommendation calculations

- **Real-time data pipeline:**
  - Stream transaction data to analytics
  - Track spending patterns in real-time
  - Cross-service event propagation

- **Audit trail:**
  - Log all financial events
  - Maintain immutable transaction history

**Why Choose Kafka:**
- High-throughput, low-latency messaging
- Persistent event log (replay-able events)
- Horizontal scalability
- Self-hosted, no signup required
- Industry-standard for microservices

**Integration Points:**
```
Finance Service (Producer)
    ↓
    Kafka Topic: transactions.created
    ↓
Insight Service (Consumer) → Generate analytics
Recommendation Service (Consumer) → Create suggestions
Notification Service (Consumer) → Send alerts
```

**Deployment:**
- Docker Compose or Kubernetes
- Requires ZooKeeper for coordination
- Message retention configurable

**GitHub:** https://github.com/apache/kafka

**Cost:** Free (only pay for infrastructure)

---

### 3. Prometheus + Grafana (AWS CloudWatch Alternative)

**Purpose:** Monitoring, metrics collection, and visualization dashboards

**Use Cases in Your Project:**
- **System Monitoring:**
  - Monitor all 4 microservices health
  - Track API Gateway latency and throughput
  - Database connection pool monitoring
  - JVM memory and CPU usage

- **Business Metrics:**
  - Daily transactions created
  - Goals created/completed per day
  - Total spending and income
  - Insights generated
  - Average transaction value

- **Performance Monitoring:**
  - API response times
  - Database query performance
  - Service-to-service call latency
  - Error rates by endpoint

- **Alerts & Notifications:**
  - Service down alerts
  - High latency warnings
  - Error rate thresholds
  - Unusual spending patterns

**Why Choose Prometheus + Grafana:**
- Industry-standard monitoring stack
- Your Spring Boot services already have Micrometer support
- Beautiful customizable dashboards
- Self-hosted, no signup required
- Open-source and free

**Integration Points:**
```
Spring Boot Actuator (Micrometer)
    ↓
    /actuator/prometheus endpoint
    ↓
Prometheus (Scrapes metrics)
    ↓
Grafana (Visualizes data)
    ↓
User Dashboard
```

**Deployment:**
- Docker containers (3-4 containers: Prometheus, Grafana, AlertManager)
- Kubernetes deployments with persistent volumes
- Configuration via YAML files

**GitHub:**
- https://github.com/prometheus/prometheus
- https://github.com/grafana/grafana

**Cost:** Free (only pay for infrastructure)

---

### 4. OpenSearch (AWS Elasticsearch/OpenSearch Alternative)

**Purpose:** Full-text search and analytics engine

**Use Cases in Your Project:**
- **Transaction Search:**
  - Search transactions by description, amount, date range
  - Advanced filtering across millions of records
  - Real-time search suggestions

- **Analytics:**
  - Category-wise spending aggregations
  - Time-series analytics (daily/weekly/monthly trends)
  - Percentile calculations (top 10% spenders)
  - Anomaly detection in spending

- **Insights Enhancement:**
  - Fast aggregations for recommendation engine
  - Complex filtering for insight generation
  - Historical data analysis

- **Dashboard & Reporting:**
  - Real-time spending dashboards
  - Advanced filtering UI
  - Export functionality with complex queries

**Why Choose OpenSearch:**
- 100% open-source fork of Elasticsearch
- Petabyte-scale search and analytics
- Real-time search capabilities
- Horizontally scalable
- No vendor lock-in

**Integration Points:**
```
Finance Service (Index Transactions)
    ↓
OpenSearch Cluster
    ↓
Query Layer (Spring Data Elasticsearch)
    ↓
Insight Service / Frontend Search API
```

**Deployment:**
- Docker containers (3+ node cluster recommended)
- Kubernetes StatefulSet for high availability
- Requires persistent storage

**GitHub:** https://github.com/opensearch-project/OpenSearch

**Cost:** Free (only pay for infrastructure)

---

## AWS Services for Production Deployment

### 1. AWS EC2 (Elastic Compute Cloud)

**Purpose:** Virtual servers for hosting your microservices

**Use Cases:**
- Host Eureka Server, Config Server, API Gateway
- Host authentication, finance, goal, and insight services
- Run MySQL database
- Deploy monitoring stack (Prometheus, Grafana)

**Instance Types Recommended:**
```
Development:
- t3.medium or t3.small (burstable, cost-effective)

Production:
- t3.large or t3.xlarge (for services)
- r5.large or r5.xlarge (for database and Elasticsearch)
```

**Configuration:**
- Auto Scaling Group for horizontal scaling
- Load Balancer (ALB) for traffic distribution
- Security Groups for network isolation
- EBS volumes for persistent storage

**Cost Estimate:**
- Single t3.medium: ~$30/month
- Production cluster (3x t3.large): ~$300/month

**Integration:**
```
Load Balancer (ALB)
    ↓
EC2 Auto Scaling Group (API Gateway + Services)
    ↓
RDS MySQL or EC2 MySQL
```

---

### 2. AWS RDS (Relational Database Service)

**Purpose:** Managed MySQL database

**Use Cases:**
- Replace self-hosted MySQL with managed RDS
- Automatic backups and point-in-time recovery
- High availability with Multi-AZ deployment
- Automated patching and maintenance

**Database Tier:**
```
Development:
- db.t3.micro or db.t3.small

Production:
- db.t3.medium (single-AZ)
- db.r5.large (Multi-AZ for high availability)
```

**Configuration:**
- Create 4 separate databases:
  - auth_service_db
  - user_finance_db
  - goal_service_db
  - insight_service_db

**Cost Estimate:**
- db.t3.micro (free tier eligible): $0-15/month
- db.t3.medium: ~$50/month
- db.r5.large Multi-AZ: ~$300/month

**Benefits Over Self-Hosted:**
- Automated backups and PITR
- High availability
- Read replicas for scaling
- Security patches automatic
- Monitoring included

---

### 3. AWS S3 (Simple Storage Service)

**Purpose:** Object storage for files and backups

**Use Cases:**
- Store transaction receipts and invoices
- Save goal images and user photos
- CSV export storage
- Database backups and snapshots
- Log archival

**Storage Classes:**
```
Hot Data (Frequently Accessed):
- S3 Standard: $0.023 per GB/month

Warm Data (Occasional Access):
- S3 Standard-IA: $0.0125 per GB/month

Cold Data (Archival):
- S3 Glacier: $0.004 per GB/month
- S3 Glacier Deep Archive: $0.00099 per GB/month
```

**Lifecycle Policies:**
- New files → S3 Standard
- After 30 days → S3 Standard-IA
- After 90 days → S3 Glacier

**Security:**
- Versioning enabled
- Server-side encryption (AES-256)
- Access control with IAM policies
- Block public access

**Cost Estimate (1 TB/month):**
- S3 Standard only: ~$23/month
- With tiering: ~$15/month

**Integration:**
```
Application (AWS SDK)
    ↓
S3 (Bucket)
    ↓
CloudFront CDN (Optional, for image delivery)
```

---

### 4. AWS IAM (Identity and Access Management)

**Purpose:** Authentication, authorization, and access control

**Use Cases:**
- Service-to-service authentication (EC2 → S3 → RDS)
- Role-based access control
- API access keys for applications
- Audit trail and compliance

**Required Roles & Policies:**
```
1. EC2ServiceRole
   - Permissions: EC2, RDS access, S3 read/write

2. AppServiceRole
   - Permissions: S3, RDS, CloudWatch

3. LambdaExecutionRole (if using Lambda)
   - Permissions: CloudWatch Logs, S3, RDS

4. BackupRole
   - Permissions: S3, RDS snapshots, EBS snapshots
```

**Security Best Practices:**
- Create service-specific IAM roles
- Use temporary credentials via STS
- Enable MFA for human users
- Rotate credentials regularly
- Principle of least privilege

**Cost:** Free (IAM is always free)

---

### 5. AWS CloudWatch (Monitoring & Logging)

**Purpose:** Centralized logging and monitoring

**Use Cases:**
- Collect logs from all services
- Set up alarms for errors and performance issues
- Create dashboards
- Track custom metrics

**Log Groups:**
```
/aws/ec2/api-gateway
/aws/ec2/auth-service
/aws/ec2/finance-service
/aws/ec2/goal-service
/aws/ec2/insight-service
/aws/rds/mysql
```

**Metrics to Monitor:**
- API latency (p50, p95, p99)
- Error rates
- Database connections
- CPU and memory usage
- Network I/O

**Alarms:**
```
- Service CPU > 80% → Scale up
- API Error Rate > 5% → Page on-call
- Database connections > 80% → Alert
- Low disk space → Alert
```

**Cost Estimate:**
- Logs ingestion: ~$0.50 per GB
- Typical project: ~$50-100/month

**Integration:**
```
Spring Boot (Logback)
    ↓
CloudWatch Logs
    ↓
CloudWatch Alarms
    ↓
SNS (Email/SMS notifications)
```

---

### 6. AWS Elastic Container Registry (ECR)

**Purpose:** Docker image repository

**Use Cases:**
- Store Docker images for all services
- Integration with EC2 and ECS deployments
- Image scanning for vulnerabilities
- Version control for deployments

**Setup:**
```
Create repositories for:
- personal-finance-api-gateway
- personal-finance-auth-service
- personal-finance-finance-service
- personal-finance-goal-service
- personal-finance-insight-service
```

**CI/CD Integration:**
```
GitHub Actions / Jenkins
    ↓
Build Docker image
    ↓
Push to ECR
    ↓
Deploy to EC2 or ECS
```

**Cost Estimate:**
- Storage: $0.10 per GB/month
- Typical project: ~$10-20/month

---

### 7. AWS Lambda (Serverless Computing)

**Purpose:** Run functions without managing servers

**Optional Use Cases:**
- Scheduled tasks (daily report generation)
- Webhook processing (external payment APIs)
- Image processing (resize goal images)
- Background jobs (insight calculations)

**Example: Daily Analytics Job**
```
CloudWatch Events (Cron: 2 AM daily)
    ↓
Lambda Function
    ↓
Query RDS (fetch daily transactions)
    ↓
Calculate insights
    ↓
Send notifications
```

**Cost Estimate:**
- 1 million requests/month: ~$0.20/month
- Storage: $0.20 per GB-month
- Typical usage: $5-20/month

---

### 8. AWS SNS (Simple Notification Service)

**Purpose:** Send notifications and alerts

**Use Cases:**
- Email alerts for spending anomalies
- SMS notifications for goal milestones
- Push notifications to mobile app
- Alert notifications to admins

**Topics to Create:**
```
- spending-alerts
- goal-milestones
- system-alerts
- daily-summary
```

**Integration:**
```
Finance Service (Event)
    ↓
SNS Topic (spending-alerts)
    ↓
Email/SMS Subscription
    ↓
User notification
```

**Cost Estimate:**
- Email: $0.002 per email
- SMS: $0.0075 per SMS
- Typical usage: $10-50/month

---

### 9. AWS CloudFront (CDN)

**Purpose:** Distribute content globally with low latency

**Use Cases:**
- Serve static assets (React build)
- Cache goal images
- API response caching
- Global user access with low latency

**Configuration:**
```
CloudFront Distribution
    ↓
S3 (for static assets)
    ↓
ALB (for API endpoints)
```

**Cost Estimate:**
- Data transfer: $0.085 per GB
- Requests: varies by region
- Typical usage: $20-100/month

---

## Implementation Architecture

### Option 1: Hybrid Approach (Recommended for Learning)

```
┌─────────────────────────────────────────┐
│         AWS Cloud Environment            │
├─────────────────────────────────────────┤
│                                          │
│  ┌──────────────────────────────────┐  │
│  │   AWS Application Load Balancer  │  │
│  └─────────────┬────────────────────┘  │
│                │                        │
│  ┌─────────────▼────────────────────┐  │
│  │  EC2 Auto Scaling Group (Services) │  │
│  │  ├─ API Gateway                    │  │
│  │  ├─ Auth Service                   │  │
│  │  ├─ Finance Service                │  │
│  │  ├─ Goal Service                   │  │
│  │  └─ Insight Service                │  │
│  └────────────────────────────────────┘  │
│                │                        │
│  ┌─────────────▼────────────────────┐  │
│  │      AWS RDS MySQL               │  │
│  │  (4 separate databases)          │  │
│  └────────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  Self-Hosted (On Premise/Docker) │  │
│  ├──────────────────────────────────┤  │
│  │ - MinIO (S3 alternative)         │  │
│  │ - Kafka (SQS/SNS alternative)    │  │
│  │ - Prometheus + Grafana           │  │
│  │ - OpenSearch                     │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │     AWS Services                 │  │
│  ├──────────────────────────────────┤  │
│  │ - CloudWatch (Logs & Monitoring) │  │
│  │ - S3 (Backups & Archives)        │  │
│  │ - IAM (Access Control)           │  │
│  │ - ECR (Docker Registry)          │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Advantages:**
- AWS handles scalability and high availability
- Self-hosted tools give you complete control
- Easy to migrate self-hosted to managed AWS later
- Cost-effective for learning

---

### Option 2: Full AWS Managed Services

```
┌─────────────────────────────────────────────┐
│         Fully Managed AWS Environment        │
├─────────────────────────────────────────────┤
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │  CloudFront CDN (Static Assets)      │  │
│  └─────────────────────────────────────┘   │
│                │                            │
│  ┌─────────────▼──────────────────────┐   │
│  │  ALB (Application Load Balancer)   │   │
│  └─────────────┬──────────────────────┘   │
│                │                            │
│  ┌─────────────▼──────────────────────┐   │
│  │  ECS Fargate (Container Orchestration) │   │
│  │  ├─ API Gateway Task                  │   │
│  │  ├─ Auth Service Task                 │   │
│  │  ├─ Finance Service Task              │   │
│  │  ├─ Goal Service Task                 │   │
│  │  └─ Insight Service Task              │   │
│  └──────────────────────────────────────┘  │
│                │                            │
│  ┌─────────────▼──────────────────────┐   │
│  │      AWS RDS Aurora MySQL          │   │
│  │  (Multi-AZ, Auto-scaling)          │   │
│  └──────────────────────────────────────┘  │
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │      AWS Services                    │  │
│  ├──────────────────────────────────────┤  │
│  │ - S3 (File Storage & Backups)       │  │
│  │ - CloudWatch (Monitoring & Logs)    │  │
│  │ - SNS/SQS (Messaging)               │  │
│  │ - Lambda (Serverless Jobs)          │  │
│  │ - IAM (Access Control)              │  │
│  │ - ECR (Docker Registry)             │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

**Advantages:**
- No infrastructure management
- Auto-scaling built-in
- High availability by default
- AWS handles updates and patches

---

## Cost Comparison

### Monthly Cost Estimates

#### Option 1: Self-Hosted + AWS (Recommended)
```
AWS Services:
- EC2 (t3.medium): $30
- RDS (db.t3.small): $30
- CloudWatch: $50
- S3 (100GB): $2.30
- ALB: $16
- Data Transfer: $10
Subtotal AWS: ~$138/month

Self-Hosted (VPS or Local):
- MinIO: $0 (free, storage cost only)
- Kafka: $0 (free, storage cost only)
- Prometheus: $0 (free)
- Grafana: $0 (free)
- VPS (if needed): $10-20

TOTAL: ~$150-160/month
```

#### Option 2: Full AWS Managed
```
AWS Services:
- ECS Fargate: $150 (5 services)
- RDS Aurora: $100
- S3: $30
- CloudFront: $50
- SNS/SQS: $20
- CloudWatch: $50
- ALB: $16
- Data Transfer: $20
- NAT Gateway: $32

TOTAL: ~$468/month
```

#### Option 3: Self-Hosted (Docker Compose)
```
VPS (16GB RAM, 8 CPU):
- Linode: $120/month
- DigitalOcean: $160/month
- AWS EC2 (equivalent): $150/month

All Services Included:
- Microservices
- MySQL
- MinIO
- Kafka
- Prometheus
- Grafana
- OpenSearch

TOTAL: ~$120-160/month
```

---

## Migration Path

### Phase 1: Development (Current)
- Run everything locally with Docker Compose
- Use open-source alternatives

**Services:**
```
- MinIO (S3 alternative)
- Kafka (SQS alternative)
- Prometheus + Grafana
- OpenSearch
- Local MySQL
```

**Infrastructure:** Docker Compose on laptop

---

### Phase 2: Staging (AWS + Open-Source Hybrid)
- Deploy microservices to AWS EC2
- Use AWS RDS for database
- Keep MinIO, Kafka, Prometheus self-hosted on separate servers

**Services:**
```
AWS:
- EC2 (API Gateway + Services)
- RDS (MySQL)
- S3 (backups)
- CloudWatch (logs)
- IAM (access control)

Self-Hosted:
- MinIO
- Kafka
- Prometheus + Grafana
- OpenSearch
```

**Infrastructure:** AWS + VPS

---

### Phase 3: Production (Full AWS)
- Migrate to AWS managed services for better reliability
- Replace open-source with AWS equivalents if needed
- Enable auto-scaling, multi-AZ, CDN

**Services:**
```
AWS:
- ECS/EKS (container orchestration)
- RDS Aurora (database)
- S3 (file storage)
- CloudFront (CDN)
- SNS/SQS (messaging)
- CloudWatch (monitoring)
- Lambda (serverless jobs)
- IAM (access control)
```

**Infrastructure:** Fully AWS managed

---

## Implementation Checklist

### For AWS Services:

- [ ] **EC2 Setup**
  - [ ] Create VPC and subnets
  - [ ] Launch EC2 instances (AMI: Ubuntu 22.04 LTS)
  - [ ] Configure Security Groups (ports 8081-8085, 3306, 9090, 3000)
  - [ ] Attach IAM role with S3, RDS permissions
  - [ ] Install Java, Maven, Node.js, Docker

- [ ] **RDS Setup**
  - [ ] Create MySQL instance (db.t3.small)
  - [ ] Configure security group to allow EC2 access
  - [ ] Create 4 databases:
    - auth_service_db
    - user_finance_db
    - goal_service_db
    - insight_service_db
  - [ ] Create backup schedule

- [ ] **S3 Setup**
  - [ ] Create buckets:
    - personal-finance-receipts
    - personal-finance-images
    - personal-finance-exports
    - personal-finance-backups
  - [ ] Enable versioning on all buckets
  - [ ] Set up lifecycle policies (transition to Glacier after 90 days)
  - [ ] Enable encryption (AES-256)
  - [ ] Block public access

- [ ] **IAM Setup**
  - [ ] Create AppServiceRole with S3, RDS permissions
  - [ ] Create BackupRole for automated backups
  - [ ] Create monitoring IAM user for CloudWatch

- [ ] **CloudWatch Setup**
  - [ ] Create log groups for each service
  - [ ] Set up log retention (30 days)
  - [ ] Create CloudWatch dashboards
  - [ ] Set up alarms for errors and latency

- [ ] **ECR Setup**
  - [ ] Create repositories for each service
  - [ ] Push Docker images
  - [ ] Enable image scanning

- [ ] **Load Balancer**
  - [ ] Create Application Load Balancer (ALB)
  - [ ] Configure target groups for services
  - [ ] Set up HTTPS certificate (AWS Certificate Manager)
  - [ ] Configure routing rules

### For Open-Source Services:

- [ ] **MinIO Setup**
  - [ ] Deploy MinIO (Docker or VM)
  - [ ] Create buckets
  - [ ] Configure S3-compatible SDKs in services

- [ ] **Kafka Setup**
  - [ ] Deploy Kafka cluster (3+ brokers)
  - [ ] Create topics:
    - transactions.created
    - goals.updated
    - insights.generated
  - [ ] Configure retention policies

- [ ] **Prometheus Setup**
  - [ ] Deploy Prometheus server
  - [ ] Configure scrape configs for all services
  - [ ] Set up retention (15 days)

- [ ] **Grafana Setup**
  - [ ] Deploy Grafana
  - [ ] Add Prometheus data source
  - [ ] Create dashboards for:
    - System health
    - Business metrics
    - Service performance

- [ ] **OpenSearch Setup**
  - [ ] Deploy OpenSearch cluster (3+ nodes)
  - [ ] Configure indexes for transactions
  - [ ] Set up index lifecycle policies

---

## Quick Start: Implementing AWS S3 + MinIO

### Step 1: Add AWS S3 Dependency

In each service `pom.xml`:
```xml
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
    <version>2.20.0</version>
</dependency>
```

### Step 2: Create S3 Client Configuration

```java
@Configuration
public class S3Config {

    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
            .region(Region.US_EAST_1)
            .build();
    }
}
```

### Step 3: Create File Service

```java
@Service
public class FileStorageService {

    @Autowired
    private S3Client s3Client;

    public String uploadFile(String bucketName, String key, File file) {
        s3Client.putObject(
            PutObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .build(),
            RequestBody.fromFile(file)
        );
        return s3Client.utilities().getUrl(b -> b.bucket(bucketName).key(key)).toExternalForm();
    }

    public byte[] downloadFile(String bucketName, String key) {
        return s3Client.getObject(
            GetObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .build()
        ).readAllBytes();
    }
}
```

### Step 4: Use in Services

**Goal Service - Store Goal Images:**
```java
@PostMapping("/{id}/image")
public ResponseEntity<?> uploadGoalImage(
    @PathVariable Long id,
    @RequestParam("file") MultipartFile file) {

    String key = "goals/" + id + "/" + file.getOriginalFilename();
    String url = fileStorageService.uploadFile("personal-finance-images", key, file);

    goal.setImageUrl(url);
    goalRepository.save(goal);

    return ResponseEntity.ok("Image uploaded: " + url);
}
```

---

## Recommendations

### For MVP/Learning Project:
✅ **Use Open-Source Alternatives** + Basic AWS
- Deploy on EC2 with self-hosted services
- Use RDS for database
- Use S3 for critical backups
- Cost: ~$150/month

### For Scaling/Production:
✅ **Use Hybrid Approach**
- AWS for compute and database
- Self-hosted for advanced tools (Kafka, OpenSearch)
- Cost: ~$300-400/month

### For Enterprise:
✅ **Use Full AWS Managed Services**
- ECS/EKS for container orchestration
- RDS Aurora for database
- All managed services (SNS, SQS, Lambda)
- Cost: ~$500-1000+/month

---

## Useful AWS Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)
- [AWS SDK for Java](https://docs.aws.amazon.com/sdk-for-java/)

## Open-Source Documentation

- [MinIO Official Docs](https://docs.min.io/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenSearch Documentation](https://opensearch.org/docs/)

---

**Last Updated:** October 27, 2025
**Project:** Personal Finance Goal Tracker
**Status:** Ready for AWS integration