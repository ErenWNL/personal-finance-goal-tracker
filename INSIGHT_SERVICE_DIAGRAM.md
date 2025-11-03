# Insight Service Architecture & Communication Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FRONTEND (React - Port 3000)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Insights Page Component (Insights.js)                              │   │
│  │  ├─ Redux useSelector: insights, transactions, goals               │   │
│  │  ├─ useEffect: Dispatch fetchUserInsights() & fetchSpendingAnalytics() │
│  │  ├─ Transform Data:                                                 │   │
│  │  │  ├─ transformSpendingTrendData()    → Line/Area Chart            │   │
│  │  │  ├─ transformCategorySpendingData() → Pie Chart                  │   │
│  │  │  ├─ transformGoalProgressData()     → Bar Chart                  │   │
│  │  │  └─ generateInsights()              → Insight Cards              │   │
│  │  └─ Render: 4 Charts + Insight Cards                               │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                  │                                            │
│                          Redux Store (insightsSlice)                          │
│                          ├─ overview (data structure)                         │
│                          ├─ analytics (array)                                 │
│                          ├─ spendingSummary (object)                          │
│                          ├─ trends (object)                                   │
│                          ├─ isLoading (boolean)                               │
│                          └─ error (string)                                    │
│                                  │                                            │
└──────────────────────────────────┼────────────────────────────────────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │   API Axios Configuration   │
                    ├────────────────────────────┤
                    │ baseURL: localhost:8081    │
                    │ Headers: Authorization     │
                    │ timeout: 10s               │
                    └──────────────┬──────────────┘
                                   │
