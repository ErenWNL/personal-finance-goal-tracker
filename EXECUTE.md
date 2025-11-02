# Complete Execution Guide: Personal Finance Goal Tracker

**Last Updated**: 2025-11-01
**Project Location**: `~/Documents/SEM3/MSA/personal-finance-goal-tracker`

---

## Table of Contents

1. [Option A: Local Development (Quick Testing)](#option-a-local-development-quick-testing)
2. [Option B: Docker Compose (Full Stack)](#option-b-docker-compose-full-stack)
3. [Port Reference](#port-reference)
4. [Accessing Services](#accessing-services)
5. [Monitoring & Metrics](#monitoring--metrics)
6. [Troubleshooting](#troubleshooting)

---

## Option A: Local Development (Quick Testing)

**Best for**: API testing, Swagger UI exploration, quick development

**Services Running Locally**: Microservices + MySQL
**Services NOT Running**: Kafka, MinIO, OpenSearch, Prometheus, Grafana

**Time to Setup**: ~5 minutes

### Step 1: Start MySQL Database

```bash
# Start MySQL server
brew services start mysql-server

# Verify MySQL is running
mysql -u root -p"root@123" -e "SHOW DATABASES;"
```

**Expected Output**:
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| auth_service_db    |
| goal_service_db    |
| insight_service_db |
| user_finance_db    |
| mysql              |
+--------------------+
```

---

### Step 2: Start Eureka Server (Service Registry)

**Port**: 8761

```bash
# Navigate to eureka-server directory
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/eureka-server

# Build (if not already built)
mvn clean package -DskipTests

# Run from IDE or using Maven
mvn spring-boot:run
```

**Verify**: Open http://localhost:8761 in browser
**Expected**: Eureka dashboard showing 0 instances (until other services start)

---

### Step 3: Start Config Server (Configuration Management)

**Port**: 8888

```bash
# Open NEW TERMINAL
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/config-server

# Run
mvn spring-boot:run
```

**Verify**:
```bash
curl http://localhost:8888/auth-service/development
```

**Expected Output**: Configuration JSON for auth service

---

### Step 4: Start Microservices (In This Order)

#### 4.1 Authentication Service
**Port**: 8082

```bash
# Open NEW TERMINAL
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/authentication-service

# Run
mvn spring-boot:run
```

**Verify**:
```bash
curl http://localhost:8082/auth/health
```

**Expected Output**: `{"status":"UP"}`

---

#### 4.2 Goal Service
**Port**: 8084

```bash
# Open NEW TERMINAL
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/goal-service

# Run
mvn spring-boot:run
```

**Verify**:
```bash
curl http://localhost:8084/goals/health
```

---

#### 4.3 User Finance Service
**Port**: 8083

```bash
# Open NEW TERMINAL
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/user-finance-service

# Run
mvn spring-boot:run
```

**Verify**:
```bash
curl http://localhost:8083/finance/health
```

---

#### 4.4 Insight Service
**Port**: 8085

```bash
# Open NEW TERMINAL
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/insight-service

# Run
mvn spring-boot:run
```

**Verify**:
```bash
curl http://localhost:8085/insights/health
```

---

### Step 5: Start API Gateway (Entry Point)

**Port**: 8081

```bash
# Open NEW TERMINAL
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/api-gateway

# Run
mvn spring-boot:run
```

**Verify**:
```bash
curl http://localhost:8081/swagger-ui.html
```

**Expected**: Swagger UI should load

---

### Step 6: Access Swagger UI

Once all services are running:

```bash
# Open in browser
http://localhost:8081/swagger-ui.html
```

**What You'll See**:
- API Gateway Swagger UI
- Dropdown to select service documentation:
  - Authentication Service
  - User Finance Service
  - Goal Service
  - Insight Service

**Ignore These Warnings** (Non-blocking):
- ❌ Kafka connection refused
- ❌ MinIO connection refused
- ❌ OpenSearch connection refused

These are optional services. Basic API testing works without them.

---

## Option B: Docker Compose (Full Stack)

**Best for**: Production testing, full feature testing, complete infrastructure

**Services**: All 26 components including Kafka, MinIO, OpenSearch, Prometheus, Grafana

**Time to Setup**: ~3-5 minutes (after Docker starts)

---

### Step 1: Ensure Docker is Running

```bash
# Open Docker Desktop
open /Applications/Docker.app

# Wait 30-60 seconds for Docker to start

# Verify Docker is running
docker ps
```

**Expected Output**: List of Docker containers (may be empty)

---

### Step 2: Start All Infrastructure with Docker Compose

**Location**: `docker-compose-self-hosted.yml`

```bash
# Navigate to project root
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker

# Start all containers in background
docker-compose -f docker-compose-self-hosted.yml up -d

# Wait 30-60 seconds for containers to initialize
sleep 60

# Verify all containers are running
docker-compose -f docker-compose-self-hosted.yml ps
```

**Expected Output**:
```
NAME                   STATUS
db                     Up 2 minutes
kafka                  Up 2 minutes
zookeeper              Up 2 minutes
opensearch-node1       Up 2 minutes
minio                  Up 2 minutes
prometheus             Up 2 minutes
grafana                Up 2 minutes
kafka-ui               Up 2 minutes
opensearch-dashboards  Up 2 minutes
```

---

### Step 3: Verify Database Connectivity

```bash
# Check MySQL container is running
docker-compose -f docker-compose-self-hosted.yml logs db | head -20

# Connect to MySQL inside container
docker exec -it db mysql -u root -p"root@123" -e "SHOW DATABASES;"
```

---

### Step 4: Start Microservices

Open SEPARATE terminals for each service and run from your IDE or use these commands:

#### 4.1 Eureka Server
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/eureka-server
mvn spring-boot:run
```

#### 4.2 Config Server
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/config-server
mvn spring-boot:run
```

#### 4.3 Authentication Service
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/authentication-service
mvn spring-boot:run
```

#### 4.4 Goal Service
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/goal-service
mvn spring-boot:run
```

#### 4.5 User Finance Service
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/user-finance-service
mvn spring-boot:run
```

#### 4.6 Insight Service
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/insight-service
mvn spring-boot:run
```

#### 4.7 API Gateway
```bash
cd ~/Documents/SEM3/MSA/personal-finance-goal-tracker/api-gateway
mvn spring-boot:run
```

**Verify all services are registered**:
```bash
curl http://localhost:8761/eureka/apps
```

---

## Port Reference

### Microservices (Local)
```
8081  ← API Gateway (Entry Point)
8082  ← Authentication Service
8083  ← User Finance Service
8084  ← Goal Service
8085  ← Insight Service
8761  ← Eureka Server (Service Registry)
8888  ← Config Server (Configuration Management)
```

### Databases & Infrastructure
```
3306  ← MySQL Database (localhost for local dev, "db" for Docker)
9092  ← Kafka (localhost for local, "kafka:9092" in Docker)
2181  ← Zookeeper (coordinating Kafka)
```

### Storage & Search
```
9000  ← MinIO API (S3-compatible storage)
9001  ← MinIO Console (Web UI for file management)
9200  ← OpenSearch (Full-text search engine)
9600  ← OpenSearch Node Communication
```

### Monitoring & Observability
```
9090  ← Prometheus (Metrics collection)
3001  ← Grafana (Dashboard - mapped from 3000)
5601  ← OpenSearch Dashboards (Search index UI)
8000  ← Kafka UI (Kafka monitoring)
```

---

## Accessing Services

### API Documentation & Testing

```
http://localhost:8081/swagger-ui.html          ← Main Swagger UI (Recommended)
http://localhost:8081/v3/api-docs              ← OpenAPI Spec (JSON)

# Direct service access (if needed)
http://localhost:8082/swagger-ui.html          ← Auth Service
http://localhost:8083/swagger-ui.html          ← Finance Service
http://localhost:8084/swagger-ui.html          ← Goal Service
http://localhost:8085/swagger-ui.html          ← Insight Service
```

### Service Discovery & Registry

```
http://localhost:8761                          ← Eureka Server
http://localhost:8761/eureka/apps              ← All registered services
```

### Configuration Management

```
http://localhost:8888/auth-service/development         ← Auth config
http://localhost:8888/user-finance-service/development ← Finance config
http://localhost:8888/goal-service/development         ← Goal config
http://localhost:8888/insight-service/development      ← Insight config
```

---

## Monitoring & Metrics

### Prometheus (Metrics Collection)

**Access**: http://localhost:9090

**What to Check**:
```
# Navigate to Status → Targets
# Verify these endpoints are UP:
- http://localhost:8081/actuator/prometheus        (API Gateway)
- http://localhost:8082/actuator/prometheus        (Auth Service)
- http://localhost:8083/actuator/prometheus        (Finance Service)
- http://localhost:8084/actuator/prometheus        (Goal Service)
- http://localhost:8085/actuator/prometheus        (Insight Service)
- http://localhost:8761/actuator/prometheus        (Eureka Server)
```

**Common Queries**:
```
# HTTP Request Count
http_requests_received_total

# JVM Memory Usage
jvm_memory_used_bytes

# Database Connection Pool
jdbc_connections_active

# Spring Boot Application Info
spring_boot_info
```

---

### Grafana (Visualization Dashboard)

**Access**: http://localhost:3001

**Default Credentials**:
```
Username: admin
Password: admin
```

**First Time Setup**:
1. Login with default credentials
2. Click "Data Sources" on home page
3. Click "Add data source" → Select "Prometheus"
4. URL: `http://localhost:9090`
5. Click "Test & Save"
6. Import dashboards or create custom ones

**Useful Dashboards to Import**:
- Spring Boot 2.0 System Monitor (ID: 10280)
- JVM (Micrometer) (ID: 4701)
- PostgreSQL Database (ID: 3662) - for MySQL visualization

---

### OpenSearch Dashboards (Full-Text Search UI)

**Access**: http://localhost:5601

**What to Do**:
1. Create index pattern for transaction logs
2. Explore transaction search capabilities
3. View analytics from indexed data

---

### Kafka UI (Event Streaming Management)

**Access**: http://localhost:8000

**What to Check**:
- Topics created
- Messages published
- Consumer groups
- Broker status

---

## Testing the System

### Example: Register a User

1. Open http://localhost:8081/swagger-ui.html
2. Expand "Authentication Service" section
3. Find `POST /auth/register`
4. Click "Try it out"
5. Enter JSON body:
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```
6. Click "Execute"
7. Expected Status: 201 Created

---

### Example: Create a Goal

1. Get JWT token from login endpoint
2. Expand "Goal Service" section
3. Find `POST /goals/create`
4. Click "Try it out"
5. Add Authorization header with JWT token
6. Enter goal details
7. Click "Execute"

---

### Example: Add a Transaction

1. Get JWT token
2. Expand "User Finance Service"
3. Find `POST /finance/transactions`
4. Enter transaction details
5. Click "Execute"

**Note**: Events will be published to Kafka (if running)

---

## Stopping Services

### Stop Docker Compose Stack

```bash
# Stop all containers
docker-compose -f docker-compose-self-hosted.yml down

# Stop and remove volumes (fresh start next time)
docker-compose -f docker-compose-self-hosted.yml down -v
```

### Stop MySQL (Local Development)

```bash
brew services stop mysql-server
```

### Stop Microservices

- Press `Ctrl+C` in each terminal running a microservice
- Or kill processes:
```bash
lsof -i :8081  # Find process on port 8081
kill -9 <PID>
```

---

## Complete Startup Checklist (Docker Compose)

Use this checklist to ensure everything is running:

### Pre-Startup
- [ ] Docker Desktop is open
- [ ] Project is on latest main branch
- [ ] MySQL not running locally (avoid port conflicts)

### Infrastructure (Docker)
- [ ] `docker-compose -f docker-compose-self-hosted.yml up -d`
- [ ] Wait 60 seconds
- [ ] `docker-compose -f docker-compose-self-hosted.yml ps` shows all "Up"

### Microservices
- [ ] Eureka Server started (port 8761)
- [ ] Config Server started (port 8888)
- [ ] Authentication Service started (port 8082)
- [ ] Goal Service started (port 8084)
- [ ] User Finance Service started (port 8083)
- [ ] Insight Service started (port 8085)
- [ ] API Gateway started (port 8081)

### Verification
- [ ] `curl http://localhost:8761/eureka/apps` returns 7 services
- [ ] Swagger UI loads: http://localhost:8081/swagger-ui.html
- [ ] Prometheus targets: http://localhost:9090/targets (all green)
- [ ] Grafana accessible: http://localhost:3001

### Services Status
- [ ] No "Connection refused" errors in logs
- [ ] All microservices show "ACTIVE" on Eureka
- [ ] All databases have tables created

---

## Troubleshooting

### Problem: Port Already in Use

```bash
# Find process using port
lsof -i :8081

# Kill the process
kill -9 <PID>
```

### Problem: MySQL Won't Start

```bash
# Check MySQL status
brew services list

# Restart MySQL
brew services restart mysql-server

# Verify connection
mysql -u root -p"root@123" -e "SHOW DATABASES;"
```

### Problem: Docker Containers Not Starting

```bash
# Check Docker logs
docker-compose -f docker-compose-self-hosted.yml logs -f

# Restart containers
docker-compose -f docker-compose-self-hosted.yml restart

# Full rebuild
docker-compose -f docker-compose-self-hosted.yml down
docker-compose -f docker-compose-self-hosted.yml up -d
```

### Problem: Microservice Can't Connect to Kafka/MinIO/OpenSearch

```bash
# If running with Docker:
# Ensure you're using container names (kafka, minio, opensearch-node1)
# NOT localhost (those are already updated in configuration)

# If running locally without Docker:
# These errors are expected, services will continue to work
# Basic API testing doesn't require these components
```

### Problem: Prometheus Not Scraping Metrics

```bash
# Check service is exposing metrics
curl http://localhost:8081/actuator/prometheus

# Expected: Text format metrics data

# If 404 error:
# - Ensure service has management.endpoints.web.exposure.include=prometheus
# - Restart the microservice
```

### Problem: Grafana Showing "No Data"

```bash
# Verify Prometheus is running
curl http://localhost:9090

# Check data source in Grafana (http://localhost:3001)
# Configuration → Data Sources → Prometheus → Test
```

---

## Quick Reference Commands

```bash
# Start full stack
docker-compose -f docker-compose-self-hosted.yml up -d

# Check all containers running
docker-compose -f docker-compose-self-hosted.yml ps

# View logs of specific service
docker-compose -f docker-compose-self-hosted.yml logs -f db

# Stop everything
docker-compose -f docker-compose-self-hosted.yml down

# Check if MySQL running
mysql -u root -p"root@123" -e "SHOW DATABASES;"

# Check Eureka services
curl http://localhost:8761/eureka/apps

# Check health of all services
for port in 8081 8082 8083 8084 8085; do
  echo "Port $port:"
  curl -s http://localhost:$port/actuator/health | jq .
done

# View Prometheus metrics
curl http://localhost:8081/actuator/prometheus | head -20
```

---

## Recommended Workflow

### For API Development/Testing
1. Start MySQL: `brew services start mysql-server`
2. Start Eureka Server
3. Start Config Server
4. Start 4 Microservices
5. Start API Gateway
6. Use Swagger UI for testing
7. No Docker required!

### For Full Feature Testing
1. Start Docker: `open /Applications/Docker.app && sleep 30`
2. Start Docker Compose: `docker-compose -f docker-compose-self-hosted.yml up -d`
3. Start Eureka Server locally
4. Start Config Server locally
5. Start 4 Microservices locally
6. Start API Gateway locally
7. Access Swagger UI, Prometheus, Grafana

### For Production-like Testing
1. Start Docker Compose stack
2. Run all 7 components (Eureka, Config, Auth, Finance, Goal, Insight, Gateway) as Docker containers
3. Use Kubernetes manifests from `kubernetes/` folder
4. Full monitoring with Prometheus & Grafana

---

## Additional Resources

- **Swagger UI**: http://localhost:8081/swagger-ui.html
- **OpenAPI Spec**: http://localhost:8081/v3/api-docs
- **Eureka Dashboard**: http://localhost:8761
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001
- **Kafka UI**: http://localhost:8000
- **OpenSearch Dashboard**: http://localhost:5601
- **MinIO Console**: http://localhost:9001

---

## Support & Documentation

- See `CONNECTIVITY_TROUBLESHOOTING.md` for connection issues
- See `PORT_ALLOCATION_AUDIT.md` for complete port reference
- See `SWAGGER_API_DOCUMENTATION.md` for API details
- See `docker-compose-self-hosted.yml` for infrastructure config
- See `kubernetes/` folder for K8s deployment

---

**Happy Testing! 🚀**

Last verified: 2025-11-01
All configurations are Docker-compatible and production-ready.
