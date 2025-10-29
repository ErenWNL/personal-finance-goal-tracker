import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';
import { X, DollarSign, Tag } from 'lucide-react';
import toast from 'react-hot-toast';
import { Button, Input, Label, ErrorMessage, LoadingSpinner } from '../../styles/GlobalStyles';

const ModalOverlay = styled(motion.div)`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: ${props => props.theme.spacing[4]};
`;

const ModalContent = styled(motion.div)`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.xl};
  box-shadow: ${props => props.theme.shadows['2xl']};
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
`;

const ModalHeader = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: ${props => props.theme.spacing[6]};
  border-bottom: 1px solid ${props => props.theme.colors.gray[200]};
`;

const ModalTitle = styled.h2`
  font-size: ${props => props.theme.fontSizes.xl};
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.theme.colors.gray[900]};
  margin: 0;
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[2]};
`;

const CloseButton = styled.button`
  background: none;
  border: none;
  color: ${props => props.theme.colors.gray[500]};
  cursor: pointer;
  padding: ${props => props.theme.spacing[1]};
  border-radius: ${props => props.theme.borderRadius.md};
  transition: all ${props => props.theme.transitions.fast};

  &:hover {
    background: ${props => props.theme.colors.gray[100]};
    color: ${props => props.theme.colors.gray[700]};
  }
`;

const ModalBody = styled.div`
  padding: ${props => props.theme.spacing[6]};
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing[4]};
`;

const FormRow = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: ${props => props.theme.spacing[4]};

  @media (max-width: ${props => props.theme.breakpoints.sm}) {
    grid-template-columns: 1fr;
  }
`;

const FormGroup = styled.div``;

const TypeSelector = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: ${props => props.theme.spacing[3]};
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const TypeButton = styled.button`
  padding: ${props => props.theme.spacing[3]} ${props => props.theme.spacing[4]};
  border: 2px solid ${props => props.selected ? (props.isIncome ? props.theme.colors.success[500] : props.theme.colors.error[500]) : props.theme.colors.gray[300]};
  background: ${props => props.selected ? (props.isIncome ? props.theme.colors.success[50] : props.theme.colors.error[50]) : props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.lg};
  cursor: pointer;
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.selected ? (props.isIncome ? props.theme.colors.success[600] : props.theme.colors.error[600]) : props.theme.colors.gray[600]};
  transition: all ${props => props.theme.transitions.fast};

  &:hover {
    border-color: ${props => props.isIncome ? props.theme.colors.success[300] : props.theme.colors.error[300]};
  }
`;

const TextArea = styled.textarea`
  width: 100%;
  padding: ${props => props.theme.spacing[3]};
  font-size: ${props => props.theme.fontSizes.sm};
  border: 1px solid ${props => props.theme.colors.gray[300]};
  border-radius: ${props => props.theme.borderRadius.md};
  background: ${props => props.theme.colors.white};
  transition: all ${props => props.theme.transitions.fast};
  resize: vertical;
  min-height: 60px;
  font-family: inherit;

  &:focus {
    outline: none;
    border-color: ${props => props.theme.colors.primary[500]};
    box-shadow: 0 0 0 3px ${props => props.theme.colors.primary[100]};
  }

  &::placeholder {
    color: ${props => props.theme.colors.gray[400]};
  }

  &:disabled {
    background: ${props => props.theme.colors.gray[100]};
    cursor: not-allowed;
  }

  ${props => props.error && `
    border-color: ${props.theme.colors.error[500]};

    &:focus {
      border-color: ${props.theme.colors.error[500]};
      box-shadow: 0 0 0 3px ${props.theme.colors.error[100]};
    }
  `}
`;

