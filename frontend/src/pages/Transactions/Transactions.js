import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { Plus, CreditCard, TrendingUp, TrendingDown, Filter, Search } from 'lucide-react';
import { fetchUserTransactions, fetchTransactionSummary } from '../../store/slices/transactionsSlice';
import { Container, Card, Button, Flex, Grid, Heading, Text, Input } from '../../styles/GlobalStyles';

const TransactionsContainer = styled(Container)`
  max-width: 1400px;
`;

const PageHeader = styled(motion.div)`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing[8]};
  flex-wrap: wrap;
  gap: ${props => props.theme.spacing[4]};
`;

const StatsGrid = styled(Grid)`
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const StatCard = styled(Card)`
  text-align: center;
  padding: ${props => props.theme.spacing[6]};
  border-left: 4px solid ${props => props.color || props.theme.colors.primary[500]};
`;

const StatValue = styled.div`
  font-size: ${props => props.theme.fontSizes['2xl']};
  font-weight: ${props => props.theme.fontWeights.bold};
  color: ${props => props.theme.colors.gray[900]};
  margin-bottom: ${props => props.theme.spacing[1]};
`;

const StatLabel = styled.div`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.medium};
`;

const TransactionsList = styled(Card)`
  padding: 0;
  overflow: hidden;
`;

const TransactionItem = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: ${props => props.theme.spacing[4]} ${props => props.theme.spacing[6]};
  border-bottom: 1px solid ${props => props.theme.colors.gray[100]};

  &:last-child {
    border-bottom: none;
  }
`;

const TransactionInfo = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[3]};
`;

const TransactionIcon = styled.div`
  width: 40px;
  height: 40px;
  border-radius: ${props => props.theme.borderRadius.full};
  background: ${props => props.color || props.theme.colors.gray[100]};
  color: ${props => props.iconColor || props.theme.colors.gray[600]};
  display: flex;
  align-items: center;
  justify-content: center;
`;

const TransactionDetails = styled.div``;

const TransactionTitle = styled.div`
  font-weight: ${props => props.theme.fontWeights.medium};
  color: ${props => props.theme.colors.gray[900]};
  margin-bottom: ${props => props.theme.spacing[1]};
`;

const TransactionMeta = styled.div`
  font-size: ${props => props.theme.fontSizes.sm};
  color: ${props => props.theme.colors.gray[500]};
`;

const TransactionAmount = styled.div`
  font-weight: ${props => props.theme.fontWeights.semibold};
  font-size: ${props => props.theme.fontSizes.lg};
  color: ${props => props.positive ? props.theme.colors.success[600] : props.theme.colors.error[600]};
`;

const Transactions = () => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);
  const { transactions, summary, isLoading } = useSelector((state) => state.transactions);

  const [sampleTransactions] = useState([
    {
      id: 1,
      description: 'Salary Deposit',
      amount: 3200,
      type: 'INCOME',
      date: '2024-01-15',
      category: 'Salary'
    },
    {
      id: 2,
      description: 'Grocery Shopping',
      amount: -125.50,
      type: 'EXPENSE',
      date: '2024-01-14',
      category: 'Food'
    },
    {
      id: 3,
      description: 'Gas Station',
      amount: -45.00,
      type: 'EXPENSE',
      date: '2024-01-13',
      category: 'Transport'
    },
    {
      id: 4,
      description: 'Freelance Payment',
      amount: 800,
      type: 'INCOME',
      date: '2024-01-12',
      category: 'Freelance'
    },
  ]);

  useEffect(() => {
    if (user?.id) {
      dispatch(fetchUserTransactions(user.id));
      dispatch(fetchTransactionSummary(user.id));
    }
  }, [dispatch, user]);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(Math.abs(amount) || 0);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  };

  return (
    <TransactionsContainer>
      <PageHeader
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div>
          <Heading level={1}>Transactions</Heading>
          <Text color={props => props.theme.colors.gray[600]} size={props => props.theme.fontSizes.lg}>
            Track your income and expenses
          </Text>
        </div>
        <Button variant="primary">
          <Plus size={20} />
          Add Transaction
        </Button>
      </PageHeader>

      <StatsGrid
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        <StatCard color="#10b981">
          <StatValue>{formatCurrency(summary.totalIncome)}</StatValue>
          <StatLabel>Total Income</StatLabel>
        </StatCard>
        <StatCard color="#ef4444">
          <StatValue>{formatCurrency(summary.totalExpense)}</StatValue>
          <StatLabel>Total Expenses</StatLabel>
        </StatCard>
        <StatCard color="#3b82f6">
          <StatValue>{formatCurrency(summary.balance)}</StatValue>
          <StatLabel>Net Balance</StatLabel>
        </StatCard>
      </StatsGrid>

      <TransactionsList
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
      >
        <div style={{ padding: '24px 24px 16px' }}>
          <Flex justify="space-between" align="center">
            <Heading level={3}>Recent Transactions</Heading>
            <Flex gap="12px">
              <Button variant="outline" size="sm">
                <Filter size={16} />
                Filter
              </Button>
              <Button variant="outline" size="sm">
                <Search size={16} />
                Search
              </Button>
            </Flex>
          </Flex>
        </div>
        
        {sampleTransactions.map((transaction) => (
          <TransactionItem key={transaction.id}>
            <TransactionInfo>
              <TransactionIcon
                color={transaction.type === 'INCOME' ? '#dcfce7' : '#fee2e2'}
                iconColor={transaction.type === 'INCOME' ? '#16a34a' : '#dc2626'}
              >
                {transaction.type === 'INCOME' ? <TrendingUp size={20} /> : <TrendingDown size={20} />}
              </TransactionIcon>
              <TransactionDetails>
                <TransactionTitle>{transaction.description}</TransactionTitle>
                <TransactionMeta>
                  {transaction.category} • {formatDate(transaction.date)}
                </TransactionMeta>
              </TransactionDetails>
            </TransactionInfo>
            <TransactionAmount positive={transaction.type === 'INCOME'}>
              {transaction.type === 'INCOME' ? '+' : '-'}{formatCurrency(transaction.amount)}
            </TransactionAmount>
          </TransactionItem>
        ))}
      </TransactionsList>
    </TransactionsContainer>
  );
};

export default Transactions;
