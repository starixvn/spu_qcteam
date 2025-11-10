-- select top 10 * from bodb02.dbo.VRMemberBigStake v (NOLOCK) order by v.RepUpdateTime desc;

/*
================================================================================
FEATURE #243071 - DATA GENERATION SCRIPT 2: Create DW Performance Data
================================================================================
Purpose: Insert historical performance data directly into DW system
Database: DBWH.bodb_Account (FactCustStatsInfo)
Note: Creates performance data for bet count testing
================================================================================
select * FROM bodb_Account.dbo.FactCustStatsInfo WHERE custid in (187910809,187910810)
select * from bodb02.dbo.VRMemberBigStake WHERE custid in (187910808,187910809,187910810)
select * from bodb_Account.dbo.BigCreditMembersMonitor WHERE custid in (187910808,187910809,187910810)
select * from bodb02.dbo.custinfo where custid in (187909777)

Update bodb_Account.dbo.BigCreditMembersMonitor set createdate = '2025-11-05 00:00:00.000' where   custid in (148628770,148628771,148628772)

DELETE FROM bodb_Account.dbo.FactCustStatsInfo
WHERE custid in (148628770,148628771,148628772)

*/

USE bodb_dwrs
GO

SET NOCOUNT ON

-- ============================================================================
-- INPUT PARAMETERS
-- ============================================================================

DECLARE @CustIds VARCHAR(2000) = '148628770,148628771,148628772'  -- Test CustIDs
DECLARE @TotalBetsPerCust INT = 1                            -- Total bets per customer (will be distributed across days)
DECLARE @DaysToGenerate INT = 1                                  -- Number of days with data
DECLARE @TicketStatus INT = 12                                 --In DW: Valid (3:DRAW , 4: LOSE, 8: WON , 12:HALF LOSE , 13:HALF WON );Invalid (9:Reject , 10: Void, 17: Rejected )
DECLARE @IsDeleteAll INT = 1 
DECLARE @betcount INT = 10000
DECLARE @SportType INT = 1  



DECLARE @EndDate DATE
IF OBJECT_ID('tempdb..#TempBalanceUpDay', 'U') IS NOT NULL 
    DROP TABLE #TempBalanceUpDay

CREATE TABLE #TempBalanceUpDay (BalanceUpDay DATE, MoveBetsDay DATE)

INSERT INTO #TempBalanceUpDay
EXEC bodb02.dbo.Age_SelBalanceUpDay

SELECT @EndDate = MoveBetsDay FROM #TempBalanceUpDay
DROP TABLE #TempBalanceUpDay

DECLARE @StartDate DATE = DATEADD(DAY, -@DaysToGenerate, @EndDate)
DECLARE @TestType TINYINT = 1                                    -- VR Type (1 = All VR sports except E-Sports)

-- Calculate bets per day (distributed evenly)
DECLARE @BetsPerDay INT = @TotalBetsPerCust / @DaysToGenerate
DECLARE @RemainingBets INT = @TotalBetsPerCust % @DaysToGenerate  -- Remainder bets for last day

PRINT '========================================================================'
PRINT 'FEATURE #243071 - DW PERFORMANCE DATA GENERATION'
PRINT '========================================================================'
PRINT 'Test CustIDs: ' + @CustIds
PRINT 'Date Range: ' + CAST(@StartDate AS VARCHAR(20)) + ' to ' + CAST(@EndDate AS VARCHAR(20))
PRINT 'Days to Generate: ' + CAST(@DaysToGenerate AS VARCHAR(10))
PRINT 'Total Bets per Customer: ' + CAST(@TotalBetsPerCust AS VARCHAR(10))
PRINT 'Bets per Day: ' + CAST(@BetsPerDay AS VARCHAR(10)) + ' (+ ' + CAST(@RemainingBets AS VARCHAR(10)) + ' on last day)'
PRINT ''

-- ============================================================================
-- SETUP
-- ============================================================================

