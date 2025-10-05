import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { Eye, EyeOff, Target, Mail, Lock, User } from 'lucide-react';
import toast from 'react-hot-toast';
import { registerUser, clearError } from '../../store/slices/authSlice';
import { Button, Input, Label, ErrorMessage, LoadingSpinner } from '../../styles/GlobalStyles';

const RegisterContainer = styled.div`
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[50]} 0%, ${props => props.theme.colors.secondary[50]} 100%);
  padding: ${props => props.theme.spacing[4]};
`;

const RegisterCard = styled(motion.div)`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius['2xl']};
  box-shadow: ${props => props.theme.shadows['2xl']};
  padding: ${props => props.theme.spacing[8]};
  width: 100%;
  max-width: 480px;
`;

const LogoContainer = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: ${props => props.theme.spacing[3]};
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const LogoIcon = styled.div`
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, ${props => props.theme.colors.primary[500]}, ${props => props.theme.colors.secondary[500]});
  border-radius: ${props => props.theme.borderRadius.xl};
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${props => props.theme.colors.white};
`;

const LogoText = styled.h1`
  font-size: ${props => props.theme.fontSizes['2xl']};
  font-weight: ${props => props.theme.fontWeights.bold};
  color: ${props => props.theme.colors.gray[900]};
  margin: 0;
`;

const WelcomeText = styled.div`
  text-align: center;
  margin-bottom: ${props => props.theme.spacing[6]};
`;

const WelcomeTitle = styled.h2`
  font-size: ${props => props.theme.fontSizes.xl};
  font-weight: ${props => props.theme.fontWeights.semibold};
  color: ${props => props.theme.colors.gray[900]};
  margin: 0 0 ${props => props.theme.spacing[2]} 0;
`;

const WelcomeSubtitle = styled.p`
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.sm};
  margin: 0;
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing[4]};
`;

const InputRow = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: ${props => props.theme.spacing[4]};

  @media (max-width: ${props => props.theme.breakpoints.sm}) {
    grid-template-columns: 1fr;
  }
`;

const InputGroup = styled.div`
  position: relative;
`;

const InputIcon = styled.div`
  position: absolute;
  left: ${props => props.theme.spacing[3]};
  top: 50%;
  transform: translateY(-50%);
  color: ${props => props.theme.colors.gray[400]};
  z-index: 1;
`;

const StyledInput = styled(Input)`
  padding-left: ${props => props.theme.spacing[10]};
`;

const PasswordInputContainer = styled.div`
  position: relative;
`;

const PasswordToggle = styled.button`
  position: absolute;
  right: ${props => props.theme.spacing[3]};
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: ${props => props.theme.colors.gray[400]};
  cursor: pointer;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;

  &:hover {
    color: ${props => props.theme.colors.gray[600]};
  }
`;

const PasswordStrength = styled.div`
  margin-top: ${props => props.theme.spacing[2]};
  font-size: ${props => props.theme.fontSizes.xs};
  color: ${props => {
    switch (props.strength) {
      case 'weak': return props.theme.colors.error[600];
      case 'medium': return props.theme.colors.warning[600];
      case 'strong': return props.theme.colors.success[600];
      default: return props.theme.colors.gray[500];
    }
  }};
`;

const LoginPrompt = styled.div`
  text-align: center;
  margin-top: ${props => props.theme.spacing[6]};
  padding-top: ${props => props.theme.spacing[6]};
  border-top: 1px solid ${props => props.theme.colors.gray[200]};
  color: ${props => props.theme.colors.gray[600]};
  font-size: ${props => props.theme.fontSizes.sm};
`;

const LoginLink = styled(Link)`
  color: ${props => props.theme.colors.primary[600]};
  font-weight: ${props => props.theme.fontWeights.medium};
  text-decoration: none;

  &:hover {
    color: ${props => props.theme.colors.primary[700]};
    text-decoration: underline;
  }
