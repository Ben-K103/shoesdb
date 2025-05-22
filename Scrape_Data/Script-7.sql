CREATE TABLE shoes (
    shoe_sku VARCHAR(50) PRIMARY KEY,
    shoe_name VARCHAR(100) NOT NULL,
    shoe_brand VARCHAR(50) NOT NULL,
    shoe_type VARCHAR(50) NOT NULL,
    shoe_gender VARCHAR(50) NOT NULL
);


CREATE TABLE scrape_data (
    scrape_id SERIAL PRIMARY KEY,
    shoe_sku VARCHAR(50) NOT NULL REFERENCES shoes(shoe_sku),
    price NUMERIC(10,2) NOT NULL,
    discount_1_text VARCHAR(50),
    discount_1_weighted SMALLINT,
    discount_2_text VARCHAR(50),
    discount_2_weighted SMALLINT,
    discount_3_text VARCHAR(50),
    discount_3_weighted SMALLINT,
    uk_size_5 SMALLINT CHECK (uk_size_5 IN (0, 1, 2)),
    uk_size_5_5 SMALLINT CHECK (uk_size_5_5 IN (0, 1, 2)),
    uk_size_6 SMALLINT CHECK (uk_size_6 IN (0, 1, 2)),
    uk_size_6_5 SMALLINT CHECK (uk_size_6_5 IN (0, 1, 2)),
    uk_size_7 SMALLINT CHECK (uk_size_7 IN (0, 1, 2)),
    uk_size_7_5 SMALLINT CHECK (uk_size_7_5 IN (0, 1, 2)),
    uk_size_8 SMALLINT CHECK (uk_size_8 IN (0, 1, 2)),
    uk_size_8_5 SMALLINT CHECK (uk_size_7_5 IN (0, 1, 2)),
    uk_size_9 SMALLINT CHECK (uk_size_8 IN (0, 1, 2)),
    uk_size_9_5 SMALLINT CHECK (uk_size_7_5 IN (0, 1, 2)),
    uk_size_10 SMALLINT CHECK (uk_size_8 IN (0, 1, 2)),
    page_ranking SMALLINT NOT NULL,
    website SMALLINT CHECK (website IN (0, 1, 2)),
    scrape_time VARCHAR(50) NOT NULL
);

-- tool to remove all duplicated sku_rows
-- Step 1: Create a temporary table with unique shoe_sku values
CREATE TABLE temp_table AS
SELECT DISTINCT ON (shoe_sku) *
FROM "20250415_marathon_women_shoes_csv" mwsc ;

-- Step 2: Drop the original table
DROP TABLE "20250415_marathon_women_shoes_csv";

-- Step 3: Rename the temporary table to the original table name
ALTER TABLE temp_table RENAME TO "20250415_marathon_women_shoes_csv";

-- Step 4: Add the primary key constraint
ALTER TABLE "20250415_marathon_women_shoes_csv" ADD PRIMARY KEY (shoe_sku);


-- with no duplicates insert new shoes data into shoes table.
INSERT INTO shoes (shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender)
SELECT shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender
FROM "20250414_marathon_women_shoes_csv"

-- use to to insert new shoes data into old shoes data without inputing any duplicates!
INSERT INTO shoes (shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender)
SELECT shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender
FROM "20250415_marathon_women_shoes_csv" s
WHERE NOT EXISTS (
    SELECT 1
    FROM shoes
    WHERE shoe_sku = s.shoe_sku
);

-- now check if shoes table is all goood
select * from shoes s

-- this insert new scrape data into scrape data table
INSERT INTO scrape_data (scrape_id, shoe_sku, price, 
                         discount_1_text, discount_1_weighted, 
                         discount_2_text, discount_2_weighted, 
                         discount_3_text, discount_3_weighted,
                         uk_size_5, uk_size_5_5, uk_size_6, 
                         uk_size_6_5, uk_size_7, uk_size_7_5, 
                         uk_size_8, uk_size_8_5, uk_size_9, 
                         uk_size_9_5, uk_size_10, 
                         page_ranking, website, scrape_time)
