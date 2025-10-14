/*
	Created:	20230922@John.Ngo
	Task :		Delete all related Data in CTS -> Create new cc
	DB:			CTS_DataCenter
*/

SET @ip_UserNames = '12BETAUD02001,12BETAUD02002,12BETAUD02003,M28RMB06001,MBRM55568';
    
/* Check UserName
SELECT * FROM CTS_DataCenter.CTSCustomer where  UserName like 'ACGUUS38%';
SELECT * FROM CTS_DataCenter.CTSCustomer where site = '722222' and RoleID = 1
order by CTSCustID desc;
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
        ,	PRIMARY KEY				PK_Temp_ExistedCustomer_UserName(UserName)
        ,	INDEX					IX_Temp_ExistedCustomer_CTSCustID(CTSCustID)
        ,	INDEX					IX_Temp_ExistedCustomer_CustID(CustID)
	);
 
    /*1. Receive UserName List */
    SET @sql = 	CONCAT("INSERT IGNORE INTO Temp_UserName (UserName) VALUES ('", REPLACE(@ip_UserNames, ",", "'),('"),"');");
	PREPARE stmt1 FROM @sql;
	EXECUTE stmt1;    

	/*3. Get Existed Customers */
	INSERT IGNORE INTO Temp_ExistedCustomer(CTSCustID, CustID, CustSubID, UserName, RoleID, SiteID, SubscriberID)
    SELECT 	c.CTSCustID
		,	c.CustID
        ,	c.CustSubID
		,	u.UserName
        , 	c.RoleID
        ,	c.SiteID
        ,	c.SubscriberID
	FROM Temp_UserName AS u
		LEFT JOIN CTS_DataCenter.CTSCustomer AS c ON u.UserName = c.UserName;

## Classification
DELETE cls FROM CTS_DataCenter.CTSCustomerClassification AS cls
	INNER JOIN Temp_ExistedCustomer AS tmpC ON cls.CTSCustID = tmpC.CTSCustID;
DELETE ch FROM CTS_DataCenter.CTSCustomerClassification_History AS ch
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ch.CTSCustID = tmpC.CTSCustID;
DELETE clg FROM CTS_DataCenter.CTSCustomerClassification_Log AS clg
	INNER JOIN Temp_ExistedCustomer AS tmpC ON clg.CustID = tmpC.CustID;
DELETE lg FROM CTS_DataCenter.CTSCustomerClassification_InputDataLog AS lg
	INNER JOIN Temp_ExistedCustomer AS tmpC ON lg.CustID = tmpC.CustID;

## Classification By Sports
DELETE cls FROM CTS_DataCenter.CTSCustomerClassification_BySport AS cls
	INNER JOIN Temp_ExistedCustomer AS tmpC ON cls.CTSCustID = tmpC.CTSCustID;
DELETE ch FROM CTS_DataCenter.CTSCustomerClassification_BySport_History AS ch
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ch.CTSCustID = tmpC.CTSCustID;
DELETE clg FROM CTS_DataCenter.CTSCustomerClassification_BySport_Log AS clg
	INNER JOIN Temp_ExistedCustomer AS tmpC ON clg.CustID = tmpC.CustID;
DELETE pm FROM CTS_DataCenter.ProbationAccountMonitor_BySport pm
	INNER JOIN Temp_ExistedCustomer AS tmpC ON pm.CTSCustID = tmpC.CTSCustID;

## Others    
DELETE o FROM CTS_DataCenter.CTSCustomerClassificationOldPA AS o
	INNER JOIN Temp_ExistedCustomer AS tmpC ON o.CTSCustID = tmpC.CTSCustID;
DELETE vv FROM CTS_DataCenter.CTSCustomerClassificationVVIP vv
	INNER JOIN Temp_ExistedCustomer AS tmpC ON vv.CTSCustID = tmpC.CTSCustID;
DELETE q FROM CTS_DataCenter.CTSCustomerClassificationQueue q
	INNER JOIN Temp_ExistedCustomer AS tmpC ON q.CTSCustID = tmpC.CTSCustID;
DELETE p FROM CTS_DataCenter.PinCustomerCategory p
	INNER JOIN Temp_ExistedCustomer AS tmpC ON p.CTSCustID = tmpC.CTSCustID;
DELETE e FROM CTS_DataCenter.CustEvidence e 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON e.CTSCustID = tmpC.CTSCustID;
DELETE pm FROM CTS_DataCenter.ProbationAccountMonitor pm
	INNER JOIN Temp_ExistedCustomer AS tmpC ON pm.CTSCustID = tmpC.CTSCustID;
DELETE sc FROM CTS_DataCenter.SpecialCustomerClass sc
	INNER JOIN Temp_ExistedCustomer AS tmpC ON sc.CTSCustID = tmpC.CTSCustID;

## Robot
DELETE rc FROM CTS_DataCenter.RobotClassification AS rc
	INNER JOIN Temp_ExistedCustomer AS tmpC ON rc.CustID = tmpC.CustID;
DELETE rd FROM CTS_DataCenter.RobotDetection AS rd
	INNER JOIN Temp_ExistedCustomer AS tmpC ON rd.CustID = tmpC.CustID;
