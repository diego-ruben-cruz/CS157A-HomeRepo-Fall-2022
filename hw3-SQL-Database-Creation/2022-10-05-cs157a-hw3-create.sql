-- 	Description: SQL File for HW3. Meant for all CREATE statements.

-- 	Name: Diego Cruz
-- 	SID: 013540384
-- 	Course: CS 157A
-- 	Section: 02
-- 	Homework: HW3
-- 	Date: 05 October 2022

-- to run
-- db2 -td"^" -f hw3-create.sql 	
    -- td"^" denotes that "^" character is considered equivalent to ";"
    -- for statements outside of triggers
    -- For normal files that use ";" delimiter, 
    -- use db2 -tvf file_name_here.sql

connect to cs157a ^ 
-- Creating student table.
CREATE TABLE hw3.student (
    student_id varchar (6) NOT NULL PRIMARY KEY,
    firstname varchar (15) NOT NULL,
    lastname varchar (15) NOT NULL,
    gender char (1),  
    CONSTRAINT gender_spec_char CHECK (gender IN ('M','F','O'))
) ^

-- Creating class table.
CREATE TABLE hw3.class (
	class_id char (6) NOT NULL PRIMARY KEY,
	class_name varchar (20) NOT NULL,
	class_desc varchar (20) NOT NULL
) ^ 

-- Creating pre-req table.
CREATE TABLE hw3.class_prereq (
	class_id char (6) REFERENCES hw3.class(class_id) ON DELETE CASCADE,
	prereq_id char (6) REFERENCES hw3.class(class_id) ON DELETE CASCADE,
		-- See about whether references properly checks if 
		-- class_prereq.prereq_id is equal to itself
    req_grade char (1) NOT NULL,
        -- "[ABC]" uses regular expressions to check that gender 
        -- input matches 'A', 'B', or 'C'
    CONSTRAINT check_not_listing_self_as_prereq CHECK (prereq_id <> class_id),
    CONSTRAINT must_be_spec_char CHECK (req_grade IN('A','B','C'))
) ^

-- Creating Schedule table.
CREATE TABLE hw3.schedule (
	student_id char (6) REFERENCES hw3.student(student_id) ON DELETE CASCADE,
	class_id char (6) REFERENCES hw3.class(class_id) ON DELETE CASCADE,
	semester int NOT NULL,
	year int,
	grade char (1),

    CONSTRAINT must_be_specific_int CHECK (semester = 1 OR semester = 2 OR semester = 3),
    CONSTRAINT must_be_positive_int CHECK (year > 0),
    CONSTRAINT less_than_current_year CHECK (year <= 2023),
        -- investigate how to force year input to be less than
        -- current year on the machine.
        -- Hard-coded 2023 because I don't know how to get current year
        -- from db2 server or sql itself.
    CONSTRAINT specific_grade_chars CHECK (grade LIKE '[ABCDFIW]') 
            -- "[ABCDFIW]" uses regular expressions to check that 
            -- grade input matches 'A', 'B', 'C', 'D', 'E', 'F', 'I'
            -- or 'W'
) ^

-- Creating trigger to check prerequisites.
CREATE TRIGGER hw3.classcheck NO CASCADE BEFORE INSERT ON hw3.schedule 
    -- Trigger occurs on schedule table
    -- NO CASCADE BEFORE INSERT clarifies that the trigger will activate
    -- on attempted insertion into the database.
    -- The triggered action of the trigger will not cause other triggers to
    -- be activated.
	REFERENCING NEW AS newrow 
        -- References the new row to be inserted as newrow
	FOR EACH ROW MODE DB2SQL 
        -- Specifies that trigger action will be done once for each row of
        -- subject table that is affected by triggering SQL operation.
	WHEN (
		0 < (
			SELECT
				COUNT(*)
			FROM
				hw3.class_prereq
			WHERE
				hw3.class_prereq.class_id = newrow.class_id
		)
	) 
        -- When() specifies a search condition where if any row inserted
        -- contains a classID that has any prerequisites, it will do the trigger
        -- operations below.
	BEGIN ATOMIC 
        
    -- Declares new ints to temporarily use during trigger ops.
	DECLARE num_prereq int;
    DECLARE prereq_pass int;

    -- Updates num_prereq variable to count all prerequisites 
    SET
        num_prereq = (
            SELECT
                COUNT(*)
            FROM
                hw3.class_prereq
            WHERE
                hw3.class_prereq.class_id = newrow.class_id
        );

    -- Updates prereq_pass to count all prerequisites that are passed.
    SET
        prereq_pass = (
            SELECT *
            FROM hw3.class_prereq
            WHERE hw3.class_prereq.class_id = newrow.class_id
            JOIN hw3.schedule ON hw2.class_prereq.prereq_id = hw3.schedule.class_id
            WHERE hw3.schedule.grade <= hw3.class_prereq.req_grade AND hw3.schedule.student_id = newrow.student_id;
            
            -- SELECT
            --     COUNT(*)
            -- FROM
            --     hw3.schedule
            --     INNER JOIN hw3.class_prereq ON hw3.schedule.class_id = hw3.class_prereq.class_id
            -- WHERE
            --     hw3.class_prereq.class_id = newrow.class_id
            --     AND grade <= req_grade -- in ASCII A < F in value
            -- stuck on this line where I find bounds for
            -- satisfactory grade according to defined 
            -- passing grade in hw3.class_prereq
            -- attempting to use >= instead of regex.
        );

        IF (num_prereq < prereq_pass) THEN SIGNAL SQLSTATE '88888' ('Missing Pre-req');

    END IF;

END ^

terminate^