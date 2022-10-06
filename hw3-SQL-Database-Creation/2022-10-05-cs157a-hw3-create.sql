/*
	Description: SQL File for HW3. Meant for all CREATE statements.

	Name: Diego Cruz
	SID: 013540384

	Course: CS 157A
	Section: 02
	Homework: HW3
	Date: 05 October 2022
*/

-- Useful db2 command to run this file:
-- db2 -td"^" -f 2022-10-05-cs157a-hw3-create.sql
/* 
	-td"^" denotes that "^" character is considered equivalent to ";"
	for statements outside of triggers.
*/

connect to cs157a^

--Creating student table
CREATE TABLE hw3.student (
       student_id char (6),
       first varchar (15),
       last varchar (15),
       gender char (1)
)^

--Creating class table
CREATE TABLE hw3.class (
       class_id char (6),
       name varchar (20),
       desc varchar (20)
)^

--Creating pre-req table
CREATE TABLE hw3.class_prereq (
       class_id char (6),
       prereq_id char (6),
       req_grade char (1)
)^

--Creating schedule table
CREATE TABLE hw3.schedule (
       student_id char (6),
       class_id char (6),
       semester int,
       year int,
       grade char (1)
)^

--Creating trigger for pre-req
CREATE TRIGGER hw3.classcheck
NO CASCADE BEFORE INSERT ON hw3.schedule
REFERENCING NEW AS newrow  
FOR EACH ROW MODE DB2SQL
WHEN ( 0 < (SELECT COUNT(*)
              FROM hw3.class_prereq 
              WHERE hw3.class_prereq.class_id = newrow.class_id ) ) 
BEGIN ATOMIC
       DECLARE num_prereq int;
       DECLARE prereq_pass int;

       SET num_prereq = (SELECT COUNT(*)
                            FROM hw3.class_prereq 
                            WHERE hw3.class_prereq.class_id = newrow.class_id);

       IF ( num_prereq > 0 ) 
       THEN      SIGNAL SQLSTATE '88888' ( 'Missing Pre-req' );
       END IF;
END^