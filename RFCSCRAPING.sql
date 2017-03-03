--sp_configure 'show advanced options', 1 
--
--GO 
--RECONFIGURE; 
--GO 
--sp_configure 'Ole Automation Procedures', 1 
--GO 
--RECONFIGURE; 
--GO 
--sp_configure 'show advanced options', 1 
--GO 
--RECONFIGURE;



USE tempdb
GO

IF OBJECT_ID('tempdb..#xml') IS NOT NULL DROP TABLE #xml
CREATE TABLE #xml ( yourXML XML )
GO

DECLARE @URL VARCHAR(8000) 

--SELECT @URL = 'http://maps.google.com/maps/api/geocode/xml?latlng=10.247087,-65.598409&sensor=false'	-- This works
SELECT @URL ='http://home/saplink/PRD/default.asp?XDoc=<ZRFC_SEND_POSERIALDATA_ACS> <AUFNR>000100238115</AUFNR> </ZRFC_SEND_POSERIALDATA_ACS>'
--SELECT @URL = 'http://maps.google.com/maps/api/geocode/xml?latlng=10.247087,-67.598409&sensor=false'	-- This doesn't as string is too long
--SELECT @URL = 'http://maps.google.com/maps/api/geocode/xml?latlng=10.247087,-67.598409'

DECLARE @Response varchar(8000)
DECLARE @XML xml
DECLARE @Obj int 
DECLARE @Result int 
DECLARE @HTTPStatus int 
DECLARE @ErrorMsg varchar(MAX)

EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT 

EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false
EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
EXEC @Result = sp_OAMethod @Obj, send, NULL, ''
EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT 

INSERT #xml ( yourXML )
EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'--, @Response OUT 


--SELECT *
--FROM #xml -- ok

--SELECT x.*, y.c.query('.')
--FROM #xml x
--	CROSS APPLY x.yourXML.nodes('/GeocodeResponse/status') y(c)

--	SELECT x.*, y.c.query('.')
--FROM #xml x
--	CROSS APPLY x.yourXML.nodes('/ROOT/AUFNR') y(c)

--		SELECT x.*, y.c.query('.')
--FROM #xml x
--CROSS APPLY x.yourXML.nodes('/ROOT/ZSERIALNR_ACS/item') y(c)

--select T.N.query('.')
--from yourXML.nodes('/ROOT/ZSERIALNR_ACS') as T(N)
declare @newxml xml
		select   @newxml= y.c.query('.') 
	FROM #xml x
CROSS APPLY x.yourXML.nodes('/ROOT/ZSERIALNR_ACS') y(c)


--select  @newxml


DECLARE @handle INT  
DECLARE @PrepareXmlStatus INT  

EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @newxml--@XML  

SELECT  *
FROM    OPENXML(@handle, '/ZSERIALNR_ACS/item', 2)  
    WITH (
    AUFNR varchar(130),
    MATNR varchar(130),
    ATWRT varchar(130),
    PERIOD varchar(130),
    SERNR varchar(130),
    ZHPCTSERNR varchar(130)
    )  


EXEC sp_xml_removedocument @handle 