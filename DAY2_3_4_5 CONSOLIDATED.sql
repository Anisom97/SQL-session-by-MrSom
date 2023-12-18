sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'max server memory', 32768;   -- for 32 GB
GO  
RECONFIGURE;  
GO

--------------------------------------------------
--DROP TABLE TABLE_NAME;

CREATE DATABASE ECOMMERCE_PLATFORM;

USE ECOMMERCE_PLATFORM;

CREATE TABLE TRANSAC (     --SYNTAX FOR CREATING AN EMPTY TABLE , SPECIFY THE NAME OF THE TABLE NAME
TNXID INT PRIMARY KEY,     --ASSIGN APPROPRIATE DATATYPES TO THE COLUMNS CREATED (BASICALLY WHAT TYPE OF DATA YOU WANT TO STORE)
PRODUCTID VARCHAR(255),
PRODUCTDESC VARCHAR(255),
PRICE FLOAT
);

INSERT INTO TRANSAC       --FILL IN INFORMATION INTO THE TABLE CREATED (HERE ITS TRANSACION TABLE)
VALUES                  -- ALL VALUES SHOULD BE STORED IN ORDER OF THE COLUMN NAMES
(1001,'P1','TSHIRT',100.50), -- DATATYPES OF THE COLUMNS AND THE VALUES IN IT SHOULD BE SAME
(1002,'P2','SHIRT',50),
(1003,'P3','PANT',40),
(1004,'P4','SAREE',120),
(1005,'P5','TOP',110),
(1006,'P6','TSHIRT',60),
(1007,'P1','TSHIRT',90),
(1008,'P3','PANT',50),
(1009,'P7','TSHIRT',70)
;


SELECT * FROM TRANSAC; --VIEW THE ENTIRE TABLE WITH ALL THE INFORMATION/DATA

--USE TRANS;
ALTER TABLE TRANSAC ADD DISCOUNT INT ;   -- ADDING A NEW COLUMN 
--ALTER TABLE TRANS ADD QTY INT AFTER PRODUCTDESC;

--ALTER TABLE TRANS RENAME DISCOUNT TO DISC_PEC;  MYSQL SYNTAX
EXEC SP_RENAME 'TRANSAC.DISCOUNT', 'DISC_PEC', 'COLUMN';  --SQL SERVER SYNTAX   -- RENAMING COLUMN

--Alter table table_name modify column column_name varchar(30);  MYSQL SYNTAX
-- ALTER TABLE dbo.TRANS ALTER COLUMN TNXID VARCHAR (255);
SELECT * FROM TRANSAC;

UPDATE TRANSAC SET DISC_PEC=10 WHERE TNXID=1001;   -- SETTING VALUES IN THE NEW COLUMN CREATED AS PER THE UNIQUE KEY TNXID
UPDATE TRANSAC SET DISC_PEC=15 WHERE TNXID=1002;
UPDATE TRANSAC SET DISC_PEC=5 WHERE TNXID=1003;
UPDATE TRANSAC SET DISC_PEC=20 WHERE TNXID=1004;
UPDATE TRANSAC SET DISC_PEC=8 WHERE TNXID=1005;
UPDATE TRANSAC SET DISC_PEC=12 WHERE TNXID=1006;
UPDATE TRANSAC SET DISC_PEC=11 WHERE TNXID=1007;
UPDATE TRANSAC SET DISC_PEC=15 WHERE TNXID=1008;
UPDATE TRANSAC SET DISC_PEC=5 WHERE TNXID=1009;

SELECT * FROM TRANSAC;


SELECT TRANSAC.TNXID, TRANSAC.PRODUCTDESC FROM TRANSAC;
SELECT TNXID, PRODUCTDESC FROM TRANSAC;   -- SELECT ONLY SPECIFIC COLUMN/INFO FROM THE TABLE

SELECT TOP 2 * FROM TRANSAC;    -- HELPS YOU TO VIEW A SUBSET OF THE TABLE - YOU CAN SPECIFY HOW MANY ROWS YOU WANT TO SEE
--SELECT * FROM TRANS LIMIT 2;

SELECT * FROM TRANSAC WHERE PRICE>=50; 

