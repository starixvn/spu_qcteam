/*
		Created:	20230929@Lisa.Phan	
		Purose:	    Create account with Category: New/Good/Normal/Probation/Smart/Risky -- NOT push CC to maindb
		DB:			CTS_DataCenter
*/ 
#-- 0. Set value for CategoryID, TargetCC
SET @CategoryID = 201, @TargetCC = 200;
-- New: 		CategoryID = 201, CustomerClass = 200
-- Normal:		CategoryID = 202, CustomerClass = 202
-- Good: 		CategoryID = 205, CustomerClass = 201
-- Probation:	CategoryID = 206, CustomerClass = 203
-- Smart:		CategoryID = 203, CustomerClass = 204
-- Risky:		CategoryID = 204, CustomerClass = 205

#-- 1. Pick a cust exist both in CTS and maindb 
SET @CusTID := 51932858, @CTSCustID := 1831891, @SubscriberID := 898203;

/*
	-- pick a random cust which is existing in CTS
	SELECT 	CustID, CTSCustID, SubscriberID
	INTO @CustID, @CTSCustID, @SubscriberID
	FROM CTS_DataCenter.CTSCustomer 
	where CustSubID = 0 and IsInternal = 0 
	and RoleID = 1 -- 1: Member, 2: Agent, 3: Master, 4: Super
	and IsLicensee = 1 -- 1: Deposit/Licensee, 0: Credit
	-- and IsLicenseeBA = 0
	-- and IsLicenseeVIP = 0
	order by RAND() -- random
	limit 1;
*/

SET	
-- CustomerClassification
		@SportGroupID := 200, @CategoryID := @CategoryID, 
        @CreatedDate := current_timestamp(), @CreatedBy := 10278938, 
        @LastModifiedDate:= current_timestamp(), @LastScannedDate := current_date(), 
        @IsFromTVS := 0, @IsFromTW := 0, @ISFromCTS := 1, @IsFromAI := 0, @IsFromImperva := 0,
-- CustomerClassification_History, CustomerClassification_Log
		@TurnoverRM := 0, @WinlossRM := 0, @BetCount := 0, @ActiveDays := 9, 
        @TargetCC := @TargetCC, @SourceTypeID := 1, 
        @FromCategoryID := 201, @ToCategoryID := @CategoryID,
        @IsAppliedCC := 0, @IsDataChanged := 1, @ActionType := 0, @IsAuto := 1, 
        @LastModifiedBy := 10278938, @InsertDate:= TIMESTAMP(Current_Date(), "00:00:00"), 
        @TaggingType := 1, @IsAppliedDangerLevel1 := 0, 
        @TWGroupBettingRate := 0, @TWTicketRejectRate := 0, @TWBetCount := 0, @TWDesktopUsageRate := 0;
#-- 2. Remove special cases:
DELETE FROM CTS_DataCenter.CTSCustomerClassification WHERE CustID = @CustID;
-- DELETE FROM CTS_DataCenter.CTSCustomerClassification_Log WHERE CustID = @CustID;
-- DELETE FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.ProbationAccountMonitor WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.SpecialCustomerClass WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.PinCustomerCategory WHERE CTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.CTSCustomerClassificationVVIP WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.CTSCustomerClassificationQueue  WHERE CustID = @CustID;
DELETE FROM CTS_DataCenter.CustEvidenceAffectedQueueInsert  WHERE CTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.CustEvidence WHERE CTSCustID = @CTSCustID;
DELETE FROM CTS_DataCenter.TaggingExclusion WHERE CTSCustID = @CTSCustID;
-- (Optional) Remove Association (IP/Device/Betting Pattern): 
DELETE FROM CTS_DataCenter.AssociationByIP WHERE ToCustID = @CustID OR FromCustID = @CustID;
DELETE FROM CTS_DataCenter.AssociationByDevice WHERE CTSCUSTID = @CTSCustID;
DELETE FROM CTS_DataCenter.AssociationByAI WHERE ToCustID = @CustID OR FromCustID = @CustID;
DELETE FROM CTS_DataCenter.AssociationGroupByAI WHERE CustID = @CustID ;
       
