# AWS CodePipeline - Step-by-Step Console Walkthrough
## Personal Finance Goal Tracker - Visual Setup Guide

**This is a hands-on guide to set up CodePipeline using AWS Console with screenshots/text descriptions**

---

## Quick Setup Checklist

```
[ ] Step 1: Get AWS Account ID (5 min)
[ ] Step 2: Create IAM Roles (10 min)
[ ] Step 3: Create ECR Repositories (5 min)
[ ] Step 4: Create CodeBuild Project (10 min)
[ ] Step 5: Create CodePipeline (10 min)
[ ] Step 6: Connect GitHub (5 min)
[ ] Step 7: Test Pipeline (5 min)

Total Setup Time: ~50 minutes
```

---

## STEP 1: Get Your AWS Account ID (5 min)

### Action 1.1: Find Your Account ID

1. **Log into AWS Console** at https://console.aws.amazon.com
2. Look at **top right corner** of the page
3. Click on your **account name/email**
4. Click **My Account**
5. Scroll down to find **Account ID** (12-digit number)
6. **COPY THIS** - you'll use it 10+ times!

```
Example Account ID: 123456789012
Save this in a notepad: _______________________
```

### Action 1.2: Set Default Region

1. **Top right corner** → Click region dropdown (e.g., "N. Virginia")
2. Select **us-east-1** (or your preferred region, but keep it consistent)
3. All services should be created in the same region

---

## STEP 2: Create IAM Roles (10 min)

These roles give CodePipeline and CodeBuild permission to access your resources.

### Action 2.1: Create CodePipeline Service Role

