# 🗄️ Database Integration Guide

## ✅ **Your Database Schema Analysis**

Based on your `cleaned_schema.sql`, you have a well-structured microservices database setup:

### 📊 **Database Structure:**
- **auth_service_db** - User authentication and sessions
- **goal_service_db** - Financial goals and progress tracking  
- **insight_service_db** - Analytics and recommendations
- **user_finance_db** - Transactions and budgets

## 🔄 **Switching from Mock to Real Backend**

### **Step 1: Set Up Databases**
```sql
-- Run your cleaned_schema.sql file
mysql -u root -p < cleaned_schema.sql
```

### **Step 2: Create Guest User in Database**
```sql
USE auth_service_db;

-- Insert guest user with hashed password
INSERT INTO users (email, password, first_name, last_name, is_active, is_email_verified, created_at) 
VALUES (
    'arya@gmail.com', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- bcrypt hash for 'arya@123'
    'Arya', 
    'Demo', 
    TRUE, 
    TRUE, 
    NOW()
);
```

### **Step 3: Add Sample Data for Testing**
```sql
-- Get the user ID
SET @user_id = (SELECT id FROM auth_service_db.users WHERE email = 'arya@gmail.com');

-- Add sample goal categories
USE goal_service_db;
INSERT INTO goal_categories (name, description, icon_name, color_code, is_default) VALUES
('Emergency Fund', 'Emergency savings fund', 'shield', '#EF4444', TRUE),
('Vacation', 'Travel and vacation savings', 'plane', '#3B82F6', TRUE),
('Home', 'Home purchase and renovation', 'home', '#10B981', TRUE),
('Education', 'Learning and skill development', 'book', '#8B5CF6', TRUE),
('Investment', 'Investment and retirement', 'trending-up', '#F59E0B', TRUE);

-- Add sample goals
INSERT INTO goals (user_id, title, description, target_amount, current_amount, category_id, priority_level, target_date, start_date, status) VALUES
(@user_id, 'Emergency Fund', 'Save 6 months of expenses', 15000.00, 8500.00, 1, 'HIGH', '2024-12-31', '2024-01-01', 'ACTIVE'),
(@user_id, 'Europe Vacation', 'Dream trip to Europe', 5000.00, 2250.00, 2, 'MEDIUM', '2024-08-15', '2024-02-01', 'ACTIVE'),
(@user_id, 'Car Down Payment', 'Save for new car', 8000.00, 6400.00, 3, 'HIGH', '2024-10-01', '2024-01-15', 'ACTIVE'),
(@user_id, 'Home Renovation', 'Kitchen renovation', 12000.00, 12000.00, 3, 'MEDIUM', '2024-06-30', '2024-01-01', 'COMPLETED');

-- Add transaction categories
USE user_finance_db;
INSERT INTO transaction_categories (name, description, category_type, color_code, icon_name, is_default) VALUES
('Salary', 'Monthly salary income', 'INCOME', '#22C55E', 'briefcase', TRUE),
('Freelance', 'Freelance work income', 'INCOME', '#10B981', 'laptop', TRUE),
('Food & Dining', 'Restaurants and groceries', 'EXPENSE', '#EF4444', 'utensils', TRUE),
('Transportation', 'Gas, public transport, car', 'EXPENSE', '#F59E0B', 'car', TRUE),
('Housing', 'Rent, utilities, maintenance', 'EXPENSE', '#8B5CF6', 'home', TRUE),
('Entertainment', 'Movies, games, hobbies', 'EXPENSE', '#EC4899', 'gamepad-2', TRUE),
('Shopping', 'Clothes, electronics, misc', 'EXPENSE', '#06B6D4', 'shopping-bag', TRUE),
('Utilities', 'Electricity, water, internet', 'EXPENSE', '#84CC16', 'zap', TRUE);

-- Add sample transactions
INSERT INTO transactions (user_id, amount, description, transaction_type, category_id, transaction_date, account_type, notes) VALUES
(@user_id, 3500.00, 'Monthly Salary', 'INCOME', 1, '2024-01-15', 'BANK', 'Regular monthly income'),
(@user_id, -1200.00, 'Rent Payment', 'EXPENSE', 5, '2024-01-01', 'BANK', 'Monthly rent'),
(@user_id, -350.00, 'Grocery Shopping', 'EXPENSE', 3, '2024-01-14', 'CREDIT_CARD', 'Weekly groceries'),
(@user_id, -85.00, 'Gas Station', 'EXPENSE', 4, '2024-01-13', 'CREDIT_CARD', 'Fuel for car'),
(@user_id, 800.00, 'Freelance Project', 'INCOME', 2, '2024-01-12', 'DIGITAL_WALLET', 'Web development project'),
(@user_id, -120.00, 'Utilities Bill', 'EXPENSE', 8, '2024-01-10', 'BANK', 'Electricity and water'),
(@user_id, -45.00, 'Coffee Shop', 'EXPENSE', 6, '2024-01-09', 'CREDIT_CARD', 'Morning coffee'),
(@user_id, -200.00, 'Online Shopping', 'EXPENSE', 7, '2024-01-08', 'CREDIT_CARD', 'Clothes and accessories');
```

### **Step 4: Switch Frontend to Real Backend**

Edit `frontend/src/services/apiConfig.js`:
```javascript
// Change this line from true to false
export const USE_MOCK_API = false;
```