SELECT scrape_id, shoe_sku, price, 
       discount_1_text, discount_1_weighted, 
       discount_2_text, discount_2_weighted, 
       discount_3_text, discount_3_weighted,
       uk_size_5, uk_size_5_5, uk_size_6, 
       uk_size_6_5, uk_size_7, uk_size_7_5, 
       uk_size_8, uk_size_8_5, uk_size_9, 
       uk_size_9_5, uk_size_10, 
       page_ranking, website, scrape_time
FROM "20250414_marathon_women_scrape_data_csv";

-- now (20250417) recreate Shoes DB V6 to:
-- DONE?1. Add 20250415 data Marathon & Catalog, Men and Women to shoes and scrape_data
-- DONE 2. Make sure all scrape_id fit
-- 3. Remove any duplicated data rows (make sure pk is pk)
-- 4. Drop all crocs and other similar errors
-- 5. Try fixing PUMA problem

--5. PUMA problem-- can't solve


--DONE 1. insert 20250415 cat_men_shoes ->cat_women_shoes-> mar_women_shoes -> mar_men_shoes
CREATE TABLE temp_table AS
SELECT DISTINCT ON (shoe_sku) *
FROM "20250415_marathon_men_shoes_csv";

-- Step 2: Drop the original table
DROP TABLE "20250415_marathon_men_shoes_csv";

-- Step 3: Rename the temporary table to the original table name
ALTER TABLE temp_table RENAME TO "20250415_marathon_men_shoes_csv";

-- Step 4: Add the primary key constraint
ALTER TABLE "20250415_marathon_men_shoes_csv" ADD PRIMARY KEY (shoe_sku);

-- use to to insert new shoes data into old shoes data without inputing any duplicates!
INSERT INTO shoes (shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender)
SELECT shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender
FROM "20250415_marathon_men_shoes_csv" s
WHERE NOT EXISTS (
    SELECT 1
    FROM shoes
    WHERE shoe_sku = s.shoe_sku
);

-- this adds shoe_type from shoe_name -- 
-- puma corrector --
UPDATE shoes
SET shoe_type = CASE
    WHEN shoe_name ILIKE '%Sneakers%' THEN 'Sneakers'
    WHEN shoe_name ILIKE '%Slip-on%' THEN 'Slip-on Shoes'
    WHEN shoe_name ILIKE '%Hiking Shoes%' THEN 'Hiking Shoes'
    WHEN shoe_name ILIKE '%Running Shoes%' THEN 'Running Shoes'
    WHEN shoe_name ILIKE '%Football Boots%' THEN 'Football Boots'
    WHEN shoe_name ILIKE '%Trainers%' THEN 'Trainers'
    WHEN shoe_name ILIKE '%Sandals%' THEN 'Sandals'
    WHEN shoe_name ILIKE '%Slides%' THEN 'Slides'
    WHEN shoe_name ILIKE '%Football Boots%' THEN 'Football Boots'
    WHEN shoe_name ILIKE '%Basketball Shoes%' THEN 'Basketball Shoes'
    WHEN shoe_name ILIKE '%Driving Shoes%' THEN 'Driving Shoes'
    ELSE shoe_type
END
WHERE shoe_brand = 'PUMA come from PUMA merchant'

-- Chinese Corrector --
UPDATE shoes
SET shoe_type = CASE
    WHEN shoe_type ILIKE '%Ã©Â«ËœÃ§Â­â€™Ã¥Â¸â€ Ã¥Â¸Æ’Ã©Å¾â€¹%' THEN 'Canvas Shoes'
    WHEN shoe_type ILIKE '%Ã§â„¢Â»Ã¥Â±Â±Ã©Å¾â€¹%' THEN 'Hiking Shoes'
    WHEN shoe_type ILIKE '%Ã§ï¿½Æ’Ã©Å¾â€¹%' THEN 'Sport Shoes'
    WHEN shoe_type ILIKE '%Ã¦Â¶Â¼Ã©Å¾â€¹%' THEN 'Sandals'
    WHEN shoe_type ILIKE '%Ã¦Å“ÂªÃ§Å¸Â¥Ã©Â¡Å¾Ã¥Å¾â€¹%' THEN 'Unknown'
    WHEN shoe_type ILIKE '%Ã¦â€¹â€“Ã©Å¾â€¹%' THEN 'Slippers'
    ELSE shoe_type
