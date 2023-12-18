USE RETURNS_PRACTICE;

CREATE TABLE ORDER_RETTYPE (
ORDER_NO VARCHAR(255)
, SKU_NO VARCHAR(255)
, RETURN_TYPE VARCHAR(255)
);

INSERT INTO ORDER_RETTYPE VALUES 
('2001','P2','Dc return')
,('2011','P4','DC return')
,('2011','P1','Store return')
,('2023','P5','dc return')
,('2021','P1','store return')
,('2019','P1','DC return')
,('2013','P4','store return')
,('2071','P5','Store return')
;


-----------------------------------------------------------

SELECT * FROM TRANSACTION_V1;

SELECT * FROM CUST_360_INFO_V1;

SELECT * FROM CUSTSEGROLL_V1;

SELECT * FROM CALENDER;

SELECT * FROM ORDER_RETTYPE;

--CUSTOMER_ID , CUST_SEG
-----------------------------------------------------------

SELECT COUNT(*) FROM CUST_360_INFO_V1 WHERE CUSTOMER_SEGMENTS IS NULL;


SELECT DISTINCT T.AMPERITY_ID
		, COALESCE (CR.SEGMENT,C.CUSTOMER_SEGMENTS) AS CUSTOMER_SEG
		--, C.TIER_NAME

		FROM TRANSACTION_V1 T
		LEFT JOIN CUST_360_INFO_V1 C
		ON T.AMPERITY_ID=C.AMP_ID
		LEFT JOIN CUSTSEGROLL_V1 CR
		ON CR.AMPERITY_ID=T.AMPERITY_ID;


--DROP VIEW RETURNS_ANALYSIS_M;

--CTE - COMMON TABLE EXPRESSIONS

--PERFORM ANALYSIS TO SEE FROM WHERE DO WE GET THE MOST RETURNS?

--STEP 1: FIRST CREATE A TABLE THAT HAS CUSTOMER WISE INFORMATION  (HERE WE HAVE TAKEN CUSTOMER, MONTH WISE TRASANCTION INFORMATION)
--STEP 2: PRE PROCESS THE REQUIRED INFOS FROM EACH OF THESE TABLES AND BRING DATA AT A CUSTOMER LEVEL
--STEP 3: IN THE FINAL QUERY JOIN ALL THE INFORMNATIONS AND CREATE A FINAL DATASET THAT HAS ALL THE POSSIBLE REASONS/INFORMATIONS ON WHICH AN RCA CAN BE DONE

CREATE VIEW RETURNS_ANALYSIS_TABLE AS   --CREATING A VIEW FOR THIS EVERY DATASET CREATED BY JOINING MULTIPLE TABLE AND DOING MULTIPLE OPERATIONS

WITH LOYALTY AS (   --THIS CTE IS PULLING OUT THE LATEST LOYALTY TIER VALUES OF EVERY CUSTOMER
				 SELECT A.AMP_ID, A.TIER_NAME FROM (    --SO THE INNER TABLE IS FIRST CREATING THE ROW NUMBER COLUMN ACCORDING TO WHICH WE WANT TO FILTER
													 SELECT *      --FOR EVERY CUSTOMER IT IS GROUPING THE RECORDS OF THE CUSTOMER AND ORDERING BY DESC W.R.T THE LAST_ACTIVITY_DATE 
															, ROW_NUMBER() OVER (PARTITION BY AMP_ID ORDER BY LAST_ACTIVITY_DATE DESC) AS LOYALTY_ROW_NUM 
													 FROM CUST_360_INFO_V1
												    ) A
				 WHERE A.LOYALTY_ROW_NUM = 1  --FILTERING OUT WHERE ROW NUMBER IS 1 AS IT INDICATES THE LAST ACTIVITY
				 ),

CUSTSEG AS (SELECT DISTINCT A.AMPERITY_ID      --THIS CTE IS INCREASING THE COVERAGE OF THE CUSTOMER SEGMENTS I.E. FILLING IN THE NULL VALUES
					, COALESCE (CR.SEGMENT,C.CUSTOMER_SEGMENTS) AS CUSTOMER_SEG  --COALESCE WHICH IS FILLING IN THE NULL VALUES BY PULLING VALUES FROM OTHER TABLES AND COLUMNS AS MENTIONED
					FROM TRANSACTION_V1 A   -- WE WANT ALL CUSTOMERS FORM THE TRANSACTION TABLE I.E. WHY WE ARE TAKING IT AS THE BASE TABLE I.E. THE LEFT MOST TABLE
					LEFT JOIN CUST_360_INFO_V1 C  --JOIN ON THIS TABLE TO GET IN THE CUSTOMER SEG INFO
					ON A.AMPERITY_ID=C.AMP_ID
					LEFT JOIN CUSTSEGROLL_V1 CR  --JOIN ON THIS TABLE TO GET IN THE CUSTOMER INFO, BY DOING A COALESCE WHICH IS FILLING IN THE NULL VALUES
					ON CR.AMPERITY_ID=A.AMPERITY_ID
			)

