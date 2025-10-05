-- ================================
-- CREATE GUEST USER FOR FRONTEND TESTING
-- ================================

-- Use auth service database
USE auth_service_db;

-- Create the guest user with hashed password for 'arya@123'
INSERT INTO users (
    email, 
    password, 
    first_name, 
    last_name, 
    phone,
    date_of_birth,
    is_active, 
    is_email_verified, 
    created_at,
    last_login
) VALUES (
    'arya@gmail.com', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- bcrypt hash for 'arya@123'
    'Arya', 
    'Demo',
    '+1234567890',
    '1995-01-15',
    TRUE, 
    TRUE, 
    NOW(),
    NOW()
);

-- Get the user ID for subsequent inserts
SET @user_id = LAST_INSERT_ID();

-- ================================
-- ADD SAMPLE GOAL CATEGORIES
-- ================================
USE goal_service_db;

INSERT INTO goal_categories (name, description, icon_name, color_code, is_default, sort_order) VALUES
('Emergency Fund', 'Emergency savings for unexpected expenses', 'shield', '#EF4444', TRUE, 1),
('Vacation', 'Travel and vacation savings', 'plane', '#3B82F6', TRUE, 2),
('Home', 'Home purchase, renovation, and maintenance', 'home', '#10B981', TRUE, 3),
('Education', 'Learning, courses, and skill development', 'book', '#8B5CF6', TRUE, 4),
('Investment', 'Investment and retirement planning', 'trending-up', '#F59E0B', TRUE, 5),
('Transportation', 'Car purchase, maintenance, and transport', 'car', '#EC4899', TRUE, 6);

-- ================================
-- ADD SAMPLE GOALS FOR GUEST USER
-- ================================
INSERT INTO goals (
    user_id, 
    title, 
    description, 
    target_amount, 
    current_amount, 
    category_id, 
    priority_level, 
    target_date, 
    start_date, 
    status,
    motivation_note,
    created_at
) VALUES
(@user_id, 'Emergency Fund', 'Save 6 months of expenses for emergencies', 15000.00, 8500.00, 1, 'HIGH', '2024-12-31', '2024-01-01', 'ACTIVE', 'Financial security is my top priority', '2024-01-01 10:00:00'),
(@user_id, 'Europe Vacation', 'Dream trip to explore European cities', 5000.00, 2250.00, 2, 'MEDIUM', '2024-08-15', '2024-02-01', 'ACTIVE', 'I deserve this amazing vacation!', '2024-02-01 14:30:00'),
(@user_id, 'Car Down Payment', 'Save for reliable transportation', 8000.00, 6400.00, 6, 'HIGH', '2024-10-01', '2024-01-15', 'ACTIVE', 'Need a dependable car for work', '2024-01-15 09:15:00'),
(@user_id, 'Home Renovation', 'Kitchen and bathroom upgrade', 12000.00, 12000.00, 3, 'MEDIUM', '2024-06-30', '2024-01-01', 'COMPLETED', 'Creating my dream home space', '2024-01-01 16:45:00'),
(@user_id, 'Online Course Fund', 'Professional development courses', 2000.00, 800.00, 4, 'LOW', '2024-11-30', '2024-03-01', 'ACTIVE', 'Investing in my future career', '2024-03-01 11:20:00');

-- ================================
-- ADD TRANSACTION CATEGORIES
-- ================================
USE user_finance_db;

INSERT INTO transaction_categories (name, description, category_type, color_code, icon_name, is_default, sort_order) VALUES
('Salary', 'Monthly salary and regular income', 'INCOME', '#22C55E', 'briefcase', TRUE, 1),
('Freelance', 'Freelance work and side income', 'INCOME', '#10B981', 'laptop', TRUE, 2),
('Investment Returns', 'Dividends, interest, and investment gains', 'INCOME', '#059669', 'trending-up', TRUE, 3),
('Food & Dining', 'Restaurants, groceries, and food delivery', 'EXPENSE', '#EF4444', 'utensils', TRUE, 4),
('Transportation', 'Gas, public transport, car maintenance', 'EXPENSE', '#F59E0B', 'car', TRUE, 5),
('Housing', 'Rent, mortgage, utilities, maintenance', 'EXPENSE', '#8B5CF6', 'home', TRUE, 6),
('Entertainment', 'Movies, games, hobbies, subscriptions', 'EXPENSE', '#EC4899', 'gamepad-2', TRUE, 7),
('Shopping', 'Clothes, electronics, miscellaneous', 'EXPENSE', '#06B6D4', 'shopping-bag', TRUE, 8),
('Utilities', 'Electricity, water, internet, phone', 'EXPENSE', '#84CC16', 'zap', TRUE, 9),
('Healthcare', 'Medical expenses, insurance, pharmacy', 'EXPENSE', '#F97316', 'heart', TRUE, 10),
('Education', 'Courses, books, training materials', 'EXPENSE', '#6366F1', 'book', TRUE, 11);

