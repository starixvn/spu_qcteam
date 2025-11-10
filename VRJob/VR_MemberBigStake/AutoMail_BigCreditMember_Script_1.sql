/*
================================================================================
FEATURE #243071 - DATA GENERATION SCRIPT 1: Validate & Prepare Test Customers
================================================================================
Purpose: Validate test CustIDs exist in Customer and CustInfo tables
Database: DBCUST.CustDB
Note: This script does NOT create customers - only validates existing ones
================================================================================
*/
/*

  DELETE FROM CustDB.dbo.VRMemberBigStake
OUTPUT 
    deleted.CustID,
    deleted.Type,
    GETDATE() AS RepUpdateTime
INTO dbo.VRMemberBigStake_Del_InHouse (CustID, Type, RepUpdateTime)
WHERE CustID IN (148628770,148628771,148628772);

UPDATE  CustDB.dbo.VRMemberBigStake Set Status = 0, repUpdatetime = getdate() where CustID NOT IN (148628770, 148628771, 148628772);

*/

USE CustDB
GO

SET NOCOUNT ON

-- ============================================================================
-- INPUT PARAMETERS
-- ============================================================================

DECLARE @CustIds VARCHAR(2000) = '148628770,148628771,148628772' -- ,148737307,148737306,148737305,148737304,148737303,148737302,148737301,148737300'  -- Test CustIDs (comma-separated)
DECLARE @TestType TINYINT = 1                                    -- VR Type (1 = All VR sports except E-Sports)
DECLARE @GivenCredit INT = 50000                                 -- Credit amount to set for test customers

-- ============================================================================
-- VALIDATION: Check CustIDs exist
-- ============================================================================

CREATE TABLE #TestCustIDs (CustID INT)
INSERT INTO #TestCustIDs (CustID)
SELECT CAST(val AS INT) FROM dbo.f_SplitString(@CustIds, ',')

PRINT '========================================================================'
PRINT 'FEATURE #243071 - TEST CUSTOMER VALIDATION'
PRINT '========================================================================'
PRINT 'Test CustIDs: ' + @CustIds
PRINT ''

-- Check Customer table
DECLARE @MissingFromCustomer VARCHAR(MAX) = ''
SELECT @MissingFromCustomer = @MissingFromCustomer + CAST(t.CustID AS VARCHAR(20)) + ','
FROM #TestCustIDs t
WHERE NOT EXISTS (SELECT 1 FROM CustDB.dbo.Customer c (NOLOCK) WHERE c.custid = t.CustID)

IF LEN(@MissingFromCustomer) > 0
BEGIN
    PRINT '? ERROR: Following CustIDs NOT FOUND in Customer table:'
    PRINT '   ' + LEFT(@MissingFromCustomer, LEN(@MissingFromCustomer) - 1)
    PRINT ''
    PRINT 'Please provide valid CustIDs that exist in Customer table.'
    DROP TABLE #TestCustIDs
    RETURN
END

-- Check CustInfo table
DECLARE @MissingFromCustInfo VARCHAR(MAX) = ''
SELECT @MissingFromCustInfo = @MissingFromCustInfo + CAST(t.CustID AS VARCHAR(20)) + ','
FROM #TestCustIDs t
WHERE NOT EXISTS (SELECT 1 FROM CustDB.dbo.CustInfo ci (NOLOCK) WHERE ci.custid = t.CustID)

IF LEN(@MissingFromCustInfo) > 0
BEGIN
    PRINT '? ERROR: Following CustIDs NOT FOUND in CustInfo table:'
    PRINT '   ' + LEFT(@MissingFromCustInfo, LEN(@MissingFromCustInfo) - 1)
    PRINT ''
    PRINT 'Please provide valid CustIDs that exist in CustInfo table.'
    DROP TABLE #TestCustIDs
    RETURN
END

PRINT '? All CustIDs validated successfully!'
PRINT ''

UPDATE ci SET Credit = @GivenCredit -- Medium credit
FROM CustInfo ci 
INNER JOIN #TestCustIDs tc ON ci.CustID = tc.CustID
;
-- ============================================================================
-- DISPLAY CUSTOMER INFORMATION
-- ============================================================================

PRINT '--- Customer Information ---'
SELECT c.CustID, c.Username, c.Site, c.RoleID, c.CreatDate,
       ci.Credit, ci.Currency, ex.Currency AS CurrencyName, ex.actualrate AS ExchangeRate,
       ci.Credit * ex.actualrate AS GivenCredit_RM,
       ci.Recommend, ci.MRecommend, ci.SRecommend
FROM CustDB.dbo.Customer c (NOLOCK)
INNER JOIN CustDB.dbo.CustInfo ci (NOLOCK) ON c.custid = ci.custid
INNER JOIN CustDB.dbo.exchange ex (NOLOCK) ON ci.currency = ex.exchangeid
WHERE EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = c.CustID)

-- ============================================================================
-- PREPARE BigCreditMembersMonitor DATA
-- ============================================================================

PRINT ''
PRINT '--- Preparing BigCreditMembersMonitor Data ---'

-- Check if customers already exist in VRMemberBigStake
SELECT 'Existing in VRMemberBigStake' AS Status, v.CustID, v.Type, v.Status, v.FirstBetDate, v.RepUpdateTime
FROM CustDB.dbo.VRMemberBigStake v (NOLOCK)
WHERE v.Type = @TestType
  AND EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = v.CustID)

-- Insert missing customers into VRMemberBigStake (if not exists)
INSERT INTO CustDB.dbo.VRMemberBigStake (CustID, Type, Status, FirstBetDate, RepUpdateTime)
SELECT t.CustID, @TestType, 1, NULL, GETDATE()
FROM #TestCustIDs t
WHERE NOT EXISTS (SELECT 1 FROM CustDB.dbo.VRMemberBigStake v (NOLOCK) 
                  WHERE v.CustID = t.CustID AND v.Type = @TestType)

PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' new records into VRMemberBigStake'

-- Verify VRMemberBigStake data
SELECT 'VRMemberBigStake After Insert' AS Status, v.CustID, v.Type, v.Status, v.FirstBetDate, v.RepUpdateTime
FROM CustDB.dbo.VRMemberBigStake v (NOLOCK)
WHERE v.Type = @TestType
  AND EXISTS (SELECT 1 FROM #TestCustIDs t WHERE t.CustID = v.CustID);

  select top 10 * from CustDB.dbo.VRMemberBigStake v (NOLOCK) order by v.RepUpdateTime desc;

DROP TABLE #TestCustIDs