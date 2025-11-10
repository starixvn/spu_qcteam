/*
	Created:	20240913@Randy.Nguyen
	Task :		Create script check General Normal Classification flow in DW (bodb_VR2Model)
	DB:			<MainDB TESTDB053 (xx.xx.xxx.xx)>
	
	Revisions: 
			-	20240913@Randy.Nguyen:			Initial Writing [Redmine ID: #205317]
*/

USE bodb_VR2Model;
-- ### REALTIME CHECKCHANGES ###
-- delete from CustomerClassification_RealtimeChanges where custid <> 179806713;
-- delete from CustomerClassification_LatestActiveDay where custid in (148628769,148628770);


select * from CustomerClassification_RealtimeChanges (nolock) where custid = 179806713;

select top 100 * from CustomerClassification_LatestActiveDay (nolock) where custid in(148628769,148628770) order by CreatedTime desc ;
 Insert into CustomerClassification_LatestActiveDay (custid, LastTransDate, LastTransTime,CreatedTime) values 
 (148628769,	'2025-04-01'	,'2025-04-01 02:44:56.420',	'2025-04-01 02:44:56.420'),
  (148628770,	'2025-04-01'	,'2025-04-01 02:44:56.420',	'2025-04-01 02:4
  4:56.420');
update CustomerClassification_Parameter set value = '2024-11-14 00:00:00.000' where DataId in(10,11,12,13);

select * from CustomerClassification_Parameter (nolock);

-- ### REALTIME SCAN ###
-- delete from CustomerClassification_NormalPool where FunctionId = 100;
-- delete from CustomerClassification_NormalPool where (custid >= 1000000 and custid <= 1999999) and FunctionId = 100;

delete from CustomerClassification_NormalPool where ID > 2670916;

delete from CustomerClassification_NormalPool;

-- ### NORMAL POOL ###

INSERT INTO CustomerClassification_NormalPool (CustId, Priority, FunctionId, CreatedTime)
VALUES
-- Cust 1277
(1277, 100, 1, GETDATE()), (1277, 200, 2, GETDATE()), (1277, 300, 3, GETDATE()),
(1277, 10, 4, GETDATE()), (1277, 20, 5, GETDATE()), (1277, 30, 6, GETDATE()),
(1277, 1000, 7, GETDATE()), (1277, 1000, 8, GETDATE()), (1277, 100, 9, GETDATE());
	
		 
	select * from CustomerClassification_NormalPool (nolock);

update CustomerClassification_NormalPool set FunctionId = 3, Priority = 300 where custid = 148626489;

Select * from [dbo].[CustomerClassification_Priority];

SELECT Priority, FunctionId, COUNT(*) AS TotalCount, MIN(CustId) AS MinCustId, MAX(CustId) AS MaxCustId, MIN(CreatedTime) AS MinCreatedTime, MAX(CreatedTime) AS MaxCreatedTime 
FROM CustomerClassification_NormalPool (NOLOCK)
GROUP BY Priority, FunctionId;



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

INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(148626489,	200, 40100, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(148626524,	200, 40200, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(148626489,	200, 40300, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(148626489,	200, 40400, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(148626489,	200, 40500, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(148628814,	200, 40200, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;
INSERT INTO dbo.CustomerClassification(CustId, SportId, CategoryId, CurrentCategoryId, CreatedDate, CreatedTime, TurnoverRM, WinlossRM, BetCount, ActiveDays, PerformanceTime, ScanTaggingType) Values
(239084214,	200, 40700, 0, GETDATE(), GETDATE() ,	10000,	 10000,	10,	10,	GETDATE(), 0)
;

select Max(ID) from CustomerClassification
;

UPDATE c WITH (ROWLOCK, UPDLOCK)
		SET c.Value = 0
		FROM dbo.CustomerClassification_Parameter AS c
		WHERE c.DataId = 2;
UPDATE c WITH (ROWLOCK, UPDLOCK)
		SET c.Value = CONVERT(VARCHAR(200), cast((select Max(rowversion) from CustomerClassification) AS bigint))
		FROM dbo.CustomerClassification_Parameter AS c
		WHERE c.DataId = 1;


-- Check pool CustomerClassification before insert CategoryID into CTS



UPDATE c WITH (ROWLOCK, UPDLOCK)
		SET c.Value = (select Max(ID) from CustomerClassification)
		FROM dbo.CustomerClassification_Parameter AS c
		WHERE c.DataId = 3;
		
 
 
select * from bodb_VR2Model.dbo.CustomerClassification_Parameter (nolock) where DataId in (3);

select top 1000 i.username,c.* from bodb_VR2Model.dbo.CustomerClassification (nolock) as c
left join bodb02.dbo.custinfo as i (nolock)on c.CustId = i.custid
order by c.ID desc;


update CustomerClassificationAgency set custid = 85337943, CategoryId = 140500 where ID = 100940

UPDATE c WITH (ROWLOCK, UPDLOCK)
		SET c.Value = CONVERT(VARCHAR(200), cast((select Max(rowversion) from CustomerClassificationAgency) AS bigint))
		FROM dbo.CustomerClassification_Parameter AS c
		WHERE c.DataId = 1000;
		
select * from bodb_VR2Model.dbo.CustomerClassificationAgency_NormalPool (nolock);

select * from bodb_VR2Model.dbo.CustomerClassification_Parameter (nolock) where DataId in (1000);

select top 1000 i.username,cast(c.Rowversion as bigint),c.* from bodb_VR2Model.dbo.CustomerClassificationAgency (nolock) as c
left join bodb02.dbo.custinfo as i (nolock)on c.CustId = i.custid
order by c.RowVersion desc;


INSERT INTO CustomerClassificationAgency_RealtimeChanges (RoleId, CustId, CreatedTime)
VALUES (2, 179807104, GETDATE());


select * from CustomerClassificationAgency_RealtimeChanges (nolock) where custid = 179807104;