-- ================================
-- ADD SAMPLE TRANSACTIONS
-- ================================
INSERT INTO transactions (
    user_id, 
    amount, 
    description, 
    transaction_type, 
    category_id, 
    transaction_date, 
    account_type, 
    location,
    notes,
    is_recurring,
    created_at
) VALUES
-- Income transactions
(@user_id, 3500.00, 'Monthly Salary - January', 'INCOME', 1, '2024-01-15', 'BANK', 'Direct Deposit', 'Regular monthly income', TRUE, '2024-01-15 09:00:00'),
(@user_id, 800.00, 'Freelance Web Development', 'INCOME', 2, '2024-01-12', 'DIGITAL_WALLET', 'Remote Work', 'Client project completion', FALSE, '2024-01-12 16:30:00'),
(@user_id, 150.00, 'Investment Dividends', 'INCOME', 3, '2024-01-10', 'BANK', 'Investment Account', 'Quarterly dividend payment', FALSE, '2024-01-10 10:15:00'),

-- Expense transactions
(@user_id, -1200.00, 'Monthly Rent Payment', 'EXPENSE', 6, '2024-01-01', 'BANK', 'Apartment Complex', 'Monthly rent for January', TRUE, '2024-01-01 08:00:00'),
(@user_id, -350.00, 'Weekly Grocery Shopping', 'EXPENSE', 4, '2024-01-14', 'CREDIT_CARD', 'SuperMart', 'Weekly groceries and household items', FALSE, '2024-01-14 18:45:00'),
(@user_id, -85.00, 'Gas Station Fill-up', 'EXPENSE', 5, '2024-01-13', 'CREDIT_CARD', 'Shell Station', 'Fuel for car', FALSE, '2024-01-13 07:30:00'),
(@user_id, -120.00, 'Electricity Bill', 'EXPENSE', 9, '2024-01-10', 'BANK', 'Utility Company', 'Monthly electricity bill', TRUE, '2024-01-10 14:20:00'),
(@user_id, -45.00, 'Coffee Shop', 'EXPENSE', 7, '2024-01-09', 'CREDIT_CARD', 'Starbucks', 'Morning coffee and pastry', FALSE, '2024-01-09 08:15:00'),
(@user_id, -200.00, 'Online Shopping', 'EXPENSE', 8, '2024-01-08', 'CREDIT_CARD', 'Amazon', 'Clothes and electronics', FALSE, '2024-01-08 20:30:00'),
(@user_id, -75.00, 'Movie Night', 'EXPENSE', 7, '2024-01-07', 'CREDIT_CARD', 'Cinema Complex', 'Movie tickets and snacks', FALSE, '2024-01-07 19:00:00'),
(@user_id, -60.00, 'Internet Bill', 'EXPENSE', 9, '2024-01-05', 'BANK', 'ISP Provider', 'Monthly internet service', TRUE, '2024-01-05 12:00:00'),
(@user_id, -25.00, 'Parking Fee', 'EXPENSE', 5, '2024-01-04', 'CASH', 'Downtown Parking', 'Parking for shopping trip', FALSE, '2024-01-04 15:45:00'),
(@user_id, -180.00, 'Gym Membership', 'EXPENSE', 10, '2024-01-03', 'BANK', 'Fitness Center', 'Monthly gym membership', TRUE, '2024-01-03 10:30:00'),
(@user_id, -90.00, 'Phone Bill', 'EXPENSE', 9, '2024-01-02', 'BANK', 'Mobile Carrier', 'Monthly phone service', TRUE, '2024-01-02 11:15:00');

-- ================================
-- ADD USER BUDGET CATEGORIES
-- ================================
INSERT INTO user_budget_categories (user_id, category_id, monthly_budget, alert_threshold) VALUES
(@user_id, 4, 500.00, 80.00),  -- Food & Dining
(@user_id, 5, 200.00, 75.00),  -- Transportation
(@user_id, 6, 1300.00, 90.00), -- Housing
(@user_id, 7, 150.00, 70.00),  -- Entertainment
(@user_id, 8, 300.00, 80.00),  -- Shopping
(@user_id, 9, 250.00, 85.00),  -- Utilities
(@user_id, 10, 200.00, 75.00), -- Healthcare
(@user_id, 11, 100.00, 60.00); -- Education

-- ================================
-- ADD SAMPLE ANALYTICS DATA
-- ================================
USE insight_service_db;

