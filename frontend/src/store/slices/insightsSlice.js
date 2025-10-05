import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { insightsService } from '../../services/apiConfig';

// Async thunks
export const fetchUserInsights = createAsyncThunk(
  'insights/fetchUserInsights',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await insightsService.getCompleteOverview(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch insights');
    }
  }
);

export const fetchSpendingAnalytics = createAsyncThunk(
  'insights/fetchSpendingAnalytics',
  async ({ userId, period = 'MONTHLY' }, { rejectWithValue }) => {
    try {
      const response = await insightsService.getSpendingAnalytics(userId, period);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch analytics');
    }
  }
);

export const fetchSpendingSummary = createAsyncThunk(
  'insights/fetchSpendingSummary',
  async ({ userId, period = 'MONTHLY' }, { rejectWithValue }) => {
    try {
      const response = await insightsService.getSpendingSummary(userId, period);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch spending summary');
    }
  }
);

export const fetchSpendingTrends = createAsyncThunk(
  'insights/fetchSpendingTrends',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await insightsService.getSpendingTrends(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch trends');
    }
  }
);

const initialState = {
  overview: {
    transactions: [],
    goals: [],
    transactionSummary: {},
    analyticsSummary: {},
    combinedInsights: {},
  },
  analytics: [],
  spendingSummary: {},
  trends: {},
  isLoading: false,
  error: null,
  lastUpdated: null,
};

const insightsSlice = createSlice({
  name: 'insights',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    clearInsights: (state) => {
      state.overview = {
        transactions: [],
        goals: [],
        transactionSummary: {},
        analyticsSummary: {},
        combinedInsights: {},
      };
      state.analytics = [];
      state.spendingSummary = {};
      state.trends = {};
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch user insights
      .addCase(fetchUserInsights.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchUserInsights.fulfilled, (state, action) => {
        state.isLoading = false;
        state.overview = {
          transactions: action.payload.transactions || [],
          goals: action.payload.goals || [],
          transactionSummary: action.payload.transactionSummary || {},
          analyticsSummary: action.payload.analyticsSummary || {},
          combinedInsights: action.payload.combinedInsights || {},
        };
        state.lastUpdated = new Date().toISOString();
      })
      .addCase(fetchUserInsights.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Fetch spending analytics
      .addCase(fetchSpendingAnalytics.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchSpendingAnalytics.fulfilled, (state, action) => {
        state.isLoading = false;
        state.analytics = action.payload.analytics || [];
      })
      .addCase(fetchSpendingAnalytics.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Fetch spending summary
      .addCase(fetchSpendingSummary.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchSpendingSummary.fulfilled, (state, action) => {
        state.isLoading = false;
        state.spendingSummary = action.payload;
      })
      .addCase(fetchSpendingSummary.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Fetch spending trends
      .addCase(fetchSpendingTrends.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchSpendingTrends.fulfilled, (state, action) => {
        state.isLoading = false;
        state.trends = action.payload;
      })
      .addCase(fetchSpendingTrends.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      });
  },
});

export const { clearError, clearInsights } = insightsSlice.actions;
export default insightsSlice.reducer;
