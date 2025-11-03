# Jenkins Automation Guide
## Automated Git Commits & Docker Version Updates

---

## Overview

The updated **Jenkinsfile** now includes **automatic version tagging and GitHub commits**:

```
Code Update
    ↓ (Push to main)
Jenkins Webhook Triggered
    ↓
Jenkins pulls latest code
    ↓
Pulls Docker images from Docker Hub
    ↓
Starts containers with docker-compose
    ↓
Updates docker-compose.yml with new version tags
    ↓
Auto-commits and pushes changes back to GitHub
    ↓
Services running with latest versions
```

---

## Pipeline Stages

### Stage 1: Checkout Code
- Pulls latest code from GitHub main branch
- Configures git user for Jenkins commits
- Stores commit hash

### Stage 2: Pull Docker Images from Docker Hub
- Logs in to Docker Hub
- Pulls all 7 service images
- Uses `latest` tag by default

### Stage 3: Prepare Deployment
- Creates deployment directory
- Copies docker-compose.yml
- Copies environment files

### Stage 4: Stop Running Containers
- Gracefully stops existing containers
- Cleans up old deployments

### Stage 5: Start Services with Docker Compose
- Runs `docker-compose up -d`
- Waits for services to start

### Stage 6: Health Check
- Pings API Gateway (8081)
- Pings Eureka Server (8761)
- Verifies services are responding

### **Stage 7: Update Version & Commit** ⭐ (NEW)
- Generates version tag: `{BUILD_NUMBER}_{COMMIT_HASH}`
- Updates docker-compose.yml with new image versions
- **Auto-commits** to GitHub
- **Auto-pushes** to main branch
- Example: `Update Docker image versions: Build #25 (a1b2c3d)`

### Stage 8: Notify
- Reports success/failure
- (Optional) Sends Slack notification

---

## How It Works

### Version Tagging Strategy

Each build gets a **unique version tag**:

```
Version Format: {BUILD_NUMBER}_{COMMIT_HASH}

Examples:
├─ Build 25 of commit a1b2c3d → Version: 25_a1b2c3d
├─ Build 26 of commit f4e5d6c → Version: 26_f4e5d6c
└─ Build 27 of commit 9k8l7m6 → Version: 27_9k8l7m6
```

### Automatic docker-compose.yml Updates

**Before (using latest tag):**
```yaml
services:
  authentication-service:
    image: personalfinance/authentication-service:latest
  api-gateway:
    image: personalfinance/api-gateway:latest
```

**After (using versioned tag):**
```yaml
services:
  authentication-service:
    image: personalfinance/authentication-service:25_a1b2c3d
  api-gateway:
    image: personalfinance/api-gateway:25_a1b2c3d
```

### Git Commit History

Every successful build creates a commit in GitHub:

```
GitHub Commit Log:
├─ Update Docker image versions: Build #27 (9k8l7m6) ✓
├─ Update Docker image versions: Build #26 (f4e5d6c) ✓
├─ Update Docker image versions: Build #25 (a1b2c3d) ✓
├─ Update authentication service code
├─ Fix API gateway routing
└─ Initial commit
```

---

## How to Use

### Step 1: Make Code Changes

```bash
# Update any service code
vi authentication-service/src/main/java/...

# Commit locally (optional - Jenkins will do this)
git add .
git commit -m "Update authentication service"
```

### Step 2: Push to GitHub

```bash
git push origin main
```

### Step 3: Jenkins Automatically:

1. **Detects** the push via webhook
2. **Pulls** latest code
3. **Pulls** Docker images from Docker Hub
4. **Starts** services with docker-compose
5. **Updates** docker-compose.yml with new versions
6. **Commits** the changes back to GitHub
7. **Reports** success

---

## Benefits

✅ **Automatic version tracking** - Every build is tagged uniquely
✅ **Deployment history** - Can rollback to any previous version
✅ **No manual commits** - Jenkins handles all git operations
✅ **Immutable releases** - Each version is locked to specific commit
✅ **Audit trail** - Git shows exactly when each deployment happened

---

## Jenkins Setup Requirements

### Credentials Needed

1. **GitHub Credentials** (for git push)
   - ID: `github-credentials`
   - Type: Personal Access Token
   - Scope: repo + admin:repo_hook

2. **Docker Hub Credentials** (for docker pull)
   - ID: `dockerhub-username`
   - ID: `dockerhub-password`

### Git Configuration

Jenkins automatically configures:
```
git config user.email "jenkins@personal-finance.io"
git config user.name "Jenkins CI"
```

These are used for auto-commits.

---

## Troubleshooting

### Issue: "Permission denied" when pushing to GitHub

**Problem:** Jenkins doesn't have permission to push

**Solution:**
1. Go to Jenkins → Manage Credentials
2. Update GitHub credentials with valid Personal Access Token
3. Token must have `repo` and `admin:repo_hook` scopes
4. Test in Jenkins Script Console:
   ```groovy
   'git push origin main'.execute()
   ```

### Issue: "Docker Hub login failed"

**Problem:** Docker Hub credentials incorrect

**Solution:**
1. Verify credentials in Jenkins
2. Test locally: `echo $PASSWORD | docker login -u $USERNAME --password-stdin`
3. If using 2FA, use Personal Access Token instead of password

### Issue: "sed: command not found" on macOS Jenkins

**Problem:** Jenkins running on macOS doesn't have `sed` with `-i` flag

**Solution:**
Install GNU sed or use compatible version:
```bash
brew install gnu-sed
ln -s /usr/local/bin/gsed /usr/local/bin/sed
```