INSERT INTO spending_analytics (
    user_id, 
    category_id, 
    analysis_period, 
    period_start_date, 
    period_end_date, 
    total_amount, 
    transaction_count, 
    average_transaction, 
    trend_direction, 
    trend_percentage,
    calculated_at
) VALUES
(@user_id, 4, 'MONTHLY', '2024-01-01', '2024-01-31', 350.00, 3, 116.67, 'STABLE', 2.50, NOW()),
(@user_id, 5, 'MONTHLY', '2024-01-01', '2024-01-31', 110.00, 2, 55.00, 'DECREASING', -5.00, NOW()),
(@user_id, 6, 'MONTHLY', '2024-01-01', '2024-01-31', 1200.00, 1, 1200.00, 'STABLE', 0.00, NOW()),
(@user_id, 7, 'MONTHLY', '2024-01-01', '2024-01-31', 120.00, 2, 60.00, 'INCREASING', 15.00, NOW()),
(@user_id, 8, 'MONTHLY', '2024-01-01', '2024-01-31', 200.00, 1, 200.00, 'STABLE', 0.00, NOW()),
(@user_id, 9, 'MONTHLY', '2024-01-01', '2024-01-31', 230.00, 3, 76.67, 'STABLE', 1.00, NOW());

-- ================================
-- ADD GOAL PREDICTIONS
-- ================================
INSERT INTO goal_predictions (
    goal_id, 
    user_id, 
    predicted_completion_date, 
    predicted_final_amount, 
    confidence_score, 
    required_monthly_savings, 
    current_monthly_average, 
    probability_of_success, 
    recommended_action,
    created_at
) VALUES
(1, @user_id, '2024-11-15', 15000.00, 0.85, 650.00, 700.00, 90.00, 'ON_TRACK', NOW()),
(2, @user_id, '2024-08-10', 5000.00, 0.75, 458.33, 400.00, 75.00, 'INCREASE_SAVINGS', NOW()),
(3, @user_id, '2024-09-15', 8000.00, 0.92, 200.00, 250.00, 95.00, 'ON_TRACK', NOW()),
(5, @user_id, '2024-12-20', 2000.00, 0.60, 133.33, 100.00, 65.00, 'INCREASE_SAVINGS', NOW());

-- ================================
-- ADD USER RECOMMENDATIONS
-- ================================
INSERT INTO user_recommendations (
    user_id, 
    recommendation_type, 
    title, 
    description, 
    detailed_explanation,
    impact_amount, 
    priority_score, 
    difficulty_level,
    success_rate,
    created_at
) VALUES
(@user_id, 'SPENDING_REDUCTION', 'Reduce Dining Out Expenses', 'Cut restaurant spending by 20% to save more', 'You spent $350 on food last month. Reducing dining out by 20% could save you $70 monthly, adding $840 annually to your savings.', 70.00, 8, 'EASY', 85.00, NOW()),
(@user_id, 'SAVINGS_INCREASE', 'Automate Emergency Fund Savings', 'Set up automatic transfer for emergency fund', 'Automatically transfer $100 weekly to your emergency fund to reach your goal faster and build consistent saving habits.', 400.00, 9, 'EASY', 90.00, NOW()),
(@user_id, 'GOAL_ADJUSTMENT', 'Accelerate Vacation Savings', 'Increase monthly vacation fund contribution', 'Your Europe vacation goal needs $458/month. Consider increasing to $500/month to ensure you reach your target by August.', 42.00, 7, 'MEDIUM', 80.00, NOW()),
(@user_id, 'BUDGET_OPTIMIZATION', 'Review Entertainment Budget', 'Optimize entertainment spending allocation', 'You have $30 remaining in entertainment budget. Consider reallocating some funds to your vacation goal for better progress.', 30.00, 6, 'EASY', 75.00, NOW());

-- ================================
-- ADD SAMPLE NOTIFICATIONS
-- ================================
INSERT INTO user_notifications (
    user_id, 
    notification_type, 
    title, 
    message, 
    priority_level, 
    delivery_method,
    is_read,
    created_at
) VALUES
(@user_id, 'GOAL_DEADLINE', 'Emergency Fund Progress', 'Great job! You\'re 56% towards your emergency fund goal.', 'MEDIUM', 'IN_APP', FALSE, NOW()),
(@user_id, 'MILESTONE_ACHIEVED', 'Car Fund Milestone', 'Congratulations! You\'ve reached 80% of your car down payment goal.', 'HIGH', 'ALL', FALSE, NOW()),
(@user_id, 'SPENDING_ALERT', 'Monthly Budget Update', 'You\'ve used 70% of your food budget this month.', 'LOW', 'IN_APP', TRUE, NOW());

-- ================================
-- VERIFICATION QUERIES
-- ================================
SELECT 'User created successfully:' as status, email, first_name, last_name FROM auth_service_db.users WHERE email = 'arya@gmail.com';
SELECT 'Goals created:' as status, COUNT(*) as goal_count FROM goal_service_db.goals WHERE user_id = @user_id;
SELECT 'Transactions created:' as status, COUNT(*) as transaction_count FROM user_finance_db.transactions WHERE user_id = @user_id;
SELECT 'Analytics created:' as status, COUNT(*) as analytics_count FROM insight_service_db.spending_analytics WHERE user_id = @user_id;

-- ================================
-- SUCCESS MESSAGE
-- ================================
SELECT 'Database setup complete! Guest user arya@gmail.com created with sample data.' as message;
