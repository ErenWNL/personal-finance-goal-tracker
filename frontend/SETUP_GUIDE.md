# Complete Setup Guide for Personal Finance Goal Tracker

## 🗄️ Database Setup

### 1. Start MySQL Server
Make sure MySQL is running on your system (default port 3306).

### 2. Create Required Databases
```sql
CREATE DATABASE auth_service_db;
CREATE DATABASE goal_service_db;
CREATE DATABASE user_finance_service_db;
CREATE DATABASE insight_service_db;
```

### 3. Update Database Credentials
Check each service's `application.properties` file and update:
```properties
spring.datasource.username=root
spring.datasource.password=root@123
```

## 🚀 Microservices Startup Sequence

### Step 1: Start Eureka Server (Service Discovery)
```bash
cd eureka-server
./mvnw spring-boot:run
# Or: mvn spring-boot:run
```
**Port**: 8761  
**URL**: http://localhost:8761  
**Status**: Wait until you see "Started EurekaServerApplication"

### Step 2: Start Authentication Service
```bash
cd authentication-service
./mvnw spring-boot:run
```
**Port**: 8082  
**URL**: http://localhost:8082/auth/health  
**Status**: Should return "Authentication Service is running!"

### Step 3: Start User Finance Service
```bash
cd user-finance-service
./mvnw spring-boot:run
```
**Port**: 8083  
**URL**: http://localhost:8083/finance/health  
**Status**: Should return "User Finance Service is running!"

### Step 4: Start Goal Service
```bash
cd goal-service
./mvnw spring-boot:run
```
**Port**: 8084  
**URL**: http://localhost:8084/goals/health  
**Status**: Should return service health information

### Step 5: Start Insight Service
```bash
cd insight-service
./mvnw spring-boot:run
```
**Port**: 8085  
**URL**: http://localhost:8085/insights/health  
**Status**: Should return service health information

### Step 6: Start API Gateway (Last)
```bash
cd api-gateway
./mvnw spring-boot:run
```
**Port**: 8081  
**URL**: http://localhost:8081/gateway/health  
**Status**: Should return "API Gateway is running successfully!"

### Step 7: Start Frontend
```bash
cd frontend
npm install  # First time only
npm start
```
**Port**: 3000  
**URL**: http://localhost:3000

## 🔍 Verification Steps

### 1. Check Eureka Dashboard
Visit http://localhost:8761 - You should see all services registered:
- AUTHENTICATION-SERVICE
- USER-FINANCE-SERVICE  
- GOAL-SERVICE
- INSIGHT-SERVICE
- API-GATEWAY

### 2. Test API Gateway Routes
```bash
# Check gateway health
curl http://localhost:8081/gateway/health

# Check available routes
curl http://localhost:8081/gateway/routes

# Test auth service through gateway
curl http://localhost:8081/auth/health

# Test other services
curl http://localhost:8081/finance/health
curl http://localhost:8081/goals/health
curl http://localhost:8081/insights/health
```

### 3. Test Frontend Connection
1. Open http://localhost:3000
2. Try to register a new user
3. Login with the registered user
4. Check if dashboard loads with data

## 📊 Data Flow

```
Frontend (React) 
    ↓ HTTP Requests
API Gateway (Port 8081)
    ↓ Routes to appropriate service
Microservices (Ports 8082-8085)
    ↓ Database queries
MySQL Databases
```

## 🐛 Troubleshooting

### Common Issues:

1. **Services not registering with Eureka**
   - Make sure Eureka server is running first
   - Check `eureka.client.service-url.defaultZone` in application.properties

2. **Database connection errors**
   - Verify MySQL is running
   - Check database credentials in application.properties
   - Ensure databases exist

3. **Frontend API errors**
   - Verify API Gateway is running on port 8081
   - Check browser network tab for failed requests
   - Ensure all microservices are registered with Eureka

4. **Port conflicts**
   - Make sure no other applications are using the required ports
   - Check with: `netstat -an | findstr :8081` (Windows) or `lsof -i :8081` (Mac/Linux)

### Service Health Check URLs:
- Eureka: http://localhost:8761
- API Gateway: http://localhost:8081/gateway/health
- Auth Service: http://localhost:8081/auth/health
- Finance Service: http://localhost:8081/finance/health
- Goal Service: http://localhost:8081/goals/health
- Insight Service: http://localhost:8081/insights/health

## 🔄 Development Workflow

### For Development:
1. Keep all microservices running in separate terminals
2. Frontend will automatically reload on code changes
3. Backend services need manual restart after code changes

### For Testing:
1. Create a test user through the frontend registration
2. Add some sample transactions and goals
3. Check if data appears correctly in all sections

## 📝 Sample Data

### Create Test User:
```json
{
  "firstName": "John",
  "lastName": "Doe", 
  "email": "john.doe@example.com",
  "password": "password123"
}
```

### Add Sample Goal:
```json
{
  "title": "Emergency Fund",
  "description": "Save for emergencies",
  "targetAmount": 10000,
  "currentAmount": 2500,
  "categoryId": 1,
  "priorityLevel": "HIGH",
  "targetDate": "2024-12-31"
}
```

### Add Sample Transaction:
```json
{
  "amount": 3000,
  "description": "Monthly Salary",
  "categoryId": 1,
  "transactionType": "INCOME",
  "transactionDate": "2024-01-15"
}
```

## 🎯 Next Steps

1. Start all services in the correct order
2. Verify each service is healthy
3. Test the frontend functionality
4. Add sample data to see the full system in action
5. Explore all features: Dashboard, Goals, Transactions, Insights, Profile

The system is designed to work with real data from the databases, so you'll see actual charts and statistics based on the data you create!
