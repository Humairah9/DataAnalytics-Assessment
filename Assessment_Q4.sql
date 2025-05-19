
/**Customer Lifetime Value (CLV) Report in Kobo
Objective: To estimate CLV per user by evaluating inflow transactions and tenure
across all customers with at least one month of activity.**/

-- Step 1: Aggregate transaction data per customer (only positive inflow transactions)
WITH customer_transactions AS (
    SELECT
        sa.owner_id,  -- User ID
        COUNT(*) AS total_transactions,  -- Total number of inflow transactions
        SUM(sa.amount) AS total_transaction_value  -- Total value of all inflow transactions
    FROM savings_savingsaccount sa
    WHERE sa.amount > 0
    GROUP BY sa.owner_id
),

-- Step 2: Calculate tenure (in months) and derive full name
tenure_calc AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS full_name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months
    FROM users_customuser u
),

-- Step 3: Calculate CLV in Kobo
clv_calc AS (
    SELECT
        t.customer_id,
        t.full_name,
        t.tenure_months,
        ct.total_transactions,
        
        -- CLV formula in Kobo (no conversion to naira)
        ROUND((
            (ct.total_transactions / t.tenure_months) * 12 *
            (ct.total_transaction_value / ct.total_transactions)
        ), 2) AS estimated_clv_kobo
        
    FROM tenure_calc t
    JOIN customer_transactions ct ON t.customer_id = ct.owner_id
    WHERE t.tenure_months > 0
)

-- Step 4: Return final results
SELECT *
FROM clv_calc
ORDER BY estimated_clv_kobo DESC;
