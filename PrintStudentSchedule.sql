

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





DECLARE	@ID	TINYINT

	SET @ID=15
	EXEC spPrintStudentSchedule @ID

GO



