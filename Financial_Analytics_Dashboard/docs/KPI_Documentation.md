# KPI Documentation: Financial Performance & Profitability

## Executive KPIs
| KPI | Formula | Description | Target |
|-----|---------|-------------|--------|
| **Total Revenue** | `SUM(Sales)` | Total gross income from all transactions. | Growth of 10% MoM |
| **Total Profit** | `SUM(Profit)` | Net income after costs and discounts. | Positive & Growing |
| **Profit Margin %**| `Total Profit / Total Revenue` | Percentage of revenue that is actual profit. | > 15% |
| **Sales Growth %** | `(CM - PM) / PM` | Month-over-month growth in revenue. | > 5% |

## Operational KPIs
| KPI | Formula | Description | Impact |
|-----|---------|-------------|--------|
| **Total Loss** | `SUM(Profit) < 0` | Aggregated losses from unprofitable orders. | Minimize |
| **Shipping Cost Ratio** | `Shipping / Revenue` | Proportion of revenue spent on logistics. | < 8% |
| **Discount Impact** | `Σ(Qty * Price * Disc%)`| Revenue lost due to applied discounts. | Monitor vs. Volume |

## Alert Logic
- **Critical (Red):** Profit Margin < 5% or Sales Growth < -10%.
- **Warning (Yellow):** Profit Margin 5-12% or Sales Growth -10% to 0%.
- **Healthy (Green):** Profit Margin > 15% and Sales Growth > 5%.
