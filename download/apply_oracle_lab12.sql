/* 
** Enkey, William
** CIT225, McLaughlin
** 2018, Winter (TA)
*/

-- Run prior scripts through lab 11 --
@/home/student/Data/cit225/oracle/lab11/apply_oracle_lab11.sql

SPOOL apply_oracle_lab12.log

BEGIN
  FOR i IN (SELECT TABLE_NAME
            FROM   user_tables
            WHERE  TABLE_NAME = 'CALENDAR') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||i.table_name||' CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP SEQUENCE' ||i.table_name|| '_s01';
  END LOOP;
END;
/
 
-- Create the table.
CREATE TABLE calendar
( calendar_id           NUMBER          CONSTRAINT pk_calendar_01 PRIMARY KEY
, calendar_name         VARCHAR2(10)    CONSTRAINT nn_calendar_01 NOT NULL
, calendar_short_name   VARCHAR2(3)     CONSTRAINT nn_calendar_02 NOT NULL
, start_date            DATE            CONSTRAINT nn_calendar_03 NOT NULL
, end_date              DATE            CONSTRAINT nn_calendar_04 NOT NULL
, created_by            NUMBER          
, creation_date         DATE            CONSTRAINT nn_calendar_05 NOT NULL
, last_updated_by       NUMBER          
, last_update_date      DATE            CONSTRAINT nn_calendar_06 NOT NULL
, CONSTRAINT fk_calendar_01 FOREIGN KEY (created_by) REFERENCES system_user(system_user_id)
, CONSTRAINT fk_calendar_02 FOREIGN KEY (last_updated_by) REFERENCES system_user(system_user_id));

CREATE SEQUENCE calendar_s01;
 
-- Seed the table with 10 years of data.
DECLARE
  -- Create local collection data types.
  TYPE smonth IS TABLE OF VARCHAR2(3);
  TYPE lmonth IS TABLE OF VARCHAR2(9);
 
  -- Declare month arrays.
  short_month SMONTH := smonth('JAN','FEB','MAR','APR','MAY','JUN'
                              ,'JUL','AUG','SEP','OCT','NOV','DEC');
  long_month  LMONTH := lmonth('January','February','March','April','May','June'
                              ,'July','August','September','October','November','December');
 
  -- Declare base dates.
  start_date DATE := '01-JAN-09';
  end_date   DATE := '31-JAN-09';
 
  -- Declare years.
  years      NUMBER := 1;
 
BEGIN
 
  -- Loop through years and months.
  FOR i IN 1..years LOOP
    FOR j IN 1..short_month.COUNT LOOP
      INSERT INTO calendar VALUES
      ( calendar_s01.NEXTVAL
      , long_month(j)
      , short_month(j)
      , add_months(start_date,(j-1)+(12*(i-1)))
      , add_months(end_date,(j-1)+(12*(i-1)))
      , 1, SYSDATE, 1, SYSDATE);
    END LOOP;
  END LOOP;
 
END;
/
 
-- Format set break for output.
SET PAGESIZE 16
 
-- Format column output.
COL short_month FORMAT A5 HEADING "Short|Month"
COL long_month  FORMAT A9 HEADING "Long|Month"
COL start_date  FORMAT A9 HEADING "Start|Date"
COL end_date    FORMAT A9 HEADING "End|Date" 
 
SELECT * FROM calendar;   

INSERT INTO system_user
VALUES
( 2
, '#2'
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_type = 'INDIVIDUAL'
     AND  common_lookup_table = 'SYSTEM_USER')
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_type = 'SYSTEM_ADMIN')
, 'Joe'
, 'E'
, 'Enkey'
, 1, SYSDATE, 1, SYSDATE); 

INSERT INTO system_user
VALUES
( 3
, 'DABOSS'
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_type = 'SYSTEM_GROUP')
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_type = 'DBA')
, 'Vilhelm'
, 'E'
, 'Enkey'
, 1, SYSDATE, 1, SYSDATE);

CREATE SEQUENCE transaction_reversal_s1;

CREATE TABLE transaction_reversal
( transaction_id                NUMBER
, transaction_account           VARCHAR2(15)    
, transaction_type              NUMBER  
, transaction_date              DATE    
, transaction_amount            NUMBER(5,2)  
, rental_id                     NUMBER  
, payment_method_type           NUMBER  
, payment_account_number        VARCHAR2(19)   
, created_by                    NUMBER  
, creation_date                 DATE         
, last_updated_by               NUMBER
, last_update_date              DATE)
ORGANIZATION EXTERNAL
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "UPLOAD"
      ACCESS PARAMETERS
      ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
      BADFILE     'UPLOAD':'transaction_upload2.bad'
      DISCARDFILE 'UPLOAD':'transaction_upload2.dis'
      LOGFILE     'UPLOAD':'transaction_upload2.log'
      FIELDS TERMINATED BY ','
      OPTIONALLY ENCLOSED BY "'"  
      MISSING FIELD VALUES ARE NULL     )
      LOCATION
       ( 'transaction_upload2.csv'
       )
    )
    REJECT LIMIT UNLIMITED;

-- Move the data from TRANSACTION_REVERSAL to TRANSACTION. --
INSERT INTO transaction
SELECT transaction_s1.NEXTVAL
,       tr.transaction_account
,       (SELECT common_lookup_id
           FROM  common_lookup
          WHERE  common_lookup_table  = 'TRANSACTION'
            AND  common_lookup_column = 'TRANSACTION_TYPE'
            AND  common_lookup_type   = 'CREDIT')
