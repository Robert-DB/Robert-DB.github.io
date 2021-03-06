USE [DataBaseName]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--THIS QUERY FINDS PEOPLE WHO HAVE FAILED THE LAST 3 CONSECUTIVE ADMINISTRATIONS(DATES) OF A SPECIFIC EXAM NAME/TYPE
--IT IS A GAPS AND ISLANDS TYPE OF PROBLEM.  THIS IS FINDING ISLANDS OF 3 OR MORE FAILED CONSECUTIVE TEST ADMINS FOR A PERSON.

CREATE VIEW [dbo].[vListRegistrationConsecutiveFails]
AS
--THIS IS A NUMBERED LIST OF ADMINISTRATION DATES FOR SPECIFIC EXAM NAME/TYPES AND ORDERED BY MOST RECENT TO OLDEST ADMINISTRATION DATE.
WITH consecutiveexamadmins
AS (
	SELECT e.Name
		,e.Examtype
		,a.Administrationdate
		,Row_number() OVER (
			PARTITION BY e.NAME
			,e.Examtype ORDER BY a.Administrationdate DESC
			) AS rownum
	FROM registration.Administration a
	JOIN registration.Exam e ON e.Examid = a.Examid
	WHERE a.Administrationdate < Getdate()
	)

--THIS IS A DATASET OF FAILED EXAMS SPECIFIED BY PERSON, ADMINISTRATION DATE, EXAM TYPE, AND EXAM NAME.
	,diplomatefailedexams
AS (
	SELECT DISTINCT r.Memberid
		,u.Abimid
		,r.Examresult
		,e.Name
		,e.Examtype
		,a.Administrationdate
	FROM registration.Registration r
	JOIN registration.Administration a ON r.Administrationid = a.Administrationid
	JOIN registration.Exam e ON e.Examid = a.Examid
	JOIN identitydata.Userprofile u ON r.Memberid = u.Memberid
	WHERE r.Examresult = 'Fail'
	)
	,diplomatecertfails
AS (
	SELECT c1.Abimid
		,c1.NAME
		,c1.Examtype
		,c1.Examresult
		,c2.Rownum AS AdminRowNum
		,c1.Administrationdate
		--THE ROWNUMBER OF THE FAILED EXAMS ARE GENERATED AND THEY ARE SUBTRACTED FROM THE ROWNUMBER OF THE EXAM ADMIN
		--IF THESE ROWNUMBERS KEEP THE SAME DIFFERENCE FROM EACH OTHER, IT MEANS THAT THE FAILED EXAM COUNT IS INCREASING ALONG WITH
		--THE COUNT OF ALL ADMINS.  THIS UNCHANGING NUMBER, IS AN ISLAND OF CONSECUTIVE FAILS.
		,c2.Rownum - Row_number() OVER (
			PARTITION BY c1.Abimid
			,c1.NAME
			,c1.Examtype
			,c1.Examresult ORDER BY c2.Rownum
			) AS IslandGroupNum
	--ALL EXAM ADMINISTRATIONS ARE JOINED TO FAILED ADMINISTRATIONS FOR EACH PERSON.
	FROM diplomatefailedexams c1
	JOIN consecutiveexamadmins c2 ON c1.NAME = c2.NAME
		AND c1.Examtype = c2.Examtype
		AND c1.Administrationdate = c2.Administrationdate
		-- THIS LIMITS THIS TO THE MOST RECENT 3 EXAMS, BUT IT COULD BE CHANGED TO ANY NUMBER.
		AND c2.rownum <= 3
	)
--GROUP BY THE PERSON, EXAM, AND ISLAND, AND FILTER FOR ISLANDS WITH A COUNT OF 3 OR MORE.
SELECT Abimid
	,NAME
	,Examtype
	,COUNT(ExamResult) AS CountFails
FROM diplomatecertfails
GROUP BY Abimid
	,NAME
	,Examtype
	,IslandGroupNum
--3 OR MORE FAILURES IN A ROW.  COULD BE CHANGE TO ANY NUMBER.
HAVING COUNT(ExamResult) >= 3
GO
