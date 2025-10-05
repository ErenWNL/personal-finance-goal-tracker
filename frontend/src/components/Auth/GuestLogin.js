import React from 'react';
import styled from 'styled-components';
import { User } from 'lucide-react';
import { Button } from '../../styles/GlobalStyles';

const GuestSection = styled.div`
  margin-top: ${props => props.theme.spacing[6]};
  padding-top: ${props => props.theme.spacing[6]};
  border-top: 1px solid ${props => props.theme.colors.gray[200]};
  text-align: center;
`;

const GuestTitle = styled.h3`
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.medium};
  color: ${props => props.theme.colors.gray[700]};
  margin-bottom: ${props => props.theme.spacing[3]};
`;

const GuestCredentials = styled.div`
  background: ${props => props.theme.colors.gray[50]};
  border-radius: ${props => props.theme.borderRadius.md};
  padding: ${props => props.theme.spacing[3]};
  margin-bottom: ${props => props.theme.spacing[4]};
  font-size: ${props => props.theme.fontSizes.sm};
  color: ${props => props.theme.colors.gray[600]};
`;

const CredentialRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing[1]};

  &:last-child {
    margin-bottom: 0;
  }
`;

const CredentialLabel = styled.span`
  font-weight: ${props => props.theme.fontWeights.medium};
`;

const CredentialValue = styled.span`
  font-family: ${props => props.theme.fonts.mono};
  background: ${props => props.theme.colors.white};
  padding: ${props => props.theme.spacing[1]} ${props => props.theme.spacing[2]};
  border-radius: ${props => props.theme.borderRadius.sm};
  border: 1px solid ${props => props.theme.colors.gray[200]};
`;

const GuestLogin = ({ onGuestLogin, isLoading }) => {
  const handleGuestLogin = () => {
    onGuestLogin({
      email: 'arya@gmail.com',
      password: 'arya@123'
    });
  };

  return (
    <GuestSection>
      <GuestTitle>Try with Guest Account</GuestTitle>
      <GuestCredentials>
        <CredentialRow>
          <CredentialLabel>Email:</CredentialLabel>
          <CredentialValue>arya@gmail.com</CredentialValue>
        </CredentialRow>
        <CredentialRow>
          <CredentialLabel>Password:</CredentialLabel>
          <CredentialValue>arya@123</CredentialValue>
        </CredentialRow>
      </GuestCredentials>
      <Button
        variant="outline"
        fullWidth
        onClick={handleGuestLogin}
        disabled={isLoading}
      >
        <User size={16} />
        Login as Guest
      </Button>
    </GuestSection>
  );
};

export default GuestLogin;