END

-- check shoe types in shoes --


--change all datetime str in scrape_data to datetime obj--



'''--Now conditions (20/4/2025 19:21)
Shoes table:
1. All 20250415 Marathon/ Cat, Men and Women data entered
2. scrape_data cannot be entered!! Because scrape_ID duplicated!
	2.1 fix all scrape_id by the following rule:
		1/2(marathon/catalog) + 1/2(men/women) + mmdd + scrape order (0,1,2...,n)
		must not over 9 digits! (will int4 error)
	2.2 Try to combine all 20250420 scrape_data into the same table
'''

-- Add all 20250415 Scrape Data to scrape_data--
-- 1. DONE! Insert 20250415 marathon women scrape_da
-- fixed: deleted a row where shoe_sku is unreadable characters
INSERT INTO scrape_data (scrape_id, shoe_sku, price, 
                         discount_1_text, discount_1_weighted, 
                         discount_2_text, discount_2_weighted, 
                         discount_3_text, discount_3_weighted,
                         uk_size_5, uk_size_5_5, uk_size_6, 
                         uk_size_6_5, uk_size_7, uk_size_7_5, 
                         uk_size_8, uk_size_8_5, uk_size_9, 
                         uk_size_9_5, uk_size_10, 
                         page_ranking, website, scrape_time)
SELECT scrape_id, shoe_sku, price, 
       discount_1_text, discount_1_weighted, 
       discount_2_text, discount_2_weighted, 
       discount_3_text, discount_3_weighted,
       uk_size_5, uk_size_5_5, uk_size_6, 
       uk_size_6_5, uk_size_7, uk_size_7_5, 
       uk_size_8, uk_size_8_5, uk_size_9, 
       uk_size_9_5, uk_size_10, 
       page_ranking, website, scrape_time
FROM "20250415_marathon_women_scrape_data_v2_csv";

-- DONE! 2. Insert 20250415 marathon men scrape_data
INSERT INTO scrape_data (scrape_id, shoe_sku, price, 
                         discount_1_text, discount_1_weighted, 
                         discount_2_text, discount_2_weighted, 
                         discount_3_text, discount_3_weighted,
                         uk_size_5, uk_size_5_5, uk_size_6, 
                         uk_size_6_5, uk_size_7, uk_size_7_5, 
                         uk_size_8, uk_size_8_5, uk_size_9, 
                         uk_size_9_5, uk_size_10, 
                         page_ranking, website, scrape_time)
SELECT scrape_id, shoe_sku, price, 
       discount_1_text, discount_1_weighted, 
       discount_2_text, discount_2_weighted, 
       discount_3_text, discount_3_weighted,
       uk_size_5, uk_size_5_5, uk_size_6, 
       uk_size_6_5, uk_size_7, uk_size_7_5, 
       uk_size_8, uk_size_8_5, uk_size_9, 
       uk_size_9_5, uk_size_10, 
       page_ranking, website, scrape_time
FROM "20250415_marathon_men_scrape_data_v2_csv";

--  DONE! 3. Insert 20250415 Catalog men scrape_data
INSERT INTO scrape_data (scrape_id, shoe_sku, price, 
                         discount_1_text, discount_1_weighted, 
                         discount_2_text, discount_2_weighted, 
                         discount_3_text, discount_3_weighted,
                         uk_size_5, uk_size_5_5, uk_size_6, 
                         uk_size_6_5, uk_size_7, uk_size_7_5, 
                         uk_size_8, uk_size_8_5, uk_size_9, 
                         uk_size_9_5, uk_size_10, 
                         page_ranking, website, scrape_time)
