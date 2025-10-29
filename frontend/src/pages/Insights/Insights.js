import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { TrendingUp, PieChart, BarChart3, Target } from 'lucide-react';
import { 
  LineChart, 
  Line, 
  AreaChart, 
  Area, 
  PieChart as RechartsPieChart, 
  Pie, 
  Cell, 
  BarChart,
  Bar,
  ResponsiveContainer, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend 
} from 'recharts';
import { fetchUserInsights, fetchSpendingAnalytics } from '../../store/slices/insightsSlice';
import { Container, Card, Button, Flex, Grid, Heading, Text } from '../../styles/GlobalStyles';

const InsightsContainer = styled(Container)`
  max-width: 1400px;
`;

const PageHeader = styled(motion.div)`
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const ChartsGrid = styled(Grid)`
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const ChartCard = styled(Card)`
  height: 400px;
  padding: ${props => props.theme.spacing[6]};
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

const InsightCard = styled(Card)`
  padding: ${props => props.theme.spacing[6]};
  border-left: 4px solid ${props => props.color || props.theme.colors.primary[500]};
`;

const InsightIcon = styled.div`
  width: 48px;
  height: 48px;
  border-radius: ${props => props.theme.borderRadius.lg};
  background: ${props => props.color || props.theme.colors.primary[100]};
  color: ${props => props.iconColor || props.theme.colors.primary[600]};
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const InsightTitle = styled(Heading)`
  level: 4;
  margin-bottom: ${props => props.theme.spacing[2]};
`;

const InsightDescription = styled(Text)`
  color: ${props => props.theme.colors.gray[600]};
`;

// Default data for charts - will be replaced with backend data
const defaultSpendingTrendData = [
  { month: 'Jan', spending: 0, income: 0, savings: 0 },
  { month: 'Feb', spending: 0, income: 0, savings: 0 },
  { month: 'Mar', spending: 0, income: 0, savings: 0 },
  { month: 'Apr', spending: 0, income: 0, savings: 0 },
  { month: 'May', spending: 0, income: 0, savings: 0 },
  { month: 'Jun', spending: 0, income: 0, savings: 0 },
];

const defaultCategorySpendingData = [
  { name: 'No Data', value: 1, color: '#9ca3af' },
];

const defaultGoalProgressData = [
  { name: 'No Goals', progress: 0, target: 0, current: 0 },
];

