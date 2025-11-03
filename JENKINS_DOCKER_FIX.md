# Fix Jenkins Docker Access
## Jenkins Cannot Find Docker Command

**Error:**
```
docker: command not found
```

This means Jenkins is running as a user that doesn't have Docker in their PATH.

---

## Solution (2 Steps)

### Step 1: Add Jenkins User to Docker Group

```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Or if Jenkins runs as _jenkins on macOS:
sudo usermod -aG docker _jenkins

# Or for current user:
sudo usermod -aG docker $(whoami)
```

### Step 2: Restart Jenkins

```bash
# macOS with Homebrew:
brew services restart jenkins-lts

# Or manually:
# 1. Go to Jenkins → Manage Jenkins → Shutdown
# 2. Wait for Jenkins to stop
# 3. Restart from terminal or Activity Monitor
```

---

## Verify Docker Works

After restart, check if docker command is found:

```bash
# From Jenkins shell:
Jenkins → Build Now → Stage: Verify Docker & Docker Compose

Should show:
✓ Docker version 20.x.x
✓ Docker Compose version 2.x.x
```

---

## Alternative: Use Full Docker Path

If adding to docker group doesn't work, you can use the full path:

In Jenkinsfile, change:
```bash
docker --version
```

To:
```bash
/usr/local/bin/docker --version
```

But the user group method is better.

---

## Check Current Jenkins User

To see which user Jenkins is running as:

```bash
# macOS:
ps aux | grep jenkins

# Look for: jenkins or _jenkins
```

Then add that user to docker group:

```bash
sudo usermod -aG docker jenkins
# or
sudo usermod -aG docker _jenkins
```

---

## Restart Jenkins and Test

```
1. Jenkins → Manage Jenkins → Shutdown
2. Wait 30 seconds for shutdown
3. Start Jenkins again (Homebrew will auto-start, or manually start)
4. Jenkins → finance-pipeline → Build Now
5. Check Stage 2: Verify Docker & Docker Compose
6. Should show Docker versions now ✓
```

---

## If Still Not Working

Check Jenkins log for errors:

```bash
# macOS Homebrew Jenkins logs:
tail -f /usr/local/var/log/jenkins/jenkins.log

# Or via Jenkins UI:
Jenkins → System Log → All → Watch for docker errors
```

---

**Do this and test again!**

---

**Last Updated:** November 2025
