/*
	Created:	20230918@John.Ngo
	Task :		Create New Match from maindb
	DB:			MainDB Local TESTDBTRANS (10.18.200.55)
*/

/*
SELECT TOP 10 l.leagueid, l.leaguename, m.matchid, m.homeid, m.awayid, ht.teamname + ' - vs - ' + at.teamname [event], m.eventdate, m.eventstatus, m.kickofftime, m.GlobalShowTime, GETDATE() [NOW]
FROM bodb02.dbo.Match m WITH(NOLOCK)
		LEFT JOIN bodb02.dbo.bettrans b WITH(NOLOCK) ON b.matchid = m.matchid
		LEFT JOIN bodb02.dbo.League l WITH(NOLOCK)	ON m.leagueid = l.leagueid
		LEFT JOIN bodb02.dbo.Team ht WITH(NOLOCK) ON m.homeid = ht.teamid
		LEFT JOIN bodb02.dbo.Team at WITH(NOLOCK) ON m.awayid = at.teamid
WHERE b.transid >= 157405397437644804

SELECT TOP 100	* FROM dbo.bettrans AS b WITH(NOLOCK)
INNER JOIN dbo.match AS m WITH(NOLOCK) ON b.matchid = m.matchid
WHERE m.matchcode = 'CTS_Test_J01';						
	
DELETE b FROM dbo.bettrans AS b WITH(NOLOCK)
INNER JOIN dbo.match AS m WITH(NOLOCK) ON b.matchid = m.matchid
WHERE m.matchcode = 'CTS_Test_J01';
	
DELETE m FROM dbo.match AS m WITH(ROWLOCK) WHERE m.matchcode = 'CTS_Test_J01';	
DELETE FROM [bodb02].[dbo].bettrans where matchid = 99612178;
DELETE FROM [bodb02].[dbo].bettrans where transid in (144460589345800192)

SELECT TOP (100) ExchangeId,* FROM [dbo].Exchange (NOLOCK);

Update dbo.bettrans WITH(ROWLOCK) set currency = 5, actualrate = 0.5906, odds = -0.65, winlostdate = '2022-06-26 00:00:00.000' where TransId IN  (144337937964728434) -- HK$
Update dbo.match WITH(ROWLOCK) set eventstatus = 'Completed' where matchid = 70042341; -- running Completed
--------------------------------------------------------------------------------------------
## OddsType
,	CASE 
	-- Decimal
	WHEN b.oddstype = 1 THEN (CASE WHEN ot.OddsType IS NOT NULL THEN (CASE 
										WHEN b.odds <= 2 THEN (b.odds - 1)
										WHEN b.odds > 2 THEN -(1/(b.odds - 1)) END)
								ELSE b.odds END)
	-- Hong Kong
	WHEN b.oddstype = 2 THEN (CASE WHEN b.odds <= 1 THEN b.odds
								   WHEN b.odds > 1 THEN -(1/b.odds) END)
	-- Indonesia
	WHEN b.oddstype = 3 THEN -(1/NULLIF(b.odds,0))
	-- Malaysian & Myanmar
	WHEN b.oddstype IN (4,6) THEN b.odds
	-- US
	WHEN b.oddstype = 5 THEN -(1/NULLIF(b.odds,0))
END AS odds
*/

