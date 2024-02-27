#===== EXISTING CATEGORY
-- Step 1: Define parameters
SET 	@CustIDs = '1284,3681780,4504877' /*recommend at least 1 credit & 1 licensee & 1 special site*/
    ,	@CategoryGroup = 201 /*201: New;   202: Normal;   203: Smart;   204: Risky;   205: Good;   206: Probation*/
    ,	@TaggingType = 2 /*0: Normal;   1: Ass with PA;   2: TWGB*/
    , 	@TaggingID = 9 /*0: Normal;   8,10,13: Ass with PA (all category);  7,8,9: TWGB (7,8: Probation,Smart,Risky;   9: New)*/
    ,	@TurnoverRM = 10.000, @WinlossRM = 10.000, @BetCount = 100, @ActiveDays = 10, @PerformanceTime = CURRENT_TIMESTAMP()
    ,	@TWGroupBettingRate = 10, @TWTicketRejectRate = 10, @TWBetCount = 10, @TWDesktopUsageRate = 10 /*Probation, Smart, Risky  (TWGB)*/
	,	@First5TWGBTicketCount = 20, @SportType = 1 /*TWGB - New*/ /*0: mix;   1: soccer;  2: basketball*/
    ,	@CreatedBy = 10278938, @CreatedDate = CURRENT_DATE(), @CreatedTime = CURRENT_TIMESTAMP()  /*starixIT, default value*/
    ; 
    
-- Step 2: Update customer info  
DROP TEMPORARY TABLE IF EXISTS Temp_CustInfo;
CREATE TEMPORARY TABLE Temp_CustInfo (
		CustID BIGINT PRIMARY KEY
    ,	CTSCustID BIGINT
    ,	SubscriberID INT
    ,	CategoryID SMALLINT
    ,	CustomerClass SMALLINT
);

SET @sql = 	CONCAT("INSERT IGNORE INTO Temp_CustInfo (CustID) VALUES ('", REPLACE(@CustIDs, ",", "'),('"),"');");
PREPARE stmt1 FROM @sql;
EXECUTE stmt1;  

UPDATE Temp_CustInfo AS tmp
	INNER JOIN CTS_DataCenter.CTSCustomer AS cus ON cus.CustID = tmp.CustID AND cus.RoleID = 1 /*Only support Member*/
SET tmp.CTSCustID = cus.CTSCustID, tmp.SubscriberID = cus.SubscriberID;

UPDATE Temp_CustInfo AS tmp
	INNER JOIN CTS_DataCenter.CustomerCategory AS c ON c.CategoryGroup = @CategoryGroup AND c.TaggingType = @TaggingType AND c.TaggingID = @TaggingID
SET tmp.CategoryID = c.CategoryID;

-- Step 3: Clean old data
DELETE cc FROM CTS_DataCenter.CTSCustomerClassification AS cc WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = cc.CustID);
DELETE his FROM CTS_DataCenter.CTSCustomerClassification_History AS his WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = his.CustID);
DELETE p FROM CTS_DataCenter.ProbationAccountMonitor AS p WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = p.CustID);

-- Step 4: Generate existing data: CTSCustomerClassification, CTSCustomerClassification_History, ProbationAccountMonitor
INSERT INTO CTS_DataCenter.CTSCustomerClassification (CustID, CTSCustID, SubscriberID, SportGroupID, CategoryID, CreatedDate, CreatedBy, LastScannedDate, SportType) 
SELECT 		tmp.CustID
		, 	tmp.CTSCustID
		, 	tmp.SubscriberID
		, 	200 AS SportGroupID /*Normal group*/
		, 	tmp.CategoryID
		, 	@CreatedTime
		, 	@CreatedBy
		, 	@CreatedDate
		, 	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID = 9 /*New*/ THEN @SportType ELSE NULL END AS SportType 
FROM Temp_CustInfo AS tmp;

INSERT INTO CTS_DataCenter.CTSCustomerClassification_History (CustID, CTSCustID, SportGroupID, CategoryID, TaggingType, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, TWGroupBettingRate, TWTicketRejectRate, TWBetCount, TWDesktopUsageRate, First5TWGBTicketCount, SportType,
TargetCC, IsDataChanged, ActionType, LastModifiedDate, LastModifiedBy, InsertDate) 
SELECT 		tmp.CustID
		, 	tmp.CTSCustID
		, 	200 AS SportGroupID /*Normal group*/
		, 	tmp.CategoryID
        ,	@TaggingType
        ,   @TurnoverRM
        , 	@WinlossRM
        , 	@BetCount
        ,	@ActiveDays
        , 	@PerformanceTime
        , 	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID IN (7,8) /*Probation, Smart, Risky*/ THEN @TWGroupBettingRate ELSE 0 END AS TWGroupBettingRate
        , 	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID IN (7,8) /*Probation, Smart, Risky*/ THEN @TWTicketRejectRate ELSE 0 END AS TWTicketRejectRate
        , 	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID IN (7,8) /*Probation, Smart, Risky*/ THEN @TWBetCount ELSE 0 END AS TWBetCount
        , 	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID IN (7,8) /*Probation, Smart, Risky*/ THEN @TWDesktopUsageRate ELSE 0 END AS TWDesktopUsageRate
        ,	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID = 9 /*New*/ THEN @First5TWGBTicketCount ELSE NULL END AS First5TWGBTicketCount
        , 	CASE WHEN @TaggingType = 2 /*TWGB*/ AND @TaggingID = 9 /*New*/ THEN @SportType ELSE NULL END AS SportType 
        ,	tmp.CustomerClass
        ,	1 AS IsDataChanged /*Show in web*/
        ,	0 AS ActionType /*0: Add, 1: Update*/
		, 	@CreatedDate
		, 	@CreatedBy
		, 	@CreatedDate
FROM Temp_CustInfo AS tmp;

INSERT INTO CTS_DataCenter.ProbationAccountMonitor (CTSCustID, CustID, SportGroupID, TargetCategoryID, FirstMargin, CreatedBy, CreatedDate, CreatedTime, LastScannedDate)
SELECT 		tmp.CTSCustID
		, 	tmp.CustID
		, 	200
		, 	tmp.CategoryID
		, 	(@WinlossRM/@TurnoverRM)*100
		, 	@CreatedBy
		, 	@CreatedDate
		, 	@CreatedTime
		, 	@CreatedDate
FROM Temp_CustInfo AS tmp 
WHERE @CategoryGroup = 206;

-- Step 5: Check result in CTS
SELECT * FROM CTS_DataCenter.CTSCustomerClassification AS cc WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = cc.CustID);
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History AS his WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = his.CustID);
SELECT * FROM CTS_DataCenter.ProbationAccountMonitor AS p WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = p.CustID);

-- Step 6 --> 15: Prepare data in bodb02, bodb_VR2Model
/*File: 2024-02-27_SwitchNormalCategory_Source_bodbVR2Model_bodb02_CustDB.sql*/

-- Step 16: Check new category
SELECT * FROM CTS_DataCenter.CTSCustomerClassification AS cc WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = cc.CustID);
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History AS his WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = his.CustID);
SELECT * FROM CTS_DataCenter.ProbationAccountMonitor AS p WHERE EXISTS (SELECT 1 FROM Temp_CustInfo AS tmp WHERE tmp.CustID = p.CustID);
CALL CTS_DataCenter.CTS_DC_CustClassification_GetCCAndDangerLevel (@CustIDs);

-- Step 17 --> 19: Check data in CustDB
/*File: 2024-02-27_SwitchNormalCategory_Source_bodbVR2Model_bodb02_CustDB.sql*/