IF OBJECT_ID('tempdb..#TestCustIDs', 'U') IS NOT NULL 
    DROP TABLE #TestCustIDs

CREATE TABLE #TestCustIDs (CustID INT, Currency INT, Site VARCHAR(50))

INSERT INTO #TestCustIDs (CustID, Currency, Site)
SELECT c.custid, ci.currency, c.site
FROM bodb02.dbo.Customer c (NOLOCK)
INNER JOIN bodb02.dbo.CustInfo ci (NOLOCK) ON c.custid = ci.custid
WHERE c.custid IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@CustIds, ','))

PRINT '--- Test Customers (with Dynamic Values) ---'
SELECT 
    t.CustID,
    c.Username,
    t.Site,
    t.Currency,
    ex.Currency AS CurrencyName,
    CASE t.Site 
        WHEN 'FUN88' THEN 1046
        WHEN 'W88' THEN 1047
        ELSE 1046
    END AS DynamicSiteID,
    CASE 
        WHEN t.Currency = 2 THEN 1.0
        WHEN t.Currency = 1 THEN 4.5
        WHEN t.Currency = 3 THEN 0.032
        WHEN t.Currency = 4 THEN 0.29
        WHEN t.Currency = 5 THEN 1.52
        WHEN t.Currency = 6 THEN 0.67
        WHEN t.Currency = 7 THEN 0.0016
        WHEN t.Currency = 8 THEN 0.0016
        WHEN t.Currency = 9 THEN 1.07
        ELSE 1.0
    END AS ExchangeRateToRMB
FROM #TestCustIDs t
INNER JOIN bodb02.dbo.Customer c (NOLOCK) ON t.CustID = c.CustID
LEFT JOIN bodb02.dbo.exchange ex (NOLOCK) ON t.Currency = ex.exchangeid

-- ============================================================================
-- PREPARE BigCreditMembersMonitor DATA
-- ============================================================================

-- Delete existing test data from BigCreditMembersMonitor
DELETE FROM bodb_Account.dbo.BigCreditMembersMonitor
WHERE EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = CustID)
  AND Type = @TestType 


-- Get total number of customers
DECLARE @TotalCust INT = (SELECT COUNT(*) FROM #TestCustIDs)
DECLARE @HalfCust INT = @TotalCust / 2

-- Insert test customers into BigCreditMembersMonitor
-- Split customers: Half with Status=0, Half with Status=1
INSERT INTO bodb_Account.dbo.BigCreditMembersMonitor (CustID, Type, FirstBetDate, CreateDate, Status)
SELECT t.CustID, 
       @TestType AS Type,
       CASE 
           WHEN ROW_NUMBER() OVER (ORDER BY t.CustID) <= @HalfCust 
           THEN CAST(GETDATE() AS DATE)                         -- Status=0: FirstBetDate = Today
           ELSE DATEADD(DAY, -10, CAST(GETDATE() AS DATE))      -- Status=1: FirstBetDate 10 days ago
       END AS FirstBetDate,
       CAST(GETDATE() AS DATE) AS CreateDate,                   -- Today's date
       CASE 
           WHEN ROW_NUMBER() OVER (ORDER BY t.CustID) <= @HalfCust 
           THEN 0                                                -- Status=0: First ticket
           ELSE 1                                                -- Status=1: Whitelisted
       END AS Status
FROM #TestCustIDs t


-- Verify BigCreditMembersMonitor data
PRINT '--- BigCreditMembersMonitor Records ---'
SELECT b.CustID, b.Type, b.Status, 
       CASE b.Status 
           WHEN 0 THEN 'First Ticket'
           WHEN 1 THEN 'Whitelisted'
       END AS StatusName,
       b.FirstBetDate, b.CreateDate
FROM bodb_Account.dbo.BigCreditMembersMonitor b (NOLOCK)
WHERE EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = b.CustID)
  AND b.Type = @TestType
ORDER BY b.Status, b.CustID

