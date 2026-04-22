-- ============================================================
-- AFFILIATE COMMISSION RECONCILIATION — SQL SCRIPT
-- Author  : Kwanda Zama | Financial & BI Analyst
-- Dataset : ecommerce_sales_34500 (34,500 transactions)
-- Purpose : Extract, validate, and reconcile affiliate
--           commission payments against expected values
-- Tools   : SQL (compatible with SQL Server / PostgreSQL)
-- ============================================================


-- ============================================================
-- SECTION 1: DATA EXTRACTION & BASE VIEW
-- ============================================================

-- 1.1 Base transactions with commission calculation
SELECT
    t.order_id,
    t.order_date,
    t.customer_id,
    t.category,
    t.region,
    t.total_amount,
    t.returned,
    a.affiliate_name,
    a.commission_rate,
    ROUND(t.total_amount * a.commission_rate, 2)        AS expected_commission,
    p.actual_amount_paid                                 AS actual_commission_paid,
    ROUND(
        (t.total_amount * a.commission_rate) - p.actual_amount_paid, 2
    )                                                    AS variance,
    ROUND(
        ((t.total_amount * a.commission_rate) - p.actual_amount_paid)
        / NULLIF(t.total_amount * a.commission_rate, 0) * 100, 2
    )                                                    AS variance_pct

FROM transactions t
INNER JOIN affiliate_master a
    ON t.affiliate_id = a.affiliate_id
LEFT JOIN commission_payments p
    ON t.order_id = p.order_id

WHERE t.order_date BETWEEN '2023-09-01' AND '2025-09-30'
ORDER BY t.order_date DESC;


-- ============================================================
-- SECTION 2: EXECUTIVE KPI SUMMARY
-- ============================================================