/*
-- 12BETAUD02001,12BETAUD02002,12BETAUD02003,M28RMB06001,MBRM55568,M28RMB06027
   Custid in (1411402,1481207,1775698,121124,169695,954103)
-- MS88HK$01014,MS88HK$01015,MS88HK$01016,MS88HK$01017
   Custid in (1773935,1773951,1773953,1807075)
-- AB88GBP01010,AB88GBP01011,AB88GBP01012,AB88GBP01013,MBRM55569
   Custid in (1780022,1809391,1821795,1838970,169696)
-- AB88GBP01025,AB88GBP01026,AB88GBP01027,AB88GBP01028,M28RMB06010
   Custid in (192205,1945686,1967881,1980160,1980344)
-- DUL8000B012,DUL8000B00E,DUL8000B004,FC940009047,FC94000904C,FC94000904H (789y Member), DUL8000B,FC940009 (789y Agent) (79642387,77653253)
   Custid in (80187175,79786725,79651700,86705341,86931017,87316463)
-- BC985AM011,BC985AM009,XU25T202003,XU25T202004 (789y Member) M222MNT398,M28RMB06788,MS88HK$01018
   Custid in (51803846,51811392,51811775,51815630,14051943,834082,2808564)
*/
-- TESTDBTRANS (10.18.200.55)
USE bodb02
DECLARE @matchid int = 72187867 -- Enter matchid here to create tickets into that match. If leave blank, a random match will be selected
,@sporttype smallint = 1, @stakeRM money = 10000, @stake money = 500 ,@currency smallint = 16, @actualrate float = 4.1723, @virtualrate float = 4.1723
 -- @stakeRM <> 0 -> Create tickets ~ stakeRM value, not check @stake value
,@CustIds varchar(2000) = '1411402,1481207,1775698,121124,169695,954103' -- Create ticket for custids list
,@bettype1 smallmoney = 3, @bettype2 smallmoney = 0, @bettype3 smallmoney= 0, @bettype4 smallmoney = 0
,@liveindicator bit = 1, @livehomescore int = 0, @liveawayscore int = 0 --, @HTHomeScore INT = 0, @HTAwayScore INT = 0, @FinalHomeScore INT = 0, @FinalAwayScore INT = 0
,@hdp1 smallmoney = 0, @hdp2 smallmoney = 0.5 -- (0.25 - 0.5 - 0.75 - 1 ...)
,@oddsid1 int = 0, @oddsid2 int = 0, @oddsid3 int = 0, @oddsid4 int = 0, @statusid int = 0, @oddsstatus varchar(20) = 'running' -- oddsstatus = 'running', 'closed'
,@odds smallmoney = 0.65, @oddsType tinyint = 2 ---- odds, oddsType -----
,@leagueid int = 3, @homeid int = 8, @awayid int = 9, @eventstatus varchar(20) = 'running'
,@matchcode varchar(200) = 'CTS_Test_J01', @creator int = 8, @ip varchar(45) = '10.164.168.09' -- '161.142.250.65' --ipv6:  '240e:465:1f32:2dd3:64a6:d7ff:fed9:3046'
,@betteam varchar(10) = 'h', @betid int = 0, @time time = CONVERT(Time, GETDATE())
,@eventdate datetime = '2023-09-14 00:00:00.000' -- DATEADD(DD, 0, DATEDIFF(DD, 0, GETDATE())) 
declare @transdate datetime = @eventdate + CAST(@time AS DATETIME) -- DATEADD(DD, 0, GETDATE()) OR DATEADD(HOUR,10,DATEADD(MINUTE,30,DATEADD(SECOND,0,@eventdate)))
	   ,@kickofftime datetime = DATEADD(DD,0, DATEADD(HOUR,10,DATEADD(MINUTE,20,@eventdate))) -- DATEADD(HOUR,10,DATEADD(MINUTE,20,@eventdate));
------------- Get match ----------------------------------------------------
-- SELECT @eventdate,@transdate,@kickofftime;
DECLARE @Tickets INT = 4; -- Create tickets
DECLARE @steptimeticket INT = 5; -- transdate step of ticket1 & ticket2 ... (second)

if object_id ( 'tempdb..#tmpMatches', 'U') is not null drop table #tmpMatches
create table #tmpMatches(matchid int);

select	@livehomescore = CASE WHEN @liveindicator = 0 THEN 0 ELSE m.livehomescore END
	,	@liveawayscore = CASE WHEN @liveindicator = 0 THEN 0 ELSE m.liveawayscore END
from dbo.match m (NOLOCK) where m.matchid  = @matchid;

