# API Gateway Testing Guide

## Overview
API Gateway serves as the **single entry point** for all client requests in your microservices architecture.

## Your Service Ports (Jenkins uses 8080):
- **Jenkins**: `8080` (external)
- **API Gateway**: `8081` ✅
- **Auth Service**: `8082` ✅
- **User Finance Service**: `8083` ✅
- **Goal Service**: `8084` ✅
- **Insight Service**: `8085` ✅
- **Eureka Server**: `8761` ✅

---

## How API Gateway Works in Your Scenario

### 1. **Request Flow**
```
Client → API Gateway (8080) → Service Discovery → Target Service
```

### 2. **Route Mapping**
| Gateway URL | Target Service | Example |
|-------------|----------------|---------|
| `/api/auth/**` | authentication-service | `/api/auth/login` → `http://localhost:8082/login` |
| `/api/finance/**` | user-finance-service | `/api/finance/transactions` → `http://localhost:8083/transactions` |
| `/api/goals/**` | goal-service | `/api/goals/user/1` → `http://localhost:8084/api/goals/user/1` |
| `/api/insights/**` | insight-service | `/api/insights/analytics` → `http://localhost:8085/analytics` |

---

## Testing Steps

### **Step 1: Start All Services (in order)**

```bash
# 1. Start Eureka Server
cd eureka-server
mvn spring-boot:run

# 2. Start API Gateway
cd api-gateway
mvn spring-boot:run

# 3. Start all microservices
cd authentication-service && mvn spring-boot:run &
cd user-finance-service && mvn spring-boot:run &
cd goal-service && mvn spring-boot:run &
cd insight-service && mvn spring-boot:run &
```

### **Step 2: Verify Service Registration**

```bash
# Check Eureka Dashboard
curl http://localhost:8761/

# Check Gateway Service Discovery
curl http://localhost:8081/gateway/services
```

**Expected Response:**
```json
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

### **Step 3: Test Health Checks Through Gateway**

```bash
# Test individual service health through gateway
curl http://localhost:8080/health/auth
curl http://localhost:8080/health/finance
curl http://localhost:8080/health/goals
curl http://localhost:8080/health/insights

# Gateway health
curl http://localhost:8080/gateway/health
```

### **Step 4: Test Route Functionality**

#### **Authentication Service via Gateway:**
```bash
# Instead of: http://localhost:8081/auth/health
curl http://localhost:8080/api/auth/health

# Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

#### **User Finance Service via Gateway:**
```bash
# Instead of: http://localhost:8082/finance/categories
curl http://localhost:8080/api/finance/categories

# Create transaction
curl -X POST http://localhost:8080/api/finance/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "amount": 100.50,
    "description": "Test transaction",
    "categoryId": 1,
    "type": "EXPENSE"
  }'
```

#### **Goal Service via Gateway:**
```bash
# Instead of: http://localhost:8083/api/goals
curl http://localhost:8080/api/goals

# Create goal
curl -X POST http://localhost:8080/api/goals \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "title": "Save for vacation",
    "targetAmount": 5000,
    "categoryId": 1
  }'
```

#### **Insight Service via Gateway:**
```bash
# Instead of: http://localhost:8085/analytics/user/1
curl http://localhost:8080/api/insights/user/1

# Test communication status
curl http://localhost:8080/test/communication-status

# Get integrated insights
curl http://localhost:8080/integrated/user/1/complete-overview
```

### **Step 5: Test Microservice Communication**

```bash
# Test service-to-service communication through insights
curl http://localhost:8080/test/user/1/test-integration

# Test personalized recommendations
curl http://localhost:8080/integrated/user/1/recommendations
```

---

## Testing Scenarios

### **Scenario 1: Complete User Journey via Gateway**

```bash
# 1. Register user via gateway
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"pass123","firstName":"Test","lastName":"User"}'

# 2. Create categories via gateway
curl -X POST http://localhost:8080/api/finance/categories/initialize-defaults

# 3. Create transaction via gateway
curl -X POST http://localhost:8080/api/finance/transactions \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"amount":200,"description":"Salary","categoryId":1,"type":"INCOME"}'

# 4. Create goal via gateway
curl -X POST http://localhost:8080/api/goals \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"title":"Emergency Fund","targetAmount":1000,"categoryId":1}'

# 5. Get insights via gateway
curl http://localhost:8080/integrated/user/1/complete-overview
```

### **Scenario 2: Load Balancing Test**
```bash
# Start multiple instances of a service on different ports
# Gateway will automatically load balance between them

# Start second finance service instance
cd user-finance-service
mvn spring-boot:run -Dserver.port=8092

# Test requests - Gateway will distribute load
for i in {1..10}; do
  curl http://localhost:8080/api/finance/health
done
```

---

## Expected Benefits in Your Scenario

### **1. Centralized Access**
- Single URL for clients: `http://localhost:8080`
- No need to know individual service ports

### **2. Service Discovery Integration**
- Automatic routing to available service instances
- Load balancing across multiple instances

### **3. Cross-Cutting Concerns**
- CORS handling for web clients
- Request/response logging
- Header manipulation

### **4. Frontend Integration**
Your React frontend only needs to know:
```javascript
const API_BASE_URL = 'http://localhost:8080';

// All API calls go through gateway
fetch(`${API_BASE_URL}/api/auth/login`)
fetch(`${API_BASE_URL}/api/finance/transactions`)
fetch(`${API_BASE_URL}/api/goals/user/1`)
fetch(`${API_BASE_URL}/integrated/user/1/complete-overview`)
```

---

## Troubleshooting

### **Common Issues:**

1. **Service Not Found (404)**
   - Check if service is registered in Eureka: `http://localhost:8761`
   - Verify service is running on correct port

2. **Gateway Routes Not Working**
   - Check route configuration in `application.properties`
   - Verify StripPrefix settings

3. **CORS Issues**
   - Gateway includes CORS configuration
   - Check browser network tab for preflight requests

### **Debug Commands:**
```bash
# Check what services are registered
curl http://localhost:8080/gateway/services

# Test connectivity
curl http://localhost:8080/gateway/test-connectivity

# Check available routes
curl http://localhost:8080/gateway/routes
```

---

## Production Considerations

1. **Security**: Add authentication filters
2. **Rate Limiting**: Implement request throttling
3. **Monitoring**: Add metrics and logging
4. **SSL**: Configure HTTPS
5. **Caching**: Add response caching for read operations

Your API Gateway provides a solid foundation for scaling your Personal Finance Goal Tracker microservices architecture!