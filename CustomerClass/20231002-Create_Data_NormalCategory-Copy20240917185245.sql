/*
		Created:	20230929@Lisa.Phan	
		Purose:	    Create account with Category: New/Good/Normal/Probation/Smart/Risky -- NOT push CC to maindb
		DB:			CTS_DataCenter
*/ 
SET SQL_SAFE_UPDATES = 0;
#-- Step1. Pick a cust exist both in CTS and maindb 
-- SET @CusTID := 1967881, @CTSCustID := 2576360, @SubscriberID := 105; # Manual
SET @CustID = 1967881;

SELECT CTSCustID, SubscriberID
INTO @CTSCustID, @SubscriberID
FROM CTS_DataCenter.CTSCustomer WHERE CustID = @CustID AND CustSubID = 0; 

/* Pick a random cust which is existing in CTS
	SELECT * FROM CTS_DataCenter.CTSCustomer
	where CustSubID = 0 and IsINTernal = 0
	and RoleID = 1 -- 1: Member, 2: Agent, 3: Master, 4: Super
	and IsLicensee = 1 -- 1: Deposit/Licensee, 0: Credit
    and CustID = 1967881
	order by RAND() -- random
	limit 1;
*/

/* Standard: (Margin = WL/TurnOver * 100)
New: 		CategoryID = 201, CC = 200, BetCount < 10
Normal:		CategoryID = 202, CC = 202, BC >=10, -2%< Margin < 0
Good: 		CategoryID = 205, CC = 201, BC >300, Margin <-2%, Turnover>150K(RM), ActiveDays >=8
Smart:		CategoryID = 203, CC = 204, BC >=20, 0 <= Margin <=1%, WL > 15K(RM)
Risky:		CategoryID = 204, CC = 205, BC >=20, Margin > 1%, WL > 15K(RM)
Probation:	CategoryID = 206, CC = 203
	- New/Good/Normal --> Probation: BC >=10, Margin >=0, WL > 15K(RM)
	- Smart --> Probation: BC >=20, 0<=Margin<=1%, WL <=10K (RM)
	- Risky --> Probation: BC >=20, 0<=Margin<=1%, WL <=15K (RM)
*/
-- CustomerClassification
SET	@SportGroupID := 200, @CategoryID := @CategoryID, 
	@CreatedDate := current_timestamp(), @CreatedBy := 10278938, @LastModifiedDate:= current_timestamp(), @LastScannedDate := current_date(), 
    @IsFromTVS := 0, @IsFromTW := 0, @ISFromCTS := 1, @IsFromAI := 0, @IsFromImperva := 0;
-- CategoryID, TargetCC, CustomerClassification_History, CustomerClassification_Log
# SET	@CategoryId := 201, @TargetCC = 200, @TurnoverRM := 10123, @WinlossRM := -4123, @BetCount := 9, @ActiveDays := 9; -- New(Betcount < 10) 
# SET	@CategoryId := 202, @TargetCC = 202, @TurnoverRM := 1012345, @WinlossRM := -6123, @BetCount := 21, @ActiveDays := 11; -- Normal(M=-0.6) 
# SET	@CategoryId := 205, @TargetCC = 201, @TurnoverRM := 250123, @WinlossRM := -10123, @BetCount := 310, @ActiveDays := 11; -- Good (M=4)
 SET	@CategoryId := 206, @TargetCC = 203, @TurnoverRM := 101234, @WinlossRM := 10123, @BetCount := 11, @ActiveDays := 11; -- Prob (M=15.9)
# SET	@CategoryId := 203, @TargetCC = 204, @TurnoverRM := 10123456, @WinlossRM := 16123, @BetCount := 21, @ActiveDays := 11; -- Smart (M=0.16) 
# SET	@CategoryId := 204, @TargetCC = 205, @TurnoverRM := 1012345, @WinlossRM := 17123, @BetCount := 21, @ActiveDays := 11; -- Risky (M=1.68)

SET @TargetCC := @TargetCC, @SourceTypeID := 1, 
    @FromCategoryID := 203, @ToCategoryID := @CategoryID,
    @IsAppliedCC := 0, @IsDataChanged := 1, @ActionType := 0, @IsAuto := 1, 
    @LastModifiedBy := 10278938, @InsertDate:= TIMESTAMP(Current_Date(), "00:00:00"), 
    @TaggingType := 1, @IsAppliedDangerLevel1 := 0, 
    @TWGroupBettingRate := 0, @TWTicketRejectRate := 0, @TWBetCount := 0, @TWDesktopUsageRate := 0;
	
