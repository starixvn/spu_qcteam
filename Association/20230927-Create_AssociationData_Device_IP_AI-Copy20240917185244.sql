/*
	Created:	20230927@John.Ngo
	Task :		Only create association by Device/IP/AI on CTS (Skip details for IP, AI)
	DB:			CTS_DataCenter
*/

# SET @ip_UserNames = '8Q902P06,8Q902P06001,8Q902P06010'; # Agent - Member
# SET @ip_UserNames = 'DZAIVV05,DZAIVV05000,DZAIVV05002'; # Agent - Member
# SET @ip_UserNames = '8Q902P06,DZAIVV05'; # Agent
# SET @ip_UserNames = 'DZ520901002,DZ520901004' # Member;

SET @ip_UserNames = 'M28RMB06001,MBRM55568,M28RMB06027,12BETAUD02001,12BETAUD02002,12BETAUD02003';
    
/* Check UserName
SELECT * FROM CTS_DataCenter.CTSCustomer where  UserName like '8IN019%';
SELECT * FROM CTS_DataCenter.CTSCustomer where site = '722222' and RoleID = 1 order by CTSCustID desc;
SELECT * FROM CTS_DataCenter.AssociationTypeSetting;
*/
SET SQL_SAFE_UPDATES = 0;
-- Start
    DROP TEMPORARY TABLE IF EXISTS Temp_UserName;
	CREATE TEMPORARY TABLE Temp_UserName( 	 
			UserName				VARCHAR(50)
	      ,	PRIMARY KEY 			PK_Temp_UserName_UserName (UserName)
	);
	
    DROP TEMPORARY TABLE IF EXISTS Temp_ExistedCustomer;
	CREATE TEMPORARY TABLE Temp_ExistedCustomer(		
			UserName				VARCHAR(50)
        ,	CTSCustID 				BIGINT UNSIGNED
        ,	RoleID					SMALLINT
        ,	CustID					BIGINT UNSIGNED
        ,   CustSubID				SMALLINT
        ,	SiteID					INT
        ,	SubscriberID			INT UNSIGNED
        ,	IsLicensee				BIT /* 0: Credit,  1: Licensee */
        ,	IsInternal				BIT 
        ,	PRIMARY KEY				PK_Temp_ExistedCustomer_UserName(UserName)
        ,	INDEX					IX_Temp_ExistedCustomer_CTSCustID(CTSCustID)
	);
 
    /*1. Receive UserName List */
    SET @sql = 	CONCAT("INSERT IGNORE INTO Temp_UserName (UserName) VALUES ('", REPLACE(@ip_UserNames, ",", "'),('"),"');");
	PREPARE stmt1 FROM @sql;
	EXECUTE stmt1;    

	/*3. Get Existed Customers */
	INSERT IGNORE INTO Temp_ExistedCustomer(CTSCustID, CustID, CustSubID, UserName, RoleID, SiteID, SubscriberID, IsLicensee, IsInternal)
    SELECT 	c.CTSCustID
		,	c.CustID
        ,	c.CustSubID
		,	u.UserName
        , 	c.RoleID
        ,	c.SiteID
        ,	c.SubscriberID
		,	c.IsLicensee
		,	c.IsInternal
	FROM Temp_UserName AS u
		LEFT JOIN CTS_DataCenter.CTSCustomer AS c ON u.UserName = c.UserName;
        
SET @lv_DeviceID  = (SELECT MAX(DCSDeviceID) + 1 FROM CTS_DataCenter.AssociationByDevice); -- Insert max DeviceID
-- SET @lv_DeviceID = 20230909; --  Insert manual DeviceID

DROP TEMPORARY TABLE IF EXISTS Temp_AssociationByDevice;
CREATE TEMPORARY TABLE   Temp_AssociationByDevice (CTSCustID BIGINT UNSIGNED PRIMARY KEY, SubscriberID INT UNSIGNED); 

-- Get info customers
INSERT IGNORE INTO Temp_AssociationByDevice (CTSCustID, SubscriberID)
SELECT temp.CTSCustID, temp.SubscriberID
FROM Temp_ExistedCustomer AS temp;

SELECT temp.CustID FROM Temp_ExistedCustomer AS temp order by temp.CustID asc LIMIT 1 INTO @RootAcc;
SELECT temp.CustID FROM Temp_ExistedCustomer AS temp WHERE temp.CustID <> @RootAcc LIMIT 1 INTO @CustID2;
-- Clean Data
DELETE ass from CTS_DataCenter.AssociationByDevice AS ass 
INNER JOIN Temp_AssociationByDevice AS ta ON ass.CTSCustID = ta.CTSCustID;

