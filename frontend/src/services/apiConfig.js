// API Configuration - Switch between real API and mock API
import api, { authAPI, goalsAPI, financeAPI, insightsAPI } from './api';
import mockApi, { mockAuthAPI, mockGoalsAPI, mockFinanceAPI, mockInsightsAPI } from './mockApi';

// Set to true to use mock data (no backend required)
// Set to false to use real backend API
export const USE_MOCK_API = false;

// Export the appropriate API based on configuration
export const apiClient = USE_MOCK_API ? null : api;

export const authService = USE_MOCK_API ? mockAuthAPI : authAPI;
export const goalsService = USE_MOCK_API ? mockGoalsAPI : goalsAPI;
export const financeService = USE_MOCK_API ? mockFinanceAPI : financeAPI;
export const insightsService = USE_MOCK_API ? mockInsightsAPI : insightsAPI;

// Helper function to check if we're in mock mode
export const isMockMode = () => USE_MOCK_API;

// Helper function to get base URL
export const getBaseURL = () => USE_MOCK_API ? 'mock://localhost' : (process.env.REACT_APP_API_URL || 'http://localhost:8081');

export default {
  auth: authService,
  goals: goalsService,
  finance: financeService,
  insights: insightsService,
  isMockMode,
  getBaseURL
};
