/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) check_pk
FROM db_silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 AND cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
	cst_key
FROM db_silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
	cst_gndr
FROM db_silver.crm_cust_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	prd_id,
    COUNT(*) check_pk
FROM db_silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
	prd_nm
FROM db_silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
	prd_cost
FROM db_silver.crm_prd_info
WHERE prd_cost <= 0 OR prd_cost IS NULL;


-- Data Standardization & Consistency
SELECT DISTINCT
	prd_line
FROM db_silver.crm_prd_info;


-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
	prd_start_dt
FROM db_silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    sls_ship_dt
FROM db_silver.crm_sales_details
WHERE sls_ship_dt <= 0 
	OR LENGTH(sls_ship_dt) <> 8
	OR sls_ship_dt < 19000101
	OR sls_ship_dt > 20500101;


-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
	NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM db_silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
	OR sls_order_dt > sls_due_dt;


-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT
	sls_sales,
    sls_quantity,
    sls_price
FROM db_silver.crm_sales_details
WHERE sls_sales <= 0 
	OR sls_quantity <= 0
    OR sls_price <= 0
	OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
	OR sls_sales <> (sls_quantity * sls_price)
ORDER BY sls_sales, sls_quantity, sls_price;

    

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT 
	bdate
FROM db_silver.erp_cust_az12
WHERE bdate < 1926-01-01 OR bdate > CURRENT_DATE();

-- Data Standardization & Consistency
SELECT DISTINCT
	gen
FROM db_silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT
    cntry
FROM db_silver.erp_loc_a101;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
	id
FROM db_silver.erp_px_cat_g1v2
WHERE id <> TRIM(id);

-- Data Standardization & Consistency 
SELECT 
  DISTINCT
  TRIM(REPLACE(REPLACE(maintenance,CHAR(10),''),CHAR(13),'')) AS maintenance
FROM db_bronze.erp_px_cat_g1v2;
