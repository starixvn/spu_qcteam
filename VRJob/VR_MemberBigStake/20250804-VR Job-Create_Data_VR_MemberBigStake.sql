/*
	Created:	20250804@John.Ngo 
	Task :		Create data for VR Job - VR_MemberBigStake
	DB:			MainDB
*/
-- Ref: https://docs.google.com/spreadsheets/d/1ROSuD5rlajTZkeA30QHzJleD61I1Lih4NkupxTHBXKI/edit?gid=225145907#gid=225145907

-- VR Job - VR_MemberBigStake
/*
MemberBigStake API - Stored Procedures
Step 1: Insert Data
SP: Acc_VR_MemberBigStake_Ins
DB: DBCUST.CustDB.wsv_nap

Step 2: Get Performance Data
SP: Task_VRSetting_CheckMemberBigStakePerformance
DB: DBWH.bodb_dwrs.wsv_nap

Step 3: Update First Bet Dates
SP: Acc_VR_MemberBigStake_FirstBetDate_Upd
DB: DBCUST.CustDB.wsv_nap

Process: Groups by bet date, chunks of 500 customers
Step 4: Update Status
SP: Acc_VR_MemberBigStake_WhiteList_Upd
DB: DBCUST.CustDB.wsv_nap

Process: Chunks of 500 customers, XML format
Step 5: Get Email Data
SP: Acc_Rpt_Automail_BigCreditMembers
DB: DBWH.bodb_dwrs.wsv_nap

Step 6: Send Notifications
Action: Email generation and sending

Process: Uses email templates, Telegram notifications
Step 7: Logging
Action: Log completion and results
*/

--------------------------------------------------- Script Create data ---------------------------------------------------
/*
=============================================================================
Feature #150298 - VR Member Big Stake Test Data Generation Script 
=============================================================================
Purpose: Generate comprehensive test data for ALL logical paths in Acc_VR_MemberBigStake_Ins:

✅ Case 1: Daily Member Scan (Current Date - 1)
   - Scan members created on current date - 1 and created date > release date
   - If member doesn't exist in VRMemberBigStake → Insert with FirstBetDate = NULL, Status = 0
   - Log: "Big Given Credit Member - Put On Queue"

✅ Case 2: High VR Immediate Whitelist  
   - Check if member soccer HDP VR >= site value → Whitelist immediately
   - Log: "Whitelist Big Given Credit Member - Reason: High VR"
   
✅ Case 3: First Ticket Processing (FirstBetDate = NULL)
   - Check if member has Won/Lost/Drawn ticket on current date-1
   - Sport: Sportsbook excluding E-Sports (updated from excluding E-Sports)
   - Bet type: Apply virtual rate
   - If credit < site threshold → Whitelist (Status = 1), Log: "Reason: Credit"
   - If not → Set FirstBetDate = ticket's winlostdate, Log: "Big Given Credit Member - First Ticket"
   
✅ Case 4: 7+ Days Performance Check (FirstBetDate != NULL)
   - If current date - FirstBetDate >= 7 days
   - Calculate winloss: Sportsbook excluding E-Sports, VR Applied Bet Types, from member created date
   - If winloss <= -200K RM → Whitelist (Status = 1), Log: "Reason: Winloss"

🧾 Updated Business Logic:
   - Daily job at 9am GMT+8 / 9pm GMT-4
   - Sport exclusion: Only E-Sports (removed Basketball exclusion)
   - Enhanced logging with specific reasons
   - High VR immediate processing

Database: DBCUST.CustDB / DBWH.bodb_dwrs
Author: 
Date: 2025-07-29
=============================================================================
*/

USE [CustDB]
GO

-- Enable Test Mode
DECLARE @TestCurrency INT = -1  -- '-1' All currency
DECLARE @TestType TINYINT = 1 -- All VR sports except Esports

PRINT '=== COMPREHENSIVE TEST DATA FOR Acc_VR_MemberBigStake_Ins ==='
PRINT 'Test Type: ' + CAST(@TestType AS VARCHAR(5))
PRINT 'Test Currency: ' + CAST(@TestCurrency AS VARCHAR(5))

-- Get all site configurations for comprehensive testing
IF OBJECT_ID ( 'tempdb..#tmpAllSiteConfigs', 'U') IS NOT NULL DROP TABLE #tmpAllSiteConfigs
CREATE TABLE #tmpAllSiteConfigs(Site VARCHAR(10), Type TINYINT, Credit MONEY, StakeRM MONEY, VRValue SMALLMONEY, ReleasedDate DATETIME)
INSERT INTO #tmpAllSiteConfigs 
SELECT Site, Type, Credit, StakeRM, VRValue, ReleasedDate FROM dbo.f_GetVRBigStakeConfig(NULL) 
WHERE Type = @TestType

-- Display site configurations
SELECT 'Site Configurations' AS Info, * FROM #tmpAllSiteConfigs ORDER BY Site
-- =============================================================================
-- STEP 1: SELECT EXISTING CUSTOMERS FOR COMPREHENSIVE TESTING
-- =============================================================================

PRINT CHAR(13) + '=== STEP 1: SELECTING EXISTING CUSTOMERS FOR ALL TEST CASES ==='

