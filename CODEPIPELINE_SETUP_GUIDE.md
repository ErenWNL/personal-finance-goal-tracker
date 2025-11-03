# AWS CodePipeline Setup Guide
## Personal Finance Goal Tracker - CI/CD Automation

**Last Updated:** November 2025
**Project:** Personal Finance Goal Tracker
**Budget:** $60 AWS Credits
**Estimated Cost:** ~$30/month (within budget)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Pre-requisites](#pre-requisites)
4. [Step 1: AWS Account Setup](#step-1-aws-account-setup)
5. [Step 2: Create IAM Roles & Policies](#step-2-create-iam-roles--policies)
6. [Step 3: Create ECR Repositories](#step-3-create-ecr-repositories)
7. [Step 4: Create CodeBuild Project](#step-4-create-codebuild-project)
8. [Step 5: Create CodePipeline](#step-5-create-codepipeline)
9. [Step 6: Configure GitHub Integration](#step-6-configure-github-integration)
10. [Step 7: Test & Monitor](#step-7-test--monitor)
11. [Troubleshooting](#troubleshooting)
12. [Cost Tracking](#cost-tracking)

---

## Overview

### What is AWS CodePipeline?

AWS CodePipeline is a fully managed continuous delivery service that automates the entire release process:

```
GitHub Push → CodeBuild (Build & Test) → ECR (Store Images) → CodeDeploy (Deploy)
```

### Why CodePipeline Over Jenkins?

| Aspect | Jenkins | CodePipeline |
|--------|---------|--------------|
| **Maintenance** | You manage server | AWS managed |
| **Cost** | $15-30/month (EC2) | $1-10/month |
| **Setup Time** | 2-3 hours | 30 minutes |
| **Scaling** | Manual | Automatic |
| **Integration** | Plugins (sometimes broken) | Native AWS |

**For your $60 budget:** CodePipeline saves ~$15/month vs Jenkins!

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Your GitHub Repository                  │
│              (personal-finance-goal-tracker)                │
└───────────────────────────┬──────────────────────────────────┘
                            │ (Webhook on push to main)
┌───────────────────────────▼──────────────────────────────────┐
│             AWS CodePipeline (Orchestrator)                 │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ STAGE 1: SOURCE                                     │   │
│  │ - Fetch code from GitHub main branch               │   │
│  │ - Detect changes automatically                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↓                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ STAGE 2: BUILD (CodeBuild)                          │   │
│  │ - Run buildspec.yml                                │   │
│  │ - Maven clean install                              │   │
│  │ - Run unit tests                                   │   │
│  │ - Build 7 Docker images                            │   │
│  │ - Push to ECR                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↓                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ STAGE 3: DEPLOY (CodeDeploy or Manual)             │   │
│  │ - Option A: Deploy to EC2                          │   │
│  │ - Option B: Deploy to ECS Fargate                  │   │
│  │ - Option C: Manual approval + deploy               │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↓                                     │
└───────────────────────┬──────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
    ┌───▼──┐                      ┌────▼────┐
    │ ECR  │                      │CodeDeploy
    │(Images) │                      │(Deploy)
    └──────┘                      └─────────┘
```

---

## Pre-requisites

### Required
- [ ] AWS Account with $60 credits
- [ ] GitHub Account with repository access
- [ ] GitHub Personal Access Token
- [ ] Docker installed locally
- [ ] Maven 3.11.0+
- [ ] Java 24

### Information You'll Need
```
AWS Account ID: _____________________  (12 digits)
GitHub Username: _____________________
GitHub Token: (Personal Access Token)
GitHub Repo: personal-finance-goal-tracker
GitHub Owner: ErenWNL
```

---

## Step 1: AWS Account Setup

### 1.1 Find Your AWS Account ID

1. Log in to AWS Console
2. Click your account name (top right)
3. Select "My Account"
4. Look for "Account ID" - copy this 12-digit number
5. **Save it** - you'll need it multiple times

```
Format: 123456789012
```

### 1.2 Create AWS Access Keys (for local testing)

1. Go to **IAM** → **Users** → **Your User**
2. Click **"Create access key"**
3. Select **"Command Line Interface (CLI)"**
4. Copy and save:
    - Access Key ID
    - Secret Access Key
5. Configure locally: `aws configure`

```bash
$ aws configure
AWS Access Key ID: AKIA...
AWS Secret Access Key: ****...
Default region: us-east-1
Default output format: json
```

### 1.3 Enable CodeBuild & CodePipeline APIs

1. Go to **API Gateway** in AWS Console
2. Search for "CodeBuild" → Enable
3. Search for "CodePipeline" → Enable
4. Search for "CodeDeploy" → Enable

---

## Step 2: Create IAM Roles & Policies

### 2.1 Create CodePipeline Service Role

1. Go to **IAM** → **Roles** → **Create Role**
2. Select **AWS Service** → **CodePipeline**
3. Click **Next**
4. Search for and select these policies:
   - `AWSCodePipelineFullAccess`
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonS3FullAccess`
   - `AWSCodeBuildAdminAccess`
   - `AWSCodeDeployFullAccess`

5. Role Name: `CodePipelineServiceRole`
6. Click **Create Role**

### 2.2 Create CodeBuild Service Role

1. Go to **IAM** → **Roles** → **Create Role**
2. Select **AWS Service** → **CodeBuild**
3. Click **Next**
4. Attach these policies:
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonEC2InstanceProfileForImageBuilder`
   - `CloudWatchLogsFullAccess`
   - `AmazonS3FullAccess`

5. Click **Next**
6. Role Name: `CodeBuildServiceRole`
7. Click **Create Role**

### 2.3 Create Inline Policy for ECR Push (CodeBuild)

1. Go to **IAM** → **Roles** → **CodeBuildServiceRole**
2. Click **Add inline policy**
3. Paste this JSON:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:us-east-1:YOUR_AWS_ACCOUNT_ID:repository/personal-finance/*"
    }
  ]
}
```

4. Replace `YOUR_AWS_ACCOUNT_ID` with your 12-digit account ID
5. Review and create

---

## Step 3: Create ECR Repositories

### 3.1 Create ECR Repositories via AWS Console

1. Go to **Elastic Container Registry (ECR)** → **Repositories**
2. Click **Create Repository**
3. Create repositories for each service:

```
Repository names to create:
├─ personal-finance/authentication-service
├─ personal-finance/user-finance-service
├─ personal-finance/goal-service
├─ personal-finance/insight-service
├─ personal-finance/api-gateway
├─ personal-finance/eureka-server
└─ personal-finance/config-server
```

**For each repository:**
- Repository Name: `personal-finance/service-name`
- Image Tag Mutability: **Disabled**
- Scan on Push: **Enabled** (optional, scans for vulnerabilities)
- Encryption: **AWS managed key**
- Click **Create Repository**

### 3.2 Get ECR Login Command

```bash
# Login to ECR locally (for testing)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Tag and push a test image
docker tag my-app:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/personal-finance/my-app:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/personal-finance/my-app:latest
```

---

## Step 4: Create CodeBuild Project

### 4.1 Create CodeBuild Project via Console

1. Go to **AWS CodeBuild** → **Projects** → **Create Project**

2. **Project Configuration**
   - Project Name: `personal-finance-build`
   - Description: `Build and push Docker images for Personal Finance app`

3. **Source**
   - Source Provider: **GitHub**
   - Repository: Select **personal-finance-goal-tracker**
   - Branch: **main**
   - (Click "Connect to GitHub" if not connected)

4. **Primary Source Webhook Events**
   - Check: **Rebuild every time a code change is pushed to this repository**
   - Events: **Push**

5. **Environment**
   - Managed Image: **Amazon Linux 2**
   - Runtime(s): **Standard**
   - Image: **aws/codebuild/standard:5.0** (Java 11+, Docker included)
   - Image Version: **Latest**
   - Environment Type: **Linux**
   - Privileged: **CHECK THIS** (needed for Docker)
   - Service Role: **CodeBuildServiceRole** (created in Step 2)

6. **Buildspec**
   - Buildspec name: **buildspec.yml** (uses file from repo root)

7. **Logs**
   - CloudWatch logs: **Enable**
   - Group Name: `/aws/codebuild/personal-finance-pipeline`
   - Stream Name: `codebuild-log-stream`

8. Click **Create Build Project**

### 4.2 Test CodeBuild Locally (Optional)

```bash
# Install AWS CodeBuild agent locally
git clone https://github.com/aws/aws-codebuild-docker-images.git
cd aws-codebuild-docker-images/ubuntu/standard/5.0
docker build -t aws/codebuild/standard:5.0 .

# Test build
cd /path/to/personal-finance-goal-tracker
docker run -it -v $(pwd):/tmp -w /tmp aws/codebuild/standard:5.0 /bin/bash
# Inside container: chmod +x buildspec.yml && ./buildspec.yml
```

---

## Step 5: Create CodePipeline

### 5.1 Create Pipeline via Console

1. Go to **AWS CodePipeline** → **Pipelines** → **Create Pipeline**

2. **Pipeline Settings**
   - Pipeline Name: `personal-finance-pipeline`
   - Service Role: **CodePipelineServiceRole** (created in Step 2)
   - Artifact Store: **Amazon S3**
   - S3 Bucket: Create new → `personal-finance-pipeline-artifacts-YOUR_ACCOUNT_ID`
   - Encryption Key: **Default AWS Managed Key**

3. Click **Next**

### 5.2 Add Source Stage

1. **Source Stage**
   - Source Provider: **GitHub (Version 2)**
   - Repository Owner: **ErenWNL**
   - Repository Name: **personal-finance-goal-tracker**
   - Branch: **main**
   - GitHub Connection: Click **Create Connection**
     - Connection Name: `personal-finance-github`
     - GitHub Apps Configuration: Click **Install a New App**
     - Authorize GitHub Aps
     - Install & Authorize
     - Click **Connect**

2. Click **Next**

### 5.3 Add Build Stage

1. **Build Stage**
   - Build Provider: **AWS CodeBuild**
   - Project Name: **personal-finance-build**
   - Build Type: **Single Build**

2. Click **Next**

### 5.4 Add Deploy Stage (Skip for Now)

1. **Deploy Stage**
   - Deploy Provider: **Skip Deploy Stage** (we'll add this later)

2. Click **Create Pipeline**

---

## Step 6: Configure GitHub Integration

### 6.1 Create GitHub Personal Access Token

1. Go to GitHub → **Settings** → **Developer Settings** → **Personal Access Tokens** → **Tokens (classic)**
2. Click **Generate New Token**
3. Name: `AWS CodePipeline`
4. Scopes: Select:
   - `repo` (full control)
   - `admin:repo_hook` (hook permissions)
5. Click **Generate**
6. Copy token (you'll only see it once!)

### 6.2 Verify Webhook in GitHub

1. Go to your GitHub repo → **Settings** → **Webhooks**
2. You should see AWS CodePipeline webhook created
3. Check the webhook is active (green checkmark)

```
Webhook Details:
├─ Payload URL: https://api.github.com/repos/ErenWNL/personal-finance-goal-tracker/dispatches
├─ Content Type: application/json
├─ Events: Push events
└─ Active: ✓
```

### 6.3 Update buildspec.yml with Your Account ID

1. In your repo, open `buildspec.yml`
2. Find: `AWS_ACCOUNT_ID: "YOUR_AWS_ACCOUNT_ID"`
3. Replace with your actual 12-digit AWS Account ID

Example:
```yaml
env:
  variables:
    AWS_ACCOUNT_ID: "123456789012"  # Your actual ID
```

---

## Step 7: Test & Monitor

### 7.1 Trigger First Pipeline Run

1. Go to GitHub → **personal-finance-goal-tracker**
2. Make a small change to any file
3. Commit and push to main:

```bash
git add .
git commit -m "Trigger CodePipeline test"
git push origin main
```

4. Go to **AWS CodePipeline** → **personal-finance-pipeline**
5. Watch the pipeline execute:
   - Source: Fetching code (1 min)
   - Build: Running Maven + Docker (5-10 min)
   - Deploy: Skipped (we added no deploy stage)

### 7.2 Monitor Build Logs

1. Click on **Build** stage → **Details** link
2. Click **Build ID** to see detailed logs
3. Watch for:
   - Maven compilation: `mvn clean install`
   - Tests: `mvn test`
   - Docker builds: `docker build`
   - ECR push: `docker push`

### 7.3 Verify Docker Images in ECR

```bash
# List images in ECR
aws ecr describe-images \
  --repository-name personal-finance/authentication-service \
  --region us-east-1

# Output should show:
# ├─ authentication-service:ab12cd34
# ├─ authentication-service:latest
# └─ ... (other services)
```

### 7.4 Check CloudWatch Logs

1. Go to **CloudWatch** → **Logs** → **Log Groups**
2. Find: `/aws/codebuild/personal-finance-pipeline`
3. Click the log stream
4. Review build output

---

## Troubleshooting

### Issue: "Permission Denied" in CodeBuild

**Problem:** Docker or ECR push fails with permission denied

**Solution:**
1. Check CodeBuildServiceRole has `AmazonEC2ContainerRegistryFullAccess`
2. Verify Privileged is **enabled** in CodeBuild environment
3. Check IAM inline policy has correct AWS Account ID

### Issue: "Repository not found" in CodeBuild

**Problem:** CodeBuild can't find ECR repository

**Solution:**
1. Verify ECR repositories exist: `aws ecr describe-repositories`
2. Check buildspec.yml has correct repository name
3. Verify Region is `us-east-1` (or your chosen region)

### Issue: GitHub Webhook Not Triggering

**Problem:** Pipeline doesn't start when code is pushed

**Solution:**
1. Go to GitHub repo → Settings → Webhooks
2. Click AWS CodePipeline webhook
3. Scroll down and click **Redeliver** to test
4. Verify "Payload URL" starts with `https://api.github.com`

### Issue: Build Timeout (>1 hour)

**Problem:** CodeBuild times out

**Solution:**
1. Go to CodeBuild project settings
2. Increase **Timeout** (default: 60 min, max: 480 min)
3. Optimize buildspec.yml:
   - Cache Maven dependencies
   - Parallelize Docker builds
   - Skip unnecessary tests in CI

---

## Cost Tracking

### Monthly Cost Breakdown

| Service | Cost | Notes |
|---------|------|-------|
| **CodePipeline** | $1 | First active pipeline free, $1 per additional |
| **CodeBuild** | ~$9 | ~60 min/day * 30 days = 1800 min = $0.005/min |
| **ECR Storage** | ~$2 | 7 images * ~300MB each = ~2GB |
| **S3 (Artifacts)** | <$1 | Small artifact store |
| **CloudWatch Logs** | ~$1 | Build logs ingestion |
| **TOTAL** | ~$13/month | Well within $60 budget |

### Monitor Costs

```bash
# Check CodeBuild minutes
aws codebuild batch-get-builds \
  --ids $(aws codebuild list-builds-for-project \
    --project-name personal-finance-build \
    --query 'ids[0:10]' --output text) \
  --query 'builds[].buildDurationInMinutes' \
  --output text

# Check ECR storage
aws ecr describe-repositories \
  --query 'repositories[].repositoryUri' \
  --output table
```

### Enable AWS Budgets (Optional)

1. Go to **AWS Budgets** → **Create Budget**
2. Set:
   - Budget Name: `CodePipeline-$60-Limit`
   - Budget Amount: `$60`
   - Alert at: `80%` ($48)

3. Add email notification
4. Create budget

---

## Next Steps

Once CodePipeline is working:

### Phase 2: Add RDS Database
- Replace Docker MySQL with AWS RDS
- Cost: $0-15/month

### Phase 3: Add SNS Notifications
- Send spending alerts & goal updates to users
- Cost: $0-5/month

### Phase 4: Add CloudWatch Logs
- Centralized log aggregation
- Cost: $0-5/month

### Phase 5: Add CodeDeploy (Optional)
- Automate deployment to EC2/ECS
- Cost: Free (you pay for compute only)

---

## Useful Commands

### AWS CLI Commands

```bash
# List all pipelines
aws codepipeline list-pipelines

# Get pipeline details
aws codepipeline get-pipeline --name personal-finance-pipeline

# Get latest pipeline execution
aws codepipeline get-pipeline-state --name personal-finance-pipeline

# Start manual execution
aws codepipeline start-pipeline-execution --name personal-finance-pipeline

# List CodeBuild projects
aws codebuild list-projects

# Get build logs
aws logs tail /aws/codebuild/personal-finance-pipeline --follow

# Clear ECR repository
aws ecr batch-delete-image \
  --repository-name personal-finance/authentication-service \
  --image-ids imageTag=latest
```

### Docker Commands

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build and push locally
docker build -t personal-finance/auth-service .
docker tag personal-finance/auth-service:latest \
  YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/personal-finance/authentication-service:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/personal-finance/authentication-service:latest

# Pull from ECR
docker pull YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/personal-finance/authentication-service:latest
```

---

## References

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [ECR Getting Started](https://docs.aws.amazon.com/AmazonECR/latest/userguide/)
- [CodeBuild Buildspec Reference](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)

---

**Created:** November 2025
**Last Updated:** November 2025
**Status:** Ready for Implementation
