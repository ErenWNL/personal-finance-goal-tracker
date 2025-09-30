# Personal Finance Goal Tracker

A comprehensive microservices-based personal finance management system built with Spring Boot, Spring Cloud, and MySQL.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Technology Stack](#technology-stack)

## Overview

The Personal Finance Goal Tracker is a microservices application that helps users manage their finances, track expenses, set financial goals, and receive personalized insights and recommendations. The system follows a microservices architecture pattern with service discovery, API gateway, and inter-service communication.

### Key Features
- **User Authentication & Management**: Secure user registration, login, and profile management
- **Transaction Management**: Track income and expenses with categorization
- **Financial Goal Setting**: Create and monitor progress towards financial goals
- **Spending Analytics**: Automated analysis of spending patterns and trends
- **Personalized Recommendations**: AI-driven insights for budget optimization
- **Integrated Insights**: Cross-service data aggregation for comprehensive financial overview

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Gateway (8081)                       │
│                    Spring Cloud Gateway                          │
└───────────┬─────────────────────────────────────────────────────┘
            │
            ├──────────────┬──────────────┬──────────────┬────────────────┐
            │              │              │              │                │
    ┌───────▼──────┐ ┌────▼─────┐ ┌─────▼──────┐ ┌────▼────────┐ ┌────▼────────┐
    │ Authentication│ │  Finance │ │    Goal    │ │   Insight   │ │   Eureka    │
    │   Service     │ │  Service │ │  Service   │ │   Service   │ │   Server    │
    │    (8082)     │ │  (8083)  │ │   (8084)   │ │   (8085)    │ │   (8761)    │
    └───────┬───────┘ └────┬─────┘ └─────┬──────┘ └──────┬──────┘ └─────────────┘
            │              │              │               │
            │              │              │               │
    ┌───────▼──────────────▼──────────────▼───────────────▼──────┐
    │                      MySQL Databases                        │
    │  auth_service_db | user_finance_db | goal_service_db |     │
    │                  insight_service_db                         │
    └─────────────────────────────────────────────────────────────┘
```

### Service Communication
- **API Gateway**: Routes external requests to appropriate microservices
- **Eureka Server**: Service discovery and registration
- **Inter-Service Communication**: REST APIs for cross-service data retrieval

## Services

### 1. Eureka Server (Service Discovery)
- **Port**: 8761
- **Purpose**: Service registration and discovery
- **Dashboard**: http://localhost:8761

### 2. API Gateway
- **Port**: 8081
- **Purpose**: Single entry point for all client requests, routing, and load balancing
- **Technology**: Spring Cloud Gateway

### 3. Authentication Service
- **Port**: 8082
- **Database**: auth_service_db
- **Purpose**: User authentication, registration, and profile management
- **Features**:
  - JWT token-based authentication
  - BCrypt password encryption
  - User CRUD operations

### 4. User Finance Service
- **Port**: 8083
- **Database**: user_finance_db
- **Purpose**: Transaction and category management
- **Features**:
  - Income/Expense tracking
  - Category management with defaults
  - Transaction summaries by user
  - CSV data import support

### 5. Goal Service
- **Port**: 8084
- **Database**: goal_service_db
- **Purpose**: Financial goal creation and tracking
- **Features**:
  - Goal CRUD operations
  - Goal categories
  - Progress tracking
  - Priority levels

### 6. Insight Service
- **Port**: 8085
- **Database**: insight_service_db
- **Purpose**: Analytics, recommendations, and integrated insights
- **Features**:
  - Spending analytics by period
  - Trend analysis
  - Personalized recommendations
  - Cross-service data aggregation
  - Notification management

## Getting Started

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+
- Git

### Database Setup

1. Create MySQL databases:
```sql
CREATE DATABASE auth_service_db;
CREATE DATABASE user_finance_db;
CREATE DATABASE goal_service_db;
CREATE DATABASE insight_service_db;
```

2. Update database credentials in each service's `application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/<database_name>
spring.datasource.username=root
spring.datasource.password=root@123
```

### Building the Project

```bash
# Clone the repository
git clone <repository-url>
cd personal-finance-goal-tracker

# Build all services
./mvnw clean install
```

### Running the Services

Start services in this order:

1. **Eureka Server**:
```bash
cd eureka-server
./mvnw spring-boot:run
```

2. **Start Microservices** (can be started in parallel):
```bash
# Authentication Service
cd authentication-service
./mvnw spring-boot:run

# User Finance Service
cd user-finance-service
./mvnw spring-boot:run

# Goal Service
cd goal-service
./mvnw spring-boot:run

# Insight Service
cd insight-service
./mvnw spring-boot:run
```

3. **API Gateway**:
```bash
cd api-gateway
./mvnw spring-boot:run
```

### Verify Services

Check Eureka Dashboard: http://localhost:8761
All services should show as registered and UP.

## API Documentation

All API requests go through the API Gateway at `http://localhost:8081`

### Authentication Service Endpoints

#### User Management
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login (returns JWT token)
- `GET /auth/users` - Get all users
- `GET /auth/user/{id}` - Get user by ID
- `PUT /auth/user/{id}` - Update user
- `DELETE /auth/user/{id}` - Delete user
- `GET /auth/health` - Health check

**Example: Register User**
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "1234567890"
  }'