SELECT
    COUNT(*)                                            AS total_orders,
    ROUND(SUM(total_amount), 2)                         AS total_revenue,
    ROUND(SUM(expected_commission), 2)                  AS total_expected_commission,
    ROUND(SUM(actual_commission_paid), 2)               AS total_actual_paid,
    ROUND(SUM(variance), 2)                             AS total_variance,
    ROUND(SUM(variance) / SUM(expected_commission) * 100, 2) AS variance_pct_overall,
    ROUND(SUM(total_amount) - SUM(actual_commission_paid), 2) AS net_profit,
    SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END)  AS returned_orders,
    ROUND(
        SUM(CASE WHEN returned = 'Yes' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2
    )                                                    AS return_rate_pct

FROM vw_commission_reconciliation;  -- The view from Section 1


-- ============================================================
-- SECTION 3: MONTHLY REVENUE & COMMISSION TREND
-- ============================================================

SELECT
    FORMAT(order_date, 'yyyy-MM')                       AS month,
    COUNT(*)                                            AS orders,
    ROUND(SUM(total_amount), 2)                         AS revenue,
    ROUND(SUM(expected_commission), 2)                  AS expected_commission,
    ROUND(SUM(actual_commission_paid), 2)               AS actual_commission_paid,
    ROUND(SUM(variance), 2)                             AS monthly_variance,
    -- Month-over-Month revenue growth
    ROUND(
        (SUM(total_amount) - LAG(SUM(total_amount), 1)
            OVER (ORDER BY FORMAT(order_date, 'yyyy-MM')))
        / NULLIF(LAG(SUM(total_amount), 1)
            OVER (ORDER BY FORMAT(order_date, 'yyyy-MM')), 0) * 100, 2
    )                                                    AS mom_revenue_growth_pct

FROM vw_commission_reconciliation
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month ASC;


-- ============================================================
-- SECTION 4: AFFILIATE PERFORMANCE TABLE
-- ============================================================

SELECT
    affiliate_name,
    COUNT(*)                                            AS total_orders,
    ROUND(SUM(total_amount), 2)                         AS total_revenue,
    MAX(commission_rate) * 100                          AS commission_rate_pct,
    ROUND(SUM(expected_commission), 2)                  AS expected_commission,
    ROUND(SUM(actual_commission_paid), 2)               AS actual_commission_paid,
    ROUND(SUM(variance), 2)                             AS total_variance,
    ROUND(SUM(variance) / SUM(expected_commission) * 100, 2) AS variance_pct,
    ROUND(SUM(total_amount) / SUM(SUM(total_amount)) OVER () * 100, 2) AS revenue_share_pct,
    -- Performance tier classification
    CASE
        WHEN SUM(total_amount) > 400000 THEN 'Top Tier'
        WHEN SUM(total_amount) > 200000 THEN 'Mid Tier'
        ELSE 'Low Tier'
    END                                                  AS performance_tier

FROM vw_commission_reconciliation
GROUP BY affiliate_name, commission_rate
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 5: ANOMALY DETECTION — FLAG TRANSACTIONS
-- ============================================================

-- 5.1 Flag all transactions with variance > ±20%
SELECT
    order_id,
    order_date,
    affiliate_name,
    category,
    region,
    total_amount,
    expected_commission,
    actual_commission_paid,
    variance,
    variance_pct,
    -- Severity classification
    CASE
        WHEN ABS(variance_pct) > 60 THEN 'HIGH'
        WHEN ABS(variance_pct) > 40 THEN 'MEDIUM'
        WHEN ABS(variance_pct) > 20 THEN 'LOW'
        ELSE 'CLEAN'
    END                                                  AS anomaly_severity,
    -- Direction
    CASE
        WHEN variance > 0 THEN 'UNDERPAYMENT'
        WHEN variance < 0 THEN 'OVERPAYMENT'
        ELSE 'EXACT'
    END                                                  AS payment_status

FROM vw_commission_reconciliation
WHERE ABS(variance_pct) > 20
ORDER BY ABS(variance_pct) DESC;


-- 5.2 Anomaly summary by affiliate
SELECT
    affiliate_name,
    COUNT(*)                                            AS anomaly_count,
    ROUND(SUM(ABS(variance)), 2)                        AS total_amount_at_risk,
    ROUND(AVG(ABS(variance_pct)), 2)                    AS avg_variance_pct,
    SUM(CASE WHEN ABS(variance_pct) > 60 THEN 1 ELSE 0 END) AS high_severity_count,
    SUM(CASE WHEN variance > 0 THEN 1 ELSE 0 END)      AS underpayment_count,
    SUM(CASE WHEN variance < 0 THEN 1 ELSE 0 END)      AS overpayment_count

FROM vw_commission_reconciliation
WHERE ABS(variance_pct) > 20
GROUP BY affiliate_name
ORDER BY anomaly_count DESC;


-- 5.3 Spike detection — months with anomaly count > average
WITH monthly_anomalies AS (
    SELECT
        FORMAT(order_date, 'yyyy-MM')                   AS month,
        COUNT(*)                                        AS anomaly_count
    FROM vw_commission_reconciliation
    WHERE ABS(variance_pct) > 20
    GROUP BY FORMAT(order_date, 'yyyy-MM')
),
avg_anomalies AS (
    SELECT AVG(anomaly_count * 1.0) AS avg_monthly_anomalies
    FROM monthly_anomalies
)
SELECT
    m.month,
    m.anomaly_count,
    a.avg_monthly_anomalies,
    CASE
        WHEN m.anomaly_count > a.avg_monthly_anomalies * 1.5 THEN '🚨 SPIKE'
        WHEN m.anomaly_count > a.avg_monthly_anomalies THEN '⚠ ELEVATED'
        ELSE '✅ NORMAL'
    END                                                  AS spike_status

FROM monthly_anomalies m
CROSS JOIN avg_anomalies a
ORDER BY m.month ASC;


-- ============================================================
-- SECTION 6: RECONCILIATION REPORT — MISSING TRANSACTIONS
-- ============================================================

-- Identify orders in transactions table but NOT in commission_payments
SELECT
    t.order_id,
    t.order_date,
    a.affiliate_name,
    t.total_amount,
    ROUND(t.total_amount * a.commission_rate, 2)        AS expected_commission,
    'MISSING PAYMENT RECORD'                             AS issue_type

FROM transactions t
INNER JOIN affiliate_master a
    ON t.affiliate_id = a.affiliate_id
LEFT JOIN commission_payments p
    ON t.order_id = p.order_id
WHERE p.order_id IS NULL
  AND t.order_date BETWEEN '2023-09-01' AND '2025-09-30'
ORDER BY t.order_date DESC;


-- ============================================================
-- SECTION 7: RETURNED ORDERS — COMMISSION CLAW-BACK
-- ============================================================

-- Commissions paid on subsequently returned orders
SELECT
    t.order_id,
    t.order_date,
    a.affiliate_name,
    t.total_amount,
    p.actual_amount_paid                                AS commission_paid,
    'CLAW-BACK REQUIRED'                                AS action_required

FROM transactions t
INNER JOIN affiliate_master a
    ON t.affiliate_id = a.affiliate_id
INNER JOIN commission_payments p
    ON t.order_id = p.order_id
WHERE t.returned = 'Yes'
  AND p.actual_amount_paid > 0
ORDER BY p.actual_amount_paid DESC;


-- ============================================================
-- SECTION 8: CATEGORY & REGION BREAKDOWN
-- ============================================================

SELECT
    category,
    region,
    COUNT(*)                                            AS orders,
    ROUND(SUM(total_amount), 2)                         AS revenue,
    ROUND(SUM(expected_commission), 2)                  AS expected_commission,
    ROUND(SUM(actual_commission_paid), 2)               AS actual_paid,
    ROUND(SUM(variance), 2)                             AS variance,
    SUM(CASE WHEN ABS(variance_pct) > 20 THEN 1 ELSE 0 END) AS anomaly_count

FROM vw_commission_reconciliation
GROUP BY ROLLUP(category, region)
ORDER BY category, region;


-- ============================================================
-- END OF SCRIPT
-- Kwanda Zama | github.com/umshana-star
-- ============================================================