`;

const Register = () => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [validationErrors, setValidationErrors] = useState({});
  const [passwordStrength, setPasswordStrength] = useState('');

  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { isLoading, error, isAuthenticated } = useSelector((state) => state.auth);

  useEffect(() => {
    if (isAuthenticated) {
      navigate('/dashboard', { replace: true });
    }
  }, [isAuthenticated, navigate]);

  useEffect(() => {
    if (error) {
      toast.error(error);
      dispatch(clearError());
    }
  }, [error, dispatch]);

  const calculatePasswordStrength = (password) => {
    if (password.length < 6) return 'weak';
    if (password.length < 8) return 'medium';
    
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
    
    const strengthScore = [hasUpperCase, hasLowerCase, hasNumbers, hasSpecialChar].filter(Boolean).length;
    
    if (strengthScore >= 3) return 'strong';
    if (strengthScore >= 2) return 'medium';
    return 'weak';
  };

  const validateForm = () => {
    const errors = {};

    if (!formData.firstName.trim()) {
      errors.firstName = 'First name is required';
    }

    if (!formData.lastName.trim()) {
      errors.lastName = 'Last name is required';
    }

    if (!formData.email) {
      errors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      errors.email = 'Please enter a valid email';
    }

    if (!formData.password) {
      errors.password = 'Password is required';
    } else if (formData.password.length < 6) {
      errors.password = 'Password must be at least 6 characters';
    }

    if (!formData.confirmPassword) {
      errors.confirmPassword = 'Please confirm your password';
    } else if (formData.password !== formData.confirmPassword) {
      errors.confirmPassword = 'Passwords do not match';
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
    
    // Calculate password strength
    if (name === 'password') {
      setPasswordStrength(calculatePasswordStrength(value));
    }
    
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

    try {
      const result = await dispatch(registerUser({
        firstName: formData.firstName.trim(),
        lastName: formData.lastName.trim(),
        email: formData.email.trim(),
        password: formData.password,
      }));
      
      if (registerUser.fulfilled.match(result)) {
        toast.success('Account created successfully! Please sign in.');
        navigate('/login');
      }
    } catch (err) {
      console.error('Registration error:', err);
    }
  };

  const togglePasswordVisibility = (field) => {
    if (field === 'password') {
      setShowPassword(!showPassword);
    } else {
      setShowConfirmPassword(!showConfirmPassword);
    }
  };

  const getPasswordStrengthText = () => {
    switch (passwordStrength) {
      case 'weak': return 'Weak password';
      case 'medium': return 'Medium strength';
      case 'strong': return 'Strong password';
      default: return '';
    }
  };

  return (
    <RegisterContainer>
      <RegisterCard
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <LogoContainer>
          <LogoIcon>
            <Target size={28} />
          </LogoIcon>
          <LogoText>FinanceTracker</LogoText>
        </LogoContainer>

        <WelcomeText>
          <WelcomeTitle>Create your account</WelcomeTitle>
          <WelcomeSubtitle>Start managing your finances effectively</WelcomeSubtitle>
        </WelcomeText>

        <Form onSubmit={handleSubmit}>
          <InputRow>
            <div>
              <Label htmlFor="firstName">First Name</Label>
              <InputGroup>
                <InputIcon>
                  <User size={20} />
                </InputIcon>
                <StyledInput
                  id="firstName"
                  name="firstName"
                  type="text"
                  placeholder="First name"
                  value={formData.firstName}
                  onChange={handleChange}
                  error={validationErrors.firstName}
                  disabled={isLoading}
                />
              </InputGroup>
              {validationErrors.firstName && <ErrorMessage>{validationErrors.firstName}</ErrorMessage>}
            </div>

            <div>
              <Label htmlFor="lastName">Last Name</Label>
              <InputGroup>
                <InputIcon>
                  <User size={20} />
                </InputIcon>
                <StyledInput
                  id="lastName"
                  name="lastName"
                  type="text"
                  placeholder="Last name"
                  value={formData.lastName}
                  onChange={handleChange}
                  error={validationErrors.lastName}
                  disabled={isLoading}
                />
              </InputGroup>
              {validationErrors.lastName && <ErrorMessage>{validationErrors.lastName}</ErrorMessage>}
            </div>
          </InputRow>

          <div>
            <Label htmlFor="email">Email Address</Label>
            <InputGroup>
              <InputIcon>
                <Mail size={20} />
              </InputIcon>
              <StyledInput
                id="email"
                name="email"
                type="email"
                placeholder="Enter your email"
                value={formData.email}
                onChange={handleChange}
                error={validationErrors.email}
                disabled={isLoading}
              />
            </InputGroup>
            {validationErrors.email && <ErrorMessage>{validationErrors.email}</ErrorMessage>}
          </div>

          <div>
            <Label htmlFor="password">Password</Label>
            <InputGroup>
              <InputIcon>
                <Lock size={20} />
              </InputIcon>
              <PasswordInputContainer>
                <StyledInput
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="Create a password"
                  value={formData.password}
                  onChange={handleChange}
                  error={validationErrors.password}
                  disabled={isLoading}
                  style={{ paddingRight: '48px' }}
                />
                <PasswordToggle
                  type="button"
                  onClick={() => togglePasswordVisibility('password')}
                  disabled={isLoading}
                >
                  {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </PasswordToggle>
              </PasswordInputContainer>
            </InputGroup>
            {formData.password && (
              <PasswordStrength strength={passwordStrength}>
                {getPasswordStrengthText()}
              </PasswordStrength>
            )}
            {validationErrors.password && <ErrorMessage>{validationErrors.password}</ErrorMessage>}
          </div>

          <div>
            <Label htmlFor="confirmPassword">Confirm Password</Label>
            <InputGroup>
              <InputIcon>
                <Lock size={20} />
              </InputIcon>
              <PasswordInputContainer>
                <StyledInput
                  id="confirmPassword"
                  name="confirmPassword"
                  type={showConfirmPassword ? 'text' : 'password'}
                  placeholder="Confirm your password"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  error={validationErrors.confirmPassword}
                  disabled={isLoading}
                  style={{ paddingRight: '48px' }}
                />
                <PasswordToggle
                  type="button"
                  onClick={() => togglePasswordVisibility('confirmPassword')}
                  disabled={isLoading}
                >
                  {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </PasswordToggle>
              </PasswordInputContainer>
            </InputGroup>
            {validationErrors.confirmPassword && <ErrorMessage>{validationErrors.confirmPassword}</ErrorMessage>}
          </div>

          <Button
            type="submit"
            variant="primary"
            size="lg"
            fullWidth
            disabled={isLoading}
          >
            {isLoading ? <LoadingSpinner size="20px" /> : 'Create Account'}
          </Button>
        </Form>

        <LoginPrompt>
          Already have an account?{' '}
          <LoginLink to="/login">Sign in here</LoginLink>
        </LoginPrompt>
      </RegisterCard>
    </RegisterContainer>
  );
};

export default Register;
