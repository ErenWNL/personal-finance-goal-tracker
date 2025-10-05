import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import styled from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Plus, 
  Target, 
  Calendar, 
  DollarSign, 
  TrendingUp, 
  Edit3, 
  Trash2, 
  CheckCircle,
  Clock,
  AlertCircle
} from 'lucide-react';
import toast from 'react-hot-toast';
import { fetchUserGoals, createGoal, updateGoal, deleteGoal } from '../../store/slices/goalsSlice';
import { Container, Card, Button, Flex, Grid, Heading, Text, Input, Label } from '../../styles/GlobalStyles';
import GoalModal from '../../components/Goals/GoalModal';
import GoalCard from '../../components/Goals/GoalCard';

const GoalsContainer = styled(Container)`
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

const HeaderContent = styled.div``;

const PageTitle = styled(Heading)`
  margin-bottom: ${props => props.theme.spacing[2]};
`;

const PageSubtitle = styled(Text)`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.lg};
`;

const StatsOverview = styled(motion.div)`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: ${props => props.theme.spacing[4]};
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

const FiltersSection = styled(motion.div)`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.lg};
  padding: ${props => props.theme.spacing[4]};
  margin-bottom: ${props => props.theme.spacing[6]};
  box-shadow: ${props => props.theme.shadows.sm};
`;

const FilterGrid = styled(Grid)`
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  align-items: end;
`;

const FilterGroup = styled.div``;

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
`;

const GoalsGrid = styled(motion.div)`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: ${props => props.theme.spacing[6]};
`;

const EmptyState = styled(motion.div)`
  text-align: center;
  padding: ${props => props.theme.spacing[12]} ${props => props.theme.spacing[6]};
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.xl};
  box-shadow: ${props => props.theme.shadows.sm};
`;

const EmptyIcon = styled.div`
  width: 80px;
  height: 80px;
  background: ${props => props.theme.colors.gray[100]};
  border-radius: ${props => props.theme.borderRadius.full};
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto ${props => props.theme.spacing[4]};
  color: ${props => props.theme.colors.gray[400]};
`;

const EmptyTitle = styled(Heading)`
  level: 3;
  color: ${props => props.theme.colors.gray[700]};
  margin-bottom: ${props => props.theme.spacing[2]};
