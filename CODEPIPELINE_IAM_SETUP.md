# AWS IAM Roles Setup for CodePipeline
## Correct Step-by-Step Instructions

---

## STEP 1: Create CodePipeline Service Role

### Action 1.1: Create the Role

1. Go to **AWS Console** → **IAM** → **Roles**
2. Click **Create Role**
3. **Select trusted entity type:**
   - Select: **AWS Service**
4. **Search and select service:**
   - In the search box, type: `codepipeline`
   - **DO NOT** look for "CodePipeline" in use cases
   - Click on **AWS CodePipeline** (the service option)
5. Click **Next**

### Action 1.2: Add Permissions

On the "Add permissions" page:

1. Search for and check these policies:
   - [ ] `AWSCodePipelineFullAccess`
   - [ ] `AmazonEC2ContainerRegistryFullAccess`
   - [ ] `AmazonS3FullAccess`
   - [ ] `AWSCodeBuildAdminAccess`

2. Click **Next**

### Action 1.3: Name the Role

- **Role name:** `CodePipelineServiceRole`
- Click **Create role** ✓

---

## STEP 2: Create CodeBuild Service Role

### Action 2.1: Create the Role

1. Go to **IAM** → **Roles** → **Create Role**
2. **Select trusted entity type:**
   - Select: **AWS Service**
3. **Search and select service:**
   - In the search box, type: `codebuild`
   - Click on **AWS CodeBuild** (the service option)
4. Click **Next**

### Action 2.2: Add Permissions

1. Search for and check these policies:
   - [ ] `AmazonEC2ContainerRegistryFullAccess`
   - [ ] `CloudWatchLogsFullAccess`
   - [ ] `AmazonS3FullAccess`
   - [ ] `AmazonEC2InstanceProfileForImageBuilder`

2. Click **Next**

### Action 2.3: Name the Role

- **Role name:** `CodeBuildServiceRole`
- Click **Create role** ✓

---

## STEP 3: Add Inline Policy to CodeBuild Role (IMPORTANT)

This allows CodeBuild to push Docker images to ECR.

### Action 3.1: Go to the Role

1. Go to **IAM** → **Roles**
2. Find and click: **CodeBuildServiceRole**

### Action 3.2: Add Inline Policy

1. Scroll down to **Inline policies** section
2. Click **Add inline policy**
3. Select **JSON** tab
4. **PASTE THIS CODE** (replace `YOUR_ACCOUNT_ID` with your 12-digit AWS Account ID):

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

5. Click **Review policy**
6. **Policy name:** `ECRPushPolicy`
7. Click **Create policy** ✓

---

## Summary

You now have:
- ✅ **CodePipelineServiceRole** - Can orchestrate pipelines, build, deploy
- ✅ **CodeBuildServiceRole** - Can run builds and push to ECR

Both roles are ready for CodePipeline setup.

---

**Next Step:** Create ECR repositories
