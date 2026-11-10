CREATE OR REFRESH STREAMING TABLE bronze_hospital_billing AS
SELECT *,
       _metadata.file_name AS source_file,
       current_timestamp() AS loaded_at
FROM STREAM read_files(
  '/Volumes/healthcare_catalog/health_care_catelog_billing/healthcare_catalog_billing_raw_files/',
      format => 'csv', 
      header => true
  );