`;

const EmptyDescription = styled(Text)`
  color: ${props => props.theme.colors.gray[500]};
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const Goals = () => {
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);
  const { goals, isLoading, totalGoals, completedGoals } = useSelector((state) => state.goals);
  
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedGoal, setSelectedGoal] = useState(null);
  const [filters, setFilters] = useState({
    status: 'all',
    category: 'all',
    priority: 'all',
  });

  useEffect(() => {
    if (user?.id) {
      dispatch(fetchUserGoals(user.id));
    }
  }, [dispatch, user]);

  const handleCreateGoal = () => {
    setSelectedGoal(null);
    setIsModalOpen(true);
  };

  const handleEditGoal = (goal) => {
    setSelectedGoal(goal);
    setIsModalOpen(true);
  };

  const handleDeleteGoal = async (goalId) => {
    if (window.confirm('Are you sure you want to delete this goal?')) {
      try {
        const result = await dispatch(deleteGoal(goalId));
        if (deleteGoal.fulfilled.match(result)) {
          toast.success('Goal deleted successfully');
        }
      } catch (error) {
        toast.error('Failed to delete goal');
      }
    }
  };

  const handleModalClose = () => {
    setIsModalOpen(false);
    setSelectedGoal(null);
  };

  const handleModalSubmit = async (goalData) => {
    try {
      let result;
      if (selectedGoal) {
        result = await dispatch(updateGoal({ id: selectedGoal.id, goalData }));
        if (updateGoal.fulfilled.match(result)) {
          toast.success('Goal updated successfully');
        }
      } else {
        result = await dispatch(createGoal({ ...goalData, userId: user.id }));
        if (createGoal.fulfilled.match(result)) {
          toast.success('Goal created successfully');
        }
      }
      handleModalClose();
    } catch (error) {
      toast.error(selectedGoal ? 'Failed to update goal' : 'Failed to create goal');
    }
  };

  const handleFilterChange = (filterType, value) => {
    setFilters(prev => ({
      ...prev,
      [filterType]: value
    }));
  };

  const filteredGoals = goals.filter(goal => {
    if (filters.status !== 'all' && goal.status !== filters.status.toUpperCase()) {
      return false;
    }
    if (filters.category !== 'all' && goal.category?.name !== filters.category) {
      return false;
    }
    if (filters.priority !== 'all' && goal.priorityLevel !== filters.priority.toUpperCase()) {
      return false;
    }
    return true;
  });

  const activeGoals = goals.filter(goal => goal.status === 'ACTIVE').length;
  const totalTargetAmount = goals.reduce((sum, goal) => sum + (goal.targetAmount || 0), 0);
  const totalCurrentAmount = goals.reduce((sum, goal) => sum + (goal.currentAmount || 0), 0);
  const overallProgress = totalTargetAmount > 0 ? (totalCurrentAmount / totalTargetAmount) * 100 : 0;

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount || 0);
  };

  return (
    <GoalsContainer>
      <PageHeader
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <HeaderContent>
          <PageTitle level={1}>Financial Goals</PageTitle>
          <PageSubtitle>
            Track your progress and achieve your financial dreams
          </PageSubtitle>
        </HeaderContent>
        <Button
          variant="primary"
          onClick={handleCreateGoal}
        >
          <Plus size={20} />
          Create New Goal
        </Button>
      </PageHeader>

      <StatsOverview
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        <StatCard color="#3b82f6">
          <StatValue>{totalGoals}</StatValue>
          <StatLabel>Total Goals</StatLabel>
        </StatCard>
        <StatCard color="#10b981">
          <StatValue>{activeGoals}</StatValue>
          <StatLabel>Active Goals</StatLabel>
        </StatCard>
        <StatCard color="#8b5cf6">
          <StatValue>{completedGoals}</StatValue>
          <StatLabel>Completed</StatLabel>
        </StatCard>
        <StatCard color="#f59e0b">
          <StatValue>{Math.round(overallProgress)}%</StatValue>
          <StatLabel>Overall Progress</StatLabel>
        </StatCard>
      </StatsOverview>

      <FiltersSection
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
      >
        <FilterGrid>
          <FilterGroup>
            <Label>Status</Label>
            <Select
              value={filters.status}
              onChange={(e) => handleFilterChange('status', e.target.value)}
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="completed">Completed</option>
              <option value="paused">Paused</option>
            </Select>
          </FilterGroup>
          <FilterGroup>
            <Label>Category</Label>
            <Select
              value={filters.category}
              onChange={(e) => handleFilterChange('category', e.target.value)}
            >
              <option value="all">All Categories</option>
              <option value="Emergency Fund">Emergency Fund</option>
              <option value="Vacation">Vacation</option>
              <option value="Home">Home</option>
              <option value="Education">Education</option>
              <option value="Investment">Investment</option>
            </Select>
          </FilterGroup>
          <FilterGroup>
            <Label>Priority</Label>
            <Select
              value={filters.priority}
              onChange={(e) => handleFilterChange('priority', e.target.value)}
            >
              <option value="all">All Priorities</option>
              <option value="high">High</option>
              <option value="medium">Medium</option>
              <option value="low">Low</option>
            </Select>
          </FilterGroup>
          <FilterGroup>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setFilters({ status: 'all', category: 'all', priority: 'all' })}
            >
              Clear Filters
            </Button>
          </FilterGroup>
        </FilterGrid>
      </FiltersSection>

      {filteredGoals.length > 0 ? (
        <GoalsGrid
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <AnimatePresence>
            {filteredGoals.map((goal, index) => (
              <GoalCard
                key={goal.id}
                goal={goal}
                onEdit={handleEditGoal}
                onDelete={handleDeleteGoal}
                index={index}
              />
            ))}
          </AnimatePresence>
        </GoalsGrid>
      ) : (
        <EmptyState
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <EmptyIcon>
            <Target size={40} />
          </EmptyIcon>
          <EmptyTitle>No goals found</EmptyTitle>
          <EmptyDescription>
            {filters.status !== 'all' || filters.category !== 'all' || filters.priority !== 'all'
              ? 'No goals match your current filters. Try adjusting your search criteria.'
              : 'Start your financial journey by creating your first goal!'
            }
          </EmptyDescription>
          <Button variant="primary" onClick={handleCreateGoal}>
            <Plus size={20} />
            Create Your First Goal
          </Button>
        </EmptyState>
      )}

      <GoalModal
        isOpen={isModalOpen}
        onClose={handleModalClose}
        onSubmit={handleModalSubmit}
        goal={selectedGoal}
        isLoading={isLoading}
      />
    </GoalsContainer>
  );
};

export default Goals;
