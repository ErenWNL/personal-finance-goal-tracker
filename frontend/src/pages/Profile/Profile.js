import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { User, Mail, Phone, MapPin, Calendar, Edit3, Save, X } from 'lucide-react';
import toast from 'react-hot-toast';
import { Container, Card, Button, Input, Label, Heading, Text, Flex } from '../../styles/GlobalStyles';

const ProfileContainer = styled(Container)`
  max-width: 800px;
`;

const ProfileHeader = styled(motion.div)`
  text-align: center;
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const AvatarSection = styled.div`
  position: relative;
  display: inline-block;
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const Avatar = styled.div`
  width: 120px;
  height: 120px;
  border-radius: ${props => props.theme.borderRadius.full};
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[500]}, ${props => props.theme.colors.secondary[500]});
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${props => props.theme.colors.white};
  font-size: ${props => props.theme.fontSizes['3xl']};
  font-weight: ${props => props.theme.fontWeights.bold};
  margin: 0 auto;
  box-shadow: ${props => props.theme.shadows.lg};
`;

const EditAvatarButton = styled(Button)`
  position: absolute;
  bottom: 0;
  right: 0;
  width: 36px;
  height: 36px;
  border-radius: ${props => props.theme.borderRadius.full};
  padding: 0;
  min-height: auto;
`;

const UserName = styled(Heading)`
  level: 2;
  margin-bottom: ${props => props.theme.spacing[2]};
`;

const UserEmail = styled(Text)`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.lg};
`;

const ProfileCard = styled(Card)`
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const CardHeader = styled(Flex)`
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const CardTitle = styled(Heading)`
  level: 3;
  margin: 0;
`;

const FormGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: ${props => props.theme.spacing[4]};
`;

const FormGroup = styled.div`
  margin-bottom: ${props => props.theme.spacing[4]};
`;

const InputWithIcon = styled.div`
  position: relative;
`;

const InputIcon = styled.div`
  position: absolute;
  left: ${props => props.theme.spacing[3]};
  top: 50%;
  transform: translateY(-50%);
  color: ${props => props.theme.colors.gray[400]};
`;

const StyledInput = styled(Input)`
  padding-left: ${props => props.theme.spacing[10]};
`;

const ActionButtons = styled(Flex)`
  justify-content: flex-end;
  gap: ${props => props.theme.spacing[3]};
  margin-top: ${props => props.theme.spacing[6]};
`;

const StatsGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: ${props => props.theme.spacing[4]};
  margin-bottom: ${props => props.theme.spacing[8]};
`;

const StatCard = styled(Card)`
  text-align: center;
  padding: ${props => props.theme.spacing[4]};
`;

const StatValue = styled.div`
  font-size: ${props => props.theme.fontSizes.xl};
  font-weight: ${props => props.theme.fontWeights.bold};
  color: ${props => props.theme.colors.gray[900]};
  margin-bottom: ${props => props.theme.spacing[1]};
`;

const StatLabel = styled.div`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.sm};
`;

