# Fix Jenkins Build Error
## Docker Hub Credentials Setup

Your Jenkins build failed because the Jenkinsfile is looking for Docker Hub credentials that don't exist yet.

**Error:**
```
ERROR: dockerhub-username
Finished: FAILURE
```

---

## Quick Fix (3 Steps)

### Step 1: Add Docker Hub Credentials to Jenkins

1. Go to **Jenkins** → **Manage Jenkins** (left menu)
2. Click **Manage Credentials**
3. Click **System** (left menu)
4. Click **Global credentials (unrestricted)**
5. Click **Add Credentials** (left menu)

### Step 2: Add First Credential (Username)

Fill in:
- **Kind:** Secret text
- **Secret:** YOUR_DOCKERHUB_USERNAME
  - Example: if your Docker Hub username is `srihari`, put `srihari`
- **ID:** `dockerhub-username` (EXACT - case sensitive)
- **Description:** Docker Hub username

Click **Create**

### Step 3: Add Second Credential (Password)

Click **Add Credentials** again

Fill in:
- **Kind:** Secret text
- **Secret:** YOUR_DOCKERHUB_PASSWORD
  - Use your Docker Hub password OR Personal Access Token
  - **Note:** If you have 2FA enabled on Docker Hub, use a Personal Access Token instead of password
- **ID:** `dockerhub-password` (EXACT - case sensitive)
- **Description:** Docker Hub password

Click **Create**

---

## Verify Credentials Were Added

1. Go to **Jenkins** → **Manage Jenkins** → **Manage Credentials**
2. Click **System**
3. Click **Global credentials (unrestricted)**
4. You should see:
   - `dockerhub-username` ✓
   - `dockerhub-password` ✓

---

## Rebuild Jenkins Job

Now that credentials are added:

1. Go to **Jenkins Dashboard**
2. Click **finance-pipeline** (or your job name)
3. Click **Build Now** (left menu)
4. Watch the build progress

---

## Expected Output

If credentials are correct, you should see:

```
Stage 1: Checkout Code
✓ Code checked out successfully

Stage 2: Pull Docker Images from Docker Hub
Logging in to Docker Hub...
✓ Successfully pulled: authentication-service:latest
✓ Successfully pulled: user-finance-service:latest
... (more services)

Stage 5: Start Services with Docker Compose
✓ Services started successfully

Stage 6: Health Check
✓ Health check completed

✓ Deployment successful!
```

---

## If Build Still Fails

### Check Credentials Are Correct

```bash
# Test Docker Hub login locally
docker login

# If it asks for username/password, verify they're correct
# If using 2FA, you need Personal Access Token (not password)
```

### Get Docker Hub Personal Access Token (If Needed)

If you have 2FA on Docker Hub:

1. Go to https://hub.docker.com/settings/security
2. Click **New Access Token**
3. Name: `Jenkins`
4. Click **Generate**
5. Copy the token
6. Update Jenkins credential with this token instead of password

### Verify Docker Hub Image Names

The Jenkinsfile pulls these images:
```
personalfinance/authentication-service:latest
personalfinance/user-finance-service:latest
personalfinance/goal-service:latest
personalfinance/insight-service:latest
personalfinance/api-gateway:latest
personalfinance/eureka-server:latest
personalfinance/config-server:latest
```

If your Docker Hub username is different, you need to update the Jenkinsfile. For example, if your username is `srihari`:

```
srihari/authentication-service:latest
srihari/user-finance-service:latest
... etc
```

Contact me if you need to update image names.

---

## Also Fixed in Jenkinsfile

I also updated the Jenkinsfile to:
- ✅ Remove `githubPush()` trigger (webhook not needed)
- ✅ Remove GitHub credentials requirement
- ✅ Use Poll SCM instead (configured in Jenkins job UI)

---

## Next Steps

1. ✅ Add Docker Hub credentials (this page)
2. ✅ Configure Jenkins job with Poll SCM (see JENKINS_SETUP_SUMMARY.md)
3. ✅ Click "Build Now" to test
4. ✅ Verify services are running

---

**Once you add the credentials, the build should work!**

---

**Last Updated:** November 2025
