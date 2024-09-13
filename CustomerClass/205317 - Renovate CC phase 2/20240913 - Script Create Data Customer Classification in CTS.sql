/*
	Created:	20240913@Randy.Nguyen
	Task :		Create script Create Data Customer Classification flows in CTS (CTS_DataCenter)
	DB:			<MySQL CTS_DataCenter (xx.xx.xxx.xx)>
	
	Revisions: 
			-	20240913@Randy.Nguyen:			Initial Writing [Redmine ID: #205317]
	Explaination:
		1. Test Normal flow
			1.1 Scan Tagging Daily
			1.2 Scan New inactive
			1.3 Realtime Scan
			1.4 Probation Scan
			1.5 Others
		2. Test Problem Account flow
			2.1 Category Robot User
			2.2 Category SDUL CC305/3005
            2.3 Others
		3. Test Potential PA flow
			3.1 CC2600 - Initial GB
            3.2 CC2700 - Initial Smart
            3.3 CC2800 - Early Warning Members
		4. Change CC Prio by Renovate Setting
			
*/

/*************************************** 1. Test Normal flow ***************************************/
/*************************************** 1.1 Scan Tagging Daily ***************************************/
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = 40604  WHERE (`ParameterID` = '144');

select ParameterID,ParameterName,ParameterValue  from SystemParameter where parameterID in (143,144,145); 

CALL CTS_DC_CustClassification_TaggingScan_Get_UAT4(@outParam0, @outParam1);

CALL CTS_DC_CustClassification_GetTaggingByAssociationWithPA_UAT3('148628950');

CALL CTS_DC_CustClassification_GetTaggingByAssociationWithPA_UAT4('148626490');

CALL CTS_DC_CustClassification_TaggingScan_CheckChanges_UAT4('[{"CustID":148626489,"TaggingID":7,"TaggingType":2}]');

