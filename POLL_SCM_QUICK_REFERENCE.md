# Poll SCM Quick Reference
## Jenkins + GitHub Integration (Simplified)

---

## What is Poll SCM?

**Poll SCM** = Jenkins automatically checks GitHub for new commits every 5 minutes

```
No webhook needed ✓
Works on localhost ✓
Simple setup ✓
```

---

## Setup (Super Quick)

### Step 1: Create Jenkins Job
```
Jenkins → New Item
Name: personal-finance-pipeline
Type: Pipeline
Click: OK
```

### Step 2: Add Credentials
```
Jenkins → Manage Jenkins → Manage Credentials
  → System → Global credentials
  → Add Credentials

Credential 1:
  Kind: Secret text
  Secret: YOUR_DOCKERHUB_USERNAME
  ID: dockerhub-username

Credential 2:
  Kind: Secret text
  Secret: YOUR_DOCKERHUB_PASSWORD
  ID: dockerhub-password
```

### Step 3: Configure Job

**Fill in these fields:**

```
GENERAL:
  ✓ GitHub project
  Project url: https://github.com/ErenWNL/personal-finance-goal-tracker/

BUILD TRIGGERS:
  ✓ Poll SCM
  Schedule: H/5 * * * *

PIPELINE:
  Definition: Pipeline script from SCM
  SCM: Git
    Repository URL: https://github.com/ErenWNL/personal-finance-goal-tracker.git
    Credentials: - none -
    Branch Specifier: */main
    Script Path: Jenkinsfile

Save
```

---

## How It Works

```
Every 5 minutes:
├─ Jenkins checks GitHub for new commits
├─ If new commit found:
│  ├─ Pulls code
│  ├─ Runs Jenkinsfile
│  ├─ Pulls Docker images
│  ├─ Starts containers
│  ├─ Updates docker-compose.yml
│  ├─ Auto-commits to GitHub
│  └─ Done!
└─ If no new commits:
   └─ Waits 5 more minutes
```

---

## Test It

### Make a Change
```bash
# Edit any file
vi README.md

# Commit and push
git add .
git commit -m "Test Jenkins Poll SCM"
git push origin main
```

### Watch Jenkins
```
1. Go to Jenkins Dashboard
2. Click: personal-finance-pipeline
3. Wait 0-5 minutes
4. Build #1 should start automatically
5. Click the build number to see logs
```

---

## Schedule Syntax (H/5 * * * *)

```
H/5 * * * *
├─ H/5 = Every 5 minutes (at varying minute)
├─ * = Every hour
├─ * = Every day
├─ * = Every month
└─ * = Every day of week

COMMON OPTIONS:
├─ H/5 * * * * = Every 5 minutes (RECOMMENDED)
├─ H/15 * * * * = Every 15 minutes
├─ H * * * * = Once per hour
├─ H 8 * * * = Daily at 8 AM
└─ H H/6 * * * = Every 6 hours
```

---

## Advantages

✅ No webhook needed
✅ Works on localhost
✅ Works behind firewall
✅ Simple setup
✅ No external tools

## Disadvantages

⚠️ Slight delay (0-5 minutes)
⚠️ More frequent GitHub API calls

---

## Troubleshooting

### Build not starting?

1. Check Poll SCM is enabled:
   ```
   Jenkins → personal-finance-pipeline → Configure
   Build Triggers → ✓ Poll SCM (must be checked)
   ```

2. Check credentials are correct:
   ```
   Jenkins → Manage Credentials
   Verify: dockerhub-username and dockerhub-password exist
   ```

3. Check Git Repository URL:
   ```
   Must be exactly: https://github.com/ErenWNL/personal-finance-goal-tracker.git
   ```

4. Check Jenkinsfile exists in repo root:
   ```bash
   ls -la /path/to/repo/Jenkinsfile
   # Should exist and be readable
   ```

5. Force a poll check:
   ```
   Jenkins → personal-finance-pipeline → Build Now
   (This manually triggers the job)
   ```

### Build fails with git error?

Check the Git plugin is installed:
```
Jenkins → Manage Plugins → Installed
Search: "Git plugin"
Should be there and checked
```

### Docker images not pulling?

Check Docker Hub credentials:
```
Jenkins → Manage Credentials
Verify: dockerhub-username and dockerhub-password
Test: docker login -u YOUR_USERNAME -p YOUR_PASSWORD
```

---

## Monitoring

### View Recent Builds
```
Jenkins → personal-finance-pipeline → Build History
Shows: Last 10+ builds with timestamps
```

### View Build Logs
```
Jenkins → personal-finance-pipeline → Click build number
Shows: Full console output with timestamps
```

### View Git Commits from Jenkins
```bash
cd /path/to/repo
git log --oneline | head -10
# Look for commits with message:
# "Update Docker image versions: Build #X"
```

---

## Performance

```
Poll SCM Frequency: Every 5 minutes
Build Time: 3-5 minutes (average)

Timeline:
├─ Minute 0: Push code to GitHub
├─ Minute 5: Jenkins detects change (next poll)
├─ Minute 5-10: Build runs
├─ Minute 10: Services deployed
├─ Minute 11: New commit pushed to GitHub
└─ Total latency: 5-11 minutes
```

---

## Summary

1. **Setup:** 5 minutes (2 steps)
2. **Trigger:** Every 5 minutes automatically
3. **Latency:** 0-5 minutes (next poll cycle)
4. **Maintenance:** None (Jenkins handles it)
5. **Cost:** Free

---

**That's it! Just push code to GitHub, Jenkins handles the rest.**

---

**Last Updated:** November 2025
**Status:** Ready to use
