Textfile which contains special instructions and confessions for hw3.

Process is Container>Sample_Database

Initialize db2
db2start

Initialize Container
docker exec -ti mydb2 bash -c "su - db2inst1"

List databases
db2 list db directory
db2 list database directory

Create new database
db2 create db [insert_db_name_here]
db2 create database [insert_db_name_here]

Connect to database
db2 connect to [insert_db_name_here]

Connect to sample database
db2 connect to sample

Make sql query
db2 "[insert SQL Query here]"

End Session
db2 terminate

Useful sql to help find proper filtration for trigger.
```````````````
connect to cs157a;

INSERT INTO hw3.student VALUES
    ('2077', 'Morgan', 'Blackhand', 'M'),
    ('2023','Johnny','Silverhand','M'),
    ('2076','David','Martinez','M');

INSERT INTO hw3.class VALUES
    ('1','CW 76','Intro to Sandevistan'),
    ('2','CW 70','Intro to Cyberware'),
    ('3','MERC 10','Intro to The Solo');

INSERT INTO hw3.class_prereq VALUES
    ('3','1','C'),
    ('3','2','C'),
    ('1','2','C');

INSERT INTO hw3.schedule VALUES
    ('2023','2',2,2022,'C'),
    ('2023', '1',3,2023,'B'),
    ('2076','2',1,2019,'C'),
    ('2076','1',1,2020,'D'),
    ('2076','3',3,2020,'B');

SELECT *
FROM hw3.schedule INNER JOIN hw3.class_prereq ON hw3.schedule.class_id = hw3.class_prereq.prereq_id
WHERE hw3.class_prereq.class_id = schedule.class_id
                                    {newrow}
AND student_id = schedule.student_id
                {newrow}
AND grade <= req_grade
AND ( (year * 10) + semester) < ( (schedule.year * 10 ) + schedule.semester)
                                    {newrow}            {newrow}

terminate;
```````````````