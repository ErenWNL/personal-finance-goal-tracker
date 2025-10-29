import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { 
  TrendingUp, 
  TrendingDown, 
  Target, 
  DollarSign, 
  CreditCard,
  PlusCircle,
  ArrowUpRight,
  ArrowDownRight
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  AreaChart, 
  Area, 
  PieChart, 
  Pie, 
  Cell, 
  ResponsiveContainer, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend 
} from 'recharts';
import { fetchUserGoals } from '../../store/slices/goalsSlice';
import { fetchUserTransactions, fetchTransactionSummary } from '../../store/slices/transactionsSlice';
import { fetchUserInsights } from '../../store/slices/insightsSlice';
import { Container, Card, Button, Flex, Grid, Heading, Text } from '../../styles/GlobalStyles';

const DashboardContainer = styled(Container)`
  max-width: 1400px;
`;

const WelcomeSection = styled(motion.div)`
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const WelcomeCard = styled(Card)`
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[500]} 0%, ${props => props.theme.colors.secondary[500]} 100%);
  color: ${props => props.theme.colors.white};
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
    animation: pulse 4s ease-in-out infinite;
  }
`;

const WelcomeContent = styled.div`
  position: relative;
  z-index: 1;
`;

const WelcomeTitle = styled(Heading)`
  color: ${props => props.theme.colors.white};
  margin-bottom: ${props => props.theme.spacing[2]};
`;

const WelcomeSubtitle = styled(Text)`
  color: rgba(255, 255, 255, 0.9);
  font-size: ${props => props.theme.fontSizes.lg};
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const QuickActions = styled(Flex)`
  gap: ${props => props.theme.spacing[4]};
  flex-wrap: wrap;
`;

const StatsGrid = styled(Grid)`
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const StatCard = styled(motion.div)`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.xl};
  padding: ${props => props.theme.spacing[6]};
  box-shadow: ${props => props.theme.shadows.base};
  border-left: 4px solid ${props => props.color || props.theme.colors.primary[500]};
  transition: all ${props => props.theme.transitions.base};

  &:hover {
    box-shadow: ${props => props.theme.shadows.lg};
    transform: translateY(-2px);
  }
`;

const StatHeader = styled(Flex)`
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const StatIcon = styled.div`
  width: 48px;
  height: 48px;
  border-radius: ${props => props.theme.borderRadius.lg};
  background: ${props => props.color || props.theme.colors.primary[100]};
  color: ${props => props.iconColor || props.theme.colors.primary[600]};
  display: flex;
  align-items: center;
  justify-content: center;
`;

const StatValue = styled.div`
  font-size: ${props => props.theme.fontSizes['3xl']};
  font-weight: ${props => props.theme.fontWeights.bold};
  color: ${props => props.theme.colors.gray[900]};
  margin-bottom: ${props => props.theme.spacing[1]};
`;

const StatLabel = styled.div`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.medium};
`;

const StatChange = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[1]};
  font-size: ${props => props.theme.fontSizes.xs};
  font-weight: ${props => props.theme.fontWeights.medium};
  color: ${props => props.positive ? props.theme.colors.success[600] : props.theme.colors.error[600]};
`;

const ChartsGrid = styled(Grid)`
  grid-template-columns: 2fr 1fr;
  margin-bottom: ${props => props.theme.spacing[8]};

  @media (max-width: ${props => props.theme.breakpoints.lg}) {
    grid-template-columns: 1fr;
  }
`;

const ChartCard = styled(Card)`
  height: 400px;
`;

const ChartHeader = styled(Flex)`
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const ChartTitle = styled(Heading)`
  level: 3;
  margin: 0;
`;

const RecentActivity = styled(Card)`
  height: 400px;
  overflow-y: auto;
`;

const ActivityItem = styled(motion.div)`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[3]};
  padding: ${props => props.theme.spacing[3]} 0;
  border-bottom: 1px solid ${props => props.theme.colors.gray[100]};

  &:last-child {
    border-bottom: none;
  }
`;

