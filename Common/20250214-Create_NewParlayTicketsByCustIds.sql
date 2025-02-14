/*
	Created:	20250214@John.Ngo
	Task :		Create New Parlay ticket from maindb
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

SELECT TOP (1000) * FROM [dbo].bettrans b (NOLOCK) WHERE b.refno = 1000000002348097938;
SELECT TOP (1000) * FROM [dbo].bettransm b (NOLOCK) WHERE b.refno = 1000000002348097938
ORDER BY b.winlostdate desc;

select top(1000)  b.transid, b.refno, bm.TransId AS mtransid, b.username, b.status, bm.status AS mstatus, b.betteam, bm.betteam AS mbetteam, b.*, bm.*
from bettrans b with(nolock)
	inner join [bodb02].[dbo].bettransm bm with(nolock) on bm.refno = b.refno
	inner join [bodb02].[dbo].match m with(nolock) on m.matchid = bm.matchid
	inner join CustDB.dbo.customer c with(nolock) on c.custid = b.custid
where b.refno = 1000000002348097723 
	
DELETE b FROM dbo.bettrans AS b WITH(NOLOCK)
INNER JOIN dbo.match AS m WITH(NOLOCK) ON b.matchid = m.matchid
WHERE m.matchcode = 'CTS_Test_J01';
	
DELETE m FROM dbo.match AS m WITH(ROWLOCK) WHERE m.matchcode = 'CTS_Test_J01';

DELETE b FROM [bodb02].dbo.bettrans AS b
	INNER JOIN dbo.bettransm AS bm WITH(NOLOCK) ON b.refno = bm.refno
where bm.matchid in (83695726,83695727,83695728);
DELETE FROM [bodb02].[dbo].bettransm where matchid in (83695726,83695727,83695728);
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
-- M28RMB06001,MBRM55568,M28RMB06027,12BETAUD02001,12BETAUD02002,12BETAUD02003
   Custid in (121124,169695,954103,1411402,1481207,1775698)
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
DECLARE @matchids varchar(2000) = '83730188,83730189' -- Enter matchid here to create tickets into that match. If leave blank, a random match will be selected
,@matchid1 int, @matchid2 INT, @matchid3 int
,@stakeRM money = 500, @stake money = 2000 ,@currency smallint = 16, @actualrate float = 4.1723, @virtualrate float = 4.1723
 -- @stakeRM <> 0 -> Create tickets ~ stakeRM value, not check @stake value
,@CustIds varchar(2000) = '1176092,121124' -- Create ticket for custids list
,@bettype1 smallmoney = 1, @bettype2 smallmoney = 3, @bettype3 SMALLMONEY = 1
,@liveindicator1 bit = 0, @liveindicator2 bit = 0, @liveindicator3 bit = 1, @livehomescore int = 0, @liveawayscore int = 0 --, @HTHomeScore INT = 0, @HTAwayScore INT = 0, @FinalHomeScore INT = 0, @FinalAwayScore INT = 0
,@hdp1 smallmoney = 0, @hdp2 smallmoney = 0.5 -- (0.25 - 0.5 - 0.75 - 1 ...)
,@oddsid1 int = 0, @oddsid2 int = 0, @oddsid3 int = 0
,@odds1 smallmoney = 1.65, @odds2 smallmoney = 1.8, @odds3 smallmoney = 1.95, @oddsType tinyint = 1, @statusid int = 0, @status varchar(20) = 'running' ---- odds, oddsType, {@statusid,@status}: ticket status -----
/* @statusid = 0,111,112,113; @status = 'running','DRAW','WON','LOSE'*/
,@ip varchar(45) = '161.142.250.65' -- ipv4 '10.164.168.09', '161.142.250.65' --ipv6:  '240e:465:1f32:2dd3:64a6:d7ff:fed9:3046'
,@refno bigint, @betcheckmain tinyint -- 2: combo2, 4: combo3
,@betteammain varchar(10) = 1 /*betteam = 1 mix parlay */ ,@betteam varchar(10) = 'a', @time time = CONVERT(Time, GETDATE())
,@betid1 int = 0, @betid2 int = 0, @betid3 int = 0
,@hdp1main smallmoney = 1, @hdp2main smallmoney = 2 -- @hdp2main = 2: combo2, 3: combo3
,@oddsidmain int = 1  -- 1: combo2, 99: combo3
,@oddsmain smallmoney = 0

