-- run this with 
-- 		db2 -vtd";" -f <File Name
-- db2 -vtd"^" -f hw3/CREATE.sql
-- db2 -vtd"^" -f hw3/DROP.sql

delete from hw3.student;
delete from hw3.class;
delete from hw3.class_prereq;
delete from hw3.schedule;

ECHO ;
ECHO ******************************;
ECHO Cheking hw3.student;
ECHO Checking primary key duplicate check;
ECHO Checking first last name and gender;
ECHO ******************************;
ECHO ;

INSERT INTO hw3.student VALUES
	('123456', 'Tom', 'Doe', 'M');
INSERT INTO hw3.student VALUES
	('123456', 'Tom', 'Copy', 'M');
INSERT INTO hw3.student VALUES
	('1', NULL, 'nullguy', 'M');
INSERT INTO hw3.student VALUES
	('2', 'nullfam', NULL, 'M');
INSERT INTO hw3.student VALUES
	('3', 'a', 'alpha', 'F');
INSERT INTO hw3.student VALUES
	('4', 'b', 'alpha', 'O');

ECHO hw3.student;
SELECT * FROM hw3.student;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(1) only 3 entry in above table;
ECHO ******************************;
ECHO ;


INSERT INTO hw3.class values
	('010000','CS100W','Technical Writing'),
	('100000','CS46A','Intro to Programming'),
	('100001','CS46B','Intro to Data Struct'),
	('100002','CS47', 'Intro to Comp Sys');

INSERT INTO hw3.class values
	('010000','cpy','copy');
INSERT INTO hw3.class VALUES
	('1', NULL, 'Null class');
INSERT INTO hw3.class VALUES
	('2', 'NULL', Null);

ECHO hw3.class;
SELECT * FROM hw3.class;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(2) only 4 entry in above table;
ECHO ******************************;
ECHO ;

ECHO ;
ECHO ******************************;
ECHO Checking Foriegn key for class_prereq on class;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;

INSERT INTO hw3.class_prereq VALUES
	('100005', '010000', 'C');

INSERT INTO hw3.class_prereq VALUES
	('100000', '010005', 'C');

INSERT INTO hw3.class_prereq VALUES
	('100005', '010005', 'C');

INSERT INTO hw3.class_prereq VALUES
	('100000', '010000', 'C');

SELECT * FROM hw3.class_prereq;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(3) 3 failed commands, 1 succesfull command  and 1 entry in class_prereq;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;


-- THIS PART IS TRICKY. IT INVIVLES THE TRIGGER 
-- to check prerequsit. Reference notes in ATLA book -- for solution.
--INSERT INTO hw3.schedule VALUES	('000000', '100000', 1, 2019, 'A');

--INSERT INTO hw3.schedule VALUES	('123456', '100000', 1, 2019, 'A');

--INSERT INTO hw3.schedule values ('abc', 'DEF', 1, 2018, 'A');

--SELECT * FROM hw3.schedule;


INSERT INTO hw3.class_prereq VALUES
	('100001', '100000', 'C'),
	('100002', '010000', 'C');

ECHO ;
ECHO ******************************;
ECHO Checking Cascade for class_prereq on class;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;


DELETE FROM hw3.class WHERE class_id IN ('100000', '100001');

ECHO hw3.class;
SELECT * FROM hw3.class;
ECHO hw3.class_prereq;
SELECT * FROM hw3.class_prereq;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(4) delete succesfull and only 1 entry in hw3.class_prereq;
ECHO ******************************;
ECHO ;

ECHO ;
ECHO ******************************;
ECHO Checking not null for prereq grade;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;

DELETE FROM hw3.class_prereq;
INSERT INTO hw3.class_prereq VALUES
	('100000', '010000', NULL);
ECHO class_prereq;
SELECT * FROM hw3.class_prereq;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(5) 0 entry in hw3.class_prereq;
ECHO ******************************;
ECHO ;


ECHO ;
ECHO ******************************;
ECHO Checking Foriegn for schedule on student and class;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;

