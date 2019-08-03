/* 
** Enkey, William
** CIT225, McLaughlin
** 2018, Winter (TA)
*/ 

-- Call LAB09, NOT lab10 -- 
@/home/student/Data/cit225/oracle/lab9/apply_oracle_lab9.sql

SPOOL apply_oracle_lab11.log

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 01 -----------------------------------------------
------------------------------------------------------------------------------------------------------
/*
MERGE INTO rental target
USING ( SELECT DISTINCT r.rental_id AS rental_id
     ,                c.contact_id AS customer_id
     ,                TRUNC(tu.check_out_date) AS check_out_date
     ,                TRUNC(tu.return_date) AS return_date
     ,                1 AS created_by
     ,                SYSDATE AS creation_date
     ,                1 AS last_updated_by
     ,                SYSDATE AS last_update_date
      FROM contact c INNER JOIN member m
        ON c.member_id = m.member_id INNER JOIN transaction_upload tu
        ON m.account_number = tu.account_number
       AND c.first_name = tu.first_name
       AND NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
       AND c.last_name = tu.last_name LEFT JOIN rental r
        ON c.contact_id = r.customer_id 
       AND TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
       AND TRUNC(tu.return_date) = TRUNC(r.return_date) ) source
ON (target.rental_id = source.rental_id)
WHEN MATCHED THEN
UPDATE SET target.last_updated_by = source.last_updated_by
,          target.last_update_date = source.last_update_date
WHEN NOT MATCHED THEN
INSERT VALUES
( rental_s1.NEXTVAL
, source.customer_id
, TRUNC(source.check_out_date)
, TRUNC(source.return_date)
, source.created_by
, TRUNC(source.creation_date)
, source.last_updated_by
, TRUNC(source.last_update_date));

SELECT   TO_CHAR(COUNT(*),'99,999') AS "Rental after merge"
FROM     rental;

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 02 -----------------------------------------------
------------------------------------------------------------------------------------------------------

MERGE INTO rental_item target
USING (SELECT   rental_item_id
         ,        r.rental_id AS rental_id
         ,        tu.item_id AS item_id
         ,        TRUNC(r.return_date) - TRUNC(r.check_out_date) AS rental_item_price
         ,        cl.common_lookup_id AS rental_item_type
         ,        1002 AS created_by
         ,        TRUNC(SYSDATE) AS creation_date
         ,        1002 AS last_updated_by
         ,        TRUNC(SYSDATE) AS last_update_date
         FROM  member m INNER JOIN contact c 
                        ON m.member_id = c.member_id
                        INNER JOIN transaction_upload tu 
                        ON m.account_number = tu.account_number
                        AND c.first_name = tu.first_name
                        AND NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
                        AND c.last_name = tu.last_name
                        LEFT JOIN rental r
                        ON c.contact_id = r.customer_id
                        AND TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
                        AND TRUNC(tu.return_date) = TRUNC(r.return_date)
                        INNER JOIN common_lookup cl
                        ON tu.rental_item_type = cl.common_lookup_type
                        AND cl.common_lookup_column = 'RENTAL_ITEM_TYPE'
                        LEFT JOIN rental_item ri
                        ON r.rental_id = ri.rental_id
                        AND tu.item_id = ri.item_id) source
ON (target.rental_item_id = source.rental_item_id)
WHEN MATCHED THEN
UPDATE SET target.last_updated_by = source.last_updated_by
,          target.last_update_date = source.last_update_date
WHEN NOT MATCHED THEN
INSERT VALUES
( rental_item_s1.NEXTVAL
, source.rental_id
, source.item_id
, source.created_by
, source.creation_date
, source.last_updated_by
, source.last_update_date
, source.rental_item_price
, source.rental_item_type);

SELECT   TO_CHAR(COUNT(*),'99,999') AS "Rental Item after merge"
FROM     rental_item;

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 03 -----------------------------------------------
------------------------------------------------------------------------------------------------------

MERGE INTO transaction target
USING ( SELECT      t.transaction_id AS transaction_id
         ,        tu.payment_account_number AS transaction_account
         ,        cl1.common_lookup_id AS transaction_type
         ,        TRUNC(tu.transaction_date) AS transaction_date
         ,        SUM(tu.transaction_amount) / 1.06 AS transaction_amount
         ,        r.rental_id AS rental_id
         ,        cl2.common_lookup_id AS payment_method_type
         ,        m.credit_card_number AS payment_account_number
         ,        1002 AS created_by
         ,        TRUNC(SYSDATE) AS creation_date
         ,        1002 AS last_updated_by
         ,        TRUNC(SYSDATE) AS last_update_date
         FROM  member m INNER JOIN contact c 
                                ON m.member_id = c.member_id
                        INNER JOIN transaction_upload tu 
                                ON m.account_number = tu.account_number
                                AND c.first_name = tu.first_name
                                AND NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
                                AND c.last_name = tu.last_name
                        INNER JOIN rental r
                                ON c.contact_id = r.customer_id
                                AND TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
                                AND TRUNC(tu.return_date) = TRUNC(r.return_date)
                        INNER JOIN common_lookup cl1
                                ON      cl1.common_lookup_table = 'TRANSACTION'
                                AND     cl1.common_lookup_column = 'TRANSACTION_TYPE'
                                AND     cl1.common_lookup_type = tu.transaction_type
                        INNER JOIN common_lookup cl2
                                ON      cl2.common_lookup_table = 'TRANSACTION'
                                AND     cl2.common_lookup_column = 'PAYMENT_METHOD_TYPE'
                                AND     cl2.common_lookup_type = tu.payment_method_type
                        LEFT JOIN transaction t
                                ON tu.payment_account_number = t.transaction_account
                                AND cl1.common_lookup_id = t.transaction_type
                                AND tu.transaction_date = t.transaction_date
                                AND cl2.common_lookup_id = t.payment_method_type
                                AND m.credit_card_number = t.payment_account_number
                                AND tu.transaction_amount = t.transaction_amount
                        GROUP BY transaction_id 
                        ,               tu.payment_account_number
                        ,		cl1.common_lookup_id
                        ,		tu.transaction_date
                        ,		r.rental_id
                        ,		cl2.common_lookup_id
                        ,		m.credit_card_number) source
ON (target.transaction_id = source.transaction_id)
WHEN MATCHED THEN
UPDATE SET target.last_updated_by = source.last_updated_by
,          target.last_update_date = source.last_update_date
WHEN NOT MATCHED THEN
INSERT VALUES
( transaction_s1.nextval
, source.transaction_account
, source.transaction_type
, TRUNC(source.transaction_date)
, source.transaction_amount
, source.rental_id
, source.payment_method_type
, source.payment_account_number
, source.created_by
, source.creation_date
, source.last_updated_by
, source.last_update_date);

SELECT   TO_CHAR(COUNT(*),'99,999') AS "Transaction after merge"
FROM     transaction;
*/
------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 04 -----------------------------------------------
------------------------------------------------------------------------------------------------------