-- Customer selection strategy: Get existing customers from different sites for comprehensive testing
IF OBJECT_ID ( 'tempdb..#tmpTestCustomers', 'U') IS NOT NULL DROP TABLE #tmpTestCustomers
CREATE TABLE #tmpTestCustomers (
	CustID INT,
	Username VARCHAR(30),
	Site VARCHAR(10),
	Currency INT,
	Credit MONEY,
	actualrate FLOAT,
	CreditRM MONEY,
	SiteConfig_CreditRM MONEY,
	CreateDate DATETIME,
	SeqNo TINYINT,
	CurrentVR SMALLMONEY,
	TestCase VARCHAR(50)
)

-- Case 1: New members created yesterday - Should be inserted to queue
INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
SELECT TOP 3 
    c.CustID,
    c.Username,
    c.Site,
    c.Currency,
    ci.credit,
	ex.actualrate,
	ci.credit*ex.actualrate,
	cfg.Credit,
    c.CreatDate,
    ISNULL(cvs.SeqNo, 1) AS SeqNo,
    ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 0.85) AS CurrentVR,
    'Case1-NewMember_Queue' AS TestCase
FROM Customer c WITH(NOLOCK)
    INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
	LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
    LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
    LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
        AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
    INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
WHERE c.RoleID = 1 
    AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
    AND c.CreatDate >= cfg.ReleasedDate
    AND c.CreatDate BETWEEN DATEADD(hh, -25, GETDATE()) AND GETDATE() -- 25-hour window
    AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
    AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers)
ORDER BY ci.RepUpdateTime, c.CreatDate

-- Case 2: High VR members - Should be whitelisted immediately  
INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
SELECT TOP 2 
    c.CustID,
    c.Username,
    c.Site,
    c.Currency,
    ci.credit,
	ex.actualrate,
	ci.credit*ex.actualrate,
	cfg.Credit,
    c.CreatDate,
    ISNULL(cvs.SeqNo, 1) AS SeqNo,
    ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 1.10) AS CurrentVR, -- High VR for immediate whitelist
    'Case2-HighVR_ImmediateWhitelist' AS TestCase
FROM Customer c WITH(NOLOCK)
    INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
	LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
    LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
    LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
        AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
    INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
WHERE c.RoleID = 1 
    AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
    AND c.CreatDate >= cfg.ReleasedDate
    AND c.CreatDate BETWEEN DATEADD(hh, -25, GETDATE()) AND GETDATE() -- 25-hour window
    AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
    AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers) -- Exclude already selected customers
ORDER BY ci.RepUpdateTime, c.CreatDate

-- Case 3: First ticket processing (FirstBetDate = NULL) - Credit-based whitelist
INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
SELECT TOP 2 
    c.CustID,
    c.Username,
    c.Site,
    c.Currency,
    ci.credit,
	ex.actualrate,
	ci.credit*ex.actualrate,
	cfg.Credit,
    c.CreatDate,
    ISNULL(cvs.SeqNo, 1) AS SeqNo,
    ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 0.90) AS CurrentVR,
    'Case3-FirstTicket_CreditWhitelist' AS TestCase
FROM Customer c WITH(NOLOCK)
    INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
	LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
    LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
    LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
        AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
    INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
WHERE c.RoleID = 1 
    AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
    AND c.CreatDate >= cfg.ReleasedDate
    AND c.CreatDate BETWEEN DATEADD(hh, -25, GETDATE()) AND GETDATE() -- 25-hour window
    AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
    AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers) -- Exclude already selected customers
ORDER BY ci.RepUpdateTime, c.CreatDate

-- Case 4: 7+ days performance check (FirstBetDate != NULL) - Performance-based whitelist
INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
SELECT TOP 2 
    c.CustID,
    c.Username,
    c.Site,
    c.Currency,
    ci.credit,
	ex.actualrate,
	ci.credit*ex.actualrate,
	cfg.Credit,
    c.CreatDate,
    ISNULL(cvs.SeqNo, 1) AS SeqNo,
    ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 0.95) AS CurrentVR,
    'Case4-7Days_PerformanceWhitelist' AS TestCase
FROM Customer c WITH(NOLOCK)
    INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
	LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
    LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
    LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
        AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
    INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
WHERE c.RoleID = 1 
    AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
    AND c.CreatDate >= cfg.ReleasedDate
    AND c.CreatDate BETWEEN DATEADD(hh, -25, GETDATE()) AND GETDATE() -- 25-hour window
    AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
    AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers) -- Exclude already selected customers
ORDER BY ci.RepUpdateTime, c.CreatDate