DELETE rd FROM CTS_DataCenter.RobotImperva AS rd
	INNER JOIN Temp_ExistedCustomer AS tmpC ON rd.CustID = tmpC.CustID;

## Association
DELETE ass FROM CTS_DataCenter.AssociationByDevice AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.CTSCustID = tmpC.CTSCustID;
DELETE ass FROM CTS_DataCenter.AssociationByManual AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCTSCustID = tmpC.CTSCustID OR ToCTSCustID = tmpC.CTSCustID;
DELETE ass FROM CTS_DataCenter.AssociationByIP AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCustID = tmpC.CustID OR ToCustID = tmpC.CustID;
DELETE ass FROM CTS_DataCenter.AssociationByAI AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.FromCustID = tmpC.CustID OR ToCustID = tmpC.CustID;
DELETE ass FROM CTS_DataCenter.AssociationGroupByAI AS ass 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON ass.CustID = tmpC.CustID;

UPDATE CTS_DataCenter.CTSCustomer AS c 
	INNER JOIN Temp_ExistedCustomer AS tmpC ON c.CustID = tmpC.CustID
SET c.Danger1 = 0, c.Danger2 = 0, c.Danger3 = 0, c.Danger4 = 0, c.Danger5 = 0;

-- Set New Category
SELECT * FROM Temp_ExistedCustomer;
SELECT JSON_ARRAYAGG(JSON_OBJECT('CustId', CustId, 'CategoryId', 201, 'TaggingID', 0, 'TaggingType', 1, 'ScanTaggingType', 1,'CreatedTime', now(), 'TurnoverRM', 1000, 'WinlossRM', 20, 'BetCount', 9, 'ActiveDays', 10, 'PerformanceTime', now()))
INTO @CustListJson FROM Temp_ExistedCustomer;

CALL CTS_DataCenter.CTS_DC_CustClassification_InsertNormalAccount(@CustListJson,@orr);

-- Set New Category by Sports
SELECT JSON_ARRAYAGG(JSON_OBJECT('CustId', CustId, 'CategoryId', 201, 'SportGroup', SportId, 'TurnoverRM', 1000, 'WinlossRM', 20, 'BetCount', 9, 'ActiveDays', 10, 'PerformanceTime', now()))
INTO @CustListJsonbySport FROM Temp_ExistedCustomer
JOIN (SELECT * FROM (
     SELECT 1 AS SportId union
	 SELECT 2 AS SportId union 
	 SELECT 43 AS SportId union # E-Sports
	 SELECT 99 AS SportId union # Other Sports
     SELECT 229 AS SportId union # Non-Sport
     SELECT 145 AS SportId union # Saba Soccer
     SELECT 912 AS SportId # Saba Basketball
     ) AS tbs) as bb;

CALL CTS_DataCenter.CTS_DC_CustClassification_BySport_InsertNormalAccount(@CustListJsonbySport,@or);

/*
# New linked PA (TaggingID = 10)
CALL CTS_DataCenter.CTS_DC_CustClassification_InsertNormalAccount_xtest('[
{"CustId": "1411402","CategoryId":"201","CreatedTime":"2023-09-21 00:00:00","TurnoverRM":"1000","WinlossRM":"20","BetCount":"9","ActiveDays":"10","TaggingID":1,"TaggingType":1,"PerformanceTime":"2023-09-21 00:00:00", "ScanTaggingType":1}]',@or);
*/

-- MainDB (TESTDBCUST)
-- Update danger... = 0 & CustomerClass = 201
/* 
UPDATE c WITH(ROWLOCK, UPDLOCK)
	SET c.CustomerClass = 201, c.CCSoccer = 201, c.CCBasketball = 201, c.CCEsports = 201, c.CCOtherSports = 201,
	c.danger = 0, c.danger2 = 0, c.danger3 = 0, c.danger4 = 0, c.danger5 = 0
FROM dbo.custInfo AS c
	WHERE c.custid in (1411402,1481207,1775698,121124,169695)

SELECT TOP (100) cm.site,c.CustomerClass, c.danger, c.danger2, c.danger3, c.danger4, c.danger5, c.DangerLevel&15 as SabaDangerSoccer, (c.DangerLevel&240)/16 as SabaDangerBasketball,
c.CCSoccer, c.CCBasketball, c.CCEsports, c.CCOtherSports FROM dbo.custInfo c WITH (NOLOCK)
INNER JOIN dbo.customer cm WITH (NOLOCK) ON c.custid = cm.custid
	WHERE c.custid in (1411402,1481207,1775698,121124,169695)

INSERT INTO [dbo].[CustomerClassSetting]([custid], [SportType], [CustomerClass], [ModifiedDate])
VALUES (1411402,145,201,GETDATE())
	,(1481207,145,201,GETDATE())
	,(1775698,145,201,GETDATE())
	,(121124,145,201,GETDATE())
	,(169695,145,201,GETDATE())
	,(1411402,912,201,GETDATE())
	,(1481207,912,201,GETDATE())
	,(1775698,912,201,GETDATE())
	,(121124,912,201,GETDATE())
	,(169695,912,201,GETDATE());

SELECT TOP (100) * FROM [CustDB].[dbo].[CustomerClassSetting] (NOLOCK)
	WHERE custid in (1411402,1481207,1775698,121124,169695);
*/