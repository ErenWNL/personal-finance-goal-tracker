# Fix Jenkins Docker Access on macOS
## Jenkins Running as Your User - Docker Path Issue

Since Jenkins is running as your user (`sriharichari`), the issue is that Jenkins doesn't have Docker in its PATH.

---

## Quick Fix (Choose One)

### Option 1: Use Full Docker Path in Jenkinsfile (Easiest)

Edit the Jenkinsfile to use the full path to docker:

Change all instances of:
```bash
docker
docker-compose
```

To:
```bash
/opt/homebrew/bin/docker
/opt/homebrew/bin/docker-compose
```

**I'll do this for you - just continue reading**

---

### Option 2: Fix Jenkins Environment (Better Long-term)

1. Stop Jenkins:
```bash
brew services stop jenkins-lts
```

2. Create/edit Jenkins plist file:
```bash
nano ~/.launchctl/homebrew.mxcl.jenkins-lts.plist
```

Or find the actual file:
```bash
find ~ -name "*jenkins*" -type f | grep plist
```

3. Add Docker paths to the environment in the plist

4. Restart Jenkins:
```bash
brew services start jenkins-lts
```

---

## Best Solution: Update Jenkinsfile

I'll update the Jenkinsfile to use full paths since you're on macOS.

Let me verify your Docker installation first:

```bash
# Check where Docker is installed
which docker
which docker-compose

# Should output something like:
# /opt/homebrew/bin/docker
# /opt/homebrew/bin/docker-compose
```

Can you run these commands and tell me the output?

Then I'll update the Jenkinsfile with the correct paths.

---

**What's the output of:**
```bash
which docker
which docker-compose
```

---

**Last Updated:** November 2025