-------
-- a --
-------

CREATE OR REPLACE PROCEDURE upload_transaction IS
BEGIN
  SAVEPOINT starting_point;

MERGE INTO rental target
USING ( SELECT DISTINCT r.rental_id AS rental_id
     ,                c.contact_id AS customer_id
     ,                TRUNC(tu.check_out_date) AS check_out_date
     ,                TRUNC(tu.return_date) AS return_date
     ,                1 AS created_by
     ,                SYSDATE AS creation_date
     ,                1 AS last_updated_by
     ,                SYSDATE AS last_update_date
      FROM contact c INNER JOIN member m
        ON c.member_id = m.member_id INNER JOIN transaction_upload tu
        ON m.account_number = tu.account_number
       AND c.first_name = tu.first_name
       AND NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
       AND c.last_name = tu.last_name LEFT JOIN rental r
        ON c.contact_id = r.customer_id 
       AND TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
       AND TRUNC(tu.return_date) = TRUNC(r.return_date) ) source
ON (target.rental_id = source.rental_id)
WHEN MATCHED THEN
UPDATE SET target.last_updated_by = source.last_updated_by
,          target.last_update_date = source.last_update_date
WHEN NOT MATCHED THEN
INSERT VALUES
( rental_s1.NEXTVAL
, source.customer_id
, TRUNC(source.check_out_date)
, TRUNC(source.return_date)
, source.created_by
, TRUNC(source.creation_date)
, source.last_updated_by
, TRUNC(source.last_update_date));

