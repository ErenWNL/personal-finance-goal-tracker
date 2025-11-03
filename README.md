# Personal Finance Goal Tracker

A comprehensive **microservices-based full-stack application** for personal finance management built with Spring Boot, Spring Cloud, React, and modern enterprise technologies.

**Architecture Pattern:** Microservices with Service Discovery | **Status:** Production-Ready | **Version:** 1.0.0

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Microservices](#microservices)
- [Frontend Application](#frontend-application)
- [Technology Stack](#technology-stack)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
- [Running Services](#running-services)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [API Documentation](#api-documentation)
- [Service Communication](#service-communication)
- [Monitoring & Infrastructure](#monitoring--infrastructure)
- [Configuration](#configuration)
- [Development Notes](#development-notes)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

---

## Project Overview

The **Personal Finance Goal Tracker** is a sophisticated full-stack application that helps users manage personal finances, track expenses, set financial goals, and receive AI-driven insights. The system leverages a distributed microservices architecture with service discovery, API gateway pattern, event-driven capabilities, and comprehensive monitoring.

### Key Features

- **User Authentication & Management** - Secure registration, login, and profile management with JWT tokens
- **Transaction Management** - Track income and expenses with flexible categorization
- **Financial Goal Setting** - Create, track, and monitor progress towards financial objectives
- **Spending Analytics** - Automated analysis of spending patterns, trends, and projections
- **Personalized Recommendations** - AI-driven insights for budget optimization and savings opportunities
- **Integrated Insights** - Cross-service data aggregation for comprehensive financial overview
- **Multiple Export Formats** - CSV support for data import/export
- **Service Discovery** - Automatic service registration and health monitoring
- **API Gateway** - Unified entry point with routing and load balancing
- **Full Observability** - Prometheus metrics, Grafana dashboards, and health checks

---

## Architecture

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Frontend (React 19.2)                        │
│                   http://localhost:3000                             │
└─────────────────────────────┬─────────────────────────────────────┘
                              │ (HTTP/REST)
┌─────────────────────────────▼─────────────────────────────────────┐
│                     API Gateway (Port 8081)                        │
│              Spring Cloud Gateway - Route Dispatcher               │
└──────┬──────────┬──────────┬──────────┬──────────────────────────┘
       │          │          │          │
   ┌───▼──┐  ┌────▼────┐ ┌──▼──┐   ┌───▼────┐
   │ Auth │  │ Finance │ │Goal │   │Insight │
   │ Svc  │  │  Svc    │ │ Svc │   │  Svc   │
   │(8082)│  │ (8083)  │ │(8084)   │ (8085) │
   └───┬──┘  └────┬────┘ └──┬──┘   └───┬────┘
       │          │         │          │
       └──────────┬─────────┴─────────┘
                  │ (Database access)
                  │
        ┌─────────▼──────────┐
        │  MySQL Databases   │
        ├────────────────────┤
        │ • auth_service_db  │
        │ • user_finance_db  │
        │ • goal_service_db  │
        │ • insight_service_db
        └────────────────────┘

Supporting Infrastructure:
├─ Eureka Server (8761) - Service Registry & Discovery
├─ Config Server (8888) - Centralized Configuration
├─ Kafka & Zookeeper - Event Streaming
├─ MinIO - S3-Compatible Storage
├─ OpenSearch - Full-Text Search & Analytics
├─ Prometheus (9090) - Metrics Collection
├─ Grafana (3001) - Metrics Visualization
└─ Kubernetes - Container Orchestration
```

### Detailed Component Interaction

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Client Applications (Web Browser, Mobile, API Consumers)                 │
└─────────────────────────┬────────────────────────────────────────────────┘
                          │ HTTP/HTTPS
         ┌────────────────▼────────────────┐
         │     API Gateway (8081)          │
         │  Spring Cloud Gateway           │
         │                                 │
         │  Route Configuration:           │
         │  • /auth/** → Auth Service      │
         │  • /finance/** → Finance Svc    │
         │  • /goals/** → Goal Service     │
         │  • /insights/** → Insight Svc   │
         │  • /analytics/** → Insight Svc  │
         │  • /v3/api-docs/** → Services   │
         └────┬───────┬───────┬───────┬────┘
              │       │       │       │
    ┌─────────▼─┐ ┌──▼──────┐ ┌─────▼──┐ ┌────▼──────┐
    │ Eureka    │ │ Config  │ │Service │ │ Service   │
    │ Server    │ │ Server  │ │  Pool  │ │  Mesh     │
    │ (8761)    │ │ (8888)  │ │        │ │           │
    └───────────┘ └────┬────┘ │        │ │           │
                       │      │        │ │           │
          ┌────────────▼──┐   │        │ │           │
          │ Centralized  │   │        │ │           │
          │ Configuration│   │        │ │           │
          └──────────────┘   │        │ │           │
                             │        │ │           │
        ┌────────────────────┼────────┴─┴───────────┐
        │                    │                      │
    ┌───▼──┐         ┌───────▼──┐         ┌────────▼───┐
    │Auth  │         │ Finance  │         │  Goal      │
    │Svc   │         │  Svc     │         │  Svc       │
    │8082  │         │ 8083     │         │  8084      │
    └───┬──┘         └────┬─────┘         └────┬───────┘
        │                 │                    │
        │   ┌─────────────▼──────────────┐    │
        │   │   Insight Service (8085)   │    │
        │   │                            │    │
        │   │ • Spending Analytics       │    │
        │   │ • Recommendations          │    │
        │   │ • Notifications            │    │
        │   │ • Integrated Insights      │    │
        │   └────┬──────────────────┬────┘    │
        │        │                  │         │
        │        │  REST Calls      │         │
        │ ┌──────▼──────┐      ┌───▼──────┐  │
        │ │  Fetches    │      │ Fetches  │  │
        │ │ Transactions│      │  Goals   │  │
        │ │ Categories  │      │ Categories│  │
        │ └─────────────┘      └──────────┘  │
        │
    ┌───▼──────────────┬─────────────────┬──────────────────┐
    │                  │                 │                  │
┌───▼─────┐   ┌────────▼────┐   ┌────────▼────┐   ┌────────▼────┐
│ MySQL   │   │   Kafka     │   │   MinIO     │   │OpenSearch   │
│Database │   │ & Zookeeper │   │  Storage    │   │ Engine      │
│ (3306)  │   │  (9092)     │   │  (9000)     │   │  (9200)     │
└─────────┘   └─────────────┘   └─────────────┘   └─────────────┘
    │               │                   │              │
    │          Async Events       File/Data Storage   Indexing
    │
    └─ Each Service Has: Dedicated MySQL Database (Database per Service Pattern)
       • auth_service_db
       • user_finance_db
       • goal_service_db
       • insight_service_db

Monitoring Layer:
┌──────────────────────────────────────────────────────┐
│         Prometheus (9090)                            │
│  • Collects metrics from all services                │
│  • Stores time-series metrics                        │
└────┬─────────────────────────────────────────────────┘
     │
     └──► Grafana (3001) - Visualization & Dashboards
```

---

## Microservices

### 1. Eureka Server (Service Discovery)

**Port:** 8761
**Technology:** Spring Cloud Netflix Eureka
**Location:** `/eureka-server`

**Purpose:**
- Service registration and discovery
- Health monitoring of all microservices
- Dynamic service endpoint resolution
- Load balancing support for API Gateway

**Key Features:**
- Self-preservation mode disabled for development
- 5-second eviction interval for quick failure detection
- 30-second response cache
- Prometheus metrics export
- Dashboard for service monitoring

**Dashboard URL:** `http://localhost:8761`

**Access:**
```bash
# View registered services
curl http://localhost:8761/eureka/apps
```

---

### 2. Config Server (Centralized Configuration)

**Port:** 8888
**Technology:** Spring Cloud Config Server
**Location:** `/config-server`

**Purpose:**
- Centralized configuration management
- Environment-specific configurations
- Dynamic configuration updates without restart
- Version control integration

**Configuration Sources:**
- Local file system properties
- Git repository configurations
- Environment-specific profiles (dev, prod, test)

---

### 3. API Gateway

**Port:** 8081
**Technology:** Spring Cloud Gateway
**Location:** `/api-gateway`

**Purpose:**
- Single entry point for all client requests
- Route requests to appropriate microservices
- Request/response filtering and transformation
- Load balancing using Eureka service discovery
- OpenAPI/Swagger documentation aggregation

**Route Configuration:**

| Path Pattern | Target Service | Methods | Purpose |
|---|---|---|---|
| `/auth/**` | Authentication Service (8082) | GET, POST, PUT, DELETE | User auth, profile mgmt |
| `/finance/**` | User Finance Service (8083) | GET, POST, PUT, DELETE | Transactions, categories |
| `/goals/**` | Goal Service (8084) | GET, POST, PUT, DELETE | Goal management |
| `/insights/**` | Insight Service (8085) | GET, POST, PUT, DELETE | Insights, notifications |
| `/analytics/**` | Insight Service (8085) | GET, POST, PUT, DELETE | Spending analytics |
| `/v3/api-docs/**` | Individual Services | GET | OpenAPI documentation |

**Key Features:**
- Automatic service discovery via Eureka
- Path-based routing rules
- Request metrics exposure
- Load balancing with RoundRobinLoadBalancer
- OpenAPI/Swagger aggregation

---

### 4. Authentication Service

**Port:** 8082
**Database:** `auth_service_db`
**Location:** `/authentication-service`

**Purpose:**
- User registration and login
- JWT token generation and validation
- User profile management
- Password encryption and security

**Core Components:**

**Entities:**
- `User` - User account with credentials and profile information

**Controllers:**
- `AuthController` - REST endpoints for authentication operations

**Services:**
- `AuthService` - Business logic for authentication and validation

**Repositories:**
- `UserRepository` - JPA data access for users

**Key APIs:**

```
POST   /auth/register          - Register new user
POST   /auth/login             - User login (returns JWT token)
GET    /auth/users             - Get all users
GET    /auth/user/{id}         - Get user by ID
PUT    /auth/user/{id}         - Update user profile
DELETE /auth/user/{id}         - Delete user account
GET    /auth/health            - Health check
```

**Security Features:**
- BCrypt password hashing
- JWT token-based authentication
- Token expiration (24 hours default)
- Email validation
- Duplicate email checking

**Example Request:**
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

---

### 5. User Finance Service

**Port:** 8083
**Database:** `user_finance_db`
**Location:** `/user-finance-service`

**Purpose:**
- Transaction management (income/expense tracking)
- Category management for transactions
- Spending summary and analysis
- CSV data import support

**Core Components:**

**Entities:**
- `Transaction` - Individual financial transactions
- `TransactionCategory` - Categories for organizing transactions

**Controllers:**
- `TransactionController` - Transaction CRUD operations
- `CategoryController` - Category management

**Services:**
- `TransactionService` - Transaction business logic
- `CategoryService` - Category management logic

**Repositories:**
- `TransactionRepository` - JPA data access for transactions
- `TransactionCategoryRepository` - JPA data access for categories

**Key APIs:**

```
# Transaction Management
POST   /finance/transactions                      - Create transaction
GET    /finance/transactions                      - Get all transactions
GET    /finance/transactions/{id}                 - Get transaction by ID
GET    /finance/transactions/user/{userId}        - Get user transactions
GET    /finance/transactions/user/{userId}/summary - Get spending summary
PUT    /finance/transactions/{id}                 - Update transaction
DELETE /finance/transactions/{id}                 - Delete transaction

# Category Management
POST   /finance/categories                        - Create category
GET    /finance/categories                        - Get all categories
GET    /finance/categories/{id}                   - Get category by ID
PUT    /finance/categories/{id}                   - Update category
DELETE /finance/categories/{id}                   - Delete category
POST   /finance/categories/initialize-defaults    - Initialize 12 default categories
GET    /finance/health                            - Health check
```

**Transaction Types:**
- `INCOME` - Money coming in
- `EXPENSE` - Money going out

**Default Categories (12):**
Housing, Transportation, Food, Utilities, Insurance, Healthcare, Personal Care, Entertainment, Education, Savings, Debt Payments, Other

**Example Requests:**
```bash
# Create transaction
curl -X POST http://localhost:8081/finance/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "amount": 50.00,
    "description": "Groceries",
    "categoryId": 5,
    "type": "EXPENSE",
    "transactionDate": "2025-11-02",
    "notes": "Weekly shopping"
  }'

# Get user transactions
curl http://localhost:8081/finance/transactions/user/1

# Get spending summary
curl http://localhost:8081/finance/transactions/user/1/summary
```

---

### 6. Goal Service

**Port:** 8084
**Database:** `goal_service_db`
**Location:** `/goal-service`

**Purpose:**
- Create and manage financial goals
- Track goal progress with percentage tracking
- Goal categorization and priority levels
- Goal completion analytics

**Core Components:**

**Entities:**
- `Goal` - Financial goals with targets and progress
- `GoalCategory` - Categories for organizing goals
- `GoalProgressSnapshot` - Historical progress tracking

**Controllers:**
- `GoalController` - Goal CRUD operations
- `GoalCategoryController` - Category management

**Services:**
- `GoalService` - Goal business logic
- `GoalCategoryService` - Category management

**External Clients:**
- `UserFinanceServiceClient` - REST client to Finance Service
- `InsightServiceClient` - REST client to Insight Service

**Key APIs:**

```
# Goal Management
POST   /goals                          - Create goal
GET    /goals                          - Get all goals
GET    /goals/{id}                     - Get goal by ID
GET    /goals/user/{userId}            - Get user's goals
PUT    /goals/{id}                     - Update goal
DELETE /goals/{id}                     - Delete goal

# Goal Category Management
POST   /api/goal-categories            - Create category
GET    /api/goal-categories            - Get all categories
GET    /api/goal-categories/{id}       - Get by ID
PUT    /api/goal-categories/{id}       - Update category
DELETE /api/goal-categories/{id}       - Delete category
```

**Goal Attributes:**
- Title, description, target amount, current amount
- Target date, start date, completion date
- Priority levels: `LOW`, `MEDIUM`, `HIGH`
- Status: `ACTIVE`, `COMPLETED`, `ABANDONED`
- Completion percentage tracking (auto-calculated)
- Progress snapshots for historical tracking

**Built-in Goal Categories (9):**
Emergency Fund, Vacation, Home Purchase, Vehicle, Education, Wedding, Retirement, Debt Payoff, Other

**Example Requests:**
```bash
# Create goal
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

# Get user goals
curl http://localhost:8081/goals/user/1

# Update goal progress
curl -X PUT http://localhost:8081/goals/1 \
  -H "Content-Type: application/json" \
  -d '{
    "currentAmount": 2500.00
  }'
```

---

### 7. Insight Service

**Port:** 8085
**Database:** `insight_service_db`
**Location:** `/insight-service`

**Purpose:**
- Spending analytics and trend analysis
- Personalized financial recommendations
- Cross-service data aggregation
- Notification management
- Integrated financial insights

**Core Components:**

**Entities:**
- `SpendingAnalytics` - Analytics records for spending patterns
- `UserRecommendation` - AI-generated financial recommendations
- `UserNotification` - User notifications
- `IntegratedInsight` - Aggregated cross-service insights

**Controllers:**
- `SpendingAnalyticsController` - Analytics endpoints
- `RecommendationController` - Recommendation management
- `NotificationController` - Notification management
- `IntegratedInsightController` - Cross-service insights
- `TestCommunicationController` - Service communication testing

**Services:**
- `SpendingAnalyticsService` - Analytics calculations
- `RecommendationService` - Recommendation generation
- `NotificationService` - Notification handling
- `IntegratedInsightService` - Cross-service data aggregation

**External Clients:**
- `UserFinanceServiceClient` - Access to transactions and categories
- `GoalServiceClient` - Access to goals and progress
- `Similar clients for other services as needed`

**Key APIs:**

```
# Spending Analytics
GET    /analytics/user/{userId}?period=...              - Get user analytics
GET    /analytics/user/{userId}/summary?period=...      - Get spending summary
GET    /analytics/user/{userId}/trends                  - Get spending trends
GET    /analytics/user/{userId}/category/{categoryId}   - Category-specific analytics
GET    /analytics/user/{userId}/top-categories          - Top spending categories
GET    /analytics/user/{userId}/recent?months={N}       - Recent N months analytics
GET    /analytics/user/{userId}/increasing-trends       - Increasing spending trends
GET    /analytics/user/{userId}/date-range?period=...&startDate=...&endDate=... - Date range analytics
POST   /analytics                                       - Create analytics record
PUT    /analytics/{id}                                  - Update analytics record
DELETE /analytics/{id}                                  - Delete analytics record
GET    /analytics/health                                - Health check

# Recommendations
GET    /insights/recommendations/user/{userId}                    - Get all recommendations
GET    /insights/recommendations/user/{userId}/summary            - Recommendation summary
GET    /insights/recommendations/user/{userId}/type/{type}        - By type
GET    /insights/recommendations/user/{userId}/priority/{priority} - By priority
GET    /insights/recommendations/user/{userId}/category/{catId}   - Category recommendations
GET    /insights/recommendations/user/{userId}/goal/{goalId}      - Goal recommendations
GET    /insights/recommendations/user/{userId}/unread-count       - Unread count
POST   /insights/recommendations                                  - Create recommendation
POST   /insights/recommendations/budget-optimization              - Budget optimization rec
POST   /insights/recommendations/goal-adjustment                  - Goal adjustment rec
POST   /insights/recommendations/spending-alert                   - Spending alert
PUT    /insights/recommendations/{id}/read                        - Mark as read
PUT    /insights/recommendations/{id}/dismiss                     - Dismiss recommendation
PUT    /insights/recommendations/{id}/action-taken                - Mark action taken
DELETE /insights/recommendations/{id}                             - Delete recommendation
POST   /insights/recommendations/cleanup-expired                  - Cleanup expired
GET    /insights/recommendations/health                           - Health check

# Integrated Insights
GET    /insights/integrated/user/{userId}/complete-overview       - Full financial overview
GET    /insights/integrated/user/{userId}/goal-progress-analysis  - Goal progress analysis
GET    /insights/integrated/user/{userId}/spending-vs-goals       - Spending vs goals comparison
GET    /insights/integrated/user/{userId}/recommendations         - Personalized recommendations
GET    /insights/integrated/health                                - Health check
```

**Recommendation Types:**
- `BUDGET_OPTIMIZATION` - Budget improvement suggestions
- `GOAL_ADJUSTMENT` - Goal modification recommendations
- `SPENDING_ALERT` - High spending notifications
- `SAVINGS_OPPORTUNITY` - Savings opportunities

**Priority Levels:**
- `LOW`, `MEDIUM`, `HIGH`, `URGENT`

**Analysis Periods:**
- `DAILY`, `WEEKLY`, `MONTHLY`, `YEARLY`

**Example Requests:**
```bash
# Get spending summary
curl "http://localhost:8081/analytics/user/1/summary?period=MONTHLY"

# Get complete overview
curl http://localhost:8081/insights/integrated/user/1/complete-overview

# Get recommendations
curl http://localhost:8081/insights/recommendations/user/1
```

---

## Frontend Application

**Location:** `/frontend`
**Framework:** React 19.2.0
**Port:** 3000
**API Proxy:** http://localhost:8081 (API Gateway)

### Technologies & Dependencies

**Core Framework:**
- React 19.2.0 - Modern UI library
- React Router 7.9.3 - Client-side routing
- Redux Toolkit 2.9.0 - State management

**HTTP & Data:**
- Axios 1.12.2 - HTTP client
- Recharts 3.2.1 - Data visualization and charts

**Styling & Animation:**
- Styled Components 6.1.19 - CSS-in-JS styling
- Framer Motion 12.23.22 - Smooth animations and transitions
- Lucide React 0.544.0 - Icon library (100+ icons)

**Utilities:**
- Date-fns 4.1.0 - Date manipulation and formatting
- React Query - Data fetching and caching

### Directory Structure

```
frontend/src/
├── components/                 # React components
│   ├── Auth/                  # Login, Register components
│   ├── Transactions/          # Transaction UI components
│   ├── Goals/                 # Goal management UI
│   ├── Layout/                # Header, Sidebar, Navigation
│   ├── Dashboard/             # Dashboard widgets
│   ├── Insights/              # Analytics and recommendations
│   ├── Common/                # Shared components
│   └── DemoModeIndicator/     # Demo mode indicator
│
├── pages/                      # Route pages
│   ├── Auth/                  # Login, Register pages
│   ├── Dashboard/             # Main dashboard page
│   ├── Transactions/          # Transactions management page
│   ├── Goals/                 # Goals management page
│   ├── Insights/              # Insights page
│   ├── Analytics/             # Analytics page
│   ├── Profile/               # User profile page
│   ├── Settings/              # Settings page
│   └── NotFound/              # 404 error page
│
├── services/                   # API and data services
│   ├── api.js                 # Axios API client configuration
│   ├── apiConfig.js           # API endpoint configuration
│   ├── mockApi.js             # Mock data for demo mode
│   ├── authService.js         # Authentication service
│   ├── financeService.js      # Finance/transaction service
│   ├── goalService.js         # Goal management service
│   └── insightService.js      # Analytics/insights service
│
├── store/                      # Redux store & slices
│   ├── store.js               # Redux store configuration
│   ├── slices/               # Redux slice definitions
│   │   ├── authSlice.js
│   │   ├── financeSlice.js
│   │   ├── goalSlice.js
│   │   └── insightSlice.js
│   └── selectors/            # Redux selectors
│
├── hooks/                      # Custom React hooks
│   ├── useApi.js              # API fetch hook
│   ├── useAuth.js             # Authentication hook
│   └── useLocalStorage.js     # Local storage hook
│
├── styles/                     # Global styles
│   ├── global.css             # Global CSS
│   ├── theme.js               # Theme configuration
│   └── variables.css          # CSS variables
│
├── utils/                      # Utility functions
│   ├── formatting.js          # Data formatting
│   ├── validation.js          # Form validation
│   └── constants.js           # App constants
│
├── App.js                      # Main App component
├── index.js                    # React entry point
└── index.css                   # Index styles
```

### Key Pages & Features

1. **Authentication Pages**
   - Login with email and password
   - User registration
   - Password reset functionality
   - JWT token management

2. **Dashboard**
   - Overview of finances, goals, and insights
   - Recent transactions list
   - Goal progress visualization
   - Key metrics cards
   - Quick action buttons

3. **Transactions Page**
   - View all transactions in table format
   - Filter by category, type, date range
   - Create new transaction
   - Edit existing transactions
   - Delete transactions
   - CSV export functionality

4. **Goals Page**
   - Create and manage financial goals
   - Track goal progress with visual indicators
   - Update goal amounts
   - View goal categories
   - Priority-based filtering
   - Goal status management

5. **Insights Page**
   - Spending analytics and trends
   - Category-wise breakdown with charts
   - Top spending categories
   - Monthly comparison charts
   - Personalized recommendations
   - Spending vs goals analysis

6. **Profile Page**
   - View and edit user information
   - Change password
   - Account settings
   - Notification preferences

### React Architecture Best Practices

- **Component Composition** - Small, reusable functional components
- **State Management** - Redux Toolkit for global state
- **API Integration** - Axios with error handling and interceptors
- **Routing** - React Router v7 with nested routes
- **Styling** - Styled Components for scoped CSS
- **Form Handling** - Formik or React Hook Form with validation
- **Performance** - Memoization and code splitting
- **Error Boundaries** - Graceful error handling
- **Responsive Design** - Mobile-first approach with Tailwind CSS or custom CSS

---

## Technology Stack

### Backend Framework & Core

| Component | Technology | Version |
|-----------|-----------|---------|
| **Language** | Java | 24 (with preview features) |
| **Framework** | Spring Boot | 3.5.5 |
| **Cloud Framework** | Spring Cloud | 2023.0.3 |
| **Build Tool** | Maven | 3.11.0 |

### Spring Cloud Components

| Component | Purpose | Version |
|-----------|---------|---------|
| **Spring Cloud Gateway** | API Gateway & Routing | 4.1.5 |
| **Spring Cloud Netflix Eureka** | Service Discovery & Registry | 4.1.3 |
| **Spring Cloud Config** | Centralized Configuration | 4.1.3 |
| **Spring Cloud OpenFeign** | Declarative HTTP Clients | 4.1.3 |
| **Spring Boot Actuator** | Metrics & Monitoring | 3.5.5 |

### Data & Persistence

| Component | Purpose | Version |
|-----------|---------|---------|
| **MySQL** | Relational Database | 8.0.33 |
| **Hibernate** | ORM Framework | 6.x |
| **Spring Data JPA** | Data Access Abstraction | 3.5.5 |

### Security & Authentication

| Component | Purpose | Version |
|-----------|---------|---------|
| **JJWT** | JWT Token Library | 0.12.6 |
| **BCrypt** | Password Hashing | 0.10.2 |
| **Spring Security** | Security Framework | 6.x |

### Messaging & Event Streaming

| Component | Purpose | Version |
|-----------|---------|---------|
| **Apache Kafka** | Event Streaming Platform | 7.5.0 |
| **Confluent Zookeeper** | Kafka Coordination | 7.5.0 |

### Storage & Indexing

| Component | Purpose | Version |
|-----------|---------|---------|
| **MinIO** | S3-Compatible Object Storage | Latest |
| **OpenSearch** | Full-Text Search & Analytics | Latest |
| **OpenSearch Dashboards** | OpenSearch UI | Latest |

### Monitoring & Observability

| Component | Purpose | Version |
|-----------|---------|---------|
| **Prometheus** | Metrics Collection | Latest |
| **Grafana** | Metrics Visualization | Latest |

### Frontend Technologies

| Component | Purpose | Version |
|-----------|---------|---------|
| **React** | UI Framework | 19.2.0 |
| **Redux Toolkit** | State Management | 2.9.0 |
| **React Router** | Client Routing | 7.9.3 |
| **Axios** | HTTP Client | 1.12.2 |
| **Recharts** | Data Visualization | 3.2.1 |
| **Styled Components** | CSS-in-JS | 6.1.19 |
| **Framer Motion** | Animations | 12.23.22 |
| **Lucide React** | Icons | 0.544.0 |
| **Date-fns** | Date Utilities | 4.1.0 |

### API Documentation

| Component | Purpose | Version |
|-----------|---------|---------|
| **Springdoc OpenAPI** | OpenAPI/Swagger 3.0 | 2.0.4 |
| **Swagger UI** | Interactive API Explorer | Latest |

### Additional Libraries

| Component | Purpose | Version |
|-----------|---------|---------|
| **OpenCSV** | CSV Data Processing | 5.9 |
| **Lombok** | Code Generation | 1.18.30 |
| **Jackson** | JSON Processing | 2.x |

### Container & Orchestration

| Component | Purpose |
|-----------|---------|
| **Docker** | Containerization |
| **Docker Compose** | Multi-container Orchestration |
| **Kubernetes** | Container Orchestration Platform |

---

## Database Schema

### auth_service_db

```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);
```

### user_finance_db

```sql
CREATE TABLE transactions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(255),
  transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
  category_id BIGINT,
  transaction_date DATE NOT NULL,
  goal_id BIGINT,
  notes VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_category_id (category_id),
  INDEX idx_transaction_date (transaction_date)
);

CREATE TABLE transaction_categories (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) UNIQUE NOT NULL,
  description VARCHAR(255),
  color_code VARCHAR(7),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);
```

### goal_service_db

```sql
CREATE TABLE goals (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  target_amount DECIMAL(10, 2) NOT NULL,
  current_amount DECIMAL(10, 2) DEFAULT 0,
  category_id BIGINT,
  priority_level ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'MEDIUM',
  target_date DATE,
  start_date DATE DEFAULT CURRENT_DATE,
  status ENUM('ACTIVE', 'COMPLETED', 'ABANDONED') DEFAULT 'ACTIVE',
  completion_percentage DECIMAL(5, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_target_date (target_date)
);

CREATE TABLE goal_categories (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  icon_name VARCHAR(100),
  color_code VARCHAR(7),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);

CREATE TABLE goal_progress_snapshots (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  goal_id BIGINT NOT NULL,
  progress_amount DECIMAL(10, 2) NOT NULL,
  snapshot_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
);
```

### insight_service_db

```sql
CREATE TABLE spending_analytics (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  category_id BIGINT,
  analysis_period ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY') NOT NULL,
  analysis_month DATE NOT NULL,
  total_amount DECIMAL(10, 2),
  transaction_count INT,
  average_transaction DECIMAL(10, 2),
  percentage_of_total DECIMAL(5, 2),
  trend_direction ENUM('UP', 'DOWN', 'STABLE') DEFAULT 'STABLE',
  trend_percentage DECIMAL(5, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_analysis_month (analysis_month)
);

CREATE TABLE user_recommendations (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  recommendation_type ENUM('BUDGET_OPTIMIZATION', 'GOAL_ADJUSTMENT', 'SPENDING_ALERT', 'SAVINGS_OPPORTUNITY') NOT NULL,
  title VARCHAR(255),
  description TEXT,
  priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
  category_id BIGINT,
  goal_id BIGINT,
  is_read BOOLEAN DEFAULT false,
  is_dismissed BOOLEAN DEFAULT false,
  action_taken BOOLEAN DEFAULT false,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read),
  INDEX idx_expires_at (expires_at)
);

CREATE TABLE user_notifications (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  notification_type VARCHAR(50),
  message TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read)
);
```

---

## Getting Started

### Prerequisites

- **Java 24** (or Java 17+)
- **Maven 3.11.0** (or higher)
- **MySQL 8.0.33** (or compatible)
- **Git**
- **Node.js 20+** (for frontend development)
- **npm 10+** or **yarn**

### Environment Setup

#### 1. Clone Repository

```bash
git clone https://github.com/your-org/personal-finance-goal-tracker.git
cd personal-finance-goal-tracker
```

#### 2. Database Setup

Create MySQL databases:

```sql
CREATE DATABASE auth_service_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE user_finance_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE goal_service_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE insight_service_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 3. Database Configuration

Update database credentials in each service's `application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/{database_name}
spring.datasource.username=root
spring.datasource.password=root@123
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
```

Replace `{database_name}` with:
- `auth_service_db` for Authentication Service
- `user_finance_db` for User Finance Service
- `goal_service_db` for Goal Service
- `insight_service_db` for Insight Service

#### 4. Build Project

```bash
# Build all services
./mvnw clean install

# Build specific service
./mvnw clean install -f authentication-service/pom.xml

# Skip tests during build
./mvnw clean install -DskipTests
```

---

## Running Services

### Manual Service Startup (Development)

Start services in the following order:

#### 1. Eureka Server (Service Discovery)

```bash
cd eureka-server
./mvnw spring-boot:run
```

**Verify:** Access http://localhost:8761

#### 2. Config Server (Configuration)

```bash
cd config-server
./mvnw spring-boot:run
```

#### 3. Start Microservices (Can run in parallel)

**Terminal 1 - Authentication Service:**
```bash
cd authentication-service
./mvnw spring-boot:run
```

**Terminal 2 - User Finance Service:**
```bash
cd user-finance-service
./mvnw spring-boot:run
```

**Terminal 3 - Goal Service:**
```bash
cd goal-service
./mvnw spring-boot:run
```

**Terminal 4 - Insight Service:**
```bash
cd insight-service
./mvnw spring-boot:run
```

#### 4. API Gateway

```bash
cd api-gateway
./mvnw spring-boot:run
```

#### 5. Frontend Application

```bash
cd frontend
npm install
npm start
```

**Frontend URL:** http://localhost:3000

### Verify All Services

Check Eureka Dashboard: http://localhost:8761

All services should appear as **UP**:
- ✅ eureka-server
- ✅ config-server
- ✅ api-gateway
- ✅ authentication-service
- ✅ user-finance-service
- ✅ goal-service
- ✅ insight-service

---

## Docker Deployment

### Using Docker Compose (Basic Setup)

The basic `docker-compose.yml` includes all microservices and MySQL:

```bash
docker-compose up -d
```

**Wait 30-45 seconds** for all services to initialize.

**Access:**
- Frontend: http://localhost:3000
- API Gateway: http://localhost:8081
- Eureka: http://localhost:8761

**Logs:**
```bash
docker-compose logs -f
docker-compose logs -f authentication-service
```

**Stop Services:**
```bash
docker-compose down
docker-compose down -v  # Remove volumes as well
```

### Using Docker Compose (Self-Hosted Infrastructure)

The `docker-compose-self-hosted.yml` includes full infrastructure:

```bash
docker-compose -f docker-compose-self-hosted.yml up -d
```

**Includes:**
- All microservices
- MySQL database
- Kafka & Zookeeper (event streaming)
- MinIO (S3-compatible storage) - Port 9000 (API) & 9001 (Console)
- OpenSearch (full-text search) - Port 9200
- OpenSearch Dashboards - Port 5601
- Kafka UI - Port 8000
- Prometheus - Port 9090
- Grafana - Port 3001

**Access:**
```
Frontend: http://localhost:3000
API Gateway: http://localhost:8081
Eureka: http://localhost:8761
MinIO Console: http://localhost:9001
Kafka UI: http://localhost:8000
Prometheus: http://localhost:9090
Grafana: http://localhost:3001
OpenSearch Dashboards: http://localhost:5601
```

**Grafana Credentials:**
- Username: `admin`
- Password: `admin`

### Building Custom Docker Images

```bash
# Build individual service image
docker build -t personal-finance/authentication-service:1.0 ./authentication-service

# Build all services
for service in eureka-server config-server api-gateway authentication-service user-finance-service goal-service insight-service; do
  docker build -t personal-finance/$service:1.0 ./$service
done

# Tag for registry
docker tag personal-finance/authentication-service:1.0 your-registry/personal-finance/authentication-service:1.0

# Push to registry
docker push your-registry/personal-finance/authentication-service:1.0
```

---

## Kubernetes Deployment

### Prerequisites

- **kubectl** configured to access cluster
- **Docker images** pushed to registry
- **Persistent volume provisioner** configured

### Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f k8s/

# Verify deployment
kubectl get pods -l app=personal-finance
kubectl get svc -l app=personal-finance

# Check logs
kubectl logs -f deployment/api-gateway -n personal-finance

# Port forward for local access
kubectl port-forward svc/api-gateway 8081:8081 -n personal-finance
```

### Kubernetes Manifests

Located in `/k8s/` directory:

- `eureka-server-deployment.yaml` & `eureka-server-service.yaml`
- `config-server-deployment.yaml` & `config-server-service.yaml`
- `api-gateway-deployment.yaml` & `api-gateway-service.yaml`
- `authentication-service-deployment.yaml` & `authentication-service-service.yaml`
- `user-finance-service-deployment.yaml` & `user-finance-service-service.yaml`
- `goal-service-deployment.yaml` & `goal-service-service.yaml`
- `insight-service-deployment.yaml` & `insight-service-service.yaml`
- `mysql-deployment.yaml` & `mysql-service.yaml`

### Scale Services

```bash
# Scale authentication service to 3 replicas
kubectl scale deployment/authentication-service --replicas=3 -n personal-finance

# Horizontal Pod Autoscaling
kubectl autoscale deployment/authentication-service --min=2 --max=5 -n personal-finance
```

---

## Port Allocation

| Component | Port | Purpose |
|-----------|------|---------|
| React Frontend | 3000 | Web application |
| API Gateway | 8081 | API entry point |
| Authentication Service | 8082 | User authentication |
| User Finance Service | 8083 | Transaction management |
| Goal Service | 8084 | Goal management |
| Insight Service | 8085 | Analytics & insights |
| Eureka Server | 8761 | Service discovery |
| Config Server | 8888 | Configuration server |
| MySQL | 3306 | Database |
| MinIO API | 9000 | Object storage |
| MinIO Console | 9001 | Storage management UI |
| Kafka | 9092 | Event streaming |
| Zookeeper | 2181 | Kafka coordination |
| Kafka UI | 8000 | Kafka management |
| Prometheus | 9090 | Metrics collection |
| Grafana | 3001 | Metrics visualization |
| OpenSearch | 9200 | Search engine |
| OpenSearch Dashboards | 5601 | Search UI |

---

## API Documentation

### API Gateway Base URL

All API requests go through: **http://localhost:8081**

### OpenAPI/Swagger Documentation

Access interactive API documentation at:

```
http://localhost:8081/swagger-ui.html
```

Individual service documentation:
```
http://localhost:8082/swagger-ui.html  (Auth Service)
http://localhost:8083/swagger-ui.html  (Finance Service)
http://localhost:8084/swagger-ui.html  (Goal Service)
http://localhost:8085/swagger-ui.html  (Insight Service)
```

### Common API Examples

```bash
# Register user
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123","firstName":"John","lastName":"Doe"}'

# Login
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123"}'

# Get user transactions
curl http://localhost:8081/finance/transactions/user/1

# Get user goals
curl http://localhost:8081/goals/user/1

# Get spending analytics
curl "http://localhost:8081/analytics/user/1/summary?period=MONTHLY"

# Get complete overview
curl http://localhost:8081/insights/integrated/user/1/complete-overview
```

---

## Service Communication

### Synchronous REST Calls

```
Insight Service → Finance Service: Fetch transactions, categories
Insight Service → Goal Service: Fetch goals, progress
Goal Service → Finance Service: Analyze spending for goal contributions
API Gateway → All Services: Route requests via Eureka discovery
```

### Service Discovery Pattern

All services register with **Eureka Server** on startup. API Gateway uses `lb://service-name` for load-balanced access:

```properties
spring.cloud.gateway.routes[0].id=auth-service
spring.cloud.gateway.routes[0].uri=lb://authentication-service
spring.cloud.gateway.routes[0].predicates[0]=Path=/auth/**
```

### Asynchronous Communication (via Kafka)

```
Transaction Created → Kafka Topic → Insight Service Consumer → Analytics Generated
```

---

## Monitoring & Infrastructure

### Prometheus Metrics

All services expose metrics at `/actuator/prometheus`:

```
http://localhost:8082/actuator/prometheus  (Auth Service metrics)
http://localhost:8083/actuator/prometheus  (Finance Service metrics)
http://localhost:8084/actuator/prometheus  (Goal Service metrics)
http://localhost:8085/actuator/prometheus  (Insight Service metrics)
```

**Key Metrics:**
- `http_requests_total` - Total HTTP requests
- `http_request_duration_seconds` - Request latency
- `jvm_memory_used_bytes` - JVM memory usage
- `db_connection_active` - Active database connections

### Prometheus Configuration

Edit `/prometheus.yml` to add scrape targets:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'eureka-server'
    static_configs:
      - targets: ['localhost:8761']

  - job_name: 'api-gateway'
    static_configs:
      - targets: ['localhost:8081']

  - job_name: 'microservices'
    static_configs:
      - targets: ['localhost:8082', 'localhost:8083', 'localhost:8084', 'localhost:8085']
```

**Access Prometheus UI:** http://localhost:9090

### Grafana Dashboards

**Access:** http://localhost:3001 (User: admin | Password: admin)

**Pre-configured Dashboards:**
- System metrics and resource usage
- HTTP request rates and latencies
- Database connection pool statistics
- JVM memory and garbage collection
- Service availability and uptime

---

## Configuration

### Application Properties Files

Each service has configuration in `src/main/resources/application.properties`:

**Authentication Service:**
```properties
spring.application.name=authentication-service
server.port=8082
spring.datasource.url=jdbc:mysql://localhost:3306/auth_service_db
spring.datasource.username=root
spring.datasource.password=root@123
eureka.client.service-url.defaultZone=http://localhost:8761/eureka/
```

**Similar configuration** for other services with appropriate database and port settings.

### Environment-Specific Profiles

Support for multiple profiles:

```bash
# Production profile
./mvnw spring-boot:run -Dspring.profiles.active=prod

# Development profile (default)
./mvnw spring-boot:run -Dspring.profiles.active=dev
```

Create `application-prod.properties` for production settings.

---

## Development Notes

### Building Individual Services

```bash
# Build specific service
./mvnw clean package -f authentication-service/pom.xml

# Build and skip tests
./mvnw clean package -DskipTests -f authentication-service/pom.xml
```

### Running Tests

```bash
# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=AuthServiceTest

# Skip tests during build
./mvnw clean install -DskipTests
```

### Code Generation with Lombok

Ensure IDE has Lombok plugin installed:

- **IntelliJ IDEA**: Install Lombok Plugin and enable Annotation Processing
- **Eclipse**: Install Lombok and run `java -jar lombok.jar install eclipse.exe`
- **VS Code**: Install Lombok extension

### Debugging

**Remote Debug Mode:**
```bash
./mvnw spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
```

Connect IDE debugger to `localhost:5005`.

---

## Troubleshooting

### Common Issues & Solutions

#### 1. Services Not Registering with Eureka

**Symptoms:** Services not appearing in Eureka dashboard

**Solutions:**
```bash
# Ensure Eureka Server started first
# Check firewall allows port 8761
# Verify application names in properties match

# Check service logs for errors
./mvnw spring-boot:run | grep -i eureka

# Test Eureka endpoint
curl http://localhost:8761/eureka/apps
```

#### 2. Database Connection Errors

**Symptoms:** `java.sql.SQLException: Connection refused`

**Solutions:**
```bash
# Verify MySQL is running
mysql -u root -p -e "SELECT 1"

# Check database exists
mysql -u root -p -e "SHOW DATABASES;"

# Create database if missing
mysql -u root -p < setup_databases.sql

# Verify connection string in application.properties
# URL format: jdbc:mysql://host:port/database_name
```

#### 3. Port Conflicts

**Symptoms:** `Address already in use: bind` errors

**Solutions:**
```bash
# Find process using port
lsof -i :8081  # macOS/Linux
netstat -ano | findstr :8081  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Change port in application.properties
server.port=8090
```

#### 4. API Gateway Not Routing Requests

**Symptoms:** 404 errors when accessing services through gateway

**Solutions:**
```bash
# Verify service registered with Eureka
curl http://localhost:8761/eureka/apps

# Check gateway logs for routing errors
./mvnw spring-boot:run | grep -i route

# Test direct service endpoint
curl http://localhost:8082/auth/health

# Verify gateway routes configured
# Check application.properties or application.yml
```

#### 5. Frontend Build Errors

**Symptoms:** `npm ERR!` during build

**Solutions:**
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and lock files
rm -rf node_modules package-lock.json

# Reinstall dependencies
npm install

# Check Node version
node --version  # Should be 20+
npm --version   # Should be 10+
```

#### 6. CORS Errors in Frontend

**Symptoms:** `Access-Control-Allow-Origin` errors

**Solutions:**
```
# API Gateway has CORS configured
# Ensure frontend points to http://localhost:8081
# Check apiConfig.js for correct base URL
```

### Health Check Endpoints

Verify service health:

```bash
curl http://localhost:8082/auth/health         # Auth Service
curl http://localhost:8083/finance/health      # Finance Service
curl http://localhost:8084/goals/health        # Goal Service (if available)
curl http://localhost:8085/analytics/health    # Insight Service
```

---

## Project Structure

```
personal-finance-goal-tracker/
│
├── Backend Services
│   ├── eureka-server/                    # Service Discovery (Port 8761)
│   ├── config-server/                    # Configuration Server (Port 8888)
│   ├── api-gateway/                      # API Gateway (Port 8081)
│   ├── authentication-service/           # Auth & Users (Port 8082)
│   ├── user-finance-service/             # Transactions (Port 8083)
│   ├── goal-service/                     # Goals (Port 8084)
│   └── insight-service/                  # Analytics (Port 8085)
│
├── Frontend
│   └── frontend/                         # React 19.2.0 Application (Port 3000)
│
├── Infrastructure & Configuration
│   ├── k8s/                              # Kubernetes Manifests
│   │   ├── eureka-server-deployment.yaml
│   │   ├── config-server-deployment.yaml
│   │   ├── api-gateway-deployment.yaml
│   │   ├── *-service-deployment.yaml
│   │   ├── *-service.yaml
│   │   └── mysql-deployment.yaml
│   │
│   ├── grafana/                          # Grafana Dashboards
│   ├── docker-compose.yml                # Basic Docker Compose
│   ├── docker-compose-self-hosted.yml    # Full Infrastructure
│   └── prometheus.yml                    # Prometheus Config
│
├── Build & Configuration
│   ├── pom.xml                           # Parent Maven POM
│   ├── .mvn/                             # Maven Wrapper
│   ├── .gitignore                        # Git Ignore Rules
│   └── mvnw / mvnw.cmd                   # Maven Wrapper Scripts
│
└── Documentation
    ├── README.md                         # This file
    ├── AWS_SERVICES_GUIDE.md
    ├── IMPLEMENTATION_DEPLOYMENT_GUIDE.md
    ├── INSIGHT_SERVICE_ANALYSIS.md
    ├── KAFKA_INTEGRATION_GUIDE.md
    ├── MINIO_INTEGRATION_GUIDE.md
    ├── OPENSEARCH_INTEGRATION_GUIDE.md
    ├── PROMETHEUS_MONITORING_GUIDE.md
    ├── SELF_HOSTED_IMPLEMENTATION_GUIDE.md
    └── SWAGGER_API_DOCUMENTATION.md
```

---

## Key Integration Points

### Service-to-Service REST Calls

| From | To | Endpoint | Purpose |
|------|----|---------|-----------|
| Insight | Finance | `/finance/transactions/user/{userId}` | Get transactions |
| Insight | Finance | `/finance/categories` | Get categories |
| Insight | Finance | `/finance/transactions/user/{userId}/summary` | Get summary |
| Insight | Goal | `/goals/user/{userId}` | Get goals |
| Insight | Goal | `/api/goal-categories` | Get categories |
| Goal | Finance | `/finance/transactions/user/{userId}/summary` | Analyze spending |
| Gateway | Services | `lb://service-name` | Load-balanced routing |

### Data Flow Examples

**Transaction Creation:**
```
Frontend → API Gateway → Finance Service → MySQL
                         ↓
                    Kafka (publish event)
                         ↓
                    Insight Service → Create Analytics
```

**Getting Complete Overview:**
```
Frontend → API Gateway → Insight Service
                         ├→ Finance Service (transactions)
                         ├→ Goal Service (goals)
                         └→ Local Analytics DB
                         ↓
                    Aggregated Response → Frontend
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -am 'Add your feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit pull request

### Code Standards

- Follow Java naming conventions
- Use meaningful variable and method names
- Write unit tests for new features
- Add JavaDoc comments for public methods
- Format code with project style guidelines

---

## License

This project is licensed under the MIT License - see LICENSE file for details.

---

## Support & Contact

For issues, questions, or suggestions:

1. **GitHub Issues:** https://github.com/your-org/personal-finance-goal-tracker/issues
2. **Email:** support@example.com
3. **Documentation:** See docs/ directory for detailed guides

---

## Project Status

✅ **Production Ready**

### Completed Features
- ✅ Microservices architecture with 7 services
- ✅ Service discovery with Eureka
- ✅ API Gateway with routing
- ✅ User authentication with JWT
- ✅ Transaction management
- ✅ Goal tracking and progress
- ✅ Spending analytics
- ✅ Personalized recommendations
- ✅ Integrated insights
- ✅ React frontend with Redux state management
- ✅ Docker containerization
- ✅ Kubernetes deployment manifests
- ✅ Prometheus monitoring
- ✅ Grafana dashboards

### Testing & Verification
- ✅ Service discovery and registration
- ✅ API routing through gateway
- ✅ Database operations
- ✅ Inter-service REST communication
- ✅ Transaction CRUD operations
- ✅ Goal tracking and updates
- ✅ Analytics calculations
- ✅ Health checks on all services

---

**Last Updated:** November 2, 2025
**Version:** 1.0.0
**Status:** Production Ready

Your Personal Finance Goal Tracker is fully operational and ready for deployment! 🚀