-- Verify customer selection
DECLARE @CustomerCount INT = (SELECT COUNT(*) FROM #tmpTestCustomers)
IF @CustomerCount < 10
BEGIN
    PRINT 'WARNING: Not enough customers found with recent CreatDate (25 hours). Found: ' + CAST(@CustomerCount AS VARCHAR(10)) + '. Using fallback logic...'
    
    -- Clear existing selections
    DELETE FROM #tmpTestCustomers
    
    -- Fallback: Get any available customers without CreatDate restriction
    -- Case 1: New members for queue - fallback
	INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
	SELECT TOP 3 
		c.CustID,
		c.Username,
		c.Site,
		c.Currency,
		ci.credit,
		ex.actualrate,
		ci.credit*ex.actualrate,
		cfg.Credit,
		c.CreatDate,
        ISNULL(cvs.SeqNo, 1) AS SeqNo,
        ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 0.85) AS CurrentVR,
        'Case1-NewMember_Queue' AS TestCase
    FROM Customer c WITH(NOLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
		LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
        LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
        LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
            AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
        INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
    WHERE c.RoleID = 1 
        AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
        AND c.CreatDate >= cfg.ReleasedDate
        AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
    ORDER BY ci.RepUpdateTime, c.CreatDate

    -- Case 2: High VR members for immediate whitelist - fallback
	INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
	SELECT TOP 2 
		c.CustID,
		c.Username,
		c.Site,
		c.Currency,
		ci.credit,
		ex.actualrate,
		ci.credit*ex.actualrate,
		cfg.Credit,
		c.CreatDate,
        ISNULL(cvs.SeqNo, 1) AS SeqNo,
        ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 1.10) AS CurrentVR,
        'Case2-HighVR_ImmediateWhitelist' AS TestCase
    FROM Customer c WITH(NOLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
		LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
        LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
        LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
            AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
        INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
    WHERE c.RoleID = 1 
        AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
        AND c.CreatDate >= cfg.ReleasedDate
        AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
        AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers)
    ORDER BY ci.RepUpdateTime, c.CreatDate

    -- Case 3: First ticket processing for credit whitelist - fallback
	INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
	SELECT TOP 2 
		c.CustID,
		c.Username,
		c.Site,
		c.Currency,
		ci.credit,
		ex.actualrate,
		ci.credit*ex.actualrate,
		cfg.Credit,
		c.CreatDate,
        ISNULL(cvs.SeqNo, 1) AS SeqNo,
        ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 0.90) AS CurrentVR,
        'Case3-FirstTicket_CreditWhitelist' AS TestCase
    FROM Customer c WITH(NOLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
		LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
        LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
        LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
            AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
        INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
    WHERE c.RoleID = 1 
        AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
        AND c.CreatDate >= cfg.ReleasedDate
        AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
        AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers)
    ORDER BY ci.RepUpdateTime, c.CreatDate

    -- Case 4: 7+ days performance check for performance whitelist - fallback
	INSERT INTO #tmpTestCustomers (CustID, Username, Site, Currency, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CreateDate, SeqNo, CurrentVR, TestCase)
	SELECT TOP 2 
		c.CustID,
		c.Username,
		c.Site,
		c.Currency,
		ci.credit,
		ex.actualrate,
		ci.credit*ex.actualrate,
		cfg.Credit,
		c.CreatDate,
        ISNULL(cvs.SeqNo, 1) AS SeqNo,
        ISNULL(dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID), 0.95) AS CurrentVR,
        'Case4-7Days_PerformanceWhitelist' AS TestCase
    FROM Customer c WITH(NOLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
		LEFT JOIN dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid
        LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
        LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
            AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
        INNER JOIN #tmpAllSiteConfigs cfg ON c.Site = cfg.Site
    WHERE c.RoleID = 1 
        AND (@TestCurrency = -1 OR c.Currency = @TestCurrency)
        AND c.CreatDate >= cfg.ReleasedDate
        AND NOT EXISTS (SELECT 1 FROM VRMemberBigStake vr WHERE vr.CustID = c.CustID AND vr.Type = @TestType)
        AND c.CustID NOT IN (SELECT DISTINCT CustID FROM #tmpTestCustomers)
    ORDER BY ci.RepUpdateTime, c.CreatDate

    -- Update CreateDate for fallback customers to make them appear recent
    UPDATE c SET CreatDate = DATEADD(hh, -24, GETDATE())
    FROM Customer c 
    INNER JOIN #tmpTestCustomers tc ON c.CustID = tc.CustID
    
    PRINT 'Fallback logic completed. Updated CreatDate for selected customers.'
        END
ELSE
    PRINT 'Found enough customers with recent CreatDate: ' + CAST(@CustomerCount AS VARCHAR(10)) + '. No CreatDate update needed.'

-- Display selected test customers
-- SELECT STRING_AGG(CAST(CustID AS VARCHAR), ',') AS ListCustID FROM #tmpTestCustomers;

SELECT 'Selected Test Customers' AS Info, 
       CustID, Username, Currency, Site, TestCase, Credit, actualrate, CreditRM, SiteConfig_CreditRM, CurrentVR
FROM #tmpTestCustomers 
ORDER BY TestCase, CustID

-- =============================================================================
-- STEP 2: SETUP TEST DATA FOR EACH LOGICAL CASE
-- =============================================================================

PRINT CHAR(13) + '=== STEP 2: CONFIGURING TEST DATA FOR ALL ACC_VR_MEMBERBIGSTAKE_INS CASES ==='
-- Check
-- SELECT TOP 1000 * FROM VRMemberBigStake WHERE CustID IN (SELECT CustID FROM #tmpTestCustomers) AND Type = 1
-- Clean up any existing test records first
DELETE FROM VRMemberBigStake WHERE CustID IN (SELECT CustID FROM #tmpTestCustomers) AND Type = @TestType
PRINT 'Cleaned up existing test records'

-- =============================================================================
-- ✅ CASE 1A: NEW MEMBERS CREATED YESTERDAY - SHOULD BE QUEUED
-- Update bitmapVirtual only SportType = 1 AND BetType = 1 AND IsLive = 1
-- Business Rule: Scan members created on current date - 1, insert with Status = 0, FirstBetDate = NULL
-- =============================================================================
/* Show BIN val
DECLARE @VirtualMultiplier FLOAT = 0.8  
SELECT CONVERT(VARBINARY(64), (  
    SELECT CONVERT(VARCHAR, CAST(CASE WHEN CAST(@VirtualMultiplier * 100 AS INT) > 200 THEN ((CAST(@VirtualMultiplier * 100 AS INT) - 200) / 5 + 200) 
								 ELSE CAST(@VirtualMultiplier * 100 AS INT) END AS BINARY(1)), 2)
    FOR XML PATH ('')), 2) AS Val
*/
PRINT CHAR(13) + '=== CASE 1: NEW MEMBERS CREATED YESTERDAY - PUT ON QUEUE ==='

-- Configure members created yesterday for queue insertion
UPDATE ci SET ci.Credit = 250000 -- Medium credit
FROM CustInfo ci 
INNER JOIN #tmpTestCustomers tc ON ci.CustID = tc.CustID
WHERE tc.TestCase = 'Case1-NewMember_Queue'

-- Set VR = 0.85 (85% = 85 decimal = 0x55 hex) for normal queue processing
-- Position: profileID=2, seqNo=1 -> byte position 2 (3rd byte)
UPDATE cvs SET bitmapVirtual = 0x0055000000000000000000000000000000000000000000000000000000000000, RepUpdateTime = GETDATE()
FROM CustVirtualSetting cvs 
INNER JOIN #tmpTestCustomers tc ON cvs.CustID = tc.CustID
WHERE tc.TestCase = 'Case1-NewMember_Queue'

-- Insert VR setting if not exists
INSERT INTO CustVirtualSetting (CustID, SeqNo, bitmapVirtual, RepUpdateTime)
SELECT tc.CustID, 1, 0x0055000000000000000000000000000000000000000000000000000000000000, GETDATE()
FROM #tmpTestCustomers tc
WHERE tc.TestCase = 'Case1-NewMember_Queue'
    AND NOT EXISTS (SELECT 1 FROM CustVirtualSetting WHERE CustID = tc.CustID)

PRINT 'Case 1: New members created yesterday configured and queued'
PRINT 'Expected Result: Should be inserted into VRMemberBigStake with Status = 0, FirstBetDate = NULL'
PRINT 'Expected Log: Big Given Credit Member - Put On Queue'

-- =============================================================================
-- ✅ CASE 1B: HIGH VR MEMBERS - IMMEDIATE WHITELIST
-- Business Rule: Check if member soccer HDP VR >= site value → Whitelist immediately with reason 'High VR'
-- =============================================================================

PRINT CHAR(13) + '=== CASE 2: HIGH VR MEMBERS - IMMEDIATE WHITELIST ==='

-- Configure members with high VR for immediate whitelist
UPDATE ci SET ci.Credit = 200000 -- Medium credit
FROM CustInfo ci 
INNER JOIN #tmpTestCustomers tc ON ci.CustID = tc.CustID
WHERE tc.TestCase = 'Case2-HighVR_ImmediateWhitelist'

-- Set VR = 1.10 (110% = 110 decimal = 0x6E hex) - above site threshold for immediate whitelist
-- Position: profileID=2, seqNo=1 -> byte position 2 (3rd byte)
UPDATE cvs SET bitmapVirtual = 0x006E000000000000000000000000000000000000000000000000000000000000, RepUpdateTime = GETDATE()
FROM CustVirtualSetting cvs 
INNER JOIN #tmpTestCustomers tc ON cvs.CustID = tc.CustID
WHERE tc.TestCase = 'Case2-HighVR_ImmediateWhitelist'

-- Insert VR setting if not exists
INSERT INTO CustVirtualSetting (CustID, SeqNo, bitmapVirtual, RepUpdateTime)
SELECT tc.CustID, 1, 0x006E000000000000000000000000000000000000000000000000000000000000, GETDATE()
FROM #tmpTestCustomers tc
WHERE tc.TestCase = 'Case2-HighVR_ImmediateWhitelist'
    AND NOT EXISTS (SELECT 1 FROM CustVirtualSetting WHERE CustID = tc.CustID)

PRINT 'Case 2: High VR members configured and immediately whitelisted'
PRINT 'Expected Result: Should be inserted and immediately whitelisted (Status = 1) due to High VR'
PRINT 'Expected Log: Whitelist Big Given Credit Member - Reason: High VR'

-- =============================================================================
-- ✅ CASE 3: FIRST TICKET PROCESSING (FirstBetDate = NULL) - CREDIT-BASED WHITELIST
-- Each members in VRMemberBigStake with Status = 1 (Whitelisted) "Status <> 1 (not whitelisted)"
-- Business Rule: FirstBetDate = NULL, has ticket on current date-1, if credit < threshold → Whitelist
-- =============================================================================

PRINT CHAR(13) + '=== CASE 3: FIRST TICKET PROCESSING - CREDIT-BASED WHITELIST ==='

-- Configure customers with low credit for credit-based whitelist
UPDATE ci SET ci.Credit = ROUND((SiteConfig_CreditRM/tc.actualrate),0) + 100 -- CreditRM >= SiteConfig_CreditRM
FROM CustInfo ci 
	INNER JOIN #tmpTestCustomers tc ON ci.CustID = tc.CustID
WHERE tc.TestCase = 'Case3-FirstTicket_CreditWhitelist'

-- Set VR = 0.90 (90% = 90 decimal = 0x5A hex) for test customers - below site VR threshold
-- Position: profileID=2, seqNo=1 -> byte position 2 (3rd byte)
UPDATE cvs SET bitmapVirtual = 0x005A000000000000000000000000000000000000000000000000000000000000, RepUpdateTime = GETDATE()
FROM CustVirtualSetting cvs 
INNER JOIN #tmpTestCustomers tc ON cvs.CustID = tc.CustID
WHERE tc.TestCase = 'Case3-FirstTicket_CreditWhitelist'

-- Insert VR setting if not exists
INSERT INTO CustVirtualSetting (CustID, SeqNo, bitmapVirtual, RepUpdateTime)
SELECT tc.CustID, 1, 0x005A000000000000000000000000000000000000000000000000000000000000, GETDATE()
FROM #tmpTestCustomers tc
WHERE tc.TestCase = 'Case3-FirstTicket_CreditWhitelist'
    AND NOT EXISTS (SELECT 1 FROM CustVirtualSetting WHERE CustID = tc.CustID)

PRINT 'Case 3: First ticket processing customers configured for credit-based whitelist'
PRINT 'Expected Result: Should be whitelisted (Status = 1) due to Credit < Site threshold'
PRINT 'Expected Log: Whitelist Big Given Credit Member - Reason: Credit'

-- =============================================================================
-- ✅ CASE 4: 7+ DAYS PERFORMANCE CHECK (FirstBetDate != NULL) - PERFORMANCE-BASED WHITELIST
-- Business Rule: FirstBetDate != NULL, current date - FirstBetDate >= 7, WinLoss <= -200K RM → Whitelist
-- Sport: Sportsbook excluding E-Sports (updated from excluding Basketball and E-Sports)
-- =============================================================================

PRINT CHAR(13) + '=== CASE 4: 7+ DAYS PERFORMANCE CHECK - PERFORMANCE WHITELIST ==='

-- Configure customers with high credit but poor performance
UPDATE ci SET Credit = 400000
FROM CustInfo ci 
INNER JOIN #tmpTestCustomers tc ON ci.CustID = tc.CustID
WHERE tc.TestCase = 'Case4-7Days_PerformanceWhitelist'

-- Set VR = 0.95 (95% = 95 decimal = 0x5F hex) for test customers - below site VR threshold
-- Position: profileID=2, seqNo=1 -> byte position 2 (3rd byte)
UPDATE cvs SET bitmapVirtual = 0x005F000000000000000000000000000000000000000000000000000000000000, RepUpdateTime = GETDATE()
FROM CustVirtualSetting cvs 
INNER JOIN #tmpTestCustomers tc ON cvs.CustID = tc.CustID
WHERE tc.TestCase = 'Case4-7Days_PerformanceWhitelist'

-- Insert VR setting if not exists
INSERT INTO CustVirtualSetting (CustID, SeqNo, bitmapVirtual, RepUpdateTime)
SELECT tc.CustID, 1, 0x005F000000000000000000000000000000000000000000000000000000000000, GETDATE()
FROM #tmpTestCustomers tc
WHERE tc.TestCase = 'Case4-7Days_PerformanceWhitelist'
    AND NOT EXISTS (SELECT 1 FROM CustVirtualSetting WHERE CustID = tc.CustID)

PRINT 'Case 4: 7+ days performance check customers configured for performance-based whitelist'
PRINT 'Expected Result: Should be whitelisted (Status = 1) due to WinLoss <= -200K RM'
PRINT 'Expected Log: Whitelist Big Given Credit Member - Reason: Winloss'
PRINT 'Note: WinLoss calculated from Sportsbook excluding E-Sports (updated exclusion)'

-- Initial 'FirstBetDate != NULL, current date - FirstBetDate >= 7'
INSERT INTO dbo.VRMemberBigStake(CustID, Type, FirstBetDate, Status)  
SELECT tc.CustID, 1, GETDATE()-8, 0 FROM #tmpTestCustomers tc -- GETDATE()-7
WHERE tc.TestCase = 'Case4-7Days_PerformanceWhitelist'
-- SELECT DATEDIFF(DAY, GETDATE()-7, GETDATE()) -- SELECT DATEDIFF(DAY, FirstBetDate, Today) >= 7  

-- =============================================================================
-- STEP 3: TEST DATA GENERATION COMPLETED
-- =============================================================================
-- EXEC Acc_VR_MemberBigStake_Ins @IsTest = 1

-- Check
-- DELETE FROM VRMemberBigStake
-- SELECT TOP 1000 * FROM dbo.VRMemberBigStake vm (NOLOCK)

SELECT TOP 1000 vm.*, tc.*, ci.credit AS 'CustInfo.Credit' FROM dbo.VRMemberBigStake vm (NOLOCK)
	INNER JOIN #tmpTestCustomers tc (NOLOCK) ON vm.CustID = tc.CustID 
	INNER JOIN CustInfo ci (NOLOCK) ON ci.CustID = tc.CustID
WHERE vm.Type = 1
GO

-- Show data update
SELECT cvs.custid, ci.credit,
       pvs.sporttype AS '@sporttype',  
       pvs.bettype AS '@bettype', 
       pvs.islive AS '@islive',
       dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID)  AS '@VirtualMultiplier',
	   (dbo.f_GetVirtualSetting(cvs.bitmapVirtual,pvs.profileID))*100-100 AS 'virtualMultiplierPer',
	   cvs.bitmapVirtual
FROM   dbo.CustVirtualSetting AS cvs WITH(NOLOCK)  
   INNER JOIN dbo.ProfileVirtualSetting AS pvs WITH(NOLOCK) ON  cvs.seqNo = pvs.seqNo
   INNER JOIN #tmpTestCustomers tc ON tc.CustID = cvs.custid
   LEFT JOIN dbo.CustInfo ci ON ci.custid = tc.CustID
WHERE pvs.isActive = 1  and pvs.sporttype = 1 AND pvs.bettype = 1 -- AND pvs.islive = 1
order by cvs.custid, pvs.sporttype 

SELECT 'Selected Test Customers' AS Info, 
       c.CustID, c.Username, c.Currency, c.Site, c.TestCase, c.Credit, i.credit AS UpdatedCredit, c.actualrate, c.CreditRM, i.credit*c.actualrate AS UpdatedCreditRM , c.SiteConfig_CreditRM, c.CurrentVR,
	   dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID) AS UpdatedVR
FROM #tmpTestCustomers c
	LEFT JOIN custInfo i WITH(NOLOCK) ON c.CustID = i.CustID
	LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
    LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
            AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
ORDER BY c.TestCase, c.CustID

/*
SELECT 'Selected Test Customers' AS Info, 
       c.CustID, c.Username, c.Currency, c.Site, c.TestCase, c.Credit, c.actualrate, c.CreditRM, c.SiteConfig_CreditRM, c.CurrentVR,
	   dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID) AS UpdatedVR
FROM #tmpTestCustomers c
	LEFT JOIN CustVirtualSetting cvs WITH(NOLOCK) ON c.CustID = cvs.CustID AND cvs.SeqNo = 1
    LEFT JOIN ProfileVirtualSetting pvs WITH(NOLOCK) ON cvs.SeqNo = pvs.SeqNo 
            AND pvs.SportType = 1 AND pvs.BetType = 1 AND pvs.IsLive = 1
ORDER BY c.TestCase, c.CustID

EXEC bodb_dwrs.dbo.Task_VRSetting_CheckMemberBigStakePerformance @IsTest = 1

SELECT TOP 1000 bm.*, ci.username, ci.currency FROM bodb_Account.dbo.BigCreditMembersMonitor bm
	INNER JOIN bodb02.dbo.CustInfo ci (NOLOCK) ON ci.CustID = bm.CustID 
WHERE bm.Type = 1
*/

--------------------------- Script case 3 ---------------------------

/* 'Case3-FirstTicket_CreditWhitelist'
- Tạo Match Completed - Yesterday / Insert Bettrans - Yesterday
- Select First bet date đúng logic (Winlostdate = current date - 1 ...)
*/
-- Replace with your custids from 'Case3-FirstTicket_CreditWhitelist'
DECLARE @listOfCustID VARCHAR(MAX) = '187909777,187910809,187909775,187910769'

-- Main query to get first bet date for given customer IDs
DECLARE @sqlCommand VARCHAR(MAX)

IF (ISNULL(@listOfCustID, '') <> '')
BEGIN
    SELECT @sqlCommand = '
    SELECT 
        b.custid AS CustID, 
        MIN(b.winlostdate) AS FirstBetDate,
        COUNT(*) AS TotalBets
    FROM bodb02.dbo.bettrans b (NOLOCK)
         INNER JOIN bodb02.dbo.match m (NOLOCK) ON b.matchid = m.matchid
    WHERE b.custid IN (' + @listOfCustID + ')
          AND b.statusid IN (111, 112, 113) -- Only settled bets
          AND m.sporttype <= 99 
          AND m.sporttype NOT IN (43) -- Exclude ESports
    GROUP BY b.custid
    ORDER BY b.custid'

    -- Execute the dynamic SQL
    EXEC (@sqlCommand)
END
ELSE
BEGIN
    PRINT 'No customer IDs provided'
END

-- SELECT TOP 100 * FROM bodb_Account.dbo.BigCreditMembersMonitor (NOLOCK) WHERE CustID IN (SELECT value FROM STRING_SPLIT(@listOfCustID, ','));

--------------------------- Script case 4 ---------------------------

/*
=============================================================================
WinLoss Performance Data Initialization
=============================================================================
Purpose: Initialize ONLY WinLoss performance data scenarios (ko dùng currency test - do SPs exclude)
         for Task_VRSetting_CheckMemberBigStakePerformance.sql testing

Focus Areas:
✅ WinLoss Performance Data (FactCustStatsInfo + BetTrans). Script only create data on FactCustStatsInfo

Database: DBWH.bodb_dwrs (FactCustStatsInfo) / CustDB.bodb02 (BetTrans)
Author:
Date: 2025-07-29
Feature: #150298 - VR Member Big Stake Testing
=============================================================================
*/

/* 'Case4-7Days_PerformanceWhitelist'
- Muốn check perf cả FactCustStatsInfo + BetTrans
- Tạo Match Completed <= Yesterday / Insert Bettrans <= Yesterday
*/
USE [bodb_dwrs] -- Start with DW database for FactCustStatsInfo
GO

SET NOCOUNT ON

-- Replace with your custids from 'Case4-7Days_PerformanceWhitelist'
DECLARE @CustIDs VARCHAR(MAX) = '187909775,187910769'

IF OBJECT_ID ('tempdb..#tmpCustIDList', 'U') IS NOT NULL DROP TABLE #tmpCustIDList
CREATE TABLE #tmpCustIDList(CustId BIGINT);
INSERT INTO  #tmpCustIDList (CustId) 
SELECT DISTINCT CAST(value AS BIGINT) CustId 
FROM STRING_SPLIT(@CustIDs, ',');


-- Get MoveBetsDay for date calculations
DECLARE @MoveBetsDay DATE
SELECT @MoveBetsDay = MoveBetsDay
FROM OPENQUERY(DBACC,'EXEC bodb02.dbo.Age_SelBalanceUpDay')

-- Performance Thresholds
DECLARE @PerformanceThreshold_200K DECIMAL(19,4) = -200000.0 -- -200K RM WL threshold

-- Test Customer Definitions - Focus on WinLoss Performance & GivenCredit Scenarios
IF OBJECT_ID ( 'tempdb..#tmpTestCustomers', 'U') IS NOT NULL DROP TABLE #tmpTestCustomers
CREATE TABLE #tmpTestCustomers (
    CustID INT,
    CurrencyID INT,
    SiteID VARCHAR(50),
    MemberWinlossRM DECIMAL(19,4)
)

-- WINLOSS PERFORMANCE
INSERT INTO #tmpTestCustomers (CustID, CurrencyID, SiteID, MemberWinlossRM)
SELECT c.CustID, c.Currency, c.Site, 280000
FROM bodb02.dbo.Customer c WITH(NOLOCK)
    INNER JOIN bodb02.dbo.CustInfo ci WITH(NOLOCK) ON c.CustID = ci.CustID
	INNER JOIN #tmpCustIDList tc WITH(NOLOCK) ON c.CustID = tc.CustID
	LEFT JOIN bodb02.dbo.exchange ex (NOLOCK) ON c.currency = ex.exchangeid

-- =============================================================================
-- STEP 1: CREATE HISTORICAL PERFORMANCE DATA (FactCustStatsInfo) 
-- =============================================================================
PRINT CHAR(13) + '=== STEP 1: CREATING HISTORICAL PERFORMANCE DATA (FactCustStatsInfo) ==='

DELETE f FROM bodb_account.dbo.FactCustStatsInfo f WITH(ROWLOCK)
	INNER JOIN #tmpCustIDList tmp ON tmp.CustId = f.CustId
-- Insert complete FactCustStatsInfo records with all required columns
INSERT INTO bodb_Account.dbo.FactCustStatsInfo (
    RptDate, SportType, SiteID, BetType, TicketStatus, LiveStatus, LeagueID, 
    CurrencyID, BetFromID, CustID, MemberTurnover, MemberWinloss, MemberCommission, BetCount
)
SELECT 
    DATEADD(DAY, -30, @MoveBetsDay) AS RptDate, -- 30 days ago for historical data
    1 AS SportType, -- Soccer (main VR sport)
    s.SiteID, -- Get SiteID from site table to avoid NULL
    1 AS BetType, -- HDP (main VR bet type)
    3 AS TicketStatus, -- Settled status
    1 AS LiveStatus, -- Live status
    0 AS LeagueID, -- Default league
    tc.CurrencyID,
    1 AS BetFromID, -- Default bet from
    tc.CustID,
    ABS(tc.MemberWinlossRM * 5) AS MemberTurnover, -- Turnover
    tc.MemberWinlossRM * 0.8 AS MemberWinloss, -- 80% of expected WL in historical data
    0 AS MemberCommission, -- No commission
    1 AS BetCount -- Single ticket
FROM #tmpTestCustomers tc
    INNER JOIN bodb02.dbo.customer c WITH(NOLOCK) ON tc.CustID = c.CustID
    INNER JOIN bodb02.dbo.site s WITH(NOLOCK) ON s.Site = c.Site
WHERE tc.MemberWinlossRM <> 0 -- Only customers with expected WL
    AND NOT EXISTS (
        SELECT 1 FROM bodb_Account.dbo.FactCustStatsInfo f 
        WHERE f.CustID = tc.CustID 
            AND f.RptDate = DATEADD(DAY, -30, @moveBetsDay)
            AND f.SportType = 1 AND f.BetType = 1
    )

PRINT 'Created FactCustStatsInfo historical data (80% of expected WL, one row per customer)'

-- Show FactCustStatsInfo summary
SELECT 
    'FactCustStatsInfo Summary' AS Info,
    tc.CustID,
    'Currency-' + CAST(tc.CurrencyID AS VARCHAR(10)) AS Currency,
    ISNULL(f.MemberWinloss, 0) AS HistoricalWL_Native,
    ISNULL(f.MemberWinloss, 0) * ISNULL(c.Rate, 1.0) AS HistoricalWL_Converted, -- Convert by real rate
    f.RptDate AS DataDate,
    ISNULL(c.Rate, 1.0) AS ExchangeRate
FROM #tmpTestCustomers tc
LEFT JOIN bodb_Account.dbo.FactCustStatsInfo f WITH (NOLOCK) 
    ON tc.CustID = f.CustID 
    AND f.RptDate = DATEADD(DAY, -30, @moveBetsDay)
    AND f.SportType = 1 AND f.Bettype = 1
LEFT JOIN bodb_Account.dbo.tbl_Currency_Daily c WITH (NOLOCK) 
    ON f.RptDate = c.ExchangeDate AND f.CurrencyID = c.Currency

-- =============================================================================
-- STEP 2: CREATE CURRENT BETTING DATA (Match + BetTrans) 
-- =============================================================================
/*
PRINT CHAR(13) + '=== STEP 2: CREATING CURRENT BETTING DATA (Match + BetTrans) ==='
-- Create Match records first

-- Create BetTrans records (one row per customer with expected WL)
INSERT INTO bodb02.dbo.bettrans (custid, matchid, bettype, winlostdate, statusid, winlost, actual_stake, actualrate)
SELECT tc.CustID,
    (5500000 + tc.CustID) AS matchid, -- Matches the Match record
    1 AS bettype, -- HDP (VR bet type from Task logic)
    DATEADD(DAY, -5, GETDATE()) AS winlostdate, -- 5 days ago for current data
    111 AS statusid, -- Win status (from Task logic: 111, 112, 113)
    (tc.ExpectedWL_RM * 0.2) + 10000 AS winlost, -- 20% of expected WL + stake (unified for all currencies)
    10000 AS actual_stake, -- Fixed stake amount
    ISNULL(ex.actualrate, 1.0) AS actualrate -- Real exchange rate from exchange table
FROM @TestCustomers tc
LEFT JOIN bodb02.dbo.exchange ex WITH (NOLOCK) ON tc.CurrencyID = ex.exchangeid
WHERE tc.ExpectedWL_RM <> 0 -- Only customers with expected WL
    AND NOT EXISTS (
        SELECT 1 FROM bodb02.dbo.bettrans b 
        WHERE b.custid = tc.CustID 
            AND b.matchid = (5500000 + tc.CustID)
    )

PRINT 'Created BetTrans records (20% of expected WL, one row per customer)'
*/
-- Show BetTrans summary
SELECT 
    'BetTrans Summary' AS Info,
    b.custid AS CustID,
    'Currency-' + CAST(tc.CurrencyID AS VARCHAR(10)) AS Currency,
    b.winlost AS WinLost_Native,
    b.actual_stake AS Stake_Native,
    (b.winlost - b.actual_stake) AS NetWL_Native,
    (b.winlost - b.actual_stake) * b.actualrate AS NetWL_Converted, -- Convert by rate (unified)
    b.winlostdate AS DataDate,
    b.matchid,
    m.sporttype
FROM #tmpTestCustomers tc
INNER JOIN bodb02.dbo.bettrans b WITH (NOLOCK) ON tc.CustID = b.custid
INNER JOIN bodb02.dbo.match m WITH (NOLOCK) ON b.matchid = m.matchid
WHERE tc.MemberWinlossRM <> 0 -- Only customers with expected WL data
    AND b.statusid IN (111, 112, 113) -- Match the same status filter as Task logic
-- =============================================================================
-- STEP 3: PERFORMANCE & CREDIT VALIDATION SUMMARY
-- =============================================================================

PRINT CHAR(13) + '=== STEP 3: PERFORMANCE & CREDIT VALIDATION SUMMARY ===';

-- Currency-aware performance calculation simulation
WITH CTE_OLTPPerformance AS (
    SELECT 
        b.custid AS CustID,
        SUM((b.winlost - b.actual_stake) * b.actualrate) AS OLTPWinloss_RM
    FROM bodb02.dbo.bettrans b WITH (NOLOCK)
    INNER JOIN bodb02.dbo.match m WITH (NOLOCK) ON b.matchid = m.matchid
    WHERE EXISTS (SELECT 1 FROM #tmpTestCustomers tc WHERE tc.CustID = b.custid)
        AND b.statusid IN (111, 112, 113)
        AND m.sporttype <= 99 AND m.sporttype NOT IN (43) -- Exclude ESports
    GROUP BY b.custid
),
CTE_DWPerformance AS (
    SELECT 
        f.CustID,
        SUM(f.MemberWinloss * ISNULL(c.Rate, 1.0)) AS DWWinloss_Converted -- Convert by real exchange rate like Task
    FROM bodb_Account.dbo.FactCustStatsInfo f WITH (NOLOCK)
    LEFT JOIN bodb_Account.dbo.tbl_Currency_Daily c WITH (NOLOCK) ON f.RptDate = c.ExchangeDate AND f.CurrencyID = c.Currency
    INNER JOIN #tmpTestCustomers tc ON f.CustID = tc.CustID
    WHERE f.RptDate >= '2019-01-01' 
        AND f.RptDate <= @moveBetsDay
        AND f.TicketStatus IN (3, 4, 8, 12, 13)
        AND f.SportType = 1 AND f.Bettype = 1 -- Simplified to main VR sport/bet
    GROUP BY f.CustID
),
CTE_TotalPerformance AS (
    SELECT 
        tc.CustID,
        tc.CurrencyID,
        tc.MemberWinlossRM,
        ISNULL(oltp.OLTPWinloss_RM, 0) + ISNULL(dw.DWWinloss_Converted, 0) AS CalculatedWL_Converted,
        ISNULL(oltp.OLTPWinloss_RM, 0) AS OLTPPortion_Converted,
        ISNULL(dw.DWWinloss_Converted, 0) AS DWPortion_Converted
    FROM #tmpTestCustomers tc
    LEFT JOIN CTE_OLTPPerformance oltp ON tc.CustID = oltp.CustID
    LEFT JOIN CTE_DWPerformance dw ON tc.CustID = dw.CustID
)
SELECT 
    'WinLoss Performance & Credit Analysis' AS Info,
    CustID,
    'Currency-' + CAST(CurrencyID AS VARCHAR(10)) AS Currency,
    MemberWinlossRM,
    CalculatedWL_Converted,
    ABS(MemberWinlossRM - CalculatedWL_Converted) AS Variance_Converted,
    CASE 
        WHEN CalculatedWL_Converted <= @PerformanceThreshold_200K THEN 'POOR: WL ≤ -200K'
        ELSE 'GOOD: WL > -200K'
    END AS PerformanceCategory,
    OLTPPortion_Converted,
    DWPortion_Converted
FROM CTE_TotalPerformance

-- EXEC bodb_dwrs.dbo.Task_VRSetting_CheckMemberBigStakePerformance @IsTest = 0 
-- SELECT TOP 100 * FROM bodb_Account.dbo.BigCreditMembersMonitor (NOLOCK) WHERE CustID IN (SELECT value FROM STRING_SPLIT(@CustIDs, ','));