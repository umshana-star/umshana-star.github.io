# Financial Performance & Profitability Intelligence Dashboard

## Project Overview
This project is an enterprise-level Power BI Financial Analytics solution designed for CFOs and Financial Analysts to monitor company performance, investigate profitability leaks, and forecast future trends.

## Features
- **Executive Overview:** High-level KPIs (Revenue, Profit, Margin, Growth).
- **Profit & Loss Analysis:** Deep dive into loss-making products and regions using Waterfall charts and Decomposition Trees.
- **Sales Performance:** Monthly and quarterly trends with interactive forecasting.
- **Operational Efficiency:** Analysis of shipping costs and discount impacts.
- **Automated KPI Monitoring:** Conditional formatting for critical alerts.

## Repository Structure
- `data/`: Contains the raw dataset (`global_ecommerce_sales.csv`) and the filtered Q1 dataset (`Sales_Q1.csv`).
- `sql/`: Data cleaning and transformation scripts.
- `dax/`: Advanced DAX measures library.
- `docs/`: KPI documentation, Business insights, and visual reports.
- `analyze_q1.py`: Python script used for Trend Analysis.

## Technologies Used
- **Microsoft Power BI:** Dashboarding and Data Modeling.
- **SQL:** Data cleaning and validation.
- **DAX:** Advanced business logic calculations.
- **Python (Pandas/Matplotlib):** Exploratory data analysis and trend visualization.
- **Excel:** Report exporting.

## Business Insights Summary
- **Primary Profit Drivers:** Technology category (Headphones, Keyboards).
- **Major Profit Leaks:** High shipping costs for Furniture in European regions.
- **Recommendation:** Implement a tiered discount policy to protect margins on low-margin products.

## How to Use
1. Run the `sql/data_cleaning.sql` script on your database.
2. Import the cleaned data into Power BI.
3. Apply the DAX measures provided in `dax/measures.dax`.
4. Use the `docs/KPI_Documentation.md` to set up visual alerts.

---
*Developed as part of the Financial Intelligence Initiative.*
