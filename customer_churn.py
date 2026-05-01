import pandas as pd
import numpy as np
df=pd.read_excel('Telco_customer_churn.xlsx')
# Converting column name to lowercase and replacing spaces with underscores
df.columns=df.columns.str.lower().str.replace(' ','_')
print(df.head(10))
# Confirming data types of numeric columns and checking for any inconsistencies
print(f"data type of total_charges: {df['total_charges'].dtype}")
print(f"data type of monthly_charges: {df['monthly_charges'].dtype}")
print(f"data type of churn_score: {df['churn_score'].dtype}")
# Stripping leading and trailing spaces 
df['total_charges']=df['total_charges'].astype(str).str.strip()
df['total_charges']=df['total_charges'].replace('',np.nan)
# Converting object to numeric (total_charges ), coercing errors to NaN
df['total_charges']=pd.to_numeric(df['total_charges'],errors='coerce')
# Checking for missing values
print(df.isnull().sum())
# Filling missing values in total charges with the mean of the column
df.loc[df['tenure_months']==0,'total_charges']=0
df['total_charges']=df['total_charges'].fillna(df['total_charges'].median())
print(df.isnull().sum())
# Checking for duplicates in customerid column
print(df['customerid'].duplicated().sum())
# Dropping duplicates if any
df.drop_duplicates(subset='customerid',inplace=True)
# Filling missing values in churn reason with Unknown
df['churn_reason']=df['churn_reason'].fillna('Unknown')
# Ensuring missing values again in dataset
print(df.isnull().sum())
# Performin EDA on churn score to understand distribution and central tendency
print(df.describe()[['churn_score']])
# Performing IQR method to identify outliers in churn score
Q1=df['churn_score'].quantile(0.25)
Q3=df['churn_score'].quantile(0.75)
IQR=Q3-Q1
Lower_bound=Q1-1.5*IQR
Upper_bound=Q3+1.5*IQR
print(f"Lower Bound: {Lower_bound}")
print(f"Upper Bound: {Upper_bound}")    
# Creating new column for risk based on churn score
df['churn_status']=pd.cut(df['churn_score'],bins=[-1,Q1,Q3,float('inf')],labels=['Low Risk','Medium Risk','High Risk'])
df.to_csv('Cleaned_Telco_customer_churn.csv',index=False)