MERGE INTO rental_item target
USING (SELECT   rental_item_id
         ,        r.rental_id AS rental_id
         ,        tu.item_id AS item_id
         ,        TRUNC(r.return_date) - TRUNC(r.check_out_date) AS rental_item_price
         ,        cl.common_lookup_id AS rental_item_type
         ,        1002 AS created_by
         ,        TRUNC(SYSDATE) AS creation_date
         ,        1002 AS last_updated_by
         ,        TRUNC(SYSDATE) AS last_update_date
         FROM  member m INNER JOIN contact c 
                        ON m.member_id = c.member_id
                        INNER JOIN transaction_upload tu 
                        ON m.account_number = tu.account_number
                        AND c.first_name = tu.first_name
                        AND NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
                        AND c.last_name = tu.last_name
                        LEFT JOIN rental r
                        ON c.contact_id = r.customer_id
                        AND TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
                        AND TRUNC(tu.return_date) = TRUNC(r.return_date)
                        INNER JOIN common_lookup cl
                        ON tu.rental_item_type = cl.common_lookup_type
                        AND cl.common_lookup_column = 'RENTAL_ITEM_TYPE'
                        LEFT JOIN rental_item ri
                        ON r.rental_id = ri.rental_id
                        AND tu.item_id = ri.item_id) source
ON (target.rental_item_id = source.rental_item_id)
WHEN MATCHED THEN
UPDATE SET target.last_updated_by = source.last_updated_by
,          target.last_update_date = source.last_update_date
WHEN NOT MATCHED THEN
INSERT VALUES
( rental_item_s1.NEXTVAL
, source.rental_id
, source.item_id
, source.created_by
, source.creation_date
, source.last_updated_by
, source.last_update_date
, source.rental_item_price
, source.rental_item_type);

MERGE INTO transaction target
USING ( SELECT      t.transaction_id AS transaction_id
         ,        tu.payment_account_number AS transaction_account
         ,        cl1.common_lookup_id AS transaction_type
         ,        TRUNC(tu.transaction_date) AS transaction_date
         ,        SUM(tu.transaction_amount) / 1.06 AS transaction_amount
         ,        r.rental_id AS rental_id
         ,        cl2.common_lookup_id AS payment_method_type
         ,        m.credit_card_number AS payment_account_number
         ,        1002 AS created_by
         ,        TRUNC(SYSDATE) AS creation_date
         ,        1002 AS last_updated_by
         ,        TRUNC(SYSDATE) AS last_update_date
         FROM  member m INNER JOIN contact c 
                                ON m.member_id = c.member_id
                        INNER JOIN transaction_upload tu 
                                ON m.account_number = tu.account_number
                                AND c.first_name = tu.first_name
                                AND NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
                                AND c.last_name = tu.last_name
                        INNER JOIN rental r
                                ON c.contact_id = r.customer_id
                                AND TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
                                AND TRUNC(tu.return_date) = TRUNC(r.return_date)
                        INNER JOIN common_lookup cl1
                                ON      cl1.common_lookup_table = 'TRANSACTION'
                                AND     cl1.common_lookup_column = 'TRANSACTION_TYPE'
                                AND     cl1.common_lookup_type = tu.transaction_type
                        INNER JOIN common_lookup cl2
                                ON      cl2.common_lookup_table = 'TRANSACTION'
                                AND     cl2.common_lookup_column = 'PAYMENT_METHOD_TYPE'
                                AND     cl2.common_lookup_type = tu.payment_method_type
                        LEFT JOIN transaction t
                                ON tu.payment_account_number = t.transaction_account     -- ET :: r.rental_id = t.rental_id
                                AND cl1.common_lookup_id = t.transaction_type
                                AND tu.transaction_date = t.transaction_date
                                AND cl2.common_lookup_id = t.payment_method_type
                                AND m.credit_card_number = t.payment_account_number
                                AND tu.transaction_amount = t.transaction_amount
                        GROUP BY transaction_id 
                        ,               tu.payment_account_number
                        ,		cl1.common_lookup_id
                        ,		tu.transaction_date
                        ,		r.rental_id
                        ,		cl2.common_lookup_id
                        ,		m.credit_card_number) source
