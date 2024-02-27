/*
	Created:	20240227@Irena.Vo
	Task :		Create script to create Tickets for Realtime Scanning
	DB:			TESTDB053 (bodb_Account, bodb_ODS)
	
	Revisions:
			-   20240227@Irena.Vo: Created
*/

-- select top 5* from bodb02.dbo.customer with(nolock) where site = 'W88' and roleid = 1 and currency not in (20, 27, 28) order by custid asc;
-- 1. Special site:
-- site = haifa: 4359501,4359569,4501696,4526581,4529106
-- site = MANBETX: 43054420,43054421,43054422,43054423,43054424,43054425
-- site = HC6Yayou: 43841252,43841253,43841255,43841256,43841257
-- site = US8Yayou: 44199465,44199466,44199467,44199468,44199469
-- site = BPLE: 41878831,41878832,41878833,41878834,41878835
-- site = Okada: 27109626,27109627,27109628,27109629,27109630
-- 2. Credit site: 
-- site = best-odds: 1275,1277,1280,1282,1284,1287
-- site = 611111: 5940,5941,5942,5943,5944
-- 3. Licensee site:
-- site = 12bet: 791050,791054,832131,832132,832134
-- site = W88: 10580727,10580728,10580729,10580730,10580772

-- test cust: 4359501,1275,791050,4359569,1277,791054,4501696,1280,832131,4526581,1282,832132

use bodb_Account 
declare
	@CustIDList varchar(max) = '1277,1280,1282,1284,1287,1290,1295,43054421,43054422,43054423,43054424,43054425,43841252,43841253'-- 4359569
,	@SportTypeList varchar(255) = '2'
,	@BetType smallint = 1 -- 1: hdp, 3: ou, 7: 1st hdp, 8: 1st ou
,	@LeagueID int = 3
,	@RptDate DATE = DATEADD(DD, -1, CAST(GETDATE() AS DATE)), @RangeRptDate smallint = 0, @MinRptDate DATE -- yesterday, today
,	@TicketStatus varchar(50) = 'won', @ExternalBet BIT = 1
,	@ProductID smallint = 1, @ActualRate decimal(19,4) = 1 
,	@BetFromID smallint =  1
,	@Turnover DECIMAL(19, 4) = 150001, @FinalTurnover DECIMAL(19, 4)
,	@Winloss DECIMAL(19, 4) = -3002, @FinalWinloss DECIMAL(19, 4)
,	@BetCount DECIMAL(19, 4) = 300, @FinalBetCount DECIMAL(19, 4), @Option DECIMAL(19, 4) = 0.05
,	@MatchID BIGINT = 12345690
;

-- 1. RptDate is mapping to WinlostDate
if object_id('tempdb..#tmpRptDate', 'U') is not null drop table #tmpRptDate
create table #tmpRptDate (RptDate DATE);
set @MinRptDate = DATEADD(DD, -@RangeRptDate, @RptDate);
select @MinRptDate;
while (@RptDate >= @MinRptDate)
begin 
	insert into #tmpRptDate (RptDate) values (@RptDate);
	set @RptDate =DATEADD(DD, -1, @RptDate);
end
select * from #tmpRptDate;

-- 2. Cust
if object_id ( 'tempdb..#tmpCustIDList', 'U') is not null drop table #tmpCustIDList
create table #tmpCustIDList(CustId bigint);
INSERT INTO  #tmpCustIDList (CustId) 
SELECT DISTINCT CAST(value AS bigint) CustId 
FROM STRING_SPLIT(@CustIDList, ',');

-- 3. Sport
if object_id ( 'tempdb..#tmpSportTypeList', 'U') is not null drop table #tmpSportTypeList
create table #tmpSportTypeList(SportType smallint);
INSERT INTO  #tmpSportTypeList (SportType) 
SELECT DISTINCT CAST(value AS smallint) SportType 
FROM STRING_SPLIT(@SportTypeList, ',');

-- 4. Trans
if object_id ( 'tempdb..#tmpTransList', 'U') is not null drop table #tmpTransList
create table #tmpTransList(
	TransID bigint NOT NULL IDENTITY(1000000,1) PRIMARY KEY, 
	CustID bigint, 
	SportType int, 
	WinlostDate date, 
);
INSERT INTO  #tmpTransList(CustID,SportType,WinlostDate) 
select c.CustID,sp.SportType,rpt.RptDate
from #tmpCustIDList c
	cross join  #tmpSportTypeList sp
	cross join  #tmpRptDate rpt; 

delete b
from bodb_ODS.dbo.ODS_bettrans_final_SiteDB01_batch01 b
	inner join #tmpCustIDList tmp on tmp.CustId = b.CustId 
	inner join  #tmpSportTypeList sp on sp.SportType = b.SportType
	inner join  #tmpRptDate rpt on rpt.RptDate = b.WinlostDate; 

-- 4. Insert data
set @FinalTurnover = @Turnover/(@RangeRptDate + 1);
set @FinalWinloss = @Winloss/(@RangeRptDate  + 1);
set @FinalBetCount = ROUND(@BetCount/(@RangeRptDate  + 1) + @Option, 0);

select  @FinalTurnover, @FinalWinloss, @FinalBetCount;

insert into bodb_ODS.dbo.ODS_bettrans_final_SiteDB01_batch01 (WinlostDate,TransDate,ModifiedDate,TransID,MatchID,SportType,ProductID,BetType,Status,ExternalBet,LeagueID,Stake,actual_stake,Winlost,BetCount,ActualRate,CustID,Currency,Recommend, Mrecommend, Srecommend, SiteID)
select distinct rpt.RptDate,rpt.RptDate,rpt.RptDate,tr.TransID,@MatchID,sp.SportType,@ProductID,@BetType,@TicketStatus,@ExternalBet,@LeagueID,@FinalTurnover,0,@FinalWinloss,@FinalBetCount,@ActualRate,tmp.CustID,13/*c.currency*/,c.Recommend,c.Mrecommend,c.Srecommend, s.SiteID
from bodb02.dbo.customer c
	inner join bodb02.dbo.Site s on c.Site = s.Site
	inner join #tmpCustIDList tmp on tmp.CustId = c.CustId 
	cross join #tmpSportTypeList sp
	inner join #tmpTransList tr on tr.CustId = tmp.CustId and tr.SportType = sp.SportType
	cross join #tmpRptDate rpt
order by rpt.RptDate asc;

select distinct b.*
from bodb_ODS.dbo.ODS_bettrans_final_SiteDB01_batch01 b
	inner join #tmpCustIDList tmp on tmp.CustId = b.CustId
	cross join #tmpSportTypeList sp
	cross join #tmpRptDate rpt; 

select distinct b.*
from bodb_ODS.dbo.ODS_bettrans b
	inner join #tmpCustIDList tmp on tmp.CustId = b.CustId
	cross join #tmpSportTypeList sp
	cross join #tmpRptDate rpt; 