if @bettype1 <> 0 begin
	select top 1 @oddsid1 = od.oddsid from bodb02.dbo.Match m WITH(NOLOCK)	
			INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
	WHERE m.matchid = @matchid AND bettype = @bettype1;
END
if @bettype2 <> 0 begin
	select top 1 @oddsid2 = od.oddsid from bodb02.dbo.Match m WITH(NOLOCK)	
	INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
	WHERE m.matchid = @matchid AND bettype = @bettype2;
END
if @bettype3 <> 0 begin
	select top 1 @oddsid3 = od.oddsid from bodb02.dbo.Match m WITH(NOLOCK)	
	INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
	WHERE m.matchid = @matchid AND bettype = @bettype3;
END
if @bettype4 <> 0 begin
	select top 1 @oddsid4 = od.oddsid from bodb02.dbo.Match m WITH(NOLOCK)	
	INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
	WHERE m.matchid = @matchid AND bettype = @bettype4;
END
-- select top 10 * from [bodb02].[dbo].[odds] od WITH(NOLOCK) WHERE od.matchid = @matchid

---------------------Get Cust Info-----------------------------------------------
if object_id ('tempdb..#tmpCustInfo', 'U') is not null drop table #tmpCustInfo
create table #tmpCustInfo (id int primary key identity(1,1), custid int, creator int, username nvarchar(30), username2 nvarchar(50), recommend int, mrecommend int, srecommend int, currency tinyint, currencyName nvarchar(50), siteName nvarchar(100), isDeposit bit
, actualrate float);

insert into #tmpCustInfo (custid, username, username2, recommend, mrecommend, srecommend, currency, currencyname, sitename, isdeposit, actualrate)
select distinct ci.custid, ci.username, usn.username2, ci.recommend, ci.mrecommend, ci.srecommend, ci.currency, ex.currency, ag.site, case when sp.custid is null then 0 else 1 end, ex.actualrate
from CustDB.dbo.custinfo ci (nolock) 
	inner join CustDB.dbo.exchange ex (nolock) on ex.exchangeid = ci.currency 
	left join CustDB.dbo.customer ag (nolock) on ag.custid = ci.recommend 
	left join CustDB.dbo.Dep_CustSuper sp (nolock) on ci.srecommend = sp.custid 
	inner join CustDB.dbo.customer usn (nolock) on usn.custid = ci.custid
	inner join (SELECT val as CustId FROM dbo.f_SplitString(@CustIds, ',')) AS cc ON cc.CustId = ci.CustId
where ci.username not like '%bettrade%'
   /* Filter internal customer */
    -- AND ci.[Enabled] = 1
    AND ci.roleid = 1
    AND ci.srecommend NOT IN (41430709)
    AND ci.mrecommend NOT IN (27899314, 11656504, 12146012)
    AND ci.recommend NOT IN (52466, 5707545, 29270764, 134456, 27787409)
    AND ci.username NOT LIKE '%CashOut'
    /* Remove oddsfeed site */
    AND ag.site NOT IN ('NextBet', '9wickets', '9wsports')

select * from #tmpCustInfo;

----------------------------Get Bettype Matrix--------------------------------------------------
if object_id ( 'tempdb..#matrixBettype', 'U') is not null drop table #matrixBettype
create table #matrixBettype(
  id int identity(1,1) primary key