const Select = styled.select`
  width: 100%;
  padding: ${props => props.theme.spacing[3]};
  font-size: ${props => props.theme.fontSizes.sm};
  border: 1px solid ${props => props.theme.colors.gray[300]};
  border-radius: ${props => props.theme.borderRadius.md};
  background: ${props => props.theme.colors.white};
  transition: all ${props => props.theme.transitions.fast};

  &:focus {
    outline: none;
    border-color: ${props => props.theme.colors.primary[500]};
    box-shadow: 0 0 0 3px ${props => props.theme.colors.primary[100]};
  }

  &:disabled {
    background: ${props => props.theme.colors.gray[100]};
    cursor: not-allowed;
  }

  ${props => props.error && `
    border-color: ${props.theme.colors.error[500]};

    &:focus {
      border-color: ${props.theme.colors.error[500]};
      box-shadow: 0 0 0 3px ${props.theme.colors.error[100]};
    }
  `}
`;

const ModalFooter = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: ${props => props.theme.spacing[3]};
  padding: ${props => props.theme.spacing[6]};
  border-top: 1px solid ${props => props.theme.colors.gray[200]};
`;

const TransactionModal = ({ isOpen, onClose, onSubmit, transaction, isLoading }) => {
  const [transactionType, setTransactionType] = useState('EXPENSE');
  const [formData, setFormData] = useState({
    description: '',
    amount: '',
    categoryId: 5, // Default to Food & Dining (first expense category)
    categoryName: '',
    transactionDate: new Date().toISOString().split('T')[0],
    notes: '',
  });
  const [validationErrors, setValidationErrors] = useState({});

  // Categories from backend - using actual category IDs
  // Income categories (IDs: 1-4)
  const incomeCategories = [
    { id: 1, name: 'Salary' },
    { id: 2, name: 'Business Income' },
    { id: 3, name: 'Investment Returns' },
    { id: 4, name: 'Other Income' },
  ];

  // Expense categories (IDs: 5-12)
  const expenseCategories = [
    { id: 5, name: 'Food & Dining' },
    { id: 6, name: 'Transportation' },
    { id: 7, name: 'Shopping' },
    { id: 8, name: 'Entertainment' },
    { id: 9, name: 'Bills & Utilities' },
    { id: 10, name: 'Healthcare' },
    { id: 11, name: 'Education' },
    { id: 12, name: 'Other Expenses' },
  ];

  const currentCategories = transactionType === 'INCOME' ? incomeCategories : expenseCategories;

  useEffect(() => {
    if (transaction) {
      setTransactionType(transaction.type || 'EXPENSE');
      setFormData({
        description: transaction.description || '',
        amount: transaction.amount || '',
        categoryId: transaction.category?.id || 5, // Default to Food & Dining
        categoryName: transaction.category?.name || '',
        transactionDate: transaction.transactionDate || new Date().toISOString().split('T')[0],
        notes: transaction.notes || '',
      });
    } else {
      setTransactionType('EXPENSE');
      setFormData({
        description: '',
        amount: '',
        categoryId: 5, // Default to Food & Dining for expenses
        categoryName: '',
        transactionDate: new Date().toISOString().split('T')[0],
        notes: '',
      });
    }
    setValidationErrors({});
  }, [transaction, isOpen]);

  // Update category when transaction type changes
  useEffect(() => {
    const defaultCategoryId = transactionType === 'INCOME' ? 1 : 5; // 1=Salary, 5=Food & Dining
    const defaultCategory = (transactionType === 'INCOME' ? incomeCategories : expenseCategories)[0];

    setFormData(prev => ({
      ...prev,
      categoryId: defaultCategoryId,
      categoryName: defaultCategory?.name || '',
    }));
  }, [transactionType]);

  const validateForm = () => {
    const errors = {};

    if (!formData.description.trim()) {
      errors.description = 'Description is required';
    }

    if (!formData.amount || formData.amount <= 0) {
      errors.amount = 'Amount must be greater than 0';
    }

    if (!formData.categoryId) {
      errors.categoryId = 'Category is required';
    }

    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));

    if (validationErrors[name]) {
      setValidationErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleCategoryChange = (e) => {
    const categoryId = e.target.value;
    const category = currentCategories.find(cat => cat.id === categoryId);
    setFormData(prev => ({
      ...prev,
      categoryId,
      categoryName: category?.name || ''
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    const transactionData = {
      description: formData.description,
      amount: parseFloat(formData.amount),
      type: transactionType,
      categoryId: parseInt(formData.categoryId),
      categoryName: formData.categoryName,
      transactionDate: formData.transactionDate,
      notes: formData.notes,
    };

    await onSubmit(transactionData);
  };

  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <ModalOverlay
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={handleOverlayClick}
      >
        <ModalContent
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          transition={{ duration: 0.2 }}
        >
          <ModalHeader>
            <ModalTitle>
              <DollarSign size={24} />
              {transaction ? 'Edit Transaction' : 'Add Transaction'}
            </ModalTitle>
            <CloseButton onClick={onClose} disabled={isLoading}>
              <X size={20} />
            </CloseButton>
          </ModalHeader>

          <ModalBody>
            <Form onSubmit={handleSubmit}>
              {/* Transaction Type Selector */}
              <FormGroup>
                <Label>Transaction Type *</Label>
                <TypeSelector>
                  <TypeButton
                    type="button"
                    selected={transactionType === 'INCOME'}
                    isIncome={true}
                    onClick={() => setTransactionType('INCOME')}
                    disabled={isLoading}
                  >
                    + Income
                  </TypeButton>
                  <TypeButton
                    type="button"
                    selected={transactionType === 'EXPENSE'}
                    isIncome={false}
                    onClick={() => setTransactionType('EXPENSE')}
                    disabled={isLoading}
                  >
                    - Expense
                  </TypeButton>
                </TypeSelector>
              </FormGroup>

              {/* Description */}
              <FormGroup>
                <Label htmlFor="description">Description *</Label>
                <Input
                  id="description"
                  name="description"
                  type="text"
                  placeholder="e.g., Salary, Grocery Shopping"
                  value={formData.description}
                  onChange={handleChange}
                  error={validationErrors.description}
                  disabled={isLoading}
                />
                {validationErrors.description && <ErrorMessage>{validationErrors.description}</ErrorMessage>}
              </FormGroup>

              {/* Amount and Category Row */}
              <FormRow>
                <FormGroup>
                  <Label htmlFor="amount">Amount *</Label>
                  <Input
                    id="amount"
                    name="amount"
                    type="number"
                    step="0.01"
                    min="0"
                    placeholder="0.00"
                    value={formData.amount}
                    onChange={handleChange}
                    error={validationErrors.amount}
                    disabled={isLoading}
                  />
                  {validationErrors.amount && <ErrorMessage>{validationErrors.amount}</ErrorMessage>}
                </FormGroup>

                <FormGroup>
                  <Label htmlFor="categoryId">Category *</Label>
                  <Select
                    id="categoryId"
                    name="categoryId"
                    value={formData.categoryId}
                    onChange={handleCategoryChange}
                    error={validationErrors.categoryId}
                    disabled={isLoading}
                  >
                    {currentCategories.map(cat => (
                      <option key={cat.id} value={cat.id}>
                        {cat.name}
                      </option>
                    ))}
                  </Select>
                  {validationErrors.categoryId && <ErrorMessage>{validationErrors.categoryId}</ErrorMessage>}
                </FormGroup>
              </FormRow>

              {/* Date */}
              <FormGroup>
                <Label htmlFor="transactionDate">Date</Label>
                <Input
                  id="transactionDate"
                  name="transactionDate"
                  type="date"
                  value={formData.transactionDate}
                  onChange={handleChange}
                  disabled={isLoading}
                />
              </FormGroup>

              {/* Notes */}
              <FormGroup>
                <Label htmlFor="notes">Notes</Label>
                <TextArea
                  id="notes"
                  name="notes"
                  placeholder="Add any additional details (optional)"
                  value={formData.notes}
                  onChange={handleChange}
                  disabled={isLoading}
                />
              </FormGroup>
            </Form>
          </ModalBody>

          <ModalFooter>
            <Button
              variant="secondary"
              onClick={onClose}
              disabled={isLoading}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={handleSubmit}
              disabled={isLoading}
            >
              {isLoading ? (
                <LoadingSpinner size="16px" />
              ) : (
                transaction ? 'Update Transaction' : 'Add Transaction'
              )}
            </Button>
          </ModalFooter>
        </ModalContent>
      </ModalOverlay>
    </AnimatePresence>
  );
};

export default TransactionModal;