/*************************************** 1.2 Scan New inactive ***************************************/
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` =40500  WHERE (`ParameterID` = '80');

select * from SystemParameter where parameterID in (79,80,81);

UPDATE `CTS_DataCenter`.`CTSCustomer` SET CreatedDate  = '2024-08-15 05:00:00' where CustID = 148628766;
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `LastModifiedDate` = '2024-07-15 05:00:00' WHERE (`CustID` in (148628766)) and (`ParentID` = '40000') ;
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `LastModifiedDate` = '2024-07-15 04:00:00' WHERE (`CustID` in (148628767)) and (`ParentID` = '40000') ;
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `LastModifiedDate` = '2024-07-15 03:00:00' WHERE (`CustID` in (148628768)) and (`ParentID` = '40000') ;
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `LastModifiedDate` = '2024-07-15 02:00:00' WHERE (`CustID` in (148628769)) and (`ParentID` = '40000') ;
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `CreatedDate` = '2024-07-15 00:00:00' WHERE (`CustID` in (148628766,148628767,148628768,148628769)) and (`ParentID` = '40000') ;
UPDATE `CTS_Archive`.`CTSCustomerAssociationStatus` SET `Created` = '2024-07-15 00:00:00' WHERE (`CustID` in (148628766,148628767,148628768,148628769));

select * from CTS_Archive.CTSCustomerAssociationStatus where Custid in (148628766,148628767,148628768,148628769);

CALL CTS_DC_CustClassification_DailyScan_GetInactiveNewMember_UAT4(@outParam0, @outParam1);

select DATE_SUB(now(), INTERVAL 14 DAY);

call CTS_DataCenter.CTS_DC_CustClassification_Normal_GetCurrentCategory_UAT4('148628766');

CALL CTS_DataCenter.CTS_DC_CustClassification_GetCCAndDangerLevel_UAT4('148626489');

/*************************************** 1.3 Realtime Scan ***************************************/
CALL CTS_DC_CustClassification_Realtime_GetCategory_UAT4('148626489');

CALL CTS_DC_CustClassification_Insert_VIC(9, 0, 0, 0, false, false, '[{"CreatedTime":"2024-07-12T04:47:13.553","TaggingID":8,"TaggingType":1,"TWBetCount":0,"TWGroupBettingRate":0.0,"TWTicketRejectRate":0.0,"TWDesktopUsageRate":0.0,"ScanTaggingType":2,"CustID":1277,"CategoryID":40600,"CategoryGroupID":40600,"TurnoverRM":0.0,"WinlossRM":0.0,"BetCount":0,"ActiveDays":0,"PerformanceTime":"2024-07-12T04:47:13.553"},{"CreatedTime":"2024-07-12T04:47:13.553","TaggingID":13,"TaggingType":1,"TWBetCount":0,"TWGroupBettingRate":0.0,"TWTicketRejectRate":0.0,"TWDesktopUsageRate":0.0,"ScanTaggingType":2,"CustID":1027611,"CategoryID":40600,"CategoryGroupID":40600,"TurnoverRM":6074069.9976,"WinlossRM":102738.0024,"BetCount":132,"ActiveDays":11,"PerformanceTime":"2024-07-12T04:47:13.67"},{"CreatedTime":"2024-07-12T04:47:13.553","TaggingID":8,"TaggingType":1,"TWBetCount":0,"TWGroupBettingRate":0.0,"TWTicketRejectRate":0.0,"TWDesktopUsageRate":0.0,"ScanTaggingType":2,"CustID":1031372,"CategoryID":40600,"CategoryGroupID":40600,"TurnoverRM":6074069.9976,"WinlossRM":102738.0024,"BetCount":132,"ActiveDays":11,"PerformanceTime":"2024-07-12T04:47:13.67"},{"CreatedTime":"2024-07-12T04:47:13.553","TaggingID":10,"TaggingType":1,"TWBetCount":0,"TWGroupBettingRate":0.0,"TWTicketRejectRate":0.0,"TWDesktopUsageRate":0.0,"ScanTaggingType":2,"CustID":1031376,"CategoryID":40600,"CategoryGroupID":40600,"TurnoverRM":6074069.9976,"WinlossRM":102738.0024,"BetCount":132,"ActiveDays":11,"PerformanceTime":"2024-07-12T04:47:13.67"},{"CreatedTime":"2024-07-12T04:47:13.553","TaggingID":7,"TaggingType":2,"TWBetCount":20,"TWGroupBettingRate":45.0000,"TWTicketRejectRate":0.0,"TWDesktopUsageRate":0.0,"ScanTaggingType":2,"CustID":1032813,"CategoryID":40600,"CategoryGroupID":40600,"TurnoverRM":6074069.9976,"WinlossRM":102738.0024,"BetCount":132,"ActiveDays":11,"PerformanceTime":"2024-07-12T04:47:13.67"},{"CreatedTime":"2024-07-12T04:47:13.553","TaggingID":8,"TaggingType":2,"TWBetCount":0,"TWGroupBettingRate":0.0,"TWTicketRejectRate":350.0000,"TWDesktopUsageRate":950.0000,"ScanTaggingType":2,"CustID":1033999,"CategoryID":40600,"CategoryGroupID":40600,"TurnoverRM":6074069.9976,"WinlossRM":102738.0024,"BetCount":132,"ActiveDays":11,"PerformanceTime":"2024-07-12T04:47:13.67"}]', @outParam7);

select * from Temp_NewClassification;

select CTS_DC_CategoryTypeParent_Get_UAT4 ('CONST_CC_LICVIPSUSPICIOUS');

UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `CreatedDate` = '2024-06-15 00:00:00' WHERE (`CustID` = '117811711') and (`ParentID` = '40000') ;
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `CreatedDate` = '2024-06-15 00:00:00' WHERE (`CustID` = '117817224') and (`ParentID` = '40000');
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` SET `CreatedDate` = '2024-06-15 00:00:00' WHERE (`CustID` = '117835739') and (`ParentID` = '40000') ;
UPDATE `CTS_Archive`.`CTSCustomerAssociationStatus` SET `Created` = '2024-06-15 00:00:00' WHERE (`CTSCustID` = '1000930421');
UPDATE `CTS_Archive`.`CTSCustomerAssociationStatus` SET `Created` = '2024-06-15 00:00:00' WHERE (`CTSCustID` = '1000930423');
UPDATE `CTS_Archive`.`CTSCustomerAssociationStatus` SET `Created` = '2024-06-15 00:00:00' WHERE (`CTSCustID` = '1000930424');