SELECT productid        -- GOOD PRACTICE FOR WRITING QUERY
		, PRODUCTDESC
		, price
		--,DISC_PEC
		FROM TRANSAC  
			WHERE PRICE>=50;

SELECT PRODUCTDESC FROM TRANSAC WHERE PRICE>=50 AND PRICE<=100;    -- SET RANGE FOR FILTERING


SELECT * FROM TRANSAC WHERE PRICE>=50 AND PRICE<=100;

SELECT PRODUCTID, PRODUCTDESC FROM TRANSAC WHERE PRICE BETWEEN 50 AND 100;  -- ANOTHER WAY OF SETTING RANGE FOR FILERING

SELECT * FROM TRANSAC WHERE PRODUCTDESC IN ('TSHIRT','SHIRT');   -- SPECIFY AS PER WHAT VALUES YOU WANT TO FILTER 

SELECT *            --GETTING ALL COLUMNS 
		FROM TRANSAC 
			WHERE  --FILTERING OPERATIONS START
			PRODUCTID IN ('P1','P2','P3')    --FILTER 1
			AND PRICE>50   --FILTER 2 -- FOR ADDING MORE FILTERS USE AND
			AND DISC_PEC>10;  --FILTER 3

SELECT * FROM TRANSAC ORDER BY PRICE; -- DEFAULT IS ASCENDING
SELECT * FROM TRANSAC ORDER BY PRICE DESC;


--------- 26TH AUG 
SELECT * FROM TRANSAC ORDER BY PRICE, DISC_PEC;
SELECT * FROM TRANSAC ORDER BY PRICE DESC, DISC_PEC;

USE ECOMMERCE_PLATFORM;

SELECT * FROM TRANSAC;

SELECT DISTINCT PRODUCTID FROM TRANSAC;  --GIVES YOU UNIQUE VALUES FROM THE COLUMNS

SELECT PRODUCTID, PRICE FROM TRANSAC WHERE PRODUCTID IN ('P1');

INSERT INTO TRANSAC       --FILL IN INFORMATION INTO THE TABLE CREATED (HERE ITS TRANSACION TABLE)
VALUES                  -- ALL VALUES SHOULD BE STORED IN ORDER OF THE COLUMN NAMES
(1010,'P1','TSHIRT',NULL,NULL)  -- INSERTING A NULL VALUE IN THE TABLE
;

SELECT * FROM TRANSAC;

SELECT * FROM TRANSAC WHERE PRICE IS NOT NULL;
SELECT *, ISNULL(PRICE,50) AS UPDT_PRC FROM TRANSAC;  --GIVING ALIAS TO ISNULL(PRICE,50) I.E. GIVING IT A COLUMN NAME -- IF there is a null replace that null value with a given value keeping the actual table intact and creating a new column
SELECT *, COALESCE(PRICE,100) AS UPDT_PRC2 FROM TRANSAC; -- ADVANTAGE OF COALESCE IS IT TAKES IN THE FIRST NON NULL VALUES IN ORDER OF THE COLUMNS SPECIFIED (FROM MULTIPLE COLUMNS) 


-- Bucket the products as per price ranges as high, medium and low 

CREATE VIEW TRANSAC_PRC AS 
SELECT *  --BASE TRANSAC
	, CASE        -- DEFINING CONDITIONS 
	WHEN PRICE>100 THEN 'HIGH'  -- IF ELSE STATEMENTS 
	WHEN PRICE>50 AND PRICE<100 THEN 'MEDIUM'
	ELSE 'LOW'
	END AS PRICE_CLASS    -- THE NEW COLUMN CREATED WILL BE UPDATED IN THE TABLE(VIEW TRANSAC_PRC) AND THE COLUMN WILL STAY
	FROM TRANSAC ; 

--DROP VIEW TRANSAC_PRC;
SELECT * FROM TRANSAC_PRC;

-- DROP VIEW TRANSAC_PRC_CLASS;
-- Make product categories and classify the items

CREATE VIEW TRANSAC_PRC_CLASS AS
SELECT *     -- * HERE IS ALL COLUMNS FROM THE NEW TABLE TRANSAC_PRC
		, CASE 
		WHEN PRODUCTDESC IN ('TSHIRT','SHIRT') THEN 'MENS WEAR'
		WHEN PRODUCTDESC IN ('SAREE','TOP') THEN 'WOMEN WEAR'
		WHEN PRODUCTDESC IN ('PANT') THEN 'UNISEX'
		ELSE 'UNK'
		END AS PRODUCT_CLASS
		FROM TRANSAC_PRC;  -- USING THE LAST CREATED TABLE AM UPDATING IT AGAIN WITH A NEW COLUMN