ON (target.transaction_id = source.transaction_id)
WHEN MATCHED THEN
UPDATE SET target.last_updated_by = source.last_updated_by
,          target.last_update_date = source.last_update_date
WHEN NOT MATCHED THEN
INSERT VALUES
( transaction_s1.nextval
, source.transaction_account
, source.transaction_type
, TRUNC(source.transaction_date)
, source.transaction_amount
, source.rental_id
, source.payment_method_type
, source.payment_account_number
, source.created_by
, source.creation_date
, source.last_updated_by
, source.last_update_date);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END;
/

-------
-- b --
-------

EXECUTE upload_transaction;

-------
-- c --
-------

COLUMN rental_count      FORMAT 99,999 HEADING "Rental|Count"
COLUMN rental_item_count FORMAT 99,999 HEADING "Rental|Item|Count"
COLUMN transaction_count FORMAT 99,999 HEADING "Transaction|Count"
 
SELECT   il1.rental_count
,        il2.rental_item_count
,        il3.transaction_count
FROM    (SELECT COUNT(*) AS rental_count FROM rental) il1 CROSS JOIN
        (SELECT COUNT(*) AS rental_item_count FROM rental_item) il2 CROSS JOIN
        (SELECT COUNT(*) AS transaction_count FROM TRANSACTION) il3;

-------
-- d --
-------

EXECUTE upload_transaction;

-------
-- e --
-------

COLUMN rental_count      FORMAT 99,999 HEADING "Rental|Count"
COLUMN rental_item_count FORMAT 99,999 HEADING "Rental|Item|Count"
COLUMN transaction_count FORMAT 99,999 HEADING "Transaction|Count"
 
SELECT   il1.rental_count
,        il2.rental_item_count
,        il3.transaction_count
FROM    (SELECT COUNT(*) AS rental_count FROM rental) il1 CROSS JOIN
        (SELECT COUNT(*) AS rental_item_count FROM rental_item) il2 CROSS JOIN
        (SELECT COUNT(*) AS transaction_count FROM TRANSACTION) il3;

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 05 -----------------------------------------------
------------------------------------------------------------------------------------------------------

