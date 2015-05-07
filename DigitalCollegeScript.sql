
CREATE DATABASE DigitalCollege
GO

USE DigitalCollege

CREATE TABLE Schools
(
  	schid		CHAR(4)		NOT NULL,
	school_name	VARCHAR(28)	NOT NULL,
	school_dean	TINYINT		NOT NULL,
	CONSTRAINT PK_schid PRIMARY KEY (schid)
)

CREATE TABLE Departments
(
  	schid		CHAR(4)		NOT NULL,
	deptid		TINYINT		NOT NULL,
	dept_name	VARCHAR(28)	NOT NULL,
	dept_chair	TINYINT		NOT NULL,
	CONSTRAINT FK_schid FOREIGN KEY (schid) REFERENCES Schools(schid),
	CONSTRAINT PK_schid_deptid PRIMARY KEY (schid, deptid)
)

CREATE TABLE Courses
(
  	schid		CHAR(4)		NOT NULL,
	deptid		TINYINT		NOT NULL,
	corid		TINYINT		NOT NULL,
	course_name	VARCHAR(37)	NOT NULL,
	CONSTRAINT FK_schid_deptid FOREIGN KEY (schid, deptid) REFERENCES Departments(schid, deptid),
	CONSTRAINT PK_schid_deptid_corid PRIMARY KEY (schid, deptid, corid)
)

CREATE TABLE Employees
(
  	eid			TINYINT		NOT NULL,
	ename		VARCHAR(20)	NOT NULL,
	etitle		CHAR(4)		NOT NULL,
	schid		CHAR(4)		NOT NULL REFERENCES Schools(schid),
	deptid		TINYINT		NOT NULL,
	CONSTRAINT FK_eschid_deptid FOREIGN KEY (schid, deptid) REFERENCES Departments(schid, deptid),
	CONSTRAINT PK_eid PRIMARY KEY (eid)
)

CREATE TABLE Classes
(
  	schid		CHAR(4)		NOT NULL,
	deptid		TINYINT		NOT NULL,
	corid		TINYINT		NOT NULL,
	cordays		CHAR(2)		NOT NULL,
	corhrs		VARCHAR(4)	NOT NULL,
	instr		TINYINT		NOT NULL,
	CONSTRAINT FK_instr FOREIGN KEY (instr) REFERENCES Employees(eid)
)

CREATE TABLE Students
(
  	stdid		TINYINT		NOT NULL,
	std_name	VARCHAR(20)	NOT NULL,
	std_advisor	TINYINT		NOT NULL REFERENCES Employees(eid),
	schid		CHAR(4)		NOT NULL,
	deptid		TINYINT		NOT NULL,
	CONSTRAINT FK_sschid_deptid FOREIGN KEY (schid, deptid) REFERENCES Departments(schid, deptid),
	CONSTRAINT PK_stdid PRIMARY KEY (stdid)
)

CREATE TABLE Register
(
  	stdid		TINYINT		NOT NULL REFERENCES Students(stdid),
  	schid		CHAR(4)		NOT NULL,
	deptid		TINYINT		NOT NULL,
	corid		TINYINT		NOT NULL
)

BULK INSERT Schools
FROM 'c:\Databases\Schools.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')

BULK INSERT Departments
FROM 'c:\Databases\Departments.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')

BULK INSERT Courses
FROM 'c:\Databases\Courses.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')

BULK INSERT Classes
FROM 'c:\Databases\Classes.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')

BULK INSERT Employees
FROM 'c:\Databases\Employees.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')

BULK INSERT Students
FROM 'c:\Databases\Students.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')

BULK INSERT Register
FROM 'c:\Databases\Register.txt'
WITH (FIELDTERMINATOR = '|',
	ROWTERMINATOR = '\n')


SELECT TOP 15 * FROM Schools
SELECT TOP 15 * FROM Departments
SELECT TOP 15 * FROM Courses
SELECT TOP 15 * FROM Classes
SELECT TOP 15 * FROM Employees
SELECT TOP 15 * FROM Students
SELECT TOP 15 * FROM Register

----------------------------------------------------

USE DigitalCollege
-- spPrintStudentSchedule
IF OBJECT_ID('spPrintStudentSchedule')IS NOT NULL
    DROP PROC spPrintStudentSchedule
GO

--Stored Procedure spPrintStudentSchedule
-----------------------------------
CREATE PROC  spPrintStudentSchedule @ID TINYINT
AS
DECLARE @College Table 
(
	row			INT IDENTITY,
	Student		VARCHAR(20),
	ClassID		CHAR(6),
	Days		CHAR(2),
	Hrs			VARCHAR(4),
	Course		VARCHAR(37),
	Instructor	VARCHAR(20),
	SID			TINYINT,
	School		VARCHAR(28),
	Adv			VARCHAR(20)
)

