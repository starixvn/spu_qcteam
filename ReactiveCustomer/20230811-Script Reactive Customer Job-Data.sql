/*
	Created:	20230811@John.Ngo
	Task :		Reactivated Customer from maindb to CTS
	DB:			MainDB Local TESTDB055 (10.18.200.57)
*/
-- # Full Script data for Job Reactive Account (input Username)
-- ////////////////////////////////////////////////////////////////////////
# MySQL CTS_DataCenter
# ReActiveDate < ReActiveDate of custid
-- Step1:

SELECT @ReActiveDate:= DATE_ADD(NOW(), INTERVAL -1 Minute);
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = @ReActiveDate WHERE (`ParameterID` = '76');

SELECT * FROM CTS_DataCenter.SystemParameter where ParameterID in (76);
-- ////////////////////////////////////////////////////////////////////////

-- ////////////////////////////////////////////////////////////////////////
-- SQL SERVER - MainDB Local: TESTDB055 (10.18.200.57)
/* 789y site
SELECT TOP (100) c.site, c.username, c.custid, c.currency, c.srecommend, c.mrecommend, c.recommend, i.Enabled, i.reject, i.closed, c.roleid FROM dbo.customer c WITH (NOLOCK) 
INNER JOIN dbo.custInfo i (NOLOCK) ON c.custid = i.custid
WHERE c.site IN ('y789', 'y889', 'yUT', 'yOther') AND c.roleid = 1 AND c.currency <> 20 ORDER BY c.custid desc
*/
-- Step2:
DECLARE @UserNames NVARCHAR(MAX) = 'SL88SWINH07702,ig128INH581124,ig128RM712033,SM88INH10302666'

IF OBJECT_ID('tempdb..#tmpCustomer') IS NOT NULL
BEGIN
	DROP TABLE	#tmpCustomer;
END
	
CREATE TABLE #tmpCustomer(
		Custid			INT
	,	UserName		NVARCHAR(50)
);

INSERT INTO #tmpCustomer(UserName)
SELECT val FROM dbo.f_SplitString(@UserNames, ',');

UPDATE	tmpc WITH (ROWLOCK, UPDLOCK)
SET		tmpc.Custid = c.custid
FROM	#tmpCustomer tmpc
INNER JOIN	bodb02.dbo.Customer c (NOLOCK) ON tmpc.UserName = c.username;
-- SELECT * FROM #tmpCustomer tmpc
DECLARE @CustIds NVARCHAR(MAX);
SELECT @CustIds = STUFF((SELECT ',', CONVERT(VARCHAR(20), tmpc.Custid) FROM #tmpCustomer tmpc WITH (NOLOCK) FOR XML PATH('')), 1, 1, '');
-- SELECT @CustIds

-- Pro DB054 - Reactivated Customer: Run at 8:00 AM/day
SELECT TOP (100) ra.* FROM [bodb_CustomerLog].[dbo].[DBALog_Archive_Dep_Cust_Process] ra (NOLOCK)
INNER JOIN (SELECT val as CustId FROM dbo.f_SplitString(@CustIds, ',')) AS cc ON cc.CustId = ra.CustId;

WHILE EXISTS (SELECT TOP(1) 1 FROM #tmpCustomer WITH (NOLOCK))
BEGIN
	DECLARE @custid int
	SELECT TOP (1) @custid = custid FROM #tmpCustomer (NOLOCK)
	-- SELECT TOP (1) c.custid,c.username,c.site,c.currency FROM bodb02.dbo.Customer c (NOLOCK) where c.custid = @custid;
	
	DELETE [bodb_CustomerLog].[dbo].[DBALog_Archive_Dep_Cust_Process] WHERE CustID = @custid

	INSERT INTO [bodb_CustomerLog].[dbo].[DBALog_Archive_Dep_Cust_Process](CustID,Action,Status,Message,LogTime)
	VALUES (@custid,'REACTIVATION','Done','Testing ReActive',GETDATE());
	-- SELECT TOP (100) * FROM [bodb_CustomerLog].[dbo].[DBALog_Archive_Dep_Cust_Process] (NOLOCK) where CustID = @custid;
		
	DELETE FROM #tmpCustomer WHERE Custid = @custid;

END;
-- SELECT TOP (100) * FROM [bodb_CustomerLog].[dbo].[DBALog_Archive_Dep_Cust_Process] ra (NOLOCK) where ra.CustID in (72477890,75191624,75192133,75176588,72479286,72479615)
/*
SELECT TOP (100) * FROM [bodb_CustomerLog].[dbo].[DBALog_Archive_Dep_Cust_Process] ra (NOLOCK)
INNER JOIN #tmpCustomer tc ON ra.CustID = tc.Custid
*/
-- ////////////////////////////////////////////////////////////////////////

-- Step3: Start job Job Reactive Account "CTS_CC.CTS_Transform_InsertReactivatedCustomer"
-- Step4: Check Username in CTS