SELECT scrape_id, shoe_sku, price, 
       discount_1_text, discount_1_weighted, 
       discount_2_text, discount_2_weighted, 
       discount_3_text, discount_3_weighted,
       uk_size_5, uk_size_5_5, uk_size_6, 
       uk_size_6_5, uk_size_7, uk_size_7_5, 
       uk_size_8, uk_size_8_5, uk_size_9, 
       uk_size_9_5, uk_size_10, 
       page_ranking, website, scrape_time
FROM "20250415_catalog_men_scrape_data_v2_csv";

--  DONE! 4. Insert 20250415 Catalog women scrape_data
-- fixed: deleted a row where shoe_sku is unreadable characters
INSERT INTO scrape_data (scrape_id, shoe_sku, price, 
                         discount_1_text, discount_1_weighted, 
                         discount_2_text, discount_2_weighted, 
                         discount_3_text, discount_3_weighted,
                         uk_size_5, uk_size_5_5, uk_size_6, 
                         uk_size_6_5, uk_size_7, uk_size_7_5, 
                         uk_size_8, uk_size_8_5, uk_size_9, 
                         uk_size_9_5, uk_size_10, 
                         page_ranking, website, scrape_time)
SELECT scrape_id, shoe_sku, price, 
       discount_1_text, discount_1_weighted, 
       discount_2_text, discount_2_weighted, 
       discount_3_text, discount_3_weighted,
       uk_size_5, uk_size_5_5, uk_size_6, 
       uk_size_6_5, uk_size_7, uk_size_7_5, 
       uk_size_8, uk_size_8_5, uk_size_9, 
       uk_size_9_5, uk_size_10, 
       page_ranking, website, scrape_time
FROM "20250415_catalog_women_scrape_data_v2_csv";

-- Queries to quickly check data in shoes and scrape_data table
-- 1. Count how many data rows scraped:
select * from scrape_data sd
where 'scrape_id' = distinct 


-- 21/04/2025 23:15 Upload New Date: 21st dataset --

-- PART 1: add shoes dataset
--1. DONE! insert 20250421 mar_men_shoes ->mar_women_shoes-> cat_women_shoes -> cat_men_shoes
CREATE TABLE temp_table AS
SELECT DISTINCT ON (shoe_sku) *
FROM "20250421_catalog_men_shoes_csv";

-- Step 2: Drop the original table
DROP TABLE "20250421_catalog_men_shoes_csv";

-- Step 3: Rename the temporary table to the original table name
ALTER TABLE temp_table RENAME TO "20250421_catalog_men_shoes_csv";

-- Step 4: Add the primary key constraint
ALTER TABLE "20250421_catalog_men_shoes_csv" ADD PRIMARY KEY (shoe_sku);

-- use to to insert new shoes data into old shoes data without inputing any duplicates!
INSERT INTO shoes (shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender)
SELECT shoe_sku, shoe_name, shoe_brand, shoe_type, shoe_gender
FROM "20250421_catalog_men_shoes_csv" s
WHERE NOT EXISTS (
    SELECT 1
    FROM shoes
    WHERE shoe_sku = s.shoe_sku
);

-- this adds shoe_type from shoe_name -- 
-- puma corrector --
UPDATE shoes
SET shoe_type = CASE
    WHEN shoe_name ILIKE '%Sneakers%' THEN 'Sneakers'
    WHEN shoe_name ILIKE '%Slip-on%' THEN 'Slip-on Shoes'
    WHEN shoe_name ILIKE '%Hiking Shoes%' THEN 'Hiking Shoes'
    WHEN shoe_name ILIKE '%Running Shoes%' THEN 'Running Shoes'
    WHEN shoe_name ILIKE '%Football Boots%' THEN 'Football Boots'
    WHEN shoe_name ILIKE '%Trainers%' THEN 'Trainers'
    WHEN shoe_name ILIKE '%Sandals%' THEN 'Sandals'
    WHEN shoe_name ILIKE '%Slides%' THEN 'Slides'
    WHEN shoe_name ILIKE '%Football Boots%' THEN 'Football Boots'
    WHEN shoe_name ILIKE '%Basketball Shoes%' THEN 'Basketball Shoes'
    WHEN shoe_name ILIKE '%Driving Shoes%' THEN 'Driving Shoes'
    ELSE shoe_type