SELECT T.AMPERITY_ID
		, C.CUSTOMER_SEG  -- THIS CUSTOMER_SEG NOW HAS MORE COVERAGE SINCE WE HAVE DONE A COALESCE WITH MULTIPLE TABLES IN THE ABOVE CTE CUTSEG
		, L.TIER_NAME
		, MONTH(T.ORDER_DATETIME) AS MONTH_NUM  -- EXTRACTING OUT MONTH FROM THE ORDER DATE TIME

		-- THIS CASE WHEN STATEMENT SUMS UP ALL THE VALUES I.E. ITEM PRICE FOR EVERY CUSTOMER-MONTH_NUM CONBINATION WHEREVER IS_RETURN='FALSE' AND IS_CANCELLATION='FALSE' -- THUS IT RETURNS GROSS SALES FOR ALL CUSTOMERS-MONTH_NUM (EVERY CUSTOMER, IN EVERY MONTH)
		, ISNULL(SUM(ABS(CASE WHEN T.IS_RETURN='FALSE' AND T.IS_CANCELLATION='FALSE' THEN T.ITEM_REVENUE END)),0) AS GROSS_SALES  
		, ISNULL(SUM(ABS(CASE WHEN T.IS_RETURN='TRUE' AND T.IS_CANCELLATION='FALSE' THEN T.ITEM_REVENUE END)),0) AS GROSS_RETURNS  -- SIMILARLY LIKE THE PREIOUS ONE BUT ONLY TAKES INTO ACCOUNT THE RETURN ORDERS

		-- THIS CASE WHEN STATEMENT SUMS UP ALL THE VALUES I.E. QUANTITIES FOR EVERY CUSTOMER-MONTH_NUM CONBINATION WHEREVER IS_RETURN='FALSE' AND IS_CANCELLATION='FALSE'  -- RETURNS GROSS ITEMS ORDERED BY EVERY CUSTOMER, IN EVERY MONTH
		, ISNULL(SUM(ABS(CASE WHEN T.IS_RETURN='FALSE' AND T.IS_CANCELLATION='FALSE' THEN T.ITEM_QUANTITY END)),0) AS GROSS_ITEMS_ORDERED
		, ISNULL(SUM(ABS(CASE WHEN T.IS_RETURN='TRUE' AND T.IS_CANCELLATION='FALSE' THEN T.ITEM_QUANTITY END)),0) AS GROSS_ITEMS_RETURNED

		FROM TRANSACTION_V1 T   --TAKING TRANSACTION AS THE BASE TABLE SINCE WE WANT ALL CUSTOMER TRANSACTION INFO
		LEFT JOIN LOYALTY L    -- JOIN ON LOYALTY CTE I.E. TEMP TABLE TO PULL IN THE LATEST ACTIVITY LOYALTY INFO.
		ON T.AMPERITY_ID=L.AMP_ID

		LEFT JOIN CUSTSEG C  -- JOIN ON CUSTSEG CTE I.E. TEMP TABLE TO PULL IN THE CUSTOMER SEGMENTS
		ON C.AMPERITY_ID=T.AMPERITY_ID

		--LEFT JOIN CALENDER CA
		--ON CA.DAY_NAME = T.ORDER_DATETIME

		GROUP BY T.AMPERITY_ID, CUSTOMER_SEG, TIER_NAME, MONTH(T.ORDER_DATETIME)  -- GROUP BY ALL THE COLUMNS PRESENT BEFORE THE AGGREGATIONS I.E. GROUPING IT BY EVERY CUSTOMER'S MONTH WISE TRABSACTION INFO
		;


SELECT * FROM TRANSACTION_V1;

SELECT COUNT(*) FROM (SELECT DISTINCT AMPERITY_ID, ORDER_DATETIME, ORDER_ID, PRODUCT_ID FROM TRANSACTION_V1) T;

