
-- Create the metrics log

CREATE OR REPLACE TABLE DQ_METRICS_LOG (
    LOG_ID          NUMBER AUTOINCREMENT PRIMARY KEY,
    RUN_TIMESTAMP   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    TABLE_NAME      VARCHAR(100),
    DQ_DIMENSION    VARCHAR(50),    
    CHECK_NAME      VARCHAR(200),
    TOTAL_RECORDS   NUMBER,
    PASS_COUNT      NUMBER,
    FAIL_COUNT      NUMBER,
    PASS_PCT        NUMBER(6,2),
    FAIL_PCT        NUMBER(6,2)
);


CREATE OR REPLACE PROCEDURE SP_CALCULATE_DQ_METRICS()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN



-- CUSTOMER metrics 
INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT
    'RAW_CUSTOMERS'          AS TABLE_NAME,
    'Completeness'           AS DQ_DIMENSION,
    chk.check_name           AS CHECK_NAME,
    chk.total                AS TOTAL_RECORDS,
    chk.pass_cnt             AS PASS_COUNT,
    chk.total - chk.pass_cnt AS FAIL_COUNT,
    ROUND((chk.pass_cnt / chk.total) * 100, 2) AS PASS_PCT,
    ROUND(((chk.total - chk.pass_cnt) / chk.total) * 100, 2) AS FAIL_PCT
FROM (
    SELECT 'chk_customer_id_not_null' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_customer_id_not_null = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_CUSTOMER_DQ
    UNION ALL
    SELECT 'chk_first_name_not_null',
           COUNT(*),
           SUM(CASE WHEN chk_first_name_not_null = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_CUSTOMER_DQ
    UNION ALL
    SELECT 'chk_last_name_not_null',
           COUNT(*),
           SUM(CASE WHEN chk_last_name_not_null = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_CUSTOMER_DQ
    UNION ALL
    SELECT 'chk_email_not_null',
           COUNT(*),
           SUM(CASE WHEN chk_email_not_null = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_CUSTOMER_DQ
) chk;

INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_CUSTOMERS', 'Uniqueness', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_customer_id_unique' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_customer_id_unique = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_CUSTOMER_DQ
) chk;

INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_CUSTOMERS', 'Validity', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_email_format' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_email_format = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_CUSTOMER_DQ
    UNION ALL
    SELECT 'chk_phone_format', COUNT(*),
           SUM(CASE WHEN chk_phone_format = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_CUSTOMER_DQ
    UNION ALL
    SELECT 'chk_province_valid', COUNT(*),
           SUM(CASE WHEN chk_province_valid = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_CUSTOMER_DQ
    UNION ALL
    SELECT 'chk_spend_numeric_positive', COUNT(*),
           SUM(CASE WHEN chk_spend_numeric_positive = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_CUSTOMER_DQ
) chk;

INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_CUSTOMERS', 'Timeliness', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_dob_valid' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_dob_valid = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_CUSTOMER_DQ
) chk;

-- ── ORDER metrics ─────────────────────────────────────────
INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_ORDERS', 'Completeness', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_order_id_not_null' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_order_id_not_null = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_ORDER_DQ
    UNION ALL
    SELECT 'chk_order_date_not_null', COUNT(*),
           SUM(CASE WHEN chk_order_date_not_null = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_ORDER_DQ
) chk;

INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_ORDERS', 'Validity', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_quantity_positive' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_quantity_positive = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_ORDER_DQ
    UNION ALL
    SELECT 'chk_total_matches_qty_price', COUNT(*),
           SUM(CASE WHEN chk_total_matches_qty_price = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_ORDER_DQ
    UNION ALL
    SELECT 'chk_status_valid', COUNT(*),
           SUM(CASE WHEN chk_status_valid = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_ORDER_DQ
    UNION ALL
    SELECT 'chk_channel_valid', COUNT(*),
           SUM(CASE WHEN chk_channel_valid = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_ORDER_DQ
) chk;

INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_ORDERS', 'Referential Integrity', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_customer_fk' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_customer_fk = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_ORDER_DQ
    UNION ALL
    SELECT 'chk_product_fk', COUNT(*),
           SUM(CASE WHEN chk_product_fk = 'PASS' THEN 1 ELSE 0 END)
    FROM VW_ORDER_DQ
) chk;

INSERT INTO DQ_METRICS_LOG (TABLE_NAME, DQ_DIMENSION, CHECK_NAME, TOTAL_RECORDS, PASS_COUNT, FAIL_COUNT, PASS_PCT, FAIL_PCT)
SELECT 'RAW_ORDERS', 'Timeliness', chk.check_name, chk.total, chk.pass_cnt,
       chk.total - chk.pass_cnt,
       ROUND((chk.pass_cnt/chk.total)*100,2),
       ROUND(((chk.total-chk.pass_cnt)/chk.total)*100,2)
FROM (
    SELECT 'chk_order_date_not_future' AS check_name,
           COUNT(*) AS total,
           SUM(CASE WHEN chk_order_date_not_future = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt
    FROM VW_ORDER_DQ
) chk;

RETURN 'DQ Metrics calculated successfully at ' || CURRENT_TIMESTAMP();
END;
$$;

-- Run it once now to populate the first set of metrics
CALL SP_CALCULATE_DQ_METRICS();


select * from DQ_METRICS_LOG;