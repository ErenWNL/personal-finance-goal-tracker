// Mock API for testing UI without backend
const MOCK_DELAY = 500; // Simulate network delay

const mockDelay = (data) => new Promise(resolve => 
  setTimeout(() => resolve({ data }), MOCK_DELAY)
);

// Mock user data
const mockUser = {
  id: 1,
  firstName: 'Arya',
  lastName: 'Demo',
  email: 'arya@gmail.com',
  phone: '+1 234 567 8900',
  address: '123 Demo Street, Test City',
  dateOfBirth: '1995-01-15',
  createdAt: '2024-01-01',
  lastLogin: new Date().toISOString()
};

// Mock goals data
const mockGoals = [
  {
    id: 1,
    title: 'Emergency Fund',
    description: 'Save 6 months of expenses for emergencies',
    targetAmount: 15000,
    currentAmount: 8500,
    category: { id: 1, name: 'Emergency Fund' },
    priorityLevel: 'HIGH',
    status: 'ACTIVE',
    targetDate: '2024-12-31',
    startDate: '2024-01-01',
    completionPercentage: 56.67,
    createdAt: '2024-01-01'
  },
  {
    id: 2,
    title: 'Vacation to Europe',
    description: 'Dream vacation to explore European cities',
    targetAmount: 5000,
    currentAmount: 2250,
    category: { id: 2, name: 'Vacation' },
    priorityLevel: 'MEDIUM',
    status: 'ACTIVE',
    targetDate: '2024-08-15',
    startDate: '2024-02-01',
    completionPercentage: 45,
    createdAt: '2024-02-01'
  },
  {
    id: 3,
    title: 'New Car Down Payment',
    description: 'Save for a reliable car down payment',
    targetAmount: 8000,
    currentAmount: 6400,
    category: { id: 3, name: 'Transportation' },
    priorityLevel: 'HIGH',
    status: 'ACTIVE',
    targetDate: '2024-10-01',
    startDate: '2024-01-15',
    completionPercentage: 80,
    createdAt: '2024-01-15'
  },
  {
    id: 4,
    title: 'Home Renovation',
    description: 'Kitchen and bathroom renovation project',
    targetAmount: 12000,
    currentAmount: 12000,
    category: { id: 4, name: 'Home' },
    priorityLevel: 'MEDIUM',
    status: 'COMPLETED',
    targetDate: '2024-06-30',
    startDate: '2024-01-01',
    completionPercentage: 100,
    createdAt: '2024-01-01'
  }
];

// Mock transactions data
const mockTransactions = [
  {
    id: 1,
    amount: 3500,
    description: 'Monthly Salary',
    category: { id: 1, name: 'Salary' },
    transactionType: 'INCOME',
    transactionDate: '2024-01-15',
    notes: 'Regular monthly income',
    createdAt: '2024-01-15'
  },
  {
    id: 2,
    amount: -1200,
    description: 'Rent Payment',
    category: { id: 2, name: 'Housing' },
    transactionType: 'EXPENSE',
    transactionDate: '2024-01-01',
    notes: 'Monthly rent',
    createdAt: '2024-01-01'
  },
  {
    id: 3,
    amount: -350,
    description: 'Grocery Shopping',
    category: { id: 3, name: 'Food' },
    transactionType: 'EXPENSE',
    transactionDate: '2024-01-14',
    notes: 'Weekly groceries',
    createdAt: '2024-01-14'
  },
  {
    id: 4,
    amount: -85,
    description: 'Gas Station',
    category: { id: 4, name: 'Transportation' },
    transactionType: 'EXPENSE',
    transactionDate: '2024-01-13',
    notes: 'Fuel for car',
    createdAt: '2024-01-13'
  },
  {
    id: 5,
    amount: 800,
    description: 'Freelance Project',
    category: { id: 5, name: 'Freelance' },
    transactionType: 'INCOME',
    transactionDate: '2024-01-12',
    notes: 'Web development project',
    createdAt: '2024-01-12'
  },
  {
    id: 6,
    amount: -120,
    description: 'Utilities Bill',
    category: { id: 6, name: 'Utilities' },
    transactionType: 'EXPENSE',
    transactionDate: '2024-01-10',
    notes: 'Electricity and water',
    createdAt: '2024-01-10'
  },
  {
    id: 7,
    amount: -45,
    description: 'Coffee Shop',
    category: { id: 7, name: 'Entertainment' },
    transactionType: 'EXPENSE',
    transactionDate: '2024-01-09',
    notes: 'Morning coffee',
    createdAt: '2024-01-09'
  },
  {
    id: 8,
    amount: -200,
    description: 'Online Shopping',
    category: { id: 8, name: 'Shopping' },
    transactionType: 'EXPENSE',
    transactionDate: '2024-01-08',
    notes: 'Clothes and accessories',
    createdAt: '2024-01-08'
  }
];

// Calculate transaction summary
const calculateSummary = () => {
  const totalIncome = mockTransactions
    .filter(t => t.transactionType === 'INCOME')
    .reduce((sum, t) => sum + t.amount, 0);
  
  const totalExpense = Math.abs(mockTransactions
    .filter(t => t.transactionType === 'EXPENSE')
    .reduce((sum, t) => sum + t.amount, 0));
  
  return {
    totalIncome,
    totalExpense,
    balance: totalIncome - totalExpense
  };
};

