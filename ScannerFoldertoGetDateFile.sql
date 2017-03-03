DECLARE  @PathName       VARCHAR(256)='d:\'  , 
         @CMD            VARCHAR(512) 
 
IF OBJECT_ID('tempdb..#CommandShell') IS NOT NULL
    DROP TABLE #CommandShell

CREATE TABLE #CommandShell ( Line VARCHAR(512)) 
 
   SET @CMD = 'DIR ' + @PathName + ' /TC' --file +date
    --test
    --SET @PathName ='"F:\1. Documentation\2017 Decision ME\"'

   SET @PathName ='"\\vnmsrv300\Grpfiles\Document Control\Current Method sheet\QD24XX (Marco Polo)"'
    SET @CMD = 'DIR ' + @PathName + ' /s'  -- tìm tất cả các file

 
 
   PRINT @CMD -- test & debug
   -- DIR F:\data\download\microsoft /TC
 
   -- MSSQL insert exec - insert table from stored procedure execution
   INSERT INTO #CommandShell 
   EXEC MASTER..xp_cmdshell   @CMD 

   -- Delete lines not containing filename
   DELETE 
   FROM   #CommandShell 
   WHERE  Line NOT LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9] %' 
   OR Line LIKE '%<DIR>%'
   OR Line is null

SELECT 
    Line File_details 
   ,CAST(LEFT(Line,20) as DATETIME)AS file_date
   ,Rtrim(LTRIM(substring(Line,21,18))) as file_size
   ,Rtrim(LTRIM(substring(Line,39,Len(Line)))) as file_Names   
from #CommandShell 
  ORDER BY file_date DESC