SELECT * FROM RETURNS_ANALYSIS_TABLE;  -- PRINTING THE VIEW I.E. THE RUNNING THE ENTIRE CODE CHUNK PRESENT IN IT AND CREATING THE TABLE AS AN OUTPUT

SELECT SUM(GROSS_SALES) TOT_SALES, SUM(GROSS_RETURNS) TOT_RET_REV FROM RETURNS_ANALYSIS_TABLE;  -- SUM(GROSS_SALES) SUMMING UP ALL SALES VALUES WILL GIVE ME TOTAL SALES --SUM(GROSS_RETURNS) SUMMING UP ALL RETURN SALES VALUES WILL GIVE ME TOTAL RETURN SALES

-- CALC. CUSTOMER SEGMENT WISE RETURN RATE
SELECT CUSTOMER_SEG, SUM(GROSS_RETURNS)/SUM(GROSS_SALES) AS CUSTSEG_WISE_RETRATE FROM RETURNS_ANALYSIS_TABLE GROUP BY CUSTOMER_SEG; 

SELECT TIER_NAME
		, MONTH_NUM
		, SUM(GROSS_RETURNS)/NULLIF(SUM(GROSS_SALES),0) AS TIER_WISE_RETRATE 
		FROM RETURNS_ANALYSIS_TABLE 
		GROUP BY TIER_NAME, MONTH_NUM;

--------------------------------------------------------------------------------------------------------------------------
-----------------------------------

SELECT * FROM ORDER_RETTYPE;

DROP VIEW RETURNS_TYPE_ANALYSIS;

CREATE VIEW RETURNS_TYPE_ANALYSIS AS
WITH LOYALTY AS (
				 SELECT A.AMP_ID, A.TIER_NAME FROM (
				 SELECT *
						, ROW_NUMBER() OVER (PARTITION BY AMP_ID ORDER BY LAST_ACTIVITY_DATE DESC) AS LOYALTY_ROW_NUM 
				 FROM CUST_360_INFO_V1) A
				 WHERE A.LOYALTY_ROW_NUM = 1
				 ),

CUSTSEG AS (SELECT DISTINCT A.AMPERITY_ID
					, COALESCE (CR.SEGMENT,C.CUSTOMER_SEGMENTS) AS CUSTOMER_SEG
					FROM TRANSACTION_V1 A
					LEFT JOIN CUST_360_INFO_V1 C
					ON A.AMPERITY_ID=C.AMP_ID
					LEFT JOIN CUSTSEGROLL_V1 CR
					ON CR.AMPERITY_ID=A.AMPERITY_ID
			)

SELECT T.AMPERITY_ID
		, C.CUSTOMER_SEG
		, L.TIER_NAME
		, T.PRODUCT_ID
		, MONTH(T.ORDER_DATETIME) AS MONTH_NUM
		, O.RETURN_TYPE
		, ISNULL(SUM(ABS(CASE WHEN T.IS_RETURN='TRUE' AND T.IS_CANCELLATION='FALSE' THEN T.ITEM_REVENUE END)),0) AS GROSS_RETURNS
		, ISNULL(SUM(ABS(CASE WHEN T.IS_RETURN='TRUE' AND T.IS_CANCELLATION='FALSE' THEN T.ITEM_QUANTITY END)),0) AS GROSS_ITEMS_RETURNED
		FROM TRANSACTION_V1 T
		LEFT JOIN LOYALTY L
		ON T.AMPERITY_ID=L.AMP_ID

		LEFT JOIN CUSTSEG C
		ON C.AMPERITY_ID=T.AMPERITY_ID

		LEFT JOIN ORDER_RETTYPE O
		ON O.ORDER_NO=T.ORDER_ID
		AND O.SKU_NO=T.PRODUCT_ID

		WHERE T.IS_RETURN='TRUE'

		GROUP BY T.AMPERITY_ID, CUSTOMER_SEG, TIER_NAME, PRODUCT_ID, MONTH(T.ORDER_DATETIME), RETURN_TYPE;

SELECT * FROM RETURNS_TYPE_ANALYSIS;

SELECT LOWER(RETURN_TYPE) AS RET_TYPE, SUM(GROSS_RETURNS) FROM RETURNS_TYPE_ANALYSIS GROUP BY LOWER(RETURN_TYPE);

SELECT MONTH_NUM
		, LOWER(RETURN_TYPE) AS RET_TYPE
		, SUM(GROSS_RETURNS) 
		FROM RETURNS_TYPE_ANALYSIS 
		GROUP BY MONTH_NUM, LOWER(RETURN_TYPE);