/*
	Created:	20240913@Randy.Nguyen
	Task :		Create script check General Normal Classification flow in DW (bodb_VR2Model)
	DB:			<MainDB TESTDB053 (xx.xx.xxx.xx)>
	
	Revisions: 
			-	20240913@Randy.Nguyen:			Initial Writing [Redmine ID: #205317]
*/
-- Service CTS_CustomerClassification_Secondly_NormalAccountClassification

USE bodb_VR2Model;
-- ### REALTIME CHECKCHANGES ###
-- delete from CustomerClassification_RealtimeChanges;
-- delete from CustomerClassification_LatestActiveDay where custid < 1000000 or custid > 1999999;

select * from CustomerClassification_RealtimeChanges (nolock);

select top 100 * from CustomerClassification_LatestActiveDay (nolock) order by CreatedTime desc ;

update CustomerClassification_Parameter set value = '2024-07-03 00:00:00.000' where DataId in(10,11,12,13);

select * from CustomerClassification_Parameter (nolock);

-- ### REALTIME SCAN ###
-- delete from CustomerClassification_NormalPool where FunctionId = 100;
-- delete from CustomerClassification_NormalPool where (custid >= 1000000 and custid <= 1999999) and FunctionId = 100;
/*
DELETE FROM [dbo].[CustomerClassification_NormalPool]
INSERT INTO [CustomerClassification_NormalPool] (CustId,[Priority],FunctionId,CreatedTime)
VALUES(43289963, 10, 45, GETDATE()) -- GB
*/
delete from CustomerClassification_NormalPool where custid not in (82349969);

delete from CustomerClassification_NormalPool where FunctionId = 4;

select * from CustomerClassification_NormalPool (nolock);

Select * from [dbo].[CustomerClassification_Priority];

-- ### GENERAL CLASSIFICATION ###
-- delete from CustomerClassification_BetCount where custid in (148626538);

-- delete from CustomerClassification where RowVersion > 0x0000000000C23EE3 and custid in (1277);

-- update CustomerClassification_Parameter set value = 12730145 where DataId = 1;

-- Check if exists in CustomerClassification_ScannedDailyCust, DailyNormalScan will not classify again in same day
select * from CustomerClassification_ScannedDailyCust where custid in (1277,43054421);

-- Check rule BetCount, Realtime scan only classify when Normal has >= 20 new tickets, Good has >= 100 new tickets
select * from CustomerClassification_BetCount where custid in (148626538);

-- CREDIT: only count WL perf from the date in CustomerClassification_ResetBalance
select * from CustomerClassification_ResetBalance where custid in (148626498,14862649);

-- Rule classify: select * from CustomerClassification_Rule (nolock);

-- ### Normal Account Insert ###
DELETE FROM [dbo].[CustomerClassification] -- WHERE CustId IN (43289963,42784044,43290047,50706645);
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(43290035,	200, 40200, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0); -- Good
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(43290035,	200, 40300, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0); -- Normal
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(43290035,	200, 40400, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0); -- Pro

INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(43290027,	200, 40701, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0); -- Smart (Inactive)
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(43290035,	200, 40700, 0, GETDATE(), GETDATE() ,	999999.0000,	 -9999.0000,	20,	4,	GETDATE(), 0); -- System Detect Unauthorized Login
		
Update CustomerClassification Set Custid = 148626508, CurrentCategoryId = 0 ,CategoryId = 40400,
ScanTaggingType=0, performanceTime = GETDATE() where ID = 26561;

Update CustomerClassification Set Custid = 148626498, CurrentCategoryId = 0, CategoryId = 40701,
ScanTaggingType=0, performanceTime = GETDATE(), BetCount = 1 where ID = 26560;

-- Update Parameter of service NormalAccountInsert to latest
UPDATE c WITH (ROWLOCK, UPDLOCK)
		SET c.Value = UPDATE c WITH (ROWLOCK, UPDLOCK) SET c.Value = (select Max(ID) from dbo.CustomerClassification)
	FROM dbo.CustomerClassification_Parameter AS c
	WHERE c.DataId = 3;

-- Check pool CustomerClassification before insert CategoryID into CTS
select * from CustomerClassification_Parameter (nolock) where DataId = 3;

select top 1000 cast(rowversion AS bigint),* from CustomerClassification (nolock)  order by RowVersion desc;

-- Service CTS_CC.CTS_CustomerClassification_Secondly_NormalAccountInsert
DECLARE @ScannedMaxId BIGINT;
EXEC bodb_VR2Model.dbo.CTS_GeneralNormalClassification_NormalAccount_Get @ScannedMaxId = @ScannedMaxId OUTPUT, @IsLogData = 0
SELECT @ScannedMaxId;