/*
SELECT month       AS "Month"
,      base        AS "Base Revenue"
,      ten_plus    AS "10 Plus Revenue"
,      twenty_plus AS "20 Plus Revenue"
,      ten_diff    AS "10 Plus Difference"
,      twenty_diff AS "20 Plus Difference"
FROM  ( SELECT EXTRACT(month FROM transaction_date) AS month
      , TO_CHAR(SUM(transaction_amount), '9,999,999.00') AS base
      , TO_CHAR(SUM(transaction_amount) * 1.1, '9,999,999.00') AS ten_plus
      , TO_CHAR(SUM(transaction_amount) * 1.2, '9,999,999.00') AS twenty_plus
      , TO_CHAR(SUM(transaction_amount) * 0.1, '9,999,999.00') AS ten_diff
      , TO_CHAR(SUM(transaction_amount) * 0.2, '9,999,999.00') AS twenty_diff
      FROM transaction
      WHERE EXTRACT (YEAR FROM transaction_date) = 2009
      GROUP BY EXTRACT(MONTH FROM transaction_date)) il
GROUP BY month, base, ten_plus, twenty_plus, ten_diff, twenty_diff
ORDER BY MIN(il.month);


SELECT month, revenue, "10 plus", "20 Plus", "10 Plus B", "20 Plus B"
FROM   ( SELECT TO_CHAR(transaction_date, 'MON-YYYY') AS month
       , TO_CHAR(SUM(transaction_amount), '$9,999,999.00') AS Revenue
       , TO_CHAR(SUM(transaction_amount) * 1.1 , '$9,999,999.00') AS "10 plus"
       , TO_CHAR(SUM(transaction_amount) * 1.2 , '$9,999,999.00') AS "20 Plus"
       , TO_CHAR(SUM(transaction_amount) * 0.1 , '$9,999,999.00') AS "10 Plus B"
       , TO_CHAR(SUM(transaction_amount) * 0.2 , '$9,999,999.00') AS "20 Plus B"
       FROM transaction
        WHERE EXTRACT(YEAR FROM transaction_date) = '2009'
        GROUP BY TO_CHAR(transaction_date, 'MON-YYYY')
        ORDER BY MIN(transaction_date));



SET PAGESIZE 9999

SELECT TO_CHAR(TO_DATE(m, 'MM'), 'MON') || '-' || year AS month
, TO_CHAR(base_revenue,'$9,999,999.00') AS base_revenue
, TO_CHAR(base_revenue * 1.1,'$9,999,999.00') AS "10_PLUS"
, TO_CHAR(base_revenue * 1.2,'$9,999,999.00') AS "20_PLUS"
, TO_CHAR(base_revenue * 1.1 - base_revenue,'$9,999,999.00') AS "10_PLUS_LESS_B"
, TO_CHAR(base_revenue * 1.2 - base_revenue,'$9,999,999.00') AS "20_PLUS_LESS_B"
FROM (SELECT EXTRACT(YEAR FROM transaction_date) AS year
, EXTRACT(MONTH FROM transaction_date) AS m
, SUM(transaction_amount) AS base_revenue
FROM transaction
WHERE EXTRACT(YEAR FROM transaction_date) = 2009
GROUP BY EXTRACT(MONTH FROM transaction_date)
, EXTRACT(YEAR FROM transaction_date))
ORDER BY m;

SELECT "Month"
,       "Base Revenue"
,       "10 Plus Revenue"
,       "20 Plus Revenue"
,       "10 Plus Difference"
,       "20 Plus Difference"
FROM (SELECT TO_CHAR(t.transaction_date, 'MON-YYYY')                    AS "Month"
,            TO_CHAR(SUM(t.transaction_amount), '9,999,999.99')         AS "Base Revenue"
,            TO_CHAR(SUM(t.transaction_amount) * 1.1, '9,999,999.99')   AS "10 Plus Revenue"
,            TO_CHAR(SUM(t.transaction_amount) * 1.2, '9,999,999.99')   AS "20 Plus Revenue"
,            TO_CHAR(SUM(t.transaction_amount) * 0.1, '9,999,999.99')   AS "10 Plus Difference"
,            TO_CHAR(SUM(t.transaction_amount) * 0.2, '9,999,999.99')   AS "20 Plus Difference"
        FROM transaction t
        WHERE EXTRACT(YEAR FROM t.transaction_date) = 2009
        GROUP BY TO_CHAR(t.transaction_date, 'MON-YYYY')
        ORDER BY MIN(t.transaction_date));

*/

SELECT  month		      AS "MONTH"
, 	    base_revenue  AS "BASE REVENUE"
, 	    ten_plus	    AS "10 PLUS"
,	      twenty_plus	  AS "20 PLUS"
,	      ten_diff	    AS "10 DIFFERENCE"
,	      twenty_diff	  AS "20 DIFFERENCE"
FROM  (SELECT TO_CHAR(transaction_date, 'MON YYYY') AS month
      ,       EXTRACT(month FROM transaction_date) AS month_list
	    ,       TO_CHAR(SUM(transaction_amount)      , '$9,999,999.00') AS base_revenue
	    ,       TO_CHAR(SUM(transaction_amount) * 1.1, '$9,999,999.00') AS ten_plus
	    ,       TO_CHAR(SUM(transaction_amount) * 1.2, '$9,999,999.00') AS twenty_plus
	    ,       TO_CHAR(SUM(transaction_amount) * 0.1, '$9,999,999.00') AS ten_diff
	    ,       TO_CHAR(SUM(transaction_amount) * 0.2, '$9,999,999.00') AS twenty_diff
	    FROM      transaction
	    WHERE     EXTRACT(YEAR FROM transaction_date) = 2009
	    GROUP BY  TO_CHAR(transaction_date, 'MON YYYY')
	    ,	        EXTRACT(month FROM transaction_date)) il
  ORDER BY      il.month_list;

SPOOL OFF

