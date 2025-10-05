# 🧪 Frontend Testing Guide

## 🚀 Quick Start - Testing the Frontend

### Option 1: With Backend Services (Full Functionality)

#### Step 1: Start All Backend Services
```bash
# Make sure MySQL is running first!

# Terminal 1 - Eureka Server
cd eureka-server
./mvnw spring-boot:run

# Terminal 2 - Authentication Service
cd authentication-service  
./mvnw spring-boot:run

# Terminal 3 - Other services (in separate terminals)
cd user-finance-service && ./mvnw spring-boot:run
cd goal-service && ./mvnw spring-boot:run  
cd insight-service && ./mvnw spring-boot:run
cd api-gateway && ./mvnw spring-boot:run
```

#### Step 2: Start Frontend
```bash
cd frontend
npm install  # First time only
npm start
```

#### Step 3: Test with Guest Account
1. Open http://localhost:3000
2. Click **"Login as Guest"** button
3. Uses credentials: `arya@gmail.com` / `arya@123`

### Option 2: Frontend Only (Mock Data Mode)

If you want to see the UI without backend services:

#### Step 1: Modify API Service for Mock Mode
```bash
cd frontend/src/services
```

Create a mock mode by updating `api.js`:

```javascript
// Add this at the top of api.js
const MOCK_MODE = true; // Set to false when backend is ready

// Mock data responses
const mockResponses = {
  login: {
    data: {
      success: true,
      user: { id: 1, firstName: 'Arya', lastName: 'User', email: 'arya@gmail.com' },
      token: 'mock-jwt-token'
    }
  },
  goals: {
    data: {
      success: true,
      goals: [
        {
          id: 1,
          title: 'Emergency Fund',
          description: 'Save for emergencies',
          targetAmount: 10000,
          currentAmount: 7500,
          category: { name: 'Emergency' },
          status: 'ACTIVE',
          priorityLevel: 'HIGH'
        }
      ],
      count: 1
    }
  }
};
```

#### Step 2: Start Frontend Only
```bash
cd frontend
npm start
```

## 🎯 Testing Scenarios

### 1. Authentication Testing

#### A. Guest Login (Easiest)
1. Go to http://localhost:3000
2. Click **"Login as Guest"**
3. Should redirect to dashboard

#### B. Manual Login
1. Use email: `arya@gmail.com`
2. Use password: `arya@123`
3. Click "Sign In"

#### C. Registration Test
1. Click "Sign up here"
2. Fill in the form:
   - First Name: `Test`
   - Last Name: `User`
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
3. Click "Create Account"

### 2. Dashboard Testing

Once logged in, you should see:
- ✅ Welcome message with user name
- ✅ Financial overview cards (Income, Expenses, Balance, Goals)
- ✅ Interactive charts (Income vs Expenses, Spending by Category)
- ✅ Recent activity feed
- ✅ Quick action buttons

### 3. Goals Management Testing

#### Navigate to Goals Page
1. Click "Goals" in sidebar
2. Should see goals overview

#### Create New Goal
1. Click "Create New Goal"
2. Fill in the modal:
   - Title: `Vacation Fund`
   - Description: `Save for summer vacation`
   - Target Amount: `5000`
   - Current Amount: `1200`
   - Category: `Vacation`
   - Priority: `Medium`
   - Target Date: `2024-12-31`
3. Click "Create Goal"

#### Test Goal Actions
- ✅ Edit goal (pencil icon)
- ✅ Delete goal (trash icon)
- ✅ View progress bars
- ✅ Filter by status/category/priority

### 4. Transactions Testing

#### Navigate to Transactions
1. Click "Transactions" in sidebar
2. Should see transaction list and summary

#### Expected Features
- ✅ Transaction list with icons
- ✅ Income (green) vs Expense (red) indicators
- ✅ Summary cards (Total Income, Expenses, Balance)
- ✅ Filter and search buttons

### 5. Insights Testing

#### Navigate to Insights
1. Click "Insights" in sidebar
2. Should see analytics dashboard

#### Expected Charts
- ✅ Spending Trends (Area chart)
- ✅ Category Breakdown (Pie chart)
- ✅ Goal Progress (Bar chart)
- ✅ Monthly Savings (Line chart)
- ✅ Insight cards with recommendations

### 6. Profile Testing

#### Navigate to Profile
1. Click "Profile" in sidebar
2. Should see user profile page

