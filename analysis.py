import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

raw = pd.read_csv('../data/banking_customer_churn_dirty.csv')
print('Raw shape:', raw.shape)

# Standardize text
raw['Gender'] = raw['Gender'].astype('string').str.strip().str.title()
raw['Geography'] = raw['Geography'].astype('string').str.strip().str.title().replace({'Germnay':'Germany'})

# Numeric validation
raw.loc[~raw['Age'].between(18,80), 'Age'] = np.nan
raw.loc[~raw['Credit_Score'].between(300,900), 'Credit_Score'] = np.nan
raw.loc[~raw['Num_Products'].between(1,4), 'Num_Products'] = np.nan
raw.loc[raw['Monthly_Transactions'] < 0, 'Monthly_Transactions'] = np.nan

# Remove duplicates
clean = raw.drop_duplicates(subset=['Customer_ID']).copy()

# Missing-value treatment
for col in ['Credit_Score','Balance','Estimated_Salary','Satisfaction_Score']:
    clean[col] = clean[col].fillna(clean[col].median())
clean['Age'] = clean['Age'].fillna(clean['Age'].median())
clean['Num_Products'] = clean['Num_Products'].fillna(clean['Num_Products'].mode()[0])
clean['Monthly_Transactions'] = clean['Monthly_Transactions'].fillna(clean['Monthly_Transactions'].median())

# Business-friendly flags
clean['Active_Status'] = clean['Is_Active_Member'].map({1:'Active',0:'Inactive'})
clean['Churn_Status'] = clean['Churned'].map({1:'Churned',0:'Retained'})
clean['Age_Band'] = pd.cut(clean['Age'], [17,24,34,44,54,64,100], labels=['18-24','25-34','35-44','45-54','55-64','65+'])
clean['High_Risk'] = ((clean['Is_Active_Member']==0) & (clean['Satisfaction_Score']<=2)).astype(int)

# KPIs
print('\nKPIs')
print('Customers:', clean['Customer_ID'].nunique())
print('Churned:', clean['Churned'].sum())
print('Churn rate %:', round(clean['Churned'].mean()*100,2))
print('Average balance:', round(clean['Balance'].mean(),2))
print('Average credit score:', round(clean['Credit_Score'].mean(),2))

print('\nChurn by geography')
print(clean.groupby('Geography')['Churned'].agg(['count','mean']).assign(churn_rate_pct=lambda x:x['mean']*100).sort_values('churn_rate_pct',ascending=False))
print('\nChurn by activity')
print(clean.groupby('Active_Status')['Churned'].mean().mul(100).round(2))
print('\nChurn by products')
print(clean.groupby('Num_Products')['Churned'].mean().mul(100).round(2))

clean.to_csv('../data/banking_customer_churn_clean_python.csv', index=False)
