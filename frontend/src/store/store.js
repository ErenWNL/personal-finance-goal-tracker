import { configureStore } from '@reduxjs/toolkit';
import authSlice from './slices/authSlice';
import goalsSlice from './slices/goalsSlice';
import transactionsSlice from './slices/transactionsSlice';
import insightsSlice from './slices/insightsSlice';

export const store = configureStore({
  reducer: {
    auth: authSlice,
    goals: goalsSlice,
    transactions: transactionsSlice,
    insights: insightsSlice,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST'],
      },
    }),
});

export default store;
