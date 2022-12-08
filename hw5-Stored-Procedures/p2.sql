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
-- db2 -td"@" -f p2.sql

-- to run play by play
-- db2 -vtd"@" -f p2.sql
    -- td"@" denotes that "@" character is considered equivalent to ";"
    -- for statements outside of triggers
    -- For normal files that use ";" delimiter, 
    -- use db2 -tvf file_name_here.sql
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
      SET err_msg = 'Error: Invalid gender';
    ELSEIF p_age <= 0 THEN
      SET sql_code = -100;
      SET err_msg = 'Error: Invalid age';
    ELSEIF p_pin < 0 THEN
      SET sql_code = -100;
      SET err_msg = 'Error: Invalid pin';
    ELSE
      SET err_msg = 'Account creation Successful';
      SET id = (SELECT ID FROM FINAL TABLE (INSERT INTO p2.customer(Name, Gender, Age, Pin) VALUES (p_name, p_gender, p_age, p2.encrypt(p_pin))));
      SET sql_code = 0;
    END IF;
END @

CREATE PROCEDURE P2.CUST_LOGIN
  (IN input_id INTEGER, IN input_pin INTEGER, OUT valid INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      DECLARE pin_extract INTEGER;
      SET valid = (SELECT COUNT(p2.customer.id) FROM p2.customer WHERE p2.customer.id = input_id);
      IF input_id = 0 AND input_pin = 0 THEN
        SET valid = 100;
        SET sql_code = 0;
        SET err_msg = 'Admin Panel Active';
      ELSEIF valid = 0 THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid ID';
      ELSEIF valid = 1 THEN
        SET pin_extract = p2.decrypt((SELECT p2.customer.Pin FROM p2.customer WHERE p2.customer.id = input_id));
        IF pin_extract != input_pin THEN
          SET sql_code = -100;
          SET err_msg = 'Error: Invalid PIN';
        ELSE
          SET sql_code = 0;
          SET err_msg = 'Login Successful';
        END IF;
      END IF;
END@

CREATE PROCEDURE P2.ACCT_OPN
  (IN input_id INTEGER, IN input_balance INTEGER, IN input_type CHAR(1), OUT accNum Integer, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
    IF input_id IN (SELECT ID FROM p2.customer) AND input_balance >= 0 THEN
      IF input_type = 'C' OR input_type = 'S' THEN
        SET accNum = (SELECT NUMBER FROM FINAL TABLE (INSERT INTO p2.account(ID, Balance, Type, Status) VALUES (input_id, input_balance, input_type, 'A')));
        SET sql_code = 0;
        SET err_msg = 'Account Creation Successful';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid Account Type';
      END IF;
    ELSEIF input_balance < 0 THEN
      SET sql_code = -100;
      SET err_msg = 'Error: Invalid Amount';
    ELSE
      SET accNum = NULL;
      SET sql_code = -100;
      SET err_msg = 'Error: ID not found in DB';
    END IF;
END@

CREATE PROCEDURE P2.ACCT_CLS
  (IN input_accNum INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      IF input_accNum IN (SELECT Number FROM p2.account) THEN
        UPDATE p2.account SET p2.account.Status = 'I' WHERE p2.account.Number = input_accNum;
        UPDATE p2.account SET p2.account.Balance = 0 WHERE p2.account.Number = input_accNum;
        SET sql_code = 0;
        SET err_msg = 'Account Closure Successful';
      ELSEIF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'I') THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Account already closed';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_DEP
  (IN input_accNum INTEGER, IN input_amount INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      IF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'A') AND input_amount >= 0 THEN
        UPDATE p2.account SET p2.account.Balance = p2.account.Balance + input_amount WHERE p2.account.Number = input_accNum;
        SET sql_code = 0;
        SET err_msg = 'Deposit Successful';
      ELSEIF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'I') THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Account is inactive';
      ELSEIF input_amount < 0 THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid Deposit Amount';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_WTH
  (IN input_accNum INTEGER, IN withdraw_amount INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      IF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'A') AND withdraw_amount >= 0 THEN
        IF withdraw_amount <= (SELECT Balance FROM p2.account WHERE p2.account.Number = input_accNum) THEN
          UPDATE p2.account SET p2.account.Balance = p2.account.Balance - withdraw_amount WHERE p2.account.Number = input_accNum;
          SET sql_code = 0;
          SET err_msg = 'Withdrawal Successful';
        ELSE
          SET sql_code = -100;
          SET err_msg = 'Error: Insufficient Funds';
        END IF;
      ELSEIF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'I') THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Account is inactive';
      ELSEIF withdraw_amount < 0 THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid Withdrawal Amount';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_TRX
  (IN src_accNum INTEGER, IN dest_accNum INTEGER, IN amount INTEGER, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      IF src_accNum IN (SELECT Number FROM p2.account) AND dest_accNum IN (SELECT Number FROM p2.account) THEN
        IF amount <= (SELECT Balance FROM p2.account WHERE p2.account.Number = src_accNum) THEN
          CALL p2.ACCT_WTH(src_accNum, amount, sql_code, err_msg);
          CALL p2.ACCT_DEP(dest_accNum, amount, sql_code, err_msg);
          SET sql_code = 0;
          SET err_msg = 'Transaction Successful';
        ELSE
          SET sql_code = -100;
          SET err_msg = 'Error: Insufficient Funds from Source Account';
        END IF;
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Source or Destination Account was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ADD_INTEREST
  (IN savings_rate FLOAT, IN checking_rate FLOAT, OUT sql_code INTEGER, OUT err_msg CHAR(100))
  LANGUAGE SQL
    BEGIN
      UPDATE p2.account SET Balance = ROUND((1 + checking_rate) * Balance) WHERE Type = 'C' AND Status = 'A';
      UPDATE p2.account SET Balance = ROUND((1 + savings_rate) * Balance) WHERE Type = 'S' AND Status = 'A';
      SET sql_code = 0;
      SET err_msg = 'Interest Addition Successful';
END@
--
TERMINATE@