INSERT @College
SELECT std_name AS Student,
	CAST(Register.schid + '' + CONVERT(varchar, Register.deptid) + '' + CONVERT(varchar, Register.corid)
			AS CHAR(6)) AS ClassID,
		Classes.cordays AS Days, Classes.corhrs AS Hrs,
		course_name AS Course, ename AS Instructor, Students.stdid, Schools.school_name AS School,
		(SELECT ename FROM Employees WHERE eid=std_advisor) AS Adv
		
FROM Register JOIN Classes ON (Register.schid = Classes.schid AND Register.deptid = Classes.deptid AND
								Register.corid = Classes.corid)
			  JOIN Students ON Register.stdid = Students.stdid
			  JOIN Employees ON eid = instr
			  JOIN Courses ON (Register.schid = Courses.schid AND Register.deptid = Courses.deptid AND
								Register.corid = Courses.corid)
			  JOIN Schools ON Schools.schid = Students.schid
WHERE Students.stdid = @ID
ORDER BY Student, ClassID

DECLARE @Student	VARCHAR(20),
	@ClassID		CHAR(6),
	@Days			CHAR(2),
	@Hrs			VARCHAR(4),
	@Course			VARCHAR(37),
	@Instructor		VARCHAR(20),
	@School			VARCHAR(28),
	@Adv			VARCHAR(20)

DECLARE	@row INT,
	@numRows INT

--Assign Variables
SET @numRows = ( SELECT COUNT(*) FROM @College ) -- () required

--Process Records
SET @row = 1      --initialize control variable

        SELECT  @Student=Student, @ClassID=ClassID, @Days=Days, @Hrs=Hrs,
				@Course=Course, @Instructor=Instructor, @School=School, @Adv=Adv
        FROM    @College
        WHERE   row=@row
        
        PRINT ' '
        PRINT 'DIGITAL COMMUNITY COLLEGE'
        IF @numRows = 0
			PRINT 'NO STUDENT LISTED WITH THAT STUDENT ID.'
        PRINT 'School of ' + @School
        PRINT ' '

while @row <=  @numRows
    BEGIN   
        --fetch one record 
        SELECT  @Student=Student, @ClassID=ClassID, @Days=Days, @Hrs=Hrs,
				@Course=Course, @Instructor=Instructor, @School=School, @Adv=Adv
        FROM    @College
        WHERE   row=@row

		IF @row = 1
			PRINT ' '
		IF @row = 1
			PRINT CAST('Student' AS CHAR(20)) + ' ' + 
			CAST('ClassID' AS CHAR(7)) + ' ' + 
			CAST('Days' AS CHAR(4)) + ' ' + 
			CAST('Hrs' AS CHAR(4)) + ' ' + 
			CAST('Course' AS CHAR(37)) + ' ' + 
			CAST('Instructor' AS CHAR(20))
		IF @row = 1
			PRINT CAST('-------------------' AS CHAR(20)) + ' ' + 
			CAST('-------' AS CHAR(7)) + ' ' + 
			CAST('----' AS CHAR(4)) + ' ' + 
			CAST('----' AS CHAR(4)) + ' ' + 
			CAST('------------------------------------' AS CHAR(37)) + ' ' + 
			CAST('--------------------' AS CHAR(20))
		IF @row=1
			PRINT CAST(@Student AS CHAR(20)) + ' ' + 
			CAST(@ClassID AS CHAR(7)) + ' ' + 
			CAST(@Days AS CHAR(4)) + ' ' + 
			CAST(@Hrs AS CHAR(4)) + ' ' + 
			CAST(@Course AS CHAR(37)) + ' ' + 
			CAST(@Instructor AS CHAR(20))
		ELSE
			PRINT CAST(' ' AS CHAR(20)) + ' ' +
			CAST(@ClassID AS CHAR(7)) + ' ' + 
			CAST(@Days AS CHAR(4)) + ' ' + 
			CAST(@Hrs AS CHAR(4)) + ' ' + 
			CAST(@Course AS CHAR(37)) + ' ' + 
			CAST(@Instructor AS CHAR(20))		

    SET @row=@row+1   --update control variable
        
    END
    --end while loop

	PRINT ' '
	PRINT 'Advisor: ' + @Adv
	PRINT ' '
	PRINT ' '

GO

-------------------------------------------------

USE DigitalCollege
-- spPrintInsgtructorSchedule
IF OBJECT_ID('spPrintInsgtructorSchedule')IS NOT NULL
    DROP PROC spPrintInsgtructorSchedule
GO

