CREATE OR REFRESH MATERIALIZED VIEW silver_billing_clean (
  CONSTRAINT valid_quantity   EXPECT (quantity > 0)    ON VIOLATION DROP ROW,
  CONSTRAINT valid_unit_price EXPECT (unit_price >= 0) ON VIOLATION DROP ROW
) AS
SELECT DISTINCT
  bill_id,
  visit_id,
  patient_id,
  COALESCE(INITCAP(TRIM(department)), 'Unknown')   AS department,
  INITCAP(TRIM(service_category))                   AS service_category,
  COALESCE(total_amount, quantity * unit_price)    AS total_amount,
  INITCAP(TRIM(patient_gender))                    AS patient_gender,
  patient_age,
  visit_date,
  INITCAP(TRIM(visit_type))                        AS visit_type,
  INITCAP(TRIM(doctor_name))                       AS doctor_name,
  INITCAP(TRIM(service_name))                     AS service_name,
  INITCAP(TRIM(hospital_branch))                   AS hospital_branch,
  COALESCE(INITCAP(TRIM(city)), 'Unknown')        AS city,
  INITCAP(TRIM(region))                            AS region,
  COALESCE(INITCAP(TRIM(payer_type)), 'Unknown')   AS payer_type,
  quantity,
  unit_price,
  insurance_amount,
  INITCAP(TRIM(payment_status))                    AS payment_status,
  source_file,
  loaded_at
FROM bronze_hospital_billing;
 
CREATE OR REFRESH MATERIALIZED VIEW silver_billing_rejected AS
SELECT *,
  CASE WHEN quantity <= 0 THEN 'Quantity is zero or negative'
       ELSE 'Unit price is negative' END AS reject_reason
FROM bronze_hospital_billing
WHERE quantity <= 0 OR unit_price < 0;
