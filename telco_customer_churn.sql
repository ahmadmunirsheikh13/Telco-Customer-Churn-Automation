create DATABASE if not exists telco_churn_db;
Use telco_churn_db;
DROP TABLE IF EXISTS telco_churn;
CREATE TABLE telco_churn(
customerid varchar(50) Primary Key,
customer_count int,
country varchar(50),
state varchar(50),
city varchar(50),
zip_code int,
lat_long varchar(100),
latitude decimal(10,8),
longitude decimal(11,8),
gender varchar(20),
senior_citizen varchar(5),
partner varchar(5),
dependents varchar(5),
tenure_months int,
phone_service varchar(5),
multiple_lines varchar(30),
internet_service varchar(30),
online_security varchar(30),
online_backup varchar(30),
device_protection varchar(30),
tech_support varchar(30),
streaming_tv varchar(30),
streaming_movies varchar(30),
contract varchar(30),
paperless_billing varchar(5),
payment_method varchar(30),
monthly_charges decimal(15,2),
total_charges decimal(10,2),
churn_label varchar(10),
churn_value int,
churn_score int,
cltv int,
churn_reason text,
churn_status varchar(20));
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:\\Users\\Ahmad Munir Sheikh\\OneDrive\\Desktop\\Telecom Customer Churn Prediction\\Cleaned_Telco_customer_churn.csv'
INTO TABLE telco_churn
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 rows;
SELECT * FROM telco_churn limit 10; 
 --  1- Calculating Revenue
SELECT churn_status,SUM(monthly_charges) as monthly_revenue 
from telco_churn where churn_value=0 
group by churn_status;
 --  2- Active customers with highest churn risk score
 CREATE OR REPLACE VIEW high_risk_customers as
 SELECT customerid,country,state,city,gender,tenure_months,monthly_charges,total_charges,churn_score,churn_status
 from telco_churn 
 where churn_value=0;
 SELECT * FROM  high_risk_customers;
 -- 3- Filtering out senior citizens who are still in network 
SELECT customerid,gender,tenure_months,contract,monthly_charges,churn_status 
from telco_churn
where churn_value=0 AND senior_citizen='Yes' 
ORDER BY monthly_charges DESC;
 -- 4- Making count of people churned on the basis of gender
SELECT senior_citizen,gender,count(*) as total_churned_customers,SUM(monthly_charges)as monthly_revenue_lost 
from telco_churn 
where churn_value=1
group by senior_citizen,gender
order by monthly_revenue_lost DESC;
 -- 5- Getting insights why people are churning from this network
SELECT churn_reason,count(*) as total_customers_churned
from telco_churn
 where churn_value=1 
 group by churn_reason 
 order by total_customers_churned DESC; 
 -- 6- Calculating Revenue loss from each city
 CREATE OR REPLACE VIEW revenue_loss_by_city as
 SELECT city, SUM(monthly_charges) as revenue_loss 
 from telco_churn 
 where churn_value=1
 group by city ;
 SELECT * FROM  revenue_loss_by_city;
 -- 7- Calculating AVG revenue overall on the basis of internet_service & tech support and ranked them
 SELECT internet_service,tech_support,AVG(monthly_charges) as avg_monthly_revenue,
 RANK()OVER(Order by AVG(monthly_charges) DESC) as revenue_rank
 from telco_churn 
 group by internet_service,tech_support;
  -- 8- Calculating Churn rate by contract
  CREATE OR REPLACE VIEW churn_rate as
SELECT contract,Count(*) as total_customers,sum(churn_value) as churned,
Round(SUM(churn_value)*100.0/Count(*),2) as churn_rate
from telco_churn
Group BY contract;
SELECT * FROM  churn_rate;
 -- 9- How much avg revenue is generating from our partners monthly in each city
SELECT city,AVG(monthly_charges) as revenue_generated
from telco_churn
where partner='Yes'
group by city
order by revenue_generated DESC;
 -- 10- High value lost customers
CREATE OR REPLACE VIEW high_value_lost_customer as
 SELECT customerid,total_charges,monthly_charges
FROM telco_churn
WHERE churn_value = 1;
SELECT * FROM  high_value_lost_customer;
-- 11- Cohort Analysis (Tenure-based Grouping)
CREATE OR REPLACE VIEW cohort_analysis as 
SELECT
     CASE WHEN tenure_months BETWEEN 1 AND 12 THEN '0-1 Year' 
          WHEN tenure_months BETWEEN 13 AND 24 THEN '1-2 Year'
          WHEN tenure_months BETWEEN 25 AND 36 THEN '2-3 Year'
          WHEN tenure_months BETWEEN 37 AND 48 THEN '3-4 Year'
		  ELSE '4+ year'
	 END as cohort_group,
     Count(*) as total_customers,
     Round(AVG(churn_score),2) as avg_risk_score,
     SUM(churn_value) as actual_churn
    from telco_churn
    group by cohort_group;
    SELECT * FROM  cohort_analysis;
 -- 12- Retention Rate by contract type
 CREATE OR REPLACE VIEW retention_rate as
 SELECT contract, count(*) as total_customers,
 SUM(CASE WHEN churn_value=0 then 1 else 0 END) as retained_customer,
 SUM(CASE WHEN churn_value=1 then 1 else 0 END) as churned_customer,
 Round(sum(case when churn_value=0 then 1 else 0 end)*100.0/count(*),2) as retention_rate
 from telco_churn
 group by contract;
 SELECT * FROM  retention_rate;
  -- Calculating Cumulating (running) total revenue based on tenure_months
  CREATE OR REPLACE VIEW cumulative_revenue AS 
  SELECT tenure_months,SUM(monthly_charges) as monthly_revenue,
  SUM(SUM(monthly_charges)) OVER(ORDER BY tenure_months) as total_revenue
  from telco_churn
  group by tenure_months;
SELECT * FROM  cumulative_revenue