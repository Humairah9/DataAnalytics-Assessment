/**Inactive Plans Report (Jan 2023 - Jan 2024)
Objective: Identify all Savings or Investment plans with their last inflow
transaction dated between Jan 1, 2023 and Jan 31, 2024, where no further
inflow has occurred within 365 days as of Jan 31, 2024**/

-- Step 1: Capture the most recent inflow (positive transaction) for each plan
WITH last_inflow AS (
    SELECT
        sa.plan_id,                            -- Unique ID of the plan
        sa.owner_id,                           -- Owner of the plan (customer ID)
        MAX(sa.transaction_date) AS last_transaction_date  -- Most recent inflow date
    FROM 
        savings_savingsaccount sa
    WHERE 
        sa.amount > 0                          -- Consider only positive inflow transactions
    GROUP BY 
        sa.plan_id, sa.owner_id               -- Group by plan and customer
)

-- Step 2: Join with plans table and filter by plan type and date constraints
SELECT
    p.id AS plan_id,                           -- Unique identifier of the plan
    p.owner_id,                                -- Customer who owns the plan
    CASE 
        WHEN p.plan_type_id = 1 THEN 'Savings'     -- Translate plan_type_id to human-readable type
        WHEN p.plan_type_id = 2 THEN 'Investment'
    END AS type,
    DATE(li.last_transaction_date) AS last_transaction_date,   -- Most recent inflow date
    DATEDIFF('2024-01-31', li.last_transaction_date) AS inactivity_days  -- Days since last inflow as of Jan 31, 2024
FROM 
    plans_plan p
JOIN 
    last_inflow li ON p.id = li.plan_id AND p.owner_id = li.owner_id  -- Match inflow data to plan
WHERE 
    p.plan_type_id IN (1, 2)                    -- Only include Savings (1) or Investment (2) plans
    AND li.last_transaction_date BETWEEN '2023-01-01' AND '2024-01-31'  -- Last inflow must be within this date range
    AND DATEDIFF('2024-01-31', li.last_transaction_date) <= 365         -- Inactivity must be 365 days or less
ORDER BY 
    li.last_transaction_date DESC;              -- Sort with most recent last inflow first