select * from CTS_Archive.CTSCustomerAssociationStatus where Custid in (117797608,117817224,117835739);

CALL CTS_DC_CustClassification_ReScan_Get_UAT4('117817224');

/*************************************** 1.4 Probation Scan ***************************************/
select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (165,166,167);

UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = '40400' WHERE (`ParameterID` = '166');
UPDATE `CTS_DataCenter`.`CTSCustomerClassification` 
SET `CreatedDate` = DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY),`LastModifiedDate` = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY),
 `LastScannedDate` = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
WHERE `CustID` in (148626498) and (`ParentID` = '40000');

CALL CTS_DC_CustClassification_ProbationScan_Get_UAT4(500, @outParam1, @outParam2);

/*************************************** 1.5 Others ***************************************/
/*************************************** 1.5.a Function web: Ass group monitor ***************************************/
select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (97,98,99);

select * from AssociatedGroup;

CALL CTS_DC_AssociatedGroup_Scan(@outParam0, @outParam1, @outParam2, @outParam3, @outParam4, @outParam5);


select * from Temp_Cust;

select * from Temp_CustDetected;

-- LastTicketDate >= Detect date of association
UPDATE `CTS_Archive`.`CTSCustomerAssociationStatus` SET `LastTicketDate` = '2024-08-09 06:49:10' WHERE (`CTSCustID` = '1001062411');

select * from CTS_Archive.CTSCustomerAssociationStatus where CTSCustID = 1001062411;

-- trigger service: CTS_CC.CTS_CustomerClassification_Secondly_AssociationAccountScan

/*************************************** 1.5.b Function web: LastTicketDate ***************************************/
-- Insert New cust
SELECT @LastScannedTVS := DATE_ADD(NOW(), INTERVAL -2 Minute);

UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` =  @LastScannedTVS WHERE (`ParameterID` = '2');

select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (2);
 
-- LastTicketDate:
UPDATE `CTS_Archive`.`CTSCustomerAssociationStatus` SET `LastTicketDate` = NULL WHERE (`CTSCustID` = '1001062307');

select * from CTS_Archive.CTSCustomerAssociationStatus where CTSCustID = 1001062307;

###########################################################################################################################################################################
/*************************************** 2. Test Problem Account flow ***************************************/
/*************************************** 2.1 Category Robot User ***************************************/
-- Parameter of AI - Imperva robot
DELETE from `CTS_DataCenter`.`RobotDetection` where ID > 3675;

UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = 3682 WHERE (`ParameterID` = '94');

/*
INSERT INTO `CTS_DataCenter`.`RobotDetection` (`CustID`, `PeriodRangeType`, `CreatedDate`, `LastModifiedDate`, `IsDisabled`) VALUES
 ('117797608', '200', now(), now(), b'0')
 ,('117811711', '1', now(), now(), b'0')
 ,('117817224', '3', now(), now(), b'0')
 ,('117835739', '5', now(), now(), b'0')
 ,('119272457', '10', now(), now(), b'1')
 ,('117797608', '20', now(), now(), b'0')
 ;
 
 INSERT INTO `CTS_DataCenter`.`RobotDetection` (`CustID`, `PeriodRangeType`, `CreatedDate`, `LastModifiedDate`, `IsDisabled`) VALUES

('148626504', '200', now(), now(), b'0'); 
 */
INSERT INTO `CTS_DataCenter`.`RobotDetection` (`CustID`, `PeriodRangeType`, `CreatedDate`, `LastModifiedDate`, `IsDisabled`) VALUES
('9020527', '1', now(), now(), b'0'),
('9020527', '200', now(), now(), b'0'); -- Losing
 
 
select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (94,133,134,140);

select * from RobotDetection order by ID desc;

select c.UserName,r.* from RobotDetection as r inner join CTSCustomer as c on c.CustID = r.CustID order by r.ID desc;

select * from CTSCustomer where custid  in (9700000,9700001,9700002,9700003);

DELETE from `CTS_DataCenter`.`RobotDetection` where custid in (9700000,9700001,9700002,9700003);

call CTS_DataCenter.CTS_DC_RobotDetection_Insert_UAT4 (
'[{"C": 9700000, "R": 1}, 
{"C": 9700001, "R": 2}, 
{"C": 9700002, "R": 200},
{"C": 9700003, "R": 20}]','2024-09-06 15:59:13.000', @ErrorMessage);

call CTS_DataCenter.CTS_DC_RobotDetection_Insert (
'[ 
{"C": 9020527, "R": 200}]','2024-09-06 15:59:13.000', @ErrorMessage);

call CTS_DataCenter.CTS_DC_RobotDetection_Insert_UAT4 (
'[{"C": 9020527, "R": 4}]' 
,'2024-09-06 15:59:13.000', @ErrorMessage);

select * from RobotDetection where custid in (9700000,9700001,9700002,9700003) order by ID desc;

/*
CALL CTS_DC_ProblemAccountManagement_GetCategories_UAT4(false);
CALL CTS_DC_CustClassification_Get_UAT4(1000828965);


CALL CTS_DC_RobotDetection_GetLatest_UAT4(34);
*/
 select * from RobotImperva  where custid in (9700000,9700001,9700002,9700003) order by LogID desc;
 
-- CTS Robot 
select * from CTSRobotUser order by CreatedDate desc;

-- TW Robot 
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = '698015' WHERE (`ParameterID` = '3');

select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (3);

 select * from TWRobotUser order by CreatedDate desc;

DECLARE @ip_CustID INT = 117811711; -- 100030201,100030238
 UPDATE  [ON_USER].[dbo].[RobotUsers] SET LastChangeTime = getdate()
 where custid = @ip_CustID  ; -- RowVersionAsBigInt = 650001

  SELECT CAST(CONVERT(BIGINT, TSTAMP) AS INT) AS "TSTAMP_INT" ,*  FROM [ON_USER].[dbo].[RobotUsers] order by tstamp desc ;
 
 --INSERT INTO [ON_USER].[dbo].[RobotUsers] (custid, IP, LastChangeTime, site, counter, serverip, RobotDate, remark, Creator, countryLONG, ipREGION) VALUES 
 --(100030201, 'N/A', getdate(), 'DEWA', 11, NULL, getdate(), NULL, 8, NULL, NULL)
 --,(100030238, 'N/A', getdate(), 'MYGAME', 11, NULL, getdate(), NULL, 8, NULL, NULL)
 --;
 
/*************************************** 2.2 Category SDUL CC305/3005 ***************************************/
-- CC305/3005 CTS
-- select * from CTSCustomer where CTScustID in (1000930436,1000930437,1000930443,1000930444);
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = DATE_SUB(curdate(), INTERVAL 1 DAY) WHERE (`ParameterID` = '149');
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = DATE_SUB(curdate(), INTERVAL 1 DAY) WHERE (`ParameterID` = '150');

 
delete from CustomerLoginInfoDetection where CTScustID in (1000930436,1000930437,1000930443,1000930444);
delete from CTS_DataCenter.CustDCSAccount where AccountID in (1000834179,1000834180,1000834189,1000834190,1000834191,1000834192);
delete from `DCS_DataTrace`.`LoginTransactionSummary` where  AccountID in (1000834179,1000834180,1000834189,1000834190,1000834191,1000834192);

-- select * from DCS_DataCenter.StaticList;
-- select DATE_SUB(NOW(), INTERVAL 1 DAY);

Insert into CTS_DataCenter.CustDCSAccount (CTSCustID, AccountID, SubscriberID,InsertTime) values
(1000930436,1000834189,130,DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1000930437,1000834190,130,DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1000930443,1000834191,5733203,DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1000930444,1000834192,2313,DATE_SUB(NOW(), INTERVAL 1 DAY))
;

INSERT INTO `DCS_DataTrace`.`LoginTransactionSummary` (`TransDate`, `SubscriberID`, `AccountID`, `DeviceID`, `Flagged`, `TotalTrans`, `FirstLoginTransTime`, `LastLoginTransTime`, `CreatedTime`, `ModifiedTime`, `FlaggedGroupID`)  VALUES
		(DATE_SUB(NOW(), INTERVAL 1 DAY), 5733203,1000834191, 125, 8, 5001, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 2)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 5733203,1000834191, 125, 9, 4999, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 3)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 2313,1000834192, 125, 8, 4999, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 2)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 2313,1000834192, 125, 9, 5001, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 3)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 130  ,1000834190, 125, 8, 5001, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 2)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 130  ,1000834190, 125, 9, 4999, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 3)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 130,1000834189, 125, 8, 4999, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 2)
 ,		(DATE_SUB(NOW(), INTERVAL 1 DAY), 130,1000834189, 125, 9, 5001, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY),DATE_SUB(NOW(), INTERVAL 1 DAY) ,DATE_SUB(NOW(), INTERVAL 1 DAY), 3)
 ;

select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (147,148,149,150);
SELECT * FROM DCS_DataTrace.LoginTransactionSummary where  AccountID in (1000834189,1000834190,1000834191,1000834192);  -- groupid = 2 --> InvalidBrowser, 3 --> bottrans
SELECT * FROM CTS_DataCenter.CustDCSAccount where CTSCustid in (1000930436,1000930437,1000930443,1000930444);
select * from CustomerLoginInfoDetection where CTScustID in (1000930436,1000930437,1000930443,1000930444);

-- Test
Insert into CTS_DataCenter.CustDCSAccount (CTSCustID, AccountID, SubscriberID,InsertTime) values
(1001062273,1001062273,6,DATE_SUB(NOW(), INTERVAL 1 DAY));

INSERT INTO `DCS_DataTrace`.`LoginTransactionSummary` (`TransDate`, `SubscriberID`, `AccountID`, `DeviceID`, `Flagged`, `TotalTrans`, `FirstLoginTransTime`, `LastLoginTransTime`, `CreatedTime`, `ModifiedTime`, `FlaggedGroupID`)  VALUES
(DATE_SUB(NOW(), INTERVAL 2 DAY), 6,1001062273, 125, 8, 1000, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY),DATE_SUB(NOW(), INTERVAL 2 DAY) ,DATE_SUB(NOW(), INTERVAL 2 DAY), 2)
 ;
 
SELECT * 
FROM DCS_DataTrace.LoginTransactionSummary AS d
INNER JOIN CTS_DataCenter.CustDCSAccount AS c ON d.AccountID = c.AccountID
INNER JOIN CTSCustomer AS Cust ON c.CTSCustID = Cust.CTSCustID
WHERE Cust.Custid = 148626504
AND d.TransDate >= DATE_SUB(NOW(), INTERVAL 90 DAY)
;

select * from CustomerLoginInfoDetection order by ID desc;

-- CC 305 - DW
delete from [bodb_Account].[dbo].[CTS_CustFirstbetDate] where custid in (82272959,82293018,82349969,82352294);

DECLARE @c_FromDate DATETIME = DATEADD(DAY, -14, GETDATE());
DECLARE @c_ToDate DATETIME = DATEADD(DAY, -8, GETDATE());
DECLARE @l_FromDate DATETIME = DATEADD(DAY, -3, GETDATE());
DECLARE @l_ToDate DATETIME = DATEADD(DAY, -1, GETDATE());

insert into [bodb_Account].[dbo].[CTS_CustFirstbetDate] (custid, firstbetDate,ModifiedDate)
values
(82272959,@c_FromDate,GETDATE()),
(82293018,@c_ToDate,GETDATE()),
(82349969,@l_FromDate,GETDATE()),
(82352294,@l_ToDate,GETDATE());

SELECT c.username,CTS.*
  FROM [bodb_Account].[dbo].[CTS_CustFirstbetDate] CTS (NOLOCK)
  INNER JOIN bodb_account.dbo.Customer c WITH (NOLOCK) ON CTS.custid = c.custid
		and FirstbetDate > 	'2024-01-16 23:59:59.997'
		AND c.roleid = 1;
		
/*************************************** 2.3 Others ***************************************/
-- Parameter of DailyPA
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_DailyPAQueue; -- 2024-01-05 05:44:42
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = '2024-04-14 05:11:41' WHERE (`ParameterID` = '88');
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_DailyPAQueue` (`CustID`, `CreatedTime`) 
VALUES 