1. Go to **Services** → **IAM** → **Roles**
2. Click **Create Role** button
3. Select: **AWS Service**
4. Under "Common use cases", find and click **CodePipeline**
5. Click **Next** → **Next** (skip permissions, we'll add them)

6. **Add Permissions:**
   - Search box: type `CodePipeline`
   - ✓ Check: `AWSCodePipelineFullAccess`
   - Search box: type `ECR`
   - ✓ Check: `AmazonEC2ContainerRegistryFullAccess`
   - Search box: type `S3`
   - ✓ Check: `AmazonS3FullAccess`
   - Search box: type `CodeBuild`
   - ✓ Check: `AWSCodeBuildAdminAccess`

7. Click **Next**
8. **Role Name:** `CodePipelineServiceRole`
9. Click **Create Role** ✓

### Action 2.2: Create CodeBuild Service Role

1. Go to **IAM** → **Roles** → Click **Create Role**
2. Select: **AWS Service**
3. Find and click **CodeBuild**
4. Click **Next**

5. **Add Permissions:**
   - Search `ECR` → ✓ `AmazonEC2ContainerRegistryFullAccess`
   - Search `CloudWatch` → ✓ `CloudWatchLogsFullAccess`
   - Search `S3` → ✓ `AmazonS3FullAccess`
   - Search `EC2` → ✓ `AmazonEC2InstanceProfileForImageBuilder`

6. Click **Next**
7. **Role Name:** `CodeBuildServiceRole`
8. Click **Create Role** ✓

### Action 2.3: Add Inline ECR Policy to CodeBuild Role

1. Go to **IAM** → **Roles** → Find **CodeBuildServiceRole**
2. Click on it
3. Scroll to **Inline policies** section
4. Click **Add inline policy**
5. Select **JSON** tab
6. **PASTE THIS** (replace YOUR_ACCOUNT_ID with your 12-digit ID):

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
      "Resource": "arn:aws:ecr:us-east-1:YOUR_ACCOUNT_ID:repository/personal-finance/*"
    }
  ]
}
```

7. Click **Review Policy**
8. **Policy Name:** `ECRPushPolicy`
9. Click **Create Policy** ✓

---

## STEP 3: Create ECR Repositories (5 min)

ECR is where your Docker images will be stored.

### Action 3.1: Create 7 ECR Repositories

1. Go to **Services** → **ECR (Elastic Container Registry)**
2. Click **Repositories** (left menu)
3. Click **Create Repository** button

**Create these 7 repositories** (one at a time):

```
Repository 1: personal-finance/authentication-service
Repository 2: personal-finance/user-finance-service
Repository 3: personal-finance/goal-service
Repository 4: personal-finance/insight-service
Repository 5: personal-finance/api-gateway
Repository 6: personal-finance/eureka-server
Repository 7: personal-finance/config-server
```

**For EACH repository:**

1. **Repository Name:** `personal-finance/authentication-service` (example for first one)
2. **Image Tag Mutability:** Disabled
3. **Scan on Push:** ✓ Enable (optional, scans for vulnerabilities)
4. **Encryption:** AWS managed key
5. Click **Create Repository** ✓

**Repeat for all 7 services** (total: 5 min)

---

## STEP 4: Create CodeBuild Project (10 min)

CodeBuild runs your Maven build and Docker commands.

### Action 4.1: Create CodeBuild Project

1. Go to **Services** → **CodeBuild**
2. Click **Projects** (left menu)
3. Click **Create Project** button

### Action 4.2: Configure Project Details

**Section: Project Configuration**
- **Project Name:** `personal-finance-build`
- **Description:** `Build and test Personal Finance application`

### Action 4.3: Configure Source

**Section: Source**
- **Source Provider:** GitHub (Version 2)
- **Repository:** Click **Connect to GitHub**
  - A popup appears → Click **Install a new GitHub App**
  - GitHub opens → Authorize → Install
  - Back to AWS → Repository should be auto-selected
  - Click **Connect**

- **Repository:** `ErenWNL/personal-finance-goal-tracker`
- **Branch:** `main`

**Section: Webhook Events**
- ✓ Check **"Rebuild every time a code change is pushed"**
- Events: **PUSH**

### Action 4.4: Configure Environment

**Section: Environment**
- **Managed Image:** ✓ Select
- **Operating System:** Amazon Linux 2
- **Runtime(s):** Standard
- **Image:** `aws/codebuild/standard:5.0`
- **Image Version:** Latest
- **Compute:** 3 GB memory, 2 vCPU (default)
- **Environment Variables:** Add one:
  - Name: `AWS_ACCOUNT_ID`
  - Value: `YOUR_12_DIGIT_ID`
  - Type: Plaintext

**IMPORTANT: Privileged**
- ✓ **CHECK "Privileged"** (required for Docker)

**Service Role:**
- ✓ **Use an existing role**
- Role: **CodeBuildServiceRole** (created earlier)

### Action 4.5: Configure Buildspec

**Section: Buildspec**
- **Buildspec Name:** `buildspec.yml`
- This tells CodeBuild to use the buildspec.yml file from your repo root

### Action 4.6: Configure Logs

**Section: Logs**
- CloudWatch logs: ✓ **Enable**
- Group Name: `/aws/codebuild/personal-finance-pipeline`
- Stream Name: `codebuild-log-stream`

### Action 4.7: Create Project

Click **Create Build Project** ✓

---

## STEP 5: Create CodePipeline (10 min)

### Action 5.1: Go to CodePipeline

1. Go to **Services** → **CodePipeline**
2. Click **Pipelines** (left menu)
3. Click **Create Pipeline** button

### Action 5.2: Configure Pipeline

**Section: Pipeline Settings**
- **Pipeline Name:** `personal-finance-pipeline`
- **Service Role:** ✓ **Use an existing role** → **CodePipelineServiceRole**
- **Artifact Store:**
  - ✓ **Amazon S3**
  - **S3 Bucket:** Click **Create artifact store**
    - Bucket name: `personal-finance-pipeline-artifacts-YOUR_ACCOUNT_ID`
    - (Replace YOUR_ACCOUNT_ID with actual ID)
    - Click **Create**
  - **Encryption Key:** AWS managed key
- Click **Next**

### Action 5.3: Add Source Stage

**Section: Source Stage**
- **Source Provider:** GitHub (Version 2)
- **Repository Owner:** `ErenWNL`
- **Repository Name:** `personal-finance-goal-tracker`
- **Branch:** `main`
- **Webhook Events:**
  - ✓ Check **"Start pipeline on source code change"**
  - Event Type: **Push**
- Click **Next**

### Action 5.4: Add Build Stage

**Section: Build Stage**
- **Build Provider:** AWS CodeBuild
- **Project Name:** `personal-finance-build`
- **Build Type:** Single Build
- Click **Next**

### Action 5.5: Skip Deploy Stage (For Now)

**Section: Deploy Stage**
- **Deploy Provider:** ⊙ **Skip Deploy Stage** (we'll add this later with RDS/EC2)
- Click **Next**

### Action 5.6: Review & Create

1. Click **Create Pipeline** button ✓
2. Wait for pipeline to be created (30 seconds)
3. You should see:
   ```
   Pipeline Status: SUCCEEDED
   Source: Green ✓
   Build: Green ✓
   ```

---

## STEP 6: Configure GitHub Integration (5 min)

### Action 6.1: Update buildspec.yml in Your Repo

1. Go to your GitHub repo: https://github.com/ErenWNL/personal-finance-goal-tracker
2. Click **buildspec.yml** file
3. Click **Edit** (pencil icon)
4. Find this line:
   ```yaml
   AWS_ACCOUNT_ID: "YOUR_AWS_ACCOUNT_ID"
   ```
5. Replace with your actual 12-digit ID:
   ```yaml
   AWS_ACCOUNT_ID: "123456789012"
   ```
6. Click **Commit changes** ✓

### Action 6.2: Verify Webhook in GitHub

1. Go to repo → **Settings** → **Webhooks**
2. You should see `api.github.com` webhook
3. Green checkmark = webhook is active ✓

---

## STEP 7: Test Pipeline (5 min)

### Action 7.1: Trigger Your First Build

1. Go to GitHub repo
2. Make a tiny change to any file (e.g., add comment to README)
3. Commit and push:
   ```bash
   git add README.md
   git commit -m "Test CodePipeline build"
   git push origin main
   ```

### Action 7.2: Watch Pipeline Execute

1. Go to **AWS CodePipeline** → **Pipelines**
2. Click **personal-finance-pipeline**
3. Watch the stages:

   **Stage 1: Source** (1 min)
   - Fetching code from GitHub
   - Status: In Progress → Success ✓

   **Stage 2: Build** (5-10 min)
   - Running Maven build
   - Running Docker builds
   - Pushing to ECR
   - Status: In Progress → Success ✓

4. Once Build stage finishes, click it to see detailed logs

### Action 7.3: View Build Logs

1. In Build stage, click the **CodeBuild** link
2. Click **Build ID** link
3. Scroll down to see detailed build output:

   ```
   [INFO] Building personal-finance-goal-tracker
   [INFO] Maven compilation: SUCCESS
   [INFO] Running tests...
   [INFO] Building Docker images...
   ✓ authentication-service built
   ✓ user-finance-service built
   ✓ goal-service built
   ✓ insight-service built
   ✓ api-gateway built
   [INFO] Pushing to ECR...
   ```

### Action 7.4: Verify Images in ECR

1. Go to **ECR** → **Repositories**
2. Click **personal-finance/authentication-service**
3. You should see images like:
   ```
   authentication-service:ab12cd34
   authentication-service:latest
   ```

4. Repeat for other services ✓

---

## CONGRATULATIONS! 🎉

Your CodePipeline is now set up and automated!

### What happens now:

1. **Every time you push to GitHub main:**
   - CodePipeline detects the change (webhook)
   - CodeBuild runs your buildspec.yml
   - Maven compiles your code
   - Tests run
   - Docker images build
   - Images push to ECR

2. **Your Docker images are ready for:**
   - Deployment to EC2
   - Deployment to ECS Fargate
   - Deployment to Kubernetes
   - Local docker-compose (pull from ECR)

---

## Cost Summary So Far

```
CodePipeline:   $1/month
CodeBuild:      ~$9/month (60 min/day average)
ECR Storage:    ~$2/month
S3 Artifacts:   <$1/month
CloudWatch:     <$1/month
─────────────────────────
TOTAL:          ~$13/month