DECLARE @Step INT = 5

------------- Get match -------------
declare @eventdate datetime =  DATEADD(DD, 0, DATEDIFF(DD, 0, GETDATE())), @kickofftime datetime;

declare @transdate datetime = @eventdate + CAST(@time AS DATETIME) -- DATEADD(DD, 0, GETDATE()) OR DATEADD(HOUR,10,DATEADD(MINUTE,30,DATEADD(SECOND,0,@eventdate)))
declare @transdate2 datetime = DATEADD(HOUR,0,DATEADD(MINUTE,ABS(CHECKSUM(NEWID()) % 2),DATEADD(SECOND, ABS(CHECKSUM(NEWID()) % 59),@transdate))) -- Random (2m59s)
-- SELECT @eventdate AS eventdate , @kickofftime AS kickofftime, @transdate AS transdate, @transdate2

if object_id ( 'tempdb..#tmpMatches', 'U') is not null drop table #tmpMatches
create table #tmpMatches(id int primary key identity(1,1), matchid int);
select distinct m.sporttype, m.matchid, l.leaguename, h.teamname, a.teamname, m.eventstatus, m.eventdate, m.kickofftime, m.GlobalShowTime, m.livehomescore, m.liveawayscore
from dbo.match m (NOLOCK)
	inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
	inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
	inner join league l (nolock) on l.leagueid = m.leagueid 
	inner join (SELECT val as MatchId FROM dbo.f_SplitString(@matchids, ',')) AS cc ON cc.MatchId = m.MatchId

insert into #tmpMatches
SELECT val as MatchId FROM dbo.f_SplitString(@matchids, ',');
-- SELECT * FROM #tmpMatches

