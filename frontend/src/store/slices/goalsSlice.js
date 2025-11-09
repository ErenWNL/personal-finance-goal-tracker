import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { goalsService } from '../../services/apiConfig';

// Async thunks
export const fetchUserGoals = createAsyncThunk(
  'goals/fetchUserGoals',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await goalsService.getUserGoals(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch goals');
    }
  }
);

export const createGoal = createAsyncThunk(
  'goals/createGoal',
  async (goalData, { rejectWithValue }) => {
    try {
      const response = await goalsService.createGoal(goalData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create goal');
    }
  }
);

export const updateGoal = createAsyncThunk(
  'goals/updateGoal',
  async ({ id, goalData }, { rejectWithValue }) => {
    try {
      const response = await goalsService.updateGoal(id, goalData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update goal');
    }
  }
);

export const deleteGoal = createAsyncThunk(
  'goals/deleteGoal',
  async (goalId, { rejectWithValue }) => {
    try {
      const response = await goalsService.deleteGoal(goalId);
      return { goalId, ...response.data };
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete goal');
    }
  }
);

const initialState = {
  goals: [],
  currentGoal: null,
  isLoading: false,
  error: null,
  totalGoals: 0,
  completedGoals: 0,
};

const goalsSlice = createSlice({
  name: 'goals',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    setCurrentGoal: (state, action) => {
      state.currentGoal = action.payload;
    },
    clearCurrentGoal: (state) => {
      state.currentGoal = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch goals
      .addCase(fetchUserGoals.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchUserGoals.fulfilled, (state, action) => {
        state.isLoading = false;
        state.goals = action.payload.goals || [];
        state.totalGoals = action.payload.count || 0;
        state.completedGoals = state.goals.filter(goal => goal.status === 'COMPLETED').length;
      })
      .addCase(fetchUserGoals.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Create goal
      .addCase(createGoal.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(createGoal.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.success && action.payload.goal) {
          state.goals.push(action.payload.goal);
          state.totalGoals += 1;
          state.completedGoals = state.goals.filter(goal => goal.status === 'COMPLETED').length;
        }
      })
      .addCase(createGoal.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Update goal
      .addCase(updateGoal.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(updateGoal.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.success && action.payload.goal) {
          const index = state.goals.findIndex(goal => goal.id === action.payload.goal.id);
          if (index !== -1) {
            state.goals[index] = action.payload.goal;
          }
          state.completedGoals = state.goals.filter(goal => goal.status === 'COMPLETED').length;
        }
      })
      .addCase(updateGoal.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Delete goal
      .addCase(deleteGoal.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(deleteGoal.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.success) {
          state.goals = state.goals.filter(goal => goal.id !== action.payload.goalId);
          state.totalGoals -= 1;
          state.completedGoals = state.goals.filter(goal => goal.status === 'COMPLETED').length;
        }
      })
      .addCase(deleteGoal.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      });
  },
});

export const { clearError, setCurrentGoal, clearCurrentGoal } = goalsSlice.actions;
export default goalsSlice.reducer;