, bettype smallint
, betteam nvarchar(10)
)
insert into #matrixBettype(bettype, betteam)
values
   (1,'a'),(1,'h')
   ,(2,'a'),(2,'h')
   ,(3,'a'),(3,'h')
   ,(4,'0:0'),(4,'0:1'),(4,'0:2'),(4,'0:3'),(4,'0:4'),(4,'0:5'),(4,'1:0'),(4,'1:1'),(4,'1:2'),(4,'1:3'),(4,'1:4'),(4,'2:0'),(4,'2:1'),(4,'2:2'),(4,'2:3'),(4,'2:4'),(4,'3:0'),(4,'3:1'),(4,'3:2'),(4,'3:3'),(4,'3:4'),(4,'4:0'),(4,'4:1'),(4,'4:2'),(4,'4:3'),(4,'4:4'),(4,'5:0')
   ,(5,'1'),(5,'2'),(5,'x')
   ,(6,'0-1'),(6,'2-3'),(6,'4-6'),(6,'7-over')
   ,(7,'a'),(7,'h')
   ,(8,'a'),(8,'h')
   ,(12,'a'),(12,'h')
   ,(13,'an'),(13,'ay'),(13,'hn'),(13,'hy')
   ,(14,'0:0'),(14,'1:1'),(14,'1:2'),(14,'2:1'),(14,'2:2')
   ,(15,'1'),(15,'2'),(15,'x')
   ,(16,'0:0'),(16,'0:1'),(16,'0:2'),(16,'1:0'),(16,'1:1'),(16,'1:2'),(16,'2:0'),(16,'2:1'),(16,'2:2')
   ,(17,'a'),(17,'h')
   ,(18,'o'),(18,'u')
   ,(20,'H'),(20,'A')
   ,(21,'H'),(21,'A')
   ,(22,'1'),(22,'2'),(22,'x')
   ,(24,'12'),(24,'1x'),(24,'2x')
   ,(25,'a'),(25,'h')
   ,(26,'b'),(26,'n'),(26,'o')
   ,(27,'a'),(27,'h')
   ,(28,'1'),(28,'2'),(28,'x')
   ,(30,'0:0'),(30,'0:1'),(30,'0:2'),(30,'0:3'),(30,'0:4'),(30,'1:0'),(30,'1:1'),(30,'1:2'),(30,'1:3'),(30,'2:0'),(30,'2:1'),(30,'2:2'),(30,'2:3'),(30,'3:0'),(30,'3:1'),(30,'3:2'),(30,'3:3'),(30,'4:0')
   ,(121,'a'),(121,'x')
   ,(122,'h'),(122,'x')
   ,(123,'a'),(123,'h')
   ,(124,'a'),(124,'h')
   ,(126,'0-1'),(126,'2-3'),(126,'4&Over')
   ,(127,'0:0'),(127,'1:1'),(127,'1:2'),(127,'2:1'),(127,'2:2')
   ,(128,'ee'),(128,'eo'),(128,'oe'),(128,'oo')
   ,(129,'0'),(129,'1'),(129,'2'),(129,'3'),(129,'4'),(129,'5&over')
   ,(130,'0'),(130,'1'),(130,'2'),(130,'3'),(130,'4'),(130,'5'),(130,'6'),(130,'7&over')
   ,(131,'0-1'),(131,'2-3'),(131,'4&Over')
   ,(132,'0-1'),(132,'2-3'),(132,'4&Over')
   -----------------  Bet-Radar Phase 1 -------------------------------
   ,(133,'N'),(133,'Y')
   ,(134,'N'),(134,'Y')
   ,(135,'N'),(135,'Y')
   ,(136,'E'),(136,'O')
   ,(137,'E'),(137,'O')
   ,(138,'E'),(138,'O')
   ,(139,'E'),(139,'O')
   ,(140,'1H'),(140,'2H'),(140,'TIE')
   ,(141,'1H'),(141,'2H'),(141,'TIE')
   ,(142,'1H'),(142,'2H'),(142,'TIE')
   ,(143,'ao'),(143,'au'),(143,'do'),(143,'du'),(143,'ho'),(143,'hu')
   ,(144,'ao'),(144,'au'),(144,'do'),(144,'du'),(144,'ho'),(144,'hu')
   ,(145,'N'),(145,'Y')
   ,(146,'N'),(146,'Y')
   ,(147,'N'),(147,'Y')
   ,(148,'N'),(148,'Y')
   ,(149,'N'),(149,'Y')
   ,(150,'N'),(150,'Y')
   ,(151,'12'),(151,'1x'),(151,'2x')
   ,(152,'0:0/0:0'),(152,'0:0/0:1'),(152,'0:0/0:2'),(152,'0:0/0:3'),(152,'0:0/1:0'),(152,'0:0/1:1'),(152,'0:0/1:2'),(152,'0:0/2:0'),(152,'0:0/2:1'),(152,'0:0/3:0'),(152,'0:0/4+'),(152,'1:0/1:0'),(152,'1:0/1:1'),(152,'1:0/1:2'),(152,'1:0/2:0'),(152,'1:0/2:1'),(152,'1:0/3:0'),(152,'1:0/4+')
   	---------------  Bet-Radar Phase 2 -------------------------------
   ,(157,'a'),(157,'h')
   ,(159,'G0'),(159,'G1'),(159,'G2'),(159,'G3'),(159,'G4'),(159,'G5'),(159,'G6')
   ,(160,'1'),(160,'2'),(160,'x')
   ,(161,'G0'),(161,'G1'),(161,'G2'),(161,'G3')
   ,(162,'G0'),(162,'G1'),(162,'G2'),(162,'G3')
   ,(163,'AO'),(163,'AU'),(163,'DO'),(163,'DU'),(163,'HO'),(163,'HU')
   ,(164,'1'),(164,'2'),(164,'x')
   ,(165,'0:0'),(165,'0:1'),(165,'0:2'),(165,'1:0'),(165,'1:1'),(165,'2:0')
   ,(166,'0:0'),(166,'0:1'),(166,'0:2'),(166,'0:3'),(166,'1:0'),(166,'1:1'),(166,'1:2'),(166,'2:0'),(166,'2:1'),(166,'3:0')
   ,(167,'1'),(167,'2'),(167,'x')
   ,(168,'a'),(168,'h')
   ,(169,'1-15'),(169,'16-30'),(169,'31-45'),(169,'46-60'),(169,'61-75'),(169,'76-90'),(169,'None')
   ,(170,'A'),(170,'B'),(170,'H'),(170,'N')
   ,(171,'A1'),(171,'A2'),(171,'A3'),(171,'D'),(171,'H1'),(171,'H2'),(171,'H3')
   ,(172,'AA'),(172,'AH'),(172,'DA'),(172,'DH'),(172,'HA'),(172,'HH'),(172,'NO')
   ,(173,'N'),(173,'Y')
   ,(174,'N'),(174,'Y')
   ,(175,'AE'),(175,'AP'),(175,'AR'),(175,'HE'),(175,'HP'),(175,'HR')
   ,(176,'1'),(176,'2'),(176,'X')
   ,(177,'1'),(177,'2'),(177,'X')
   ,(178,'O'),(178,'U')
   ,(179,'G0'),(179,'G1'),(179,'G2'),(179,'G3'),(179,'G4')
   ,(180,'1'),(180,'2'),(180,'X')
   ,(181,'G0'),(181,'G1'),(181,'G2'),(181,'G3')
   ,(182,'G0'),(182,'G1'),(182,'G2'),(182,'G3')
   ,(183,'A'),(183,'H')
   ,(184,'E'),(184,'O')
   ,(185,'A'),(185,'H')
   ,(186,'DA'),(186,'HA'),(186,'HD')
   ,(187,'G0'),(187,'G1'),(187,'G2')
   ,(188,'N'),(188,'Y')
   ,(189,'N'),(189,'Y')
   ,(190,'N'),(190,'Y')
   ,(191,'A'),(191,'H')
   ,(192,'1-10'),(192,'11-20'),(192,'21-30'),(192,'31-40'),(192,'41-50'),(192,'51-60'),(192,'61-70'),(192,'71-80'),(192,'81-90'),(192,'None')
   ,(193,'1-15'),(193,'16-30'),(193,'1-15'),(193,'31-45'),(193,'46-60'),(193,'61-75'),(193,'76-90'),(193,'None')
   ,(194,'O'),(194,'E')
   ,(195,'0-2'),(195,'3-4'),(195,'5-6'),(195,'7-over')
   ,(196,'0-2'),(196,'3-4'),(196,'5-6'),(196,'17-over')
   ,(197,'O'),(197,'U')
   ,(198,'O'),(198,'U')
   ,(199,'0-8'),(199,'9-11'),(199,'12-over')
   ,(200,'0-1'),(200,'2'),(200,'3'),(200,'4-over')
   ,(201,'0-1'),(201,'2'),(201,'3'),(201,'4-over')
   ,(202,'0-4'),(202,'5-6'),(202,'7-over')
   ,(203,'O'),(203,'E')
   ,(204,'O'),(204,'U')
   ,(205,'O'),(205,'U')
   ,(206,'H'),(206,'A'),(206,'N')
   ,(207,'H'),(207,'A'),(207,'N')
   ,(208,'H'),(208,'A'),(208,'N')
   ,(209,'H'),(209,'A'),(209,'N')
   ,(210,'Y'),(210,'N')
   ,(211,'Y'),(211,'N')
   ,(212,'Y'),(212,'N')
   ,(213,'Y'),(213,'N')
   ,(214,'Y'),(214,'N')
   ,(215,'Y'),(215,'N')
   ,(216,'P01'),(216,'P02')
   ,(217,'P01'),(217,'P02')
   	-----------------  PH All-in-One Phase 1  -------------------------------
   ,(401,'o'),(401,'u')
   ,(402,'o'),(402,'u')
   ,(403,'o'),(403,'u')
   ,(404,'o'),(404,'u')
   ,(405,'0:0'),(405,'0:1'),(405,'0:2'),(405,'0:3'),(405,'1:0'),(405,'1:1'),(405,'1:2'),(405,'1:3'),(405,'2:0'),(405,'2:1'),(405,'2:2'),(405,'2:3'),(405,'3:0'),(405,'3:1'),(405,'3:2'),(405,'3:3'),(405,'AOS')
   ,(406,'G0'),(406,'G1'),(406,'G2'),(406,'G3'),(406,'G4'),(406,'G5'),(406,'G6')
   ,(407,'G0'),(407,'G1'),(407,'G2'),(407,'G3')
   ,(408,'A1'),(408,'A2'),(408,'A3'),(408,'D'),(408,'H1'),(408,'H2'),(408,'H3'),(408,'NG')
   ,(409,'G0'),(409,'G1'),(409,'G2'),(409,'G3')
   ,(410,'12'),(410,'1x'),(410,'2x')
   ,(411,'A'),(411,'H')
   ------- Phase 2 ....
   ,(412,'0'),(412,'1'),(412,'2'),(412,'3-Over')
   ,(415,'AA'),(415,'AH'),(415,'DA'),(415,'DH'),(415,'HA'),(415,'HH'),(415,'NO')
   -----------------------Quater--------------------------------
   ,(609,'A'),(609,'H'),(610,'A'),(610,'H'),(612,'A'),(612,'H');

