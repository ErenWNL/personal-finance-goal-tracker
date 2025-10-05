# Personal Finance Goal Tracker - Frontend

A modern, responsive React.js frontend for the Personal Finance Goal Tracker system. Built with JavaScript, Redux, styled-components, and beautiful data visualizations.

## 🚀 Features

### 🔐 Authentication
- **Secure Login & Registration** - JWT-based authentication with form validation
- **Password Strength Indicator** - Real-time password strength feedback
- **Protected Routes** - Route guards for authenticated users
- **Persistent Sessions** - Automatic login state management

### 📊 Dashboard
- **Financial Overview** - Real-time summary of income, expenses, and balance
- **Interactive Charts** - Beautiful visualizations using Recharts
- **Recent Activity** - Latest transactions and goal updates
- **Quick Actions** - Easy access to common tasks

### 🎯 Goals Management
- **Create & Edit Goals** - Comprehensive goal creation with categories and priorities
- **Progress Tracking** - Visual progress bars and completion percentages
- **Goal Categories** - Organized by Emergency Fund, Vacation, Home, etc.
- **Target Dates** - Timeline tracking for goal achievement
- **Status Management** - Active, Completed, and Paused goal states

### 💳 Transactions
- **Transaction History** - Complete list of income and expenses
- **Category Filtering** - Filter by transaction type and category
- **Search Functionality** - Find specific transactions quickly
- **Summary Statistics** - Total income, expenses, and net balance

### 📈 Insights & Analytics
- **Spending Trends** - Monthly income vs expenses charts
- **Category Breakdown** - Pie charts showing spending distribution
- **Goal Progress** - Bar charts tracking goal completion
- **Financial Insights** - AI-powered recommendations and alerts
- **Savings Analysis** - Track your savings patterns over time

### 👤 Profile Management
- **User Profile** - Edit personal information and preferences
- **Account Statistics** - Overview of goals, transactions, and achievements
- **Settings** - Manage account preferences and security

## 🛠️ Technology Stack

### Core Technologies
- **React 18** - Modern React with hooks and functional components
- **JavaScript (ES6+)** - No TypeScript, pure JavaScript implementation
- **React Router v6** - Client-side routing and navigation
- **Redux Toolkit** - State management with modern Redux patterns
- **React Redux** - React bindings for Redux

### Styling & UI
- **Styled Components** - CSS-in-JS for component styling
- **Framer Motion** - Smooth animations and transitions
- **Responsive Design** - Mobile-first approach with breakpoints
- **Custom Theme System** - Consistent design tokens and colors

### Data Visualization
- **Recharts** - Beautiful, responsive charts and graphs
- **Interactive Charts** - Line, Area, Pie, and Bar charts
- **Real-time Updates** - Dynamic data visualization

### Additional Libraries
- **Axios** - HTTP client for API communication
- **React Hot Toast** - Beautiful toast notifications
- **Lucide React** - Modern icon library
- **Date-fns** - Date manipulation and formatting

## 📁 Project Structure

```
frontend/
├── public/
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Auth/           # Authentication components
│   │   ├── Goals/          # Goal-related components
│   │   └── Layout/         # Layout components (Sidebar, Header)
│   ├── pages/              # Page components
│   │   ├── Auth/           # Login, Register pages
│   │   ├── Dashboard/      # Dashboard page
│   │   ├── Goals/          # Goals management page
│   │   ├── Transactions/   # Transactions page
│   │   ├── Insights/       # Analytics and insights page
│   │   ├── Profile/        # User profile page
│   │   └── NotFound/       # 404 error page
│   ├── services/           # API services
│   │   └── api.js          # Axios configuration and API calls
│   ├── store/              # Redux store configuration
│   │   ├── store.js        # Store configuration
│   │   └── slices/         # Redux slices
│   │       ├── authSlice.js
│   │       ├── goalsSlice.js
│   │       ├── transactionsSlice.js
│   │       └── insightsSlice.js
│   ├── styles/             # Styling and theme
│   │   ├── theme.js        # Design system tokens
│   │   └── GlobalStyles.js # Global styles and components
│   ├── App.js              # Main application component
│   └── index.js            # Application entry point
├── package.json            # Dependencies and scripts
└── README.md              # This file
```

## 🚦 Getting Started

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- Backend services running (API Gateway on port 8081)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd personal-finance-goal-tracker/frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   # Create .env file (optional)
   echo "REACT_APP_API_URL=http://localhost:8081" > .env
   ```

4. **Start the development server**
   ```bash
   npm start
   ```

5. **Open your browser**
   Navigate to `http://localhost:3000`

### Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run test suite
- `npm run eject` - Eject from Create React App (not recommended)

## 🔧 Configuration

### API Configuration
The frontend is configured to communicate with the backend API Gateway on `http://localhost:8081`. This is set via:
- Proxy in `package.json` for development
- Environment variable `REACT_APP_API_URL` for production

### Theme Customization
Customize the application theme by modifying `src/styles/theme.js`:

```javascript
export const theme = {
  colors: {
    primary: { /* Primary color palette */ },
    secondary: { /* Secondary color palette */ },
    // ... other color definitions
  },
  fonts: { /* Font definitions */ },
  spacing: { /* Spacing scale */ },
  // ... other theme tokens
};
```

## 📱 Responsive Design

The application is fully responsive with breakpoints:
- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

Key responsive features:
- Collapsible sidebar on mobile
- Responsive grid layouts
- Touch-friendly interactions
- Optimized chart displays

## 🎨 Design System

### Color Palette
- **Primary**: Blue tones for main actions and branding
- **Secondary**: Purple tones for accents and highlights
- **Success**: Green for positive actions and income
- **Warning**: Yellow/Orange for alerts and notifications
- **Error**: Red for errors and expenses
- **Gray**: Neutral tones for text and backgrounds

### Typography
- **Primary Font**: Inter (Google Fonts)
- **Monospace**: JetBrains Mono for code and numbers
- **Scale**: Modular scale from xs (12px) to 6xl (60px)

### Components
All components follow consistent patterns:
- Styled with styled-components
- Responsive by default
- Accessible with proper ARIA labels
- Consistent spacing and typography

## 🔌 API Integration

### Authentication Flow
1. User submits login credentials
2. Frontend sends request to `/auth/login`
3. Backend returns JWT token and user data
4. Token stored in localStorage
5. Token included in subsequent API requests

### Data Flow
1. **Redux Actions** - Dispatch async thunks for API calls
2. **API Service** - Centralized Axios configuration
3. **State Updates** - Redux slices handle response data
4. **Component Updates** - React components re-render with new data

### Error Handling
- Global error interceptor in Axios
- Toast notifications for user feedback
- Graceful fallbacks for failed requests
- Automatic token refresh handling

## 🚀 Deployment

### Build for Production
```bash
npm run build
```

### Deploy to Static Hosting
The built files in the `build/` directory can be deployed to:
- Netlify
- Vercel
- AWS S3 + CloudFront
- GitHub Pages
- Any static file server

### Environment Variables
Set the following environment variables for production:
- `REACT_APP_API_URL` - Backend API URL

## 🧪 Testing

### Running Tests
```bash
npm test
```

### Test Structure
- Unit tests for components
- Integration tests for Redux slices
- API service tests
- End-to-end tests (optional)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Check the documentation
- Review existing issues
- Create a new issue with detailed information

---

Built with ❤️ using React, Redux, and modern web technologies.