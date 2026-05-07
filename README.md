# Telco Customer Churn Prediction
### End-to-End Data Engineering & Analytics Project
**Pipeline: Python → MySQL → n8n → Google Sheets → Power BI**

---

## Project Overview
This project delivers a complete end-to-end solution for predicting and analyzing
customer churn in a telecommunications company. It combines data engineering, SQL
analytics, workflow automation, and interactive dashboarding to provide actionable
business intelligence.

---

## Project Architecture
| Stage | Tool | Purpose |
|---|---|---|
| 1. Data Cleaning | Python (Pandas) | Clean, transform & export dataset |
| 2. Data Storage | MySQL | Store structured data & SQL analytics |
| 3. Automation | n8n | Automate data flow to Google Sheets |
| 4. Reporting | Google Sheets | Intermediate data layer |
| 5. Dashboard | Power BI | Interactive visualization & insights |

---

## Tech Stack
- Python 3.x — Data cleaning, EDA, feature engineering
- Pandas & NumPy — DataFrame manipulation & IQR calculation
- MySQL 8.x — Relational database & SQL analytics
- n8n — Workflow automation
- Google Sheets — Intermediate reporting layer
- Power BI — Interactive dashboard

---

## 1. Data Cleaning (Python)

Steps performed:
- Loaded raw Excel file, standardized column names to lowercase with underscores
- Validated and converted data types for total_charges, monthly_charges, churn_score
- Handled missing values: zero-tenure rows set to 0, rest filled with median
- Removed duplicate records based on customerid
- Filled missing churn_reason with 'Unknown'
- Applied IQR method to detect outliers in churn_score
- Created churn_status column using pd.cut() with Q1/Q3 thresholds
- Cleaned categorical encoding to fix \r character issue
- Exported clean CSV with UTF-8 encoding and Unix line endings

Key fix — Carriage Return (\r) Issue:
When pd.cut() output is exported to CSV on Windows, hidden \r characters
embed into category labels. Fix applied:

    df['churn_status'] = df['churn_status'].astype(str).str.strip()
    df.to_csv('file.csv', encoding='utf-8', lineterminator='\n')

Churn Status Classification:
| Label | Condition |
|---|---|
| Low Risk | churn_score <= Q1 (25th percentile) |
| Medium Risk | Q1 < churn_score <= Q3 (75th percentile) |
| High Risk | churn_score > Q3 (75th percentile) |

---

## 2. SQL Analytics (MySQL)

| # | View / Query | Business Question |
|---|---|---|
| 1 | Revenue by churn_status | How much revenue is at risk per segment? |
| 2 | high_risk_customers (VIEW) | Which active customers are most likely to churn? |
| 3 | Senior citizen filter | Which senior citizens are still active? |
| 4 | Churn by gender & senior | Who churned — gender and senior breakdown? |
| 5 | Churn reasons analysis | Why are customers leaving? |
| 6 | revenue_loss_by_city (VIEW) | Which cities lost the most revenue? |
| 7 | Revenue rank by internet+tech | Which service combos generate most revenue? |
| 8 | churn_rate (VIEW) | What is churn rate by contract type? |
| 9 | Partner revenue by city | How much do partner customers generate? |
| 10 | high_value_lost_customer (VIEW) | Which churned customers had highest value? |
| 11 | cohort_analysis (VIEW) | How does churn vary by customer tenure? |
| 12 | retention_rate (VIEW) | What is retention rate by contract? |
| 13 | cumulative_revenue (VIEW) | What is running total revenue by tenure? |

---

## 3. Workflow Automation (n8n)

Three parallel pipelines run on a Schedule Trigger:

Pipeline 1: high_risk_customers VIEW → Google Sheets (426 records)
Pipeline 2: cohort_analysis VIEW → Google Sheets (5 records)
Pipeline 3: cumulative_revenue VIEW → Google Sheets (73 records)

Nodes used:
- Schedule Trigger — starts all pipelines
- MySQL Execute Query — fetches data from SQL views
- Edit Fields — maps field names for Sheets
- Aggregate — batches records for insert
- Google Sheets: Append or Update Row — writes data
- Send a Message — notifies on completion

---

## 4. Dashboard (Power BI)

KPI Cards:
- Monthly Revenue at Risk: 26.16K
- High Risk Customers Count: 438
- Average Monthly Revenue: 236.18K

Visualizations:
| Chart | Insight |
|---|---|
| cohort_group vs churn | 0-1 Year customers have 55% churn rate |
| Count by churn_status | 50% High Risk, 25% Medium, 25% Low |
| Revenue at Risk by City | Los Angeles has highest revenue at risk |
| Customer Risk vs Revenue | High churn score = high monthly charges |
| Churn Score by Internet Service | Fiber Optic users have highest churn scores |
| cohort_group vs avg_risk_score | Risk score drops as tenure increases |

Filters: Gender Slicer | City Slicer

---

## Key Business Insights
| Finding | Recommendation |
|---|---|
| 0-1 Year cohort has 55% churn rate | Improve onboarding & early engagement |
| Fiber Optic has highest churn scores | Review Fiber Optic pricing & service quality |
| Los Angeles drives most revenue at risk | Launch targeted retention campaigns in LA |
| 50% of customers are High Risk | Immediate intervention needed at scale |
| Risk score drops after 2+ years tenure | Incentivize long-term contracts |

---

## Setup & Reproduction
1. Run Python script to clean data and export CSV
2. Execute SQL script to create DB, table, and load CSV
3. Run all SQL views and validate results
4. Configure n8n with MySQL and Google Sheets credentials
5. Connect Power BI to MySQL or Google Sheets and refresh

---

Stack: Python | MySQL | n8n | Google Sheets | Power BI