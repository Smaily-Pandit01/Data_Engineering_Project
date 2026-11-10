CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS
SELECT COUNT(*)                                             AS bronze_rows,
       COUNT(*) - COUNT(DISTINCT bill_id)                   AS duplicate_rows,
       SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END)       AS invalid_quantity_rows,
       SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END)  AS missing_department_rows,
       SUM(CASE WHEN unit_price < 0 THEN 1 ELSE 0 END)     AS negative_price_rows,
       SUM(CASE WHEN payer_type IS NULL THEN 1 ELSE 0 END)  AS missing_payer_rows,
       SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS missing_amount_rows,
       (SELECT COUNT(*) FROM silver_billing_clean)          AS clean_rows,
       (SELECT COUNT(*) FROM silver_billing_rejected)       AS rejected_rows
FROM bronze_hospital_billing;


CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_revenue AS
SELECT DATE_TRUNC('MONTH', visit_date) AS visit_month,
       COUNT(DISTINCT visit_id)         AS visits,
       SUM(total_amount)                AS total_revenue,
       SUM(insurance_amount)            AS insurance_amount
FROM silver_billing_clean
GROUP BY DATE_TRUNC('MONTH', visit_date);


CREATE OR REFRESH MATERIALIZED VIEW gold_department_summary AS
SELECT department,
       COUNT(DISTINCT visit_id)                       AS visits,
       COUNT(DISTINCT bill_id)                        AS bills,
       SUM(total_amount)                              AS total_revenue,
       SUM(total_amount) / COUNT(DISTINCT visit_id)  AS avg_revenue_per_visit
FROM silver_billing_clean
GROUP BY department;


CREATE OR REFRESH MATERIALIZED VIEW gold_branch_summary AS
SELECT region,
       city,
       hospital_branch,
       COUNT(DISTINCT visit_id) AS visits,
       SUM(total_amount)       AS total_revenue
FROM silver_billing_clean
GROUP BY region, city, hospital_branch;


CREATE OR REFRESH MATERIALIZED VIEW gold_payer_summary AS
SELECT payer_type,
       COUNT(DISTINCT visit_id)                                              AS visits,
       SUM(total_amount)                                                     AS total_revenue,
       SUM(insurance_amount)                                               AS insurance_amount,
       SUM(CASE WHEN payment_status = 'Pending' THEN total_amount ELSE 0 END) AS pending_amount
FROM silver_billing_clean
GROUP BY payer_type;
