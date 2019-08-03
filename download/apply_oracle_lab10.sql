/* 
** Enkey, William
** CIT225, McLaughlin
** 2018, WINTER (TA)
*/

/* 
** This calls Lab #9, Lab #9 calls Lab #8, Lab #8 calls Lab #7, Lab #7 
** calls Lab #6, Lab #6 calls Lab #5, and Lab #5 calls both the Creation 
** and Seed script files.
*/ 
@../lab9/apply_oracle_lab9.sql

SPOOL apply_oracle_lab10.log

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 01 -----------------------------------------------
------------------------------------------------------------------------------------------------------

SELECT   DISTINCT c.contact_id
FROM     member m INNER JOIN transaction_upload tu
ON       m.account_number = tu.account_number INNER JOIN contact c
ON       m.member_id = c.member_id
WHERE    c.first_name = tu.first_name
AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
AND      c.last_name = tu.last_name
ORDER BY c.contact_id;

-------
-- a --
-------

SELECT   COUNT(*)
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id;

-------
-- b --
-------

SELECT   COUNT(*)
FROM     contact c INNER JOIN transaction_upload tu
ON       c.first_name = tu.first_name
AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
AND      c.last_name = tu.last_name;

-------
-- c --
-------

SELECT   COUNT(*)
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN transaction_upload tu
ON       c.first_name = tu.first_name
AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
AND      c.last_name = tu.last_name
AND      m.account_number = tu.account_number;

--------------------------------
-- d -- e -- f -- g -- h -- i --
--------------------------------

SET NULL '<Null>'
COLUMN rental_id        FORMAT 9999 HEADING "Rental|ID #"
COLUMN customer         FORMAT 9999 HEADING "Customer|ID #"
COLUMN check_out_date   FORMAT A9   HEADING "Check Out|Date"
COLUMN return_date      FORMAT A10  HEADING "Return|Date"
COLUMN created_by       FORMAT 9999 HEADING "Created|By"
COLUMN creation_date    FORMAT A10  HEADING "Creation|Date"
COLUMN last_updated_by  FORMAT 9999 HEADING "Last|Update|By"
COLUMN last_update_date FORMAT A10  HEADING "Last|Updated"

SELECT DISTINCT r.rental_id AS rental_id
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
       AND TRUNC(tu.return_date) = TRUNC(r.return_date);

SELECT   COUNT(*) AS "Rental before count"
FROM     rental;

INSERT INTO RENTAL
SELECT NVL(rental_id, rental_s1.NEXTVAL) AS rental_id
,      customer_id
,      check_out_date
,      return_date
,      created_by
,      creation_date
,      last_updated_by
,      last_update_date
FROM (SELECT DISTINCT r.rental_id AS rental_id
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
       AND TRUNC(tu.return_date) = TRUNC(r.return_date));

SELECT   COUNT(*) AS "Rental after count"
FROM     rental;

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 02 -----------------------------------------------
------------------------------------------------------------------------------------------------------

SELECT   COUNT(*)
FROM    (SELECT   rental_item_id
         ,        r.rental_id AS rental_id
         ,        tu.item_id AS item_id
         ,        ((TRUNC(r.return_date) - TRUNC(r.check_out_date)) * 1.06) AS rental_item_price
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
                        AND tu.item_id = ri.item_id) il;

SET NULL '<Null>'
COLUMN rental_item_id     FORMAT 99999 HEADING "Rental|Item ID #"
COLUMN rental_id          FORMAT 99999 HEADING "Rental|ID #"
COLUMN item_id            FORMAT 99999 HEADING "Item|ID #"
COLUMN rental_item_price  FORMAT 999.99 HEADING "Rental|Item|Price"
COLUMN rental_item_type   FORMAT 99999 HEADING "Rental|Item|Type"
SELECT  il.rental_item_id
,       il.rental_id
,       il.item_id
,       il.rental_item_price
,       il.rental_item_type
,       il.created_by
,       il.creation_date
,       il.last_updated_by
,       il.last_update_date
FROM (SELECT   rental_item_id
         ,        r.rental_id AS rental_id
         ,        tu.item_id AS item_id
         ,        ((TRUNC(r.return_date) - TRUNC(r.check_out_date)) * 1.06) AS rental_item_price
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
                        AND tu.item_id = ri.item_id) il;

SELECT   COUNT(*) AS "Rental Item Before Count"
FROM     rental_item;

INSERT INTO rental_item
SELECT  NVL(il.rental_item_id, rental_item_s1.NEXTVAL) AS rental_item_id
,       il.rental_id
,       il.item_id
,       il.created_by
,       il.creation_date
,       il.last_updated_by
,       il.last_update_date
,       il.rental_item_price
,       il.rental_item_type
FROM (SELECT   rental_item_id
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
                        AND tu.item_id = ri.item_id) il;

SELECT   COUNT(*) AS "Rental Item After Count"
FROM     rental_item;

------------------------------------------------------------------------------------------------------
---------------------------------------------- Step 03 -----------------------------------------------
------------------------------------------------------------------------------------------------------

-- REMEMBER to use a SUM function and GROUP by in the insert --
SELECT COUNT(*)
FROM (SELECT      t.transaction_id AS transaction_id
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
                        ,		m.credit_card_number) il;

SELECT COUNT(*) FROM transaction;

INSERT INTO transaction
SELECT
        NVL(il2.transaction_id, transaction_s1.NEXTVAL)
,       il2.transaction_account
,       il2.transaction_type
,       il2.transaction_date
,       il2.transaction_amount
,       il2.rental_id
,       il2.payment_method_type
,       il2.payment_account_number
,       il2.created_by
,       il2.creation_date
,       il2.last_updated_by
,       il2.last_update_date
FROM (SELECT      t.transaction_id AS transaction_id
         ,        m.account_number AS transaction_account
         ,        cl1.common_lookup_id AS transaction_type
         ,        TRUNC(tu.transaction_date) AS transaction_date
         ,        (SUM(tu.transaction_amount) / 1.06) AS transaction_amount
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
                        ,		m.credit_card_number
                        ,               m.account_number) il2;

SELECT COUNT(*) FROM transaction;

SPOOL OFF
