# 📊 Financial & BI Analysis — Affiliate Revenue & Reconciliation

> **Portfolio Project by Kwanda Zama** | Financial & BI Analyst | Durban, KZN  
> 🔗 [Live Dashboard](https://umshana-star.github.io/Financial_BI_Dashboard.html) · [Portfolio](https://umshana-star.github.io) · [LinkedIn](https://www.linkedin.com/in/kwanda-zama)

---

## 📌 Problem Statement

Companies operating affiliate marketing programmes lose significant revenue due to:
- **Incorrect commission payments** — overpaying or underpaying partners
- **Poor visibility** into which affiliates are truly performing
- **No automated detection** of anomalous transactions before payouts are processed
- **Manual reconciliation** processes that are slow, error-prone, and audit-unfriendly

This project addresses all four problems with a structured BI solution.

---

## 🎯 Objective

| Goal | Outcome |
|------|---------|
| Analyse affiliate revenue & commission performance | ✅ 15-partner breakdown with rate, revenue, and efficiency metrics |
| Detect commission discrepancies before payout | ✅ Expected vs Actual reconciliation with R2,013 variance identified |
| Flag anomalous transactions automatically | ✅ 705 transactions (2.0%) flagged above ±20% threshold |
| Improve financial transparency for management | ✅ Executive overview with monthly trend, regional & category breakdown |

---

## 🔍 Key Insights

| Insight | Detail |
|---------|--------|
| 📈 **Top 5 affiliates = 57.3% of revenue** | AffiliateHub_ZA, PriceCheck_SA, Takealot_API, BidOrBuy_SA, Zando_Partner |
| ⚠️ **R2,013 commission overpayment detected** | Across the full 2-year period (Sep 2023 – Sep 2025) |
| 🚨 **705 transactions flagged** | 2.0% of all transactions exceed ±20% variance threshold |
| 💸 **Commission leakage concentrated** | Zando_Partner (–R294) and AffiliateHub_ZA (–R330) highest cumulative variance |
| 📦 **Electronics = largest revenue category** | R1.09M (18.6% of total) with highest anomaly concentration |
| 🔄 **5.5% return rate** | 1,897 orders returned — impacts net commission liability |
| 🏆 **98.0% commission accuracy** | 33,795 transactions processed within acceptable tolerance |

---

## 📐 Dashboard Structure (4 Pages)

### 📊 Page 1 — Executive Financial Overview
- Total Revenue, Orders, Net Profit, Commission Paid, Return Rate (KPI cards)
- Monthly Revenue & Commission Trend (combo bar/line chart)
- Revenue by Category (donut chart)
- Revenue by Region (horizontal bar)
- Monthly Profit Margin % trend

### 🤝 Page 2 — Affiliate Analysis
- Revenue, commission, and order count per affiliate (15 partners)
- Commission Rate vs Revenue scatter plot
- Performance ranking: Top / Mid / Low tier classification
- Full affiliate performance table with variance per partner

### ⚖️ Page 3 — Reconciliation Dashboard *(Core financial control page)*
- Expected Commission vs Actual Paid (monthly line chart)
- Monthly Variance waterfall (positive/negative colour-coded)
- Variance by affiliate partner (horizontal bar)
- Commission accuracy rate (98.0% clean / 2.0% flagged)
- **Alert:** R2,013 overpayment detected across full period

### 🚨 Page 4 — Anomaly Detection
- Anomaly count by month (bar chart)
- Anomaly distribution by product category (donut)
- Full anomaly log with severity classification (HIGH / MED / LOW)
- Threshold: ±20% variance from expected commission rate
- **705 transactions flagged** for immediate review

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|------|-------|
| **Power BI** | Dashboard design, DAX measures, data modelling |
| **SQL** | Data extraction, validation, reconciliation queries |
| **Python (Pandas)** | Data preprocessing, commission simulation, anomaly detection |
| **DAX** | Calculated measures (Variance %, MoM Growth, Avg Commission) |
| **Excel / Power Query** | Data cleaning, M-language transformations |

---

## 🧮 DAX Measures (Key)

```dax
-- Total Revenue
Total Revenue = SUM(transactions[total_amount])

-- Total Expected Commission
Total Expected Commission = SUMX(transactions, transactions[total_amount] * transactions[commission_rate])

-- Total Actual Commission Paid
Total Actual Paid = SUM(transactions[actual_commission_paid])

-- Variance
Commission Variance = [Total Expected Commission] - [Total Actual Paid]

-- Variance %
Variance % = DIVIDE([Commission Variance], [Total Expected Commission]) * 100

-- Month-over-Month Revenue Growth
MoM Revenue Growth % = 
VAR CurrentMonth = [Total Revenue]
VAR PrevMonth = CALCULATE([Total Revenue], DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PrevMonth, PrevMonth) * 100

-- Avg Commission per Affiliate
Avg Commission per Affiliate = DIVIDE([Total Actual Paid], DISTINCTCOUNT(transactions[affiliate]))

-- Anomaly Flag
Is Anomaly = IF(ABS([Variance %]) > 20, "Flagged", "Clean")

-- Profit after Commission
Net Profit = [Total Revenue] - [Total Actual Paid]
```

---

## 🗃️ Data Model (Star Schema)

```
        ┌─────────────┐
        │  Date Table  │
        └──────┬──────┘
               │
┌──────────┐   │   ┌───────────────┐
│ Affiliate │───┼───│  Fact_Orders  │───┬─── ┌──────────────┐
│  (Dim)   │   │   │  (34,500 rows)│   │    │  Category    │
└──────────┘   │   └───────────────┘   │    │    (Dim)     │
               │                       │    └──────────────┘
        ┌──────┴──────┐                │
        │  Region Dim  │               └─── ┌──────────────┐
        └─────────────┘                     │   Payment    │
                                            │    (Dim)     │
                                            └──────────────┘
```

**Fact table relationships:**
- `Fact_Orders[affiliate]` → `Dim_Affiliate[affiliate_id]`
- `Fact_Orders[order_date]` → `Dim_Date[date]`
- `Fact_Orders[category]` → `Dim_Category[category_id]`
- `Fact_Orders[region]` → `Dim_Region[region_id]`

---

## 🚀 Business Recommendations

Based on the analysis, the following actions are recommended:

1. **Implement pre-payout validation** — Run automated SQL checks against commission calculations before processing affiliate payments. Flag any variance >5% for manual review.

2. **High-variance affiliate review** — Zando_Partner and AffiliateHub_ZA show the highest cumulative variance. Commission agreement terms should be re-audited.

3. **Anomaly escalation workflow** — Transactions classified as HIGH severity (variance >50%) should trigger an immediate hold and escalation to the Financial Control Manager.

4. **Bottom-tier affiliate strategy** — Dischem_Online (R62K revenue, 346 orders) is significantly underperforming vs contract cost. Consider renegotiating terms or deactivating.

5. **Return rate monitoring** — 5.5% return rate (1,897 orders) means commission may have been paid on subsequently reversed transactions. Implement commission claw-back logic.

6. **Risk register update** — Add affiliate commission leakage as a quantified risk item (R2,013 detected, extrapolated annually ≈ R1,200/year based on trend).

---

## 📁 Repository Structure

```
Financial-BI-Affiliate-Analysis/
│
├── Financial_BI_Dashboard.html     # Interactive 4-page Power BI-style dashboard
├── processed_affiliate_data.csv    # Cleaned + enriched dataset with commission fields
├── affiliate_commission_queries.sql # SQL extraction and reconciliation scripts
├── README.md                       # This file
│
└── assets/
    └── dashboard-preview.png       # Dashboard screenshot (add after export)
```

---

## 📊 Dataset

| Dataset | Source | Records | Period |
|---------|--------|---------|--------|
| `ecommerce_sales_34500.csv` | Kaggle (Online Retail) | 34,500 orders | Sep 2023 – Sep 2025 |
| `amazon_sales_dataset.csv` | Kaggle (Amazon Sales) | 10,000 orders | Jan–Feb 2026 |

Commission rates, affiliate assignments, and payout variances were simulated to model a real-world affiliate programme reconciliation scenario.

---

## 👤 Author

**Kwanda Zama** | Financial & BI Analyst  
📍 Durban, KwaZulu-Natal, South Africa  
🔗 [GitHub](https://github.com/umshana-star) · [Portfolio](https://umshana-star.github.io) · [LinkedIn](https://www.linkedin.com/in/kwanda-zama) · [Data Portfolio](https://datascienceportfol.io/kwandazama01)

---

*Built with Power BI principles · SQL · DAX · Python · Relevant to Financial & BI Analyst roles in financial services and betting industry analytics.*
