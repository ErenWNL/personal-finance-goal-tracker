# Connectivity & Connection Refused Errors Guide

## Problem: Connection Refused Errors

**Error Message**:
```
java.net.ConnectException: Connection refused
at java.base/sun.nio.ch.Net.pollConnect(Native Method)
```

**Root Cause**: Services are trying to connect to infrastructure components (Kafka, MinIO, OpenSearch) that aren't running on your local machine.

---

## Current Status

### ✅ What IS Running
```
MySQL Database (localhost:3306) .................... RUNNING ✓
Microservices (8081-8085) .......................... RUNNING ✓
Eureka Server (8761) .............................. RUNNING ✓
Config Server (8888) .............................. RUNNING ✓
```

### ❌ What is NOT Running (Causing Errors)
```
Kafka (localhost:9092) ............................ NOT RUNNING ✗
MinIO (localhost:9000) ............................ NOT RUNNING ✗
OpenSearch (localhost:9200) ....................... NOT RUNNING ✗
Prometheus (localhost:9090) ....................... NOT RUNNING ✗
Grafana (localhost:3001) .......................... NOT RUNNING ✗
```

---

## Solution Options

### Option A: Ignore Optional Services (RECOMMENDED for Testing Swagger)

These services are **optional** for basic API testing. The errors are non-blocking:

- **Kafka**: Used for event publishing (transactions, goals created, etc.)
- **MinIO**: Used for file storage (receipts, documents)
- **OpenSearch**: Used for full-text search capabilities

**Services will continue to work** even if these are unavailable!

✅ **No action needed** - services will handle missing connections gracefully.

---

### Option B: Start Full Infrastructure with Docker (RECOMMENDED for Production Testing)

If you want **all features** (events, file storage, search), start the full stack:

```bash
# Start Docker daemon first (if not running)
open /Applications/Docker.app

# Wait 30 seconds for Docker to start

# Start all infrastructure
docker-compose -f docker-compose-self-hosted.yml up -d

# Verify all containers are running
docker-compose -f docker-compose-self-hosted.yml ps

# Check logs if something fails
docker-compose -f docker-compose-self-hosted.yml logs -f
```

**Services Started** (30-60 seconds):
- MySQL Database
- Kafka & Zookeeper
- MinIO (S3-compatible storage)
- OpenSearch (full-text search)
- Prometheus (metrics collection)
- Grafana (monitoring dashboard)
- OpenSearch Dashboards (search UI)
- Kafka UI

---

### Option C: Disable Individual Optional Services

If you only want specific services, edit their `application.properties`:

**To disable Kafka** (prevent connection attempts):
```properties
# Comment out or remove Kafka configuration
# spring.kafka.bootstrap-servers=localhost:9092
```

**To disable OpenSearch** (prevent connection attempts):
```properties
# Comment out or remove OpenSearch configuration
# spring.elasticsearch.rest.uris=http://localhost:9200
```

**To disable MinIO** (prevent connection attempts):
```properties
# Comment out or remove MinIO configuration
# minio.url=http://localhost:9000
```

---

## Configuration Inconsistencies (FIXED)

### Issue Found
**Authentication Service** was using Docker container names for local development:
```properties
# ❌ BEFORE (Docker names)
spring.kafka.bootstrap-servers=kafka:9092
minio.url=http://minio:9000
spring.elasticsearch.rest.uris=http://opensearch:9200

# ✅ AFTER (localhost)
spring.kafka.bootstrap-servers=localhost:9092
minio.url=http://localhost:9000
spring.elasticsearch.rest.uris=http://localhost:9200
```

**Status**: ✅ FIXED in `authentication-service/src/main/resources/application.properties`

---

## Testing Swagger UI Without Infrastructure

**Good News!** You can fully test Swagger UI **without any optional services**:

### What Works Without Infrastructure
✅ User Registration & Authentication
✅ Goal Management
✅ Transaction Management
✅ Profile Management
✅ API Documentation & Testing
✅ Health Checks

### What Requires Infrastructure
❌ Transaction Events (Kafka needed)
❌ File Storage (MinIO needed)
❌ Full-Text Search (OpenSearch needed)
❌ Metrics Dashboard (Prometheus + Grafana needed)

---

## Environment-Specific Configurations

### Local Development (Current Setup)
```properties
# Development - all localhost
Database: localhost:3306 ✓
Services: localhost:8081-8085 ✓
Kafka: localhost:9092 (optional)
MinIO: localhost:9000 (optional)
OpenSearch: localhost:9200 (optional)
```

### Docker Compose Setup
```properties
# Docker - use container names
Database: db:3306
Services: service-name:8082-8085
Kafka: kafka:9092
MinIO: minio:9000
OpenSearch: opensearch:9200
```