SELECT * FROM TRANSAC_PRC_CLASS;

-- Want to see how many products has price >100
SELECT COUNT(*) FROM TRANSAC_PRC_CLASS WHERE PRICE>100;

SELECT COUNT(*) FROM TRANSAC WHERE PRICE>100;

SELECT * FROM TRANSAC_PRC_CLASS;

-- https://www.w3schools.com/sql/sql_like.asp 

SELECT * FROM TRANSAC_PRC_CLASS
		WHERE PRODUCT_CLASS LIKE '%MEN%';

SELECT * FROM TRANSAC_PRC_CLASS;
SELECT * FROM TRANSAC_PRC_CLASS WHERE PRODUCT_CLASS LIKE '%WEAR%';
SELECT PRODUCTID, PRICE FROM TRANSAC_PRC_CLASS WHERE PRODUCT_CLASS LIKE '%WEAR%' OR ;

SELECT * FROM TRANSAC_PRC_CLASS
		WHERE PRODUCT_CLASS LIKE 'M%';

-- Want to see total number of products sold as per product description 
SELECT PRODUCTDESC
		, COUNT(PRODUCTID) AS NUM_OF_PRODS    -- GIVES ME THE COUNT OF PRODUCTID UNDER THE INDIVIDUAL GROUPS/UNIQUE RECORDS IN PRODUCTDESC
			FROM TRANSAC 
	   GROUP BY PRODUCTDESC;

	   SELECT * FROM TRANSAC;

-- Want to see the no. of distinct products sold under every product description
SELECT PRODUCTDESC
		, COUNT(DISTINCT PRODUCTID) AS NUM_OF_PRODS -- GIVES ME THE COUNT OF UNIQUE PRODUCTS UNDER THE INDIVIDUAL GROUPS/UNIQUE RECORDS IN PRODUCTDESC
			FROM TRANSAC 
		GROUP BY PRODUCTDESC;


SELECT PRODUCTDESC
		, COUNT(PRODUCTID) AS NUM_OF_PRODS 
			FROM TRANSAC 
		GROUP BY PRODUCTDESC 
		HAVING COUNT(PRODUCTID)>3;   -- FOR AGGREGATE FUNCTIONS USE HAVING AND NOT WHERE -- WHENEVER YOU WANT TO FILTER ON AGGREGATED VALUES USE HAVING

SELECT * FROM TRANSAC;

SELECT * FROM TRANSAC_PRC_CLASS;

USE ECOMMERCE_PLATFORM;
-- How much revenue did we generate from every product 
SELECT PRODUCTID
		, SUM(PRICE) AS TOTAL_REV
		FROM TRANSAC_PRC_CLASS
		GROUP BY PRODUCTID;

SELECT PRODUCT_CLASS     -- First specify whatever you want to see in the output table
		, PRODUCTDESC
		, SUM(PRICE) TOTAL_REV
		, AVG(PRICE) AVG_REV
		FROM TRANSAC_PRC_CLASS   -- from where I want to see it i.e. from the table
		GROUP BY PRODUCT_CLASS,PRODUCTDESC   -- how you want to see it
		ORDER BY PRODUCT_CLASS,PRODUCTDESC;

SELECT * FROM TRANSAC_PRC_CLASS;
-- How much AVERAGE revenue did we generate from every product class
SELECT PRODUCT_CLASS
		, AVG(PRICE) AS MEAN_REVENUE_GENERATED
		FROM TRANSAC_PRC_CLASS
		GROUP BY PRODUCT_CLASS;

SELECT PRODUCTID
		, MAX(DISC_PEC) AS MAX_DISCOUNT_GIVEN
		FROM TRANSAC_PRC_CLASS
		GROUP BY PRODUCTID;

SELECT * FROM TRANSAC_PRC_CLASS;