,       tr.transaction_date
,       (tr.transaction_amount/1.06)
,       tr.rental_id
,       tr.payment_method_type
,       tr.payment_account_number
,       tr.created_by, tr.creation_date, tr.last_updated_by, tr.last_update_date
 FROM   transaction_reversal tr;

-- Check current contents of the model. --
COLUMN "Debit Transactions"  FORMAT A20
COLUMN "Credit Transactions" FORMAT A20
COLUMN "All Transactions"    FORMAT A20
SELECT 'SELECT record counts' AS "Statement" FROM dual;
SELECT   LPAD(TO_CHAR(c1.transaction_count,'99,999'),19,' ') AS "Debit Transactions"
,        LPAD(TO_CHAR(c2.transaction_count,'99,999'),19,' ') AS "Credit Transactions"
,        LPAD(TO_CHAR(c3.transaction_count,'99,999'),19,' ') AS "All Transactions"
FROM    (SELECT COUNT(*) AS transaction_count FROM transaction WHERE transaction_account = '111-111-111-111') c1 CROSS JOIN
        (SELECT COUNT(*) AS transaction_count FROM transaction WHERE transaction_account = '222-222-222-222') c2 CROSS JOIN
        (SELECT COUNT(*) AS transaction_count FROM transaction) c3;

COLUMN "TRANSACTION"         FORMAT A12
COLUMN "JANUARY"             FORMAT A10
COLUMN "FEBRUARY"            FORMAT A10
COLUMN "MARCH"               FORMAT A10
COLUMN "F1Q"                 FORMAT A10
COLUMN "APRIL"               FORMAT A10
COLUMN "MAY"                 FORMAT A10
COLUMN "JUNE"                FORMAT A10
COLUMN "F2Q"                 FORMAT A10
COLUMN "JULY"                FORMAT A10
COLUMN "AUGUST"              FORMAT A10
COLUMN "SEPTEMBER"           FORMAT A10
COLUMN "F3Q"                 FORMAT A10
COLUMN "OCTOBER"             FORMAT A10
COLUMN "NOVEMBER"            FORMAT A10
COLUMN "DECEMBER"            FORMAT A10
COLUMN "F4Q"                 FORMAT A10
SELECT   CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 'Debit'
           WHEN t.transaction_account = '222-222-222-222' THEN 'Credit'
         END AS "TRANSACTION_ACCOUNT"
,        CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 1
           WHEN t.transaction_account = '222-222-222-222' THEN 2
         END AS "SORTKEY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 1 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "JANUARY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 2 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "FEBRUARY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 3 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "MARCH"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 1 AND
                    EXTRACT(MONTH FROM transaction_date) <= 3 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ1"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 4 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "APRIL"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 5 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "MAY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 6 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "JUNE"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 4 AND
                    EXTRACT(MONTH FROM transaction_date) <= 6 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ2"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 7 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "JULY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 8 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "AUGUST"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 9 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "SEPTEMBER"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 7 AND
                    EXTRACT(MONTH FROM transaction_date) <= 9 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ3"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 10 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "OCTOBER"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 11 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "NOVEMBER"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "DECEMBER"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 10 AND
                    EXTRACT(MONTH FROM transaction_date) <= 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ4"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 1 AND
                    EXTRACT(MONTH FROM transaction_date) <= 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "YTD"
FROM     transaction t INNER JOIN common_lookup cl
ON       t.transaction_type = cl.common_lookup_id 
WHERE    cl.common_lookup_table = 'TRANSACTION'
AND      cl.common_lookup_column = 'TRANSACTION_TYPE' 
GROUP BY CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 'Debit'
           WHEN t.transaction_account = '222-222-222-222' THEN 'Credit'
         END
,        CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 1
           WHEN t.transaction_account = '222-222-222-222' THEN 2
         END
UNION ALL
SELECT 'Total' AS "Account"
,       3 AS "SORTKEY"
,       LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 1 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "JANUARY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 2 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "FEBRUARY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 3 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "MARCH"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 1 AND
                    EXTRACT(MONTH FROM transaction_date) <= 3 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ1"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 4 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "APRIL"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 5 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "MAY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 6 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "JUNE"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 4 AND
                    EXTRACT(MONTH FROM transaction_date) <= 6 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ2"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 7 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "JULY"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 8 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "AUGUST"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 9 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "SEPTEMBER"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 7 AND
                    EXTRACT(MONTH FROM transaction_date) <= 9 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ3"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 10 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "OCTUBRE"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 11 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "NOVEMBER"
,        LPAD(TO_CHAR
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),'99,999.00'),10,' ') AS "DECEMBER"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 10 AND
                    EXTRACT(MONTH FROM transaction_date) <= 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "FQ4"
,        LPAD(TO_CHAR
        (SUM( CASE
               WHEN EXTRACT(MONTH FROM transaction_date) >= 1 AND
                    EXTRACT(MONTH FROM transaction_date) <= 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                        CASE
                        WHEN cl.common_lookup_type = 'DEBIT'
                        THEN  transaction_amount
                        ELSE t.transaction_amount * -1
                        END
              END),'99,999.00'),10,' ') AS "YTD"
FROM     transaction t INNER JOIN common_lookup cl
ON       t.transaction_type = cl.common_lookup_id 
WHERE    cl.common_lookup_table = 'TRANSACTION'
AND      cl.common_lookup_column = 'TRANSACTION_TYPE' 
ORDER BY SORTKEY;


SPOOL OFF
