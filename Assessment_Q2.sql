/**Categorize users by their average monthly transaction frequency on savings accounts.
Return the number of customers in each category and their average monthly transaction count**/

-- Step 1: Calculate monthly transaction count per customer
WITH monthly_transactions AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,  -- Grouping format: YYYY-MM
        COUNT(*) AS monthly_tx_count  -- Number of transactions in the month
    FROM 
        savings_savingsaccount
    WHERE 
        transaction_date IS NOT NULL
    GROUP BY 
        owner_id, DATE_FORMAT(transaction_date, '%Y-%m')
),

-- Step 2: Compute average monthly transaction count per customer
avg_transactions_per_customer AS (
    SELECT 
        owner_id,
        AVG(monthly_tx_count) AS avg_tx_per_month  -- Average number of transactions per month per customer
    FROM 
        monthly_transactions
    GROUP BY 
        owner_id
),

-- Step 3: Classify customers by average transaction frequency
categorized_customers AS (
    SELECT 
        CASE 
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'     -- 10 or more transactions/month
            WHEN avg_tx_per_month >= 3 THEN 'Medium Frequency'    -- Between 3 and 9.99
            ELSE 'Low Frequency'                                  -- Less than 3
        END AS frequency_category,
        avg_tx_per_month
    FROM 
        avg_transactions_per_customer
)

-- Step 4: Aggregate by frequency category
SELECT 
    frequency_category,  -- Frequency class (High, Medium, Low)
    COUNT(*) AS customer_count,  -- Number of customers in this category
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month  -- Average of their monthly averages (rounded to 1 dp)
FROM 
    categorized_customers
GROUP BY 
    frequency_category;