### Kubernetes Setup
```properties
# Kubernetes - use DNS names
Database: mysql.default.svc.cluster.local:3306
Services: service-name.default.svc.cluster.local:8082-8085
Kafka: kafka.default.svc.cluster.local:9092
```

---

## Quick Diagnostic Commands

### Check Running Services
```bash
# macOS - List all listening ports
lsof -i -P -n | grep LISTEN | grep -E ":(8081|8082|8083|8084|8085)"

# Check specific service
curl http://localhost:8082/auth/health
curl http://localhost:8083/finance/health
curl http://localhost:8084/goals/health
curl http://localhost:8085/analytics/health
```

### Check MySQL
```bash
# Test MySQL connection
mysql -u root -p"root@123" -e "SHOW DATABASES;"

# If error: MySQL not running, start it
brew services start mysql-server
```

### Check Docker
```bash
# Check if Docker running
docker ps

# If error: Docker daemon not running
open /Applications/Docker.app

# Check container status
docker-compose -f docker-compose-self-hosted.yml ps
```

---

## Accessing Swagger UI

### Main Entry Point
```
http://localhost:8081/swagger-ui.html
```

### Direct Service Access
```
http://localhost:8082/swagger-ui.html  (Auth)
http://localhost:8083/swagger-ui.html  (Finance)
http://localhost:8084/swagger-ui.html  (Goals)
http://localhost:8085/swagger-ui.html  (Insights)
```

### OpenAPI Specs
```
http://localhost:8081/v3/api-docs
http://localhost:8082/v3/api-docs
http://localhost:8083/v3/api-docs
http://localhost:8084/v3/api-docs
http://localhost:8085/v3/api-docs
```

---

## Best Practice Recommendations

### For API Testing Only
✅ Run microservices locally
✅ Use localhost with MySQL only
✅ Ignore Kafka/MinIO/OpenSearch errors
⏱️ Startup: ~30 seconds

### For Full Feature Testing
✅ Start Docker daemon
✅ Run: `docker-compose -f docker-compose-self-hosted.yml up -d`
✅ All infrastructure available
⏱️ Startup: ~60-90 seconds

### For Production Deployment
✅ Use Kubernetes manifests
✅ Use Docker image registry
✅ All services containerized
✅ Environment-specific configs via ConfigMaps

---

## Error Messages - What They Mean

### "Connection refused at kafka:9092"
- **Meaning**: Kafka is not running
- **Severity**: Medium (event publishing will fail)
- **Action**: Start Docker or ignore if not needed

### "Connection refused at minio:9000"
- **Meaning**: MinIO is not running
- **Severity**: Medium (file upload will fail)
- **Action**: Start Docker or use local file system

### "Connection refused at opensearch:9200"
- **Meaning**: OpenSearch is not running
- **Severity**: Low (search features unavailable)
- **Action**: Start Docker or ignore if not needed

### MySQL connection errors
- **Meaning**: Database is down or credentials wrong
- **Severity**: CRITICAL (service won't work)
- **Action**:
  ```bash
  brew services start mysql-server
  # Verify: mysql -u root -p"root@123" -e "SHOW DATABASES;"
  ```

---

## Troubleshooting Checklist

- [ ] All microservices running? `curl http://localhost:8082/auth/health`
- [ ] MySQL accessible? `mysql -u root -p"root@123" -e "SHOW DATABASES;"`
- [ ] Can access Swagger UI? http://localhost:8081/swagger-ui.html
- [ ] Endpoints responding? Try "Try it out" button on an endpoint
- [ ] Database tables created? Check MySQL databases

---

## Need Full Stack?

If you need Kafka, MinIO, and OpenSearch running:

```bash
# 1. Ensure Docker is running
open /Applications/Docker.app && sleep 30

# 2. Start infrastructure
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker
docker-compose -f docker-compose-self-hosted.yml up -d

# 3. Restart microservices
# Kill and restart them from IDE

# 4. Verify everything
docker-compose -f docker-compose-self-hosted.yml ps
curl http://localhost:8081/swagger-ui.html
```

---

## Summary

| Component | Status | For | Action |
|-----------|--------|-----|--------|
| **MySQL** | ✅ Running | Database | Continue using |
| **Services** | ✅ Running | APIs & Swagger | Use as-is |
| **Kafka** | ❌ Down | Events | Ignore errors or start Docker |
| **MinIO** | ❌ Down | File Storage | Ignore errors or start Docker |
| **OpenSearch** | ❌ Down | Search | Ignore errors or start Docker |

**Recommended**: Keep current setup. Use Swagger UI for testing. Start Docker when you need optional features.

---

**Last Updated**: 2024
**Configuration Status**: ✅ FIXED - Ready for Swagger Testing
