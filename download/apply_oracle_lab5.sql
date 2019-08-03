/* 
** Enkey, William E
** CIT 225, McLaughlin
** 2018, WINTER
*/

-------------------------------------------------------------------------------------
-- Lab 05 as TA
-------------------------------------------------------------------------------------

-- Run the setup scripts out of the lib2 folder
@/home/student/Data/cit225/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit225/oracle/lib2/create/create_oracle_store2.sql
@/home/student/Data/cit225/oracle/lib2/preseed/preseed_oracle_store.sql
@/home/student/Data/cit225/oracle/lib2/seed/seeding.sql
@/home/student/Data/cit225/oracle/lib2/seeding_employee.sql
@/home/student/Data/cit225/oracle/lib2/seeding_calendar.sql
 
SPOOL apply_oracle_lab5.log
-------------------------------------------------------------------------------------
-- STEP 01
-------------------------------------------------------------------------------------
-- A
SELECT member_id, contact_id
FROM   member JOIN contact
USING  (member_id);

-- B
SELECT m.member_id, c.contact_id
FROM   member m, contact c
WHERE  m.member_id = c.member_id;

--C
SELECT contact_id, address_id
FROM   contact JOIN address
USING  (contact_id);

-- D
SELECT c.contact_id, a.address_id
FROM   contact c, address a
WHERE  c.contact_id = a.contact_id;

-- E
SELECT address_id, street_address_id
FROM   address JOIN street_address
USING  (address_id);

-- F
SELECT a.address_id, sa.street_address_id
FROM   address a,  street_address sa
WHERE  a.address_id = sa.address_id;

-- G
SELECT contact_id, telephone_id
FROM   contact JOIN telephone
USING  (contact_id);

-- H
SELECT c.contact_id, t.telephone_id
FROM   contact c, telephone t
WHERE  c.contact_id = t.contact_id;

-------------------------------------------------------------------------------------
-- STEP 02
-------------------------------------------------------------------------------------
-- A
SELECT c.contact_id, su.system_user_id AS system_user_pk
FROM   contact c INNER JOIN system_user su 
   ON  c.created_by = su.system_user_id;

-- B ***base the join on the created_by and system_user_id columns***

SELECT c.contact_id, su.system_user_id
FROM   contact c, system_user su
WHERE  c.created_by = su.system_user_id;

-- C
SELECT c.contact_id, su.system_user_id
FROM   contact c INNER JOIN system_user su
   ON  c.last_updated_by = su.system_user_id;

-- D
SELECT c.contact_id, su.system_user_id
FROM   contact c, system_user su
WHERE  c.last_updated_by = su.system_user_id;

-------------------------------------------------------------------------------------
-- STEP 03
-------------------------------------------------------------------------------------
-- A

SELECT su1.system_user_id, su1.created_by, su2.system_user_id AS system_user_pk
FROM   system_user su1 INNER JOIN system_user su2
   ON  su1.created_by = su2.system_user_id;

-- B

SELECT su1.system_user_id, su1.created_by, su2.system_user_id AS system_user_pk
FROM   system_user su1 INNER JOIN system_user su2
   ON  su1.last_updated_by = su2.system_user_id;

-- C

SELECT 	   su1.system_user_id
, 	   su1.system_user_name
,	   su2.system_user_name AS cby_user_
, 	   su2.system_user_id   AS CREATED_BY
, 	   su3.system_user_name AS UPDATED_USER
, 	   su3.last_updated_by  AS UPDATED_BY
FROM	   system_user su1 INNER JOIN system_user su2
   ON	   su2.system_user_id = su1.created_by INNER JOIN system_user su3
   ON	   su1.last_updated_by = su3.system_user_id;

-------------------------------------------------------------------------------------
-- STEP 04
-------------------------------------------------------------------------------------
SELECT 	   r.rental_id  AS RENTAL_ID
,          ri.rental_id AS RENTAL_ID_RI
,          ri.item_id   AS ITEM_ID_RI
,          i.item_id    AS ITEM_ID
FROM	   rental r INNER JOIN rental_item ri
   ON	   ri.rental_id = r.rental_id INNER JOIN item i
   ON	   i.item_id = ri.item_id;

ALTER TABLE rental DROP CONSTRAINT nn_rental_3;

-------------------------------------------------------------------------------------
-- STEP 05
-------------------------------------------------------------------------------------
-- VERIFICATION 01 --
SELECT   d.department_name
,        ROUND(AVG(s.salary),0) AS salary
FROM     employee e INNER JOIN department d
ON       e.department_id = d.department_id INNER JOIN salary s
ON       e.salary_id = s.salary_id
GROUP BY d.department_name
ORDER BY d.department_name;

-- VERIFICATION 02 --
/* Set output parameters. */
SET PAGESIZE 16

/* Format column output. */
COL short_month FORMAT A5 HEADING "Short|Month"
COL long_month  FORMAT A9 HEADING "Long|Month"
COL start_date  FORMAT A9 HEADING "Start|Date"
COL end_date    FORMAT A9 HEADING "End|Date" 

/* Query the results from the table. */
SELECT * FROM mock_calendar;

-- VERIFICATION 03 --
SELECT   d.department_name
,        ROUND(AVG(s.salary),0) AS salary
FROM     employee e INNER JOIN department d
ON       e.department_id = d.department_id INNER JOIN salary s
ON       e.salary_id = s.salary_id
WHERE    NVL(s.effective_end_date, SYSDATE) BETWEEN NVL(s.effective_end_date, SYSDATE - 60) AND NVL(s.effective_end_date, SYSDATE + 1)
GROUP BY d.department_name
ORDER BY d.department_name;

-------------------------------------------------------------------------------------
-- TEST CASE NVL(s.effective_end_date, TRUNC(SYSDATE + 1))
-------------------------------------------------------------------------------------

SPOOL OFF
