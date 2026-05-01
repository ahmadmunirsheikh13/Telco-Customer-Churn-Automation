#  Telecom Customer Churn — Data Cleaning & Feature Engineering Pipeline

##  Project Overview

This project implements a complete data preprocessing pipeline for a telecom customer churn dataset. The goal is to transform raw, inconsistent data into a clean and structured format suitable for analytics, SQL querying, and dashboard development.

---

##  Objectives

* Standardize dataset structure
* Perform data cleaning and preprocessing
* Handle missing values and duplicates
* Convert raw churn score into meaningful risk segments
* Prepare dataset for downstream analytics (SQL / BI tools)

---

##  Dataset

* **Source:** `Telco_customer_churn.xlsx`
* **Type:** Customer-level telecom data
* **Key features:**

  * Customer ID
  * Churn Score
  * Monthly Charges
  * Total Charges
  * Tenure Months
  * Churn Reason

---

##  Pipeline Workflow

---

### 1) Data Loading & Column Standardization

* Loaded dataset using Pandas
* Standardized column names:

  * Removed spaces
  * Converted to lowercase
  * Replaced spaces with underscores

```python id="r1"
df.rename(columns=lambda x: x.strip().replace(' ','_').lower(), inplace=True)
```

---

### 2) Initial Data Inspection (EDA)

Performed basic exploratory analysis:

* Dataset structure (`info`)
* Summary statistics (`describe`)

Purpose:

* Understand schema
* Identify initial inconsistencies

---

### 3) String Cleaning

* Removed leading and trailing spaces from all text columns
* Ensured compatibility with both `object` and `string` datatypes

---

### 4) Numeric Data Processing

* Converted selected columns to numeric
* Handled invalid values using coercion
* Replaced missing values using median imputation

```python id="r2"
df[col] = pd.to_numeric(df[col], errors='coerce')
df[col] = df[col].fillna(df[col].median())
```

---

### 5) Duplicate Handling

* Identified duplicate records using `customerid`
* Retained record with highest churn score (most relevant observation)

---

### 6) Missing Value Handling

* Replaced empty strings and null values in `churn_reason`
* Standardized missing values to `"Unknown"`

```python id="r3"
df['churn_reason'] = df['churn_reason'].replace('', pd.NA).fillna('Unknown')
```

---

### 7) Feature Engineering — Churn Risk Segmentation

Created a new feature `churn_status` based on churn score:

| Churn Score Range | Segment        |
| ----------------- | -------------- |
| ≤ 35              | Low Risk       |
| 36–65             | Potential Risk |
| ≥ 66              | High Risk      |

```python id="r4"
df['churn_status'] = pd.cut(
    df['churn_score'],
    bins=[-1,35,65,float('inf')],
    labels=['Low Risk','Potential Risk','High Risk']
)
```

---

### 8) Final Validation & Export

* Final summary statistics generated
* Clean dataset exported for further analysis

```python id="r5"
df.to_csv('Cleaned_Telco_customer_churn.csv', index=False)
```

---

##  Output

* Cleaned dataset: `Cleaned_Telco_customer_churn.csv`
* Ready for:

  * SQL analysis
  * Power BI / Tableau dashboards
  * Business insights generation

---

##  Key Learnings

* Importance of structured data pipelines
* Difference between raw EDA and post-cleaning analysis
* Proper handling of missing and inconsistent data
* Use of vectorized operations over row-wise functions
* Feature engineering using binning (`pd.cut`)
* Building reproducible analytics workflows

---

##  Next Steps

* Perform SQL-based churn analysis
* Build Power BI dashboard for churn insights
* Identify key drivers of customer churn
* Generate retention strategy recommendations

---

##  Tech Stack

* Python
* Pandas
* NumPy

---



##  Notes

This project simulates a real-world telecom data preprocessing workflow and prepares data for business intelligence and predictive analytics use cases.
