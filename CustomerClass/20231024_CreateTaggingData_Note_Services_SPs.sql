/*
	Created:	20230929@Lisa.Phan
	Task :		Create Tagging; Services and SPs flow of Tagging 
	DB:			CTS_DataCenter, 10.18.200.56 (TESTDB061)
	Revision:   20241008@Lisa.Phan Renovate CC
				20241009@Lisa.Phan Update TW Tagging script
*/
-- Customer Classification - CC 20xx-21xx-22xx-23xx-24xx
-- https://nexdev.net/projects/customer-tracking-system/wiki/202307_-_Customer_Classification_-_CC_20xx-21xx-22xx-23xx-24xx

#====== Note ======= 
-- 1/check Current Tagging -> CTS_DataCenter
SELECT cc.CustID, ctsc.UserName, cc.CategoryID, c.TaggingID, c.TaggingType FROM CTSCustomerClassification as cc
	INNER JOIN CustomerCategory as c ON cc.CategoryID = c.CategoryID 
	INNER JOIN CTSCustomer as ctsc ON cc.CustID = ctsc.CustID
WHERE cc.CUSTID in (121124);
-- 2/ check Tagging linked PA -> CTS_DataCenter
CALL CTS_DC_CustClassification_GetTaggingByAssociationWithPA('10918,11576,7681880,41906,41903,3947538,3947505,117161,121126,1282,7681882,121130');
-- 3/ check TW tagging -> 10.18.200.56/ sputeam
EXEC [bodb02].[dbo].[CTS_CustomerClassification_CheckGroupBettingAndReject] @custIdList = '5941,5942'

#====== Prepare for creating Tagging =======
-- 1. Get Category can go with Tagging: Normal Category, exclude Inactive, 4x
SELECT CategoryName, CategoryID, CategoryGroupID, CustomerClass, ParentID, IsActive, ScanTaggingIntervalInSecond, RootTaggingID, a.* 
FROM CTS_DataCenter.CustomerCategory as a
WHERE ParentID = 40000 AND IsActive = 1 AND ScanTaggingIntervalInSecond > 0; 

-- 2. Get cust having Normal CategoryGroup (cust must exist both in CTS and mainDB)
SELECT c.Custid, c.CTSCustID, c.CategoryID, c.LastScannedDate, c.* FROM CTSCustomerClassification AS c
INNER JOIN CustomerCategory AS cate ON cate.CategoryID = c.CategoryID
WHERE cate.ParentID = 40000 
AND cate.IsActive = 1  AND cate.ScanTaggingIntervalInSecond > 0;
	-- and c.CategoryID IN (40100); -- 40100,40101,40102,40103,40200,40201,40202,40203,40300,40301,40302,40303,40400,40401,40402,40403,40404,40405,40500,40501,40502,40503,40504,40505,40600,40601,40602,40603,40604,40605