#-- Step2. Remove special cases:
DELETE FROM CTS_DataCenter.CTSCustomerClassification WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.CTSCustomerClassification_Log WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.ProbationAccountMonitor WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.SpecialCustomerClass WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.PinCustomerCategory WHERE CTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.CTSCustomerClassificationVVIP WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.CTSCustomerClassificationQueue WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.CustEvidenceAffectedQueueInsert WHERE CTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.CustEvidence WHERE CTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.TaggingExclusion WHERE CTSCustID = @CTSCustID;
-- (Optional) Remove Association (IP/Device/Betting Pattern): 
DELETE FROM CTS_DataCenter.AssociationByIP WHERE ToCustID = @CustID OR FromCustID = @CustID;
DELETE FROM CTS_DataCenter.AssociationByDevice WHERE CTSCUSTID = @CTSCustID;
DELETE FROM CTS_DataCenter.AssociationByAI WHERE ToCustID = @CustID OR FromCustID = @CustID;
DELETE FROM CTS_DataCenter.AssociationGroupByAI WHERE CustID = @CustID;
       
#--- Step3. Insert Category 
INSERT INTO CTS_DataCenter.CTSCustomerClassification
(CustID, CTSCustID, SubscriberID, SportGroupID, CategoryID, CreatedDate, CreatedBy, LastModifiedDate, LastScannedDate, IsFromTVS, IsFromTW, IsFromCTS, IsFromAI, IsFromImperva)
VALUES (@CustID,@CTSCustID,@SubscriberID,@SportGroupID,@CategoryID,@CreatedDate,@CreatedBy,@LastModifiedDate,@LastScannedDate,@IsFromTVS,@IsFromTW,@IsFromCTS,@IsFromAI,@IsFromImperva);
-- (Optional) Insert Log with performance - show on Web 
INSERT INTO CTS_DataCenter.CTSCustomerClassification_History 
(CustID, CTSCustID, SportGroupID, CategoryID, TurnoverRM, WinlossRM, BetCount, ActiveDays, TargetCC, SourceTypeID, FromCategoryID, ToCategoryID, IsAppliedCC, IsDataChanged, ActionType, IsAuto, LastModifiedDate, LastModifiedBy, InsertDate, TaggingType, IsAppliedDangerLevel1, TWGroupBettingRate, TWTicketRejectRate, TWBetCount, TWDesktopUsageRate, IsFromTVS, IsFromTW, IsFromCTS, IsFromAI, IsFromImperva) 
VALUES (@CustID,@CTSCustID,@SportGroupID,@CategoryID,@TurnoverRM,@WinlossRM,@BetCount,@ActiveDays,@TargetCC,@SourceTypeID,@FromCategoryID,@ToCategoryID,@IsAppliedCC,@IsDataChanged,@ActionType,@IsAuto,@LastModifiedDate,@LastModifiedBy,@InsertDate,@TaggingType,@IsAppliedDangerLevel1,@TWGroupBettingRate,@TWTicketRejectRate,@TWBetCount,@TWDesktopUsageRate,@IsFromTVS,@IsFromTW,@IsFromCTS,@IsFromAI,@IsFromImperva);
-- (Optional) Insert Log with performance 
INSERT INTO CTS_DataCenter.CTSCustomerClassification_Log 
(CustID, CTSCustID, SportGroupID, CategoryID, TurnoverRM, WinlossRM, BetCount, ActiveDays, TargetCC, SourceTypeID, FromCategoryID, ToCategoryID, IsAppliedCC, IsDataChanged, ActionType, IsAuto, LastModifiedDate, LastModifiedBy, InsertDate, TaggingType, IsAppliedDangerLevel1, TWGroupBettingRate, TWTicketRejectRate, TWBetCount, TWDesktopUsageRate, IsFromTVS, IsFromTW, IsFromCTS, IsFromAI, IsFromImperva) 
VALUES (@CustID,@CTSCustID,@SportGroupID,@CategoryID,@TurnoverRM,@WinlossRM,@BetCount,@ActiveDays,@TargetCC,@SourceTypeID,@FromCategoryID,@ToCategoryID,@IsAppliedCC,@IsDataChanged,@ActionType,@IsAuto,@LastModifiedDate,@LastModifiedBy,@InsertDate,@TaggingType,@IsAppliedDangerLevel1,@TWGroupBettingRate,@TWTicketRejectRate,@TWBetCount,@TWDesktopUsageRate,@IsFromTVS,@IsFromTW,@IsFromCTS,@IsFromAI,@IsFromImperva);