-----------------------------Get Trans-----------------------------------------------------------------------

if object_id('tempdb..#tmpBettrans', 'U') is not null drop table #tmpBettrans
create table #tmpBettrans (
  id int identity (1,1) not null
, custid int, transdate datetime, oddsid int, hdp1 smallmoney, hdp2 smallmoney, oddstype smallint, odds smallmoney, stake money, livehomescore smallint, liveawayscore smallint, liveindicator bit
, betteam nvarchar(10), matchid int, recommend int, mrecommend int, srecommend int, bettype smallint, statusID tinyint -- ticket status
, username nvarchar(30), betid int, currency smallint, currencyName nvarchar(50), actualrate float
);
CREATE UNIQUE CLUSTERED INDEX IX_Bettrans on #tmpBettrans (id, custid, matchid, bettype)

DECLARE @sm AS INT = 5;
DECLARE @c AS INT = 1;
	WHILE @c <= @Tickets
	 BEGIN
		if @bettype1 <> 0 begin
			insert into #tmpBettrans (transdate, oddsid, hdp1, hdp2, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
			,custid, matchid, recommend, mrecommend, srecommend,betid, currency, currencyName, actualrate)
			select distinct (DATEADD(SECOND,@sm,@transdate)), @oddsid1, @hdp1, @hdp2, @odds,
						case when @stakeRM = 0 then @stake  
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))-1)
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then (round(@StakeRM/c.actualrate,0))
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))+1)
						else round(@stakeRM/c.actualrate,0) end
			, @livehomescore, @liveawayscore, @liveindicator, mb.betteam, mb.bettype, @statusid, c.username
			, c.custid, m.matchid, c.recommend, c.mrecommend, c.srecommend,@betid, c.currency, c.currencyName, 
						case when @stakeRM = 0 then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						else round(@StakeRM/(round(@StakeRM/@actualrate,0)),4) end
			from #matrixbettype mb cross join #tmpCustInfo c cross join #tmpMatches m
			where bettype = @bettype1 and mb.betteam = @betteam;
		end
		if @bettype2 <> 0 begin
			insert into #tmpBettrans (transdate, oddsid, hdp1, hdp2, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
			,custid, matchid, recommend, mrecommend, srecommend,betid, currency, currencyName, actualrate)
			select distinct (DATEADD(SECOND,@sm,@transdate)), @oddsid2, @hdp1, @hdp2, @odds,
						case when @stakeRM = 0 then @stake  
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))-1)
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then (round(@StakeRM/c.actualrate,0))
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))+1)
						else round(@stakeRM/c.actualrate,0) end
			, @livehomescore, @liveawayscore, @liveindicator, mb.betteam, mb.bettype, @statusid, c.username
			, c.custid, m.matchid, c.recommend, c.mrecommend, c.srecommend,@betid, c.currency, c.currencyName,
						case when @stakeRM = 0 then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						else round(@StakeRM/(round(@StakeRM/@actualrate,0)),4) end
			from #matrixbettype mb cross join #tmpCustInfo c cross join #tmpMatches m
			where bettype = @bettype2 and mb.betteam = @betteam;
		end
		if @bettype3 <> 0 begin
			insert into #tmpBettrans (transdate, oddsid, hdp1, hdp2, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
			,custid, matchid, recommend, mrecommend, srecommend,betid, currency, currencyName, actualrate)
			select distinct (DATEADD(SECOND,@sm,@transdate)), @oddsid3, @hdp1, @hdp2, @odds,
						case when @stakeRM = 0 then @stake  
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))-1)
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then (round(@StakeRM/c.actualrate,0))
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))+1)
						else round(@stakeRM/c.actualrate,0) end
			, @livehomescore, @liveawayscore, @liveindicator, mb.betteam, mb.bettype, @statusid, c.username
			, c.custid, m.matchid, c.recommend, c.mrecommend, c.srecommend,@betid, c.currency, c.currencyName,
						case when @stakeRM = 0 then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						else round(@StakeRM/(round(@StakeRM/@actualrate,0)),4) end
			from #matrixbettype mb cross join #tmpCustInfo c cross join #tmpMatches m
			where bettype = @bettype3 and mb.betteam = @betteam;
		end
		if @bettype4 <> 0 begin
			insert into #tmpBettrans (transdate, oddsid, hdp1, hdp2, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
			,custid, matchid, recommend, mrecommend, srecommend,betid, currency, currencyName, actualrate)
			select distinct (DATEADD(SECOND,@sm,@transdate)), @oddsid4, @hdp1, @hdp2, @odds,
						case when @stakeRM = 0 then @stake  
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))-1)
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then (round(@StakeRM/c.actualrate,0))
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))+1)
						else round(@stakeRM/c.actualrate,0) end
			, @livehomescore, @liveawayscore, @liveindicator, mb.betteam, mb.bettype, @statusid, c.username
			, c.custid, m.matchid, c.recommend, c.mrecommend, c.srecommend, @betid, c.currency, c.currencyName,
						case when @stakeRM = 0 then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then c.actualrate
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then c.actualrate
						else round(@StakeRM/(round(@StakeRM/@actualrate,0)),4) end
			from #matrixbettype mb cross join #tmpCustInfo c cross join #tmpMatches m
			where bettype = @bettype4 and mb.betteam = @betteam;
		end
		SET @sm = @sm + @steptimeticket
		SET @c=@c+1;
	 END;