('1301', '2024-04-15 05:44:42')
;

###########################################################################################################################################################################
/*************************************** 3. Test Potential PA flow ***************************************/
/*************************************** 3.1 CC2600 - Initial GB ***************************************/
Use bodb_VR2Model;
DECLARE
@custid int  = 82352338,
@sporttype int = 2            -- 1: Soccer, 2: Basketball, NULL: Soccer/Basketball (mix sports)
; 

DELETE from dbo.CustomerClassification_ScannedNewCust  where CustId in (@custid);

DECLARE @Today									DATETIME2 = GETDATE();

select  c.username, c.custid, c.currency, c.site, @Today AS 'Current time' FROM bodb02.dbo.customer c WITH (NOLOCK) INNER JOIN bodb02.dbo.custInfo i (NOLOCK) ON c.custid = i.custid  where c.custid = @custid ;

INSERT INTO dbo.CustomerClassification_ScannedNewCust (CustId,TotalTicketCount,GBTicketCount,SportType,CreatedTime,JobScannedType,LastJobScannedTime)
values
(@custid,6,4,@sporttype,@Today,2,@Today)
;

Update CustomerClassification_Parameter set Value =  @Today	 where DataId = 7;
Update CustomerClassification_Parameter set Value = 0 where DataId = 14;