SELECT PRODUCT_CLASS        -- ALWAYS SPECIFY ALL THE AGGREGATIONS AFTER THE GROUPS AND BEFORE THE FROM STATEMENTS -- THE ORDER OF GROUP BY SHOULD BE THE SAME AS ORDER OF THE INPUT SEQUENCE AFTER SELECT
		, PRODUCTDESC
		, SUM(PRICE) AS TOTAL_REVENUE
		, SUM(DISC_PEC) AS TOTAL_DISCOUNT_GIVEN
		FROM TRANSAC_PRC_CLASS
		GROUP BY 
		PRODUCT_CLASS,
		PRODUCTDESC
		ORDER BY PRODUCT_CLASS,PRODUCTDESC;

-------------------------------------------------------------------------- 27 AUG
USE ECOMMERCE_PLATFORM;

CREATE TABLE ORD_CUST_DETAILS (     -- CREATING 2 TABLES FOR JOINS
TNXID INT PRIMARY KEY,    
CUST_EMAIL VARCHAR(255),
CUST_ADDRESS VARCHAR(255),
CUST_CITY VARCHAR(255),
);

INSERT INTO ORD_CUST_DETAILS       -- CUSTOMER DETAILS
VALUES                  
(1001,'ABC@GMAIL.COM','ACC HOUSE','BOM'), 
(1003,'A12@YAHOO.COM','CV NAGAR','AHMD'),
(1004,'XYZ@HOTMAIL.COM','ST PAULS ROAD','IXC'),
(1002,'qwe@gmail.com','Kalyan nagar','BOM'),
(1005,'rty@yahoo.com','BTM','CHN'),
(2011,'kkr@gmail.com','bly nest','CCU'),
(1007,'FCB@YAHOO.COM','BEL RD','CCU'),
(2008,'RMA@zoho.com','xz area','DEL'),
(1009,'ram@rediffmail.com','abc zone','GWT')
;

CREATE TABLE LOC_DETAILS (     
LOC_NAME CHAR(50) PRIMARY KEY,    
REGION CHAR(50)
);

INSERT INTO LOC_DETAILS      -- LOCATION DETAILS
VALUES
('BOM','WEST'),
('KOC','SOUTH'),
('CHN','SOUTH'),
('BBU','EAST'),
('CCU','EAST'),
('GWT','EAST'),
('DEL','NORTH'),
('IXC','NORTH'),
('AHMD','WEST')
;

SELECT * FROM  ORD_CUST_DETAILS;
SELECT * FROM LOC_DETAILS;
select * from TRANSAC_PRC_CLASS;

--------

SELECT T.*                  -- ALL COLUMNS FROM TRANSAC_PRC_CLASS WILL COME
		, O.*                   -- ALL COLUMNS FROM ORD_CUST_DETAILS WILL COME
		FROM TRANSAC_PRC_CLASS as T
		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID;   -- JOINING CONDITION -- HOW AND ON WHAT WE WANT TO JOIN THE TABLES 


SELECT TRANS.TNXID, TRANS.PRODUCTID, TRANS.PRICE  -- PULLING SPECIFIC INFO FROM TRANSAC_PRC_CLASS
		, OD.CUST_EMAIL  -- PULLING SPECIFIC INFO FROM ORD_CUST_DETAILS

		FROM TRANSAC_PRC_CLASS TRANS
		LEFT JOIN    -- ALL INFORMATION FROM LEFT TABLE + THE MATCHING VALUES FORM THE RIGHT TABLE WILL COME ON WHICH WE ARE JOINING ALONG WITH THE SPEFICIC COLUMNS THAT WE ARE PULLING FROM THE LEFT TABLE -- LEFT TABLE WILL GET PRIORITY -- VALUES WHICH ARENT MATCHING WILL BE POPULATED WILL NULL
		ORD_CUST_DETAILS AS OD

		ON TRANS.TNXID=OD.TNXID;

SELECT * FROM  ORD_CUST_DETAILS;

SELECT O.*,
		T.*
		FROM TRANSAC_PRC_CLASS AS T
		RIGHT JOIN   -- JUST THE INVERSE OF LEFT JOIN 
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID;

SELECT O.*,
		T.*
		FROM TRANSAC_PRC_CLASS AS T
		INNER JOIN   -- COMMON VALUES THAT ARE MATCHING IN BOTH THE TABLES WILL COME AS OUTPUT
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID;

