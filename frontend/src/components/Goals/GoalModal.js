import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Target, DollarSign, Calendar, Flag } from 'lucide-react';
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
  z-index: ${props => props.theme.zIndex.modal};
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

const TextArea = styled.textarea`
  width: 100%;
  padding: ${props => props.theme.spacing[3]};
  font-size: ${props => props.theme.fontSizes.sm};
  border: 1px solid ${props => props.theme.colors.gray[300]};
  border-radius: ${props => props.theme.borderRadius.md};
  background: ${props => props.theme.colors.white};
  transition: all ${props => props.theme.transitions.fast};
  resize: vertical;
  min-height: 80px;
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

const GoalModal = ({ isOpen, onClose, onSubmit, goal, isLoading }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    targetAmount: '',
    currentAmount: '',
    categoryId: '1', // Default category
    priorityLevel: 'MEDIUM',
    targetDate: '',
    startDate: '',
  });
  const [validationErrors, setValidationErrors] = useState({});

  useEffect(() => {
    if (goal) {
      setFormData({
        title: goal.title || '',
        description: goal.description || '',
        targetAmount: goal.targetAmount || '',
        currentAmount: goal.currentAmount || '',
        categoryId: goal.category?.id || '1',
        priorityLevel: goal.priorityLevel || 'MEDIUM',
        targetDate: goal.targetDate || '',
        startDate: goal.startDate || '',
      });
    } else {
      setFormData({
        title: '',
        description: '',
        targetAmount: '',
        currentAmount: '',
        categoryId: '1',
        priorityLevel: 'MEDIUM',
        targetDate: '',
        startDate: new Date().toISOString().split('T')[0],
      });
    }
    setValidationErrors({});
  }, [goal, isOpen]);

  const validateForm = () => {
    const errors = {};

    if (!formData.title.trim()) {
      errors.title = 'Goal title is required';
    }

    if (!formData.targetAmount || formData.targetAmount <= 0) {
      errors.targetAmount = 'Target amount must be greater than 0';
    }

    if (formData.currentAmount && formData.currentAmount < 0) {
      errors.currentAmount = 'Current amount cannot be negative';
    }

    if (formData.targetDate && formData.startDate && new Date(formData.targetDate) <= new Date(formData.startDate)) {
      errors.targetDate = 'Target date must be after start date';
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
    
    // Clear validation error when user starts typing
    if (validationErrors[name]) {
      setValidationErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    const goalData = {
      ...formData,
      targetAmount: parseFloat(formData.targetAmount),
      currentAmount: parseFloat(formData.currentAmount) || 0,
      categoryId: parseInt(formData.categoryId),
    };

    await onSubmit(goalData);
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
              <Target size={24} />
              {goal ? 'Edit Goal' : 'Create New Goal'}
            </ModalTitle>
            <CloseButton onClick={onClose} disabled={isLoading}>
              <X size={20} />
            </CloseButton>
          </ModalHeader>

          <ModalBody>
            <Form onSubmit={handleSubmit}>
              <FormGroup>
                <Label htmlFor="title">Goal Title *</Label>
                <Input
                  id="title"
                  name="title"
                  type="text"
                  placeholder="e.g., Emergency Fund, Vacation, New Car"
                  value={formData.title}
                  onChange={handleChange}
                  error={validationErrors.title}
                  disabled={isLoading}
                />
                {validationErrors.title && <ErrorMessage>{validationErrors.title}</ErrorMessage>}
              </FormGroup>

              <FormGroup>
                <Label htmlFor="description">Description</Label>
                <TextArea
                  id="description"
                  name="description"
                  placeholder="Describe your goal and why it's important to you..."
                  value={formData.description}
                  onChange={handleChange}
                  error={validationErrors.description}
                  disabled={isLoading}
                />
                {validationErrors.description && <ErrorMessage>{validationErrors.description}</ErrorMessage>}
              </FormGroup>

              <FormRow>
                <FormGroup>
                  <Label htmlFor="targetAmount">Target Amount *</Label>
                  <Input
                    id="targetAmount"
                    name="targetAmount"
                    type="number"
                    step="0.01"
                    min="0"
                    placeholder="0.00"
                    value={formData.targetAmount}
                    onChange={handleChange}
                    error={validationErrors.targetAmount}
                    disabled={isLoading}
                  />
                  {validationErrors.targetAmount && <ErrorMessage>{validationErrors.targetAmount}</ErrorMessage>}
                </FormGroup>

                <FormGroup>
                  <Label htmlFor="currentAmount">Current Amount</Label>
                  <Input
                    id="currentAmount"
                    name="currentAmount"
                    type="number"
                    step="0.01"
                    min="0"
                    placeholder="0.00"
                    value={formData.currentAmount}
                    onChange={handleChange}
                    error={validationErrors.currentAmount}
                    disabled={isLoading}
                  />
                  {validationErrors.currentAmount && <ErrorMessage>{validationErrors.currentAmount}</ErrorMessage>}
                </FormGroup>
              </FormRow>

              <FormRow>
                <FormGroup>
                  <Label htmlFor="categoryId">Category</Label>
                  <Select
                    id="categoryId"
                    name="categoryId"
                    value={formData.categoryId}
                    onChange={handleChange}
                    error={validationErrors.categoryId}
                    disabled={isLoading}
                  >
                    <option value="1">Emergency Fund</option>
                    <option value="2">Vacation</option>
                    <option value="3">Home</option>
                    <option value="4">Education</option>
                    <option value="5">Investment</option>
                    <option value="6">Other</option>
                  </Select>
                  {validationErrors.categoryId && <ErrorMessage>{validationErrors.categoryId}</ErrorMessage>}
                </FormGroup>

                <FormGroup>
                  <Label htmlFor="priorityLevel">Priority</Label>
                  <Select
                    id="priorityLevel"
                    name="priorityLevel"
                    value={formData.priorityLevel}
                    onChange={handleChange}
                    error={validationErrors.priorityLevel}
                    disabled={isLoading}
                  >
                    <option value="HIGH">High</option>
                    <option value="MEDIUM">Medium</option>
                    <option value="LOW">Low</option>
                  </Select>
                  {validationErrors.priorityLevel && <ErrorMessage>{validationErrors.priorityLevel}</ErrorMessage>}
                </FormGroup>
              </FormRow>

              <FormRow>
                <FormGroup>
                  <Label htmlFor="startDate">Start Date</Label>
                  <Input
                    id="startDate"
                    name="startDate"
                    type="date"
                    value={formData.startDate}
                    onChange={handleChange}
                    error={validationErrors.startDate}
                    disabled={isLoading}
                  />
                  {validationErrors.startDate && <ErrorMessage>{validationErrors.startDate}</ErrorMessage>}
                </FormGroup>

                <FormGroup>
                  <Label htmlFor="targetDate">Target Date</Label>
                  <Input
                    id="targetDate"
                    name="targetDate"
                    type="date"
                    value={formData.targetDate}
                    onChange={handleChange}
                    error={validationErrors.targetDate}
                    disabled={isLoading}
                  />
                  {validationErrors.targetDate && <ErrorMessage>{validationErrors.targetDate}</ErrorMessage>}
                </FormGroup>
              </FormRow>
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
                goal ? 'Update Goal' : 'Create Goal'
              )}
            </Button>
          </ModalFooter>
        </ModalContent>
      </ModalOverlay>
    </AnimatePresence>
  );
};

export default GoalModal;
