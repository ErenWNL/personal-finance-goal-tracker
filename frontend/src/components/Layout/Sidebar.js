import React, { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import styled from 'styled-components';
import { 
  LayoutDashboard, 
  Target, 
  CreditCard, 
  TrendingUp, 
  User, 
  Menu,
  X,
  LogOut
} from 'lucide-react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../../store/slices/authSlice';
import { Button } from '../../styles/GlobalStyles';

const SidebarContainer = styled.aside`
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  width: 280px;
  background: ${props => props.theme.colors.white};
  border-right: 1px solid ${props => props.theme.colors.gray[200]};
  box-shadow: ${props => props.theme.shadows.sm};
  z-index: ${props => props.theme.zIndex.fixed};
  transform: translateX(${props => props.isOpen ? '0' : '-100%'});
  transition: transform ${props => props.theme.transitions.base};

  @media (min-width: ${props => props.theme.breakpoints.lg}) {
    transform: translateX(0);
  }
`;

const SidebarHeader = styled.div`
  padding: ${props => props.theme.spacing[6]};
  border-bottom: 1px solid ${props => props.theme.colors.gray[200]};
`;

const Logo = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[3]};
  font-size: ${props => props.theme.fontSizes.xl};
  font-weight: ${props => props.theme.fontWeights.bold};
  color: ${props => props.theme.colors.primary[600]};
`;

const LogoIcon = styled.div`
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[500]}, ${props => props.theme.colors.secondary[500]});
  border-radius: ${props => props.theme.borderRadius.lg};
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${props => props.theme.colors.white};
`;

const Navigation = styled.nav`
  padding: ${props => props.theme.spacing[4]} 0;
  flex: 1;
`;

const NavItem = styled(NavLink)`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[3]};
  padding: ${props => props.theme.spacing[3]} ${props => props.theme.spacing[6]};
  color: ${props => props.theme.colors.gray[600]};
  font-weight: ${props => props.theme.fontWeights.medium};
  transition: all ${props => props.theme.transitions.fast};
  border-right: 3px solid transparent;

  &:hover {
    background: ${props => props.theme.colors.gray[50]};
    color: ${props => props.theme.colors.gray[900]};
  }

  &.active {
    background: ${props => props.theme.colors.primary[50]};
    color: ${props => props.theme.colors.primary[700]};
    border-right-color: ${props => props.theme.colors.primary[600]};
  }

  svg {
    width: 20px;
    height: 20px;
  }
`;

const SidebarFooter = styled.div`
  padding: ${props => props.theme.spacing[4]} ${props => props.theme.spacing[6]};
  border-top: 1px solid ${props => props.theme.colors.gray[200]};
`;

const UserInfo = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing[3]};
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const UserAvatar = styled.div`
  width: 40px;
  height: 40px;
  background: ${props => props.theme.colors.primary[100]};
  border-radius: ${props => props.theme.borderRadius.full};
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${props => props.theme.colors.primary[700]};
  font-weight: ${props => props.theme.fontWeights.semibold};
`;

const UserDetails = styled.div`
  flex: 1;
`;

const UserName = styled.div`
  font-weight: ${props => props.theme.fontWeights.medium};
  color: ${props => props.theme.colors.gray[900]};
  font-size: ${props => props.theme.fontSizes.sm};
`;

const UserEmail = styled.div`
  font-size: ${props => props.theme.fontSizes.xs};
  color: ${props => props.theme.colors.gray[500]};
`;

const MobileToggle = styled.button`
  position: fixed;
  top: ${props => props.theme.spacing[4]};
  left: ${props => props.theme.spacing[4]};
  z-index: ${props => props.theme.zIndex.modal};
  background: ${props => props.theme.colors.white};
  border: 1px solid ${props => props.theme.colors.gray[200]};
  border-radius: ${props => props.theme.borderRadius.md};
  padding: ${props => props.theme.spacing[2]};
  box-shadow: ${props => props.theme.shadows.sm};
  display: none;

  @media (max-width: ${props => props.theme.breakpoints.lg}) {
    display: flex;
    align-items: center;
    justify-content: center;
  }

  svg {
    width: 20px;
    height: 20px;
    color: ${props => props.theme.colors.gray[600]};
  }
`;

const Overlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: ${props => props.theme.zIndex.modal - 1};
  display: ${props => props.isOpen ? 'block' : 'none'};

  @media (min-width: ${props => props.theme.breakpoints.lg}) {
    display: none;
  }
`;

const navigationItems = [
  { path: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/goals', label: 'Goals', icon: Target },
  { path: '/transactions', label: 'Transactions', icon: CreditCard },
  { path: '/insights', label: 'Insights', icon: TrendingUp },
  { path: '/profile', label: 'Profile', icon: User },
];

const Sidebar = () => {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();
  const dispatch = useDispatch();
  const { user } = useSelector((state) => state.auth);

  const handleLogout = () => {
    dispatch(logoutUser());
  };

  const toggleSidebar = () => {
    setIsOpen(!isOpen);
  };

  const closeSidebar = () => {
    setIsOpen(false);
  };

  const getInitials = (name) => {
    if (!name) return 'U';
    return name.split(' ').map(n => n[0]).join('').toUpperCase();
  };

  return (
    <>
      <MobileToggle onClick={toggleSidebar}>
        {isOpen ? <X /> : <Menu />}
      </MobileToggle>

      <Overlay isOpen={isOpen} onClick={closeSidebar} />

      <SidebarContainer isOpen={isOpen}>
        <SidebarHeader>
          <Logo>
            <LogoIcon>
              <Target size={24} />
            </LogoIcon>
            FinanceTracker
          </Logo>
        </SidebarHeader>

        <Navigation>
          {navigationItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavItem
                key={item.path}
                to={item.path}
                onClick={closeSidebar}
                className={location.pathname === item.path ? 'active' : ''}
              >
                <Icon />
                {item.label}
              </NavItem>
            );
          })}
        </Navigation>

        <SidebarFooter>
          <UserInfo>
            <UserAvatar>
              {getInitials(user?.firstName || user?.name)}
            </UserAvatar>
            <UserDetails>
              <UserName>
                {user?.firstName ? `${user.firstName} ${user.lastName}` : user?.name || 'User'}
              </UserName>
              <UserEmail>{user?.email || 'user@example.com'}</UserEmail>
            </UserDetails>
          </UserInfo>
          
          <Button
            variant="outline"
            size="sm"
            fullWidth
            onClick={handleLogout}
          >
            <LogOut size={16} />
            Logout
          </Button>
        </SidebarFooter>
      </SidebarContainer>
    </>
  );
};

export default Sidebar;
