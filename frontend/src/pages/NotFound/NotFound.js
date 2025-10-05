import React from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { Home, ArrowLeft } from 'lucide-react';
import { Button, Heading, Text } from '../../styles/GlobalStyles';

const NotFoundContainer = styled.div`
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[50]} 0%, ${props => props.theme.colors.secondary[50]} 100%);
  padding: ${props => props.theme.spacing[4]};
`;

const NotFoundCard = styled(motion.div)`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius['2xl']};
  box-shadow: ${props => props.theme.shadows['2xl']};
  padding: ${props => props.theme.spacing[12]} ${props => props.theme.spacing[8]};
  text-align: center;
  max-width: 500px;
  width: 100%;
`;

const ErrorCode = styled.div`
  font-size: 8rem;
  font-weight: ${props => props.theme.fontWeights.black};
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[500]}, ${props => props.theme.colors.secondary[500]});
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1;
  margin-bottom: ${props => props.theme.spacing[4]};

  @media (max-width: ${props => props.theme.breakpoints.sm}) {
    font-size: 6rem;
  }
`;

const ErrorTitle = styled(Heading)`
  level: 1;
  margin-bottom: ${props => props.theme.spacing[4]};
  color: ${props => props.theme.colors.gray[900]};
`;

const ErrorDescription = styled(Text)`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.lg};
  margin-bottom: ${props => props.theme.spacing[8]};
  line-height: ${props => props.theme.lineHeights.relaxed};
`;

const ActionButtons = styled.div`
  display: flex;
  gap: ${props => props.theme.spacing[4]};
  justify-content: center;
  flex-wrap: wrap;
`;

const NotFound = () => {
  return (
    <NotFoundContainer>
      <NotFoundCard
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <ErrorCode>404</ErrorCode>
        <ErrorTitle>Page Not Found</ErrorTitle>
        <ErrorDescription>
          Oops! The page you're looking for doesn't exist. It might have been moved, deleted, or you entered the wrong URL.
        </ErrorDescription>
        
        <ActionButtons>
          <Button
            as={Link}
            to="/dashboard"
            variant="primary"
            size="lg"
          >
            <Home size={20} />
            Go to Dashboard
          </Button>
          <Button
            onClick={() => window.history.back()}
            variant="outline"
            size="lg"
          >
            <ArrowLeft size={20} />
            Go Back
          </Button>
        </ActionButtons>
      </NotFoundCard>
    </NotFoundContainer>
  );
};

export default NotFound;
