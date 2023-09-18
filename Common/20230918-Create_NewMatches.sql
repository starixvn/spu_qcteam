/*
	Created:	20230918@John.Ngo
	Task :		Create New Match from maindb
	DB:			MainDB Local TESTDBPRO (10.18.200.17)
*/

/*
SELECT TOP 10 l.leagueid, l.leaguename, m.matchid, m.homeid, m.awayid, ht.teamname + ' - vs - '+at.teamname [event], m.eventdate, m.eventstatus, m.kickofftime, m.GlobalShowTime, GETDATE() [NOW]
FROM bodb02.dbo.Match m WITH(NOLOCK)
		-- INNER JOIN bodb02.dbo.bettrans b WITH(NOLOCK) ON b.winlostdate = m.eventdate AND b.matchid = m.matchid
		INNER JOIN bodb02.dbo.League l WITH(NOLOCK)	ON m.leagueid = l.leagueid
		INNER JOIN bodb02.dbo.Team ht WITH(NOLOCK) ON m.homeid = ht.teamid
		INNER JOIN bodb02.dbo.Team at WITH(NOLOCK) ON m.awayid = at.teamid
WHERE m.sporttype = 1 AND m.eventstatus = 'Completed' AND l.IsMainMarket = 1 AND l.isTest = 0 AND l.leagueid = 3
		AND m.ParentID IS NULL AND l.LeagueGroupID NOT IN (42,74,108,113,122,151)  -- SABA leagues
		AND l.leaguename NOT LIKE 'Saba%'
ORDER BY NEWID() -- Random

UPDATE dbo.match WITH(ROWLOCK) set eventstatus = 'Completed' where matchid = 70042341; -- running Completed	
DELETE m FROM dbo.match AS m WITH(ROWLOCK) WHERE m.matchcode = 'CTS_Test_J01';	

*/
-- TESTDBPRO (10.18.200.17)
USE bodb02
DECLARE @matchid int = 0, @sporttype smallint = 1
,@bettype1 smallmoney = 1, @bettype2 smallmoney = 0, @bettype3 smallmoney= 0, @bettype4 smallmoney = 0
,@liveindicator bit = 1, @livehomescore int = 0, @liveawayscore int = 0 --, @HTHomeScore INT = 0, @HTAwayScore INT = 0, @FinalHomeScore INT = 0, @FinalAwayScore INT = 0
,@oddsid1 int = 0, @oddsid2 int = 0, @oddsid3 int = 0, @oddsid4 int = 0, @oddsstatus varchar(20) = 'running' -- oddsstatus = 'running', 'closed'
,@leagueid int = 3, @homeid int = 8, @awayid int = 9, @eventstatus varchar(20) = 'running'
,@matchcode varchar(200) = 'CTS_Test_J01', @creator int = 8, @time time = CONVERT(Time, GETDATE())
,@eventdate datetime = '2023-09-14 00:00:00.000' -- DATEADD(DD, 0, DATEDIFF(DD, 0, GETDATE())) 
declare @transdate datetime = @eventdate + CAST(@time AS DATETIME) -- DATEADD(DD, 0, GETDATE()) OR DATEADD(HOUR,10,DATEADD(MINUTE,30,DATEADD(SECOND,0,@eventdate)))
	   ,@kickofftime datetime = DATEADD(DD,0, DATEADD(HOUR,10,DATEADD(MINUTE,20,@eventdate))) -- DATEADD(HOUR,10,DATEADD(MINUTE,20,@eventdate));
------------- Get match info -------------
-- SELECT @eventdate, @transdate, @kickofftime;

if object_id ( 'tempdb..#tmpMatches', 'U') is not null drop table #tmpMatches
create table #tmpMatches(
matchid int
);
if @matchid = 0 begin
	
	select top 1 @leagueid = l.leagueid
			,	@homeid = m.homeid
			,	@awayid = m.awayid
			,	@creator = m.creator
			,	@livehomescore = CASE WHEN @liveindicator = 0 THEN 0 ELSE ISNULL(m.livehomescore,0) END
			,	@liveawayscore = CASE WHEN @liveindicator = 0 THEN 0 ELSE ISNULL(m.liveawayscore,0) END
			-- , m.eventdate, m.matchid, l.leaguename, ht.teamname as hometeam, at.teamname as awayteam, m.ParentID, m.ChildMatchType
			--,	@HTHomeScore = m.hthomescore
			--,	@HTAwayScore = m.htawayscore
			--,	@FinalHomeScore = m.finalhomescore
			--,	@FinalAwayScore = m.finalawayscore
	from bodb02.dbo.Match m WITH(NOLOCK)	
			INNER JOIN bodb02.dbo.League l WITH(NOLOCK)	ON m.leagueid = l.leagueid
			INNER JOIN bodb02.dbo.Team ht WITH(NOLOCK) ON m.homeid = ht.teamid
			INNER JOIN bodb02.dbo.Team at WITH(NOLOCK) ON m.awayid = at.teamid
	WHERE m.sporttype = @sporttype AND l.IsMainMarket = 1 AND l.isTest = 0 AND l.maxstake > 9 AND l.hdp_min > 0 -- AND l.leagueid <> @leagueid
			AND m.ParentID IS NULL AND m.ChildMatchType IS NULL AND l.LeagueGroupID NOT IN (42,74,108,113,122,151) -- SABA leagues
			AND l.leaguename NOT LIKE 'Saba%' -- AND m.eventstatus = 'Completed'
	order by NEWID() -- Random

	insert into dbo.match(leagueid, homeid, awayid, eventstatus, eventdate, kickofftime, GlobalShowTime, creator, matchcode, sporttype, livehomescore, liveawayscore) --, HTHomeScore, HTAwayScore, FinalHomeScore, FinalAwayScore)
					output inserted.matchid into #tmpMatches
					values(@leagueid, @homeid,	@awayid, @eventstatus,@eventdate, @kickofftime, @kickofftime, @creator, @matchcode, @sporttype, @livehomescore, @liveawayscore) --, @HTHomeScore, @HTAwayScore, @FinalHomeScore, @FinalAwayScore)
	select @matchid = matchid from #tmpMatches

	if @bettype1 <> 0 begin
			INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
			SELECT @matchid,@bettype1,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0;
	END
	if @bettype2 <> 0 begin
			INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
			SELECT @matchid,@bettype2,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0;
	END
	if @bettype3 <> 0 begin
			INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
			SELECT @matchid,@bettype3,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0; 
	END
	if @bettype4 <> 0 begin
			INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
			SELECT @matchid,@bettype4,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0;
	END

end
select distinct m.matchid, L.leagueid, l.leaguename, h.teamid, h.teamname, a.teamid, a.teamname, m.eventstatus, m.eventdate, m.kickofftime, m.GlobalShowTime , m.livehomescore, m.liveawayscore
from dbo.match m (NOLOCK)
	inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
	inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
	inner join league l (nolock) on l.leagueid = m.leagueid where m.matchid = @matchid;
insert into #tmpMatches values (@matchid);

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

select top 10 * from [bodb02].[dbo].[odds] od WITH(NOLOCK)
WHERE od.matchid = @matchid

/*
select distinct m.matchid, L.leagueid, l.leaguename, m.homeid, h.teamname, m.awayid, a.teamname, m.eventstatus, m.eventdate, m.kickofftime, m.GlobalShowTime
from dbo.match m (NOLOCK)
	inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
	inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
	inner join league l (nolock) on l.leagueid = m.leagueid where m.matchid >= 69676336 order by m.matchid desc;
*/