SELECT TOP (100) * FROM [bodb_VR2Model].[dbo].[CustomerClassification_ScannedNewCust] order by LastJobScannedTime desc;

select DataID,Value from CustomerClassification_Parameter where dataid in (7,14);

-- Step 2: Start Job "CTS_CC.CTS_CustomerClassification_Secondly_TWInitialGBToCCScan"

-- Step 3 : Check Username in CTS

-- Parameter of CC2600 - Initial GB
delete from Customer_InitialGroupBetting where custid in (148626493);
delete from CTSCustomerClassification where custid in (100030177);

INSERT INTO `CTS_DataCenter`.`Customer_InitialGroupBetting` (`CustID`, `GBTicketCount`, `SportType`, `SourceCreatedDate`, `CreatedDate`) VALUES 
('148626498', '5', '1', now(), now());

select c.UserName,gb.* from Customer_InitialGroupBetting as gb
left join CTSCustomer as c on c.CustID = gb.CustID
 order by gb.CreatedDate desc;
 
-- update CTSCustomerClassification_History set Sporttype = 50 where  custid in (82353653);
-- CALL CTS_Arc_CustomerAssociation_RollBack_CheckByNewPA('[{"CTSCustID":1000930445,"CustID":82352338,"CustomerClass":2600,"SportID":0,"CategoryID":30300,"ScannedTime":"2024-07-25T07:24:31"}]')
-- Check if CC2600 rollback Ass Archive/ service DW call UAT1
-- column DWCategoryID show cate winning?