┌──────────────────────────────────▼────────────────────────────────────────────┐
│                   API GATEWAY (Spring Cloud Gateway - Port 8081)              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Route Configuration:                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Path         → Service (via Eureka Load Balancer)                  │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ /analytics/** → lb://insight-service ──────────┐                   │   │
│  │ /insights/**  → lb://insight-service ──────────┤                   │   │
│  │ /integrated/**→ lb://insight-service ──────────┼──→ Port 8085      │   │
│  │ /recommendations/** → lb://insight-service ───┘                   │   │
│  │ /auth/**      → lb://authentication-service → Port 8082            │   │
│  │ /finance/**   → lb://user-finance-service   → Port 8083            │   │
│  │ /goals/**     → lb://goal-service           → Port 8084            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                   │                                          │
│                    ┌──────────────▼──────────────┐                          │
│                    │   Eureka Service Discovery  │                          │
│                    │     (Port 8761)             │                          │
│                    │ ✅ insight-service (8085)   │                          │
│                    │ ✅ finance-service (8083)   │                          │
│                    │ ✅ goal-service (8084)      │                          │
│                    │ ✅ auth-service (8082)      │                          │
│                    └────────────────────────────┘                          │
└──────────────────────────────────────────────────────────────────────────────┘
                                   │
┌──────────────────────────────────▼────────────────────────────────────────────┐
│             INSIGHT SERVICE (Spring Boot Microservice - Port 8085)             │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                   4 MAIN CONTROLLERS                                 │   │
│  │                                                                      │   │
│  │  1. SpendingAnalyticsController                                    │   │
│  │     ├─ GET /analytics/user/{userId}?period=X                      │   │
│  │     ├─ GET /analytics/user/{userId}/summary                       │   │
│  │     ├─ GET /analytics/user/{userId}/trends                        │   │
│  │     ├─ GET /analytics/user/{userId}/top-categories                │   │
│  │     ├─ GET /analytics/user/{userId}/increasing-trends             │   │
│  │     ├─ POST/PUT/DELETE analytics                                  │   │
│  │     └─ GET /analytics/health                                       │   │
│  │                                                                      │   │
│  │  2. RecommendationController                                       │   │
│  │     ├─ GET /recommendations/user/{userId}                         │   │
│  │     ├─ GET /recommendations/user/{userId}/summary                 │   │
│  │     ├─ GET /recommendations/user/{userId}/unread-count            │   │
│  │     ├─ GET /recommendations/user/{userId}/type/{type}             │   │
│  │     ├─ GET /recommendations/user/{userId}/priority/{priority}     │   │
│  │     ├─ POST /recommendations/budget-optimization                  │   │
│  │     ├─ POST /recommendations/spending-alert                       │   │
│  │     ├─ PUT /recommendations/{id}/read                             │   │
│  │     ├─ PUT /recommendations/{id}/dismiss                          │   │
│  │     ├─ PUT /recommendations/{id}/action-taken                     │   │
│  │     ├─ DELETE /recommendations/{id}                               │   │
│  │     ├─ POST /recommendations/cleanup-expired                      │   │
│  │     └─ GET /recommendations/health                                 │   │
│  │                                                                      │   │
│  │  3. IntegratedInsightController                                    │   │
│  │     ├─ GET /integrated/user/{userId}/complete-overview            │   │
│  │     ├─ GET /integrated/user/{userId}/goal-progress-analysis       │   │
│  │     ├─ GET /integrated/user/{userId}/spending-vs-goals            │   │
│  │     ├─ GET /integrated/user/{userId}/recommendations              │   │
│  │     └─ GET /integrated/health                                      │   │
│  │                                                                      │   │
│  │  4. NotificationController (+ TestCommunicationController)         │   │
│  │     └─ Additional endpoints for notifications                      │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                      SERVICE LAYER                                   │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ SpendingAnalyticsService                                    │   │   │
│  │  │ ├─ getUserSpendingAnalytics(userId, period)               │   │   │
│  │  │ ├─ generateSpendingSummary(userId, period)                │   │   │
│  │  │ ├─ getSpendingTrends(userId)                              │   │   │
│  │  │ ├─ getTopSpendingCategories(userId, period)              │   │   │
│  │  │ ├─ getIncreasingSpendingTrends(userId)                   │   │   │
│  │  │ ├─ getCategorySpendingAnalytics(userId, categoryId)       │   │   │
│  │  │ └─ createOrUpdateAnalytics(analytics)                     │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ RecommendationService                                      │   │   │
│  │  │ ├─ getActiveRecommendations(userId)                       │   │   │
│  │  │ ├─ createBudgetOptimizationRecommendation(...)            │   │   │
│  │  │ ├─ createGoalAdjustmentRecommendation(...)                │   │   │
│  │  │ ├─ createSpendingAlertRecommendation(...)                 │   │   │
│  │  │ ├─ markAsRead(recommendationId)                           │   │   │
│  │  │ ├─ dismissRecommendation(recommendationId)                │   │   │
│  │  │ ├─ markActionTaken(recommendationId)                      │   │   │
│  │  │ ├─ getRecommendationSummary(userId)                       │   │   │
│  │  │ └─ cleanupExpiredRecommendations()                        │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                 INTER-SERVICE CLIENTS (RestTemplate)                 │   │
│  │                                                                      │   │
│  │  ┌────────────────────────────────────┐  ┌────────────────────────┐│   │
│  │  │ UserFinanceServiceClient           │  │ GoalServiceClient      ││   │
│  │  │ (calls http://localhost:8083)      │  │ (calls http://8084)    ││   │
│  │  ├────────────────────────────────────┤  ├────────────────────────┤│   │
│  │  │ Methods:                           │  │ Methods:               ││   │
│  │  │ ✅ getUserTransactions()           │  │ ✅ getUserGoals()      ││   │
│  │  │ ✅ getUserTransactionSummary()     │  │ ✅ getGoalById()       ││   │
│  │  │ ✅ getAllCategories()              │  │ ✅ getAllGoalCategories││   │
│  │  │                                    │  │                        ││   │
│  │  │ Endpoints Called:                  │  │ Endpoints Called:      ││   │
│  │  │ • /finance/transactions/user/{id}  │  │ • /goals/user/{id}     ││   │
│  │  │ • /finance/categories              │  │ • /api/goal-categories ││   │
│  │  │ • /finance/.../summary             │  │                        ││   │
│  │  └────────────────────────────────────┘  └────────────────────────┘│   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                   │                                          │
│                    ┌──────────────▼──────────────┐                          │
│                    │      REPOSITORIES            │                          │
│                    ├──────────────────────────────┤                          │
│                    │ SpendingAnalyticsRepository  │                          │
│                    │ UserRecommendationRepository │                          │
│                    │ (JPA/Hibernate)              │                          │
│                    └──────────────┬───────────────┘                          │
│                                   │                                          │
└───────────────────────────────────┼──────────────────────────────────────────┘
                                    │
                 ┌──────────────────▼──────────────────┐
                 │   MySQL Database (Port 3306)        │
                 ├───────────────────────────────────┤
                 │ Database: insight_service_db        │
                 │ ├─ Tables:                          │
                 │ │  ├─ spending_analytics            │
                 │ │  │  ├─ id (PK)                    │
                 │ │  │  ├─ user_id (FK)               │
                 │ │  │  ├─ category_id                │
                 │ │  │  ├─ analysis_period            │
                 │ │  │  ├─ total_amount               │
                 │ │  │  ├─ transaction_count          │
                 │ │  │  ├─ trend_direction            │
                 │ │  │  └─ ...                        │
                 │ │                                   │
                 │ │  └─ user_recommendations          │
                 │ │     ├─ id (PK)                    │
                 │ │     ├─ user_id (FK)               │
                 │ │     ├─ recommendation_type        │
                 │ │     ├─ title                      │
                 │ │     ├─ description                │
                 │ │     ├─ priority_level             │
                 │ │     ├─ is_read                    │
                 │ │     ├─ is_dismissed               │
                 │ │     ├─ expires_at                 │
                 │ │     └─ ...                        │
                 │ │                                   │
                 │ └─ User Database (finance_service_db)  │
                 │    └─ transactions, categories       │
                 │                                       │
                 │ └─ User Database (goal_service_db)    │
                 │    └─ goals, goal_categories          │
                 │                                       │
                 └───────────────────────────────────────┘
```

---

## Request Flow Diagram

### Complete Overview Request Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. USER INTERACTION (React Frontend - Port 3000)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   User Clicks "Insights" Tab                                                 │
│            ↓                                                                  │
│   Insights.js Component Mounts                                               │
│            ↓                                                                  │
│   useEffect Hook Runs (line 106-111)                                         │
│            ↓                                                                  │
│   dispatch(fetchUserInsights(userId))  ─────┐                               │
│   dispatch(fetchSpendingAnalytics(...))  ────┤                              │
│                                             │                                │
└─────────────────────────────────────────────┼────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 2. REDUX ASYNC THUNK (insightsSlice)                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   fetchUserInsights(userId) executes:                                        │
│            ↓                                                                  │
│   insightsService.getCompleteOverview(userId)                                │
│            ↓                                                                  │
│   insightsAPI.getCompleteOverview(userId)  [from apiConfig.js]               │
│            ↓                                                                  │
│   api.get(`/integrated/user/${userId}/complete-overview`)                    │
│            ↓                                                                  │
│   Redux sets isLoading = true                                                │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 3. AXIOS HTTP REQUEST (api.js)                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   HTTP GET /integrated/user/1/complete-overview                              │
│   Host: localhost:8081  (baseURL from REACT_APP_API_URL)                     │
│   Headers:                                                                    │
│   ├─ Content-Type: application/json                                          │
│   ├─ Authorization: Bearer {JWT_TOKEN}  [from localStorage]                  │
│   └─ timeout: 10s                                                            │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 4. API GATEWAY (Spring Cloud Gateway - Port 8081)                           │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   Incoming Request: GET /integrated/user/1/complete-overview                 │
│            ↓                                                                  │
│   Path Matching: /integrated/** matches route config                         │
│            ↓                                                                  │
│   Route Destination: lb://insight-service                                    │
│            ↓                                                                  │
│   Service Discovery (Eureka):                                                │
│   ├─ Query Eureka @ localhost:8761                                           │
│   ├─ Resolve: insight-service → 192.168.29.185:8085                          │
│   └─ Load Balance to: http://localhost:8085                                  │
│            ↓                                                                  │
│   Forward Request: GET http://localhost:8085/integrated/user/1/complete...   │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 5. INSIGHT SERVICE (Port 8085)                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   Spring DispatcherServlet Routes to:                                        │
│   IntegratedInsightController.getCompleteUserOverview(userId)                │
│            ↓                                                                  │
│   Method: getCompleteUserOverview(1)                                         │
│            ↓                                                                  │
│   ┌─ CALL 1: userFinanceClient.getUserTransactions(1)                        │
│   │         → RestTemplate.exchange(                                         │
│   │             GET http://localhost:8083/finance/transactions/user/1,       │
│   │             Map<String,Object>.class                                     │
│   │         )                                                                │
│   │         → Returns: List<TransactionDto>  [9 records]                     │
│   │                                                                          │
│   ├─ CALL 2: userFinanceClient.getUserTransactionSummary(1)                  │
│   │         → RestTemplate.exchange(                                         │
│   │             GET http://localhost:8083/finance/transactions/user/1/...    │
│   │         )                                                                │
│   │         → Returns: Map with totalIncome, totalExpense, balance           │
│   │                                                                          │
│   ├─ CALL 3: goalServiceClient.getUserGoals(1)                               │
│   │         → RestTemplate.exchange(                                         │
│   │             GET http://localhost:8084/goals/user/1,                      │
│   │         )                                                                │
│   │         → Returns: List<GoalDto>  [5 records]                            │
│   │                                                                          │
│   ├─ CALL 4: analyticsService.generateSpendingSummary(1, "MONTHLY")          │
│   │         → Query local database                                           │
│   │         → Returns: Map with spending analytics                           │
│   │                                                                          │
│   └─ AGGREGATION: Combine all responses                                      │
│                  ├─ Transactions: [9 records]                                │
│                  ├─ Goals: [5 records]                                       │
│                  ├─ Combined Insights:                                       │
│                  │  ├─ totalIncome: 2500.0                                   │
│                  │  ├─ totalSpent: 1350.0                                    │
│                  │  ├─ netSavings: 1150.0                                    │
│                  │  ├─ overallGoalProgress: 5.56%                            │
│                  │  └─ ...                                                   │
│                  └─ Analytics Summary: {...}                                 │
│                                                                               │
│   Return: 200 OK with JSON Response                                          │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 6. BACKEND SERVICES (Finance & Goal Services)                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   Finance Service (Port 8083):                                               │
│   ├─ Receives: GET /finance/transactions/user/1                              │
│   ├─ Queries: SELECT * FROM transactions WHERE user_id = 1                   │
│   ├─ Returns: {success: true, transactions: [...]}                           │
│   │                                                                          │
│   Goal Service (Port 8084):                                                  │
│   ├─ Receives: GET /goals/user/1                                             │
│   ├─ Queries: SELECT * FROM goals WHERE user_id = 1                          │
│   └─ Returns: {success: true, goals: [...]}                                  │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 7. RESPONSE FLOWS BACK                                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   Insight Service Response → API Gateway → Frontend                          │
│                                                                               │
│   HTTP 200 OK                                                                │
│   {                                                                           │
│     "success": true,                                                         │
│     "userId": 1,                                                             │
│     "transactions": [...],     ← From Finance Service                        │
│     "goals": [...],            ← From Goal Service                           │
│     "transactionSummary": {...},                                             │
│     "analyticsSummary": {...},                                               │
│     "combinedInsights": {...}  ← Calculated by Insight Service               │
│   }                                                                           │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 8. REDUX STATE UPDATE (insightsSlice reducer)                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   fetchUserInsights.fulfilled case:                                          │
│   ├─ state.isLoading = false                                                │
│   ├─ state.overview = {                                                      │
│   │  transactions: [...],                                                    │
│   │  goals: [...],                                                           │
│   │  transactionSummary: {...},                                              │
│   │  analyticsSummary: {...},                                                │
│   │  combinedInsights: {...}                                                 │
│   │ }                                                                        │
│   ├─ state.lastUpdated = new Date().toISOString()                            │
│   └─ Component Re-renders                                                    │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                              │
┌─────────────────────────────────────────────▼────────────────────────────────┐
│ 9. COMPONENT RENDERING (React)                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   Insights.js Component Re-renders with Data                                 │
│   ├─ transformSpendingTrendData()                                            │
│   │  ├─ Processes transactions                                              │
│   │  ├─ Groups by month                                                     │
│   │  └─ Returns: [{month: 'Jan', spending: 0, income: 0, savings: 0}, ...]  │
│   │                                                                          │
│   ├─ transformCategorySpendingData()                                         │
│   │  ├─ Filters EXPENSE transactions                                        │
│   │  ├─ Groups by category                                                  │
│   │  └─ Returns: [{name: 'Food', value: 150}, ...]                          │
│   │                                                                          │
│   ├─ transformGoalProgressData()                                             │
│   │  ├─ Maps goals                                                          │
│   │  └─ Returns: [{name: 'Emergency Fund', progress: 20}, ...]              │
│   │                                                                          │
│   ├─ generateInsights()                                                      │
│   │  ├─ Analyzes spending patterns                                          │
│   │  ├─ Compares to previous month                                          │
│   │  ├─ Checks goal progress                                                │
│   │  └─ Returns: [                                                          │
│   │      {type: 'positive', title: 'Excellent Savings Rate', ...},           │
│   │      {type: 'neutral', title: 'Top Spending Category', ...},             │
│   │      ...                                                                │
│   │    ]                                                                     │
│   │                                                                          │
│   └─ JSX Rendering:                                                          │
│      ├─ <AreaChart> with spending trend data                                 │
│      ├─ <PieChart> with category breakdown                                   │
│      ├─ <BarChart> with goal progress                                        │
│      ├─ <LineChart> with monthly savings                                     │
│      └─ <InsightCard> components for each insight                            │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## Database Schema Diagram

### insight_service_db

```
┌─────────────────────────────────────────────────────────────┐
│                   spending_analytics                        │
├─────────────────────────────────────────────────────────────┤
│ id (PK)                    BIGINT AUTO_INCREMENT            │
│ user_id (FK)               BIGINT NOT NULL                  │
│ category_id (FK)           BIGINT                           │
│ analysis_period            VARCHAR (DAILY/WEEKLY/MONTHLY)   │
│ analysis_month             DATE                             │
│ total_amount               DECIMAL(10,2)                    │
│ transaction_count          INT                              │
│ average_transaction        DECIMAL(10,2)                    │
│ percentage_of_total        DECIMAL(10,2)                    │
│ trend_direction            VARCHAR (UP/DOWN/STABLE)         │
│ trend_percentage           DECIMAL(10,2)                    │
│ created_at                 TIMESTAMP                        │
│ updated_at                 TIMESTAMP                        │
└─────────────────────────────────────────────────────────────┘
         │
         └─ Relationships:
            ├─ References: users (auth_service_db)
            └─ References: transaction_categories (user_finance_db)


┌─────────────────────────────────────────────────────────────┐
│                 user_recommendations                        │
├─────────────────────────────────────────────────────────────┤
│ id (PK)                    BIGINT AUTO_INCREMENT            │
│ user_id (FK)               BIGINT NOT NULL                  │
│ recommendation_type        VARCHAR (ENUM)                   │
│ │ ├─ BUDGET_OPTIMIZATION                                   │
│ │ ├─ GOAL_ADJUSTMENT                                       │
│ │ ├─ SPENDING_ALERT                                        │
│ │ └─ SAVINGS_OPPORTUNITY                                   │
│ │                                                          │
│ title                      VARCHAR(255) NOT NULL            │
│ description                TEXT NOT NULL                    │
│ priority_level             VARCHAR (LOW/MEDIUM/HIGH)        │
│ category_id (FK)           BIGINT (nullable)                │
│ goal_id (FK)               BIGINT (nullable)                │
│ is_read                    BOOLEAN DEFAULT FALSE            │
│ is_dismissed               BOOLEAN DEFAULT FALSE            │
│ action_taken               BOOLEAN DEFAULT FALSE            │
│ expires_at                 TIMESTAMP (nullable)             │
│ created_at                 TIMESTAMP                        │
│ updated_at                 TIMESTAMP                        │
└─────────────────────────────────────────────────────────────┘
         │
         └─ Relationships:
            ├─ References: users (auth_service_db)
            ├─ References: transaction_categories (user_finance_db)
            └─ References: goals (goal_service_db)
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│                 Redux Store (insightsSlice)                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ State Structure:                                             │
│ {                                                            │
│   insights: {                                                │
│     overview: {                                              │
│       transactions: [],      ← Array of TransactionDto      │
│       goals: [],             ← Array of GoalDto             │
│       transactionSummary: {  ← Map of summary data          │
│         totalIncome,                                         │
│         totalExpense,                                        │
│         balance                                              │
│       },                                                     │
│       analyticsSummary: {    ← Map of analytics             │
│         totalSpending,                                       │
│         categoryCount,                                       │
│         averagePerCategory,                                  │
│         topCategory                                          │
│       },                                                     │
│       combinedInsights: {    ← Calculated insights          │
│         totalSpent,                                          │
│         totalIncome,                                         │
│         netSavings,                                          │
│         totalGoalTargets,                                    │
│         totalGoalProgress,                                   │
│         overallGoalProgress                                  │
│       }                                                      │
│     },                                                       │
│     analytics: [],           ← Array of SpendingAnalytics   │
│     spendingSummary: {},     ← Map of summary               │
│     trends: {},              ← Map of trend data            │
│     isLoading: false,        ← Boolean flag                 │
│     error: null,             ← Error message or null        │
│     lastUpdated: null        ← ISO string timestamp         │
│   }                                                          │
│ }                                                            │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                    Async Thunks                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ fetchUserInsights(userId)                                   │
│ ├─ pending:   isLoading = true, error = null               │
│ ├─ fulfilled: overview = payload, isLoading = false         │
│ └─ rejected:  error = payload, isLoading = false            │
│                                                              │
│ fetchSpendingAnalytics({userId, period})                    │
│ ├─ pending:   isLoading = true, error = null               │
│ ├─ fulfilled: analytics = payload.analytics                │
│ └─ rejected:  error = payload, isLoading = false            │
│                                                              │
│ fetchSpendingSummary({userId, period})                      │
│ ├─ pending:   isLoading = true, error = null               │
│ ├─ fulfilled: spendingSummary = payload                     │
│ └─ rejected:  error = payload, isLoading = false            │
│                                                              │
│ fetchSpendingTrends(userId)                                 │
│ ├─ pending:   isLoading = true, error = null               │
│ ├─ fulfilled: trends = payload                              │
│ └─ rejected:  error = payload, isLoading = false            │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                Synchronous Actions                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ clearError()      → error = null                            │
│ clearInsights()   → Reset all to initial state              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │
         └─ Used in Component:
            ├─ useSelector: Get state values
            ├─ useDispatch: Dispatch actions
            └─ useEffect: Trigger fetches on mount
```

---

## Testing Scenarios

```
┌─────────────────────────────────────────────────────────────┐
│                   TEST ENDPOINTS                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ 1. Analytics Endpoint ✅                                    │
│    GET /analytics/user/1?period=MONTHLY                    │
│    ├─ Expected: 200 OK                                     │
│    ├─ Response: analytics array with 2+ records            │
│    └─ Verified: ✅ Working                                 │
│                                                              │
│ 2. Complete Overview (Multi-Service) ✅                     │
│    GET /integrated/user/1/complete-overview                │
│    ├─ Expected: 200 OK with aggregated data                │
│    ├─ Verifies: Finance Service call ✅                    │
│    ├─ Verifies: Goal Service call ✅                       │
│    ├─ Verifies: Local Analytics ✅                         │
│    ├─ Response:                                             │
│    │ ├─ transactions: 9 records ✅                          │
│    │ ├─ goals: 5 records ✅                                │
│    │ ├─ combined insights calculated ✅                    │
│    │ └─ status: success: true ✅                           │
│    └─ Verified: ✅ Working                                 │
│                                                              │
│ 3. Recommendations Endpoint ✅                              │
│    GET /recommendations/user/1                             │
│    ├─ Expected: 200 OK                                     │
│    ├─ Response: recommendations array                       │
│    ├─ Data: BUDGET_OPTIMIZATION recommendation             │
│    └─ Verified: ✅ Working                                 │
│                                                              │
│ 4. Spending Trends ✅                                       │
│    GET /analytics/user/1/trends                            │
│    ├─ Expected: 200 OK                                     │
│    ├─ Data: includingTrends, recentAnalytics, overallTrend │
│    └─ Verified: ✅ Working                                 │
│                                                              │
│ 5. Spending Summary ✅                                      │
│    GET /analytics/user/1/summary?period=MONTHLY            │
│    ├─ Expected: 200 OK                                     │
│    ├─ Data: totalSpending, topCategory, average            │
│    └─ Verified: ✅ Working                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

**Generated**: October 29, 2025
**Status**: ✅ Complete & Verified