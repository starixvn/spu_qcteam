/*
	Created:	20240227@Irena.Vo
	Task :		Create script to create Tickets for Daily/Probation Scanning
	DB:			TESTDB053 (bodb_Account)
	
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

-- test cust: 4359501,1275,791050,4359569,1277,791054,4501696,1280,832131,4526581,1282,832132,4529106,1284,832134,43054420,5940,10580727,43054421,5941,10580728
-- ProductID <> 1,50 -> Bettype = 31. 
-- select * from bodb_account.dbo.Product_Bettype where ProductID > 0 and ProductID not in (1,50) and sporttype > 0;

use bodb_Account 
declare
	@CustIDList varchar(max) = '99189563'
,	@SportTypeList varchar(255) = '1' -- 168: non sports
,	@BetType smallint = 1 -- 1: hdp, 3: ou, 7: 1st hdp, 8: 1st ou, 3601: cho Non sports
,	@LeagueID int = 3
,	@RptDate DATE = DATEADD(DD, -7, CAST(GETDATE() AS DATE)), @RangeRptDate smallint = 3, @MinRptDate DATE -- lui ve tu moc RptDate. tinh winday lui ve them 6 ngay.
,	@LiveStatus smallint = 1 -- 1: live, 0: nonlive
,	@TicketStatus smallint = 8 -- 3: draw, 4: lose, 8: won, 12: half lose, 13: half won, 9: reject, 10: void
,	@BetFromID smallint =  1
,	@MemberTurnover DECIMAL(19, 4) = 999999, @FinalMemberTurnover DECIMAL(19, 4)
,	@MemberWinloss DECIMAL(19, 4) = 9999, @FinalMemberWinloss DECIMAL(19, 4)
,	@MemberCommission DECIMAL(19, 4) = 0, @FinalMemberCommission DECIMAL(19, 4)
,	@BetCount DECIMAL(19, 4) = 19, @FinalBetCount DECIMAL(19, 4), @Option DECIMAL(19, 4) = 0

-- 1. RptDate
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

delete f
from bodb_account.dbo.FactCustStatsInfo f
	inner join #tmpCustIDList tmp on tmp.CustId = f.CustId 
	inner join  #tmpSportTypeList sp on sp.SportType = f.SportType
	inner join  #tmpRptDate rpt on rpt.RptDate = f.RptDate; 

delete c
from bodb_account.dbo.tbl_Currency_Daily c
	inner join bodb02.dbo.customer cs on cs.Currency = c.Currency
	inner join #tmpCustIDList tmp on tmp.CustId = cs.CustId
	inner join  #tmpRptDate rpt on rpt.RptDate = c.ExchangeDate;
	
insert into bodb_account.dbo.tbl_Currency_Daily (ExchangeDate,Currency,Rate,dateupdated)
select distinct rpt.RptDate,c.Currency,1,rpt.RptDate
from bodb02.dbo.customer c
	inner join #tmpCustIDList tmp on tmp.CustId = c.CustId
	cross join  #tmpRptDate rpt;

-- 4. Insert data
set @FinalMemberTurnover = @MemberTurnover/(@RangeRptDate + 1);
set @FinalMemberWinloss = @MemberWinloss/(@RangeRptDate  + 1);
set @FinalMemberCommission = @MemberCommission;
set @FinalBetCount = ROUND(@BetCount/(@RangeRptDate  + 1) + @Option, 0);

select  @FinalMemberTurnover, @FinalMemberWinloss, @FinalMemberCommission, @FinalBetCount;

insert into bodb_account.dbo.FactCustStatsInfo (RptDate,SportType,SiteID,BetType,TicketStatus,LiveStatus,LeagueID,CurrencyID,BetFromID,CustID,MemberTurnover,MemberWinloss,MemberCommission,BetCount)
select distinct rpt.RptDate,sp.SportType,s.SiteID,@BetType,@TicketStatus,@LiveStatus,@LeagueID,c.currency,@BetFromID,tmp.CustID,@FinalMemberTurnover,@FinalMemberWinloss,@FinalMemberCommission,@FinalBetCount
from bodb02.dbo.customer c
	inner join bodb02.dbo.site s on s.Site = c.Site
	inner join #tmpCustIDList tmp on tmp.CustId = c.CustId 
	cross join #tmpSportTypeList sp
	cross join #tmpRptDate rpt
order by rpt.RptDate asc;

select distinct f.*
from bodb_account.dbo.FactCustStatsInfo f
	inner join #tmpCustIDList tmp on tmp.CustId = f.CustId
	cross join #tmpSportTypeList sp
	cross join #tmpRptDate rpt; 