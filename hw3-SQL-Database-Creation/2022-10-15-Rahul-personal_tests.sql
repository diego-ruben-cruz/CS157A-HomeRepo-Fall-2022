-- run this with 
-- 		db2 -vtd";" -f <File Name
-- db2 -vtd"^" -f hw3/CREATE.sql
-- db2 -vtd"^" -f hw3/DROP.sql
connect to cs157a;

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


delete from hw3.student;
delete from hw3.class;
delete from hw3.class_prereq;
delete from hw3.schedule;

INSERT INTO hw3.student VALUES
	('1', 'Tom', 'Riddle', 'M'),
	('2', 'Aang', 'Nomad', 'M'),
	('3', 'Double', 'Trouble', 'O'),
	('4', 'Toph', 'Beifong', 'F'),
	('5', 'Zuko', 'Iroh', 'M');

INSERT INTO hw3.class VALUES
	('1', 'AB101', 'Intro Airbending'),
	('2', 'AB103', 'Adva Airbending'),
	('3', 'WT101', 'Intro Waterbending'),
	('4', 'ER101', 'Intro Earthbending'),
	('5', 'FI101', 'Intro Firebending'),
	('6', 'AS101', 'Avatar State'),
	('7', 'MG101', 'Intro Magic'),
	('8', 'DG101', 'Intro Disguise'),
	('9', 'MG102', 'Adva Magic');

INSERT INTO hw3.class_prereq VALUES
	('2', '1', 'B'),
	('6', '2', 'C'),
	('6', '3', 'C'),
	('6', '4', 'C'),
	('6', '5', 'C'),
	('9', '7', 'C');

SELECT * FROM  hw3.student;
SELECT * FROM hw3.class;
SELECT * FROM hw3.class_prereq;

ECHO ;
ECHO ******************************;
ECHO Checking schedule Table;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;

ECHO Simple valid input tests;

ECHO;
ECHO Valid Grade;

ECHO hw3.schedule;
INSERT INTO hw3.schedule VALUES
	('1', '7', 1, 2019, 'A'),
	('2', '2', 1, 2019, 'B'),
	('2', '3', 1, 2019, 'C'),
	('2', '4', 1, 2019, 'D'),
	('2', '5', 1, 2019, 'F'),
	('3', '8', 1, 2019, 'I'),
	('4', '4', 1, 2019, 'W'),
	('5', '5', 1, 2019, NULL);

INSERT INTO hw3.schedule VALUES
	('1', '7', 1, 2019, 'E');

INSERT INTO hw3.schedule VALUES
	('1', '7', 1, 2019, 10);

SELECT * FROM hw3.schedule;


ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(6) 8 entry in hw3.schedule;
ECHO ******************************;
ECHO ;


ECHO ;
ECHO ******************************;
ECHO Checking schedule for valid student_id, class_id, semester;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;

INSERT INTO hw3.schedule VALUES
	('20', '7', 1, 2019, 'A');

INSERT INTO hw3.schedule VALUES
	('1', '15', 1, 2019, 'A');

INSERT INTO hw3.schedule VALUES
	('1', '4', 4, 2019, 'A');

SELECT * FROM hw3.schedule;
	
ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(7) still 8 entry in hw3.schedule;
ECHO ******************************;
ECHO ;

ECHO ;
ECHO ******************************;
ECHO Checking trigger part;
ECHO - - - - - - - - - - - - - - - ;
ECHO ;

DELETE from hw3.schedule;

INSERT INTO hw3.schedule VALUES
	('1', '7', 3, 2019, 'D'),
	('4', '4', 2, 2019, 'A'),
	('2', '1', 2, 2019, 'A'),
	('2', '5', 1, 2019, 'B');

ECHO Trying to insert without all the pre reqs;
INSERT INTO hw3.schedule VALUES
	('2', '6', 1, 2020, 'A');

ECHO Trying to insert with the pre req passed but wrong year;
INSERT INTO hw3.schedule VALUES
	('2', '2', 1, 2019, 'A');

ECHO Trying to insert with the pre req failed;
INSERT INTO hw3.schedule VALUES
	('1', '9', 1, 2020, NULL);


SELECT * FROM hw3.schedule;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(8) 4 entry in hw3.schedule;
ECHO ******************************;
ECHO ;


ECHO Trying to insert with all (1) pre req cleared;
INSERT INTO hw3.schedule VALUES
	('2', '2', 3, 2020, 'A');

SELECT * FROM hw3.schedule;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(9) 5 entry in hw3.schedule;
ECHO ******************************;
ECHO ;

INSERT INTO hw3.schedule VALUES
	('2', '3', 3, 2020, 'B'),
	('2', '4', 3, 2020, 'C'),
	('2', '5', 3, 2020, 'A');

ECHO Trying to insert with all (4) pre req cleared;
INSERT INTO hw3.schedule VALUES
	('2', '6', 3, 2021, 'A');

SELECT * FROM hw3.schedule;

ECHO ;
ECHO - - - - - - - - - - - - - - - ;
ECHO Check(10) 9 entry in hw3.schedule;
ECHO ******************************;
ECHO ;
terminate;