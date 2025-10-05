import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Provider } from 'react-redux';
import { ThemeProvider } from 'styled-components';
import { Toaster } from 'react-hot-toast';
import { store } from './store/store';
import { theme } from './styles/theme';
import { GlobalStyles } from './styles/GlobalStyles';

// Components
import Layout from './components/Layout/Layout';
import ProtectedRoute from './components/Auth/ProtectedRoute';
import DemoModeIndicator from './components/DemoModeIndicator';

// Pages
import Login from './pages/Auth/Login';
import Register from './pages/Auth/Register';
import Dashboard from './pages/Dashboard/Dashboard';
import Goals from './pages/Goals/Goals';
import Transactions from './pages/Transactions/Transactions';
import Insights from './pages/Insights/Insights';
import Profile from './pages/Profile/Profile';
import NotFound from './pages/NotFound/NotFound';

function App() {
  return (
    <Provider store={store}>
      <ThemeProvider theme={theme}>
        <GlobalStyles />
        <Router>
          <div className="App">
            <Routes>
              {/* Public routes */}
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              
              {/* Protected routes */}
              <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
                <Route index element={<Navigate to="/dashboard" replace />} />
                <Route path="dashboard" element={<Dashboard />} />
                <Route path="goals" element={<Goals />} />
                <Route path="transactions" element={<Transactions />} />
                <Route path="insights" element={<Insights />} />
                <Route path="profile" element={<Profile />} />
              </Route>
              
              {/* 404 route */}
              <Route path="*" element={<NotFound />} />
            </Routes>
            
            {/* Demo mode indicator */}
            <DemoModeIndicator />
            
            {/* Toast notifications */}
            <Toaster
              position="top-right"
              toastOptions={{
                duration: 4000,
                style: {
                  background: theme.colors.white,
                  color: theme.colors.gray[800],
                  boxShadow: theme.shadows.lg,
                  borderRadius: theme.borderRadius.lg,
                  padding: theme.spacing[4],
                },
                success: {
                  iconTheme: {
                    primary: theme.colors.success[600],
                    secondary: theme.colors.white,
                  },
                },
                error: {
                  iconTheme: {
                    primary: theme.colors.error[600],
                    secondary: theme.colors.white,
                  },
                },
              }}
            />
          </div>
        </Router>
      </ThemeProvider>
    </Provider>
  );
}

export default App;