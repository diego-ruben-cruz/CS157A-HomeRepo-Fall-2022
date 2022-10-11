/*
	Description: SQL File for HW3. Meant to delete and drop all data and definitions.

	Name: Diego Cruz
	SID: 013540384

	Course: CS157A
	Section: 
	Homework: HW3
	Date: 05 October 2022
*/

-- Useful db2 command to run this file:
-- db2 -td"^" -f 2022-10-05-cs157a-hw3-drop.sql
/* 
	-td"^" denotes that "^" character is considered equivalent to ";"
	for statements outside of triggers
	Otherwise use db2 -tvf file_name_here.sql
*/

connect to cs157a^

DROP TRIGGER hw3.classcheck^
DROP TABLE hw3.schedule^
DROP TABLE hw3.class_prereq^
DROP TABLE hw3.class^
DROP TABLE hw3.student^

terminate^