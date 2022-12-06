-- Description: SQL File for Proj2.

-- Name: Diego Cruz
-- SID: 013540384

-- Course: CS 157A
-- Section: 02
-- Homework: HW3
-- Date: 05 December 2022

-- Useful db2 command to run this file:
-- db2 -tvf p2.sql

-- to run simple
-- db2 -t@";" -f p2.sql

-- to run play by play
-- db2 -vtd"@" -f p2.sql
    -- td"@" denotes that "@" character is considered equivalent to ";"
    -- for statements outside of triggers
    -- For normal files that use ";" delimiter, 
    -- use db2 -tvf file_name_here.sql
-- db2 -td"@" -f p2.sql
--
CONNECT TO CS157A@
--
--
DROP PROCEDURE P2.CUST_CRT@
DROP PROCEDURE P2.CUST_LOGIN@
DROP PROCEDURE P2.ACCT_OPN@
DROP PROCEDURE P2.ACCT_CLS@
DROP PROCEDURE P2.ACCT_DEP@
DROP PROCEDURE P2.ACCT_WTH@
DROP PROCEDURE P2.ACCT_TRX@
DROP PROCEDURE P2.ADD_INTEREST@
--
--
CREATE PROCEDURE P2.CUST_CRT
(IN p_name CHAR(15), IN p_gender CHAR(1), IN p_age INTEGER, IN p_pin INTEGER, OUT id INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
LANGUAGE SQL
  BEGIN
    IF p_gender != 'M' AND p_gender != 'F' THEN
      SET sql_code = -100;
      SET err_msg = 'Invalid gender';
    ELSEIF p_age <= 0 THEN
      SET sql_code = -100;
      SET err_msg = 'Invalid age';
    ELSEIF p_pin < 0 THEN
      SET sql_code = -100;
      SET err_msg = 'Invalid pin';
    ELSE
      SET err_msg = 'Account creation succeeded, here is the customer ID:';
      SET id = (SELECT ID FROM FINAL TABLE (INSERT INTO p2.customer(Name, Gender, Age, Pin) VALUES (p_name, p_gender, p_age, p2.encrypt(p_pin))));
      SET sql_code = 0;
    END IF;
END@

CREATE PROCEDURE P2.CUST_LOGIN@
  (IN input_id INTEGER, IN input_pin, OUT valid INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      SET valid = (SELECT COUNT(p2.customer.id) FROM p2.customer WHERE p2.customer.id = input_id);
      IF valid == 0 THEN
        SET sql_code = -100;
        SET err_msg = 'Error: ID was not found in the database';
      ELSEIF valid == 1 AND input_pin != p2.decrypt(SELECT PIN FROM p2.customer WHERE p2.customer.id = input_id) THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid PIN was entered';
      ELSEIF valid == 1 AND input_pin == p2.decrypt(SELECT PIN FROM p2.customer WHERE p2.customer.id = input_id) THEN
        SET sql_code = 0;
        SET err_msg = 'Success, you have now logged in';
      ELSEIF input_id == 0 AND input_pin == 0 THEN
        SET valid = 1;
        SET sql_code 0;
        SET err_msg 'You have now logged in as an Admin';
END@

CREATE PROCEDURE P2.ACCT_OPEN@
  (IN input_id INTEGER, IN input_balance INTEGER, IN input_type CHAR, OUT accNum Integer, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
    IF input_id IN (SELECT ID FROM p2.customer) THEN
      SET accNum = (SELECT NUMBER FROM FINAL TABLE (INSERT INTO p2.account(ID, Balance, Type) VALUES (input_id, input_balance, input_type, 'A')));
      SET sql_code = 0;
      SET err_msg = 'Success, you have now opened an account';
    ELSE
      SET accNum = NULL;
      SET sql_code = -100;
      SET err_msg = 'Error: ID was not found in the database';

END@

CREATE PROCEDURE P2.ACCT_CLS@
  (IN input_accNum INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      IF input_accNum IN (SELECT Number FROM p2.account) THEN
        UPDATE p2.account SET p2.account.Status = 'I' WHERE p2.account.Number = input_accNum;
        SET sql_code = 0;
        SET err_msg = 'Success, you have now closed the account';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
END@

CREATE PROCEDURE P2.ACCT_DEP@
  (IN input_accNum INTEGER, IN input_amount INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  
END@

CREATE PROCEDURE P2.ACCT_WTH@
  
END@

CREATE PROCEDURE P2.ACCT_TRX@
  
END@

CREATE PROCEDURE P2.ADD_INTEREST@
  
END@

--
TERMINATE@