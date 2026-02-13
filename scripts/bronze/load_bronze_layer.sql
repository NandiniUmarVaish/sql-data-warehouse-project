
-- ======================== CONFIGURATION (IMPORTANT) ============================================
-- SHOW VARIABLES LIKE 'local_infile';
-- SET GLOBAL local_infile = 1;

/*
====================================================================================
 Script Name : load_into_bronze.sql
 Layer       : Bronze (Source → Bronze)
 Database    : db_bronze
====================================================================================

 Purpose:
   Load raw source data from CSV files into Bronze-layer tables.

 Design Notes:
   - Uses MySQL bulk loading via LOAD DATA LOCAL INFILE
   - Designed as a standalone script (not a stored procedure)
   - Safe to rerun due to truncate-and-load pattern

 Execution:
   Execute this script in MySQL Workbench or via mysql client.

====================================================================================
*/



-- ===================================================================================
-- Loading Bronze Layer
-- ===================================================================================

SELECT 'Loading Bronze Layer' AS status;

-- ---------------- CRM TABLES -----------------

SELECT 'Loading CRM Tables' AS status;

-- Truncate Table
SELECT 'Truncating crm_cust_info' AS status;
TRUNCATE TABLE db_bronze.crm_cust_info;

-- Insertion in Table
SELECT 'Inserting into crm_cust_info ' AS status;
LOAD DATA LOCAL INFILE 
'D:/Program_Files/MySqlData/MySQL Server 8.0/Uploads/source_crm/cust_info.csv'
INTO TABLE db_bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Validate load
SELECT COUNT(*) AS rows_loaded
FROM db_bronze.crm_cust_info;

--------------------------------------------------
-- Truncate Table
SELECT 'Truncating crm_prd_info' AS status;
TRUNCATE TABLE db_bronze.crm_prd_info;

-- Insertion in Table
SELECT 'Inserting into crm_prd_info ' AS status;
LOAD DATA LOCAL INFILE 
'D:/Program_Files/MySqlData/MySQL Server 8.0/Uploads/source_crm/prd_info.csv'
INTO TABLE db_bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Validate load
SELECT COUNT(*) AS rows_loaded
FROM db_bronze.crm_prd_info;


--------------------------------------------------
-- Truncate Table
SELECT 'Truncating crm_sales_details' AS status;
TRUNCATE TABLE db_bronze.crm_sales_details;

-- Insertion in Table
SELECT 'Inserting into crm_sales_details' AS status;
LOAD DATA LOCAL INFILE 
'D:/Program_Files/MySqlData/MySQL Server 8.0/Uploads/source_crm/sales_details.csv'
INTO TABLE db_bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Validate load
SELECT COUNT(*) AS rows_loaded
FROM db_bronze.crm_sales_details;



-- ---------------- ERP TABLES -----------------

SELECT 'Loading ERP Tables' AS status;

-- Truncate Table
SELECT 'Truncating erp_cust_az12' AS status;
TRUNCATE TABLE db_bronze.erp_cust_az12;

-- Insertion in Table
SELECT 'Inserting into erp_cust_az12' AS status;
LOAD DATA LOCAL INFILE 
'D:/Program_Files/MySqlData/MySQL Server 8.0/Uploads/source_erp/cust_az12.csv'
INTO TABLE db_bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Validate load
SELECT COUNT(*) AS rows_loaded
FROM db_bronze.erp_cust_az12;

---------------------------------------------

-- Truncate Table
SELECT 'Truncating erp_loc_a101' AS status;
TRUNCATE TABLE db_bronze.erp_loc_a101;

-- Insertion in Table
SELECT 'Inserting into erp_loc_a101' AS status;
LOAD DATA LOCAL INFILE 
'D:/Program_Files/MySqlData/MySQL Server 8.0/Uploads/source_erp/loc_a101.csv'
INTO TABLE db_bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Validate load
SELECT COUNT(*) AS rows_loaded
FROM db_bronze.erp_loc_a101;

-----------------------------------------------------

-- Truncate Table
SELECT 'Truncating erp_px_cat_g1v2' AS status;
TRUNCATE TABLE db_bronze.erp_px_cat_g1v2;

-- Insertion in Table
SELECT 'Inserting into erp_px_cat_g1v2' AS status;
LOAD DATA LOCAL INFILE 
'D:/Program_Files/MySqlData/MySQL Server 8.0/Uploads/source_erp/px_cat_g1v2.csv'
INTO TABLE db_bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Validate load
SELECT COUNT(*) AS rows_loaded
FROM db_bronze.erp_px_cat_g1v2;


SELECT 'Bronze layer load completed' AS status;

-- =======================================================================
-- WHY HERE I didn't created Stored Procedures For Data Load 
-- ==========================================================================
-- In MySQL:
-- ✅ LOAD DATA INFILE → Allowed in stored procedures
-- ❌ LOAD DATA LOCAL INFILE → NOT allowed inside stored procedures

-- Why?
-- Because LOCAL is a client-side operation.
-- Stored procedures run on the server side.
-- MySQL does not allow mixing client-side file loading inside server-side routines.