-- Insert Ass by Device
INSERT INTO CTS_DataCenter.AssociationByDevice(CTSCustID,DCSDeviceID,SubscriberID,CreatedTime,InsertTime)
SELECT DISTINCT temp.CTSCustID,@lv_DeviceID,temp.SubscriberID,current_timestamp(),current_timestamp()
from Temp_AssociationByDevice AS temp;
## End - Create Ass by Device
-- Return Results
SELECT * FROM CTS_DataCenter.AssociationByDevice AS ass 
INNER JOIN Temp_AssociationByDevice AS temp on temp.CTSCustID = ass.CTSCustID and dcsdeviceid = @lv_DeviceID
order by ass.CTSAssDevID desc;

## Start - Create Ass by IP
-- Clean Data Ass by IP
DELETE ass FROM CTS_DataCenter.AssociationByIP AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCustID = tmpC.CustID OR ToCustID = tmpC.CustID;
DELETE ass FROM CTS_DataCenter.AssociationByIP AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCustID = tmpC.CustID OR ToCustID = tmpC.CustID;  
-- Insert Ass by IP
SELECT temp.CustID FROM Temp_ExistedCustomer AS temp order by temp.CustID asc LIMIT 1 INTO @RootAcc;
-- Set JSON
SELECT JSON_ARRAYAGG(JSON_OBJECT('C1', @RootAcc, 'C2', CustId))
INTO @CustListJson FROM Temp_ExistedCustomer AS temp WHERE temp.CustID <> @RootAcc; 
# SELECT @CustListJson;
CALL CTS_DataCenter.CTS_DC_Association_InsertAssociationByIP (@CustListJson, current_timestamp(),1 , @ErrorMessage);
# ip_CoupleIPStats / ip_ScanDate / ip_AssociationType (1 - IP, 2 - 5GIP)
## End - Create Ass by IP

## CALL CTS_DataCenter.CTS_DC_Association_InsertAssociationByIP ('[{"C1": 1411402, "C2": 1481207}]', current_timestamp(), @ErrorMessage);

/*
## Start - Create Ass by Manual
-- Clean Data Ass by Manual
DELETE ass FROM CTS_DataCenter.AssociationByManual AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCTSCustID = tmpC.CTSCustID OR ToCTSCustID = tmpC.CTSCustID;
-- Insert Ass by Manual
SELECT * FROM Temp_ExistedCustomer;
SELECT temp.SubscriberID, temp.CTSCustID FROM Temp_ExistedCustomer AS temp order by temp.CustID asc LIMIT 1 INTO @RootSubscriberID, @RootCTSCustID;
-- Set JSON
SELECT JSON_ARRAYAGG(JSON_OBJECT('FromSubscriberID', @RootSubscriberID,'FromCTSCustID', @RootCTSCustID, 'ToSubscriberID', SubscriberID, 'ToCTSCustID', CTSCustID,'Remark', '', 'CreatedBy', 8))
INTO @CustListJson FROM Temp_ExistedCustomer AS temp WHERE temp.CTSCustID <> @RootCTSCustID; 
# SELECT @CustListJson;
CALL CTS_DC_Association_InsertManualMultiple(@CustListJson);
## End - Create Ass by Manual
*/

## Start - Create Ass by AI
-- Clean Data Ass by AI
DELETE ass FROM CTS_DataCenter.AssociationByAI AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCustID = tmpC.CustID OR ToCustID = tmpC.CustID;
DELETE ass FROM CTS_DataCenter.AssociationByAI AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCustID = tmpC.CustID OR ToCustID = tmpC.CustID;  

-- Insert Ass by AI
# SELECT * FROM Temp_ExistedCustomer;
SELECT temp.CustID FROM Temp_ExistedCustomer AS temp order by temp.CustID asc LIMIT 1 INTO @RootAcc;
-- Set JSON
SELECT JSON_ARRAYAGG(JSON_OBJECT('C1', @RootAcc, 'C2', CustId))
INTO @CustListJson FROM Temp_ExistedCustomer AS temp WHERE temp.CustID <> @RootAcc; 
# SELECT @CustListJson;
CALL CTS_DataCenter.CTS_DC_Association_InsertAssociationByAI (@CustListJson, current_timestamp(),2 , @ErrorMessage);
## End - Create Ass by AI - ip_AssociationType: 1 - OTGB; 2 - 5G3S

/*
CALL CTS_DataCenter.CTS_DC_Association_InsertAssociationByAI ('[{"C1": 1411402, "C2": 1481207}]', current_timestamp(), 1, @ErrorMessage);   
CALL CTS_DataCenter.CTS_DC_Association_InsertManualMultiple ('[{"FromSubscriberID":6,"FromCTSCustID":1411402,"ToSubscriberID":6,"ToCTSCustID":1481207,"Remark":"TestM","CreatedBy":"8"}]')
SELECT * FROM CTS_DataCenter.AssociationByAI;
*/
