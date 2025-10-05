import React from 'react';
import styled from 'styled-components';
import { TestTube } from 'lucide-react';
import { isMockMode } from '../services/apiConfig';

const DemoIndicator = styled.div`
  position: fixed;
  top: ${props => props.theme.spacing[4]};
  right: ${props => props.theme.spacing[4]};
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: white;
  padding: ${props => props.theme.spacing[2]} ${props => props.theme.spacing[3]};
  border-radius: ${props => props.theme.borderRadius.full};
  font-size: ${props => props.theme.fontSizes.xs};
  font-weight: ${props => props.theme.fontWeights.semibold};
  z-index: ${props => props.theme.zIndex.tooltip};
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[1]};
  box-shadow: ${props => props.theme.shadows.lg};
  animation: pulse 2s infinite;

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.8;
    }
  }

  @media (max-width: ${props => props.theme.breakpoints.sm}) {
    top: ${props => props.theme.spacing[2]};
    right: ${props => props.theme.spacing[2]};
    font-size: ${props => props.theme.fontSizes['2xs']};
    padding: ${props => props.theme.spacing[1]} ${props => props.theme.spacing[2]};
  }
`;

const DemoModeIndicator = () => {
  if (!isMockMode()) return null;

  return (
    <DemoIndicator>
      <TestTube size={14} />
      DEMO MODE
    </DemoIndicator>
  );
};

export default DemoModeIndicator;
