/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL db_silver.load_silver();
===============================================================================
*/


DROP PROCEDURE IF EXISTS db_silver.load_silver;
DELIMITER //
CREATE PROCEDURE db_silver.load_silver()
	BEGIN
		DECLARE start_time DATETIME;
		DECLARE end_time DATETIME;
		DECLARE batch_start_time DATETIME;
		DECLARE batch_end_time DATETIME;
		DECLARE err_msg TEXT;

		-- Handle Error
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 err_msg = MESSAGE_TEXT;
			SELECT CONCAT('ERROR: ', err_msg) AS error_message;
		END;
		
		SET batch_start_time = NOW();
		
		SELECT '====================================' AS msg;
		SELECT 'Loading Silver Layer' AS msg;
		SELECT '====================================' AS msg;
		
		SELECT '====================================' AS msg;
		SELECT 'Loading CRM Table' AS msg;
		SELECT '====================================' AS msg;
		
		-- Loading silver.crm_cust_info
		SET start_time = NOW();
		SELECT '>> Truncating Table: db_silver.crm_cust_info' as msg;
		TRUNCATE TABLE db_silver.crm_cust_info;
		SELECT '>> Inserting Data Into: db_silver.crm_cust_info' as msg;
		INSERT INTO db_silver.crm_cust_info(
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr, 
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM db_bronze.crm_cust_info
			WHERE cst_id <> 0) t
		WHERE flag_last = 1;
		
        SET end_time = NOW();
		SELECT CONCAT('crm_cust_info Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' second') AS msg;
		
		-- Loading silver.crm_prd_info
		SET start_time = NOW();
		SELECT '>> Truncating Table: db_silver.crm_prd_info' as msg;
		TRUNCATE TABLE db_silver.crm_prd_info;
		SELECT '>> Inserting Data Into: db_silver.crm_prd_info' as msg;
		INSERT INTO db_silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract Category ID
			SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key, -- Extract Product ID
			prd_nm,
			IFNULL(prd_cost, 0) AS prd_cost,
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				ELSE 'n/a'
			END AS prd_line, -- Map product line codes to descriptive values
			CAST(prd_start_dt as DATE) AS prd_start_dt,
			CAST(
				DATE_SUB(
					LEAD(prd_start_dt) OVER (
						PARTITION BY prd_key
						ORDER BY prd_start_dt
					),
					INTERVAL 1 DAY
				) AS DATE
			) AS prd_end_dt -- Calculate end date as one day before the next start date
		FROM db_bronze.crm_prd_info;

		SET end_time = NOW();
        SELECT CONCAT('crm_prd_info Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' second') AS msg;

		-- Loading silver.crm_sales_details
		SET start_time = NOW();
		SELECT '>> Truncating Table: db_silver.crm_sales_details' as msg;
		TRUNCATE TABLE db_silver.crm_sales_details;
		SELECT '>> Inserting Data Into: db_silver.crm_sales_details' as msg;
		INSERT INTO db_silver.crm_sales_details (
			sls_order_nm,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_order_nm,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			CASE
				WHEN sls_sales IS NULL
					 OR sls_sales <= 0
					 OR sls_sales <> (sls_quantity * ABS(sls_price))
				THEN COALESCE(sls_quantity, 0) * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sls_quantity,
			sls_price
		FROM (
			SELECT
				sls_order_nm,
				sls_prd_key,
				sls_cust_id,
				CASE 
					WHEN sls_order_dt = 0
						THEN NULL
					ELSE CAST(sls_order_dt AS DATE)
				END AS sls_order_dt,
				CAST(sls_ship_dt AS DATE) AS sls_ship_dt,
				CAST(sls_due_dt AS DATE) AS sls_due_dt,
				sls_sales, 
				sls_quantity,
				CASE 
					WHEN sls_price IS NULL OR sls_price <= 0
						THEN sls_sales / NULLIF(sls_quantity, 0)
					ELSE sls_price  -- Derive price if original value is invalid
				END AS sls_price
			FROM db_bronze.crm_sales_details
		) t;

		SET end_time = NOW();
        SELECT CONCAT('crm_sales_details Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' second') AS msg;

		SELECT '====================================' AS msg;
		SELECT 'Loading ERP Table' AS msg;
		SELECT '====================================' AS msg;

		-- Loading silver.erp_cust_az12
		SET start_time = NOW();
		SELECT '>> Truncating Table: db_silver.erp_cust_az12' as msg;
		TRUNCATE TABLE db_silver.erp_cust_az12;
		SELECT '>> Inserting Data Into: db_silver.erp_cust_az12' as msg;
		INSERT INTO db_silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE 
				WHEN cid like 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > CURRENT_DATE() THEN NULL
				ELSE bdate
			END AS bdate, -- Set future birthdates to NULL
			CASE 
				WHEN gen IS NULL OR TRIM(gen) = '' THEN NULL
				WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
				WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
				ELSE 'n/a'
			END AS gen -- Normalize gender values and handle unknown cases
		FROM db_bronze.erp_cust_az12;

		SET end_time = NOW();
        SELECT CONCAT('erp_cust_az12 Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' second') AS msg;

		-- Loading silver.erp_loc_a101
		SET start_time = NOW();
		SELECT '>> Truncating Table: db_silver.erp_loc_a101' as msg;
		TRUNCATE TABLE db_silver.erp_loc_a101;
		SELECT '>> Inserting Data Into: db_silver.erp_loc_a101' as msg;
		INSERT INTO db_silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE
				WHEN clean_cntry = 'DE' THEN 'Germany'
				WHEN clean_cntry LIKE 'US%' THEN 'United States'
				WHEN clean_cntry = '' THEN 'n/a'
				ELSE clean_cntry
			END AS cntry
		FROM (
			SELECT
				cid,
				UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) AS clean_cntry
			FROM db_bronze.erp_loc_a101
		) t;

		SET end_time = NOW();
        SELECT CONCAT('erp_loc_a101 Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' second') AS msg;

		-- Loading silver.erp_px_cat_g1v2
		SET start_time = NOW();
		SELECT '>> Truncating Table: db_silver.erp_px_cat_g1v2' as msg;
		TRUNCATE TABLE db_silver.erp_px_cat_g1v2;
		SELECT '>> Inserting Data Into: db_silver.erp_px_cat_g1v2' as msg;
		INSERT INTO db_silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM db_bronze.erp_px_cat_g1v2;
		
        SET end_time = NOW();
        SELECT CONCAT('erp_px_cat_g1v2 Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' second') AS msg;
        
        SET batch_end_time = NOW();
        SELECT CONCAT('Total Batch Duration: ', TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time), ' second') AS msg;

	END //
DELIMITER ;


CALL db_silver.load_silver();
