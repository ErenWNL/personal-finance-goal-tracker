# Jenkins + GitHub Integration Guide
## Personal Finance Goal Tracker - CI/CD Setup

---

## Overview

This guide sets up **GitHub webhooks** to trigger Jenkins builds automatically when code is pushed to the main branch.

**What happens:**
```
GitHub Push to main
    ↓ (Webhook)
Jenkins receives notification
    ↓
Jenkins runs Jenkinsfile
    ↓
Pulls Docker images from Docker Hub
    ↓
Runs docker-compose up
    ↓
Services deployed and running
```

---

## Prerequisites

- [ ] Jenkins installed and running (you already have this)
- [ ] GitHub repository: `ErenWNL/personal-finance-goal-tracker`
- [ ] Docker installed on Jenkins server
- [ ] docker-compose installed on Jenkins server
- [ ] Jenkinsfile in repo root (already created)

---

## STEP 1: Install Required Jenkins Plugins

### Action 1.1: Install GitHub Plugin

1. Go to **Jenkins Dashboard**
2. Click **Manage Jenkins** (left menu)
3. Click **Manage Plugins**
4. Go to **Available** tab
5. Search for: `GitHub Integration Plugin`
6. Check the box next to **GitHub Integration Plugin**
7. Click **Install without restart**
8. Wait for installation to complete

### Action 1.2: Install GitHub Branch Source Plugin (Optional but Recommended)

1. In **Available** plugins tab
2. Search for: `GitHub Branch Source`
3. Check and install

### Action 1.3: Verify Plugins Installed

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Go to **Installed** tab
3. Verify you see:
   - `GitHub Integration Plugin`
   - `Git Plugin` (should already be there)

---

## STEP 2: Create GitHub Personal Access Token

### Action 2.1: Generate Token on GitHub

1. Go to **GitHub** → **Settings** (top right) → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. **Token name:** `Jenkins CI/CD`
4. **Expiration:** 90 days (or No expiration)
5. **Select scopes:**
   - ✓ `repo` (full control of private repositories)
   - ✓ `admin:repo_hook` (write access to hooks)
   - ✓ `admin:org_hook` (admin of organization hooks)

