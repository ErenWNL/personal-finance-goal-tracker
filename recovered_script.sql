DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3),
    CONSTRAINT chk_future_date CHECK (transaction_date <= CURDATE() + INTERVAL 7 DAY), -- Allow future dates within 1 week
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
USE user_finance_db;
ALTER TABLE transactions DROP CONSTRAINT chk_future_date;
USE user_finance_db;
ALTER TABLE transactions DROP CONSTRAINT chk_future_date;
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3)
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3)
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3)
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3)
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3)
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3),
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
CREATE TABLE recurring_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL, -- NULL means indefinite
    next_due_date DATE NOT NULL,
    goal_id BIGINT NULL,
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    auto_create BOOLEAN DEFAULT FALSE, -- Auto-create transactions
    is_active BOOLEAN DEFAULT TRUE,
    last_created_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_recurring_amount CHECK (amount > 0),
    CONSTRAINT chk_end_after_start CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_template_name_length CHECK (CHAR_LENGTH(template_name) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_next_due_date (next_due_date),
    INDEX idx_is_active (is_active),
    INDEX idx_frequency (frequency),
    INDEX idx_auto_create (auto_create)
);
CREATE TABLE transaction_imports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    total_rows INT NOT NULL,
    successful_imports INT DEFAULT 0,
    failed_imports INT DEFAULT 0,
    duplicate_skipped INT DEFAULT 0,
    import_status ENUM('PROCESSING', 'COMPLETED', 'FAILED', 'PARTIAL') DEFAULT 'PROCESSING',
    error_details JSON NULL, -- Store import errors
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_import_status (import_status),
    INDEX idx_imported_at (imported_at)
);
DROP DATABASE IF EXISTS goal_service_db;
CREATE DATABASE goal_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE goal_service_db;
CREATE TABLE goal_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    icon_name VARCHAR(50) DEFAULT 'target',
    color_code VARCHAR(7) DEFAULT '#3B82F6',
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_goal_category_name CHECK (CHAR_LENGTH(name) >= 2),
    CONSTRAINT chk_goal_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    
    -- Indexes
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_sort_order (sort_order),
    INDEX idx_is_active (is_active)
);
CREATE TABLE goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    target_amount DECIMAL(15, 2) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0.00,
    category_id BIGINT NOT NULL,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    target_date DATE NULL, -- Can be open-ended
    start_date DATE DEFAULT '2024-01-01',
    status ENUM('ACTIVE', 'COMPLETED', 'PAUSED', 'CANCELLED') DEFAULT 'ACTIVE',
    completion_percentage DECIMAL(5, 2) GENERATED ALWAYS AS (
        CASE 
            WHEN target_amount > 0 THEN LEAST(100.00, (current_amount / target_amount) * 100)
            ELSE 0.00 
        END
    ) STORED, -- Auto-calculated field
    is_shared BOOLEAN DEFAULT FALSE,
    motivation_note TEXT NULL, -- User's motivation for the goal
    reward_description TEXT NULL, -- What they'll do when achieved
    image_url VARCHAR(500) NULL, -- Goal inspiration image
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES goal_categories(id),
    
    -- Constraints
    CONSTRAINT chk_target_amount CHECK (target_amount > 0),
    CONSTRAINT chk_current_amount CHECK (current_amount >= 0),
    CONSTRAINT chk_title_length CHECK (CHAR_LENGTH(title) >= 3),
    CONSTRAINT chk_target_after_start CHECK (target_date IS NULL OR target_date >= start_date),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_target_date (target_date),
    INDEX idx_priority_level (priority_level),
    INDEX idx_completion_percentage (completion_percentage),
    INDEX idx_created_at (created_at),
    INDEX idx_is_shared (is_shared),
    -- Composite indexes
    INDEX idx_user_status (user_id, status),
    INDEX idx_user_priority (user_id, priority_level)
);
CREATE TABLE goal_progress_snapshots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    progress_percentage DECIMAL(5, 2) NOT NULL,
    snapshot_date DATE NOT NULL,
    snapshot_type ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'MILESTONE', 'MANUAL') DEFAULT 'DAILY',
    transaction_id BIGINT NULL, -- Track which transaction caused the change
    amount_change DECIMAL(15, 2) DEFAULT 0.00, -- Change from previous snapshot
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_snapshot_amount CHECK (amount >= 0),
    CONSTRAINT chk_snapshot_percentage CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    -- Unique constraint - one snapshot per goal per date per type
    UNIQUE KEY unique_goal_snapshot (goal_id, snapshot_date, snapshot_type),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_snapshot_date (snapshot_date),
    INDEX idx_snapshot_type (snapshot_type),
    INDEX idx_progress_percentage (progress_percentage),
    INDEX idx_created_at (created_at)
);
CREATE TABLE goal_milestones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    milestone_name VARCHAR(200) NOT NULL,
    target_percentage DECIMAL(5, 2) NOT NULL, -- 25.00 for 25%
    target_amount DECIMAL(15, 2) NOT NULL,
    is_achieved BOOLEAN DEFAULT FALSE,
    achieved_at TIMESTAMP NULL,
    reward_description TEXT NULL,
    is_automatic BOOLEAN DEFAULT TRUE, -- System-generated vs user-defined
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_milestone_percentage CHECK (target_percentage > 0 AND target_percentage <= 100),
    CONSTRAINT chk_milestone_amount CHECK (target_amount > 0),
    CONSTRAINT chk_milestone_name_length CHECK (CHAR_LENGTH(milestone_name) >= 3),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_target_percentage (target_percentage),
    INDEX idx_is_achieved (is_achieved),
    INDEX idx_is_automatic (is_automatic),
    INDEX idx_achieved_at (achieved_at)
);
CREATE TABLE goal_sharing (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    owner_user_id BIGINT NOT NULL, -- Goal owner
    shared_with_email VARCHAR(255) NOT NULL, -- Partner email (may not be registered user)
    shared_with_user_id BIGINT NULL, -- Partner user ID if registered
    permission_level ENUM('VIEW_ONLY', 'VIEW_COMMENT', 'VIEW_ENCOURAGE') DEFAULT 'VIEW_ONLY',
    is_active BOOLEAN DEFAULT TRUE,
    invitation_token VARCHAR(255) NULL, -- For email invitations
    invitation_sent_at TIMESTAMP NULL,
    invitation_accepted_at TIMESTAMP NULL,
    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Unique constraint
    UNIQUE KEY unique_goal_sharing (goal_id, shared_with_email),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_owner_user_id (owner_user_id),
    INDEX idx_shared_with_user_id (shared_with_user_id),
    INDEX idx_shared_with_email (shared_with_email),
    INDEX idx_is_active (is_active),
    INDEX idx_invitation_token (invitation_token)
);
CREATE TABLE goal_comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL, -- Commenter user ID
    user_name VARCHAR(200) NOT NULL, -- Display name for comment
    comment_text TEXT NOT NULL,
    comment_type ENUM('NOTE', 'ENCOURAGEMENT', 'REMINDER', 'MILESTONE', 'PROGRESS_UPDATE') DEFAULT 'NOTE',
    is_private BOOLEAN DEFAULT FALSE, -- Only goal owner can see
    parent_comment_id BIGINT NULL, -- For threaded comments
    like_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES goal_comments(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_comment_text_length CHECK (CHAR_LENGTH(comment_text) >= 1),
    CONSTRAINT chk_like_count CHECK (like_count >= 0),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_user_id (user_id),
    INDEX idx_comment_type (comment_type),
    INDEX idx_is_private (is_private),
    INDEX idx_parent_comment_id (parent_comment_id),
    INDEX idx_created_at (created_at)
);
DROP DATABASE IF EXISTS insight_service_db;
CREATE DATABASE insight_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE insight_service_db;
CREATE TABLE spending_analytics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    category_id BIGINT NOT NULL, -- Cross-service reference to finance service
    analysis_period ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    transaction_count INT DEFAULT 0,
    average_transaction DECIMAL(15, 2) DEFAULT 0.00,
    median_transaction DECIMAL(15, 2) DEFAULT 0.00,
    highest_transaction DECIMAL(15, 2) DEFAULT 0.00,
    lowest_transaction DECIMAL(15, 2) DEFAULT 0.00,
    trend_direction ENUM('INCREASING', 'DECREASING', 'STABLE') DEFAULT 'STABLE',
    trend_percentage DECIMAL(5, 2) DEFAULT 0.00, -- -50.00 to +50.00
    variance_from_budget DECIMAL(15, 2) DEFAULT 0.00, -- Over/under budget
    budget_utilization_percentage DECIMAL(5, 2) DEFAULT 0.00, -- % of budget used
    seasonal_factor DECIMAL(5, 2) DEFAULT 1.00, -- Seasonal adjustment
    anomaly_score DECIMAL(5, 2) DEFAULT 0.00, -- 0-100, higher = more unusual
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_transaction_count CHECK (transaction_count >= 0),
    CONSTRAINT chk_period_dates CHECK (period_end_date >= period_start_date),
    CONSTRAINT chk_trend_percentage CHECK (trend_percentage BETWEEN -100.00 AND 100.00),
    CONSTRAINT chk_anomaly_score CHECK (anomaly_score BETWEEN 0.00 AND 100.00),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category_period (user_id, category_id, analysis_period, period_start_date),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_analysis_period (analysis_period),
    INDEX idx_period_dates (period_start_date, period_end_date),
    INDEX idx_trend_direction (trend_direction),
    INDEX idx_anomaly_score (anomaly_score),
    INDEX idx_calculated_at (calculated_at),
    -- Composite indexes
    INDEX idx_user_period (user_id, analysis_period),
    INDEX idx_user_category (user_id, category_id)
);
CREATE TABLE goal_predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL, -- Cross-service reference to goal service
    user_id BIGINT NOT NULL,
    predicted_completion_date DATE NULL, -- NULL if unlikely to complete
    predicted_final_amount DECIMAL(15, 2) NULL,
    confidence_score DECIMAL(3, 2) NOT NULL, -- 0.00 to 1.00
    prediction_method ENUM('LINEAR_REGRESSION', 'TREND_ANALYSIS', 'SEASONAL_ADJUSTED', 'ML_MODEL') DEFAULT 'LINEAR_REGRESSION',
    required_monthly_savings DECIMAL(15, 2) NOT NULL,
    current_monthly_average DECIMAL(15, 2) DEFAULT 0.00,
    savings_rate_needed DECIMAL(5, 2) DEFAULT 0.00, -- % of income needed
    probability_of_success DECIMAL(5, 2) DEFAULT 0.00, -- 0-100%
    days_to_completion INT NULL, -- Estimated days remaining
    months_behind_schedule INT DEFAULT 0, -- Negative if ahead
    recommended_action ENUM('INCREASE_SAVINGS', 'EXTEND_DEADLINE', 'REDUCE_TARGET', 'ON_TRACK', 'ADJUST_SPENDING') NULL,
    risk_factors JSON NULL, -- Array of risk factors
    prediction_accuracy_history DECIMAL(5, 2) DEFAULT 0.00, -- Historical accuracy of predictions
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_confidence_score CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    CONSTRAINT chk_probability_success CHECK (probability_of_success BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_required_savings CHECK (required_monthly_savings >= 0),
    
    -- Unique constraint
    UNIQUE KEY unique_goal_prediction (goal_id),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_user_id (user_id),
    INDEX idx_predicted_completion_date (predicted_completion_date),
    INDEX idx_confidence_score (confidence_score),
    INDEX idx_probability_of_success (probability_of_success),
    INDEX idx_prediction_method (prediction_method),
    INDEX idx_last_updated (last_updated)
);
CREATE TABLE user_recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recommendation_type ENUM('SPENDING_REDUCTION', 'SAVINGS_INCREASE', 'GOAL_ADJUSTMENT', 'BUDGET_OPTIMIZATION', 'CATEGORY_ANALYSIS', 'EMERGENCY_FUND', 'DEBT_PAYOFF') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    detailed_explanation TEXT NULL,
    action_items JSON NULL, -- Array of specific actions
    impact_amount DECIMAL(15, 2) NULL, -- Potential savings/impact
    impact_description VARCHAR(500) NULL,
    priority_score INT DEFAULT 5, -- 1-10 scale
    difficulty_level ENUM('EASY', 'MEDIUM', 'HARD') DEFAULT 'MEDIUM',
    estimated_time_to_implement VARCHAR(100) NULL, -- "2 weeks", "1 month"
    category_id BIGINT NULL, -- Related category
    goal_id BIGINT NULL, -- Related goal
    data_source JSON NULL, -- What data drove this recommendation
    success_rate DECIMAL(5, 2) DEFAULT 0.00, -- Historical success rate for this type
    is_active BOOLEAN DEFAULT TRUE,
    is_read BOOLEAN DEFAULT FALSE,
    is_applied BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    applied_at TIMESTAMP NULL,
    dismissed_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    feedback_rating TINYINT NULL, -- 1-5 rating from user
    feedback_comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_priority_score CHECK (priority_score BETWEEN 1 AND 10),
    CONSTRAINT chk_success_rate CHECK (success_rate BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_feedback_rating CHECK (feedback_rating IS NULL OR feedback_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_title_length CHECK (CHAR_LENGTH(title) >= 5),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_recommendation_type (recommendation_type),
    INDEX idx_priority_score (priority_score),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_is_active (is_active),
    INDEX idx_is_read (is_read),
    INDEX idx_is_applied (is_applied),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at),
    -- Composite indexes
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_user_priority (user_id, priority_score)
);
CREATE TABLE financial_reports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    report_type ENUM('MONTHLY', 'QUARTERLY', 'YEARLY', 'CUSTOM', 'GOAL_PROGRESS', 'SPENDING_ANALYSIS') NOT NULL,
    report_title VARCHAR(200) NOT NULL,
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    total_income DECIMAL(15, 2) DEFAULT 0.00,
    total_expenses DECIMAL(15, 2) DEFAULT 0.00,
    net_savings DECIMAL(15, 2) DEFAULT 0.00,
    savings_rate DECIMAL(5, 2) DEFAULT 0.00, -- % of income saved
    expense_ratio DECIMAL(5, 2) DEFAULT 0.00, -- % of income spent
    top_expense_category VARCHAR(100) NULL,
    top_expense_amount DECIMAL(15, 2) DEFAULT 0.00,
    goal_progress_summary JSON NULL, -- Summary of all goals progress
    category_breakdown JSON NULL, -- Spending by category
    monthly_trends JSON NULL, -- Month-over-month trends
    insights_summary JSON NULL, -- Key insights and recommendations
    report_data JSON NULL, -- Full detailed report data
    file_path VARCHAR(500) NULL, -- PDF/Excel file location
    file_size_kb INT DEFAULT 0,
    is_scheduled BOOLEAN DEFAULT FALSE, -- Auto-generated report
    generated_by ENUM('USER_REQUEST', 'SCHEDULED', 'API_CALL') DEFAULT 'USER_REQUEST',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL, -- When to auto-delete
    
    -- Constraints
    CONSTRAINT chk_report_period CHECK (report_period_end >= report_period_start),
    CONSTRAINT chk_savings_rate CHECK (savings_rate BETWEEN -100.00 AND 100.00),
    CONSTRAINT chk_expense_ratio CHECK (expense_ratio BETWEEN 0.00 AND 200.00),
    CONSTRAINT chk_file_size CHECK (file_size_kb >= 0),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_report_type (report_type),
    INDEX idx_report_period (report_period_start, report_period_end),
    INDEX idx_generated_at (generated_at),
    INDEX idx_is_scheduled (is_scheduled),
    INDEX idx_expires_at (expires_at)
);
CREATE TABLE user_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    notification_type ENUM('GOAL_DEADLINE', 'BUDGET_EXCEEDED', 'MILESTONE_ACHIEVED', 'SPENDING_ALERT', 'RECOMMENDATION', 'GOAL_SHARED', 'PAYMENT_DUE', 'WEEKLY_SUMMARY') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) NULL, -- Deep link to relevant page
    action_text VARCHAR(100) NULL, -- "View Goal", "Check Budget"
    related_goal_id BIGINT NULL,
    related_category_id BIGINT NULL,
    related_recommendation_id BIGINT NULL,
    data_payload JSON NULL, -- Additional data for the notification
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    is_email_sent BOOLEAN DEFAULT FALSE,
    is_push_sent BOOLEAN DEFAULT FALSE,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    delivery_method ENUM('IN_APP', 'EMAIL', 'PUSH', 'ALL') DEFAULT 'IN_APP',
    scheduled_at TIMESTAMP NULL, -- For delayed notifications
    sent_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL, -- Auto-delete old notifications
    retry_count INT DEFAULT 0,
    last_retry_at TIMESTAMP NULL,
    error_message TEXT NULL, -- If sending failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_retry_count CHECK (retry_count >= 0),
    CONSTRAINT chk_title_length CHECK (CHAR_LENGTH(title) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_is_sent (is_sent),
    INDEX idx_priority_level (priority_level),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_sent_at (sent_at),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at),
    -- Composite indexes
    INDEX idx_user_unread (user_id, is_read),
    INDEX idx_user_type (user_id, notification_type)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3),
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
CREATE TABLE recurring_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL, -- NULL means indefinite
    next_due_date DATE NOT NULL,
    goal_id BIGINT NULL,
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    auto_create BOOLEAN DEFAULT FALSE, -- Auto-create transactions
    is_active BOOLEAN DEFAULT TRUE,
    last_created_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_recurring_amount CHECK (amount > 0),
    CONSTRAINT chk_end_after_start CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_template_name_length CHECK (CHAR_LENGTH(template_name) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_next_due_date (next_due_date),
    INDEX idx_is_active (is_active),
    INDEX idx_frequency (frequency),
    INDEX idx_auto_create (auto_create)
);
CREATE TABLE transaction_imports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    total_rows INT NOT NULL,
    successful_imports INT DEFAULT 0,
    failed_imports INT DEFAULT 0,
    duplicate_skipped INT DEFAULT 0,
    import_status ENUM('PROCESSING', 'COMPLETED', 'FAILED', 'PARTIAL') DEFAULT 'PROCESSING',
    error_details JSON NULL, -- Store import errors
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_import_status (import_status),
    INDEX idx_imported_at (imported_at)
);
DROP DATABASE IF EXISTS goal_service_db;
CREATE DATABASE goal_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE goal_service_db;
CREATE TABLE goal_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    icon_name VARCHAR(50) DEFAULT 'target',
    color_code VARCHAR(7) DEFAULT '#3B82F6',
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_goal_category_name CHECK (CHAR_LENGTH(name) >= 2),
    CONSTRAINT chk_goal_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    
    -- Indexes
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_sort_order (sort_order),
    INDEX idx_is_active (is_active)
);
CREATE TABLE goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    target_amount DECIMAL(15, 2) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0.00,
    category_id BIGINT NOT NULL,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    target_date DATE NULL, -- Can be open-ended
    start_date DATE DEFAULT '2024-01-01',
    status ENUM('ACTIVE', 'COMPLETED', 'PAUSED', 'CANCELLED') DEFAULT 'ACTIVE',
    completion_percentage DECIMAL(5, 2) GENERATED ALWAYS AS (
        CASE 
            WHEN target_amount > 0 THEN LEAST(100.00, (current_amount / target_amount) * 100)
            ELSE 0.00 
        END
    ) STORED, -- Auto-calculated field
    is_shared BOOLEAN DEFAULT FALSE,
    motivation_note TEXT NULL, -- User's motivation for the goal
    reward_description TEXT NULL, -- What they'll do when achieved
    image_url VARCHAR(500) NULL, -- Goal inspiration image
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES goal_categories(id),
    
    -- Constraints
    CONSTRAINT chk_target_amount CHECK (target_amount > 0),
    CONSTRAINT chk_current_amount CHECK (current_amount >= 0),
    CONSTRAINT chk_title_length CHECK (CHAR_LENGTH(title) >= 3),
    CONSTRAINT chk_target_after_start CHECK (target_date IS NULL OR target_date >= start_date),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_target_date (target_date),
    INDEX idx_priority_level (priority_level),
    INDEX idx_completion_percentage (completion_percentage),
    INDEX idx_created_at (created_at),
    INDEX idx_is_shared (is_shared),
    -- Composite indexes
    INDEX idx_user_status (user_id, status),
    INDEX idx_user_priority (user_id, priority_level)
);
CREATE TABLE goal_progress_snapshots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    progress_percentage DECIMAL(5, 2) NOT NULL,
    snapshot_date DATE NOT NULL,
    snapshot_type ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'MILESTONE', 'MANUAL') DEFAULT 'DAILY',
    transaction_id BIGINT NULL, -- Track which transaction caused the change
    amount_change DECIMAL(15, 2) DEFAULT 0.00, -- Change from previous snapshot
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_snapshot_amount CHECK (amount >= 0),
    CONSTRAINT chk_snapshot_percentage CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    -- Unique constraint - one snapshot per goal per date per type
    UNIQUE KEY unique_goal_snapshot (goal_id, snapshot_date, snapshot_type),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_snapshot_date (snapshot_date),
    INDEX idx_snapshot_type (snapshot_type),
    INDEX idx_progress_percentage (progress_percentage),
    INDEX idx_created_at (created_at)
);
CREATE TABLE goal_milestones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    milestone_name VARCHAR(200) NOT NULL,
    target_percentage DECIMAL(5, 2) NOT NULL, -- 25.00 for 25%
    target_amount DECIMAL(15, 2) NOT NULL,
    is_achieved BOOLEAN DEFAULT FALSE,
    achieved_at TIMESTAMP NULL,
    reward_description TEXT NULL,
    is_automatic BOOLEAN DEFAULT TRUE, -- System-generated vs user-defined
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_milestone_percentage CHECK (target_percentage > 0 AND target_percentage <= 100),
    CONSTRAINT chk_milestone_amount CHECK (target_amount > 0),
    CONSTRAINT chk_milestone_name_length CHECK (CHAR_LENGTH(milestone_name) >= 3),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_target_percentage (target_percentage),
    INDEX idx_is_achieved (is_achieved),
    INDEX idx_is_automatic (is_automatic),
    INDEX idx_achieved_at (achieved_at)
);
CREATE TABLE goal_sharing (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    owner_user_id BIGINT NOT NULL, -- Goal owner
    shared_with_email VARCHAR(255) NOT NULL, -- Partner email (may not be registered user)
    shared_with_user_id BIGINT NULL, -- Partner user ID if registered
    permission_level ENUM('VIEW_ONLY', 'VIEW_COMMENT', 'VIEW_ENCOURAGE') DEFAULT 'VIEW_ONLY',
    is_active BOOLEAN DEFAULT TRUE,
    invitation_token VARCHAR(255) NULL, -- For email invitations
    invitation_sent_at TIMESTAMP NULL,
    invitation_accepted_at TIMESTAMP NULL,
    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Unique constraint
    UNIQUE KEY unique_goal_sharing (goal_id, shared_with_email),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_owner_user_id (owner_user_id),
    INDEX idx_shared_with_user_id (shared_with_user_id),
    INDEX idx_shared_with_email (shared_with_email),
    INDEX idx_is_active (is_active),
    INDEX idx_invitation_token (invitation_token)
);
CREATE TABLE goal_comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL, -- Commenter user ID
    user_name VARCHAR(200) NOT NULL, -- Display name for comment
    comment_text TEXT NOT NULL,
    comment_type ENUM('NOTE', 'ENCOURAGEMENT', 'REMINDER', 'MILESTONE', 'PROGRESS_UPDATE') DEFAULT 'NOTE',
    is_private BOOLEAN DEFAULT FALSE, -- Only goal owner can see
    parent_comment_id BIGINT NULL, -- For threaded comments
    like_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES goal_comments(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_comment_text_length CHECK (CHAR_LENGTH(comment_text) >= 1),
    CONSTRAINT chk_like_count CHECK (like_count >= 0),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_user_id (user_id),
    INDEX idx_comment_type (comment_type),
    INDEX idx_is_private (is_private),
    INDEX idx_parent_comment_id (parent_comment_id),
    INDEX idx_created_at (created_at)
);
DROP DATABASE IF EXISTS insight_service_db;
CREATE DATABASE insight_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE insight_service_db;
CREATE TABLE spending_analytics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    category_id BIGINT NOT NULL, -- Cross-service reference to finance service
    analysis_period ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    transaction_count INT DEFAULT 0,
    average_transaction DECIMAL(15, 2) DEFAULT 0.00,
    median_transaction DECIMAL(15, 2) DEFAULT 0.00,
    highest_transaction DECIMAL(15, 2) DEFAULT 0.00,
    lowest_transaction DECIMAL(15, 2) DEFAULT 0.00,
    trend_direction ENUM('INCREASING', 'DECREASING', 'STABLE') DEFAULT 'STABLE',
    trend_percentage DECIMAL(5, 2) DEFAULT 0.00, -- -50.00 to +50.00
    variance_from_budget DECIMAL(15, 2) DEFAULT 0.00, -- Over/under budget
    budget_utilization_percentage DECIMAL(5, 2) DEFAULT 0.00, -- % of budget used
    seasonal_factor DECIMAL(5, 2) DEFAULT 1.00, -- Seasonal adjustment
    anomaly_score DECIMAL(5, 2) DEFAULT 0.00, -- 0-100, higher = more unusual
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_transaction_count CHECK (transaction_count >= 0),
    CONSTRAINT chk_period_dates CHECK (period_end_date >= period_start_date),
    CONSTRAINT chk_trend_percentage CHECK (trend_percentage BETWEEN -100.00 AND 100.00),
    CONSTRAINT chk_anomaly_score CHECK (anomaly_score BETWEEN 0.00 AND 100.00),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category_period (user_id, category_id, analysis_period, period_start_date),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_analysis_period (analysis_period),
    INDEX idx_period_dates (period_start_date, period_end_date),
    INDEX idx_trend_direction (trend_direction),
    INDEX idx_anomaly_score (anomaly_score),
    INDEX idx_calculated_at (calculated_at),
    -- Composite indexes
    INDEX idx_user_period (user_id, analysis_period),
    INDEX idx_user_category (user_id, category_id)
);
CREATE TABLE goal_predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL, -- Cross-service reference to goal service
    user_id BIGINT NOT NULL,
    predicted_completion_date DATE NULL, -- NULL if unlikely to complete
    predicted_final_amount DECIMAL(15, 2) NULL,
    confidence_score DECIMAL(3, 2) NOT NULL, -- 0.00 to 1.00
    prediction_method ENUM('LINEAR_REGRESSION', 'TREND_ANALYSIS', 'SEASONAL_ADJUSTED', 'ML_MODEL') DEFAULT 'LINEAR_REGRESSION',
    required_monthly_savings DECIMAL(15, 2) NOT NULL,
    current_monthly_average DECIMAL(15, 2) DEFAULT 0.00,
    savings_rate_needed DECIMAL(5, 2) DEFAULT 0.00, -- % of income needed
    probability_of_success DECIMAL(5, 2) DEFAULT 0.00, -- 0-100%
    days_to_completion INT NULL, -- Estimated days remaining
    months_behind_schedule INT DEFAULT 0, -- Negative if ahead
    recommended_action ENUM('INCREASE_SAVINGS', 'EXTEND_DEADLINE', 'REDUCE_TARGET', 'ON_TRACK', 'ADJUST_SPENDING') NULL,
    risk_factors JSON NULL, -- Array of risk factors
    prediction_accuracy_history DECIMAL(5, 2) DEFAULT 0.00, -- Historical accuracy of predictions
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_confidence_score CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    CONSTRAINT chk_probability_success CHECK (probability_of_success BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_required_savings CHECK (required_monthly_savings >= 0),
    
    -- Unique constraint
    UNIQUE KEY unique_goal_prediction (goal_id),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_user_id (user_id),
    INDEX idx_predicted_completion_date (predicted_completion_date),
    INDEX idx_confidence_score (confidence_score),
    INDEX idx_probability_of_success (probability_of_success),
    INDEX idx_prediction_method (prediction_method),
    INDEX idx_last_updated (last_updated)
);
CREATE TABLE user_recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recommendation_type ENUM('SPENDING_REDUCTION', 'SAVINGS_INCREASE', 'GOAL_ADJUSTMENT', 'BUDGET_OPTIMIZATION', 'CATEGORY_ANALYSIS', 'EMERGENCY_FUND', 'DEBT_PAYOFF') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    detailed_explanation TEXT NULL,
    action_items JSON NULL, -- Array of specific actions
    impact_amount DECIMAL(15, 2) NULL, -- Potential savings/impact
    impact_description VARCHAR(500) NULL,
    priority_score INT DEFAULT 5, -- 1-10 scale
    difficulty_level ENUM('EASY', 'MEDIUM', 'HARD') DEFAULT 'MEDIUM',
    estimated_time_to_implement VARCHAR(100) NULL, -- "2 weeks", "1 month"
    category_id BIGINT NULL, -- Related category
    goal_id BIGINT NULL, -- Related goal
    data_source JSON NULL, -- What data drove this recommendation
    success_rate DECIMAL(5, 2) DEFAULT 0.00, -- Historical success rate for this type
    is_active BOOLEAN DEFAULT TRUE,
    is_read BOOLEAN DEFAULT FALSE,
    is_applied BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    applied_at TIMESTAMP NULL,
    dismissed_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    feedback_rating TINYINT NULL, -- 1-5 rating from user
    feedback_comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_priority_score CHECK (priority_score BETWEEN 1 AND 10),
    CONSTRAINT chk_success_rate CHECK (success_rate BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_feedback_rating CHECK (feedback_rating IS NULL OR feedback_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_title_length CHECK (CHAR_LENGTH(title) >= 5),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_recommendation_type (recommendation_type),
    INDEX idx_priority_score (priority_score),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_is_active (is_active),
    INDEX idx_is_read (is_read),
    INDEX idx_is_applied (is_applied),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at),
    -- Composite indexes
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_user_priority (user_id, priority_score)
);
CREATE TABLE financial_reports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    report_type ENUM('MONTHLY', 'QUARTERLY', 'YEARLY', 'CUSTOM', 'GOAL_PROGRESS', 'SPENDING_ANALYSIS') NOT NULL,
    report_title VARCHAR(200) NOT NULL,
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    total_income DECIMAL(15, 2) DEFAULT 0.00,
    total_expenses DECIMAL(15, 2) DEFAULT 0.00,
    net_savings DECIMAL(15, 2) DEFAULT 0.00,
    savings_rate DECIMAL(5, 2) DEFAULT 0.00, -- % of income saved
    expense_ratio DECIMAL(5, 2) DEFAULT 0.00, -- % of income spent
    top_expense_category VARCHAR(100) NULL,
    top_expense_amount DECIMAL(15, 2) DEFAULT 0.00,
    goal_progress_summary JSON NULL, -- Summary of all goals progress
    category_breakdown JSON NULL, -- Spending by category
    monthly_trends JSON NULL, -- Month-over-month trends
    insights_summary JSON NULL, -- Key insights and recommendations
    report_data JSON NULL, -- Full detailed report data
    file_path VARCHAR(500) NULL, -- PDF/Excel file location
    file_size_kb INT DEFAULT 0,
    is_scheduled BOOLEAN DEFAULT FALSE, -- Auto-generated report
    generated_by ENUM('USER_REQUEST', 'SCHEDULED', 'API_CALL') DEFAULT 'USER_REQUEST',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL, -- When to auto-delete
    
    -- Constraints
    CONSTRAINT chk_report_period CHECK (report_period_end >= report_period_start),
    CONSTRAINT chk_savings_rate CHECK (savings_rate BETWEEN -100.00 AND 100.00),
    CONSTRAINT chk_expense_ratio CHECK (expense_ratio BETWEEN 0.00 AND 200.00),
    CONSTRAINT chk_file_size CHECK (file_size_kb >= 0),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_report_type (report_type),
    INDEX idx_report_period (report_period_start, report_period_end),
    INDEX idx_generated_at (generated_at),
    INDEX idx_is_scheduled (is_scheduled),
    INDEX idx_expires_at (expires_at)
);
CREATE TABLE user_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    notification_type ENUM('GOAL_DEADLINE', 'BUDGET_EXCEEDED', 'MILESTONE_ACHIEVED', 'SPENDING_ALERT', 'RECOMMENDATION', 'GOAL_SHARED', 'PAYMENT_DUE', 'WEEKLY_SUMMARY') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) NULL, -- Deep link to relevant page
    action_text VARCHAR(100) NULL, -- "View Goal", "Check Budget"
    related_goal_id BIGINT NULL,
    related_category_id BIGINT NULL,
    related_recommendation_id BIGINT NULL,
    data_payload JSON NULL, -- Additional data for the notification
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    is_email_sent BOOLEAN DEFAULT FALSE,
    is_push_sent BOOLEAN DEFAULT FALSE,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    delivery_method ENUM('IN_APP', 'EMAIL', 'PUSH', 'ALL') DEFAULT 'IN_APP',
    scheduled_at TIMESTAMP NULL, -- For delayed notifications
    sent_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL, -- Auto-delete old notifications
    retry_count INT DEFAULT 0,
    last_retry_at TIMESTAMP NULL,
    error_message TEXT NULL, -- If sending failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_retry_count CHECK (retry_count >= 0),
    CONSTRAINT chk_title_length CHECK (CHAR_LENGTH(title) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_is_sent (is_sent),
    INDEX idx_priority_level (priority_level),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_sent_at (sent_at),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at),
    -- Composite indexes
    INDEX idx_user_unread (user_id, is_read),
    INDEX idx_user_type (user_id, notification_type)
);
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    date_of_birth DATE NULL,
    profile_picture_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_created_at (created_at),
    INDEX idx_is_active (is_active),
    INDEX idx_last_login (last_login)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of token
    token_type ENUM('ACCESS', 'REFRESH') DEFAULT 'ACCESS',
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL,
    user_agent VARCHAR(500) NULL, -- For device tracking
    ip_address VARCHAR(45) NULL, -- IPv4/IPv6 support
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    
    -- Unique constraint to prevent duplicate active tokens
    UNIQUE KEY unique_active_token (user_id, token_type, is_revoked)
);
CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_used (is_used)
);
CREATE TABLE user_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    logout_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_last_activity (last_activity)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    keywords JSON NULL, -- Array of keywords for auto-categorization
    color_code VARCHAR(7) DEFAULT '#6B7280', -- Hex color
    icon_name VARCHAR(50) DEFAULT 'dollar-sign',
    is_default BOOLEAN DEFAULT FALSE, -- System default categories
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 2),
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_is_active (is_active),
    INDEX idx_sort_order (sort_order)
);
CREATE TABLE user_budget_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference to auth_service_db.users.id
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(15, 2) DEFAULT 0.00, -- Increased precision for large amounts
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00, -- Alert at 80% of budget
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    CONSTRAINT chk_alert_threshold CHECK (alert_threshold BETWEEN 0 AND 100),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(15, 2) NOT NULL, -- Support large amounts
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goal_service_db.goals.id
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    reference_number VARCHAR(100) NULL, -- Bank reference/check number
    location VARCHAR(200) NULL, -- Where transaction occurred
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NULL,
    tags JSON NULL, -- Flexible tagging system
    notes TEXT NULL,
    receipt_url VARCHAR(500) NULL, -- File storage URL
    is_verified BOOLEAN DEFAULT TRUE, -- For imported transactions
    imported_from VARCHAR(50) NULL, -- CSV, BANK_API, MANUAL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0), -- Prevent zero amounts
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3),
    
    -- Indexes for optimal performance
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_account_type (account_type),
    INDEX idx_is_recurring (is_recurring),
    INDEX idx_created_at (created_at),
    INDEX idx_amount (amount),
    -- Composite indexes for common queries
    INDEX idx_user_date (user_id, transaction_date),
    INDEX idx_user_type (user_id, transaction_type),
    INDEX idx_user_category (user_id, category_id)
);
CREATE TABLE recurring_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL, -- NULL means indefinite
    next_due_date DATE NOT NULL,
    goal_id BIGINT NULL,
    account_type ENUM('CASH', 'BANK', 'CREDIT_CARD', 'DIGITAL_WALLET') DEFAULT 'BANK',
    auto_create BOOLEAN DEFAULT FALSE, -- Auto-create transactions
    is_active BOOLEAN DEFAULT TRUE,
    last_created_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_recurring_amount CHECK (amount > 0),
    CONSTRAINT chk_end_after_start CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_template_name_length CHECK (CHAR_LENGTH(template_name) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_next_due_date (next_due_date),
    INDEX idx_is_active (is_active),
    INDEX idx_frequency (frequency),
    INDEX idx_auto_create (auto_create)
);
CREATE TABLE transaction_imports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    total_rows INT NOT NULL,
    successful_imports INT DEFAULT 0,
    failed_imports INT DEFAULT 0,
    duplicate_skipped INT DEFAULT 0,
    import_status ENUM('PROCESSING', 'COMPLETED', 'FAILED', 'PARTIAL') DEFAULT 'PROCESSING',
    error_details JSON NULL, -- Store import errors
    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_import_status (import_status),
    INDEX idx_imported_at (imported_at)
);
DROP DATABASE IF EXISTS goal_service_db;
CREATE DATABASE goal_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE goal_service_db;
CREATE TABLE goal_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    icon_name VARCHAR(50) DEFAULT 'target',
    color_code VARCHAR(7) DEFAULT '#3B82F6',
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_goal_category_name CHECK (CHAR_LENGTH(name) >= 2),
    CONSTRAINT chk_goal_color_code CHECK (color_code REGEXP '^#[0-9A-Fa-f]{6}$'),
    
    -- Indexes
    INDEX idx_name (name),
    INDEX idx_is_default (is_default),
    INDEX idx_sort_order (sort_order),
    INDEX idx_is_active (is_active)
);
CREATE TABLE goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    target_amount DECIMAL(15, 2) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0.00,
    category_id BIGINT NOT NULL,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    target_date DATE NULL, -- Can be open-ended
    start_date DATE DEFAULT '2024-01-01',
    status ENUM('ACTIVE', 'COMPLETED', 'PAUSED', 'CANCELLED') DEFAULT 'ACTIVE',
    completion_percentage DECIMAL(5, 2) GENERATED ALWAYS AS (
        CASE 
            WHEN target_amount > 0 THEN LEAST(100.00, (current_amount / target_amount) * 100)
            ELSE 0.00 
        END
    ) STORED, -- Auto-calculated field
    is_shared BOOLEAN DEFAULT FALSE,
    motivation_note TEXT NULL, -- User's motivation for the goal
    reward_description TEXT NULL, -- What they'll do when achieved
    image_url VARCHAR(500) NULL, -- Goal inspiration image
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES goal_categories(id),
    
    -- Constraints
    CONSTRAINT chk_target_amount CHECK (target_amount > 0),
    CONSTRAINT chk_current_amount CHECK (current_amount >= 0),
    CONSTRAINT chk_goal_title_length CHECK (CHAR_LENGTH(title) >= 3),
    CONSTRAINT chk_target_after_start CHECK (target_date IS NULL OR target_date >= start_date),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_target_date (target_date),
    INDEX idx_priority_level (priority_level),
    INDEX idx_completion_percentage (completion_percentage),
    INDEX idx_created_at (created_at),
    INDEX idx_is_shared (is_shared),
    -- Composite indexes
    INDEX idx_user_status (user_id, status),
    INDEX idx_user_priority (user_id, priority_level)
);
CREATE TABLE goal_progress_snapshots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    progress_percentage DECIMAL(5, 2) NOT NULL,
    snapshot_date DATE NOT NULL,
    snapshot_type ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'MILESTONE', 'MANUAL') DEFAULT 'DAILY',
    transaction_id BIGINT NULL, -- Track which transaction caused the change
    amount_change DECIMAL(15, 2) DEFAULT 0.00, -- Change from previous snapshot
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_snapshot_amount CHECK (amount >= 0),
    CONSTRAINT chk_snapshot_percentage CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    -- Unique constraint - one snapshot per goal per date per type
    UNIQUE KEY unique_goal_snapshot (goal_id, snapshot_date, snapshot_type),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_snapshot_date (snapshot_date),
    INDEX idx_snapshot_type (snapshot_type),
    INDEX idx_progress_percentage (progress_percentage),
    INDEX idx_created_at (created_at)
);
CREATE TABLE goal_milestones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    milestone_name VARCHAR(200) NOT NULL,
    target_percentage DECIMAL(5, 2) NOT NULL, -- 25.00 for 25%
    target_amount DECIMAL(15, 2) NOT NULL,
    is_achieved BOOLEAN DEFAULT FALSE,
    achieved_at TIMESTAMP NULL,
    reward_description TEXT NULL,
    is_automatic BOOLEAN DEFAULT TRUE, -- System-generated vs user-defined
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_milestone_percentage CHECK (target_percentage > 0 AND target_percentage <= 100),
    CONSTRAINT chk_milestone_amount CHECK (target_amount > 0),
    CONSTRAINT chk_milestone_name_length CHECK (CHAR_LENGTH(milestone_name) >= 3),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_target_percentage (target_percentage),
    INDEX idx_is_achieved (is_achieved),
    INDEX idx_is_automatic (is_automatic),
    INDEX idx_achieved_at (achieved_at)
);
CREATE TABLE goal_sharing (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    owner_user_id BIGINT NOT NULL, -- Goal owner
    shared_with_email VARCHAR(255) NOT NULL, -- Partner email (may not be registered user)
    shared_with_user_id BIGINT NULL, -- Partner user ID if registered
    permission_level ENUM('VIEW_ONLY', 'VIEW_COMMENT', 'VIEW_ENCOURAGE') DEFAULT 'VIEW_ONLY',
    is_active BOOLEAN DEFAULT TRUE,
    invitation_token VARCHAR(255) NULL, -- For email invitations
    invitation_sent_at TIMESTAMP NULL,
    invitation_accepted_at TIMESTAMP NULL,
    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Unique constraint
    UNIQUE KEY unique_goal_sharing (goal_id, shared_with_email),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_owner_user_id (owner_user_id),
    INDEX idx_shared_with_user_id (shared_with_user_id),
    INDEX idx_shared_with_email (shared_with_email),
    INDEX idx_is_active (is_active),
    INDEX idx_invitation_token (invitation_token)
);
CREATE TABLE goal_comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL, -- Commenter user ID
    user_name VARCHAR(200) NOT NULL, -- Display name for comment
    comment_text TEXT NOT NULL,
    comment_type ENUM('NOTE', 'ENCOURAGEMENT', 'REMINDER', 'MILESTONE', 'PROGRESS_UPDATE') DEFAULT 'NOTE',
    is_private BOOLEAN DEFAULT FALSE, -- Only goal owner can see
    parent_comment_id BIGINT NULL, -- For threaded comments
    like_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES goal_comments(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_comment_text_length CHECK (CHAR_LENGTH(comment_text) >= 1),
    CONSTRAINT chk_like_count CHECK (like_count >= 0),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_user_id (user_id),
    INDEX idx_comment_type (comment_type),
    INDEX idx_is_private (is_private),
    INDEX idx_parent_comment_id (parent_comment_id),
    INDEX idx_created_at (created_at)
);
DROP DATABASE IF EXISTS insight_service_db;
CREATE DATABASE insight_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE insight_service_db;
CREATE TABLE spending_analytics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    category_id BIGINT NOT NULL, -- Cross-service reference to finance service
    analysis_period ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    transaction_count INT DEFAULT 0,
    average_transaction DECIMAL(15, 2) DEFAULT 0.00,
    median_transaction DECIMAL(15, 2) DEFAULT 0.00,
    highest_transaction DECIMAL(15, 2) DEFAULT 0.00,
    lowest_transaction DECIMAL(15, 2) DEFAULT 0.00,
    trend_direction ENUM('INCREASING', 'DECREASING', 'STABLE') DEFAULT 'STABLE',
    trend_percentage DECIMAL(5, 2) DEFAULT 0.00, -- -50.00 to +50.00
    variance_from_budget DECIMAL(15, 2) DEFAULT 0.00, -- Over/under budget
    budget_utilization_percentage DECIMAL(5, 2) DEFAULT 0.00, -- % of budget used
    seasonal_factor DECIMAL(5, 2) DEFAULT 1.00, -- Seasonal adjustment
    anomaly_score DECIMAL(5, 2) DEFAULT 0.00, -- 0-100, higher = more unusual
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_transaction_count CHECK (transaction_count >= 0),
    CONSTRAINT chk_period_dates CHECK (period_end_date >= period_start_date),
    CONSTRAINT chk_trend_percentage CHECK (trend_percentage BETWEEN -100.00 AND 100.00),
    CONSTRAINT chk_anomaly_score CHECK (anomaly_score BETWEEN 0.00 AND 100.00),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category_period (user_id, category_id, analysis_period, period_start_date),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_analysis_period (analysis_period),
    INDEX idx_period_dates (period_start_date, period_end_date),
    INDEX idx_trend_direction (trend_direction),
    INDEX idx_anomaly_score (anomaly_score),
    INDEX idx_calculated_at (calculated_at),
    -- Composite indexes
    INDEX idx_user_period (user_id, analysis_period),
    INDEX idx_user_category (user_id, category_id)
);
CREATE TABLE goal_predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL, -- Cross-service reference to goal service
    user_id BIGINT NOT NULL,
    predicted_completion_date DATE NULL, -- NULL if unlikely to complete
    predicted_final_amount DECIMAL(15, 2) NULL,
    confidence_score DECIMAL(3, 2) NOT NULL, -- 0.00 to 1.00
    prediction_method ENUM('LINEAR_REGRESSION', 'TREND_ANALYSIS', 'SEASONAL_ADJUSTED', 'ML_MODEL') DEFAULT 'LINEAR_REGRESSION',
    required_monthly_savings DECIMAL(15, 2) NOT NULL,
    current_monthly_average DECIMAL(15, 2) DEFAULT 0.00,
    savings_rate_needed DECIMAL(5, 2) DEFAULT 0.00, -- % of income needed
    probability_of_success DECIMAL(5, 2) DEFAULT 0.00, -- 0-100%
    days_to_completion INT NULL, -- Estimated days remaining
    months_behind_schedule INT DEFAULT 0, -- Negative if ahead
    recommended_action ENUM('INCREASE_SAVINGS', 'EXTEND_DEADLINE', 'REDUCE_TARGET', 'ON_TRACK', 'ADJUST_SPENDING') NULL,
    risk_factors JSON NULL, -- Array of risk factors
    prediction_accuracy_history DECIMAL(5, 2) DEFAULT 0.00, -- Historical accuracy of predictions
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_confidence_score CHECK (confidence_score BETWEEN 0.00 AND 1.00),
    CONSTRAINT chk_probability_success CHECK (probability_of_success BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_required_savings CHECK (required_monthly_savings >= 0),
    
    -- Unique constraint
    UNIQUE KEY unique_goal_prediction (goal_id),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_user_id (user_id),
    INDEX idx_predicted_completion_date (predicted_completion_date),
    INDEX idx_confidence_score (confidence_score),
    INDEX idx_probability_of_success (probability_of_success),
    INDEX idx_prediction_method (prediction_method),
    INDEX idx_last_updated (last_updated)
);
CREATE TABLE user_recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recommendation_type ENUM('SPENDING_REDUCTION', 'SAVINGS_INCREASE', 'GOAL_ADJUSTMENT', 'BUDGET_OPTIMIZATION', 'CATEGORY_ANALYSIS', 'EMERGENCY_FUND', 'DEBT_PAYOFF') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    detailed_explanation TEXT NULL,
    action_items JSON NULL, -- Array of specific actions
    impact_amount DECIMAL(15, 2) NULL, -- Potential savings/impact
    impact_description VARCHAR(500) NULL,
    priority_score INT DEFAULT 5, -- 1-10 scale
    difficulty_level ENUM('EASY', 'MEDIUM', 'HARD') DEFAULT 'MEDIUM',
    estimated_time_to_implement VARCHAR(100) NULL, -- "2 weeks", "1 month"
    category_id BIGINT NULL, -- Related category
    goal_id BIGINT NULL, -- Related goal
    data_source JSON NULL, -- What data drove this recommendation
    success_rate DECIMAL(5, 2) DEFAULT 0.00, -- Historical success rate for this type
    is_active BOOLEAN DEFAULT TRUE,
    is_read BOOLEAN DEFAULT FALSE,
    is_applied BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    applied_at TIMESTAMP NULL,
    dismissed_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    feedback_rating TINYINT NULL, -- 1-5 rating from user
    feedback_comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_priority_score CHECK (priority_score BETWEEN 1 AND 10),
    CONSTRAINT chk_success_rate CHECK (success_rate BETWEEN 0.00 AND 100.00),
    CONSTRAINT chk_feedback_rating CHECK (feedback_rating IS NULL OR feedback_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_recommendation_title_length CHECK (CHAR_LENGTH(title) >= 5),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_recommendation_type (recommendation_type),
    INDEX idx_priority_score (priority_score),
    INDEX idx_difficulty_level (difficulty_level),
    INDEX idx_is_active (is_active),
    INDEX idx_is_read (is_read),
    INDEX idx_is_applied (is_applied),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at),
    -- Composite indexes
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_user_priority (user_id, priority_score)
);
CREATE TABLE financial_reports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    report_type ENUM('MONTHLY', 'QUARTERLY', 'YEARLY', 'CUSTOM', 'GOAL_PROGRESS', 'SPENDING_ANALYSIS') NOT NULL,
    report_title VARCHAR(200) NOT NULL,
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    total_income DECIMAL(15, 2) DEFAULT 0.00,
    total_expenses DECIMAL(15, 2) DEFAULT 0.00,
    net_savings DECIMAL(15, 2) DEFAULT 0.00,
    savings_rate DECIMAL(5, 2) DEFAULT 0.00, -- % of income saved
    expense_ratio DECIMAL(5, 2) DEFAULT 0.00, -- % of income spent
    top_expense_category VARCHAR(100) NULL,
    top_expense_amount DECIMAL(15, 2) DEFAULT 0.00,
    goal_progress_summary JSON NULL, -- Summary of all goals progress
    category_breakdown JSON NULL, -- Spending by category
    monthly_trends JSON NULL, -- Month-over-month trends
    insights_summary JSON NULL, -- Key insights and recommendations
    report_data JSON NULL, -- Full detailed report data
    file_path VARCHAR(500) NULL, -- PDF/Excel file location
    file_size_kb INT DEFAULT 0,
    is_scheduled BOOLEAN DEFAULT FALSE, -- Auto-generated report
    generated_by ENUM('USER_REQUEST', 'SCHEDULED', 'API_CALL') DEFAULT 'USER_REQUEST',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL, -- When to auto-delete
    
    -- Constraints
    CONSTRAINT chk_report_period CHECK (report_period_end >= report_period_start),
    CONSTRAINT chk_savings_rate CHECK (savings_rate BETWEEN -100.00 AND 100.00),
    CONSTRAINT chk_expense_ratio CHECK (expense_ratio BETWEEN 0.00 AND 200.00),
    CONSTRAINT chk_file_size CHECK (file_size_kb >= 0),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_report_type (report_type),
    INDEX idx_report_period (report_period_start, report_period_end),
    INDEX idx_generated_at (generated_at),
    INDEX idx_is_scheduled (is_scheduled),
    INDEX idx_expires_at (expires_at)
);
CREATE TABLE user_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    notification_type ENUM('GOAL_DEADLINE', 'BUDGET_EXCEEDED', 'MILESTONE_ACHIEVED', 'SPENDING_ALERT', 'RECOMMENDATION', 'GOAL_SHARED', 'PAYMENT_DUE', 'WEEKLY_SUMMARY') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) NULL, -- Deep link to relevant page
    action_text VARCHAR(100) NULL, -- "View Goal", "Check Budget"
    related_goal_id BIGINT NULL,
    related_category_id BIGINT NULL,
    related_recommendation_id BIGINT NULL,
    data_payload JSON NULL, -- Additional data for the notification
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    is_email_sent BOOLEAN DEFAULT FALSE,
    is_push_sent BOOLEAN DEFAULT FALSE,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    delivery_method ENUM('IN_APP', 'EMAIL', 'PUSH', 'ALL') DEFAULT 'IN_APP',
    scheduled_at TIMESTAMP NULL, -- For delayed notifications
    sent_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL, -- Auto-delete old notifications
    retry_count INT DEFAULT 0,
    last_retry_at TIMESTAMP NULL,
    error_message TEXT NULL, -- If sending failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_retry_count CHECK (retry_count >= 0),
    CONSTRAINT chk_notification_title_length CHECK (CHAR_LENGTH(title) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_is_sent (is_sent),
    INDEX idx_priority_level (priority_level),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_sent_at (sent_at),
    INDEX idx_expires_at (expires_at),
    INDEX idx_created_at (created_at),
    -- Composite indexes
    INDEX idx_user_unread (user_id, is_read),
    INDEX idx_user_type (user_id, notification_type)
);
CREATE TABLE notification_templates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL UNIQUE,
    template_type ENUM('GOAL_DEADLINE', 'BUDGET_EXCEEDED', 'MILESTONE_ACHIEVED', 'SPENDING_ALERT', 'RECOMMENDATION', 'GOAL_SHARED', 'WEEKLY_SUMMARY') NOT NULL,
    subject_template VARCHAR(200) NOT NULL,
    body_template TEXT NOT NULL,
    email_template TEXT NULL, -- HTML email template
    variables JSON NULL, -- Available template variables
    default_priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    is_active BOOLEAN DEFAULT TRUE,
    usage_count INT DEFAULT 0, -- How many times used
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_usage_count CHECK (usage_count >= 0),
    
    -- Indexes
    INDEX idx_template_type (template_type),
    INDEX idx_template_name (template_name),
    INDEX idx_is_active (is_active),
    INDEX idx_usage_count (usage_count)
);
CREATE TABLE user_preferences (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE, -- One preference record per user
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    in_app_notifications BOOLEAN DEFAULT TRUE,
    goal_deadline_alerts BOOLEAN DEFAULT TRUE,
    budget_alerts BOOLEAN DEFAULT TRUE,
    milestone_celebrations BOOLEAN DEFAULT TRUE,
    spending_alerts BOOLEAN DEFAULT TRUE,
    weekly_summaries BOOLEAN DEFAULT TRUE,
    recommendation_alerts BOOLEAN DEFAULT TRUE,
    alert_frequency ENUM('IMMEDIATE', 'DAILY_DIGEST', 'WEEKLY_DIGEST') DEFAULT 'IMMEDIATE',
    quiet_hours_start TIME DEFAULT '22:00:00', -- No notifications during quiet hours
    quiet_hours_end TIME DEFAULT '08:00:00',
    timezone VARCHAR(50) DEFAULT 'UTC',
    currency_code VARCHAR(3) DEFAULT 'USD',
    date_format ENUM('MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD') DEFAULT 'MM/DD/YYYY',
    number_format ENUM('1,234.56', '1.234,56', '1 234,56') DEFAULT '1,234.56',
    dashboard_layout JSON NULL, -- User's preferred dashboard layout
    theme ENUM('LIGHT', 'DARK', 'AUTO') DEFAULT 'LIGHT',
    language_code VARCHAR(5) DEFAULT 'en-US',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_alert_frequency (alert_frequency),
    INDEX idx_timezone (timezone)
);
CREATE TABLE system_health_metrics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15, 4) NOT NULL,
    metric_unit VARCHAR(20) NULL, -- 'seconds', 'count', 'percentage'
    service_name VARCHAR(50) NOT NULL, -- 'insight-service', 'goal-service', etc.
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_metric_name (metric_name),
    INDEX idx_service_name (service_name),
    INDEX idx_recorded_at (recorded_at),
    INDEX idx_service_metric (service_name, metric_name)
);
USE auth_service_db;
ANALYZE TABLE users, jwt_tokens, password_reset_tokens, user_sessions;
USE user_finance_db;
ANALYZE TABLE transaction_categories, user_budget_categories, transactions, recurring_transactions, transaction_imports;
USE goal_service_db;
USE insight_service_db;
ANALYZE TABLE spending_analytics, goal_predictions, user_recommendations, financial_reports, user_notifications, notification_templates, user_preferences, system_health_metrics;
USE auth_service_db;
USE user_finance_db;
USE goal_service_db;
USE insight_service_db;
DROP DATABASE IF EXISTS auth_service_db;
CREATE DATABASE auth_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE auth_service_db;
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hashed
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_names_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2),
    
    -- Indexes
    INDEX idx_email (email),
    INDEX idx_is_active (is_active)
);
CREATE TABLE jwt_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at)
);
DROP DATABASE IF EXISTS user_finance_db;
CREATE DATABASE user_finance_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE user_finance_db;
CREATE TABLE transaction_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    color_code VARCHAR(7) DEFAULT '#6B7280',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_category_type (category_type),
    INDEX idx_name (name)
);
CREATE TABLE user_budgets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    category_id BIGINT NOT NULL,
    monthly_budget DECIMAL(12, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_monthly_budget CHECK (monthly_budget >= 0),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category (user_id, category_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id)
);
CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    amount DECIMAL(12, 2) NOT NULL,
    description VARCHAR(500) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    goal_id BIGINT NULL, -- Cross-service reference to goals
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES transaction_categories(id),
    
    -- Constraints
    CONSTRAINT chk_amount CHECK (amount != 0),
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_category_id (category_id),
    INDEX idx_goal_id (goal_id),
    INDEX idx_transaction_type (transaction_type)
);
DROP DATABASE IF EXISTS goal_service_db;
CREATE DATABASE goal_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE goal_service_db;
CREATE TABLE goal_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    color_code VARCHAR(7) DEFAULT '#3B82F6',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_name (name),
    INDEX idx_is_default (is_default)
);
CREATE TABLE goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    target_amount DECIMAL(12, 2) NOT NULL,
    current_amount DECIMAL(12, 2) DEFAULT 0.00,
    category_id BIGINT NOT NULL,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'MEDIUM',
    target_date DATE NULL,
    status ENUM('ACTIVE', 'COMPLETED', 'PAUSED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    -- Foreign Key
    FOREIGN KEY (category_id) REFERENCES goal_categories(id),
    
    -- Constraints
    CONSTRAINT chk_target_amount CHECK (target_amount > 0),
    CONSTRAINT chk_current_amount CHECK (current_amount >= 0),
    CONSTRAINT chk_goal_title_length CHECK (CHAR_LENGTH(title) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_target_date (target_date),
    INDEX idx_priority_level (priority_level)
);
CREATE TABLE goal_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    goal_id BIGINT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    progress_percentage DECIMAL(5, 2) NOT NULL,
    recorded_date DATE NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_progress_amount CHECK (amount >= 0),
    CONSTRAINT chk_progress_percentage CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    
    -- Indexes
    INDEX idx_goal_id (goal_id),
    INDEX idx_recorded_date (recorded_date),
    INDEX idx_progress_percentage (progress_percentage)
);
DROP DATABASE IF EXISTS insight_service_db;
CREATE DATABASE insight_service_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
USE insight_service_db;
CREATE TABLE spending_analytics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL, -- Cross-service reference
    category_id BIGINT NOT NULL, -- Cross-service reference
    analysis_month DATE NOT NULL, -- YYYY-MM-01 format
    total_amount DECIMAL(12, 2) NOT NULL,
    transaction_count INT DEFAULT 0,
    average_transaction DECIMAL(12, 2) DEFAULT 0.00,
    budget_variance DECIMAL(12, 2) DEFAULT 0.00, -- Over/under budget
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_transaction_count CHECK (transaction_count >= 0),
    
    -- Unique constraint
    UNIQUE KEY unique_user_category_month (user_id, category_id, analysis_month),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_analysis_month (analysis_month)
);
CREATE TABLE user_recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recommendation_type ENUM('SPENDING_REDUCTION', 'SAVINGS_INCREASE', 'GOAL_ADJUSTMENT', 'BUDGET_OPTIMIZATION') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    impact_amount DECIMAL(12, 2) NULL,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'MEDIUM',
    is_active BOOLEAN DEFAULT TRUE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_recommendation_title_length CHECK (CHAR_LENGTH(title) >= 5),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_recommendation_type (recommendation_type),
    INDEX idx_priority_level (priority_level),
    INDEX idx_is_active (is_active),
    INDEX idx_is_read (is_read)
);
CREATE TABLE user_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    notification_type ENUM('GOAL_DEADLINE', 'BUDGET_EXCEEDED', 'MILESTONE_ACHIEVED', 'SPENDING_ALERT') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    related_goal_id BIGINT NULL,
    related_category_id BIGINT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH') DEFAULT 'MEDIUM',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_notification_title_length CHECK (CHAR_LENGTH(title) >= 3),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_priority_level (priority_level)
);
USE auth_service_db;
ANALYZE TABLE users, jwt_tokens;
USE user_finance_db;
ANALYZE TABLE transaction_categories, user_budgets, transactions;
USE goal_service_db;
USE insight_service_db;
ANALYZE TABLE spending_analytics, user_recommendations, user_notifications;
USE auth_service_db;
USE user_finance_db;
USE goal_service_db;
USE insight_service_db;
