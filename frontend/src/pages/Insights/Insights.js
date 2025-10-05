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

// Sample data for charts
const spendingTrendData = [
  { month: 'Jan', spending: 2400, income: 4000, savings: 1600 },
  { month: 'Feb', spending: 1398, income: 3000, savings: 1602 },
  { month: 'Mar', spending: 2800, income: 2000, savings: -800 },
  { month: 'Apr', spending: 3908, income: 2780, savings: -1128 },
  { month: 'May', spending: 2800, income: 1890, savings: -910 },
  { month: 'Jun', spending: 3800, income: 2390, savings: -1410 },
];

const categorySpendingData = [
  { name: 'Food & Dining', value: 400, color: '#8884d8' },
  { name: 'Transportation', value: 300, color: '#82ca9d' },
  { name: 'Entertainment', value: 200, color: '#ffc658' },
  { name: 'Shopping', value: 150, color: '#ff7300' },
  { name: 'Bills & Utilities', value: 100, color: '#00ff00' },
  { name: 'Healthcare', value: 80, color: '#ff0000' },
];

const goalProgressData = [
  { name: 'Emergency Fund', progress: 75, target: 10000, current: 7500 },
  { name: 'Vacation', progress: 45, target: 5000, current: 2250 },
  { name: 'New Car', progress: 30, target: 25000, current: 7500 },
  { name: 'Home Down Payment', progress: 60, target: 50000, current: 30000 },
];

const Insights = () => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);
  const { overview, analytics, isLoading } = useSelector((state) => state.insights);

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
        <InsightCard color="#10b981">
          <InsightIcon color="#dcfce7" iconColor="#16a34a">
            <TrendingUp size={24} />
          </InsightIcon>
          <InsightTitle>Spending Decreased</InsightTitle>
          <InsightDescription>
            Your spending decreased by 15% compared to last month. Great job on controlling your expenses!
          </InsightDescription>
        </InsightCard>

        <InsightCard color="#3b82f6">
          <InsightIcon color="#dbeafe" iconColor="#2563eb">
            <Target size={24} />
          </InsightIcon>
          <InsightTitle>Goal Achievement</InsightTitle>
          <InsightDescription>
            You're on track to achieve 3 out of 4 goals by their target dates. Consider increasing contributions to your vacation fund.
          </InsightDescription>
        </InsightCard>

        <InsightCard color="#f59e0b">
          <InsightIcon color="#fef3c7" iconColor="#d97706">
            <PieChart size={24} />
          </InsightIcon>
          <InsightTitle>Category Alert</InsightTitle>
          <InsightDescription>
            Your dining expenses increased by 25% this month. Consider meal planning to reduce costs.
          </InsightDescription>
        </InsightCard>
      </Grid>
    </InsightsContainer>
  );
};

export default Insights;