SELECT * FROM CTS_DataCenter.CTSCustomerClassification WHERE CustID = @CustID;
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = @CustID ORDER BY LastModifiedDate DESC;
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_Log WHERE CustID = @CustID ORDER BY LastModifiedDate DESC;

#-- Step4. If cust is Probation (CategoryID = 206) -> Insert INTo table ProbationAccountMonitor
/*
SET	@TargetCategoryID := @TargetCC, @FirstMargin := 1.1, @CreatedDate := TIMESTAMP(Current_Date(), "00:00:00"), @CreatedTime := current_timestamp(), @LastScannedDate := current_date();
INSERT INTO CTS_DataCenter.ProbationAccountMonitor 
(CTSCustID, CustID, SportGroupID, TargetCategoryID, FirstMargin, CreatedBy, CreatedDate, CreatedTime, LastScannedDate) 
VALUES (@CTSCustID, @CustID, @SportGroupID, @TargetCategoryID, @FirstMargin, @CreatedBy, @CreatedDate, @CreatedTime,@LastScannedDate);
select * from CTS_DataCenter.ProbationAccountMonitor where CustID = @CustID;
*/

#-- Step5. check on CTS Web:
SELECT Username, CTSCustID, c.* FROM CTS_DataCenter.CTSCustomer c WHERE CustID = @CustID;


/*
	Purpose: Create account with Category: New/Good/Normal/Probation/Smart/Risky -- Push CC to maindb
	MainDB:	 TESTDB053(10.18.200.58), TESTDBCUST(10.18.200.54)
*/

/* Standard: (Margin = WL/TurnOver * 100)
New: 		CategoryID = 201, CC = 200, BetCount < 10
Normal:		CategoryID = 202, CC = 202, BC >=10, -2%< Margin < 0
Good: 		CategoryID = 205, CC = 201, BC >300, Margin <-2%, Turnover>150K(RM), ActiveDays >=8
Smart:		CategoryID = 203, CC = 204, BC >=20, 0 <= Margin <=1%, WL > 15K(RM)
Risky:		CategoryID = 204, CC = 205, BC >=20, Margin > 1%, WL > 15K(RM)
Probation:	CategoryID = 206, CC = 203
	- New/Good/Normal --> Probation: BC >=10, Margin >=0, WL > 15K(RM)
	- Smart --> Probation: BC >=20, 0<=Margin<=1%, WL <=10K (RM)
	- Risky --> Probation: BC >=20, 0<=Margin<=1%, WL <=15K (RM)
*/

--# Step1. Set value: cust must exist in both CTS and mainDB
declare @CustId INT = 1967881, @SportId INT = 200, @CreatedDate DATE = CAST(GETDATE() AS DATE), @IsApplied BIT = 0, @CreatedTime DATETIME = GETDATE(),
	@PerformanceTime DATETIME = GETDATE(), @CurrentCategoryId SMALLINT = 201, @ScanTaggingType INT = 1;
	
-- declare	@CategoryId SMALLINT = 201,	@TurnoverRM decimal(19,4) = 10123, @WinlossRM decimal(19,4) = -4123, @BetCount bigINT = 9, @ActiveDays INT = 9; -- New(Betcount < 10) 
-- declare	@CategoryId SMALLINT = 202,	@TurnoverRM decimal(19,4) = 1012345, @WinlossRM decimal(19,4) = -6123, @BetCount bigINT = 21, @ActiveDays INT = 11; -- Normal(M=-0.6) 
declare	@CategoryId SMALLINT = 205,	@TurnoverRM decimal(19,4) = 250123, @WinlossRM decimal(19,4) = -10123, @BetCount bigINT = 310, @ActiveDays INT = 11; -- Good (M=4)
-- declare @CategoryId SMALLINT = 206,	@TurnoverRM decimal(19,4) = 101234, @WinlossRM decimal(19,4) = 10123, @BetCount bigINT = 11, @ActiveDays INT = 11; -- Prob (M=15.9)
-- declare	@CategoryId SMALLINT = 203,	@TurnoverRM decimal(19,4) = 10123456, @WinlossRM decimal(19,4) = 16123, @BetCount bigINT = 21, @ActiveDays INT = 11; -- Smart (M=0.16) 
-- declare	@CategoryId SMALLINT = 204,	@TurnoverRM decimal(19,4) = 1012345, @WinlossRM decimal(19,4) = 17123, @BetCount bigINT = 21, @ActiveDays INT = 11; -- Risky (M=1.68)