### Issue: Git push creates infinite loop

**Problem:** Jenkins pushes → Webhook triggers → Jenkins pushes again...

**Solution:**
Add this to Jenkinsfile to prevent recursion:
```groovy
environment {
    GIT_SKIP_WEBHOOK = 'true'
}
```

Or configure webhook to skip certain commit messages:
```
GitHub Webhooks → Skip building on commits with message containing: [skip ci]
```

---

## Advanced Customization

### Custom Version Format

To change version format, edit Stage 7:

**Current:**
```bash
VERSION="${BUILD_NUM}_${COMMIT_HASH}"
```

**Alternative 1: Date-based**
```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VERSION="${TIMESTAMP}_${COMMIT_HASH}"
# Example: 20251103_142530_a1b2c3d
```

**Alternative 2: Semantic Versioning**
```bash
VERSION="v1.0.${BUILD_NUM}"
# Example: v1.0.25
```

### Custom Commit Message

Edit this line in Stage 7:
```bash
git commit -m "Update Docker image versions: Build #${BUILD_NUMBER} (${COMMIT_HASH})"
```

Example alternatives:
```bash
# Include timestamp
git commit -m "Deploy Build #${BUILD_NUMBER} - $(date '+%Y-%m-%d %H:%M:%S')"

# Include service info
git commit -m "[DEPLOYMENT] Build #${BUILD_NUMBER} deployed with images from commit ${COMMIT_HASH}"

# Add emoji
git commit -m "🚀 Build #${BUILD_NUMBER} deployed successfully"
```

### Selective Service Updates

If you only want to update specific services:

```bash
# Only update authentication-service
sed -i "s|personalfinance/authentication-service:.*|personalfinance/authentication-service:${VERSION}|g" docker-compose.yml

# Skip others
# sed -i "s|personalfinance/user-finance-service:.*|...|g" docker-compose.yml  # SKIP
```

---

## Monitoring Automation

### View Auto-Generated Commits

```bash
# View last 10 commits
git log --oneline -10

# View commits from Jenkins
git log --grep="Update Docker image versions" --oneline

# View specific build deployment
git log --grep="Build #25" --oneline
```

### View Jenkins Build Logs

1. Jenkins Dashboard → personal-finance-pipeline
2. Click build number (e.g., #25)
3. Click "Console Output"
4. Scroll to "Update Version & Commit" stage

Expected output:
```
Stage 7: Update Docker Image Versions
Updating docker-compose.yml with new image versions...
New Version Tag: 25_a1b2c3d
Updating docker-compose.yml with version: 25_a1b2c3d
✓ docker-compose.yml updated

Changes made:
- authentication-service: latest → 25_a1b2c3d
- user-finance-service: latest → 25_a1b2c3d
- ... (5 more services)

Committing changes to GitHub...
✓ Version update committed and pushed
```

### View Git Status

After Jenkins run:
```bash
git log --oneline | head -5
git diff HEAD~1 docker-compose.yml
git show HEAD --stat
```

---

## Common Scenarios

### Scenario 1: Code Update Flow

```
1. Edit authentication-service code
   git add .
   git commit -m "Fix auth token validation"
   git push origin main
   ↓
2. GitHub webhook triggers Jenkins
   ↓
3. Jenkins:
   - Pulls code
   - Pulls images (personalfinance/authentication-service:latest)
   - Starts containers
   - Updates docker-compose.yml:
     authentication-service: latest → Build_25_a1b2c3d
   - Commits: "Update Docker image versions: Build #25 (a1b2c3d)"
   - Pushes to main
   ↓
4. Services running with new code via Docker image
   ↓
5. docker-compose.yml is updated in GitHub with versioned tags
```

### Scenario 2: Rolling Back

If a build fails:

```bash
# Check git log for last successful build
git log --oneline | head -10

# Revert docker-compose.yml to previous build
git revert <commit-hash>
git push origin main

# Jenkins will redeploy with previous versions
```

### Scenario 3: Forcing a Rebuild

To rebuild without code changes:

```bash
# Jenkins provides "Build Now" button
Jenkins → personal-finance-pipeline → Build Now

# Or trigger via curl:
curl -X POST http://jenkins-url:8080/job/personal-finance-pipeline/build \
  -H "Authorization: Basic $(echo -n user:token | base64)"
```

---

## Security Considerations

### Git Credentials

- Jenkins stores credentials securely
- Credentials are masked in logs (no passwords visible)
- Use Personal Access Tokens (not passwords)
- Regularly rotate tokens (90+ day expiration recommended)

### Docker Hub Credentials

- Same security as git credentials
- Use Personal Access Tokens for Docker Hub as well
- Consider private Docker registry for sensitive images

### GitHub Webhook Security

- Webhook is HTTPS (if Jenkins is accessible via HTTPS)
- Add GitHub webhook secret in Jenkins configuration
- Verify webhook source is GitHub

---

## Summary

The updated Jenkinsfile now provides:

✅ **Automatic git commits** - Version tags recorded in GitHub
✅ **Version tracking** - Each build uniquely tagged
✅ **Deployment history** - Full audit trail in git
✅ **No manual steps** - Push code → Automated deployment
✅ **Easy rollback** - Revert to any previous version

Just push code to main, Jenkins handles everything else!

---

**Configuration:** Done in Jenkinsfile
**Trigger:** GitHub webhook on push to main
**Frequency:** Automatic on every push
**Status:** Ready to use

---

**Last Updated:** November 2025
