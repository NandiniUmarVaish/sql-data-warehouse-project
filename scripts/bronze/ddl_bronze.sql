/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

DROP TABLE IF EXISTS db_bronze.crm_cust_info;
CREATE TABLE db_bronze.crm_cust_info(
	cst_id					      	 INT,
	cst_key					      	 NVARCHAR(50),
  cst_firstname			    	 NVARCHAR (50),
  cst_lastname 			    	 NVARCHAR(50),
  cst_marital_status			 NVARCHAR(50),
  cst_gndr					       NVARCHAR(50),
  cst_create_date 			    DATE 
);

DROP TABLE IF EXISTS db_bronze.crm_prd_info;
CREATE TABLE db_bronze.crm_prd_info(
	  prd_id 			  	INT,
    prd_key 			  NVARCHAR(50),
    prd_nm 				  NVARCHAR(50),
    prd_cost  			INT,
    prd_line  			NVARCHAR(20),
    prd_start_dt 		DATETIME,
    prd_end_dt 			DATETIME
);


DROP TABLE IF EXISTS db_bronze.crm_sales_details;
CREATE TABLE db_bronze.crm_sales_details(
	  sls_order_nm 		NVARCHAR(30) ,
    sls_prd_key  		NVARCHAR(30) ,
    sls_cust_id 		INT,
    sls_order_dt 		DATETIME,
    sls_ship_dt			DATETIME,
    sls_due_dt 			DATETIME,
    sls_sales 			INT,
    sls_quantity 		INT ,
    sls_price 			INT
);

DROP TABLE IF EXISTS db_bronze.erp_cust_az12;
CREATE TABLE db_bronze.erp_cust_az12(
	  cid 				NVARCHAR(30),
    bdate   		DATETIME ,
    gen  				NVARCHAR(20)
);



DROP TABLE IF EXISTS db_bronze.erp_loc_a101;
CREATE TABLE db_bronze.erp_loc_a101(
	  cid   				NVARCHAR(30),
    cntry 				NVARCHAR(30)
);




DROP TABLE IF EXISTS db_bronze.erp_px_cat_g1v2;
CREATE TABLE db_bronze.erp_px_cat_g1v2(
	id     					NVARCHAR(20),
  cat 		    		NVARCHAR(30),
  subcat 			  	NVARCHAR(30),
  maintenance 		NVARCHAR(10)
);