const Insights = () => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);
  const { overview, analytics, isLoading } = useSelector((state) => state.insights);
  const { transactions } = useSelector((state) => state.transactions);
  const { goals } = useSelector((state) => state.goals);

  useEffect(() => {
    if (user?.id) {
      dispatch(fetchUserInsights(user.id));
      dispatch(fetchSpendingAnalytics({ userId: user.id, period: 'MONTHLY' }));
    }
  }, [dispatch, user]);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount || 0);
  };

  // Transform transactions into spending trends
  const transformSpendingTrendData = () => {
    if (!transactions || transactions.length === 0) {
      return defaultSpendingTrendData;
    }

    const monthlyData = {};
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    months.forEach(month => {
      monthlyData[month] = { month, spending: 0, income: 0, savings: 0 };
    });

    transactions.forEach(tx => {
      const date = new Date(tx.transactionDate || tx.createdAt);
      const monthIndex = date.getMonth();
      if (monthIndex >= 0 && monthIndex < 6) {
        const month = months[monthIndex];
        if (tx.type === 'INCOME') {
          monthlyData[month].income += tx.amount || 0;
        } else if (tx.type === 'EXPENSE') {
          monthlyData[month].spending += Math.abs(tx.amount || 0);
        }
      }
    });

    // Calculate savings
    months.forEach(month => {
      monthlyData[month].savings = monthlyData[month].income - monthlyData[month].spending;
    });

    return months.map(month => monthlyData[month]);
  };

  // Transform transactions into category spending
  const transformCategorySpendingData = () => {
    if (!transactions || transactions.length === 0) {
      return defaultCategorySpendingData;
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
    return categoryArray.length > 0 ? categoryArray : defaultCategorySpendingData;
  };

  // Transform goals into progress data
  const transformGoalProgressData = () => {
    if (!goals || goals.length === 0) {
      return defaultGoalProgressData;
    }

    return goals.map(goal => ({
      name: goal.title,
      progress: goal.completionPercentage || 0,
      target: goal.targetAmount || 0,
      current: goal.currentAmount || 0
    }));
  };

  // Generate dynamic insights based on data
  const generateInsights = () => {
    const insights = [];

    if (!transactions || transactions.length === 0) {
      return [
        {
          type: 'info',
          title: 'Start Tracking',
          description: 'Add your first transaction (income or expense) to get insights about your financial patterns.'
        }
      ];
    }

    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();

    // Calculate income and expenses for current month
    const currentMonthTransactions = transactions.filter(tx => {
      const txDate = new Date(tx.transactionDate || tx.createdAt);
      return txDate.getMonth() === currentMonth && txDate.getFullYear() === currentYear;
    });

    const currentMonthIncome = currentMonthTransactions
      .filter(tx => tx.type === 'INCOME')
      .reduce((sum, tx) => sum + (tx.amount || 0), 0);

    const currentMonthExpenses = currentMonthTransactions
      .filter(tx => tx.type === 'EXPENSE')
      .reduce((sum, tx) => sum + Math.abs(tx.amount || 0), 0);

    const prevMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const prevMonthTransactions = transactions.filter(tx => {
      const txDate = new Date(tx.transactionDate || tx.createdAt);
      return txDate.getMonth() === prevMonth && tx.type === 'EXPENSE';
    });

    const prevMonthExpenses = prevMonthTransactions
      .reduce((sum, tx) => sum + Math.abs(tx.amount || 0), 0);

    const spendingChange = prevMonthExpenses > 0
      ? ((currentMonthExpenses - prevMonthExpenses) / prevMonthExpenses) * 100
      : 0;

    // INCOME INSIGHT - Check if user has income
    if (currentMonthIncome > 0) {
      const savings = currentMonthIncome - currentMonthExpenses;
      const savingsRate = (savings / currentMonthIncome) * 100;

      if (savingsRate > 20) {
        insights.push({
          type: 'positive',
          title: 'Excellent Savings Rate',
          description: `You're saving ${savingsRate.toFixed(1)}% of your income this month! Keep up the great financial discipline.`
        });
      } else if (savingsRate > 0) {
        insights.push({
          type: 'info',
          title: 'You Are Saving',
          description: `You've saved ${formatCurrency(savings)} this month (${savingsRate.toFixed(1)}% of income). Every bit counts!`
        });
      } else if (savings < 0) {
        insights.push({
          type: 'warning',
          title: 'Spending Exceeds Income',
          description: `You're spending ${formatCurrency(Math.abs(savings))} more than your income. Review your expenses.`
        });
      }
    } else {
      insights.push({
        type: 'warning',
        title: 'No Income Recorded',
        description: 'Add your income transactions to track savings and get personalized financial insights.'
      });
    }

    // EXPENSE TREND INSIGHT
    if (spendingChange < -10) {
      insights.push({
        type: 'positive',
        title: 'Spending Decreased',
        description: `Your spending decreased by ${Math.abs(spendingChange).toFixed(1)}% compared to last month. Great job controlling expenses!`
      });
    } else if (spendingChange > 10) {
      insights.push({
        type: 'warning',
        title: 'Spending Alert',
        description: `Your spending increased by ${spendingChange.toFixed(1)}% this month. Review high-expense categories.`
      });
    }

    // GOAL achievement
    if (goals && goals.length > 0) {
      const completedGoals = goals.filter(g => g.status === 'COMPLETED').length;
      const activeGoals = goals.filter(g => g.status === 'ACTIVE').length;

      if (completedGoals > 0) {
        insights.push({
          type: 'positive',
          title: 'Goal Milestones Achieved',
          description: `Congratulations! You've completed ${completedGoals} goal(s). Keep ${activeGoals} remaining goal(s) in progress.`
        });
      }
    }

    // TOP SPENDING CATEGORY
    const categoryMap = {};
    transactions
      .filter(tx => tx.type === 'EXPENSE')
      .forEach(tx => {
        const category = tx.category?.name || tx.categoryName || 'Other';
        categoryMap[category] = (categoryMap[category] || 0) + Math.abs(tx.amount || 0);
      });

    const topCategory = Object.entries(categoryMap).sort(([, a], [, b]) => b - a)[0];
    if (topCategory) {
      const categoryPercentage = (topCategory[1] / currentMonthExpenses) * 100;
      insights.push({
        type: 'neutral',
        title: 'Top Spending Category',
        description: `${topCategory[0]} is your highest expense (${formatCurrency(topCategory[1])}, ${categoryPercentage.toFixed(1)}% of total spending).`
      });
    }

    return insights;
  };

  const spendingTrendData = transformSpendingTrendData();
  const categorySpendingData = transformCategorySpendingData();
  const goalProgressData = transformGoalProgressData();
  const dynamicInsights = generateInsights();

  return (
    <InsightsContainer>
      <PageHeader
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <Heading level={1}>Financial Insights</Heading>
        <Text color={props => props.theme.colors.gray[600]} size={props => props.theme.fontSizes.lg}>
          Analyze your spending patterns and financial trends
        </Text>
      </PageHeader>

      <ChartsGrid>
        <ChartCard
          as={motion.div}
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <ChartHeader>
            <ChartTitle level={3}>Spending Trends</ChartTitle>
            <Button variant="outline" size="sm">6 Months</Button>
          </ChartHeader>
          <ResponsiveContainer width="100%" height="85%">
            <AreaChart data={spendingTrendData}>
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
                dataKey="spending"
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
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <ChartHeader>
            <ChartTitle level={3}>Spending by Category</ChartTitle>
          </ChartHeader>
          <ResponsiveContainer width="100%" height="85%">
            <RechartsPieChart>
              <Pie
                data={categorySpendingData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={120}
                paddingAngle={5}
                dataKey="value"
              >
                {categorySpendingData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => formatCurrency(value)} />
              <Legend />
            </RechartsPieChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard
          as={motion.div}
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <ChartHeader>
            <ChartTitle level={3}>Goal Progress</ChartTitle>
          </ChartHeader>
          <ResponsiveContainer width="100%" height="85%">
            <BarChart data={goalProgressData} layout="horizontal">
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis type="number" domain={[0, 100]} />
              <YAxis dataKey="name" type="category" width={120} />
              <Tooltip formatter={(value) => `${value}%`} />
              <Bar dataKey="progress" fill="#3b82f6" radius={[0, 4, 4, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard
          as={motion.div}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
        >
          <ChartHeader>
            <ChartTitle level={3}>Monthly Savings</ChartTitle>
          </ChartHeader>
          <ResponsiveContainer width="100%" height="85%">
            <LineChart data={spendingTrendData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip formatter={(value) => formatCurrency(value)} />
              <Line
                type="monotone"
                dataKey="savings"
                stroke="#8b5cf6"
                strokeWidth={3}
                dot={{ fill: '#8b5cf6', strokeWidth: 2, r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </ChartCard>
      </ChartsGrid>

      <Grid
        columns="repeat(auto-fit, minmax(300px, 1fr))"
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.5 }}
      >
        {dynamicInsights.map((insight, index) => {
          let color = '#3b82f6';
          let bgColor = '#dbeafe';
          let iconColor = '#2563eb';
          let icon = Target;

          if (insight.type === 'positive') {
            color = '#10b981';
            bgColor = '#dcfce7';
            iconColor = '#16a34a';
            icon = TrendingUp;
          } else if (insight.type === 'warning') {
            color = '#ef4444';
            bgColor = '#fee2e2';
            iconColor = '#dc2626';
            icon = BarChart3;
          } else if (insight.type === 'neutral') {
            color = '#f59e0b';
            bgColor = '#fef3c7';
            iconColor = '#d97706';
            icon = PieChart;
          }

          const IconComponent = icon;

          return (
            <InsightCard key={index} color={color}>
              <InsightIcon color={bgColor} iconColor={iconColor}>
                <IconComponent size={24} />
              </InsightIcon>
              <InsightTitle>{insight.title}</InsightTitle>
              <InsightDescription>
                {insight.description}
              </InsightDescription>
            </InsightCard>
          );
        })}
      </Grid>
    </InsightsContainer>
  );
};

export default Insights;
