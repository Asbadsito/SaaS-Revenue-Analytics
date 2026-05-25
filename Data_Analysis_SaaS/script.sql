-- ==========================================
-- 1. CLEAN UP PREVIOUS TABLES (IF ANY)
-- ==========================================
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS users;

-- ==========================================
-- 2. CREATE THE TABLES (DATABASE STRUCTURE)
-- ==========================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    signup_date DATE,
    country VARCHAR(50),
    account_status VARCHAR(20) -- 'Active' or 'Cancelled'
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    amount_paid DECIMAL(10,2),
    payment_date DATE
);

-- ==========================================
-- 3. POPULATE THE USERS TABLE (1,000 ROWS)
-- ==========================================
INSERT INTO users (full_name, signup_date, country, account_status)
SELECT
    -- Generates realistic-looking random names by combining random first and last names
    (ARRAY['Liam', 'Noah', 'Oliver', 'James', 'Elijah', 'William', 'Henry', 'Lucas', 'Benjamin', 'Theodore', 'Mateo', 'Levi', 'Sebastian', 'Daniel', 'Jack', 'Michael', 'Alexander', 'Owen', 'Asher', 'Samuel'])[FLOOR(RANDOM() * 20 + 1)] || ' ' ||
    (ARRAY['Smith', 'Jones', 'Taylor', 'Brown', 'Williams', 'Wilson', 'Johnson', 'Davies', 'Robinson', 'Wright', 'Thompson', 'Evans', 'Walker', 'White', 'Roberts', 'Green', 'Hall', 'Wood', 'Jackson', 'Clarke'])[FLOOR(RANDOM() * 20 + 1)],
    -- Random signup date within the last year
    CURRENT_DATE - (RANDOM() * 365)::INT,
    -- Random target markets
    (ARRAY['United Kingdom', 'United States', 'Spain', 'Germany', 'Canada'])[FLOOR(RANDOM() * 5 + 1)],
    -- Weighted distribution: roughly 75% Active, 25% Cancelled (Churned)
    (ARRAY['Active', 'Active', 'Active', 'Cancelled'])[FLOOR(RANDOM() * 4 + 1)]
FROM generate_series(1, 1000);

-- ==========================================
-- 4. POPULATE THE PAYMENTS TABLE (1,500 ROWS)
-- ==========================================
INSERT INTO payments (user_id, amount_paid, payment_date)
SELECT
    -- Assigns payments randomly across our 1,000 users (creates realistic multi-paying users)
    FLOOR(RANDOM() * 1000 + 1)::INT,
    -- Standard SaaS subscription pricing tiers
    (ARRAY[14.99, 29.99, 49.99])[FLOOR(RANDOM() * 3 + 1)],
    -- Random payment date within the last 6 months
    CURRENT_DATE - (RANDOM() * 180)::INT
FROM generate_series(1, 1500);


-- Verify data

SELECT
    users.user_id,
    users.full_name,
    users.country,
    users.account_status,
    payments.amount_paid,
    payments.payment_date
FROM users
LEFT JOIN payments ON users.user_id = payments.user_id;



-- Some insights and queries for reports, although this can be done in a Pivot table in
-- excel, to practise a bit more queries I will use SQL before exporting

SELECT
    users.country ,
    COUNT(DISTINCT users.user_id) AS total_users ,
    SUM(payments.amount_paid) AS total_revenue
FROM users
LEFT JOIN payments ON users.user_id = payments.user_id
GROUP BY users.country
ORDER BY total_revenue;

/*
 This one basically selects all users, groups by country , perform count and sum as
 aggregate functions to get two different columns, total users and revenue
 and performs a left join to the payments table matchin the users id
 then I ordered each country by total revenue
 */


SELECT
    users.account_status ,
    COUNT(users.user_id) AS total_users
FROM users
GROUP BY users.account_status;

-- Basically total users count grouped by active and cancelled




SELECT
    users.user_id,
    users.full_name,
    users.country,
    SUM(payments.amount_paid) AS total_spent
FROM users
INNER JOIN payments ON users.user_id = payments.user_id
GROUP BY users.user_id, users.full_name, users.country
HAVING SUM(payments.amount_paid) > 100
ORDER BY total_spent DESC;

/*
 Top customers ordered by total spent, which is the sum of the payments using HAVING (for condition
 of someone who has spent more than 100) after
 grouping the rows of payments based on individual customer with an inner join

 */

SELECT
    payments.amount_paid AS subscription_tier,
    COUNT(payments.payment_id) AS total_orders,
    SUM(payments.amount_paid) AS total_revenue
FROM payments
GROUP BY payments.amount_paid
ORDER BY total_revenue DESC;
    
/*
 This last querie will group the amount_paid of ALL payments as a "subscription" tier,
 count each individual payment as total orders , then sum all payments as total revenue
 , finally we order the revenue
 */

 SELECT * FROM users WHERE user_id = 931;