-- SELECT * FROM #tmpBettrans

if (@@SERVERNAME in ('TESTDBTRANS') and exists (select 1 from #tmpcustinfo) and exists (select 1 from #tmpbettrans) and exists (select 1 from match(nolock) where matchid = @matchid)) begin	
	insert into dbo.bettrans (transdate, winlostdate,oddsid, hdp1, hdp2, oddstype, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid,custid,matchid,recommend,mrecommend,srecommend, refno,username,betid,currency,CurrencyName,status,oddsspread, virtualrate, actualrate, actual_stake, ip)
	select transdate, @eventdate,oddsid, hdp1, hdp2, @oddstype,odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid,custid,matchid,recommend,mrecommend,srecommend, 100000000000,username,betid,currency,currencyName,'running', 0, @virtualrate, actualrate, stake, @ip
	from #tmpbettrans (nolock) where matchid = @matchid
end

/*
SELECT TOP 100	b.TransID, b.SequenceID, b.TransDate, l.LeagueName, m.SportType, b.MatchID, m.HomeID, m.AwayID, m.EventStatus, m.KickOffTime, m.LeagueID, m.EventDate		
		, b.LiveHomeScore, b.LiveAwayScore,	b.Bettype, b.BetID,	b.CustID, b.Stake, b.Betteam, b.Odds
		, 1 as IsMajorLeague -- hardcode for Json 
		, b.Hdp1, b.Hdp2 -- Skip b.liveindicator
FROM dbo.bettrans AS b WITH(NOLOCK)
	INNER JOIN dbo.match AS m WITH(NOLOCK) ON b.matchid = m.matchid
	INNER JOIN dbo.league AS l WITH(NOLOCK) ON m.leagueid = l.leagueid
where m.matchid = @matchid ORDER BY b.sequenceid ASC
for JSON PATH;
*/

SELECT TOP 100	b.sequenceid, b.transid, b.transdate, m.eventdate		
		, b.bettype, b.custid, b.stake, b.actualrate, b.stake*b.actualrate as StakeRM, b.betteam, b.odds
		, b.liveindicator, b.hdp1, b.hdp2, l.leaguename, m.sporttype, b.livehomescore, b.liveawayscore
FROM dbo.bettrans AS b WITH(NOLOCK)
	INNER JOIN dbo.match AS m WITH(NOLOCK) ON b.matchid = m.matchid
	INNER JOIN dbo.league AS l WITH(NOLOCK) ON m.leagueid = l.leagueid
where m.matchid = @matchid ORDER BY b.sequenceid ASC;

SELECT  [CustId] = ft.CustId, ft.Username
	  , [TransIds] = STUFF((SELECT ',', CONVERT(VARCHAR(20), t1.TransId) 
							FROM dbo.bettrans AS t1 WITH(NOLOCK)
							WHERE t1.CustId = ft.CustId AND t1.MatchId = ft.MatchId 
							FOR XML PATH('')), 1, 1, '')
      ,	[TicketCounter]		= COUNT(1)
FROM dbo.bettrans ft WITH (NOLOCK) 
WHERE ft.MatchID = @matchid
GROUP BY ft.CustId, ft.Username, ft.MatchId, ft.winlostdate;

/*
SELECT [TransIds] = STUFF((SELECT ',', CONVERT(VARCHAR(20), t1.TransId) 
							FROM dbo.bettrans AS t1 WITH(NOLOCK)
							WHERE t1.MatchId = ft.MatchId 
							FOR XML PATH('')), 1, 1, '')
      ,	[TicketCounter]		= COUNT(1)
FROM dbo.bettrans ft WITH (NOLOCK) 
WHERE ft.MatchID = @matchid
GROUP BY ft.MatchId, ft.winlostdate;
*/
