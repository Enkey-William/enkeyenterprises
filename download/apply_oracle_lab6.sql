-- Run the prior lab script --
@/home/student/Data/cit225/oracle/lab5/apply_oracle_lab5.sql
 
SPOOL apply_oracle_lab6.log

---------------------------------------------------------------------------------------
--------------------------------------STEP 01------------------------------------------
---------------------------------------------------------------------------------------
 
ALTER TABLE rental_item
ADD (rental_item_type NUMBER);

ALTER TABLE rental_item
ADD CONSTRAINT fk_rental_item_5 FOREIGN KEY(rental_item_type) REFERENCES common_lookup(common_lookup_id);

ALTER TABLE rental_item
ADD (rental_item_price NUMBER(5,2));

SET NULL ''
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'RENTAL_ITEM'
ORDER BY 2;

---------------------------------------------------------------------------------------
--------------------------------------STEP 02------------------------------------------
---------------------------------------------------------------------------------------

CREATE TABLE price
( price_id              NUMBER          CONSTRAINT pk_price_1 PRIMARY KEY
, item_id               NUMBER          CONSTRAINT nn_price_1 NOT NULL
, price_type            NUMBER  
, active_flag           VARCHAR2(1)     CONSTRAINT nn_price_2 NOT NULL
, start_date            DATE            CONSTRAINT nn_price_3 NOT NULL
, end_date              DATE
, amount                NUMBER          CONSTRAINT nn_price_4 NOT NULL
, created_by            NUMBER          CONSTRAINT nn_price_5 NOT NULL
, creation_date         DATE            CONSTRAINT nn_price_6 NOT NULL
, last_updated_by       NUMBER          CONSTRAINT nn_price_7 NOT NULL
, last_update_date      DATE            CONSTRAINT nn_price_8 NOT NULL
, CONSTRAINT fk_price_1 FOREIGN KEY(item_id) REFERENCES item(item_id)
, CONSTRAINT fk_price_2 FOREIGN KEY(price_type) REFERENCES common_lookup(common_lookup_id)
, CONSTRAINT yn_price   CHECK(active_flag IN ('Y', 'N'))
, CONSTRAINT fk_price_3 FOREIGN KEY(created_by) REFERENCES system_user(system_user_id)
, CONSTRAINT fk_price_4 FOREIGN KEY(last_updated_by) REFERENCES system_user(system_user_id));

SET NULL ''
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'PRICE'
ORDER BY 2;

COLUMN constraint_name   FORMAT A16
COLUMN search_condition  FORMAT A30
SELECT   uc.constraint_name
,        uc.search_condition
FROM     user_constraints uc INNER JOIN user_cons_columns ucc
ON       uc.table_name = ucc.table_name
AND      uc.constraint_name = ucc.constraint_name
WHERE    uc.table_name = UPPER('price')
AND      ucc.column_name = UPPER('active_flag')
AND      uc.constraint_name = UPPER('yn_price')
AND      uc.constraint_type = 'C';

---------------------------------------------------------------------------------------
--------------------------------------STEP 03------------------------------------------
---------------------------------------------------------------------------------------

-- A --
ALTER TABLE item
RENAME COLUMN item_release_date TO release_date;

SET NULL ''
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

-- B --
INSERT INTO item
( item_id, item_barcode, item_type, item_title
, item_rating, release_date, created_by, creation_date
, last_updated_by, last_update_date)
VALUES
( item_s1.NEXTVAL, '09005587431'
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'ITEM'
   AND    common_lookup_type = 'DVD_WIDE_SCREEN')
, 'Tron', 'PG-13', TRUNC(SYSDATE - 1)
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO item
( item_id, item_barcode, item_type, item_title
, item_rating, release_date, created_by, creation_date
, last_updated_by, last_update_date)
VALUES
( item_s1.NEXTVAL, '882020923723'
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'ITEM'
   AND    common_lookup_type = 'DVD_FULL_SCREEN')
, 'Enders Game', 'PG-13', TRUNC(SYSDATE - 1)
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO item
( item_id, item_barcode, item_type, item_title
, item_rating, release_date, created_by, creation_date
, last_updated_by, last_update_date)
VALUES
( item_s1.NEXTVAL, '1825865'
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'ITEM'
   AND    common_lookup_type = 'DVD_WIDE_SCREEN')
