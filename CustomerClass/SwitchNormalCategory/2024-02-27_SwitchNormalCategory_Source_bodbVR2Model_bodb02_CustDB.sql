/*
	Created:	20240227@Irena.Vo
	Task :		Create script to generate data from bodbVR2Model, bodb02, CustDB for switch category
	DB:			CTS_DataCenter
	
	Revisions:
			-   20240227@Irena.Vo: Created
*/
USE bodb_VR2Model;
-- Step 6: Define parameters
DECLARE  	@CustIDs VARCHAR(MAX) = '1284,3681780,4504877' /*recommend at least 1 credit & 1 licensee & 1 special site*/
		,	@CurrentCategory SMALLINT = 201, @TargetCategory SMALLINT = 203 /*201: New;   202: Normal;   203: Smart;   204: Risky;   205: Good;   206: Probation*/
		,	@RawNum SMALLINT = 1, @TurnoverRM SMALLMONEY = 1000, @WinlossRM SMALLMONEY = 100, @BetCount INT = 10, @ActiveDays INT = 10 
		,	@Sporttype SMALLINT = 1,  @TotalTicketCount BIGINT = 6,  @GBTicketCount BIGINT = 4 /*TWGB - NEW*/
		,	@CreatedDate DATE = GETDATE(), @CreatedTime DATETIME = CURRENT_TIMESTAMP
;		

-- Step 7: Update customer info  
if OBJECT_ID ( 'tempdb..#tmpCustInfo', 'U') IS NOT NULL DROP TABLE #tmpCustInfo
CREATE TABLE #tmpCustInfo(
		CustID  BIGINT PRIMARY KEY
	,	IsSpecialSite BIT
	,	IsDeposit BIT
	,	TurnoverRM DECIMAL(19,4)
	,	WinlossRM DECIMAL(19,4)
	,	BetCount BIGINT
	,	ActiveDays BIGINT
);

INSERT INTO  #tmpCustInfo (CustID) 
SELECT DISTINCT CAST(VALUE AS BIGINT) CustID 
FROM STRING_SPLIT(@CustIDs, ',');

UPDATE	tmp WITH(ROWLOCK, UPDLOCK)
SET		tmp.IsSpecialSite = CASE WHEN c.Site IN ('haifa','manbetx','HC6YAYOU','US8YAYOU','BPLE','Okada') THEN 1 ELSE 0 END
	,	tmp.IsDeposit =  CASE WHEN d.custid IS NOT NULL THEN 1 ELSE 0 END
FROM #tmpCustInfo AS tmp
	INNER JOIN bodb02.dbo.Customer AS c WITH(NOLOCK) ON c.CustId = tmp.custid
	LEFT JOIN bodb02.dbo.Dep_CustSuper AS d WITH(NOLOCK) ON c.SRecommend = d.custid;

UPDATE	tmp WITH(ROWLOCK, UPDLOCK)
SET		tmp.TurnoverRM = CASE WHEN r.TurnoverRM IS NOT NULL THEN r.TurnoverRM + @RawNum 
							  ELSE @TurnoverRM END 
	,	tmp.WinlossRM = CASE WHEN r.WinlossRM2 IS NOT NULL THEN r.WinlossRM2 + @RawNum 
							 WHEN r.WinlossRM IS NOT NULL THEN r.WinlossRM + @RawNum 
							 ELSE @WinlossRM END
	,	tmp.BetCount = CASE WHEN r.BetCount < r.BetCount2 THEN r.BetCount2 + @RawNum 
							WHEN r.BetCount IS NOT NULL THEN r.BetCount + @RawNum 
							ELSE @BetCount END
	,	tmp.ActiveDays = CASE WHEN @TargetCategory = 205 THEN r.ActiveDays + @RawNum 
							  ELSE @ActiveDays END
FROM #tmpCustInfo AS tmp
	INNER JOIN dbo.CustomerClassification_Rule r ON r.CurrentCategory = @CurrentCategory AND r.CategoryId = @TargetCategory;