```

### Finance Service Endpoints

#### Transaction Management
- `POST /finance/transactions` - Create transaction
- `GET /finance/transactions` - Get all transactions
- `GET /finance/transactions/{id}` - Get transaction by ID
- `GET /finance/transactions/user/{userId}` - Get user transactions
- `GET /finance/transactions/user/{userId}/summary` - Get transaction summary
- `PUT /finance/transactions/{id}` - Update transaction
- `DELETE /finance/transactions/{id}` - Delete transaction

#### Category Management
- `POST /finance/categories` - Create category
- `GET /finance/categories` - Get all categories
- `GET /finance/categories/{id}` - Get category by ID
- `PUT /finance/categories/{id}` - Update category
- `DELETE /finance/categories/{id}` - Delete category
- `POST /finance/categories/initialize-defaults` - Initialize default categories
- `GET /finance/health` - Health check

**Example: Create Transaction**
```bash
curl -X POST http://localhost:8081/finance/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "amount": 50.00,
    "description": "Groceries",
    "categoryId": 5,
    "type": "EXPENSE",
    "transactionDate": "2025-09-30",
    "notes": "Weekly shopping"
  }'
```

**Example: Get User Transactions**
```bash
curl http://localhost:8081/finance/transactions/user/1
```

### Goal Service Endpoints

#### Goal Management
- `POST /goals` - Create goal
- `GET /goals` - Get all goals
- `GET /goals/{id}` - Get goal by ID
- `GET /goals/user/{userId}` - Get user goals
- `PUT /goals/{id}` - Update goal
- `DELETE /goals/{id}` - Delete goal

#### Goal Category Management
- `POST /api/goal-categories` - Create goal category
- `GET /api/goal-categories` - Get all goal categories
- `GET /api/goal-categories/{id}` - Get goal category by ID
- `PUT /api/goal-categories/{id}` - Update goal category
- `DELETE /api/goal-categories/{id}` - Delete goal category

**Example: Create Goal**
```bash
curl -X POST http://localhost:8081/goals \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "title": "Emergency Fund",
    "description": "Build 6-month emergency fund",
    "targetAmount": 10000.00,
    "currentAmount": 0.00,
    "categoryId": 1,
    "priorityLevel": "HIGH",
    "targetDate": "2025-12-31"
  }'
