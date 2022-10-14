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
	for statements outside of triggers
	Otherwise use db2 -tvf file_name_here.sql
*/

connect to cs157a^

--Creating student table
CREATE TABLE hw3.student (
       student_id char (6) 
	   PRIMARY KEY,
	   
       first varchar (15) 
	   ADD CONSTRAINT check_not_null
	   CHECK NOT NULL,
	   
       last varchar (15) 
	   ADD CONSTRAINT check_not_null
	   CHECK NOT NULL,
	   
       gender char (1) 
	   ADD CONSTRAINT must_be_specific_chars
	   CHECK (gender LIKE "[MFO]")
		/*
		"[MFO]" uses regular expressions to check that gender input
		matches 'M', 'F', or 'O'
		 */
)^

--Creating class table
CREATE TABLE hw3.class (
       class_id char (6) PRIMARY KEY,
	   
       name varchar (20) 
	   ADD CONSTRAINT check_not_null
	   CHECK NOT NULL,
	   
       desc varchar (20)
	   ADD CONSTRAINT check_not_null
	   CHECK NOT NULL
	   
)^

--Creating pre-req table
CREATE TABLE hw3.class_prereq (
       class_id char (6) 
	   REFERENCES hw3.class(class_id) 
	   ON DELETE CASCADE,
	   
       prereq_id char (6) 
	   REFERENCES hw3.class(class_id) 
	   ON DELETE CASCADE 
	   ADD CONSTRAINT check_not_listing_self_as_prereq 
	   CHECK (prereq_id <> class_id),
	   /* 
	   See about whether references properly checks if 
	   class_prereq.prereq_id is equal to itself
	   */
	   
		req_grade char (1) 
		ADD CONSTRAINT check_not_null
		CHECK NOT NULL
		ADD CONSTRAINT above_passing_grade 
		CHECK ( req_grade LIKE "[ABC]")
		/*
		"[ABC]" uses regular expressions to check that gender 
		input matches 'A', 'B', or 'C'
		*/
)^

--Creating schedule table
CREATE TABLE hw3.schedule (
       student_id char (6) 
	   REFERENCES hw3.student(student_id) 
	   ON DELETE CASCADE,
	   
       class_id char (6) 
	   REFERENCES hw3.class(class_id) 
	   ON DELETE CASCADE,
	   
       semester int 
	   ADD CONSTRAINT check_not_null
	   CHECK NOT NULL
	   ADD CONSTRAINT must_be_specific_int
	   CHECK (semester IN [1,2,3] ),
	   
       year int ADD CONSTRAINT must_be_positive_int
	   CHECK (year > 0 AND year <= DATEPART(year, GETDATE()) AS 'Year'),
	   /*
	   investigate how to force year input to be less than
	   current year on the machine.
	   */
	   
       grade char (1) ADD CONSTRAINT specific_grade_chars
	   CHECK (grade LIKE "[ABCDFIW]")
		/*
		"[ABCDFIW]" uses regular expressions to check that 
		grade input matches 'A', 'B', 'C', 'D', 'E', 'F', 'I'
		or 'W'
		*/
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