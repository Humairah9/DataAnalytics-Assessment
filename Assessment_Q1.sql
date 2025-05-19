/** Retrieve users who have both savings and investment plans with positive funding
 For each qualifying user, return their ID, full name, count of savings and investment plans,
 and the total amount deposited across those plans **/

SELECT 
    u.id AS owner_id,  -- User ID
    CONCAT(u.first_name, ' ', u.last_name) AS Name,  -- Full name from first and last name
    
    -- Count of savings plans
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count,
    
    -- Count of investment plans
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count,
    
    -- Total amount deposited in both savings and investment plans
    SUM(CASE 
            WHEN p.plan_type_id IN (1, 2) THEN p.amount 
            ELSE 0 
        END) AS total_deposits

FROM 
    users_customuser u
JOIN 
    plans_plan p ON u.id = p.owner_id  -- Join plans to users

WHERE 
    p.amount > 0  -- Only consider plans with positive balances

GROUP BY 
    u.id, Name  -- Group by user and full name

HAVING 
    -- Include only users with at least one savings and one investment plan
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) >= 1 AND
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) >= 1

ORDER BY 
    total_deposits DESC;  -- Sort by total deposits