#--- 3. Insert Category 
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification` 
(`CustID`, `CTSCustID`, `SubscriberID`, `SportGroupID`, `CategoryID`, `CreatedDate`, `CreatedBy`, `LastModifiedDate`, `LastScannedDate`, `IsFromTVS`, `IsFromTW`, `IsFromCTS`, `IsFromAI`, `IsFromImperva`)
VALUES (@CustID, @CTSCustID, @SubscriberID, @SportGroupID, @CategoryID, @CreatedDate, @CreatedBy, @LastModifiedDate, @LastScannedDate , 0, 0, 1, 0, 0);
-- (Optional) Insert Log with performance - show on Web 
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_History` 
(`CustID`, `CTSCustID`, `SportGroupID`, `CategoryID`, `TurnoverRM`, `WinlossRM`, `BetCount`, `ActiveDays`, `TargetCC`, `SourceTypeID`, `FromCategoryID`, `ToCategoryID`, `IsAppliedCC`, `IsDataChanged`, `ActionType`, `IsAuto`, `LastModifiedDate`, `LastModifiedBy`, `InsertDate`, `TaggingType`, `IsAppliedDangerLevel1`, `TWGroupBettingRate`, `TWTicketRejectRate`, `TWBetCount`, `TWDesktopUsageRate`, `IsFromTVS`, `IsFromTW`, `IsFromCTS`, `IsFromAI`, `IsFromImperva`) 
VALUES (@CustID,@CTSCustID,@SportGroupID,@CategoryID,@TurnoverRM,@WinlossRM,@BetCount,@ActiveDays,@TargetCC,@SourceTypeID,@FromCategoryID,@ToCategoryID,@IsAppliedCC,@IsDataChanged,@ActionType,@IsAuto,@LastModifiedDate,@LastModifiedBy,@InsertDate,@TaggingType,@IsAppliedDangerLevel1,@TWGroupBettingRate,@TWTicketRejectRate,@TWBetCount,@TWDesktopUsageRate,@IsFromTVS,@IsFromTW,@IsFromCTS,@IsFromAI,@IsFromImperva);
-- (Optional) Insert Log with performance 
INSERT INTO `CTS_DataCenter`.`CTSCustomerClassification_Log` 
(`CustID`, `CTSCustID`, `SportGroupID`, `CategoryID`, `TurnoverRM`, `WinlossRM`, `BetCount`, `ActiveDays`, `TargetCC`, `SourceTypeID`, `FromCategoryID`, `ToCategoryID`, `IsAppliedCC`, `IsDataChanged`, `ActionType`, `IsAuto`, `LastModifiedDate`, `LastModifiedBy`, `InsertDate`, `TaggingType`, `IsAppliedDangerLevel1`, `TWGroupBettingRate`, `TWTicketRejectRate`, `TWBetCount`, `TWDesktopUsageRate`, `IsFromTVS`, `IsFromTW`, `IsFromCTS`, `IsFromAI`, `IsFromImperva`) 
VALUES (@CustID,@CTSCustID,@SportGroupID,@CategoryID,@TurnoverRM,@WinlossRM,@BetCount,@ActiveDays,@TargetCC,@SourceTypeID,@FromCategoryID,@ToCategoryID,@IsAppliedCC,@IsDataChanged,@ActionType,@IsAuto,@LastModifiedDate,@LastModifiedBy,@InsertDate,@TaggingType,@IsAppliedDangerLevel1,@TWGroupBettingRate,@TWTicketRejectRate,@TWBetCount,@TWDesktopUsageRate,@IsFromTVS,@IsFromTW,@IsFromCTS,@IsFromAI,@IsFromImperva);

SELECT * FROM `CTS_DataCenter`.`CTSCustomerClassification` WHERE CustID = @CustID;
SELECT * FROM `CTS_DataCenter`.`CTSCustomerClassification_History` WHERE CustID = @CustID ORDER BY LastModifiedDate DESC;
SELECT * FROM `CTS_DataCenter`.`CTSCustomerClassification_Log` WHERE CustID = @CustID ORDER BY LastModifiedDate DESC;
#-- 4. If cust is Probation (CategoryID=206) -> Insert into table ProbationAccountMonitor
/*
SET	@TargetCategoryID := @TargetCC, @FirstMargin := 1.1, @CreatedDate := TIMESTAMP(Current_Date(), "00:00:00"), @CreatedTime := current_timestamp(), @LastScannedDate := current_date();
INSERT INTO `CTS_DataCenter`.`ProbationAccountMonitor` 
(`CTSCustID`, `CustID`, `SportGroupID`, `TargetCategoryID`, `FirstMargin`, `CreatedBy`, `CreatedDate`, `CreatedTime`, `LastScannedDate`) 
VALUES (@CTSCustID, @CustID, @SportGroupID, @TargetCategoryID, @FirstMargin, @CreatedBy, @CreatedDate, @CreatedTime,@LastScannedDate);
select * from `CTS_DataCenter`.`ProbationAccountMonitor` where CustID = @CustID;
*/

#-- 5. check on CTS Web:
SELECT Username, CTSCustID, c.* FROM CTS_DataCenter.CTSCustomer c WHERE CustID = @CustID;

