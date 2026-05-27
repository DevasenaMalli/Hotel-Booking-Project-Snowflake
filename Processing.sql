--Creating Database
CREATE DATABASE HOTEL_DB;

--Creating file formate---
CREATE OR REPLACE FILE FORMAT FF_CSV
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null','')


--Creatinh stage
CREATE OR REPLACE STAGE STG_HOTEL_BOOKINGS
FILE_FORMAT = FF_CSV;

---Creating table BRONZE_HOTEL_BOOKING
CREATE OR REPLACE TABLE BRONZE_HOTEL_BOOKING
(
    booking_id STRING,
    hotel_id   STRING,
    hotel_city STRING,
    customer_id STRING,
    customer_name STRING,
    customer_email STRING,
    check_in_date STRING,
    check_out_date STRING,
    room_type  STRING,
    num_guests STRING,
    total_amount STRING,
    currency STRING,
    booking_status STRING

);

--Loading data from stage to bronze layer
COPY INTO BRONZE_HOTEL_BOOKING FROM @STG_HOTEL_BOOKINGS
FILE_FORMAT = FF_CSV
ON_ERROR = 'CONTINUE';

SELECT * FROM BRONZE_HOTEL_BOOKING;


--Creating silver table
CREATE OR REPLACE TABLE SILVER_HOTEL_BOOKINGS
(
    booking_id VARCHAR,
    hotel_id   VARCHAR,
    hotel_city VARCHAR,
    customer_id VARCHAR,
    customer_name VARCHAR,
    customer_email VARCHAR,
    check_in_date DATE,
    check_out_date DATE,
    room_type  VARCHAR,
    num_guests INTEGER,
    total_amount FLOAT,
    currency VARCHAR,
    booking_status VARCHAR
);


--Checking for errors
SELECT customer_email
FROM BRONZE_HOTEL_BOOKING
WHERE NOT (customer_email LIKE '%@%.%')
    OR customer_email IS NULL;

SELECT total_amount
FROM BRONZE_HOTEL_BOOKING
WHERE total_amount < 0;

SELECT check_in_date, check_out_date
FROM BRONZE_HOTEL_BOOKING
WHERE TRY_TO_DATE(check_in_date) > TRY_TO_DATE(check_out_date);

SELECT  DISTINCT booking_status
FROM BRONZE_HOTEL_BOOKING;


--Load cleaned data to silver table
INSERT INTO SILVER_HOTEL_BOOKINGS
SELECT
    booking_id,
    hotel_id,
    INITCAP(TRIM(hotel_city)) AS hotel_city,
    customer_id,
    INITCAP(TRIM(customer_name)) AS customer_name,
    
    CASE 
        WHEN customer_email LIKE '%@%.%' THEN LOWER(TRIM(customer_email))
        ELSE NULL
    END AS customer_email,
    TRY_TO_DATE(NULLIF(check_in_date, '')) AS check_in_data,
    TRY_TO_DATE(NULLIF(check_out_date, '')) AS check_out_date,
    room_type,
    num_guests,
    ABS(total_amount) AS total_amount,
    currency,
    CASE 
        WHEN LOWER(booking_status) in ('confirmeeed', 'confirmd') THEN 'Confirmed' 
        ELSE booking_status
    END booking_status
    FROM BRONZE_HOTEL_BOOKING
    WHERE
        TRY_TO_DATE(check_in_data) IS NOT NULL
        AND TRY_TO_DATE(check_out_date) IS NOT NULL
        AND TRY_TO_DATE(check_out_date) >= TRY_TO_DATE(check_in_date);
    
    
SELECT * FROM SILVER_HOTEL_BOOKINGS;

--Creating gold table
CREATE TABLE GOLD_AGG_DAILY_BOOKING AS
SELECT 
    check_in_date AS data,
    COUNT(*) AS total_booking,
    SUM(total_amount) AS total_revenue
FROM SILVER_HOTEL_BOOKINGS
GROUP BY check_in_date
ORDER BY data;


CREATE TABLE GOLD_AGG_HOTEL_CITY_SALES AS 
SELECT
    hotel_city,
    SUM(total_amount) AS total_revenue
FROM SILVER_HOTEL_BOOKINGS
GROUP BY hotel_city
ORDER BY total_revenue DESC;

CREATE TABLE GOLD_BOOKING_CLEAN AS
SELECT  
    
    booking_id,
    hotel_id,
    hotel_city,
    customer_id,
    customer_name,
    customer_email,
    check_in_date,
    check_out_date,
    room_type,
    num_guests,
    total_amount,
    currency,
    booking_status
    
FROM SILVER_HOTEL_BOOKINGS;

SELECT * FROM GOLD_BOOKING_CLEAN ;

SELECT * FROM GOLD_AGG_DAILY_BOOKING;

SELECT * FROM GILD_AGG_HOTEL_CITY_SALES;
