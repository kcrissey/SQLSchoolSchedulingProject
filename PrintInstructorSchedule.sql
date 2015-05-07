

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





DECLARE	@IID	TINYINT

	SET @IID=8
	EXEC spPrintInsgtructorSchedule @IID

GO



