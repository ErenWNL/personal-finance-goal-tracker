import styled, { createGlobalStyle } from 'styled-components';

export const GlobalStyles = createGlobalStyle`
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@100;300;400;500;600;700;800;900&display=swap');
  
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  html {
    font-size: 16px;
    scroll-behavior: smooth;
  }

  body {
    font-family: ${props => props.theme.fonts.primary};
    font-size: ${props => props.theme.fontSizes.base};
    font-weight: ${props => props.theme.fontWeights.normal};
    line-height: ${props => props.theme.lineHeights.normal};
    color: ${props => props.theme.colors.gray[800]};
    background-color: ${props => props.theme.colors.gray[50]};
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  #root {
    min-height: 100vh;
  }

  a {
    color: inherit;
    text-decoration: none;
  }

  button {
    cursor: pointer;
    border: none;
    outline: none;
    font-family: inherit;
  }

  input, textarea, select {
    font-family: inherit;
    outline: none;
  }

  ul, ol {
    list-style: none;
  }

  img {
    max-width: 100%;
    height: auto;
  }

  /* Custom scrollbar */
  ::-webkit-scrollbar {
    width: 8px;
  }

  ::-webkit-scrollbar-track {
    background: ${props => props.theme.colors.gray[100]};
  }

  ::-webkit-scrollbar-thumb {
    background: ${props => props.theme.colors.gray[300]};
    border-radius: ${props => props.theme.borderRadius.full};
  }

  ::-webkit-scrollbar-thumb:hover {
    background: ${props => props.theme.colors.gray[400]};
  }

  /* Loading animation */
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  @keyframes slideUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes slideDown {
    from {
      opacity: 0;
      transform: translateY(-20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes slideLeft {
    from {
      opacity: 0;
      transform: translateX(20px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  @keyframes slideRight {
    from {
      opacity: 0;
      transform: translateX(-20px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.5;
    }
  }

  /* Utility classes */
  .fade-in {
    animation: fadeIn 0.3s ease-in-out;
  }

  .slide-up {
    animation: slideUp 0.3s ease-out;
  }

  .slide-down {
    animation: slideDown 0.3s ease-out;
  }

  .slide-left {
    animation: slideLeft 0.3s ease-out;
  }

  .slide-right {
    animation: slideRight 0.3s ease-out;
  }

  .pulse {
    animation: pulse 2s infinite;
  }
`;

// Common styled components
export const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 ${props => props.theme.spacing[4]};

  @media (min-width: ${props => props.theme.breakpoints.sm}) {
    padding: 0 ${props => props.theme.spacing[6]};
  }

  @media (min-width: ${props => props.theme.breakpoints.lg}) {
    padding: 0 ${props => props.theme.spacing[8]};
  }
`;

export const Card = styled.div`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.lg};
  box-shadow: ${props => props.theme.shadows.base};
  padding: ${props => props.theme.spacing[6]};
  transition: all ${props => props.theme.transitions.base};

  &:hover {
    box-shadow: ${props => props.theme.shadows.md};
  }
