# Quick Start Guide - Full Stack with Monitoring

## Prerequisites
- Docker & Docker Compose installed
- Git cloned with all services
- At least 6GB RAM available

---

## 🚀 Quick Start (3 Steps)

### Step 1: Build all microservices
```bash
cd /path/to/personal-finance-goal-tracker

# Build each service
./mvnw clean package -DskipTests -f eureka-server/pom.xml
./mvnw clean package -DskipTests -f config-server/pom.xml
./mvnw clean package -DskipTests -f api-gateway/pom.xml
./mvnw clean package -DskipTests -f authentication-service/pom.xml
./mvnw clean package -DskipTests -f user-finance-service/pom.xml
./mvnw clean package -DskipTests -f goal-service/pom.xml
./mvnw clean package -DskipTests -f insight-service/pom.xml
```

Or build all in one command:
```bash
./mvnw clean package -DskipTests
```

### Step 2: Start all containers
```bash
docker-compose -f docker-compose-self-hosted.yml up -d
```

### Step 3: Wait for services to be healthy
```bash
# Check status
docker ps

# Wait until all services show "healthy" status (may take 1-2 minutes)
# All 15 containers should be running
```

---

## 📊 Access Services

After services are running, access them at:

| Service | URL | Credentials |
|---------|-----|-------------|
| **API Gateway** | http://localhost:8081 | - |
| **Eureka Registry** | http://localhost:8761 | - |
| **Config Server** | http://localhost:8888 | - |
| **Auth Service** | http://localhost:8082 | - |
| **Finance Service** | http://localhost:8083 | - |
| **Goal Service** | http://localhost:8084 | - |
| **Insight Service** | http://localhost:8085 | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3001 | admin/admin123 |
| **Kafka UI** | http://localhost:8000 | - |
| **MinIO Console** | http://localhost:9001 | minioadmin/minioadmin123 |
| **OpenSearch** | http://localhost:9200 | - |
| **OpenSearch Dashboards** | http://localhost:5601 | - |
| **MySQL** | localhost:3306 | root/root@123 |

---

## ✅ Verification Checklist

- [ ] All 15 containers are running: `docker ps | wc -l` should be ≥ 15
- [ ] Eureka shows all services registered: http://localhost:8761
- [ ] Prometheus shows all targets UP: http://localhost:9090/targets
- [ ] Grafana dashboards have metrics: http://localhost:3001
- [ ] MinIO has 5 buckets: http://localhost:9001
- [ ] Kafka UI shows topics: http://localhost:8000
- [ ] Can call API Gateway: `curl http://localhost:8081/auth/health`

---

## 🧪 Test Signup & Login

```bash
# Test signup
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email":"test@example.com",
    "password":"password123",
    "firstName":"Test",
    "lastName":"User"
  }'

# Expected response:
# {"success":true,"message":"User registered successfully","user":{...}}

# Test login
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email":"test@example.com",
    "password":"password123"
  }'

# Expected response:
# {"success":true,"message":"Login successful","user":{...},"token":"jwt-token-here"}
```

---

## 📤 Test MinIO File Upload

```bash
# Get JWT token first
TOKEN=$(curl -s -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | jq -r '.token')

# Create a test file
echo "Test receipt" > test-receipt.txt

# Upload to MinIO
curl -X POST http://localhost:8081/finance/files/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "bucketName=receipts" \
  -F "file=@test-receipt.txt"

# Expected response: filename (e.g., "550e8400-e29b-41d4-a716-446655440000.txt")
```

---

## 📈 Monitor Metrics

1. **Open Grafana**: http://localhost:3001 (admin/admin123)
2. **Go to Dashboards** → **System Health Dashboard**
3. You should see:
   - Service Health Status
   - CPU Usage per service
   - Memory Usage per service
   - Request rates

---

## 🔍 Check Service Logs