select current_date()
-- OR create cust having Normal Category (cust must exist both in CTS and mainDB)
SELECT @custID := CustID, @CTSCustID := CTSCustID, @SubscriberID := SubscriberID FROM CTS_DataCenter.CTSCustomer 
where CustSubID = 0 
-- and UserName = '12BETAUD02001'
order by RAND()	  
LIMIT 1; 
SELECT @CategoryID := 40100, @TargetCC := 200;	   
DELETE FROM CTSCustomerClassification WHERE CustID = @custID AND CTSCustID = @CTSCustID;
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification` (`CustID`, `CTSCustID`, `SubscriberID`, `ParentID`, `CategoryID`, `CreatedDate`, `CreatedBy`, `LastModifiedDate`, `LastModifiedBy`, `LastScannedDate`) 
VALUES (@custID, @CTSCustID, @SubscriberID, 40000, @CategoryID, DATE_ADD(NOW(), INTERVAL -15 day), 10278938, NOW(), 10278938, DATE_ADD(NOW(), INTERVAL -3 day));
-- If Probation/ Prob linked PA/ Prob High Rejected ... -> LastScannedDate/CreatedDate must satisfy rule to change to other CategoryID 
-- (optinal)
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_History` (`CustID`, `CTSCustID`, `ParentID`, `CategoryID`, `TurnoverRM`, `WinlossRM`, `BetCount`, `ActiveDays`, `TargetCC`, `LastModifiedDate`, `LastModifiedBy`, `InsertDate`) 
VALUES (@custID, @CTSCustID, 40000, @CategoryID, 10, 10, 1, 1, @TargetCC, NOW(), 169368, current_date());
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_Log` (`CustID`, `CTSCustID`, `ParentID`, `CategoryID`, `TurnoverRM`, `WinlossRM`, `BetCount`, `ActiveDays`, `TargetCC`, `OldCategoryID`, `DWCategoryID`, `LastModifiedDate`, `LastModifiedBy`, `InsertDate`) 
VALUES (@custID, @CTSCustID, 40000, @CategoryID, 10, 10, 1, 1, @TargetCC, @CategoryID, @CategoryID, NOW(), 169368, current_date());

-- 3.1 delete special cases: 
DELETE from CTS_DataCenter.CTSCustomerClassificationOldCategory  where  custid = @custID;
DELETE FROM CTS_DataCenter.TaggingExclusion where CTSCUSTID = @CTSCustID;
DELETE FROM CTS_DataCenter.PinCustomerCategory where CTSCUSTID = @CTSCustID;

-- 3.2 delete all association: 
DELETE FROM CTS_DataCenter.AssociationByManual WHERE FromCTSCustID = @CTSCustID OR ToCTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.AssociationByIP where ToCustID = @custID OR FromCustID = @custID;
DELETE FROM CTS_DataCenter.AssociationByDevice WHERE CTSCUSTID = @CTSCustID;
DELETE FROM CTS_DataCenter.AssociationByAI WHERE ToCustID = @custID OR FromCustID = @custID;
DELETE FROM CTS_DataCenter.AssociationGroupByAI WHERE CustID = @custID;

#============Create Tagging linked Robot/Group/PA - CTS ==============
-- TaggingType = 1
-- TaggingId = 13 - create Device association with 3 Robot User/Odd Crawler Robot accounts (only have  Robot User/Odd Crawler Robot)
-- TaggingID = 8 -  create Device association with 3 Group Betting accounts (only have GB or can have GB and Robot User/Odd Crawler Robot)
-- TaggingID = 10 - create device association with 3 Hedging/Fixed Game/Formula Bet accounts (can have Hedging/Fixed Game/Formula Bet and other PA)

-- 1. Find 3 accounts to create association
-- Find 3 Robot accounts
SELECT a.CustID, b.UserName FROM CTS_DataCenter.CTSCustomerClassification as a 
	INNER JOIN CTS_DataCenter.CTSCustomer AS b ON a.CustID = b.CustID
where a.CategoryID in (21100,26100,21200,26200)  and b.RoleID = 1 and b.CustSubID = 0 
limit 3 ; -- ROLETEU,MENKYBEU,068RMB  CustID in (1470,1490,1640)
-- get 3 custid to run delete
DELETE FROM CTS_DataCenter.CTSCustomerClassification WHERE CustID in (1470,1490,1640) and CategoryID NOT IN (21100,26100,21200,26200); -- remove other PA, keep only Robot

-- Find 3 Group Betting accounts
SELECT a.CustID, b.UserName FROM CTS_DataCenter.CTSCustomerClassification as a 
	INNER JOIN CTS_DataCenter.CTSCustomer AS b ON a.CustID = b.CustID
where a.CategoryID in (20100,25100)  and b.RoleID = 1 and b.CustSubID = 0 
limit 3 ;  -- 141SD,710SD,757SD    CUSTID IN (1309,1338,1350)
-- get 3 custid to run delete
DELETE FROM CTS_DataCenter.CTSCustomerClassification WHERE CUSTID IN (1309,1338,1350) and CategoryID NOT IN (20100,25100); -- remove other PA, keep only GB

-- Find 3 Hedging accounts
SELECT a.CustID, b.UserName FROM CTS_DataCenter.CTSCustomerClassification as a 
	INNER JOIN CTS_DataCenter.CTSCustomer AS b ON a.CustID = b.CustID
where a.CategoryID in (20200,20400,20600,25200,25400,25600)  and b.RoleID = 1 and b.CustSubID = 0 
limit 3 ;  -- 12BETUUS01001,12BETRMB01004,12BETRMB01009

-- 2. Run script: Create association by Device with 3 Robot accounts / Group Betting accounts / Hedging accounts

-- Check Tagging linked PA -> CTS_DataCenter
CALL CTS_DC_CustClassification_GetTaggingByAssociationWithPA('10918');

## MainDB
#============Create TW Tagging - DB: 10.18.200.56 - TESTDB061 (account: sputeam/password: @sputeam#)==============
-- TaggingType = 2: TaggingID = 8 (High Rejected), 7 (Group Betting) 
-- If cust satisfies both 2 tagging type (High Rejected and Group Betting) -> cust is Group Betting tagging

Use WASAVerse
-- Step 1: Delete current data
DELETE FROM WASAVerse.dbo.TWGroupBettingCustomer
WHERE CUSTID IN (1032813,1033999,1034477) -- custid which you want to set TW Tagging
	  AND ScanDate >= DATEADD(DAY,-60,GETDATE()) AND ScanDate < DATEADD(DAY,1,GETDATE()); 

-- Step 2.a: Create TaggingID = 8: High Rejected
INSERT INTO WASAVerse.dbo.TWGroupBettingCustomer (CustID,ParlayTicketCount,DesktopTicketCount,TicketCount,RejectTicketCount,ScanDate)
VALUES (1032813,0,95,10,35,DATEADD(DAY,-5,GETDATE())),
	   (1033999,0,95,10,35,DATEADD(DAY,-5,GETDATE()));
-- Step 2.b: Create TaggingID = 7: Group Betting
INSERT INTO WASAVerse.dbo.TWGroupBettingCustomer (CustID,ParlayTicketCount,DesktopTicketCount,TicketCount,GBTicketCount,ScanDate)
VALUES (1033999,0,15,20,9,DATEADD(DAY,-6,GETDATE())),
	   (1034477,0,95,10,35,DATEADD(DAY,-6,GETDATE()));

-- Step 3: Check TW Tagging
EXEC WASAVerse.[dbo].[CTS_CustomerClassification_CheckGroupBettingAndReject] @custIdList = '1032813,1033999,1034477';	

/* 
#======= Services, SPs flow ==================

select * FROM CTS_DataCenter.SystemParameter WHERE ParameterID IN (143,144,145); 

# 1. Insert to pool (TESTDB053/10.18.200.58  table bodb_VR2Model.[dbo].[CustomerClassification_NormalPool])
- Service: CTS_CustomerClassification_Daily_NormalTaggingScan_Renovate
- sp: 
sp 1: CTS_DC_CustClassification_TaggingScan_Get
-> get danh sách accounts sẽ thực hiện scan tagging daily 
sp 2: CTS_DC_CustClassification_TaggingScan_CheckChanges
-> get danh sách accounts có sự thay đổi tagging
sp 3: CTS_GeneralNormalClassification_RescanNormal_Preprocess
-> Call sp Insert khác -> insert vào pool Normal

para ScanTaggingType: 
2 (only from service Tagging)
1 (Tagging with other flow, if not satisfy bet count - case Normal/Good -> =2)
0 ( NOT from service Tagging)

# 2. Classify (Table bodb_VR2Model.[dbo].[CustomerClassification], bodb_VR2Model.[dbo].[CustomerClassification_Log]  )
- Service: 
CTS_CustomerClassification_Secondly_NormalAccountClassification_Renovate
- SP: 
sp 1:  CTS_GeneralNormalClassification_NormalPool_Get
-> lấy ra danh sách cust đang có trong pool
sp 2:  CTS_GeneralNormalClassification_NormalPool_Classify
->  lấy latest WL, bet count, Turn over, .... insert vào table CustomerClassification -> call sp khác update bet count

# 3. Insert to CTS, push CC to maindb
- Service:
CTS_CustomerClassification_Secondly_NormalAccountInsert_Renovate
- SP: 
sp 1: (DW) CTS_GeneralNormalClassification_NormalAccount_Get
-> lấy danh sách sẽ insert/update vào CTS
sp 2: (CTS) CTS_DC_CustClassification_InsertNormalAccount
-> insert/update info vào CTS	 
*/