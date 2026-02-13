/*
====================================================================
 Create MySQL Data Warehouse – Layered Databases
====================================================================

 Script Purpose:
   This script creates a MySQL-based data warehouse using a
   layered database architecture.

   Instead of using schemas (which are treated as databases in MySQL),
   this design separates the data warehouse into three independent
   databases representing common data warehouse layers:

     - db_bronze : Raw data ingestion layer
     - db_silver : Cleaned and transformed data layer
     - db_gold   : Business-ready and aggregated data layer

   This approach follows MySQL best practices and is widely used in
   real-world data engineering projects.

 WARNING:
   Running this script will DROP the following databases if they exist:
     - db_bronze
     - db_silver
     - db_gold

   All data stored in these databases will be permanently deleted.

   ⚠️ Ensure proper backups before executing this script.
====================================================================
*/

-- ---------------------------------------------------------------
-- Step 1: Drop existing data warehouse layer databases (if any)
-- ---------------------------------------------------------------
DROP DATABASE IF EXISTS db_bronze;
DROP DATABASE IF EXISTS db_silver;
DROP DATABASE IF EXISTS db_gold;

-- ---------------------------------------------------------------
-- Step 2: Create Bronze layer database
-- Purpose: Store raw, unprocessed source data
-- ---------------------------------------------------------------
CREATE DATABASE db_bronze;

-- ---------------------------------------------------------------
-- Step 3: Create Silver layer database
-- Purpose: Store cleaned, standardized, and transformed data
-- ---------------------------------------------------------------
CREATE DATABASE db_silver;

-- ---------------------------------------------------------------
-- Step 4: Create Gold layer database
-- Purpose: Store business-ready, aggregated, and analytics data
-- ---------------------------------------------------------------
CREATE DATABASE db_gold;