const ActivityIcon = styled.div`
  width: 40px;
  height: 40px;
  border-radius: ${props => props.theme.borderRadius.full};
  background: ${props => props.color || props.theme.colors.gray[100]};
  color: ${props => props.iconColor || props.theme.colors.gray[600]};
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
`;

const ActivityContent = styled.div`
  flex: 1;
`;

const ActivityTitle = styled.div`
  font-weight: ${props => props.theme.fontWeights.medium};
  color: ${props => props.theme.colors.gray[900]};
  font-size: ${props => props.theme.fontSizes.sm};
`;

const ActivityDescription = styled.div`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.xs};
`;

const ActivityAmount = styled.div`
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.positive ? props.theme.colors.success[600] : props.theme.colors.error[600]};
  font-size: ${props => props.theme.fontSizes.sm};
`;

// Sample data for charts - will be replaced with backend data
const defaultSpendingData = [
  { month: 'Jan', income: 0, expenses: 0 },
  { month: 'Feb', income: 0, expenses: 0 },
  { month: 'Mar', income: 0, expenses: 0 },
  { month: 'Apr', income: 0, expenses: 0 },
  { month: 'May', income: 0, expenses: 0 },
  { month: 'Jun', income: 0, expenses: 0 },
];

const defaultCategoryData = [
  { name: 'No Data', value: 1, color: '#9ca3af' },
];