// Mock insights data
const mockInsights = {
  transactions: mockTransactions,
  goals: mockGoals,
  transactionSummary: calculateSummary(),
  analyticsSummary: {
    monthlySpending: 2000,
    averageTransaction: 156,
    topCategory: 'Housing',
    savingsRate: 0.25
  },
  combinedInsights: {
    totalSaved: mockGoals.reduce((sum, goal) => sum + goal.currentAmount, 0),
    goalsOnTrack: mockGoals.filter(g => g.completionPercentage > 50).length,
    monthlyProgress: 15.5,
    recommendations: [
      'Great job on your emergency fund progress!',
      'Consider increasing your vacation savings',
      'You\'re spending 35% on housing - within recommended range'
    ]
  }
};

// Mock API functions
export const mockAuthAPI = {
  login: (credentials) => {
    if (credentials.email === 'arya@gmail.com' && credentials.password === 'arya@123') {
      return mockDelay({
        success: true,
        message: 'Login successful',
        user: mockUser,
        token: 'mock-jwt-token-' + Date.now()
      });
    }
    return mockDelay({
      success: false,
      message: 'Invalid email or password'
    });
  },
  
  register: (userData) => {
    return mockDelay({
      success: true,
      message: 'User registered successfully',
      user: { ...mockUser, ...userData, id: Date.now() }
    });
  },
  
  getUserById: (id) => {
    return mockDelay({
      success: true,
      user: mockUser
    });
  }
};

export const mockGoalsAPI = {
  getUserGoals: (userId) => {
    return mockDelay({
      success: true,
      goals: mockGoals,
      count: mockGoals.length
    });
  },
  
  createGoal: (goalData) => {
    const newGoal = {
      ...goalData,
      id: Date.now(),
      currentAmount: goalData.currentAmount || 0,
      completionPercentage: ((goalData.currentAmount || 0) / goalData.targetAmount) * 100,
      status: 'ACTIVE',
      createdAt: new Date().toISOString(),
      category: { id: goalData.categoryId, name: 'New Category' }
    };
    
    return mockDelay({
      success: true,
      message: 'Goal created successfully',
      goal: newGoal
    });
  },
  
  updateGoal: (id, goalData) => {
    const updatedGoal = {
      ...mockGoals.find(g => g.id === parseInt(id)),
      ...goalData,
      completionPercentage: ((goalData.currentAmount || 0) / goalData.targetAmount) * 100,
      updatedAt: new Date().toISOString()
    };
    
    return mockDelay({
      success: true,
      message: 'Goal updated successfully',
      goal: updatedGoal
    });
  },
  
  deleteGoal: (id) => {
    return mockDelay({
      success: true,
      message: 'Goal deleted successfully'
    });
  }
};

export const mockFinanceAPI = {
  getUserTransactions: (userId) => {
    return mockDelay({
      success: true,
      transactions: mockTransactions,
      count: mockTransactions.length
    });
  },
  
  getUserTransactionSummary: (userId) => {
    return mockDelay({
      success: true,
      ...calculateSummary()
    });
  },
  
  createTransaction: (transactionData) => {
    const newTransaction = {
      ...transactionData,
      id: Date.now(),
      createdAt: new Date().toISOString(),
      category: { id: transactionData.categoryId, name: 'New Category' }
    };
    
    return mockDelay({
      success: true,
      message: 'Transaction created successfully',
      transaction: newTransaction
    });
  }
};

export const mockInsightsAPI = {
  getCompleteOverview: (userId) => {
    return mockDelay({
      success: true,
      ...mockInsights
    });
  },
  
  getSpendingAnalytics: (userId, period) => {
    return mockDelay({
      success: true,
      analytics: [
        { category: 'Housing', amount: 1200, percentage: 40 },
        { category: 'Food', amount: 450, percentage: 15 },
        { category: 'Transportation', amount: 300, percentage: 10 },
        { category: 'Entertainment', amount: 200, percentage: 7 },
        { category: 'Shopping', amount: 250, percentage: 8 },
        { category: 'Utilities', amount: 180, percentage: 6 },
        { category: 'Other', amount: 420, percentage: 14 }
      ],
      count: 7
    });
  },
  
  getSpendingSummary: (userId, period) => {
    return mockDelay({
      success: true,
      totalSpending: 3000,
      averageDaily: 100,
      topCategory: 'Housing',
      period: period
    });
  },
  
  getSpendingTrends: (userId) => {
    return mockDelay({
      success: true,
      trends: {
        monthly: [
          { month: 'Jan', spending: 2800, income: 4300 },
          { month: 'Feb', spending: 2600, income: 4300 },
          { month: 'Mar', spending: 3200, income: 4300 },
          { month: 'Apr', spending: 2900, income: 4300 },
          { month: 'May', spending: 2700, income: 4300 },
          { month: 'Jun', spending: 3000, income: 4300 }
        ]
      }
    });
  }
};

export default {
  auth: mockAuthAPI,
  goals: mockGoalsAPI,
  finance: mockFinanceAPI,
  insights: mockInsightsAPI
};