select * from Customer_InitialGroupBetting order by CreatedDate desc;
CALL CTS_DC_CustClassification_InitialGB_GetCustInfo_UAT4('100030177');
CALL CTS_DataCenter.CTS_DC_CustClassification_GetCCAndDangerLevel_UAT4('100030177');

/*************************************** 3.2 CC2700 - Initial Smart ***************************************/
-- Parameter of CC2700 - Initial Smart
-- delete from CTSCustomerClassification where custid in (82354349,82353653,43841253);
select * from Customer_InitialSmart where custid in (148626498);

-- delete from Customer_InitialGroupBetting where custid in (43841253);

 delete from Customer_InitialSmart where custid in (148626498);

UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = '0' WHERE (`ParameterID` = '159');
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = '2024-07-31 02:00:48.522' WHERE (`ParameterID` = '160');

select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (159,160,161);

 INSERT INTO `CTS_DataCenter`.`Customer_InitialSmart` (`CustID`, `Probability`, `SourceCreatedDate`, `InsertedTime`) VALUES 
 ('148626498', '0.851', '2024-07-31 02:01:01.111', now());
select * from Customer_InitialSmart order by InsertedTime desc;
select * from Customer_InitialSmart_Log;
CALL CTS_DC_CustClassification_InitialSmart_Get_UAT4(@outParam0, @outParam1);

/*************************************** 3.3 CC2800 - Early Warning Members ***************************************/
-- Parameter of CC2800 - Early Warning Members 
delete from Customer_DangerousScore where custid in ( 148626498 );

select ParameterID,ParameterName,ParameterValue from SystemParameter where parameterID in (153,154,155,156,157,158);

-- credit - 153, Deposit - 156
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = DATE_ADD(NOW(), INTERVAL -2 Minute)
WHERE (`ParameterID` = '153');
INSERT INTO `CTS_DataCenter`.`Customer_DangerousScore` (`CustID`, `IsLicensee`, `DangerousScore`, `CreatedDate`, `LastModifiedDate`, `ClassifiedScore`, `ClassifiedDate`) VALUES 
('148628838', '0', '0.9000', now(), now(), '0.9000', now());

UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = DATE_ADD(NOW(), INTERVAL -2 Minute)
WHERE (`ParameterID` = '156');
INSERT INTO `CTS_DataCenter`.`Customer_DangerousScore` (`CustID`, `IsLicensee`, `DangerousScore`, `CreatedDate`, `LastModifiedDate`, `ClassifiedScore`, `ClassifiedDate`) VALUES 
('148626498', '1', '0.9500', now(), now(), '0.9500', now());

SELECT C.CTSCustid, C.UserName, D.* FROM Customer_DangerousScore AS D INNER JOIN CTSCustomer AS C ON D.CustID = C.CustID
ORDER BY D.LastModifiedDate DESC
LIMIT 15;

##############################################################################################################################################################################
/*************************************** 4. Change CC Prio by Renovate Setting ***************************************/
-- Modify Priority
-- 1. edit  CustomerCategorySettings
select * from CustomerCategorySettings;
UPDATE `CTS_DataCenter`.`CustomerCategorySettings` SET `IsMultiCateIDSameParentID` = true,`IsKeepOldCateID` = true   WHERE  (categoryID in (30100,30200,30300,35100,35200,35300));
UPDATE `CTS_DataCenter`.`CustomerCategorySettings` SET ParentID = 20000  WHERE  (categoryID in (30100,30200,30300,35100,35200,35300));
-- 2. edit priority in CustomerCategory 
UPDATE `CTS_DataCenter`.`CustomerCategory` SET ParentID = 20000   WHERE  (categoryID in (30100,30200,30300,35100,35200,35300));
-- 3. edit sp CTS_DC_CustClassification_ReScan_get
-- 4. edit sp CTS_DC_CustClassification_Get to show multi PA + potential PA 

select * from StaticList;
select * from CustomerCategory where ( CategoryGroupID in  (21100,21200,26100,26200 ) or parentid = 30000)and isactive = 1 ;

