-- Initialize all required databases for Personal Finance Goal Tracker

-- Create Authentication Service Database
CREATE DATABASE IF NOT EXISTS auth_service_db;
USE auth_service_db;

-- Create User Finance Service Database
CREATE DATABASE IF NOT EXISTS user_finance_db;
USE user_finance_db;

-- Create Goal Service Database
CREATE DATABASE IF NOT EXISTS goal_service_db;
USE goal_service_db;

-- Create Insight Service Database
CREATE DATABASE IF NOT EXISTS insight_service_db;
USE insight_service_db;

-- Grant all privileges to root user
GRANT ALL PRIVILEGES ON auth_service_db.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON user_finance_db.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON goal_service_db.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON insight_service_db.* TO 'root'@'%';
FLUSH PRIVILEGES;
