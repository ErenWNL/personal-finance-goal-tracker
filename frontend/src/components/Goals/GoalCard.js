import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import {
  Target,
  Calendar,
  DollarSign,
  TrendingUp,
  Edit3,
  Trash2,
  CheckCircle,
  Clock,
  AlertCircle,
  MoreVertical,
  Check
} from 'lucide-react';
import { Card, Button, Flex, Text } from '../../styles/GlobalStyles';

const GoalCardContainer = styled(motion.div)`
  position: relative;
`;

const StyledCard = styled(Card)`
  height: 100%;
  padding: ${props => props.theme.spacing[6]};
  border-left: 4px solid ${props => props.statusColor || props.theme.colors.primary[500]};
  transition: all ${props => props.theme.transitions.base};

  &:hover {
    box-shadow: ${props => props.theme.shadows.lg};
    transform: translateY(-2px);
  }
`;

const CardHeader = styled(Flex)`
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const GoalInfo = styled.div`
  flex: 1;
`;

const GoalTitle = styled.h3`
  font-size: ${props => props.theme.fontSizes.lg};
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.theme.colors.gray[900]};
  margin: 0 0 ${props => props.theme.spacing[1]} 0;
`;

const GoalCategory = styled.span`
  display: inline-block;
  background: ${props => props.theme.colors.primary[100]};
  color: ${props => props.theme.colors.primary[700]};
  padding: ${props => props.theme.spacing[1]} ${props => props.theme.spacing[2]};
  border-radius: ${props => props.theme.borderRadius.base};
  font-size: ${props => props.theme.fontSizes.xs};
  font-weight: ${props => props.theme.fontWeights.medium};
`;

const StatusBadge = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[1]};
  padding: ${props => props.theme.spacing[1]} ${props => props.theme.spacing[2]};
  border-radius: ${props => props.theme.borderRadius.base};
  font-size: ${props => props.theme.fontSizes.xs};
  font-weight: ${props => props.theme.fontWeights.medium};
  background: ${props => props.bgColor || props.theme.colors.gray[100]};
  color: ${props => props.textColor || props.theme.colors.gray[700]};
`;

const ProgressSection = styled.div`
  margin: ${props => props.theme.spacing[4]} 0;
`;

const ProgressHeader = styled(Flex)`
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing[2]};
`;

const ProgressLabel = styled(Text)`
  font-size: ${props => props.theme.fontSizes.sm};
  color: ${props => props.theme.colors.gray[600]};
`;

const ProgressPercentage = styled(Text)`
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.theme.colors.gray[900]};
`;

const ProgressBar = styled.div`
  width: 100%;
  height: 8px;
  background: ${props => props.theme.colors.gray[200]};
  border-radius: ${props => props.theme.borderRadius.full};
  overflow: hidden;
`;

const ProgressFill = styled.div`
  height: 100%;
  background: linear-gradient(90deg, ${props => props.theme.colors.primary[500]}, ${props => props.theme.colors.secondary[500]});
  border-radius: ${props => props.theme.borderRadius.full};
  width: ${props => props.percentage}%;
  transition: width ${props => props.theme.transitions.base};
`;

const AmountSection = styled.div`
  margin: ${props => props.theme.spacing[4]} 0;
`;

const AmountRow = styled(Flex)`
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing[1]};
`;

const AmountLabel = styled(Text)`
  font-size: ${props => props.theme.fontSizes.sm};
  color: ${props => props.theme.colors.gray[600]};
`;

const AmountValue = styled(Text)`
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.theme.colors.gray[900]};
`;

const TargetDate = styled(Flex)`
  align-items: center;
  gap: ${props => props.theme.spacing[2]};
  margin: ${props => props.theme.spacing[4]} 0;
  padding: ${props => props.theme.spacing[3]};
  background: ${props => props.theme.colors.gray[50]};
  border-radius: ${props => props.theme.borderRadius.md};
`;

const DateIcon = styled.div`
  color: ${props => props.theme.colors.gray[500]};
`;

const DateText = styled(Text)`
  font-size: ${props => props.theme.fontSizes.sm};
  color: ${props => props.theme.colors.gray[700]};
`;

const CardActions = styled(Flex)`
  justify-content: flex-end;
  gap: ${props => props.theme.spacing[2]};
  margin-top: ${props => props.theme.spacing[4]};
  padding-top: ${props => props.theme.spacing[4]};
  border-top: 1px solid ${props => props.theme.colors.gray[100]};
`;

