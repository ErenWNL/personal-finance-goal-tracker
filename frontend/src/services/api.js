import axios from 'axios';

// Create axios instance with base configuration
const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8081',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Authentication API
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  register: (userData) => api.post('/auth/register', userData),
  getUserById: (id) => api.get(`/auth/user/${id}`),
  updateUser: (id, userData) => api.put(`/auth/user/${id}`, userData),
  deleteUser: (id) => api.delete(`/auth/user/${id}`),
  getAllUsers: () => api.get('/auth/users'),
};

// Goals API
export const goalsAPI = {
  createGoal: (goalData) => api.post('/goals', goalData),
  getAllGoals: () => api.get('/goals'),
  getUserGoals: (userId) => api.get(`/goals/user/${userId}`),
  getGoalById: (id) => api.get(`/goals/${id}`),
  updateGoal: (id, goalData) => api.put(`/goals/${id}`, goalData),
  deleteGoal: (id) => api.delete(`/goals/${id}`),
};

// Finance API
export const financeAPI = {
  // Transactions
  createTransaction: (transactionData) => api.post('/finance/transactions', transactionData),
  getAllTransactions: () => api.get('/finance/transactions'),
  getUserTransactions: (userId) => api.get(`/finance/transactions/user/${userId}`),
  getTransactionById: (id) => api.get(`/finance/transactions/${id}`),
  updateTransaction: (id, transactionData) => api.put(`/finance/transactions/${id}`, transactionData),
  deleteTransaction: (id) => api.delete(`/finance/transactions/${id}`),
  getUserTransactionSummary: (userId) => api.get(`/finance/transactions/user/${userId}/summary`),
  
  // Categories
  createCategory: (categoryData) => api.post('/finance/categories', categoryData),
  getAllCategories: () => api.get('/finance/categories'),
  getCategoryById: (id) => api.get(`/finance/categories/${id}`),
  updateCategory: (id, categoryData) => api.put(`/finance/categories/${id}`, categoryData),
  deleteCategory: (id) => api.delete(`/finance/categories/${id}`),
};

// Insights API
export const insightsAPI = {
  getCompleteOverview: (userId) => api.get(`/integrated/user/${userId}/complete-overview`),
  getGoalProgressAnalysis: (userId) => api.get(`/integrated/user/${userId}/goal-progress-analysis`),
  getSpendingAnalytics: (userId, period = 'MONTHLY') => api.get(`/analytics/user/${userId}?period=${period}`),
  getSpendingSummary: (userId, period = 'MONTHLY') => api.get(`/analytics/user/${userId}/summary?period=${period}`),
  getSpendingTrends: (userId) => api.get(`/analytics/user/${userId}/trends`),
  getCategoryAnalytics: (userId, categoryId) => api.get(`/analytics/user/${userId}/category/${categoryId}`),
  getRecommendations: (userId) => api.get(`/recommendations/user/${userId}`),
};

// Gateway API
export const gatewayAPI = {
  health: () => api.get('/gateway/health'),
  getServices: () => api.get('/gateway/services'),
  getRoutes: () => api.get('/gateway/routes'),
};

export default api;
