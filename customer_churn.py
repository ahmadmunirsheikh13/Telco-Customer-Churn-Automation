import pandas as pd
import numpy as np
df=pd.read_excel('Telco_customer_churn.xlsx')
# renaming columns to remove spaces and make them more consistent
df.rename(columns=lambda x: x.strip().replace(' ','_').lower(), inplace=True)
print(f"Printing the first 5 rows of the dataset:\n{df.head()}")
# Checking the structure of the dataset
print(f"Dataset info:\n{df.info()}")
# To remove extra spaces from each column data
df[df.select_dtypes(include=['object','string']).columns]=df.select_dtypes(include=['object','string']).apply(lambda x: x.str.strip())
# Making sure numeric columns are in correct format and handling any non-numeric values by converting them to NaN and filling with 0
numeric_cols=['churn_score','monthly_charges','total_charges','tenure_months']
for col in numeric_cols:
    df[col]=pd.to_numeric(df[col], errors='coerce')
    df[col]=df[col].fillna(df[col].median())
# Checking & removing duplicate customers based on 'Customer ID'
if df['customerid'].duplicated().sum()>0:
    print("Duplicate customers found. Removing duplicates based on 'Customer ID'.")
    df=df.sort_values('churn_score', ascending=False)
    df=df.drop_duplicates(subset='customerid', keep='first')
else:
    print("No duplicate customers found based on 'Customer ID'.")
print(f"Dataset after removing duplicates:\n{df.head()}")
# Summary statistics of the dataset
print(f"Summary statistics of the dataset:\n{df.describe()}")
# Checking for missing values in the dataset
print(f"Number of missing values in each column:\n{df.isnull().sum()}")
# Checking Relationship between Churn Score and Churn Reason
print(df[df['churn_reason'].isnull()]['churn_score'].describe())
# Adding reasons for customers with missing churn reason
df['churn_reason'] = df['churn_reason'].replace('', pd.NA).fillna('Unknown')
# Making Rules for Churn Status based on Churn Reason
df['churn_status']=pd.cut(df['churn_score'], bins=[-1,35,65,float('inf')], labels=['Low Risk','Potential Risk','High Risk'])
print(f"Updated dataset with Churn Status:\n{df[['churn_score','churn_status']].head()}") 
# Creating Cleaned csv file
df.to_csv('Cleaned_Telco_customer_churn.csv', index=False)