END
WHERE shoe_brand = 'PUMA come from PUMA merchant'

-- Chinese Corrector --
UPDATE shoes
SET shoe_type = CASE
    WHEN shoe_type ILIKE '%高筒帆布鞋%' THEN 'Canvas Shoes'
    WHEN shoe_type ILIKE '%登山鞋%' THEN 'Hiking Shoes'
    WHEN shoe_type ILIKE '%球鞋%' THEN 'Sport Shoes'
    WHEN shoe_type ILIKE '%涼鞋%' THEN 'Sandals'
    WHEN shoe_type ILIKE '%未知類型%' THEN 'Unknown'
    WHEN shoe_type ILIKE '%拖鞋%' THEN 'Slippers'
    ELSE shoe_type
END


-- check shoe types in shoes --

-- select all shoes from shoes / scrape_data sd 
select * from shoes s

-- check scrape data per day
select * from scrape_data sd 
where scrape_time = '2025-04-21'

-- count scrape data per day
select count(*) from scrape_data sd 
where scrape_time = '2025-04-15'

--change '15/4/2025' to '2025-04-15'
UPDATE scrape_data
SET scrape_time = DATE(TO_TIMESTAMP('15/4/2025', 'DD/MM/YYYY'))
WHERE scrape_time::text = '15/4/2025';

--select shoes using scrape_id--
select * from scrape_data sd 
where scrape_id = '22041527'

-- need more query samples to sample better -- 


-- now all shoes data from 15/04 and 21/04 are added to shoes--


--Part 2: add scrape_data dataset (21/04/2025)
-- DONE! try this in the order of: mar_men ->mar_women-> cat_women -> cat_men
INSERT INTO scrape_data (scrape_id, shoe_sku, price, 
                         discount_1_text, discount_1_weighted, 
                         discount_2_text, discount_2_weighted, 
                         discount_3_text, discount_3_weighted,
                         uk_size_5, uk_size_5_5, uk_size_6, 
                         uk_size_6_5, uk_size_7, uk_size_7_5, 
                         uk_size_8, uk_size_8_5, uk_size_9, 
                         uk_size_9_5, uk_size_10, 
                         page_ranking, website, scrape_time)
SELECT scrape_id, shoe_sku, price, 
       discount_1_text, discount_1_weighted, 
       discount_2_text, discount_2_weighted, 
       discount_3_text, discount_3_weighted,
       uk_size_5, uk_size_5_5, uk_size_6, 
       uk_size_6_5, uk_size_7, uk_size_7_5, 
       uk_size_8, uk_size_8_5, uk_size_9, 
       uk_size_9_5, uk_size_10, 
       page_ranking, website, scrape_time
FROM "20250421_catalog_men_scrape_data_csv";
-- done! drop the excess tables--
-- have a quick look at shoes and scrape_data tables

-- Dataset with complete 15th and 21st April data completed!!! -> Backup! (export as csv ->DB_Backup -> 14_21_04_DB_with_crocs)

-- Now try to clean crocs data -- 

'''
Step 1. Filter Out crocs in shoes
	1.2 record down their skus
Step 2. drop all crocs rows in shoes
Step 3. check all scrape_data (crocs), see if its link deleted
	3.2 confirm with their skus
'''

-- filter out crocs in shoes
select * from shoes s
where shoe_brand = 'Converse';

-- delete all crocs in scrape_data
delete from scrape_data
where shoe_sku in(
	select shoe_sku
	from shoes
	where shoe_brand = 'Crocs')
	
-- delete all crocs in shoes
delete from shoes 
where shoe_brand = 'Crocs';

select distinct shoe_brand = *
	










 