const Profile = () => {
  const { user } = useSelector((state) => state.auth);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    firstName: user?.firstName || '',
    lastName: user?.lastName || '',
    email: user?.email || '',
    phone: user?.phone || '',
    address: user?.address || '',
    dateOfBirth: user?.dateOfBirth || '',
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleEdit = () => {
    setIsEditing(true);
  };

  const handleCancel = () => {
    setIsEditing(false);
    setFormData({
      firstName: user?.firstName || '',
      lastName: user?.lastName || '',
      email: user?.email || '',
      phone: user?.phone || '',
      address: user?.address || '',
      dateOfBirth: user?.dateOfBirth || '',
    });
  };

  const handleSave = async () => {
    try {
      // Here you would dispatch an action to update user profile
      toast.success('Profile updated successfully!');
      setIsEditing(false);
    } catch (error) {
      toast.error('Failed to update profile');
    }
  };

  const getInitials = (firstName, lastName) => {
    return `${firstName?.charAt(0) || ''}${lastName?.charAt(0) || ''}`.toUpperCase() || 'U';
  };

  return (
    <ProfileContainer>
      <ProfileHeader
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <AvatarSection>
          <Avatar>
            {getInitials(user?.firstName, user?.lastName)}
          </Avatar>
          <EditAvatarButton variant="primary" size="sm">
            <Edit3 size={16} />
          </EditAvatarButton>
        </AvatarSection>
        <UserName>
          {user?.firstName ? `${user.firstName} ${user.lastName}` : user?.name || 'User'}
        </UserName>
        <UserEmail>{user?.email || 'user@example.com'}</UserEmail>
      </ProfileHeader>

      <StatsGrid
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        <StatCard>
          <StatValue>5</StatValue>
          <StatLabel>Active Goals</StatLabel>
        </StatCard>
        <StatCard>
          <StatValue>$12,450</StatValue>
          <StatLabel>Total Saved</StatLabel>
        </StatCard>
        <StatCard>
          <StatValue>156</StatValue>
          <StatLabel>Transactions</StatLabel>
        </StatCard>
        <StatCard>
          <StatValue>3</StatValue>
          <StatLabel>Goals Completed</StatLabel>
        </StatCard>
      </StatsGrid>

      <ProfileCard
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
      >
        <CardHeader>
          <CardTitle>Personal Information</CardTitle>
          {!isEditing ? (
            <Button variant="outline" onClick={handleEdit}>
              <Edit3 size={16} />
              Edit Profile
            </Button>
          ) : (
            <Flex gap="12px">
              <Button variant="outline" onClick={handleCancel}>
                <X size={16} />
                Cancel
              </Button>
              <Button variant="primary" onClick={handleSave}>
                <Save size={16} />
                Save Changes
              </Button>
            </Flex>
          )}
        </CardHeader>

        <FormGrid>
          <FormGroup>
            <Label htmlFor="firstName">First Name</Label>
            <InputWithIcon>
              <InputIcon>
                <User size={20} />
              </InputIcon>
              <StyledInput
                id="firstName"
                name="firstName"
                type="text"
                value={formData.firstName}
                onChange={handleChange}
                disabled={!isEditing}
                placeholder="Enter your first name"
              />
            </InputWithIcon>
          </FormGroup>

          <FormGroup>
            <Label htmlFor="lastName">Last Name</Label>
            <InputWithIcon>
              <InputIcon>
                <User size={20} />
              </InputIcon>
              <StyledInput
                id="lastName"
                name="lastName"
                type="text"
                value={formData.lastName}
                onChange={handleChange}
                disabled={!isEditing}
                placeholder="Enter your last name"
              />
            </InputWithIcon>
          </FormGroup>

          <FormGroup>
            <Label htmlFor="email">Email Address</Label>
            <InputWithIcon>
              <InputIcon>
                <Mail size={20} />
              </InputIcon>
              <StyledInput
                id="email"
                name="email"
                type="email"
                value={formData.email}
                onChange={handleChange}
                disabled={!isEditing}
                placeholder="Enter your email"
              />
            </InputWithIcon>
          </FormGroup>

          <FormGroup>
            <Label htmlFor="phone">Phone Number</Label>
            <InputWithIcon>
              <InputIcon>
                <Phone size={20} />
              </InputIcon>
              <StyledInput
                id="phone"
                name="phone"
                type="tel"
                value={formData.phone}
                onChange={handleChange}
                disabled={!isEditing}
                placeholder="Enter your phone number"
              />
            </InputWithIcon>
          </FormGroup>

          <FormGroup>
            <Label htmlFor="dateOfBirth">Date of Birth</Label>
            <InputWithIcon>
              <InputIcon>
                <Calendar size={20} />
              </InputIcon>
              <StyledInput
                id="dateOfBirth"
                name="dateOfBirth"
                type="date"
                value={formData.dateOfBirth}
                onChange={handleChange}
                disabled={!isEditing}
              />
            </InputWithIcon>
          </FormGroup>

          <FormGroup>
            <Label htmlFor="address">Address</Label>
            <InputWithIcon>
              <InputIcon>
                <MapPin size={20} />
              </InputIcon>
              <StyledInput
                id="address"
                name="address"
                type="text"
                value={formData.address}
                onChange={handleChange}
                disabled={!isEditing}
                placeholder="Enter your address"
              />
            </InputWithIcon>
          </FormGroup>
        </FormGrid>
      </ProfileCard>

      <ProfileCard
        as={motion.div}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.3 }}
      >
        <CardTitle>Account Settings</CardTitle>
        <Text color={props => props.theme.colors.gray[600]} style={{ marginBottom: '24px' }}>
          Manage your account preferences and security settings
        </Text>
        
        <Flex direction="column" gap="16px">
          <Button variant="outline" fullWidth>
            Change Password
          </Button>
          <Button variant="outline" fullWidth>
            Notification Preferences
          </Button>
          <Button variant="outline" fullWidth>
            Privacy Settings
          </Button>
          <Button variant="danger" fullWidth>
            Delete Account
          </Button>
        </Flex>
      </ProfileCard>
    </ProfileContainer>
  );
};

export default Profile;
