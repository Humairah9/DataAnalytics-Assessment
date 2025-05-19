# DataAnalytics-Assessment

This repository contains my solutions to the SQL assessments for a data analyst role. Each file includes a single SQL query designed to answer a specific analytical question using proper formatting, clear logic, and explanatory comments.

# Assessment 1

Question: Retrieve users who have both savings and investment plans with positive funding. For each qualifying user, return their ID, full name, count of savings and investment plans, and the total amount deposited across those plans.

Approach:
- Joined `users_customuser` with `plans_plan` on user ID.
- Filtered only plans with a positive amount.
- Used conditional aggregation to: 
  - Count distinct savings and investment plans.
  - Calculate the total amount deposited across both types.
- Used `HAVING` to ensure only users with at least one savings and one investment plan are included.
- Ordered the result by total deposits in descending order.

Challenges: Initially, there was confusion around using `COUNT(DISTINCT ...)` within the `HAVING` clause. It was resolved by ensuring consistency in the aggregation logic used in both `SELECT` and `HAVING`.

# Assessment 2

Question: Categorize users by their average monthly transaction frequency on savings accounts. Return the number of customers in each category and their average monthly transaction count.

Approach:
- Step 1: Created a `monthly_transactions` CTE to count transactions per user per month using `DATE_FORMAT` for YYYY-MM grouping.
- Step 2: Calculated each user's average monthly transactions using ‘AVG()` grouped by `owner_id`.
- Step 3: Classified users into ‘High’, ‘Medium’, or ‘Low Frequency` based on the average.
- Step 4: Counted users in each frequency category and calculated the overall average of their transaction rates.

Challenges:  
- Ensuring the correct time granularity when grouping by month. Initially, the query used the full transaction date which led to inflated counts switching to `DATE_FORMAT` resolved the issue.
- Properly structuring nested CTEs and ensuring smooth transition between steps required careful testing.
 
# Assessment 3

Question: Identify all savings or investment plans with their last inflow transaction dated between Jan 1, 2023, and Jan 31, 2024, where no further inflow has occurred within 365 days as of Jan 31, 2024.

Approach:
- Step 1: Created a CTE `last_inflow` to find the most recent positive transaction (inflow) per plan.
- Step 2: Joined the inflow data with the `plans_plan` table to:
     - Include only relevant plan types (Savings and Investment).
     - Filter for last inflows occurring between Jan 1, 2023, and Jan 31, 2024.
     - Calculate inactivity days using `DATEDIFF` from the reference date (`2024-01-31`).
     - Sorted the results by the most recent last inflow date.

Challenges:  
- Handling the `DATEDIFF` correctly to measure inactivity within the target window. Initially, plans were filtered with `> 365` days, but the correct constraint (per business rule) was `<= 365`.
- Making sure inflow detection didn’t include 0 or negative amounts by strictly filtering `sa.amount > 0`.

# Assessment 4

Question: Estimate Customer Lifetime Value (CLV) per user by evaluating positive inflow transactions and tenure across all customers with at least one month of activity. CLV is reported in **Kobo** (not Naira).

Approach:  
- Step 1: Aggregated total inflow transactions and value per customer.
- Step 2: Calculated user tenure in months using `TIMESTAMPDIFF()` between `date_joined` and the current date.
- Step 3: Applied a CLV formula to reflects expected annual value.
- Step 4: Filtered only users with more than one month tenure and returned sorted results.

Challenges:
- Ensuring tenure is in months (not days or years) for proper calculation resolved using `TIMESTAMPDIFF(MONTH, ...)`.
- Avoided division errors by filtering out users with zero-month tenure (`WHERE tenure_months > 0`).
- Clarified the monetary unit was Kobo, so no conversion to Naira was applied.