-- ============================================================================
-- DELETE EXISTING TEST DATA FROM FactCustStatsInfo
-- ============================================================================

DELETE FROM bodb_Account.dbo.FactCustStatsInfo WHERE EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = CustID) 
 and ((TicketStatus = @TicketStatus) or @IsDeleteAll = 1);


-- ============================================================================
-- GENERATE PERFORMANCE DATA (Distributed across days)
-- ============================================================================

PRINT '--- Generating Performance Data ---'

-- Create a proper numbers table for generating multiple bets
DECLARE @MaxBetsPerDay INT = @BetsPerDay + @RemainingBets
IF OBJECT_ID('tempdb..#Numbers', 'U') IS NOT NULL 
    DROP TABLE #Numbers

CREATE TABLE #Numbers (Num INT)
INSERT INTO #Numbers (Num)
SELECT TOP (@MaxBetsPerDay) 
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Num
FROM master.dbo.spt_values v1
CROSS JOIN master.dbo.spt_values v2

DECLARE @CurrentDate DATE = @StartDate
DECLARE @DayCounter INT = 0

WHILE @DayCounter < @DaysToGenerate AND @CurrentDate <= @EndDate
BEGIN
    -- Calculate bets for this day
    DECLARE @BetsThisDay INT = @BetsPerDay
    
    -- Add remaining bets on the last day
    IF @DayCounter = (@DaysToGenerate - 1)
        SET @BetsThisDay = @BetsPerDay + @RemainingBets
    
    -- Insert performance data for each customer (DYNAMIC VALUES from customer data)
    INSERT INTO bodb_Account.dbo.FactCustStatsInfo (SiteID, LiveStatus, LeagueID, BetFromID, MemberCommission,
        RptDate, CustID, CurrencyID, SportType, Bettype, 
        MemberTurnover, MemberWinloss, TicketStatus, BetCount
    )
    SELECT 
        -- DYNAMIC: Get actual SiteID from customer's site
        CASE c.Site 
            WHEN 'FUN88' THEN 1046
            WHEN 'W88' THEN 1047
            ELSE 1046  -- Default to FUN88
        END AS SiteID,
        1 AS LiveStatus,        -- 1=Live, 0=Early
        2 AS LeagueID,          -- Default league (can be made dynamic if needed)
        1 AS BetFromID,         -- 1=Web, 2=Mobile, 3=App
        0 AS MemberCommission,
        @CurrentDate AS RptDate,
        t.CustID,
        t.Currency AS CurrencyID,
        @SportType AS SportType,  
        1 AS Bettype,           -- 1=HDP, 2=OU, 3=1X2
        50000 AS MemberTurnover,
        -10000 AS MemberWinloss,      
        @Ticketstatus AS TicketStatus,
        @betcount AS BetCount 
    FROM #TestCustIDs t
    INNER JOIN bodb02.dbo.Customer c (NOLOCK) ON t.CustID = c.CustID
    CROSS JOIN (SELECT TOP (@BetsThisDay) Num FROM #Numbers) AS Numbers
    
    PRINT 'Day ' + CAST(@DayCounter + 1 AS VARCHAR(10)) + ' (' + CAST(@CurrentDate AS VARCHAR(20)) + '): Generated ' + CAST(@BetsThisDay AS VARCHAR(10)) + ' bets per customer'
    
    -- DYNAMIC: Insert exchange rates for ALL test customer currencies (not just Currency=2)
    INSERT INTO bodb_Account.dbo.tbl_Currency_Daily (ExchangeDate, Currency, Rate, dateupdated)
    SELECT DISTINCT 
        @CurrentDate AS ExchangeDate,
        t.Currency,
        CASE 
            WHEN t.Currency = 2 THEN 1.0      -- RM = 1.0
            WHEN t.Currency = 1 THEN 4.5      -- USD to RM
            WHEN t.Currency = 3 THEN 0.032    -- JPY to RM
            WHEN t.Currency = 4 THEN 0.29     -- THB to RM
            WHEN t.Currency = 5 THEN 1.52     -- SGD to RM
            WHEN t.Currency = 6 THEN 0.67     -- INR to RM
            WHEN t.Currency = 7 THEN 0.0016   -- VND to RM
            WHEN t.Currency = 8 THEN 0.0016   -- IDR to RM
            WHEN t.Currency = 9 THEN 1.07     -- MYR to RM
            ELSE 1.0                           -- Default rate
        END AS Rate,
        GETDATE() AS dateupdated
    FROM #TestCustIDs t
    WHERE NOT EXISTS (
        SELECT TOP 1 1 
        FROM bodb_Account.dbo.tbl_Currency_Daily cd
        WHERE cd.ExchangeDate = @CurrentDate 
              AND cd.Currency = t.Currency
    )

    SET @DayCounter = @DayCounter + 1
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
END

-- Cleanup numbers table
DROP TABLE #Numbers

PRINT ''
PRINT 'Total records generated: ' + CAST(@@ROWCOUNT AS VARCHAR(10))
PRINT ''

-- ============================================================================
-- VERIFY GENERATED DATA
-- ============================================================================
-- Create temp table for Sport-Bettype filtering
IF OBJECT_ID('tempdb..#tmpSportVRBettype', 'U') IS NOT NULL 
    DROP TABLE #tmpSportVRBettype
CREATE TABLE #tmpSportVRBettype (SportType INT, Bettype INT)

INSERT INTO #tmpSportVRBettype (SportType, Bettype)
SELECT Sporttype, Bettype
FROM bodb_account.dbo.DimVRBettype (NOLOCK)
WHERE Sporttype <= 99 AND Sporttype NOT IN (43)



PRINT '--- Verification Summary ---'
SELECT t.CustID, 
       t.Site,
       SUM(dw.BetCount) AS TotalBets,
       SUM(dw.MemberTurnover * c.Rate) AS TotalTurnover,
       SUM(dw.MemberWinloss * c.Rate) AS TotalWinloss,
       MIN(dw.RptDate) AS MinDate,
       MAX(dw.RptDate) AS MaxDate
FROM bodb_Account.dbo.FactCustStatsInfo dw (NOLOCK)
     LEFT JOIN bodb_Account.dbo.tbl_Currency_Daily c WITH (NOLOCK) 
         ON dw.RptDate = c.ExchangeDate AND dw.CurrencyID = c.Currency
     INNER JOIN #TestCustIDs t ON dw.CustID = t.CustID
WHERE dw.RptDate BETWEEN @StartDate AND @EndDate
      AND dw.TicketStatus IN (3, 4, 8, 12, 13)
      AND dw.SportType <= 99 
      AND dw.SportType NOT IN (43) --Not include ESports
      AND EXISTS (SELECT TOP 1 1
                  FROM #tmpSportVRBettype s
                  WHERE s.SportType = dw.SportType
                        AND s.Bettype = dw.Bettype)
GROUP BY t.CustID, t.Site

PRINT ''
PRINT '--- Currency Exchange Rates Inserted ---'
SELECT DISTINCT 
    cd.ExchangeDate,
    cd.Currency,
    ex.Currency AS CurrencyName,
    cd.Rate AS RateToRMB
FROM bodb_Account.dbo.tbl_Currency_Daily cd (NOLOCK)
INNER JOIN #TestCustIDs t ON cd.Currency = t.Currency
LEFT JOIN bodb02.dbo.exchange ex (NOLOCK) ON cd.Currency = ex.exchangeid
WHERE cd.ExchangeDate BETWEEN @StartDate AND @EndDate
ORDER BY cd.ExchangeDate, cd.Currency

PRINT ''
PRINT '--- Verification by Date ---'
SELECT *
FROM bodb_Account.dbo.FactCustStatsInfo f (NOLOCK)
WHERE EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = f.CustID)
 