-- Step 8: Clean old data
DELETE ac FROM dbo.CustomerClassification_LatestActiveDay ac WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = ac.CustID);
DELETE r FROM dbo.CustomerClassification_ResetBalance r WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = r.CustID);
DELETE p FROM dbo.CustomerClassification_NormalPool p WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = p.CustID);
DELETE cc FROM dbo.CustomerClassification cc WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = cc.CustID);
DELETE tw FROM dbo.CustomerClassification_ScannedNewCust AS tw WHERE EXISTS (SELECT 1 FROM #tmpCustInfo AS tmp WHERE tmp.CustID = tw.CustID);

-- Step 9: Generate existing data: ActiveDays, ResetBalance, Normal Pool
INSERT INTO dbo.CustomerClassification_LatestActiveDay (CustId, LastTransDate, LastTransTime, CreatedTime)
SELECT CustID,	@CreatedDate, @CreatedTime, @CreatedTime
FROM #tmpCustInfo;

INSERT INTO dbo.CustomerClassification_ResetBalance  (CustId, ResetDate, CreatedTime)
SELECT CustID, @CreatedDate, @CreatedTime
FROM #tmpCustInfo;

INSERT INTO dbo.CustomerClassification_NormalPool (CustId, Priority, FunctionId, CreatedTime)
SELECT 	CustID,	10,	4,	@CreatedTime
FROM #tmpCustInfo;

-- Step 10
-- OPTION 1. No action

-- OPTION 2. Generate existing data: NEW (TWGB) 
/*
SP: CTS_CustomerClassification_CheckNewGroupBetting
TABLE: dbo.CustomerClassification_ScannedNewCust
RULE: Soccer: TaggingID = 9: IsServiceScanned BIT = 0, JobScannedType SMALLINT = 2, Sporttype = 1,  GBTicketCount >= 4
	  Basketball: TaggingID = 9: IsServiceScanned BIT = 0, JobScannedType SMALLINT = 2, Sporttype = 2,  GBTicketCount >= 3
*/
/*INSERT INTO dbo.CustomerClassification_ScannedNewCust (CustId, TotalTicketCount, GBTicketCount, SportType, CreatedTime, JobScannedType, LastJobScannedTime, IsServiceScanned, LastServiceScannedTime)
SELECT CustID, @TotalTicketCount, @GBTicketCount, @SportType, @CreatedTime, 2, @CreatedTime, 0, @CreatedTime
FROM #tmpCustInfo;

EXEC bodb_VR2Model.dbo.CTS_CustomerClassification_CheckNewGroupBetting @custIdList = @CustIDs;*/

/*-- OPTION 3. Generate existing data: PROBATION, SMART, RISKY (TWGB)
USE bodb02;
-- Step 1: Define parameters
DECLARE  	@CustIDs VARCHAR(MAX) = '1284,3681780,4504877' /*recommend at least 1 credit & 1 licensee & 1 special site*/
		,	@TaggingID SMALLINT = 7 
		,	@TicketCount BIGINT = 30, @DesktopTicketCount BIGINT = 28, @RejectTicketCount BIGINT = 9, @GBTicketCount BIGINT = 2
		,	@CreatedDate DATE = GETDATE(), @CreatedTime DATETIME = CURRENT_TIMESTAMP
;

-- Step 2: Insert CustID list  
if OBJECT_ID ( 'tempdb..#tmpCustIDs', 'U') IS NOT NULL DROP TABLE #tmpCustIDs
CREATE TABLE #tmpCustIDs(CustID  BIGINT PRIMARY KEY);
INSERT INTO  #tmpCustIDs (CustID) 
SELECT DISTINCT CAST(VALUE AS BIGINT) CustID 
FROM STRING_SPLIT(@CustIDs, ',');

-- Step 3: Clean old data
DELETE tw FROM dbo.SPU_GroupBettingCustomer AS tw WHERE EXISTS (SELECT 1 FROM #tmpCustIDs AS tmp WHERE tmp.CustID = tw.CustID);

-- Step 4: Insert TWGB data
/*
SP: CTS_CustomerClassification_CheckGroupBettingAndReject
TABLE: dbo.SPU_GroupBettingCustomer
RULE:
. TaggingID = 8: Reject & Desktop: TWTicketParlayCount = 0 AND TWDesktopUsageRate > 90 AND TWTicketRejectRate >= 30
. TaggingID = 7: Group Betting: Not TaggingID = 8 AND TWTicketParlayCount = 0 AND ((TWBetCount <= 30 AND TWGroupBettingRate >= 6) OR (TWBetCount > 30 AND TWGroupBettingRate >= 2))
*/
IF (@TaggingID = 8) BEGIN
	INSERT INTO dbo.SPU_GroupBettingCustomer (CustId, TicketCount, ParlayTicketCount, DesktopTicketCount, RejectTicketCount, GBTicketCount, ScanDate, LastModifiedDate, LastCountTotalTicketDate)
	SELECT CustID, @TicketCount, 0, @DesktopTicketCount, @RejectTicketCount, 0, @CreatedDate, @CreatedTime, @CreatedTime
	FROM #tmpCustIDs
END;
IF (@TaggingID = 7) BEGIN
	INSERT INTO dbo.SPU_GroupBettingCustomer (CustId, TicketCount, ParlayTicketCount, DesktopTicketCount, RejectTicketCount, GBTicketCount, ScanDate, LastModifiedDate, LastCountTotalTicketDate)
	SELECT CustID, @TicketCount, 0, 0, 0, @GBTicketCount, @CreatedDate, @CreatedTime, @CreatedTime
	FROM #tmpCustIDs
END;
EXEC dbo.CTS_CustomerClassification_CheckGroupBettingAndReject @custIdList = @CustIDs;
*/

-- Step 11: Check raw data
USE bodb_VR2Model;
SELECT * FROM dbo.CustomerClassification_LatestActiveDay ac WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = ac.CustID);
SELECT * FROM dbo.CustomerClassification_ResetBalance r WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = r.CustID);
SELECT * FROM dbo.CustomerClassification_NormalPool p WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = p.CustID);