SELECT O.*,
		T.*
		FROM TRANSAC_PRC_CLASS AS T
		FULL OUTER JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID;

SELECT * FROM LOC_DETAILS;
SELECT * FROM ORD_CUST_DETAILS;

SELECT T.*    -- ALL COLUMNS FORM T
		, O.*   -- ALL COLUMNS FROM O
		, L.*  -- ALL COLUMNS FROM L
		FROM TRANSAC_PRC_CLASS AS T   -- JOINING MULTIPLE TABLES ON THE RELEVANT COLUMNS 
		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID
		
		LEFT JOIN
		LOC_DETAILS L
		ON L.LOC_NAME=O.CUST_CITY
		;

select t.tnxid, t.productid, t.price   -- PULLING IN ONLY SPECIFIC INFO FROM THE MULTIPLE TABLES 
		, o.cust_city
		,l.region
		from TRANSAC_PRC_CLASS as t
		left join 
		ORD_CUST_DETAILS AS O
		on T.TNXID=O.TNXID

		left join
		LOC_DETAILS as l
		on L.LOC_NAME=O.CUST_CITY;

SELECT T.TNXID
		, T.PRODUCTID
		, T.PRICE
		, T.PRODUCT_CLASS
		, O.CUST_CITY
		, L.REGION

		FROM TRANSAC_PRC_CLASS AS T
		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID
		
		LEFT JOIN
		LOC_DETAILS L
		ON L.LOC_NAME=O.CUST_CITY; 


SELECT T.*, O.* 
	FROM TRANSAC_PRC_CLASS AS T
		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID;


-- Calc. total revenue generated from each city
SELECT O.CUST_CITY   -- PULLING FROM O TABLE
		, SUM(T.PRICE) REVENUE_GENERATED  -- AGGREGATING ON PRICE COLUMN WHICH WE GOT AFTER JOINING BOTH THE TABLES
		FROM TRANSAC_PRC_CLASS AS T        -- JOIN THE 2 TABLES TO GET THE PRICE AND LOC INFO. 
		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID
		GROUP BY O.CUST_CITY; 

		
-- Calc. total revenue generated by PRODUCT CLASS from each city
SELECT T.PRODUCT_CLASS
		, O.CUST_CITY
		, SUM(T.PRICE) REVENUE_GENERATED
		, AVG(T.DISC_PEC) AS TOTAL_DISC_GIVEN
		FROM TRANSAC_PRC_CLASS AS T
		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID
		GROUP BY
		T.PRODUCT_CLASS
		, O.CUST_CITY
		ORDER BY 
		T.PRODUCT_CLASS;

-- 
SELECT T.PRODUCT_CLASS
		, L.REGION
		, AVG(T.PRICE) REVENUE_GENERATED

		FROM TRANSAC_PRC_CLASS AS T

		LEFT JOIN
		ORD_CUST_DETAILS AS O
		ON 
		T.TNXID=O.TNXID

		LEFT JOIN
		LOC_DETAILS L
		ON L.LOC_NAME=O.CUST_CITY

		GROUP BY
		T.PRODUCT_CLASS
		, L.REGION
		ORDER BY 
		PRODUCT_CLASS,
		REGION DESC;

USE ECOMMERCE_PLATFORM;

---------------------------------------------------------------2ND SEPT
USE ECOMMERCE_PLATFORM;
select * from TRANSAC_PRC_CLASS;

SELECT PRODUCT_CLASS
		, SUM(PRICE) 
		FROM TRANSAC_PRC_CLASS 
		GROUP BY PRODUCT_CLASS;


-- Calc. contribution of sales for each product class
SELECT PRODUCT_CLASS
		, CONCAT(
				ROUND(
						(SUM(PRICE)/ (SELECT SUM(PRICE) FROM TRANSAC_PRC_CLASS))*100
					,2)
			  ,'%') AS REVENUE_CONTRI
		--, (SUM(PRICE)/ (SELECT SUM(PRICE) FROM TRANSAC_PRC_CLASS))*100 AS REVENUE_CONTRI
		FROM TRANSAC_PRC_CLASS
		GROUP BY PRODUCT_CLASS;

