/*
	Description: SQL File for HW3. Meant to test triggers and constraints.
				with insertion and selection statements.

	Name: Diego Cruz
	SID: 013540384

	Course: CS 157A
	Section: 02
	Homework: HW3
	Date: 05 October 2022
*/

-- Useful db2 command to run this file:
-- db2 -td"^" -f 2022-10-05-cs157a-hw3.sql
/* 
	-td"^" denotes that "^" character is considered equivalent to ";"
	for statements outside of triggers.
*/

-- Data insertion operation.
connect to cs157a;
DELETE FROM hw3.student;
DELETE FROM hw3.class;
DELETE FROM hw3.class_prereq;
DELETE FROM hw3.schedule;

--Inserting data into the student table
INSERT INTO hw3.student VALUES
       ('900000','John','Doe','M'),
       ('900001','Jane','Doe','F'),
       ('900002','James','Bond','M'),
       ('900003','Chris','Newman','O'),
       ('900004','Ken','Tsang','M');

--Inserting data into the class table
INSERT INTO hw3.class VALUES
       ('010000','CS100W','Technical Writing'),
       ('100000','CS46A','Intro to Programming'),
       ('100001','CS46B','Intro to Data Struct'),
       ('100002','CS47', 'Intro to Comp Sys'),
       ('100003','CS49J','Programming in Java'),
       ('200000','CS146','Data Structure & Alg'),
       ('200001','CS157A','Intro to DBMS'),
       ('200002','CS149','Operating Systems'),
       ('200003','CS160','Software Engineering'),
       ('200004','CS157B','DBMS II'),
       ('200005','CS157C','NoSQL DB Systems'),
       ('200006','CS151','OO Design'),
       ('200007','CS155','Design & Anal of Alg'),
       ('300000','CS257','DB Mgmt Principles'),
       ('300001','CS255','Design & Anal of Alg');

--Inserting data into the classreq table
INSERT INTO hw3.class_prereq VALUES
       ('100001','100000','C'),
       ('100002','100001','C'),
       ('200000','100001','C'),
       ('200001','200000','C'),
       ('200002','200000','C'),
       ('200003','010000','C'),
       ('200003','200000','C'),
       ('200003','200006','C'),
       ('200004','200001','C'),
       ('200005','200001','C'),
       ('200006','100001','C'),
       ('200007','200000','B'),
       ('300000','200004','B'),
       ('300001','200007','B');
 
 -- Check table contents after the INSERTs
select * from hw3.student order by student_id;
select * from hw3.class order by class_id;
select * from hw3.class_prereq order by class_id;
select * from hw3.schedule order by student_id, class_id;

terminate;