, 'Elysium', 'PG-13', TRUNC(SYSDATE - 1)
, 1, SYSDATE, 1, SYSDATE);

SELECT   i.item_title
,        SYSDATE AS today
,        i.release_date
FROM     item i
WHERE   (SYSDATE - i.release_date) < 31;

-- C --
INSERT INTO member
( member_id, member_type, account_number
, credit_card_number, credit_card_type
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( member_s1.NEXTVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MEMBER'
   AND    common_lookup_type = 'GROUP')
, 'G777-1313', '1111-2222-5389-6471'
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MEMBER'
   AND    common_lookup_type = 'DISCOVER_CARD')
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO contact
( contact_id, member_id, contact_type
, first_name, middle_name, last_name
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( contact_s1.NEXTVAL, member_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'CONTACT'
   AND    common_lookup_type = 'CUSTOMER')
, 'Harry', '', 'Potter'
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO address
( address_id, contact_id, address_type
, city, state_province, postal_code
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( address_s1.NEXTVAL, contact_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MULTIPLE'
   AND    common_lookup_type = 'HOME')
, 'Provo', 'Utah', '84601'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO street_address
( street_address_id, address_id
, street_address
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( street_address_s1.NEXTVAL, address_s1.CURRVAL
, '713 Godric Hallow'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO telephone
( telephone_id, contact_id, address_id, telephone_type
, country_code, area_code, telephone_number
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( telephone_s1.NEXTVAL, contact_s1.CURRVAL, address_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MULTIPLE'
   AND    common_lookup_type = 'HOME')
, 'USA', '801', '713-1980'
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO contact
( contact_id, member_id, contact_type
, first_name, middle_name, last_name
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( contact_s1.NEXTVAL, member_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'CONTACT'
   AND    common_lookup_type = 'CUSTOMER')
, 'Ginny', '', 'Potter'
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO address
( address_id, contact_id, address_type
, city, state_province, postal_code
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( address_s1.NEXTVAL, contact_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MULTIPLE'
   AND    common_lookup_type = 'HOME')
, 'Provo', 'Utah', '84601'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO street_address
( street_address_id, address_id
, street_address
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( street_address_s1.NEXTVAL, address_s1.CURRVAL
, '713 Godric Hallow'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO telephone
( telephone_id, contact_id, address_id, telephone_type
, country_code, area_code, telephone_number
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( telephone_s1.NEXTVAL, contact_s1.CURRVAL, address_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MULTIPLE'
   AND    common_lookup_type = 'HOME')
, 'USA', '801', '713-1980'
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO contact
( contact_id, member_id, contact_type
, first_name, middle_name, last_name
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( contact_s1.NEXTVAL, member_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'CONTACT'
   AND    common_lookup_type = 'CUSTOMER')
, 'Lily', 'Luna', 'Potter'
, 1002, SYSDATE, 1002, SYSDATE);

INSERT INTO address
( address_id, contact_id, address_type
, city, state_province, postal_code
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( address_s1.NEXTVAL, contact_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MULTIPLE'
   AND    common_lookup_type = 'HOME')
, 'Provo', 'Utah', '84601'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO street_address
( street_address_id, address_id
, street_address
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( street_address_s1.NEXTVAL, address_s1.CURRVAL
, '713 Godric Hallow'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO telephone
( telephone_id, contact_id, address_id, telephone_type
, country_code, area_code, telephone_number
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( telephone_s1.NEXTVAL, contact_s1.CURRVAL, address_s1.CURRVAL
, (SELECT common_lookup_id
   FROM   common_lookup
   WHERE  common_lookup_context = 'MULTIPLE'
   AND    common_lookup_type = 'HOME')
, 'USA', '801', '713-1980'
, 1002, SYSDATE, 1002, SYSDATE);

COLUMN full_name FORMAT A20
COLUMN city      FORMAT A10
COLUMN state     FORMAT A10
SELECT   c.last_name || ', ' || c.first_name AS full_name
,        a.city
,        a.state_province AS state
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN address a
ON       c.contact_id = a.contact_id INNER JOIN street_address sa
ON       a.address_id = sa.address_id INNER JOIN telephone t
ON       c.contact_id = t.contact_id
WHERE    c.last_name = 'Potter';

-- D --
INSERT INTO rental
( rental_id, customer_id
, check_out_date, return_date
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_s1.NEXTVAL
, (SELECT contact_id
   FROM   contact
   WHERE  first_name = 'Harry'
   AND    last_name = 'Potter')
, TRUNC(SYSDATE), TRUNC(SYSDATE + 1)
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id, rental_id, item_id
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_item_s1.NEXTVAL, rental_s1.CURRVAL
, (SELECT item_id
   FROM   item
   WHERE  item_barcode = '9736-05640-4')
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id, rental_id, item_id
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_item_s1.NEXTVAL, rental_s1.CURRVAL
, (SELECT item_id
   FROM   item
   WHERE  item_barcode = '09005587431')
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental
( rental_id, customer_id
, check_out_date, return_date
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_s1.NEXTVAL
, (SELECT contact_id
   FROM   contact
   WHERE  first_name = 'Ginny'
   AND    last_name = 'Potter')
, TRUNC(SYSDATE), TRUNC(SYSDATE + 3)
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id, rental_id, item_id
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_item_s1.NEXTVAL, rental_s1.CURRVAL
, (SELECT item_id
   FROM   item
   WHERE  item_barcode = '882020923723')
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental
( rental_id, customer_id
, check_out_date, return_date
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_s1.NEXTVAL
, (SELECT contact_id
   FROM   contact
   WHERE  first_name = 'Lily'
   AND    middle_name = 'Luna'
   AND    last_name = 'Potter')
, (SYSDATE), (SYSDATE + 5)
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id, rental_id, item_id
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( rental_item_s1.NEXTVAL, rental_s1.CURRVAL
, (SELECT item_id
   FROM   item
   WHERE  item_barcode = '1825865')
, 1, SYSDATE, 1, SYSDATE);

COLUMN full_name   FORMAT A18
COLUMN rental_id   FORMAT 9999
COLUMN rental_days FORMAT A14
COLUMN rentals     FORMAT 9999
COLUMN items       FORMAT 9999
SELECT   c.last_name||', '||c.first_name||' '||c.middle_name AS full_name
,        r.rental_id
,       (r.return_date - r.check_out_date) || '-DAY RENTAL' AS rental_days
,        COUNT(DISTINCT r.rental_id) AS rentals
,        COUNT(ri.rental_item_id) AS items
FROM     rental r INNER JOIN rental_item ri
ON       r.rental_id = ri.rental_id INNER JOIN contact c
ON       r.customer_id = c.contact_id
WHERE   (SYSDATE - r.check_out_date) < 15
AND      c.last_name = 'Potter'
GROUP BY c.last_name||', '||c.first_name||' '||c.middle_name
,        r.rental_id
,       (r.return_date - r.check_out_date) || '-DAY RENTAL'
ORDER BY 2;

---------------------------------------------------------------------------------------
--------------------------------------STEP 04------------------------------------------
---------------------------------------------------------------------------------------

-- A --
DROP INDEX common_lookup_n1;
DROP INDEX common_lookup_u2;

COLUMN table_name FORMAT A14
COLUMN index_name FORMAT A20
SELECT   table_name
,        index_name
FROM     user_indexes
WHERE    table_name = 'COMMON_LOOKUP';

-- B --
ALTER TABLE common_lookup
ADD (common_lookup_table  VARCHAR2(30))
ADD (common_lookup_column VARCHAR2(30))
ADD (common_lookup_code   VARCHAR2(30));

SET NULL ''
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'COMMON_LOOKUP'
ORDER BY 2;

-- C --
UPDATE common_lookup
SET common_lookup_table = CASE WHEN common_lookup_context = 'MULTIPLE' 
                                THEN 'ADDRESS' 
                                ELSE common_lookup_context
                                END;

UPDATE common_lookup
SET common_lookup_column = CASE
		  	   WHEN common_lookup_table = 'MEMBER' AND common_lookup_type = 'INDIVIDUAL' OR common_lookup_type = 'GROUP'
			   THEN common_lookup_context || '_TYPE'
			   WHEN common_lookup_type = 'VISA_CARD' OR common_lookup_type = 'MASTER_CARD' OR common_lookup_type = 'DISCOVER_CARD'
			   THEN 'CREDIT_CARD_TYPE'
			   WHEN common_lookup_context = 'MULTIPLE'
			   THEN 'ADDRESS_TYPE'
   			   WHEN common_lookup_context <> 'MEMBER' OR common_lookup_context <> 'MULTIPLE'
			   THEN common_lookup_context || '_TYPE' 
			   ELSE ''
			   END;

INSERT INTO common_lookup
( common_lookup_id
, common_lookup_context
, common_lookup_type
, common_lookup_meaning
, common_lookup_table
, common_lookup_column
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( common_lookup_s1.NEXTVAL
, 'MULTIPLE'
, 'HOME'
, 'Home telephone'
, 'TELEPHONE'
, 'TELEPHONE_TYPE'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO common_lookup
( common_lookup_id
, common_lookup_context
, common_lookup_type
, common_lookup_meaning
, common_lookup_table
, common_lookup_column
, created_by, creation_date, last_updated_by, last_update_date)
VALUES
( common_lookup_s1.NEXTVAL
, 'MULTIPLE'
, 'WORK'
, 'Work telephone'
, 'TELEPHONE'
, 'TELEPHONE_TYPE'
, 1, SYSDATE, 1, SYSDATE);

UPDATE telephone
SET telephone_type = CASE
		     WHEN telephone_type = 1008
		     THEN (SELECT common_lookup_id
			   FROM   common_lookup
			   WHERE  common_lookup_meaning = 'Home telephone')
		     ELSE (SELECT common_lookup_id
			   FROM   common_lookup
			   WHERE  common_lookup_meaning = 'Work telephone')
		     END;

SET NULL ''
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'COMMON_LOOKUP'
ORDER BY 2;

COLUMN common_lookup_table  FORMAT A20
COLUMN common_lookup_column FORMAT A20
COLUMN common_lookup_type   FORMAT A20
SELECT   common_lookup_table
,        common_lookup_column
,        common_lookup_type
FROM     common_lookup
ORDER BY 1, 2, 3;

COLUMN common_lookup_table  FORMAT A14 HEADING "Common|Lookup Table"
COLUMN common_lookup_column FORMAT A14 HEADING "Common|Lookup Column"
COLUMN common_lookup_type   FORMAT A8  HEADING "Common|Lookup|Type"
COLUMN count_dependent      FORMAT 999 HEADING "Count of|Foreign|Keys"
COLUMN count_lookup         FORMAT 999 HEADING "Count of|Primary|Keys"
SELECT   cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type
,        COUNT(a.address_id) AS count_dependent
,        COUNT(DISTINCT cl.common_lookup_table) AS count_lookup
FROM     address a RIGHT JOIN common_lookup cl
ON       a.address_type = cl.common_lookup_id
WHERE    cl.common_lookup_table = 'ADDRESS'
AND      cl.common_lookup_column = 'ADDRESS_TYPE'
AND      cl.common_lookup_type IN ('HOME','WORK')
GROUP BY cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type
UNION
SELECT   cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type
,        COUNT(t.telephone_id) AS count_dependent
,        COUNT(DISTINCT cl.common_lookup_table) AS count_lookup
FROM     telephone t RIGHT JOIN common_lookup cl
ON       t.telephone_type = cl.common_lookup_id
WHERE    cl.common_lookup_table = 'TELEPHONE'
AND      cl.common_lookup_column = 'TELEPHONE_TYPE'
AND      cl.common_lookup_type IN ('HOME','WORK')
GROUP BY cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type;

-- D --
ALTER TABLE common_lookup DROP COLUMN common_lookup_context;

ALTER TABLE common_lookup
MODIFY common_lookup_table NOT NULL
MODIFY common_lookup_column NOT NULL;

SET NULL ''
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'COMMON_LOOKUP'
ORDER BY 2;

CREATE UNIQUE INDEX common_lookup_u2 ON common_lookup(common_lookup_table, common_lookup_column, common_lookup_type);

COLUMN table_name FORMAT A14
COLUMN index_name FORMAT A20
SELECT   table_name
,        index_name
FROM     user_indexes
WHERE    table_name = 'COMMON_LOOKUP';

SPOOL OFF