-- Probation:
	--1. Null/Inactive/New/Good/Normal -> Probation: (Margin=15.9)
-- declare	@CategoryId SMALLINT = 206,	@TurnoverRM decimal(19,4) = 101234, @WinlossRM decimal(19,4) = 10123, @BetCount bigINT = 11, @ActiveDays INT = 11; -- Prob (M=15.9)

	--2. Smart -> Probation: BC=21, WL=5123, TO=1012345 (M=0.5)
-- declare	@CategoryId SMALLINT = 203,	@TurnoverRM decimal(19,4) = 1012345, @WinlossRM decimal(19,4) = 5123, @BetCount bigINT = 21, @ActiveDays INT = 11;

	--3. Risky -> Probation: BC=21, WL=14123, TO=10123456 (M=0.15)
-- declare @CategoryId SMALLINT = 204, @TurnoverRM decimal(19,4) = 10123456, @WinlossRM decimal(19,4) = 14123, @BetCount bigINT = 21, @ActiveDays INT = 11;

/* Pick a random cust
	select ci.* from bodb02.dbo.custinfo (nolock) ci
		 inner join bodb02.dbo.Customer c on c.CustId = ci.CustId
		 inner join bodb02.dbo.Site s on s.site = c.site
	where c.currency not in (20, 27, 28) -- exclude test account
	-- and ci.Enabled = 1
	and c.roleid = 1 -- 1: Member, 2: Agent, 3: Master, 4: Super
	and s.isDeposit=0 --- 1: Licensee/ Deposit, 2: Credit
	order by NEWID(); -- Random
*/

--# Step2. Insert CategoryID to table CustomerClassification
INSERT INTO [bodb_VR2Model].[dbo].[CustomerClassification](CustId,SportId,CategoryId,CreatedDate,IsApplied,CreatedTime,TurnoverRM,WinlossRM,BetCount,ActiveDays,PerformanceTime,CurrentCategoryId,ScanTaggingType)
VALUES (@CustId, @SportId, @CategoryId, @CreatedDate, @IsApplied, @CreatedTime, @TurnoverRM, @WinlossRM, @BetCount, @ActiveDays, @PerformanceTime, @CurrentCategoryId, @ScanTaggingType);

SELECT * FROM bodb_VR2Model.dbo.CustomerClassification (NOLOCK) WHERE CustId = @CustId ORDER BY CreatedTime DESC;
SELECT Username FROM bodb02.dbo.custinfo (NOLOCK) WHERE CustId= @CustId;

--# Step3. Trigger service Insert New: to insert Category to CTS then push CC to maindb
-- URL: http://spu-main-v2.nexdev.net/quartz/Jobs
-- Service: CTS_CustomerClassification_Secondly_NormalAccountInsert_Renovate
-- Check: SELECT IsApplied, * FROM bodb_VR2Model.dbo.CustomerClassification WHERE CustId = 98426571  ORDER BY CreatedTime;

--# Step4. Check CTS Web or table CTS_DataCenter.CTSCustomerClassification
-- SELECT * FROM CTS_DataCenter.CTSCustomerClassification WHERE CustId = 98426571;

--# Step5. Check CC in maindb: TESTDBCUST (10.18.200.54)/acc: sputeam
/* Reset value
UPDATE [CustDB].[dbo].[custInfo] WITH (ROWLOCK,UPDLOCK)
SET CustomerClass = 200, danger = 0, danger2 = 0, danger3 = 0, Danger4 = 0, Danger5 = 0 WHERE custid = 1967881
*/
-- SELECT TOP (1000) [username],[custid],[CustomerClass],[danger2], danger, roleid FROM CustDB.[dbo].[custInfo] (NOLOCK) where CustId = @CustId;