--Stored Procedure spPrintInsgtructorSchedule
-----------------------------------
CREATE PROC  spPrintInsgtructorSchedule @IID TINYINT
AS
DECLARE @College Table 
(
	row			INT IDENTITY,
	Instructor	VARCHAR(20),
	ClassID		CHAR(6),
	Days		CHAR(2),
	Hrs			VARCHAR(4),
	Course		VARCHAR(37),
	eid			TINYINT,
	School		VARCHAR(28),
	Chair		VARCHAR(20),
	Dean		VARCHAR(20)
)

INSERT @College
SELECT ename AS Instructor,
	CAST(Classes.schid + '' + CONVERT(varchar, Classes.deptid) + '' + CONVERT(varchar, Classes.corid)
			AS CHAR(6)) AS ClassID,
		Classes.cordays AS Days, Classes.corhrs AS Hrs,
		course_name AS Course, eid, Schools.school_name AS School,
		(SELECT ename FROM Employees WHERE eid=dept_chair) AS Chair,
		(SELECT ename FROM Employees WHERE eid=school_dean) AS Dean
		
FROM Employees JOIN Classes ON eid = Classes.instr
			  JOIN Departments ON (Employees.schid = Departments.schid AND
					Employees.deptid = Departments.deptid)
				JOIN Courses ON (Classes.schid = Courses.schid AND
					Classes.deptid = Courses.deptid AND
					Classes.corid = Courses.corid)
				JOIN Schools ON Employees.schid = Schools.schid
WHERE eid = @IID
ORDER BY Instructor, ClassID

DECLARE @Instructor	VARCHAR(20),
	@ClassID		CHAR(6),
	@Days			CHAR(2),
	@Hrs			VARCHAR(4),
	@Course			VARCHAR(37),
	@Dean			VARCHAR(20),
	@School			VARCHAR(28),
	@Chair			VARCHAR(20)

DECLARE	@row INT,
	@numRows INT

--Assign Variables
SET @numRows = ( SELECT COUNT(*) FROM @College ) -- () required

--Process Records
SET @row = 1      --initialize control variable

        SELECT  @Instructor=Instructor, @ClassID=ClassID, @Days=Days, @Hrs=Hrs,
				@Course=Course, @Dean=Dean, @School=School, @Chair=Chair
        FROM    @College
        WHERE   row=@row
        
        PRINT ' '
        PRINT 'DIGITAL COMMUNITY COLLEGE'
        IF @numRows = 0
			PRINT 'NO INSTRUCTOR LISTED WITH THAT EMPLOYEE ID.'
        PRINT 'School of ' + @School
        PRINT ' '
        PRINT 'Dean: ' + @Dean

while @row <=  @numRows
    BEGIN   
        --fetch one record 
        SELECT  @Instructor=Instructor, @ClassID=ClassID, @Days=Days, @Hrs=Hrs,
				@Course=Course, @Dean=Dean, @School=School, @Chair=Chair
        FROM    @College
        WHERE   row=@row

		IF @row = 1
			PRINT ' '
		IF @row = 1
			PRINT CAST('Instructor' AS CHAR(20)) + ' ' + 
			CAST('ClassID' AS CHAR(7)) + ' ' + 
			CAST('Days' AS CHAR(4)) + ' ' + 
			CAST('Hrs' AS CHAR(4)) + ' ' + 
			CAST('Course' AS CHAR(37))
		IF @row = 1
			PRINT CAST('-------------------' AS CHAR(20)) + ' ' + 
			CAST('-------' AS CHAR(7)) + ' ' + 
			CAST('----' AS CHAR(4)) + ' ' + 
			CAST('----' AS CHAR(4)) + ' ' + 
			CAST('------------------------------------' AS CHAR(37))
		IF @row=1
			PRINT CAST(@Instructor AS CHAR(20)) + ' ' + 
			CAST(@ClassID AS CHAR(7)) + ' ' + 
			CAST(@Days AS CHAR(4)) + ' ' + 
			CAST(@Hrs AS CHAR(4)) + ' ' + 
			CAST(@Course AS CHAR(37))
		ELSE
			PRINT CAST(' ' AS CHAR(20)) + ' ' +
			CAST(@ClassID AS CHAR(7)) + ' ' + 
			CAST(@Days AS CHAR(4)) + ' ' + 
			CAST(@Hrs AS CHAR(4)) + ' ' + 
			CAST(@Course AS CHAR(37))

    SET @row=@row+1   --update control variable
        
    END
    --end while loop

	PRINT ' '
	PRINT 'Department Chair: ' + @Chair
	PRINT ' '
	PRINT ' '

GO

------------------------------------------------------

DECLARE	@ID	TINYINT,
		@IID TINYINT

	SET @ID=32
	EXEC spPrintStudentSchedule @ID
	
	SET @IID=14
	EXEC spPrintInsgtructorSchedule @IID

GO