-- CALC. CONTRIBUTION OF SALES BY REGION
SELECT L.REGION
		,  CONCAT(ROUND((SUM(T.PRICE)/ (SELECT SUM(PRICE) FROM TRANSAC_PRC_CLASS))*100,2),'%') AS REV_CONTRI
		FROM TRANSAC_PRC_CLASS T
		
			LEFT JOIN
			ORD_CUST_DETAILS AS O
			ON 
			T.TNXID=O.TNXID

			LEFT JOIN
			LOC_DETAILS L
			ON L.LOC_NAME=O.CUST_CITY 

			GROUP BY 
			L.REGION;



SELECT A.REGION
		, ROUND((A.TOT_REV/(SELECT SUM(PRICE) FROM TRANSAC_PRC_CLASS))*100,2) AS REV_CONTRI
		FROM (
				SELECT L.REGION
					,  SUM(T.PRICE) AS TOT_REV	
					FROM TRANSAC_PRC_CLASS T
		
						LEFT JOIN
						ORD_CUST_DETAILS AS O
						ON 
						T.TNXID=O.TNXID

						LEFT JOIN
						LOC_DETAILS L
						ON L.LOC_NAME=O.CUST_CITY 

						GROUP BY 
						L.REGION
			  ) A
		--GROUP BY A.REGION
		;
---------------------------------------------------
USE ECOMMERCE_PLATFORM;

SELECT * FROM TRANSAC_PRC_CLASS;

SELECT *
		, RANK() OVER (PARTITION BY PRODUCT_CLASS ORDER BY PRICE desc) AS RNK_PRICE
		FROM TRANSAC_PRC_CLASS
		ORDER BY PRODUCT_CLASS;

SELECT *, 
		SUM(PRICE) OVER (PARTITION BY PRODUCT_CLASS) AS PROD_CLASSWISE_REV
		FROM TRANSAC_PRC_CLASS
		ORDER BY PRODUCT_CLASS;

USE ECOMMERCE_PLATFORM;

SELECT L.REGION
		,  SUM(T.PRICE) AS TOT_REV	
		--, RANK() OVER (PARTITION BY REGION ORDER BY TOT_REV)
		FROM TRANSAC_PRC_CLASS T
		
			LEFT JOIN
			ORD_CUST_DETAILS AS O
			ON 
			T.TNXID=O.TNXID

			LEFT JOIN
			LOC_DETAILS L
			ON L.LOC_NAME=O.CUST_CITY 

			GROUP BY 
			L.REGION;


SELECT B.* FROM (
SELECT A.REGION
		, A.PRODUCT_CLASS
		, A.TOT_REV
		, RANK() OVER (PARTITION BY A.REGION ORDER BY A.TOT_REV) AS RANK_REGION_SALES
		FROM (
				SELECT L.REGION
						, T.PRODUCT_CLASS
					,  SUM(T.PRICE) AS TOT_REV	
					FROM TRANSAC_PRC_CLASS T
		
						LEFT JOIN
						ORD_CUST_DETAILS AS O
						ON 
						T.TNXID=O.TNXID

						LEFT JOIN
						LOC_DETAILS L
						ON L.LOC_NAME=O.CUST_CITY 

						GROUP BY 
						L.REGION
						, T.PRODUCT_CLASS
			  ) A
			) B
		WHERE RANK_REGION_SALES = 1
		;

USE ECOMMERCE_PLATFORM;
SELECT * FROM TRANSAC_PRC_CLASS;

SELECT A.*, 
		CASE WHEN A.PRODUCTDESC=A.LAG_PRODDESC THEN 'CONSECUTIVE BUY'
		ELSE 'NON CONSECUTIVE BUT' END AS BUY_FLAG
		FROM (
				SELECT *
						, LAG(PRODUCTDESC, 1) OVER (ORDER BY TNXID, PRODUCTDESC) AS LAG_PRODDESC
						FROM TRANSAC_PRC_CLASS
			 ) A
			 ;




--------------------------------------------------------------------------
--ALTER TABLE TRANS DROP DISC_PER;
ALTER TABLE dbo.TRANS DROP COLUMN PRICE;

--ALTER TABLE dbo.TRANS drop constraint DISC_PER;

TRUNCATE TABLE TRANS;

DROP TABLE TRANSAC;

--------------------------------------------------
