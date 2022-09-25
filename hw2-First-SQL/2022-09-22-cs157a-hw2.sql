/*
Description: SQL File for HW2.

Name: Diego Cruz
SID: 013540384

Course: CS157A
Homework: HW2
Date: 29 September 2022
*/

-- Find all the employees who has at least 10 years of experiences with the output order by the ones with the most experiences first. (Output column name: ID, Name, Years)
SELECT ID as ID, NAME as Name, YEARS as Years FROM STAFF WHERE YEARS >= 10 ORDER BY YEARS DESC;

-- Show all the commission employees (24 of them) and their total compensation (salary + comm.) in descending order based on their total compensation.  (Output columns: ID, Name, Total_Compensation)
SELECT ID as ID, NAME as Name, SALARY + COMM AS Total_Compensation FROM STAFF WHERE COMM > 0 ORDER BY Total_Compensation DESC;

-- Using SQL IS NOT NULL
SELECT ID as ID, NAME as Name, SALARY + COMM AS Total_Compensation FROM STAFF WHERE COMM IS NOT NULL ORDER BY Total_Compensation DESC;

-- Find the 5 lowest paid non-commissioned employees based on their salary in lowest order first.  (Output columns: ID, Name, Salary)
SELECT ID as ID, NAME AS Name, SALARY AS Salary FROM STAFF WHERE STAFF.COMM IS NULL ORDER BY SALARY ASC limit 0,5;

-- Find all the employees who worked in the department named Mountain, Plains, or New England in ascending order of the deptname and then name  (Output columns: Deptname, Location, Name). (Hint – JOIN)

-- Works for all department names
SELECT ORG.DEPTNAME as Deptname, ORG.LOCATION as Location, STAFF.NAME as Name FROM STAFF INNER JOIN ORG ON ORG.DEPTNUMB = STAFF.DEPT ORDER BY ORG.DEPTNAME, STAFF.NAME ASC;

-- Using SQL IN keyword
SELECT ORG.DEPTNAME as Deptname, ORG.LOCATION as Location, STAFF.NAME as Name FROM STAFF INNER JOIN ORG ON ORG.DEPTNUMB = STAFF.DEPT WHERE ORG.DEPTNAME IN ('Mountain','Plains','New England') ORDER BY ORG.DEPTNAME, STAFF.NAME ASC;

-- Using statements on JOIN
SELECT ORG.DEPTNAME as Deptname, ORG.LOCATION as Location, STAFF.NAME as Name FROM STAFF INNER JOIN ORG ON ORG.DEPTNUMB = STAFF.DEPT AND (ORG.DEPTNAME = 'Mountain' OR ORG.DEPTNAME = 'Plains' OR ORG.DEPTNAME = 'New England') ORDER BY ORG.DEPTNAME, STAFF.NAME ASC;

-- Using statements on WHERE
SELECT ORG.DEPTNAME as Deptname, ORG.LOCATION as Location, STAFF.NAME as Name FROM STAFF INNER JOIN ORG ON ORG.DEPTNUMB = STAFF.DEPT WHERE ORG.DEPTNAME = 'Mountain' OR ORG.DEPTNAME = 'Plains' OR ORG.DEPTNAME = 'New England' ORDER BY ORG.DEPTNAME, STAFF.NAME ASC;


-- There are many job roles among the 35 employees.  Find the number of people in each job role (at least 1) order by highest to lowest.  Your SQL statement must produce the output as the one shown below.  (Hint - GROUP BY)
SELECT JOB, COUNT(JOB) AS Employee_Count FROM STAFF GROUP BY JOB ORDER BY COUNT(JOB) DESC;

-- There are several divisions in the company.  Find the number of employees in each division (at least 1) order from lowest to highest.  Your SQL statement must produce the output as the one shown below.  (Hint – JOIN & GROUP BY)
SELECT DIVISION, COUNT(DIVISION) AS Employee_Count FROM STAFF JOIN ORG ON ORG.DEPTNUMB = STAFF.DEPT GROUP BY DIVISION ORDER BY COUNT(DIVISION) ASC;