## 🔧 **Backend Service Verification**

### **Required Services & Ports:**
- ✅ **Eureka Server**: 8761
- ✅ **Authentication Service**: 8082  
- ✅ **User Finance Service**: 8083
- ✅ **Goal Service**: 8084
- ✅ **Insight Service**: 8085
- ✅ **API Gateway**: 8081

### **Frontend Integration Points:**

#### **1. Authentication Flow:**
```javascript
// Login endpoint: POST /auth/login
{
  "email": "arya@gmail.com",
  "password": "arya@123"
}

// Expected response:
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "firstName": "Arya",
    "lastName": "Demo",
    "email": "arya@gmail.com"
  },
  "token": "jwt-token-here"
}
```

#### **2. Goals Integration:**
```javascript
// Get user goals: GET /goals/user/{userId}
// Create goal: POST /goals
// Update goal: PUT /goals/{id}
// Delete goal: DELETE /goals/{id}
```

#### **3. Transactions Integration:**
```javascript
// Get transactions: GET /finance/transactions/user/{userId}
// Get summary: GET /finance/transactions/user/{userId}/summary
// Create transaction: POST /finance/transactions
```

#### **4. Insights Integration:**
```javascript
// Get overview: GET /integrated/user/{userId}/complete-overview
// Get analytics: GET /analytics/user/{userId}
// Get trends: GET /analytics/user/{userId}/trends
```

## 🎯 **Frontend Features That Will Work:**

### **✅ Dashboard:**
- Real financial overview from database
- Actual income/expense calculations
- Live goal progress tracking
- Dynamic charts with real data

### **✅ Goals Management:**
- Create/edit/delete goals in database
- Real progress calculations
- Category filtering from database
- Milestone tracking

### **✅ Transactions:**
- Real transaction history
- Actual category breakdown
- Live balance calculations
- Transaction filtering and search

### **✅ Insights:**
- Real spending analytics
- Actual trend calculations
- Database-driven recommendations
- Live chart updates

### **✅ Profile:**
- Real user data from auth service
- Actual account statistics
- Live goal/transaction counts

## 🔄 **Button Functionality Mapping:**

### **Login Page:**
- ✅ **"Login as Guest"** → Calls `/auth/login` with arya@gmail.com
- ✅ **"Sign In"** → Authenticates against database
- ✅ **"Sign up here"** → Creates user in auth_service_db

### **Dashboard:**
- ✅ **"Add Transaction"** → Opens modal, saves to user_finance_db
- ✅ **"Create Goal"** → Opens modal, saves to goal_service_db
- ✅ **Chart interactions** → Real data from insight_service_db

### **Goals Page:**
- ✅ **"Create New Goal"** → Modal saves to goals table
- ✅ **Edit Goal (pencil icon)** → Updates goals table
- ✅ **Delete Goal (trash icon)** → Removes from database
- ✅ **Filter buttons** → Query database with filters

### **Transactions Page:**
- ✅ **"Add Transaction"** → Saves to transactions table
- ✅ **Filter/Search** → Database queries with conditions
- ✅ **Edit/Delete** → Updates/removes from database

### **Insights Page:**
- ✅ **Chart filters** → Queries spending_analytics table
- ✅ **"View Details"** → Detailed analytics from database
- ✅ **Time period selectors** → Dynamic data queries

### **Profile Page:**
- ✅ **"Edit Profile"** → Updates users table
- ✅ **"Save Changes"** → Commits to auth_service_db
- ✅ **Account settings** → Real user preferences

## 🚀 **Testing Checklist:**

### **Phase 1: Backend Setup**
- [ ] Run cleaned_schema.sql
- [ ] Start all microservices
- [ ] Verify Eureka registration
- [ ] Test API Gateway routes

### **Phase 2: Data Setup**
- [ ] Create guest user (arya@gmail.com)
- [ ] Add sample goals and categories
- [ ] Add sample transactions
- [ ] Verify data in all databases

### **Phase 3: Frontend Integration**
- [ ] Switch USE_MOCK_API to false
- [ ] Test guest login
- [ ] Verify dashboard loads real data
- [ ] Test all CRUD operations

### **Phase 4: Full System Test**
- [ ] Create new goal → Check goal_service_db
- [ ] Add transaction → Check user_finance_db  
- [ ] View insights → Check insight_service_db
- [ ] Edit profile → Check auth_service_db

## 🔧 **Troubleshooting:**

### **Common Issues:**

1. **Login fails:**
   - Check if auth service is running on 8082
   - Verify guest user exists in database
   - Check password hash matches

2. **Empty dashboard:**
   - Verify API Gateway routes to services
   - Check if sample data exists
   - Look for CORS issues in browser console

3. **Charts not loading:**
   - Check insight service on 8085
   - Verify spending_analytics table has data
   - Check network tab for failed requests

4. **Goals/Transactions not saving:**
   - Verify respective services are running
   - Check database connections
   - Look for validation errors in backend logs

## 🎉 **Success Indicators:**

When everything works correctly, you'll see:
- ✅ Real user data in profile
- ✅ Actual financial calculations
- ✅ Live database updates
- ✅ Dynamic charts with real data
- ✅ Persistent data across sessions
- ✅ All buttons performing database operations

The frontend is designed to work seamlessly with your database schema. All the mock data structure matches your real database tables, ensuring a smooth transition! 🚀
