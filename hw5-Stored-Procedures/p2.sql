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
CREATE PROCEDURE P2.CUST_CRT@
(IN p_name VARCHAR(15), IN p_gender CHAR(1), IN p_age INTEGER, IN p_pin INTEGER, OUT id INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
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
END@

CREATE PROCEDURE P2.CUST_LOGIN@
  (IN input_id INTEGER, IN input_pin INTEGER, OUT valid INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
  LANGUAGE SQL
    BEGIN
      SET valid = (SELECT COUNT(p2.customer.id) FROM p2.customer WHERE p2.customer.id = input_id);
      IF valid == 0 THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid ID';
      ELSEIF valid == 1 AND input_pin != p2.decrypt(SELECT PIN FROM p2.customer WHERE p2.customer.id = input_id) THEN
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid PIN';
      ELSEIF valid == 1 AND input_pin == p2.decrypt(SELECT PIN FROM p2.customer WHERE p2.customer.id = input_id) THEN
        SET sql_code = 0;
        SET err_msg = 'Login Successful';
      ELSEIF input_id == 0 AND input_pin == 0 THEN
        SET valid = 1;
        SET sql_code 0;
        SET err_msg 'Admin Panel Active';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_OPEN@
  (IN input_id INTEGER, IN input_balance INTEGER, IN input_type CHAR(1), OUT accNum Integer, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
  LANGUAGE SQL
    BEGIN
    IF input_id IN (SELECT ID FROM p2.customer) THEN
      IF input_balance >= 0 THEN
        IF input_type = 'C' OR input_type = 'S' THEN
          SET accNum = (SELECT NUMBER FROM FINAL TABLE (INSERT INTO p2.account(ID, Balance, Type) VALUES (input_id, input_balance, input_type, 'A')));
          SET sql_code = 0;
          SET err_msg = 'Account Creation Successful';
        ELSE
          SET sql_code = -100;
          SET err_msg = 'Error: Invalid Account Type';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid Amount';
    ELSE
      SET accNum = NULL;
      SET sql_code = -100;
      SET err_msg = 'Error: ID not found in DB';
    END IF;
END@

CREATE PROCEDURE P2.ACCT_CLS@
  (IN input_accNum INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
  LANGUAGE SQL
    BEGIN
      IF input_accNum IN (SELECT Number FROM p2.account) THEN
        UPDATE p2.account SET p2.account.Status = 'I' WHERE p2.account.Number = input_accNum;
        SET sql_code = 0;
        SET err_msg = 'Account Closure Successful';
      ELSE IF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'I')
        SET sql_code = -100;
        SET err_msg = 'Error: Account already closed';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_DEP@
  (IN input_accNum INTEGER, IN input_amount INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
  LANGUAGE SQL
    BEGIN
      IF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'A') AND input_amount >= 0 THEN
        UPDATE p2.account SET p2.account.Balance = p2.account.Balance + input_amount WHERE p2.account.Number = input_accNum;
        SET sql_code = 0;
        SET err_msg = 'Deposit Successful';
      ELSE IF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'I')
        SET sql_code = -100;
        SET err_msg = 'Error: Account is inactive';
      ELSE IF input_amount < 0
        SET sql_code = -100;
        SET err_msg = 'Error: Invalid Deposit Amount';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_WTH@
  (IN input_accNum INTEGER, IN withdraw_amount INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
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
      ELSE IF input_accNum IN (SELECT Number FROM p2.account WHERE p2.account.Status = 'I')
        SET sql_code = -100;
        SET err_msg = 'Error: Account is inactive';
      ELSE IF withdraw_amount < 0
        SET sql_code -100;
        SET err_msg = 'Error: Invalid Withdrawal Amount';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Account Number was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ACCT_TRX@
  (IN src_accNum INTEGER, IN dest_accNum INTEGER, IN amount INTEGER, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
  LANGUAGE SQL
    BEGIN
      IF src_accNum IN (SELECT Number FROM p2.account) AND dest_accNum IN (SELECT Number FROM p2.account) THEN
        IF amount <= (SELECT Balance FROM p2.account WHERE p2.account.Number = src_accNum) THEN
          CALL p2.ACCT_WTH(src_accNum, amount, ?, ?);
          CALL p2.ACCT_DEP(dest_accNum, amount, ?, ?);
          SET sql_code = 0;
          SET err_msg = 'Transaction Successful';
        ELSE
          SET sql_code = -100;
          SET err_msg = 'Error: Insufficient Funds from Source Account';
      ELSE
        SET sql_code = -100;
        SET err_msg = 'Error: Source or Destination Account was not found in the database';
      END IF;
END@

CREATE PROCEDURE P2.ADD_INTEREST@
  (IN savings_rate FLOAT, IN checking_rate FLOAT, OUT sql_code INTEGER, OUT err_msg VARCHAR(100))
    UPDATE p2.account SET p2.account.Balance = p2.account.Balance + (p2.account.Balance * checking_rate) WHERE p2.account.Type = 'C';
    UPDATE p2.account SET p2.account.Balance = p2.account.Balance + (p2.account.Balance * savings_rate) WHERE p2.account.Type = 'S';
    SET sql_code = 0;
    SET err_msg = 'Interest Addition Successful';
END@
--
TERMINATE@