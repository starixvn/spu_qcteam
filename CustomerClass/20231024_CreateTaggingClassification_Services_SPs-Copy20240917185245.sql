/*
	Created:	20230929@Lisa.Phan
	Task :		Create Tagging; Services and SPs flow of Tagging 
	DB:			CTS_DataCenter, 10.18.200.56 (TESTDB061)
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
SELECT CategoryName, CategoryID, CategoryGroup, CustomerClass, ParentID, IsActive, IsUsedManually, ScanTaggingIntervalInSecond, RootTaggingID, a.* 
FROM CTS_DataCenter.CustomerCategory as a
WHERE ParentID = 200 AND IsActive = 1 AND IsUsedManually = 0 AND ScanTaggingIntervalInSecond > 0; 

-- 2. Get cust having Normal CategoryGroup (cust must exist both in CTS and mainDB)
SELECT c.Custid, c.CTSCustID, c.CategoryID, c.LastScannedDate, c.* FROM CTSCustomerClassification AS c
	INNER JOIN CustomerCategory AS cate ON cate.CategoryID = c.CategoryID
WHERE c.SportGroupID = 200 
	and cate.ParentID = 200 
	AND cate.IsActive = 1
	AND cate.IsUsedManually = 0
	-- and c.CategoryID IN (201); -- 201,202,203,204,205,206,211,212,213,221,222,223,231,232,233,251,252,253,257,258,261,262,263,267,268,271,272,273,277,278

-- OR create cust having Normal Category (cust must exist both in CTS and mainDB)
SELECT @custID := CustID, @CTSCustID := CTSCustID, @SubscriberID := SubscriberID FROM CTS_DataCenter.CTSCustomer 
where CustSubID = 0 
	  -- and UserName = '12BETAUD02001'
	  LIMIT 1; 
SELECT @CategoryID := 201, @TargetCC := 200;	   
DELETE FROM CTSCustomerClassification WHERE CustID = @custID AND CTSCustID = @CTSCustID;
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification` (`CustID`, `CTSCustID`, `SubscriberID`, `SportGroupID`, `CategoryID`, `CreatedDate`, `CreatedBy`, `LastModifiedDate`, `LastModifiedBy`, `LastScannedDate`) 
VALUES (@custID, @CTSCustID, @SubscriberID, 200, @CategoryID, '2023-06-04 08:00:00', 10278938, '2023-06-04 23:44:18', 10278938, '2023-06-04');
-- If Probation/ Prob linked PA/ Prob High Rejected ... -> insert/ update table CTS_DataCenter.ProbationAccountMonitor 
-- (optinal)
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_History` (`CustID`, `CTSCustID`, `SportGroupID`, `CategoryID`, `TurnoverRM`, `WinlossRM`, `BetCount`, `ActiveDays`, `TargetCC`, `FromCategoryID`, `ToCategoryID`, `LastModifiedDate`, `LastModifiedBy`, `InsertDate`) 
VALUES (@custID, @CTSCustID, 200, @CategoryID, 10, 10, 1, 1, @TargetCC, @CategoryID, @CategoryID, '2023-06-04 23:44:18', 169368, '2023-06-04 00:00:00');
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_Log` (`CustID`, `CTSCustID`, `SportGroupID`, `CategoryID`, `TurnoverRM`, `WinlossRM`, `BetCount`, `ActiveDays`, `TargetCC`, `FromCategoryID`, `ToCategoryID`, `LastModifiedDate`, `LastModifiedBy`, `InsertDate`) 
VALUES (@custID, @CTSCustID, 200, @CategoryID, 10, 10, 1, 1, @TargetCC, @CategoryID, @CategoryID, '2023-06-04 23:44:18', 169368, '2023-06-04 00:00:00');

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

#============Create Tagging linked PA - CTS ==============
-- TaggingType = 1
-- TaggingId = 13 - create Device association with 3 Robot User accounts
-- TaggingID = 8 -  create Device association with 3 Group Betting accounts
-- TaggingID = 10 - create device association with 3 Hedging accounts

-- 1. Find 3 accounts to create association
-- Find 3 Robot accounts
SELECT a.CustID, b.UserName FROM CTS_DataCenter.CTSCustomerClassification as a 
	INNER JOIN CTS_DataCenter.CTSCustomer AS b ON a.CustID = b.CustID
where a.CategoryID in (163,164,165,166)  and b.RoleID = 1 and b.CustSubID = 0 
limit 3 ; -- ROLETEU,MENKYBEU,068RMB  CustID in (1470,1490,1640)
DELETE FROM CTS_DataCenter.CTSCustomerClassification WHERE CustID in (1470,1490,1640) and CategoryID NOT IN (163,164,165,166); -- remove other PA, keep only Robot

-- Find 3 Group Betting accounts
SELECT a.CustID, b.UserName FROM CTS_DataCenter.CTSCustomerClassification as a 
	INNER JOIN CTS_DataCenter.CTSCustomer AS b ON a.CustID = b.CustID
where a.CategoryID in (52,92)  and b.RoleID = 1 and b.CustSubID = 0 
limit 3 ;  -- 141SD,710SD,757SD    CUSTID IN (1309,1338,1350)
DELETE FROM CTS_DataCenter.CTSCustomerClassification WHERE CUSTID IN (1309,1338,1350) and CategoryID NOT IN (52,92); -- remove other PA, keep only GB

-- Find 3 Hedging accounts
SELECT a.CustID, b.UserName FROM CTS_DataCenter.CTSCustomerClassification as a 
	INNER JOIN CTS_DataCenter.CTSCustomer AS b ON a.CustID = b.CustID
where a.CategoryID in (53,55,59,93)  and b.RoleID = 1 and b.CustSubID = 0 
limit 3 ;  -- 12BETUUS01001,12BETRMB01004,12BETRMB01009


-- 2. Run script: Create association by Device with 3 Robot accounts / Group Betting accounts / Hedging accounts

-- Check Tagging linked PA -> CTS_DataCenter
CALL CTS_DC_CustClassification_GetTaggingByAssociationWithPA('10918');

## MainDB
#============Create TW Tagging - DB: 10.18.200.56 - TESTDB061==============
-- TaggingType = 2: TaggingID = 8 (High Rejected), 7 (Group Betting) 

-- Steps to create cust with Tagging 8, 7
	-- 1st way: If existing cust satisfy tagging rule
	IF OBJECT_ID('tempdb..#tmpCustomerGroupPercentage') IS NOT NULL
	BEGIN
		DROP TABLE	#tmpCustomerGroupPercentage;
	END;

	CREATE TABLE #tmpCustomerGroupPercentage (
			CustId				INT NOT NULL PRIMARY KEY	
		,	TWBetCount			INT NULL
		,	TWGroupBettingRate	MONEY NULL	
		,	TWTicketRejectRate	MONEY NULL
		,	TWDesktopUsageRate	MONEY NULL
		,	TWTicketParlayCount	INT NULL	
	);
	
	INSERT INTO #tmpCustomerGroupPercentage (CustId, TWBetCount, TWGroupBettingRate, TWTicketRejectRate, TWDesktopUsageRate, TWTicketParlayCount)
	SELECT 	gbc.CustId
		,	SUM(gbc.TicketCount) AS 'TWBetCount'
		,  	CASE WHEN SUM(gbc.TicketCount) <> 0 THEN SUM(CONVERT(MONEY, gbc.GBTicketCount)) * 100 / SUM(CONVERT(MONEY, gbc.TicketCount)) ELSE NULL END AS 'TWGroupBettingRate'
		,  	CASE WHEN SUM(gbc.TicketCount) <> 0 THEN SUM(CONVERT(MONEY, gbc.RejectTicketCount)) * 100 / SUM(CONVERT(MONEY, gbc.TicketCount)) ELSE NULL END AS 'TWTicketRejectRate'
		,  	CASE WHEN SUM(gbc.TicketCount) <> 0 THEN SUM(CONVERT(MONEY, gbc.DesktopTicketCount)) * 100 / SUM(CONVERT(MONEY, gbc.TicketCount)) ELSE NULL END AS 'TWDesktopUsageRate'
		,	SUM(gbc.ParlayTicketCount) AS 'TWTicketParlayCount'
	FROM [bodb02].dbo.SPU_GroupBettingCustomer AS gbc WITH (NOLOCK)
	WHERE gbc.ScanDate >= DATEADD(DAY,-60,GETDATE()) AND gbc.ScanDate < DATEADD(DAY,1,GETDATE())
	-- and CustId IN (1411402,1481207,1775698,121124,169695,954103) 
	-- CateID=8: 41905,121126,7681882
	-- CateID=7: 11576,121129,7681878
	GROUP BY gbc.CustId;

	-- Tagging 8: 
	SELECT * FROM  #tmpCustomerGroupPercentage  r
	WHERE r.TWTicketParlayCount = 0
		AND r.TWDesktopUsageRate > 90
		AND r.TWTicketRejectRate >= 30; -- Custid = 1481207 

	-- Tagging 7, exclude cust exists in Tagging 8 
	SELECT * FROM  #tmpCustomerGroupPercentage  r
	WHERE custid NOT IN (1780022,1809391,1821795) and r.TWTicketParlayCount = 0
		  AND ((r.TWBetCount <= 30 AND r.TWGroupBettingRate >= 6)
				OR (r.TWBetCount > 30 AND r.TWGroupBettingRate >= 2) 
			); Custid = 1775698 
	
	UPDATE [bodb02].dbo.SPU_GroupBettingCustomer SET CustID=41905 WHERE Custid = 1481207 
	and ScanDate >= DATEADD(DAY,-60,GETDATE()) AND ScanDate < DATEADD(DAY,1,GETDATE()); 
	
	UPDATE [bodb02].dbo.SPU_GroupBettingCustomer SET CustID=121130 WHERE Custid = 1775698 
	and ScanDate >= DATEADD(DAY,-60,GETDATE()) AND ScanDate < DATEADD(DAY,1,GETDATE()); 
	
	
	-- 2nd way: If NO cust satisfies tagging rule:
-- Pick 1 cust for update 
	SELECT 	* FROM [bodb02].dbo.SPU_GroupBettingCustomer AS gbc WITH (NOLOCK)
	WHERE CUSTID NOT IN (41903,7681882,121130,7681880,3947505,11576,121126,1282)
	ORDER BY gbc.CustId asc; -- Custid = 41906, 91666947
-- Update for High Rejected
    UPDATE [bodb02].dbo.SPU_GroupBettingCustomer
	SET CustID=41906,
		ParlayTicketCount = 0
		,DesktopTicketCount =95
		,RejectTicketCount = 35
		,ScanDate = DATEADD(DAY,5,GETDATE())
	WHERE Custid = 121130 and ScanDate = '2023-06-30'; 
-- Update for Group Betting: 
	UPDATE [bodb02].dbo.SPU_GroupBettingCustomer
	SET CustID=3947538,
		ParlayTicketCount = 0
		,DesktopTicketCount = 15
		,TicketCount = 20
		,GBTicketCount = 9 
		,ScanDate=DATEADD(DAY,5,GETDATE())
	WHERE Custid = 91666947  and ScanDate = '2023-06-30'; 
	
-- check TW tagging -> 10.18.200.56/ sputeam
EXEC [bodb02].[dbo].[CTS_CustomerClassification_CheckGroupBettingAndReject] @custIdList = '41906,3947538'	

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