-- Banking Customer Churn Analysis
-- MySQL 8+
CREATE DATABASE IF NOT EXISTS banking_churn;
USE banking_churn;

-- Import banking_customer_churn_clean.csv into customer_churn

-- 1. Overall KPIs
SELECT COUNT(*) AS total_customers,
       SUM(Churned) AS churned_customers,
       ROUND(100.0*AVG(Churned),2) AS churn_rate_pct,
       ROUND(AVG(Balance),2) AS avg_balance,
       ROUND(AVG(Credit_Score),2) AS avg_credit_score
FROM customer_churn;

-- 2. Churn by geography
SELECT Geography, COUNT(*) AS customers, SUM(Churned) AS churned,
       ROUND(100.0*AVG(Churned),2) AS churn_rate_pct
FROM customer_churn GROUP BY Geography ORDER BY churn_rate_pct DESC;

-- 3. Churn by activity
SELECT Is_Active_Member, COUNT(*) AS customers,
       ROUND(100.0*AVG(Churned),2) AS churn_rate_pct
FROM customer_churn GROUP BY Is_Active_Member;

-- 4. Churn by products
SELECT Num_Products, COUNT(*) AS customers,
       ROUND(100.0*AVG(Churned),2) AS churn_rate_pct
FROM customer_churn GROUP BY Num_Products ORDER BY Num_Products;

-- 5. Age bands
SELECT CASE WHEN Age < 25 THEN '18-24' WHEN Age < 35 THEN '25-34'
            WHEN Age < 45 THEN '35-44' WHEN Age < 55 THEN '45-54'
            WHEN Age < 65 THEN '55-64' ELSE '65+' END AS age_band,
       COUNT(*) customers, ROUND(100.0*AVG(Churned),2) churn_rate_pct
FROM customer_churn GROUP BY age_band ORDER BY churn_rate_pct DESC;

-- 6. Satisfaction impact
SELECT Satisfaction_Score, COUNT(*) customers,
       ROUND(100.0*AVG(Churned),2) churn_rate_pct
FROM customer_churn GROUP BY Satisfaction_Score ORDER BY Satisfaction_Score;

-- 7. High-risk segment
SELECT Customer_ID, Age, Geography, Credit_Score, Tenure_Years,
       Balance, Num_Products, Is_Active_Member, Satisfaction_Score
FROM customer_churn
WHERE Churned=1 OR (Is_Active_Member=0 AND Satisfaction_Score<=2)
ORDER BY Satisfaction_Score, Credit_Score;

-- 8. Top balance at risk
SELECT Customer_ID, Geography, Balance, Churned
FROM customer_churn WHERE Churned=1
ORDER BY Balance DESC LIMIT 20;

-- 9. Churn rate by tenure
SELECT Tenure_Years, COUNT(*) customers,
       ROUND(100.0*AVG(Churned),2) churn_rate_pct
FROM customer_churn GROUP BY Tenure_Years ORDER BY Tenure_Years;

-- 10. Ranking geographies by churn
WITH g AS (
 SELECT Geography, COUNT(*) customers, ROUND(100.0*AVG(Churned),2) churn_rate_pct
 FROM customer_churn GROUP BY Geography
)
SELECT *, DENSE_RANK() OVER(ORDER BY churn_rate_pct DESC) AS churn_rank FROM g;