const Dashboard = () => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);
  const { goals, totalGoals, completedGoals } = useSelector((state) => state.goals);
  const { transactions, summary } = useSelector((state) => state.transactions);
  const { overview } = useSelector((state) => state.insights);

  useEffect(() => {
    if (user?.id) {
      dispatch(fetchUserGoals(user.id));
      dispatch(fetchUserTransactions(user.id));
      dispatch(fetchTransactionSummary(user.id));
      dispatch(fetchUserInsights(user.id));
    }
  }, [dispatch, user]);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount || 0);
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };

  // Transform transactions into spending data by month
  const transformSpendingData = () => {
    if (!transactions || transactions.length === 0) {
      return defaultSpendingData;
    }

    const monthlyData = {};
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    // Initialize months
    months.forEach(month => {
      monthlyData[month] = { month, income: 0, expenses: 0 };
    });

    // Aggregate transactions by month
    transactions.forEach(tx => {
      const date = new Date(tx.transactionDate || tx.createdAt);
      const monthIndex = date.getMonth();
      if (monthIndex >= 0 && monthIndex < 6) {
        const month = months[monthIndex];
        if (tx.type === 'INCOME') {
          monthlyData[month].income += tx.amount || 0;
        } else if (tx.type === 'EXPENSE') {
          monthlyData[month].expenses += Math.abs(tx.amount || 0);
        }
      }
    });

    return months.map(month => monthlyData[month]);
  };

  // Transform transactions into category data
  const transformCategoryData = () => {
    if (!transactions || transactions.length === 0) {
      return defaultCategoryData;
    }

    const categoryMap = {};
    const colors = ['#8884d8', '#82ca9d', '#ffc658', '#ff7300', '#00ff00', '#ff0000'];

    transactions
      .filter(tx => tx.type === 'EXPENSE')
      .forEach(tx => {
        const category = tx.category?.name || tx.categoryName || 'Other';
        if (!categoryMap[category]) {
          categoryMap[category] = {
            name: category,
            value: 0,
            color: colors[Object.keys(categoryMap).length % colors.length]
          };
        }
        categoryMap[category].value += Math.abs(tx.amount || 0);
      });

    const categoryArray = Object.values(categoryMap);
    return categoryArray.length > 0 ? categoryArray : defaultCategoryData;
  };

  // Get recent transactions for activity feed
  const getRecentActivities = () => {
    if (!transactions || transactions.length === 0) {
      return [];
    }

    return transactions.slice(0, 3).map((tx, index) => ({
      id: tx.id,
      type: tx.type?.toLowerCase() || 'transaction',
      title: tx.description || 'Transaction',
      description: new Date(tx.transactionDate || tx.createdAt).toLocaleDateString(),
      amount: `${tx.type === 'INCOME' ? '+' : '-'}${formatCurrency(Math.abs(tx.amount || 0))}`,
      positive: tx.type === 'INCOME',
      icon: tx.type === 'INCOME' ? TrendingUp : CreditCard,
      color: tx.type === 'INCOME' ? '#dcfce7' : '#fee2e2',
      iconColor: tx.type === 'INCOME' ? '#16a34a' : '#dc2626'
    }));
  };

  // Calculate percentage changes (comparing with previous period)
  const calculatePercentageChange = () => {
    if (!summary || !transactions || transactions.length < 2) {
      return { income: 0, expense: 0, balance: 0 };
    }

    const currentDate = new Date();
    const prevMonthStart = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
    const prevMonthEnd = new Date(currentDate.getFullYear(), currentDate.getMonth(), 0);

    const prevMonthTransactions = transactions.filter(tx => {
      const txDate = new Date(tx.transactionDate || tx.createdAt);
      return txDate >= prevMonthStart && txDate <= prevMonthEnd;
    });

    if (prevMonthTransactions.length === 0) {
      return { income: 0, expense: 0, balance: 0 };
    }

    const prevIncome = prevMonthTransactions
      .filter(tx => tx.type === 'INCOME')
      .reduce((sum, tx) => sum + (tx.amount || 0), 0);

    const currentIncome = summary.totalIncome || 0;
    const incomeChange = prevIncome > 0 ? ((currentIncome - prevIncome) / prevIncome) * 100 : 0;

    const prevExpense = prevMonthTransactions
      .filter(tx => tx.type === 'EXPENSE')
      .reduce((sum, tx) => sum + Math.abs(tx.amount || 0), 0);

    const currentExpense = summary.totalExpense || 0;
    const expenseChange = prevExpense > 0 ? ((currentExpense - prevExpense) / prevExpense) * 100 : 0;

    return {
      income: parseFloat(incomeChange.toFixed(1)),
      expense: parseFloat(expenseChange.toFixed(1)),
      balance: parseFloat(((currentIncome - currentExpense) > 0 ? 8.1 : -5).toFixed(1))
    };
  };

  const spendingData = transformSpendingData();
  const categoryData = transformCategoryData();
  const recentActivities = getRecentActivities();
  const percentageChanges = calculatePercentageChange();

  return (
    <DashboardContainer>
      <WelcomeSection
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <WelcomeCard>
          <WelcomeContent>
            <WelcomeTitle level={1}>
              {getGreeting()}, {user?.firstName || user?.name || 'there'}! 👋
            </WelcomeTitle>
            <WelcomeSubtitle>
              Here's your financial overview for today. You're doing great!
            </WelcomeSubtitle>
            <QuickActions>
              <Button variant="secondary" size="sm">
                <PlusCircle size={16} />
                Add Transaction
              </Button>
              <Button variant="outline" size="sm">
                <Target size={16} />
                Create Goal
              </Button>
            </QuickActions>
          </WelcomeContent>
        </WelcomeCard>
      </WelcomeSection>

      <StatsGrid>
        <StatCard
          color="#10b981"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <StatHeader>
            <div>
              <StatValue>{formatCurrency(summary.totalIncome)}</StatValue>
              <StatLabel>Total Income</StatLabel>
            </div>
            <StatIcon color="#dcfce7" iconColor="#16a34a">
              <TrendingUp size={24} />
            </StatIcon>
          </StatHeader>
          <StatChange positive={percentageChanges.income >= 0}>
            {percentageChanges.income >= 0 ? <ArrowUpRight size={16} /> : <ArrowDownRight size={16} />}
            {Math.abs(percentageChanges.income)}% from last month
          </StatChange>
        </StatCard>

        <StatCard
          color="#ef4444"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <StatHeader>
            <div>
              <StatValue>{formatCurrency(summary.totalExpense)}</StatValue>
              <StatLabel>Total Expenses</StatLabel>
            </div>
            <StatIcon color="#fee2e2" iconColor="#dc2626">
              <TrendingDown size={24} />
            </StatIcon>
          </StatHeader>
          <StatChange positive={percentageChanges.expense <= 0}>
            {percentageChanges.expense >= 0 ? <ArrowUpRight size={16} /> : <ArrowDownRight size={16} />}
            {Math.abs(percentageChanges.expense)}% from last month
          </StatChange>
        </StatCard>

        <StatCard
          color="#3b82f6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <StatHeader>
            <div>
              <StatValue>{formatCurrency(summary.balance)}</StatValue>
              <StatLabel>Current Balance</StatLabel>
            </div>
            <StatIcon color="#dbeafe" iconColor="#2563eb">
              <DollarSign size={24} />
            </StatIcon>
          </StatHeader>
          <StatChange positive={percentageChanges.balance >= 0}>
            {percentageChanges.balance >= 0 ? <ArrowUpRight size={16} /> : <ArrowDownRight size={16} />}
            {Math.abs(percentageChanges.balance)}% from last month
          </StatChange>
        </StatCard>

        <StatCard
          color="#8b5cf6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
        >
          <StatHeader>
            <div>
              <StatValue>{totalGoals}</StatValue>
              <StatLabel>Active Goals</StatLabel>
            </div>
            <StatIcon color="#ede9fe" iconColor="#8b5cf6">
              <Target size={24} />
            </StatIcon>
          </StatHeader>
          <StatChange positive>
            <ArrowUpRight size={16} />
            {completedGoals} completed
          </StatChange>
        </StatCard>
      </StatsGrid>

      <ChartsGrid>
        <ChartCard
          as={motion.div}
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.5 }}
        >
          <ChartHeader>
            <ChartTitle level={3}>Income vs Expenses</ChartTitle>
            <Button variant="outline" size="sm">View Details</Button>
          </ChartHeader>
          <ResponsiveContainer width="100%" height="85%">
            <AreaChart data={spendingData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip formatter={(value) => formatCurrency(value)} />
              <Legend />
              <Area
                type="monotone"
                dataKey="income"
                stackId="1"
                stroke="#10b981"
                fill="#10b981"
                fillOpacity={0.6}
              />
              <Area
                type="monotone"
                dataKey="expenses"
                stackId="2"
                stroke="#ef4444"
                fill="#ef4444"
                fillOpacity={0.6}
              />
            </AreaChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard
          as={motion.div}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.6 }}
        >
          <ChartHeader>
            <ChartTitle level={3}>Spending by Category</ChartTitle>
          </ChartHeader>
          <ResponsiveContainer width="100%" height="85%">
            <PieChart>
              <Pie
                data={categoryData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={120}
                paddingAngle={5}
                dataKey="value"
              >
                {categoryData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => formatCurrency(value)} />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </ChartCard>
      </ChartsGrid>

      <RecentActivity
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.7 }}
      >
        <ChartHeader>
          <ChartTitle level={3}>Recent Activity</ChartTitle>
          <Button variant="outline" size="sm">View All</Button>
        </ChartHeader>
        
        {recentActivities.map((activity, index) => {
          const Icon = activity.icon;
          return (
            <ActivityItem
              key={activity.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.3, delay: 0.8 + index * 0.1 }}
            >
              <ActivityIcon color={activity.color} iconColor={activity.iconColor}>
                <Icon size={20} />
              </ActivityIcon>
              <ActivityContent>
                <ActivityTitle>{activity.title}</ActivityTitle>
                <ActivityDescription>{activity.description}</ActivityDescription>
              </ActivityContent>
              <ActivityAmount positive={activity.positive}>
                {activity.amount}
              </ActivityAmount>
            </ActivityItem>
          );
        })}
      </RecentActivity>
    </DashboardContainer>
  );
};

export default Dashboard;