-- Main ticket
if ((SELECT count(1) FROM #tmpMatches) = 2) begin
	SELECT @betcheckmain = 2, @hdp2main = 2, @oddsidmain = 1, @oddsmain = 0;
end

if ((SELECT count(1) FROM #tmpMatches) = 3) begin
	SELECT @betcheckmain = 4, @hdp2main = 3, @oddsidmain = 99, @oddsmain = 0;
end

if @bettype1 <> 0 begin
	select top 1 @oddsid1 = od.oddsid, @matchid1 = mm.matchid from bodb02.dbo.Match m WITH(NOLOCK)	
			INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
			INNER JOIN #tmpMatches AS mm ON mm.MatchId = m.MatchId
	where od.bettype = @bettype1 AND mm.id = 1;

	if @oddsid1 = 0 begin
		select top 1 @oddsid1 = od.oddsid, @matchid1 = mm.matchid from bodb02.dbo.Match m WITH(NOLOCK)	
		INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
		INNER JOIN #tmpMatches AS mm ON mm.MatchId = m.MatchId
		where mm.id = 1;
	end
end
if @bettype2 <> 0 begin
	select top 1 @oddsid2 = od.oddsid, @matchid2 = mm.matchid from bodb02.dbo.Match m WITH(NOLOCK)	
		INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
		INNER JOIN #tmpMatches AS mm ON mm.MatchId = m.MatchId
	where od.bettype = @bettype2 AND mm.id = 2;
	
	if @oddsid2 = 0 begin
		select top 1 @oddsid2 = od.oddsid, @matchid2 = mm.matchid from bodb02.dbo.Match m WITH(NOLOCK)	
		INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
		INNER JOIN #tmpMatches AS mm ON mm.MatchId = m.MatchId
		where mm.id = 2;
	end

end
if @bettype3 <> 0 AND ((SELECT count(1) FROM #tmpMatches) = 3) begin
	select top 1 @oddsid3 = od.oddsid, @matchid3 = mm.matchid from bodb02.dbo.Match m WITH(NOLOCK)	
		INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
		INNER JOIN #tmpMatches AS mm ON mm.MatchId = m.MatchId
	where od.bettype = @bettype3 AND mm.id = 3;

	if @oddsid3 = 0 begin
		select top 1 @oddsid3 = od.oddsid, @matchid3 = mm.matchid from bodb02.dbo.Match m WITH(NOLOCK)	
		INNER JOIN [bodb02].[dbo].[odds] od WITH(NOLOCK) ON m.matchid = od.matchid
		INNER JOIN #tmpMatches AS mm ON mm.MatchId = m.MatchId
		where mm.id = 3;
	end
end

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
    AND ci.mrecommend NOT IN (27899314,11656504,12146012)
    AND ci.recommend NOT IN (52466,5707545,29270764,134456,27787409,48367475)
    AND ci.username NOT LIKE '%CashOut'
    /* Remove oddsfeed site */
    AND ag.site NOT IN ('NextBet','9wickets','9wsports')
-- SELECT * FROM #tmpCustInfo;

----------------------------Get Bettype Matrix--------------------------------------------------
if object_id ( 'tempdb..#matrixBettype', 'U') is not null drop table #matrixBettype
create table #matrixBettype(
  id int identity(1,1) primary key
, bettype smallint
, betteam nvarchar(10)
)
insert into #matrixBettype(bettype, betteam)
values
    (1,'a'),(1,'h') -- HDP
   ,(2,'a'),(2,'h') -- O/E
   ,(3,'a'),(3,'h') -- O/U
   ,(4,'0:0'),(4,'0:1'),(4,'0:2'),(4,'0:3'),(4,'0:4'),(4,'0:5'),(4,'1:0'),(4,'1:1'),(4,'1:2'),(4,'1:3'),(4,'1:4'),(4,'2:0'),(4,'2:1'),(4,'2:2'),(4,'2:3'),(4,'2:4'),(4,'3:0'),(4,'3:1'),(4,'3:2'),(4,'3:3'),(4,'3:4'),(4,'4:0'),(4,'4:1'),(4,'4:2'),(4,'4:3'),(4,'4:4'),(4,'5:0') -- Correct Score
   ,(5,'1'),(5,'2'),(5,'x') -- FT.1X2
   ,(6,'0-1'),(6,'2-3'),(6,'4-6'),(6,'7-over') -- Total Goal
   ,(7,'a'),(7,'h') -- 1H HDP
   ,(8,'a'),(8,'h') -- 1H O/U
   ,(12,'a'),(12,'h') -- 1H O/E
   ,(13,'an'),(13,'ay'),(13,'hn'),(13,'hy') -- Clean Sheet
   ,(14,'0:0'),(14,'1:1'),(14,'1:2'),(14,'2:1'),(14,'2:2') -- First Goal/Last Goal
   ,(15,'1'),(15,'2'),(15,'x') -- 1H 1X2
   ,(16,'0:0'),(16,'0:1'),(16,'0:2'),(16,'1:0'),(16,'1:1'),(16,'1:2'),(16,'2:0'),(16,'2:1'),(16,'2:2') -- HT/FT
   ,(17,'a'),(17,'h') -- 2H HDP
   ,(18,'o'),(18,'u') -- 2H O/U
   ,(20,'h'),(20,'a') -- Moneyline
   ,(21,'h'),(21,'a') -- 1H Moneyline
   ,(22,'1'),(22,'2'),(22,'x') -- Next Goal
   ,(24,'12'),(24,'1x'),(24,'2x') -- Double Chance
   ,(25,'a'),(25,'h') -- Draw No Bet
   ,(26,'b'),(26,'n'),(26,'o') -- Both/One/Neither Team To Score
   ,(27,'a'),(27,'h') -- To Win To Nil
   ,(28,'1'),(28,'2'),(28,'x') -- 3-Way Handicap
   ,(30,'0:0'),(30,'0:1'),(30,'0:2'),(30,'0:3'),(30,'0:4'),(30,'1:0'),(30,'1:1'),(30,'1:2'),(30,'1:3'),(30,'2:0'),(30,'2:1'),(30,'2:2'),(30,'2:3'),(30,'3:0'),(30,'3:1'),(30,'3:2'),(30,'3:3'),(30,'4:0') -- 1H Correct Score
   ,(121,'a'),(121,'x') -- Home No Bet
   ,(122,'h'),(122,'x') -- Away No Bet
   ,(123,'a'),(123,'h') -- Draw/No Draw
   ,(124,'a'),(124,'h') -- FT.1X2 HDP
   ,(126,'0-1'),(126,'2-3'),(126,'4-over') -- 1H Total Goal
   ,(127,'0:0'),(127,'1:1'),(127,'1:2'),(127,'2:1'),(127,'2:2') -- 1H First Goal/Last Goal
   ,(128,'ee'),(128,'eo'),(128,'oe'),(128,'oo') -- HT/FT Odd/Even
   ,(129,'0'),(129,'1'),(129,'2'),(129,'3'),(129,'4'),(129,'5&over') -- Exact 1H Goal
   ,(130,'0'),(130,'1'),(130,'2'),(130,'3'),(130,'4'),(130,'5'),(130,'6'),(130,'7&over') -- Exact Goal
   ,(131,'0-1'),(131,'2-3'),(131,'4&Over') -- Home Team Total Goal
   ,(132,'0-1'),(132,'2-3'),(132,'4&Over') -- Away Team Total Goal
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
   ,(413,'0:0'),(413,'0:1'),(413,'0:2'),(413,'0:3'),(413,'0:4'),(413,'1:0'),(413,'1:1'),(413,'1:2'),(413,'1:3'),(413,'1:4'),(413,'2:0'),(413,'2:1'),(413,'2:2'),(413,'2:3'),(413,'2:4'),(413,'3:0'),(413,'3:1'),(413,'3:2'),(413,'3:3'),(413,'3:4'),(413,'4:0'),(413,'4:1'),(413,'4:2'),(413,'4:3'),(413,'4:4'),(413,'AOS') -- Correct Score
   ,(414,'0:0'),(414,'0:1'),(414,'0:2'),(414,'0:3'),(414,'1:0'),(414,'1:1'),(414,'1:2'),(414,'1:3'),(414,'2:0'),(414,'2:1'),(414,'2:2'),(414,'2:3'),(414,'3:0'),(414,'3:1'),(414,'3:2'),(414,'3:3'),(414,'AOS') -- 1H Correct Score
   ,(415,'AA'),(415,'AH'),(415,'DA'),(415,'DH'),(415,'HA'),(415,'HH'),(415,'NO')
   -----------------------Quater--------------------------------
   ,(609,'A'),(609,'H'),(610,'O'),(610,'U'),(611,'O'),(611,'E'),(612,'A'),(612,'H'),(613,'A'),(613,'H'),(615,'O'),(615,'U'),(616,'O'),(616,'U'),(617,'A'),(617,'H')

   ,(9001,'A'),(9001,'H'),(9002,'A'),(9002,'H'),(9003,'O'),(9003,'U'),(9005,'O'),(9005,'E'),(9006,'A'),(9006,'H') -- 80X
   ,(9007,'A'),(9007,'H'),(9068,'A'),(9068,'H'),(9070,'O'),(9070,'U'),(9071,'O'),(9071,'E'),(9072,'A'),(9072,'H'),(9077,'A'),(9077,'H'),(9089,'O'),(9089,'U') -- 80XYY
   ,(9101,'A'),(9101,'H'),(9102,'A'),(9102,'H'),(9103,'A'),(9103,'H'),(9104,'A'),(9104,'H') -- Map X 1st Kill -- 80X
      -----------------------Cricket(50)--------------------------------
   ,(501,'A'),(501,'H') -- Match Winner
   ,(9400,'A'),(9400,'H') -- Super Over Winner
   ,(9401,'A'),(9401,'H') -- Toss Winner
   ,(9404,'O'),(9404,'U') -- Home Inns Runs
   ,(9405,'O'),(9405,'U') -- Away Inns Runs
   ,(9406,'O'),(9406,'U') -- Home 1st Inns Runs
   ,(9407,'O'),(9407,'U') -- Away 1st Inns Runs
   ,(9408,'O'),(9408,'U') -- Home 2nd Inns Runs
   ,(9409,'O'),(9409,'U') -- Away 2nd Inns Runs
   ;
   
IF @betid1 = 0 BEGIN
	SELECT	@betid1 = CASE WHEN (@bettype1 BETWEEN 609 AND 617) OR (@bettype1 BETWEEN 9001 AND 9006) OR (@bettype1 BETWEEN 9101 AND 9104) THEN 801
						  WHEN (@bettype1 BETWEEN 9007 AND 9089) THEN 80105
						  ELSE 0 END
END

IF @betid2 = 0 BEGIN
	SELECT	@betid2 = CASE WHEN (@bettype2 BETWEEN 609 AND 617) OR (@bettype2 BETWEEN 9001 AND 9006) OR (@bettype2 BETWEEN 9101 AND 9104) THEN 802
						  WHEN (@bettype2 BETWEEN 9007 AND 9089) THEN 80210
						  ELSE 0 END
END

IF @betid3 = 0 BEGIN
	SELECT	@betid3 = CASE WHEN (@bettype3 BETWEEN 609 AND 617) OR (@bettype3 BETWEEN 9001 AND 9006) OR (@bettype3 BETWEEN 9101 AND 9104) THEN 803
						  WHEN (@bettype3 BETWEEN 9007 AND 9089) THEN 80310
						  ELSE 0 END
END

-----------------------------Get Trans-----------------------------------------------------------------------
if object_id('tempdb..#tmpBettrans') is not null drop table #tmpBettrans
create table #tmpBettrans (
  id int identity (1,1) not null
, custid bigint, transdate datetime, oddsid int, hdp1 smallmoney, hdp2 smallmoney, oddstype smallint default(1), odds smallmoney, stake money, livehomescore smallint, liveawayscore smallint, liveindicator bit
, betteam nvarchar(10), matchid int, winlostdate smalldatetime, recommend int, mrecommend int, srecommend int, refno bigint, bettype smallint, statusID tinyint, betcheck nvarchar(50)
, username nvarchar(30), betid int, currency smallint, currencyName nvarchar(50), actualrate float
);
CREATE UNIQUE CLUSTERED INDEX IX_Bettrans on #tmpBettrans (id, custid, matchid, bettype)

if object_id('tempdb..#tmpBettransm') is not null drop table #tmpBettransm
create table #tmpBettransm (
  id int identity (1,1) not null
, custid bigint, transdate datetime, oddsid int, hdp1 smallmoney, hdp2 smallmoney, oddstype smallint default(1), odds smallmoney, stake money, livehomescore smallint, liveawayscore smallint, liveindicator bit
, betteam nvarchar(10), matchid int, winlostdate smalldatetime, recommend int, mrecommend int, srecommend int, refno bigint, bettype smallint, statusID tinyint
, username nvarchar(30), betid int, currency smallint, currencyName nvarchar(50), actualrate float
);
CREATE UNIQUE CLUSTERED INDEX IX_Bettrans on #tmpBettransm (id, custid, matchid, bettype)

DECLARE	@StartRow	INT = 1
	,	@StopRow	INT 
	,	@MaxRow		INT 
	,	@Threshold	INT = 1
	,	@CustId		BIGINT

SET @MaxRow = (SELECT COUNT(1) FROM #tmpCustInfo);
SET @StopRow = @Threshold;
SELECT TOP 1 @refno = MAX(b.refno) FROM [dbo].bettrans b (NOLOCK);

WHILE (1=1)
BEGIN
	SELECT TOP 1 @CustId = CustId FROM #tmpCustInfo AS c WHERE c.ID  = @StartRow;
	SET @refno = @refno + 1;

	IF @CustId IS NOT NULL
		BEGIN
			UPDATE f WITH(ROWLOCK, UPDLOCK)
				SET f.CustId = @CustId
			FROM #tmpCustInfo AS f WHERE f.ID = @StartRow
		END

	IF @CustId IS NULL
		BEGIN
			SELECT TOP 1 @CustId = CustId FROM #tmpCustInfo AS c ORDER BY NEWID();

			UPDATE f WITH(ROWLOCK, UPDLOCK)
				SET f.CustId = @CustId
			FROM #tmpCustInfo AS f WHERE f.ID = @StartRow
		END
	
	WAITFOR DELAY '00:00:0.100';

	if @bettype1 <> 0 BEGIN
		SELECT @eventdate = MAX(m.eventdate) 
		from dbo.match m (NOLOCK)
		INNER JOIN #tmpMatches mm ON m.matchid = mm.matchid;

		insert into #tmpBettrans (transdate, oddsid, hdp1, hdp2, oddstype, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username, betcheck
		,custid, matchid, winlostdate, recommend, mrecommend, srecommend, refno, betid, currency, currencyName, actualrate)
		select distinct (DATEADD(SECOND,@Step,@transdate)), @oddsidmain, @hdp1main, @hdp2main, 1, @oddsmain, 
						case when @stakeRM = 0 then @stake  
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))-1)
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then (round(@StakeRM/c.actualrate,0))
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))+1)
						else round(@stakeRM/c.actualrate,0) end
		, 0, 0, 0, @betteammain, 29, @statusid, c.username, @betcheckmain
		, c.custid, 29, @eventdate, c.recommend, c.mrecommend, c.srecommend, @refno, 0, c.currency, c.currencyName, c.actualrate
		from #matrixbettype mb cross join #tmpCustInfo c
		where mb.bettype = @bettype1 and mb.betteam = @betteam and c.custid = @CustId and c.ID = @StartRow;

		select	@livehomescore = CASE WHEN @liveindicator1 = 0 THEN 0 ELSE m.livehomescore END
		,	@liveawayscore = CASE WHEN @liveindicator1 = 0 THEN 0 ELSE m.liveawayscore END
		,	@eventdate = m.eventdate, @kickofftime = m.kickofftime
		from dbo.match m (NOLOCK) WHERE m.matchid = @matchid1;

		insert into #tmpBettransm (transdate, oddsid, hdp1, hdp2, oddstype, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
		,custid, matchid, winlostdate, recommend, mrecommend, srecommend, refno, betid, currency, currencyName, actualrate)
		select distinct (DATEADD(SECOND,@Step,@transdate)), @oddsid1, @hdp1, @hdp2, @oddstype, @odds1, 
						case when @stakeRM = 0 then @stake  
						when round(((round(@StakeRM/c.actualrate,0))-1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))-1)
						when round((round(@StakeRM/c.actualrate,0))*c.actualrate,0,1) = @StakeRM then (round(@StakeRM/c.actualrate,0))
						when round(((round(@StakeRM/c.actualrate,0))+1)*c.actualrate,0,1) = @StakeRM then ((round(@StakeRM/c.actualrate,0))+1)
						else round(@stakeRM/c.actualrate,0) end
		, @livehomescore, @liveawayscore, @liveindicator1, mb.betteam, @bettype1, @statusid, c.username
		, c.custid, @matchid1, @eventdate, c.recommend, c.mrecommend, c.srecommend, @refno, @betid1, c.currency, c.currencyName, c.actualrate
		from #matrixbettype mb cross join #tmpCustInfo c
		where mb.bettype = @bettype1 and mb.betteam = @betteam and c.custid = @CustId and c.ID = @StartRow;
	end

	if @bettype2 <> 0 BEGIN
		select	@livehomescore = CASE WHEN @liveindicator2 = 0 THEN 0 ELSE m.livehomescore END
		,	@liveawayscore = CASE WHEN @liveindicator2 = 0 THEN 0 ELSE m.liveawayscore END
		,	@eventdate = m.eventdate, @kickofftime = m.kickofftime
		from dbo.match m (NOLOCK) WHERE m.matchid = @matchid2;

		insert into #tmpBettransm (transdate, oddsid, hdp1, hdp2, oddstype, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
		,custid, matchid, winlostdate, recommend, mrecommend, srecommend, refno, betid, currency, currencyName, actualrate)
		select distinct (DATEADD(SECOND,@Step,@transdate)), @oddsid2, @hdp1, @hdp2, @oddstype, @odds2, 0
		, @livehomescore, @liveawayscore, @liveindicator2, mb.betteam, @bettype2, @statusid, c.username
		, c.custid, @matchid2, @eventdate, c.recommend, c.mrecommend, c.srecommend, @refno, @betid2, c.currency, c.currencyName, c.actualrate
		from #matrixbettype mb cross join #tmpCustInfo c
		where mb.bettype = @bettype2 and mb.betteam = @betteam and c.custid = @CustId and c.ID = @StartRow;
	END

	if @bettype3 <> 0 AND ((SELECT count(1) FROM #tmpMatches) = 3) BEGIN
		select	@livehomescore = CASE WHEN @liveindicator3 = 0 THEN 0 ELSE m.livehomescore END
		,	@liveawayscore = CASE WHEN @liveindicator3 = 0 THEN 0 ELSE m.liveawayscore END
		,	@eventdate = m.eventdate, @kickofftime = m.kickofftime
		from dbo.match m (NOLOCK) WHERE m.matchid = @matchid3;

		insert into #tmpBettransm (transdate, oddsid, hdp1, hdp2, oddstype, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, statusid, username
		,custid, matchid, winlostdate, recommend, mrecommend, srecommend, refno, betid, currency, currencyName, actualrate)
		select distinct (DATEADD(SECOND,@Step,@transdate)), @oddsid3, @hdp1, @hdp2, @oddstype, @odds3, 0
		, @livehomescore, @liveawayscore, @liveindicator3, mb.betteam, @bettype3, @statusid, c.username
		, c.custid, @matchid3, @eventdate, c.recommend, c.mrecommend, c.srecommend, @refno, @betid3, c.currency, c.currencyName, c.actualrate
		from #matrixbettype mb cross join #tmpCustInfo c
		where mb.bettype = @bettype3 and mb.betteam = @betteam and c.custid = @CustId and c.ID = @StartRow;
	end

	SET @StartRow = @StopRow + 1;
	SET @StopRow = @StopRow + @Threshold;
	SET @CustId = NULL;

	IF @StartRow > @MaxRow
	BEGIN
		BREAK;
	END
END;
 --SELECT * FROM #tmpBettrans
 --SELECT * FROM #tmpBettransm
 --RETURN

if (@@SERVERNAME in ('TESTDBTRANS') and exists (select 1 from #tmpcustinfo) and exists (select 1 from #tmpbettrans)) begin	
	insert into dbo.bettrans (transdate, winlostdate,oddsid, hdp1, hdp2, oddstype, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, betcheck, bettype, statusid,custid,matchid,recommend,mrecommend,srecommend, refno,username,betid,currency,CurrencyName,status,oddsspread, virtualrate, actualrate, actual_stake, ip,creator,apositiontaking,mpositiontaking,spositiontaking,tpositiontaking)
	select transdate, @eventdate,oddsid, hdp1, hdp2, oddstype,odds, stake, livehomescore, liveawayscore, liveindicator, betteam, betcheck, bettype, statusid,custid,matchid,recommend,mrecommend,srecommend, refno,username,betid,currency,currencyName,@status, 0, @virtualrate, actualrate, stake, @ip,custid,0.3,0.4,0.2,0.9
	from #tmpbettrans (nolock)
END

if (exists (select 1 from #tmpcustinfo) and exists (select 1 from #tmpbettransm)) begin	
	insert into dbo.bettransm (transdate, winlostdate,matchdate,oddsid, hdp1, hdp2, odds, finalodds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, betcheck, statusid,custid,matchid,refno,status,oddsspread, actualrate,creator,apositiontaking,mpositiontaking,spositiontaking,tpositiontaking)
	select transdate, NULL,winlostdate,oddsid, hdp1, hdp2, odds, odds, stake, livehomescore, liveawayscore, liveindicator, betteam, bettype, 0, statusid,custid,matchid,refno,@status, 0, actualrate,custid,0.3,0.4,0.2,0.9
	from #tmpbettransm (nolock)
end

/*
select top(1000)  b.transid, b.refno, bm.TransId AS mtransid, b.username, b.status, bm.status AS mstatus, b.betteam, bm.betteam AS mbetteam, b.*, bm.*
from bettrans b with(nolock)
	inner join [bodb02].[dbo].bettransm bm with(nolock) on bm.refno = b.refno
	INNER JOIN #tmpMatches AS mm WITH(NOLOCK) ON bm.matchid = mm.matchid
	inner join CustDB.dbo.customer c with(nolock) on c.custid = b.custid
-- for JSON PATH;
*/
SELECT DISTINCT TOP 100	b.transid, b.sequenceid, b.transdate, b.winlostdate, b.refno
		, b.matchid, b.bettype, b.custid, b.stake, b.actualrate, b.stake*b.actualrate as StakeRM, b.betteam, b.betfrom, b.betcheck, b.odds
		, b.liveindicator, b.hdp1, b.hdp2, b.livehomescore, b.liveawayscore
FROM dbo.bettrans AS b WITH(NOLOCK)
	INNER JOIN dbo.bettransm AS bm WITH(NOLOCK) ON b.refno = bm.refno
	INNER JOIN #tmpMatches AS mm WITH(NOLOCK) ON bm.matchid = mm.matchid
ORDER BY b.transid ASC;

SELECT TOP 100	b.transid, b.transdate, m.eventdate, b.refno
		, b.matchid, b.bettype, b.custid, b.stake, b.actualrate, b.stake*b.actualrate as StakeRM, b.betteam, b.betfrom, b.betcheck, b.odds
		, b.liveindicator, b.hdp1, b.hdp2, l.leaguename, m.sporttype, b.livehomescore, b.liveawayscore
FROM dbo.bettransm AS b WITH(NOLOCK)
	INNER JOIN dbo.match AS m WITH(NOLOCK) ON b.matchid = m.matchid
	INNER JOIN #tmpMatches AS mm WITH(NOLOCK) ON b.matchid = mm.matchid
	INNER JOIN dbo.league AS l WITH(NOLOCK) ON m.leagueid = l.leagueid
ORDER BY b.transid ASC;