-- Step 12: Generate data in DW
SELECT * FROM #tmpCustInfo cc;-- get info for the below file.
/*File: 2024-02-27_GenerateDataRealtime.sql, Current Category = NULL/INACTIVE/NEW/GOOD/NORMAL*/
/*File: 2024-02-27_GenerateDataDailyProb.sql, Current Category = PROB/SMART/RISKY*/

-- Step 13: Start service: CTS_CustomerClassification_Secondly_NormalAccountClassification_Renovate
-- Step 14: Start service: CTS_CustomerClassification_Secondly_NormalAccountInsert_Renovate
-- Step 15: Check result on VR2Model
SELECT * FROM dbo.CustomerClassification cc WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = cc.CustID);

-- Step 16: Check new category
/*File: 2024-02-27_SwitchNormalCategory_Source_CTS.sql*/

/*=====CHECK RESULTS*/
-- Step 17: Define parameters
USE CustDB;
DECLARE @CustIDs VARCHAR(MAX) = '1284,3681780,4504877' /*recommend at least 1 credit & 1 licensee & 1 special site*/
;

-- Step 18: Insert CustID list  
if OBJECT_ID ( 'tempdb..#tmpCustIDs', 'U') IS NOT NULL DROP TABLE #tmpCustIDs
CREATE TABLE #tmpCustIDs(CustID  BIGINT PRIMARY KEY);
INSERT INTO  #tmpCustIDs (CustID) 
SELECT DISTINCT CAST(VALUE AS BIGINT) CustID 
FROM STRING_SPLIT(@CustIDs, ',');

-- Step 19: Check result
SELECT * FROM dbo.CustInfo cus WHERE EXISTS (SELECT 1 FROM #tmpCustInfo tmp WHERE tmp.CustID = cus.CustID);
