import React from 'react';
import { useLocation } from 'react-router-dom';
import styled from 'styled-components';
import { Bell, Search } from 'lucide-react';
import { useSelector } from 'react-redux';
import { Input, Button, Flex } from '../../styles/GlobalStyles';

const HeaderContainer = styled.header`
  background: ${props => props.theme.colors.white};
  border-bottom: 1px solid ${props => props.theme.colors.gray[200]};
  padding: ${props => props.theme.spacing[4]} ${props => props.theme.spacing[6]};
  position: sticky;
  top: 0;
  z-index: ${props => props.theme.zIndex.sticky};

  @media (max-width: ${props => props.theme.breakpoints.md}) {
    padding: ${props => props.theme.spacing[4]};
    margin-top: 60px; /* Account for mobile menu button */
  }
`;

const HeaderContent = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: ${props => props.theme.spacing[4]};
`;

const PageTitle = styled.h1`
  font-size: ${props => props.theme.fontSizes['2xl']};
  font-weight: ${props => props.theme.fontWeights.bold};
  color: ${props => props.theme.colors.gray[900]};
  margin: 0;

  @media (max-width: ${props => props.theme.breakpoints.md}) {
    font-size: ${props => props.theme.fontSizes.xl};
  }
`;

const SearchContainer = styled.div`
  position: relative;
  flex: 1;
  max-width: 400px;

  @media (max-width: ${props => props.theme.breakpoints.md}) {
    display: none;
  }
`;

const SearchInput = styled(Input)`
  padding-left: ${props => props.theme.spacing[10]};
`;

const SearchIcon = styled(Search)`
  position: absolute;
  left: ${props => props.theme.spacing[3]};
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  color: ${props => props.theme.colors.gray[400]};
`;

const HeaderActions = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[3]};
`;

const NotificationButton = styled(Button)`
  position: relative;
  padding: ${props => props.theme.spacing[2]};
  min-height: auto;
  width: 44px;
  height: 44px;
`;

const NotificationBadge = styled.span`
  position: absolute;
  top: -2px;
  right: -2px;
  background: ${props => props.theme.colors.error[500]};
  color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.full};
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: ${props => props.theme.fontSizes.xs};
  font-weight: ${props => props.theme.fontWeights.semibold};
`;

const WelcomeMessage = styled.div`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.sm};

  @media (max-width: ${props => props.theme.breakpoints.md}) {
    display: none;
  }
`;

const getPageTitle = (pathname) => {
  switch (pathname) {
    case '/dashboard':
      return 'Dashboard';
    case '/goals':
      return 'Financial Goals';
    case '/transactions':
      return 'Transactions';
    case '/insights':
      return 'Insights & Analytics';
    case '/profile':
      return 'Profile Settings';
    default:
      return 'Finance Tracker';
  }
};

const getWelcomeMessage = (pathname) => {
  switch (pathname) {
    case '/dashboard':
      return 'Welcome back! Here\'s your financial overview.';
    case '/goals':
      return 'Track and manage your financial goals.';
    case '/transactions':
      return 'View and manage your transactions.';
    case '/insights':
      return 'Analyze your spending patterns and trends.';
    case '/profile':
      return 'Manage your account settings and preferences.';
    default:
      return 'Manage your personal finances effectively.';
  }
};

const Header = () => {
  const location = useLocation();
  const { user } = useSelector((state) => state.auth);
  
  const pageTitle = getPageTitle(location.pathname);
  const welcomeMessage = getWelcomeMessage(location.pathname);

  return (
    <HeaderContainer>
      <HeaderContent>
        <div>
          <PageTitle>{pageTitle}</PageTitle>
          <WelcomeMessage>{welcomeMessage}</WelcomeMessage>
        </div>

        <SearchContainer>
          <SearchIcon />
          <SearchInput
            type="text"
            placeholder="Search transactions, goals..."
          />
        </SearchContainer>

        <HeaderActions>
          <NotificationButton variant="secondary">
            <Bell size={20} />
            <NotificationBadge>3</NotificationBadge>
          </NotificationButton>
        </HeaderActions>
      </HeaderContent>
    </HeaderContainer>
  );
};

export default Header;