`;

export const Button = styled.button`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: ${props => props.theme.spacing[2]};
  padding: ${props => props.theme.spacing[3]} ${props => props.theme.spacing[6]};
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.medium};
  border-radius: ${props => props.theme.borderRadius.md};
  transition: all ${props => props.theme.transitions.fast};
  cursor: pointer;
  border: none;
  outline: none;
  text-decoration: none;
  min-height: 44px;

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  /* Primary variant */
  ${props => props.variant === 'primary' && `
    background: ${props.theme.colors.primary[600]};
    color: ${props.theme.colors.white};

    &:hover:not(:disabled) {
      background: ${props.theme.colors.primary[700]};
    }

    &:active {
      background: ${props.theme.colors.primary[800]};
    }
  `}

  /* Secondary variant */
  ${props => props.variant === 'secondary' && `
    background: ${props.theme.colors.gray[100]};
    color: ${props.theme.colors.gray[700]};

    &:hover:not(:disabled) {
      background: ${props.theme.colors.gray[200]};
    }

    &:active {
      background: ${props.theme.colors.gray[300]};
    }
  `}

  /* Outline variant */
  ${props => props.variant === 'outline' && `
    background: transparent;
    color: ${props.theme.colors.primary[600]};
    border: 1px solid ${props.theme.colors.primary[600]};

    &:hover:not(:disabled) {
      background: ${props.theme.colors.primary[50]};
    }

    &:active {
      background: ${props.theme.colors.primary[100]};
    }
  `}

  /* Success variant */
  ${props => props.variant === 'success' && `
    background: ${props.theme.colors.success[600]};
    color: ${props.theme.colors.white};

    &:hover:not(:disabled) {
      background: ${props.theme.colors.success[700]};
    }

    &:active {
      background: ${props.theme.colors.success[800]};
    }
  `}

  /* Danger variant */
  ${props => props.variant === 'danger' && `
    background: ${props.theme.colors.error[600]};
    color: ${props.theme.colors.white};

    &:hover:not(:disabled) {
      background: ${props.theme.colors.error[700]};
    }

    &:active {
      background: ${props.theme.colors.error[800]};
    }
  `}

  /* Size variants */
  ${props => props.size === 'sm' && `
    padding: ${props.theme.spacing[2]} ${props.theme.spacing[4]};
    font-size: ${props.theme.fontSizes.xs};
    min-height: 36px;
  `}

  ${props => props.size === 'lg' && `
    padding: ${props.theme.spacing[4]} ${props.theme.spacing[8]};
    font-size: ${props.theme.fontSizes.base};
    min-height: 52px;
  `}

  /* Full width */
  ${props => props.fullWidth && `
    width: 100%;
  `}
`;

export const Input = styled.input`
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

export const Label = styled.label`
  display: block;
  font-size: ${props => props.theme.fontSizes.sm};
  font-weight: ${props => props.theme.fontWeights.medium};
  color: ${props => props.theme.colors.gray[700]};
  margin-bottom: ${props => props.theme.spacing[2]};
`;

export const ErrorMessage = styled.span`
  display: block;
  font-size: ${props => props.theme.fontSizes.xs};
  color: ${props => props.theme.colors.error[600]};
  margin-top: ${props => props.theme.spacing[1]};
`;

export const LoadingSpinner = styled.div`
  width: ${props => props.size || '24px'};
  height: ${props => props.size || '24px'};
  border: 2px solid ${props => props.theme.colors.gray[200]};
  border-top: 2px solid ${props => props.theme.colors.primary[600]};
  border-radius: 50%;
  animation: spin 1s linear infinite;
`;

export const Flex = styled.div`
  display: flex;
  align-items: ${props => props.align || 'stretch'};
  justify-content: ${props => props.justify || 'flex-start'};
  gap: ${props => props.gap || '0'};
  flex-direction: ${props => props.direction || 'row'};
  flex-wrap: ${props => props.wrap || 'nowrap'};
`;

export const Grid = styled.div`
  display: grid;
  grid-template-columns: ${props => props.columns || '1fr'};
  gap: ${props => props.gap || props.theme.spacing[4]};
`;

export const Text = styled.span`
  font-size: ${props => props.size || props.theme.fontSizes.base};
  font-weight: ${props => props.weight || props.theme.fontWeights.normal};
  color: ${props => props.color || props.theme.colors.gray[800]};
  line-height: ${props => props.lineHeight || props.theme.lineHeights.normal};
`;

export const Heading = styled.h1`
  font-size: ${props => {
    switch (props.level) {
      case 1: return props.theme.fontSizes['4xl'];
      case 2: return props.theme.fontSizes['3xl'];
      case 3: return props.theme.fontSizes['2xl'];
      case 4: return props.theme.fontSizes.xl;
      case 5: return props.theme.fontSizes.lg;
      case 6: return props.theme.fontSizes.base;
      default: return props.theme.fontSizes['2xl'];
    }
  }};
  font-weight: ${props => props.weight || props.theme.fontWeights.bold};
  color: ${props => props.color || props.theme.colors.gray[900]};
  line-height: ${props => props.theme.lineHeights.tight};
  margin-bottom: ${props => props.mb || '0'};
`;
