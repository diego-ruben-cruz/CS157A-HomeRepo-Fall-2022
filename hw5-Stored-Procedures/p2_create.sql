-- Project 2 DDLs: create.clp
-- Useful db2 command to run this file:
-- db2 -tvf p2_create.sql

-- to run simple
-- db2 -td";" -f p2_create.sql

-- to run play by play
-- db2 -vtd";" -f p2_create.sql
    -- td"@" denotes that "@" character is considered equivalent to ";"
    -- for statements outside of triggers
    -- For normal files that use ";" delimiter, 
    -- use db2 -tvf file_name_here.sql
--
connect to cs157a;
--
-- drop previous definition first
drop specific function p2.encrypt;
drop specific function p2.decrypt;
drop table p2.account;
drop table p2.customer;
--
-- Without column constraint on Age & Pin, need logic in application to handle
--
create table p2.customer
(
  ID		integer generated always as identity (start with 100, increment by 1),
  Name		varchar(15) not null,
  Gender	char not null check (Gender in ('M','F')),
  Age		integer not null,
  Pin		integer not null check (Pin >= 0),
  primary key (ID)
);
--
-- Without column constraint on Balance, Type, Status, need logic in application to handle
--
create table p2.account
(
  Number	integer generated always as identity (start with 1000, increment by 1),
  ID		integer not null references p2.customer (ID),
  Balance	integer not null,
  Type		char not null,
  Status	char not null,
  primary key (Number)
);
--
-- p2.encrypt takes in an integer and output an "encrypted" integer
--
CREATE FUNCTION p2.encrypt ( pin integer )
  RETURNS integer
  SPECIFIC p2.encrypt
  LANGUAGE SQL
  DETERMINISTIC
  NO EXTERNAL ACTION
  READS SQL DATA
  RETURN
    CASE
      WHEN
        pin >= 0
      THEN
        pin * pin + 1000
      ELSE
        -1
    END;
-- 
-- p2.decrypt takes in an integer and output an "unencrypted" integer
--
CREATE FUNCTION p2.decrypt ( pin integer )
  RETURNS integer
  SPECIFIC p2.decrypt
  LANGUAGE SQL
  DETERMINISTIC
  NO EXTERNAL ACTION
  READS SQL DATA
  RETURN 
    CASE
      WHEN 
        pin >= 0
      THEN
        SQRT(pin - 1000)
      ELSE
        -1
    END;
--
commit;
terminate;