```

**Example: Get User Goals**
```bash
curl http://localhost:8081/goals/user/1
```

### Insight Service Endpoints

#### Spending Analytics
- `GET /analytics/user/{userId}?period={MONTHLY|WEEKLY|YEARLY}` - Get user analytics
- `GET /analytics/user/{userId}/summary?period={period}` - Get spending summary
- `GET /analytics/user/{userId}/trends` - Get spending trends
- `GET /analytics/user/{userId}/category/{categoryId}` - Get category analytics
- `GET /analytics/user/{userId}/top-categories?period={period}` - Get top spending categories
- `GET /analytics/user/{userId}/recent?months={N}` - Get recent N months analytics
- `GET /analytics/user/{userId}/increasing-trends` - Get increasing spending trends
- `GET /analytics/user/{userId}/date-range?period={period}&startDate={date}&endDate={date}` - Get analytics for date range
- `POST /analytics` - Create analytics record
- `PUT /analytics/{id}` - Update analytics record
- `DELETE /analytics/{id}` - Delete analytics record
- `GET /analytics/health` - Health check

#### Recommendations
- `GET /insights/recommendations/user/{userId}` - Get user recommendations
- `GET /insights/recommendations/user/{userId}/summary` - Get recommendation summary
- `GET /insights/recommendations/user/{userId}/type/{type}` - Get recommendations by type
- `GET /insights/recommendations/user/{userId}/priority/{priority}` - Get recommendations by priority
- `GET /insights/recommendations/user/{userId}/category/{categoryId}` - Get category recommendations
- `GET /insights/recommendations/user/{userId}/goal/{goalId}` - Get goal recommendations
- `GET /insights/recommendations/user/{userId}/unread-count` - Get unread count
- `POST /insights/recommendations` - Create recommendation
- `POST /insights/recommendations/budget-optimization` - Create budget optimization recommendation
- `POST /insights/recommendations/goal-adjustment` - Create goal adjustment recommendation
- `POST /insights/recommendations/spending-alert` - Create spending alert
- `PUT /insights/recommendations/{id}/read` - Mark as read
- `PUT /insights/recommendations/{id}/dismiss` - Dismiss recommendation
- `PUT /insights/recommendations/{id}/action-taken` - Mark action taken
- `DELETE /insights/recommendations/{id}` - Delete recommendation
- `POST /insights/recommendations/cleanup-expired` - Cleanup expired recommendations
- `GET /insights/recommendations/health` - Health check

#### Integrated Insights
- `GET /insights/integrated/user/{userId}/complete-overview` - Get complete user overview
- `GET /insights/integrated/user/{userId}/goal-progress-analysis` - Get goal progress analysis
- `GET /insights/integrated/user/{userId}/spending-vs-goals` - Get spending vs goals comparison
- `GET /insights/integrated/user/{userId}/recommendations` - Get personalized recommendations
- `GET /insights/integrated/health` - Health check

**Example: Get Spending Summary**
```bash
curl "http://localhost:8081/analytics/user/1/summary?period=MONTHLY"
```

**Example: Get Complete Overview**
```bash
curl http://localhost:8081/insights/integrated/user/1/complete-overview
```

## Database Schema

### auth_service_db
**users**
- id (BIGINT, PK)
- email (VARCHAR, UNIQUE)
- password (VARCHAR)
- first_name (VARCHAR)
- last_name (VARCHAR)
- phone (VARCHAR)
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- last_login (TIMESTAMP)

### user_finance_db
**transactions**
- id (BIGINT, PK)
- user_id (BIGINT)
- amount (DECIMAL)
- description (VARCHAR)
- transaction_type (ENUM: INCOME, EXPENSE)
- category_id (BIGINT, FK)
- transaction_date (DATE)
- goal_id (BIGINT)
- notes (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

**transaction_categories**
- id (BIGINT, PK)
- name (VARCHAR)
- description (VARCHAR)
- color_code (VARCHAR)
- is_default (BOOLEAN)
- created_at (TIMESTAMP)

### goal_service_db
**goals**
- id (BIGINT, PK)
- user_id (BIGINT)
- title (VARCHAR)
- description (TEXT)
- target_amount (DECIMAL)
- current_amount (DECIMAL)
- category_id (BIGINT, FK)
- priority_level (ENUM: LOW, MEDIUM, HIGH)
- target_date (DATE)
- start_date (DATE)
- status (ENUM: ACTIVE, COMPLETED, ABANDONED)
- completion_percentage (DECIMAL)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- completed_at (TIMESTAMP)

**goal_categories**
- id (BIGINT, PK)
- name (VARCHAR)
- description (TEXT)
- icon_name (VARCHAR)
- color_code (VARCHAR)
- created_at (TIMESTAMP)

### insight_service_db
**spending_analytics**
- id (BIGINT, PK)
- user_id (BIGINT)
- category_id (BIGINT)
- analysis_period (ENUM: DAILY, WEEKLY, MONTHLY, YEARLY)
- analysis_month (DATE)
- total_amount (DECIMAL)
- transaction_count (INT)
- average_transaction (DECIMAL)
- percentage_of_total (DECIMAL)
- trend_direction (ENUM: UP, DOWN, STABLE)
- trend_percentage (DECIMAL)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

**user_recommendations**
- id (BIGINT, PK)
- user_id (BIGINT)
- recommendation_type (ENUM: BUDGET_OPTIMIZATION, GOAL_ADJUSTMENT, SPENDING_ALERT, SAVINGS_OPPORTUNITY)
- title (VARCHAR)
- description (TEXT)
- priority (ENUM: LOW, MEDIUM, HIGH, URGENT)
- category_id (BIGINT)
- goal_id (BIGINT)
- is_read (BOOLEAN)
- is_dismissed (BOOLEAN)
- action_taken (BOOLEAN)
- expires_at (TIMESTAMP)
- created_at (TIMESTAMP)

## Technology Stack

### Backend
- **Java 17**
- **Spring Boot 3.2.x**
- **Spring Cloud**
  - Spring Cloud Gateway
  - Spring Cloud Netflix Eureka
- **Spring Data JPA**
- **Spring Web**

### Database
- **MySQL 8.0**
- **Hibernate ORM**

### Security
- **JWT (JSON Web Tokens)**
- **BCrypt Password Encryption**

### Build Tools
- **Maven 3.6+**

### Additional Libraries
- **OpenCSV** - CSV data processing
- **Spring WebFlux** - Reactive HTTP calls between services

## Project Structure

```
personal-finance-goal-tracker/
├── eureka-server/              # Service Discovery
├── api-gateway/                # API Gateway
├── authentication-service/     # User Authentication
├── user-finance-service/       # Transaction Management
├── goal-service/              # Goal Management
├── insight-service/           # Analytics & Recommendations
└── pom.xml                    # Parent POM
```

## Configuration

### Port Configuration
- Eureka Server: 8761
- API Gateway: 8081
- Authentication Service: 8082
- User Finance Service: 8083
- Goal Service: 8084
- Insight Service: 8085

### Database Configuration
Each service has its own database. Update `application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/<db_name>
spring.datasource.username=root
spring.datasource.password=root@123
spring.jpa.hibernate.ddl-auto=update
```

## Development Notes

### Building Services
Each service can be built individually:
```bash
./mvnw clean package -DskipTests -f <service-name>/pom.xml
```

### Running Tests
```bash
./mvnw test
```

### Common Issues

1. **Services not registering with Eureka**:
   - Ensure Eureka server is running first
   - Check firewall settings
   - Verify application names match in properties files

2. **Database connection errors**:
   - Verify MySQL is running
   - Check database credentials
   - Ensure databases are created

3. **Port conflicts**:
   - Ensure no other applications are using the configured ports
   - Update port numbers in application.properties if needed

## API Testing

### Using cURL

**Get all users:**
```bash
curl http://localhost:8081/auth/users
```

**Get user transactions:**
```bash
curl http://localhost:8081/finance/transactions/user/1
```

**Get user goals:**
```bash
curl http://localhost:8081/goals/user/1
```

**Get user analytics:**
```bash
curl http://localhost:8081/analytics/user/1
```

### Using Postman
Import the API endpoints into Postman for easier testing. Base URL: `http://localhost:8081`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue in the repository.

---

**Last Updated**: September 30, 2025