#### Test Profile Features
- ✅ User avatar with initials
- ✅ Account statistics
- ✅ Edit profile information
- ✅ Account settings buttons

## 📱 Responsive Testing

### Desktop (1200px+)
- ✅ Full sidebar visible
- ✅ Multi-column layouts
- ✅ Large charts and cards

### Tablet (768px - 1024px)
- ✅ Sidebar collapses to hamburger menu
- ✅ Responsive grid layouts
- ✅ Touch-friendly buttons

### Mobile (< 768px)
- ✅ Mobile-first navigation
- ✅ Single-column layouts
- ✅ Optimized chart sizes
- ✅ Touch gestures

## 🎨 UI/UX Features to Test

### Animations & Transitions
- ✅ Page transitions (smooth fade-in)
- ✅ Card hover effects
- ✅ Button interactions
- ✅ Modal animations
- ✅ Loading spinners

### Interactive Elements
- ✅ Form validation (try submitting empty forms)
- ✅ Password visibility toggle
- ✅ Toast notifications
- ✅ Dropdown menus
- ✅ Chart tooltips and legends

### Accessibility
- ✅ Keyboard navigation (Tab through elements)
- ✅ Screen reader support
- ✅ High contrast colors
- ✅ Focus indicators

## 🔧 Development Testing

### Hot Reload Testing
1. Start frontend: `npm start`
2. Make changes to any React component
3. Should see changes instantly in browser

### Redux DevTools
1. Install Redux DevTools browser extension
2. Open browser DevTools
3. Click "Redux" tab
4. See all state changes and actions

### Network Testing
1. Open browser DevTools → Network tab
2. Perform actions (login, create goal, etc.)
3. See API calls to backend services

## 🐛 Common Issues & Solutions

### Issue: "Cannot connect to backend"
**Solution**: Make sure API Gateway is running on port 8081
```bash
curl http://localhost:8081/gateway/health
```

### Issue: "Login fails"
**Solution**: 
1. Check if authentication service is running
2. Verify guest user exists in database
3. Check browser console for errors

### Issue: "Charts not displaying"
**Solution**: 
1. Check if data is being fetched
2. Look for console errors
3. Verify Recharts is installed: `npm list recharts`

### Issue: "Styles not loading"
**Solution**:
1. Check if styled-components is installed
2. Verify theme provider is wrapping the app
3. Clear browser cache

## 📊 Sample Data for Testing

### Create Test User (if backend is running):
```json
POST /auth/register
{
  "firstName": "Arya",
  "lastName": "Tester", 
  "email": "arya@gmail.com",
  "password": "arya@123"
}
```

### Add Sample Goal:
```json
POST /goals
{
  "title": "Emergency Fund",
  "description": "6 months of expenses",
  "targetAmount": 15000,
  "currentAmount": 5000,
  "categoryId": 1,
  "priorityLevel": "HIGH",
  "targetDate": "2024-12-31",
  "userId": 1
}
```

### Add Sample Transaction:
```json
POST /finance/transactions
{
  "amount": 3500,
  "description": "Monthly Salary",
  "categoryId": 1,
  "transactionType": "INCOME",
  "transactionDate": "2024-01-15",
  "userId": 1
}
```

## ✅ Testing Checklist

### Basic Functionality
- [ ] Frontend starts without errors
- [ ] Login page loads correctly
- [ ] Guest login works
- [ ] Dashboard displays after login
- [ ] All navigation links work
- [ ] Logout functionality works

### Advanced Features
- [ ] Charts render correctly
- [ ] Forms validate properly
- [ ] Modals open and close
- [ ] Responsive design works
- [ ] Animations are smooth
- [ ] Error handling works

### Performance
- [ ] Page loads quickly (< 3 seconds)
- [ ] No console errors
- [ ] Smooth interactions
- [ ] Efficient re-renders

## 🎉 Success Indicators

If you see these, the frontend is working perfectly:

1. **Login Page**: Beautiful gradient background, clean form, guest login option
2. **Dashboard**: Colorful cards, interactive charts, recent activity
3. **Goals**: Goal cards with progress bars, create/edit modals
4. **Transactions**: Transaction list with icons, summary statistics
5. **Insights**: Multiple chart types, financial recommendations
6. **Profile**: User avatar, editable information, account stats

The frontend is now ready for production use! 🚀