Remaining Budget: $60 - $13 = $47 ✅
```

---

## Next Phase: Add RDS Database

When ready, we'll:
1. Create AWS RDS MySQL instance
2. Update service application.properties
3. Remove Docker MySQL dependency
4. Cost: ~$15/month

Would you like to proceed with RDS setup?

---

## Useful Quick Links

- [CodePipeline Console](https://console.aws.amazon.com/codepipeline)
- [CodeBuild Console](https://console.aws.amazon.com/codebuild)
- [ECR Console](https://console.aws.amazon.com/ecr)
- [IAM Roles](https://console.aws.amazon.com/iam/home#/roles)
- [CloudWatch Logs](https://console.aws.amazon.com/logs)

---

## Troubleshooting Quick Tips

**Pipeline stuck on Source stage?**
- Check GitHub webhook in repo settings
- Verify CodePipeline GitHub connection is active

**Build failing with Docker error?**
- Verify Privileged ✓ is enabled in CodeBuild
- Check CodeBuildServiceRole has ECR permissions

**Images not appearing in ECR?**
- Check CodeBuild logs for docker push errors
- Verify ECR repositories exist
- Check buildspec.yml has correct repository names

**Build timeout?**
- Increase CodeBuild timeout limit (default 60 min)
- Optimize buildspec.yml (cache Maven, parallel builds)

---

**Setup Completed:** Ready for deployment integration!
