import pandas as pd
import matplotlib.pyplot as plt
import os

# Load the dataset
file_path = 'Financial_Analytics_Dashboard/data/global_ecommerce_sales.csv'
df = pd.read_csv(file_path)

# Convert Order_Date to datetime
df['Order_Date'] = pd.to_datetime(df['Order_Date'])

# Filter for Q1 2023 (Jan, Feb, Mar)
q1_df = df[(df['Order_Date'] >= '2023-01-01') & (df['Order_Date'] <= '2023-03-31')]

# Save as Sales_Q1.csv as requested
q1_df.to_csv('Financial_Analytics_Dashboard/data/Sales_Q1.csv', index=False)

# Perform Trend Analysis (Sales by Month)
q1_df['Month'] = q1_df['Order_Date'].dt.strftime('%Y-%m')
trend_analysis = q1_df.groupby('Month')['Total_Sales'].sum().reset_index()

# Visualization: Bar Chart
plt.figure(figsize=(10, 6))
plt.bar(trend_analysis['Month'], trend_analysis['Total_Sales'], color='skyblue')
plt.title('Sales Trend - Q1 2023')
plt.xlabel('Month')
plt.ylabel('Total Sales')
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.savefig('Financial_Analytics_Dashboard/docs/Sales_Trend_Q1.png')

# Output to XLSX
trend_analysis.to_excel('Financial_Analytics_Dashboard/docs/TrendAnalysis_Q1.xlsx', index=False)

print("Analysis Complete. Sales_Q1.csv created, Bar chart saved, and XLSX report generated.")