```bash
# View logs for a specific service
docker logs personal-finance-auth-service

# View logs with timestamps
docker logs --timestamps personal-finance-finance-service

# Follow logs in real-time
docker logs -f personal-finance-kafka
```

---

## 🛑 Stop All Services

```bash
docker-compose -f docker-compose-self-hosted.yml down

# Also remove volumes (careful - deletes data!)
docker-compose -f docker-compose-self-hosted.yml down -v
```

---

## 🔧 Common Issues & Solutions

### **Issue: "docker-compose not found"**
```bash
# Use docker compose instead of docker-compose
docker compose -f docker-compose-self-hosted.yml up -d
```

### **Issue: Port already in use**
```bash
# Find process using port (e.g., 8081)
lsof -i :8081

# Kill the process
kill -9 <PID>
```

### **Issue: Services not starting**
```bash
# Check logs for errors
docker logs personal-finance-eureka

# Check Docker disk space
docker system df

# Clean up unused containers
docker system prune -a
```

### **Issue: MinIO buckets not created**
```bash
# Check MinIO logs
docker logs personal-finance-minio

# Manually create buckets via console
# http://localhost:9001 → Create Bucket
```

### **Issue: Grafana dashboards empty**
```bash
# Check Prometheus targets
# http://localhost:9090/targets

# All services should be UP (green)
# If RED, services may not be healthy yet

# Wait 1-2 minutes and refresh
```

---

## 📱 Frontend Access

The React frontend should be running separately:

```bash
# In a different terminal, run frontend
cd frontend
npm start

# Access at: http://localhost:3000
```

---

## 🧬 Architecture Overview

```
┌─ Frontend (React) 3000
│   └─ API Gateway 8081
│       ├─ Auth Service 8082
│       ├─ Finance Service 8083
│       ├─ Goal Service 8084
│       └─ Insight Service 8085
│           └─ Kafka 9092 (events)
│               └─ Zookeeper 2181
│
├─ Service Discovery
│   └─ Eureka 8761
│
├─ Configuration
│   └─ Config Server 8888
│
├─ Data
│   ├─ MySQL 3306
│   └─ MinIO 9000
│
└─ Monitoring
    ├─ Prometheus 9090
    ├─ Grafana 3001
    ├─ OpenSearch 9200
    └─ Dashboards 5601
```

---

## 🎯 Next Steps

1. ✅ Start full stack
2. ✅ Verify all services healthy
3. ✅ Test signup/login
4. ✅ Monitor metrics in Grafana
5. ⬜ (Optional) Add Kafka consumers
6. ⬜ (Optional) Implement search with OpenSearch
7. ⬜ (Optional) Add Prometheus alerting

---

## 📚 Documentation

For detailed information, see:
- `DASHBOARD_AND_MINIO_FIXES.md` - Detailed fixes applied
- `SELF_HOSTED_IMPLEMENTATION_GUIDE.md` - Full architecture guide
- Service-specific README files in each service directory

---

## 💡 Pro Tips

**Faster builds**: Skip tests during build
```bash
./mvnw clean package -DskipTests
```

**Monitor all logs at once**:
```bash
docker-compose -f docker-compose-self-hosted.yml logs -f
```

**Restart a specific service**:
```bash
docker-compose -f docker-compose-self-hosted.yml restart personal-finance-auth-service
```

**Scale a service** (create multiple instances):
```bash
docker-compose -f docker-compose-self-hosted.yml up -d --scale finance-service=3
```

**Clean up everything** (careful!):
```bash
docker system prune -a --volumes
```

---

## ✉️ Support

If you encounter issues:
1. Check logs: `docker logs <container_name>`
2. Check health: `http://localhost:9090/targets`
3. Verify connectivity: `docker network inspect personal-finance-network`
4. Review `DASHBOARD_AND_MINIO_FIXES.md` for known issues

---

**Last Updated**: 2025-11-05
**Status**: ✅ All services working with monitoring stack integrated
