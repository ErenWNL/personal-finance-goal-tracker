# Fixed API Gateway Testing Guide

## ✅ **Issues Resolved:**
- Fixed Java version compatibility (Java 17)
- Removed problematic `rewritePath` methods
- Simplified route configuration
- Updated Spring Boot/Cloud versions for compatibility

## **Your Service Architecture:**

### **Service Ports:**
- **Jenkins**: `8080` (external)
- **API Gateway**: `8081` ✅ **FIXED**
- **Auth Service**: `8082` ✅
- **User Finance Service**: `8083` ✅
- **Goal Service**: `8084` ✅
- **Insight Service**: `8085` ✅
- **Eureka Server**: `8761` ✅

---

## **Updated Route Mapping:**

| Gateway URL | Target Service | Direct Access |
|-------------|----------------|---------------|
| `http://localhost:8081/auth/**` | authentication-service (8082) | `http://localhost:8082/**` |
| `http://localhost:8081/finance/**` | user-finance-service (8083) | `http://localhost:8083/**` |
| `http://localhost:8081/goals/**` | goal-service (8084) | `http://localhost:8084/**` |
| `http://localhost:8081/insights/**` | insight-service (8085) | `http://localhost:8085/**` |
| `http://localhost:8081/test/**` | insight-service (testing) | `http://localhost:8085/test/**` |
| `http://localhost:8081/integrated/**` | insight-service (integrated) | `http://localhost:8085/integrated/**` |

---

## **Testing Steps:**

### **Step 1: Start Services (in order)**
```bash
# 1. Start Eureka Server
cd eureka-server
./mvnw spring-boot:run

# 2. Start API Gateway (now should work without errors)
cd api-gateway
./mvnw spring-boot:run

# 3. Start microservices
cd authentication-service && ./mvnw spring-boot:run &
cd user-finance-service && ./mvnw spring-boot:run &
cd goal-service && ./mvnw spring-boot:run &
cd insight-service && ./mvnw spring-boot:run &
```

### **Step 2: Test Gateway Health**
```bash
# Gateway health check
curl http://localhost:8081/gateway/health

# Expected response:
{
  "status": "UP",
  "service": "API Gateway",
  "port": 8081,
  "timestamp": "2024-01-15T10:30:00",
  "message": "API Gateway is running successfully!"
}
```

### **Step 3: Test Service Discovery**
```bash
# Check registered services
curl http://localhost:8081/gateway/services

# Expected response:
{
  "registeredServices": [
    "authentication-service",
    "user-finance-service",
    "goal-service",
    "insight-service",
    "api-gateway"
  ],
  "totalServices": 5
}
```

### **Step 4: Test Route Information**
```bash
# Get available routes
curl http://localhost:8081/gateway/routes

# Shows all configured routes and examples
```

### **Step 5: Test Individual Service Routes**
```bash
# Test each service through gateway
curl http://localhost:8081/auth/health
curl http://localhost:8081/finance/health
curl http://localhost:8081/goals/health
curl http://localhost:8081/insights/health

# Test microservice communication
curl http://localhost:8081/test/communication-status
curl http://localhost:8081/integrated/user/1/complete-overview
```

---

## **Complete User Flow Test:**

### **1. Register User via Gateway:**
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### **2. Initialize Categories:**
```bash
curl -X POST http://localhost:8081/finance/categories/initialize-defaults
```

### **3. Create Transaction:**
```bash
curl -X POST http://localhost:8081/finance/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "amount": 500.00,
    "description": "Salary",
    "categoryId": 1,
    "type": "INCOME"
  }'
```

### **4. Create Goal:**
```bash
curl -X POST http://localhost:8081/goals \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "title": "Emergency Fund",
    "targetAmount": 2000,
    "categoryId": 1
  }'
```

### **5. Get Integrated Insights:**
```bash
curl http://localhost:8081/integrated/user/1/complete-overview
```

---

## **Benefits You'll See:**

### **1. Single Entry Point:**
```javascript
// Frontend only needs to know one URL
const API_BASE_URL = 'http://localhost:8081';

// All API calls through gateway
fetch(`${API_BASE_URL}/auth/login`)
fetch(`${API_BASE_URL}/finance/transactions`)
fetch(`${API_BASE_URL}/goals/user/1`)
fetch(`${API_BASE_URL}/integrated/user/1/complete-overview`)
```

### **2. Automatic Service Discovery:**
- Gateway automatically finds services via Eureka
- No need to hardcode service IPs/ports
- Load balancing if multiple instances exist

### **3. Simplified Deployment:**
- Change service ports without affecting clients
- Services can scale independently
- Gateway provides single point for monitoring

---

## **Troubleshooting:**

### **If Gateway Won't Start:**
```bash
# Check Java version
java -version  # Should be 17+

# Clean and rebuild
cd api-gateway
./mvnw clean install

# Check for port conflicts
lsof -i :8081
```

### **If Routes Don't Work:**
```bash
# Check service registration
curl http://localhost:8761/  # Eureka dashboard

# Check gateway discovery
curl http://localhost:8081/gateway/services

# Check logs for routing errors
./mvnw spring-boot:run | grep ERROR
```

### **Common Issues:**
1. **Service not found**: Check if service is registered in Eureka
2. **Connection refused**: Verify service is running on correct port
3. **404 errors**: Check route path matches exactly

---

## **Next Steps:**
Your API Gateway is now properly configured and should run without errors. The simplified route configuration provides:

- ✅ No `rewritePath` errors
- ✅ Compatible Spring versions
- ✅ Clean route mapping
- ✅ Service discovery integration
- ✅ Testing endpoints

Start the services and test the gateway functionality!