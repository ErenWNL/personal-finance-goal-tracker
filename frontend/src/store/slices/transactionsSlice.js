import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { financeService } from '../../services/apiConfig';

// Async thunks
export const fetchUserTransactions = createAsyncThunk(
  'transactions/fetchUserTransactions',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await financeService.getUserTransactions(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch transactions');
    }
  }
);

export const fetchTransactionSummary = createAsyncThunk(
  'transactions/fetchTransactionSummary',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await financeService.getUserTransactionSummary(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch summary');
    }
  }
);

export const createTransaction = createAsyncThunk(
  'transactions/createTransaction',
  async (transactionData, { rejectWithValue }) => {
    try {
      const response = await financeService.createTransaction(transactionData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create transaction');
    }
  }
);

export const updateTransaction = createAsyncThunk(
  'transactions/updateTransaction',
  async ({ id, transactionData }, { rejectWithValue }) => {
    try {
      const response = await financeService.updateTransaction(id, transactionData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update transaction');
    }
  }
);

export const deleteTransaction = createAsyncThunk(
  'transactions/deleteTransaction',
  async (transactionId, { rejectWithValue }) => {
    try {
      const response = await financeService.deleteTransaction(transactionId);
      return { transactionId, ...response.data };
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete transaction');
    }
  }
);

const initialState = {
  transactions: [],
  summary: {
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
  },
  categories: [],
  isLoading: false,
  error: null,
  currentTransaction: null,
};

const transactionsSlice = createSlice({
  name: 'transactions',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    setCurrentTransaction: (state, action) => {
      state.currentTransaction = action.payload;
    },
    clearCurrentTransaction: (state) => {
      state.currentTransaction = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch transactions
      .addCase(fetchUserTransactions.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchUserTransactions.fulfilled, (state, action) => {
        state.isLoading = false;
        state.transactions = action.payload.transactions || [];
      })
      .addCase(fetchUserTransactions.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Fetch summary
      .addCase(fetchTransactionSummary.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchTransactionSummary.fulfilled, (state, action) => {
        state.isLoading = false;
        state.summary = {
          totalIncome: action.payload.totalIncome || 0,
          totalExpense: action.payload.totalExpense || 0,
          balance: action.payload.balance || 0,
        };
      })
      .addCase(fetchTransactionSummary.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Create transaction
      .addCase(createTransaction.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(createTransaction.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.success && action.payload.transaction) {
          state.transactions.unshift(action.payload.transaction);
        }
      })
      .addCase(createTransaction.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Update transaction
      .addCase(updateTransaction.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(updateTransaction.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.success && action.payload.transaction) {
          const index = state.transactions.findIndex(t => t.id === action.payload.transaction.id);
          if (index !== -1) {
            state.transactions[index] = action.payload.transaction;
          }
        }
      })
      .addCase(updateTransaction.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Delete transaction
      .addCase(deleteTransaction.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(deleteTransaction.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.success) {
          state.transactions = state.transactions.filter(t => t.id !== action.payload.transactionId);
        }
      })
      .addCase(deleteTransaction.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      });
  },
});

export const { clearError, setCurrentTransaction, clearCurrentTransaction } = transactionsSlice.actions;
export default transactionsSlice.reducer;