6. Click **Generate token**
7. **COPY THE TOKEN** immediately (you'll only see it once!)

```
Token format: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
Save this: _________________________________
```

---

## STEP 3: Add GitHub Credentials to Jenkins

### Action 3.1: Add GitHub Token to Jenkins Credentials

1. Go to **Jenkins Dashboard**
2. Click **Manage Jenkins** → **Manage Credentials**
3. Click **System** (if you don't see it, click the domain you use)
4. Click **Global credentials (unrestricted)**
5. Click **Add Credentials** (left menu)

### Action 3.2: Configure Credentials

1. **Kind:** Select `Secret text`
2. **Secret:** Paste your GitHub token (from Step 2)
3. **ID:** `github-token`
4. **Description:** `GitHub Personal Access Token for Jenkins`
5. Click **Create**

### Action 3.3: Add Docker Hub Credentials (For pulling images)

1. Click **Add Credentials** again
2. **Kind:** Select `Username with password`
3. **Username:** Your Docker Hub username
4. **Password:** Your Docker Hub password (or token)
5. **ID:** `dockerhub-credentials`
6. **Description:** `Docker Hub credentials`
7. Click **Create**

### Action 3.4: Alternative - Add separate Docker Hub Username/Password

If you want to use them separately in Jenkins:

1. **Add Credentials** → **Secret text**
2. **Secret:** Your Docker Hub username
3. **ID:** `dockerhub-username`
4. Click **Create**

5. **Add Credentials** → **Secret text**
6. **Secret:** Your Docker Hub password
7. **ID:** `dockerhub-password`
8. Click **Create**

---

## STEP 4: Create Jenkins Pipeline Job

### Action 4.1: Create New Job

1. Go to **Jenkins Dashboard**
2. Click **New Item** (left menu)
3. **Job name:** `personal-finance-pipeline`
4. **Job type:** Select `Pipeline`
5. Click **OK**

### Action 4.2: Configure General Settings

**General Section:**
- Description: `Personal Finance Goal Tracker - CI/CD Pipeline`
- ✓ Check **GitHub project**
- **Project url:** `https://github.com/ErenWNL/personal-finance-goal-tracker/`

### Action 4.3: Configure Build Triggers

**Build Triggers Section:**
- ✓ Check **GitHub hook trigger for GITscm polling**
  (This enables webhook trigger)

### Action 4.4: Configure Pipeline

**Pipeline Section:**
- **Definition:** Select `Pipeline script from SCM`
- **SCM:** Select `Git`

**Git Configuration:**
- **Repository URL:** `https://github.com/ErenWNL/personal-finance-goal-tracker.git`
- **Credentials:** Select `- none -` (public repo, no auth needed)
- **Branch Specifier:** `*/main`
- **Script Path:** `Jenkinsfile` (default - this file will be used)

### Action 4.5: Save Job

Click **Save**

---

## STEP 5: Create GitHub Webhook

### Action 5.1: Add Webhook to GitHub Repository

1. Go to **GitHub** → Your repo → **Settings** → **Webhooks**
2. Click **Add webhook**

### Action 5.2: Configure Webhook

Fill in:
- **Payload URL:** `http://YOUR_JENKINS_URL:8080/github-webhook/`

  Replace `YOUR_JENKINS_URL` with:
  - If local: `http://localhost:8080/github-webhook/`
  - If remote: `http://your-server-ip:8080/github-webhook/`
  - If using domain: `http://jenkins.yourdomain.com/github-webhook/`

- **Content type:** `application/json`
- **Events:** Select these:
  - ✓ `Just the push event`

- **Active:** ✓ Check this

Click **Add webhook**

### Action 5.3: Test Webhook

1. In Webhooks list, you should see your webhook
2. Click on it
3. Scroll down to **Recent Deliveries**
4. Click the latest delivery
5. Check if it shows green checkmark (successful)

If red X:
- Check your Jenkins URL is accessible from GitHub
- Verify Jenkins is running
- Check firewall allows inbound webhooks

---

## STEP 6: Configure Credentials in Jenkins Job

### Action 6.1: Update Pipeline to Use Credentials

The Jenkinsfile expects these credentials to exist:
- `github-credentials` - GitHub access
- `dockerhub-username` - Docker Hub username
- `dockerhub-password` - Docker Hub password

If you named them differently, update the Jenkinsfile:

In **Jenkinsfile**, find:
```groovy
environment {
    DOCKER_HUB_USERNAME = credentials('dockerhub-username')
    DOCKER_HUB_PASSWORD = credentials('dockerhub-password')
}
```

Replace credential IDs with your actual credential IDs.

---

## STEP 7: Test the Pipeline

### Action 7.1: Manual Trigger

1. Go to Jenkins → **personal-finance-pipeline**
2. Click **Build Now** (left menu)
3. Watch the build progress in **Build History**
4. Click the build number to see logs

### Action 7.2: Check Logs

Expected output:
```
Stage 1: Checkout Code
✓ Code checked out successfully

Stage 2: Pull Docker Images from Docker Hub
Pulling authentication-service...
✓ Successfully pulled: authentication-service:latest

Stage 3: Prepare Deployment
✓ Deployment directory prepared

Stage 4: Stop Running Containers
✓ Containers stopped

Stage 5: Start Services with Docker Compose
✓ Services started successfully

Stage 6: Health Check
✓ Health check completed

Services available at:
  - Frontend: http://localhost:3000
  - API Gateway: http://localhost:8081
  - Eureka: http://localhost:8761
```

### Action 7.3: Trigger from GitHub (Webhook Test)

1. Go to your GitHub repo
2. Make a small change (e.g., add a comment to README)
3. Commit and push to main:
   ```bash
   git add README.md
   git commit -m "Test Jenkins webhook"
   git push origin main
   ```

4. Go to Jenkins → **personal-finance-pipeline**
5. You should see a new build triggered automatically
6. Check **Build History** - new build should appear within 30 seconds

---

## STEP 8: Docker Hub Credentials

### Action 8.1: Check Which Services Exist on Docker Hub

If you want to verify your images are on Docker Hub:

```bash
# Check your Docker Hub account
curl -s https://hub.docker.com/v2/repositories/YOUR_USERNAME/?page_size=100 | grep name

# Or login and check locally
docker login
docker search personalfinance
```

### Action 8.2: Update Jenkinsfile If Image Names Are Different

If your Docker Hub images are named differently, update this line in **Jenkinsfile**:

```groovy
docker pull personalfinance/$service:latest
```

Change to your actual Docker Hub namespace:
```groovy
docker pull YOUR_DOCKERHUB_USERNAME/$service:latest
```

---

## Troubleshooting

### Issue: Webhook Not Triggering Build

**Checklist:**
1. ✓ GitHub webhook is green (successful)
2. ✓ Jenkins URL is accessible from GitHub (public IP or domain)
3. ✓ `GitHub hook trigger for GITscm polling` is checked in Jenkins job
4. ✓ Branch specifier is `*/main`

**Fix:**
- Test webhook delivery in GitHub → Webhooks → Click webhook → Redeliver latest
- Check Jenkins logs: `Manage Jenkins` → `System Log`

### Issue: "docker: command not found" in Build

**Problem:** Jenkins agent can't find Docker

**Fix:**
1. Ensure Docker is installed on Jenkins server
2. Add Jenkins user to docker group: `sudo usermod -aG docker jenkins`
3. Restart Jenkins: `sudo systemctl restart jenkins`

### Issue: "docker-compose: command not found"

**Problem:** docker-compose not installed

**Fix:**
```bash
# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker-compose --version
```

### Issue: "Cannot connect to Docker Hub"

**Problem:** Docker login fails

**Fix:**
1. Verify credentials are correct
2. Check Docker Hub username is correct
3. If using 2FA, use Personal Access Token instead of password
4. Test locally: `echo $PASSWORD | docker login -u $USERNAME --password-stdin`

### Issue: Deployment Directory Permission Denied

**Problem:** Jenkins can't write to `/home/jenkins/deployments/`

**Fix:**
```bash
# Create directory with proper permissions
sudo mkdir -p /home/jenkins/deployments/personal-finance
sudo chown jenkins:jenkins /home/jenkins/deployments
sudo chmod 755 /home/jenkins/deployments
```

---

## Next Steps

Once Jenkins pipeline is working:

1. **Monitor Builds:** Check Jenkins dashboard after each GitHub push
2. **Check Running Services:** Visit http://localhost:3000 to verify frontend is running
3. **View Logs:** `docker-compose logs -f` in deployment directory
4. **Stop Services:** `docker-compose down` to stop all containers

---

## Useful Commands

```bash
# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check Docker daemon
sudo systemctl status docker

# Check Jenkins status
sudo systemctl status jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# View running containers
docker ps

# View specific container logs
docker logs container_name

# SSH to Jenkins server (if remote)
ssh jenkins-user@jenkins-server

# Check webhook status
# GitHub repo → Settings → Webhooks → Click webhook
```

---

## Summary

You now have:
- ✅ GitHub webhook that triggers Jenkins on every push to main
- ✅ Jenkins pipeline that pulls Docker images from Docker Hub
- ✅ Automated deployment via docker-compose
- ✅ Health checks for running services

**Cost:** Free (using Jenkins + GitHub webhooks)

Next: Integrate RDS, SNS, CloudWatch when ready.

---

**Last Updated:** November 2025
**Status:** Ready for use