const ActionButton = styled(Button)`
  padding: ${props => props.theme.spacing[2]};
  min-height: auto;
  width: 36px;
  height: 36px;
`;

const GoalCard = ({ goal, onEdit, onDelete, onComplete, index }) => {
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount || 0);
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'No target date';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getStatusInfo = (status) => {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return {
          icon: CheckCircle,
          bgColor: '#dcfce7',
          textColor: '#16a34a',
          label: 'Completed',
          statusColor: '#10b981'
        };
      case 'ACTIVE':
        return {
          icon: TrendingUp,
          bgColor: '#dbeafe',
          textColor: '#2563eb',
          label: 'Active',
          statusColor: '#3b82f6'
        };
      case 'PAUSED':
        return {
          icon: Clock,
          bgColor: '#fef3c7',
          textColor: '#d97706',
          label: 'Paused',
          statusColor: '#f59e0b'
        };
      default:
        return {
          icon: AlertCircle,
          bgColor: '#fee2e2',
          textColor: '#dc2626',
          label: 'Unknown',
          statusColor: '#ef4444'
        };
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return '#ef4444';
      case 'MEDIUM':
        return '#f59e0b';
      case 'LOW':
        return '#10b981';
      default:
        return '#6b7280';
    }
  };

  const calculateProgress = () => {
    const current = goal.currentAmount || 0;
    const target = goal.targetAmount || 1;
    return Math.min((current / target) * 100, 100);
  };

  const statusInfo = getStatusInfo(goal.status);
  const StatusIcon = statusInfo.icon;
  const progress = calculateProgress();

  return (
    <GoalCardContainer
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: index * 0.1 }}
      whileHover={{ y: -4 }}
    >
      <StyledCard statusColor={statusInfo.statusColor}>
        <CardHeader>
          <GoalInfo>
            <GoalTitle>{goal.title}</GoalTitle>
            <GoalCategory>
              {goal.category?.name || 'Uncategorized'}
            </GoalCategory>
          </GoalInfo>
          <StatusBadge
            bgColor={statusInfo.bgColor}
            textColor={statusInfo.textColor}
          >
            <StatusIcon size={14} />
            {statusInfo.label}
          </StatusBadge>
        </CardHeader>

        {goal.description && (
          <Text
            size={props => props.theme.fontSizes.sm}
            color={props => props.theme.colors.gray[600]}
            style={{ marginBottom: props => props.theme.spacing[4] }}
          >
            {goal.description}
          </Text>
        )}

        <ProgressSection>
          <ProgressHeader>
            <ProgressLabel>Progress</ProgressLabel>
            <ProgressPercentage>{Math.round(progress)}%</ProgressPercentage>
          </ProgressHeader>
          <ProgressBar>
            <ProgressFill percentage={progress} />
          </ProgressBar>
        </ProgressSection>

        <AmountSection>
          <AmountRow>
            <AmountLabel>Current Amount</AmountLabel>
            <AmountValue>{formatCurrency(goal.currentAmount)}</AmountValue>
          </AmountRow>
          <AmountRow>
            <AmountLabel>Target Amount</AmountLabel>
            <AmountValue>{formatCurrency(goal.targetAmount)}</AmountValue>
          </AmountRow>
          <AmountRow>
            <AmountLabel>Remaining</AmountLabel>
            <AmountValue>
              {formatCurrency(Math.max(0, (goal.targetAmount || 0) - (goal.currentAmount || 0)))}
            </AmountValue>
          </AmountRow>
        </AmountSection>

        {goal.targetDate && (
          <TargetDate>
            <DateIcon>
              <Calendar size={16} />
            </DateIcon>
            <DateText>Target: {formatDate(goal.targetDate)}</DateText>
          </TargetDate>
        )}

        <CardActions>
          {goal.status?.toUpperCase() !== 'COMPLETED' && (
            <ActionButton
              variant="primary"
              size="sm"
              onClick={() => onComplete(goal)}
              title="Mark as Completed"
            >
              <Check size={16} />
            </ActionButton>
          )}
          <ActionButton
            variant="outline"
            size="sm"
            onClick={() => onEdit(goal)}
            title="Edit Goal"
          >
            <Edit3 size={16} />
          </ActionButton>
          <ActionButton
            variant="danger"
            size="sm"
            onClick={() => onDelete(goal.id)}
            title="Delete Goal"
          >
            <Trash2 size={16} />
          </ActionButton>
        </CardActions>
      </StyledCard>
    </GoalCardContainer>
  );
};

export default GoalCard;
