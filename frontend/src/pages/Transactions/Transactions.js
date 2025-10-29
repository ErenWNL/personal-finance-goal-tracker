import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { Plus, CreditCard, TrendingUp, TrendingDown, Filter, Search, Edit3, Trash2 } from 'lucide-react';
import toast from 'react-hot-toast';
import { fetchUserTransactions, fetchTransactionSummary, createTransaction, updateTransaction, deleteTransaction } from '../../store/slices/transactionsSlice';
import { Container, Card, Button, Flex, Grid, Heading, Text, Input } from '../../styles/GlobalStyles';
import TransactionModal from '../../components/Transactions/TransactionModal';
import { financeAPI } from '../../services/api';

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

const ActionButtons = styled(Flex)`
  gap: ${props => props.theme.spacing[2]};
`;

const ActionButton = styled(Button)`
  padding: ${props => props.theme.spacing[2]};
  min-height: auto;
  width: 36px;
  height: 36px;
`;

const EmptyStateContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: ${props => props.theme.spacing[4]};
  padding: ${props => props.theme.spacing[8]};
  text-align: center;
`;

const Transactions = () => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);
  const { transactions, summary, isLoading } = useSelector((state) => state.transactions);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedTransaction, setSelectedTransaction] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  const [filterType, setFilterType] = useState('ALL'); // ALL, INCOME, EXPENSE

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

  const handleOpenModal = () => {
    setSelectedTransaction(null);
    setIsModalOpen(true);
  };

  const handleEditTransaction = (transaction) => {
    setSelectedTransaction(transaction);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedTransaction(null);
  };

  const handleDeleteTransaction = async (transactionId) => {
    if (window.confirm('Are you sure you want to delete this transaction?')) {
      setIsSaving(true);
      try {
        const response = await financeAPI.deleteTransaction(transactionId);
        if (response.data.success) {
          toast.success('Transaction deleted successfully');
          if (user?.id) {
            dispatch(fetchUserTransactions(user.id));
            dispatch(fetchTransactionSummary(user.id));
          }
        } else {
          toast.error(response.data.message || 'Failed to delete transaction');
        }
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to delete transaction');
      } finally {
        setIsSaving(false);
      }
    }
  };

  const handleSubmitTransaction = async (transactionData) => {
    setIsSaving(true);
    try {
      if (selectedTransaction) {
        // Update existing transaction
        const response = await financeAPI.updateTransaction(selectedTransaction.id, transactionData);
        if (response.data.success || response.status === 200 || response.status === 201) {
          toast.success('Transaction updated successfully');
          handleCloseModal();
          if (user?.id) {
            dispatch(fetchUserTransactions(user.id));
            dispatch(fetchTransactionSummary(user.id));
          }
        } else {
          toast.error(response.data.message || 'Failed to update transaction');
        }
      } else {
        // Create new transaction
        transactionData.userId = user.id;
        const response = await financeAPI.createTransaction(transactionData);
        if (response.data.success || response.status === 200 || response.status === 201) {
          toast.success('Transaction added successfully');
          handleCloseModal();
          if (user?.id) {
            dispatch(fetchUserTransactions(user.id));
            dispatch(fetchTransactionSummary(user.id));
          }
        } else {
          toast.error(response.data.message || 'Failed to add transaction');
        }
      }
    } catch (error) {
      console.error('Transaction error:', error.response?.data);
      toast.error(error.response?.data?.message || error.message || 'Failed to save transaction');
    } finally {
      setIsSaving(false);
    }
  };

  // Filter transactions based on selected type
  const filteredTransactions = transactions.filter(tx => {
    if (filterType === 'ALL') return true;
    return tx.type === filterType;
  });

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
        <Button variant="primary" onClick={handleOpenModal}>
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

      {/* Filter Buttons */}
      <Flex gap="8px" style={{ marginBottom: '24px' }}>
        <Button
          variant={filterType === 'ALL' ? 'primary' : 'outline'}
          size="sm"
          onClick={() => setFilterType('ALL')}
        >
          All
        </Button>
        <Button
          variant={filterType === 'INCOME' ? 'primary' : 'outline'}
          size="sm"
          onClick={() => setFilterType('INCOME')}
        >
          Income
        </Button>
        <Button
          variant={filterType === 'EXPENSE' ? 'primary' : 'outline'}
          size="sm"
          onClick={() => setFilterType('EXPENSE')}
        >
          Expenses
        </Button>
      </Flex>

      <TransactionsList
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
      >
        <div style={{ padding: '24px 24px 16px' }}>
          <Flex justify="space-between" align="center">
            <Heading level={3}>
              {filterType === 'ALL' ? 'All Transactions' : filterType === 'INCOME' ? 'Income' : 'Expenses'}
            </Heading>
            <Flex gap="12px">
              <Button variant="outline" size="sm" disabled>
                <Search size={16} />
                Search
              </Button>
            </Flex>
          </Flex>
        </div>

        {filteredTransactions && filteredTransactions.length > 0 ? (
          filteredTransactions.map((transaction) => (
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
                    {transaction.category?.name || transaction.categoryName || 'Uncategorized'} • {formatDate(transaction.transactionDate || transaction.createdAt)}
                  </TransactionMeta>
                </TransactionDetails>
              </TransactionInfo>
              <Flex align="center" gap="16px">
                <TransactionAmount positive={transaction.type === 'INCOME'}>
                  {transaction.type === 'INCOME' ? '+' : '-'}{formatCurrency(Math.abs(transaction.amount))}
                </TransactionAmount>
                <ActionButtons>
                  <ActionButton
                    variant="outline"
                    size="sm"
                    onClick={() => handleEditTransaction(transaction)}
                    title="Edit Transaction"
                    disabled={isSaving}
                  >
                    <Edit3 size={16} />
                  </ActionButton>
                  <ActionButton
                    variant="danger"
                    size="sm"
                    onClick={() => handleDeleteTransaction(transaction.id)}
                    title="Delete Transaction"
                    disabled={isSaving}
                  >
                    <Trash2 size={16} />
                  </ActionButton>
                </ActionButtons>
              </Flex>
            </TransactionItem>
          ))
        ) : (
          <TransactionItem style={{ padding: '40px', textAlign: 'center', borderBottom: 'none' }}>
            <EmptyStateContainer style={{ width: '100%' }}>
              <CreditCard size={48} style={{ color: '#d1d5db' }} />
              <p style={{ color: '#6b7280', marginBottom: '16px' }}>
                {transactions.length === 0 ? 'No transactions yet' : 'No transactions matching this filter'}
              </p>
              <Button variant="primary" onClick={handleOpenModal}>
                <Plus size={20} />
                Add Transaction
              </Button>
            </EmptyStateContainer>
          </TransactionItem>
        )}
      </TransactionsList>

      {/* Transaction Modal */}
      <TransactionModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        onSubmit={handleSubmitTransaction}
        transaction={selectedTransaction}
        isLoading={isSaving}
      />
    </TransactionsContainer>
  );
};

export default Transactions;
