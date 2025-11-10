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
DECLARE @matchid int = 0, @sporttype smallint = 6, @CreateChildMatches bit = 0
,@oddsid1 int = 0, @oddsid2 int = 0, @oddsid3 int = 0, @oddsid4 int = 0, @oddsstatus varchar(20) = 'running' -- oddsstatus = 'running', 'closed'
,@bettype1 smallmoney = 1, @bettype2 smallmoney = 2, @bettype3 smallmoney= 3, @bettype4 smallmoney = 20
,@leagueid int = 0, @homeid int = 0, @awayid int = 0, @eventstatus varchar(20) = 'running' -- running Completed
,@liveindicator bit = 1, @livehomescore int = 0, @liveawayscore int = 0 --, @HTHomeScore INT = 0, @HTAwayScore INT = 0, @FinalHomeScore INT = 0, @FinalAwayScore INT = 0
,@matchcode varchar(200) = 'CTS_Test_DangerMonitor1', @creator int = 8
,@eventdate datetime =  DATEADD(DD, 0, DATEDIFF(DD, 0, GETDATE())) -- '2023-09-14 00:00:00.000'
declare @kickofftime datetime = DATEADD(DD,0, DATEADD(HOUR,10,DATEADD(MINUTE,20,@eventdate))) -- DATEADD(HOUR,10,DATEADD(MINUTE,20,@eventdate));

SELECT @eventdate AS eventdate , @kickofftime AS kickofftime;

------------- Get match info -------------
if object_id ( 'tempdb..#tmpMatches', 'U') is not null drop table #tmpMatches
create table #tmpMatches(
matchid int
);

-- Validate sporttype exists in League table
IF NOT EXISTS (SELECT 1 FROM bodb02.dbo.League WITH(NOLOCK) WHERE sporttype = @sporttype AND IsMainMarket = 1 AND isTest = 0)
BEGIN
    RAISERROR ('No valid leagues found for sporttype %d. Please check the sporttype parameter.', 16, 1, @sporttype);
    RETURN;
END

-- Validate teams exist for the sporttype
IF NOT EXISTS (SELECT 1 FROM bodb02.dbo.Team WITH(NOLOCK) WHERE SportType = @sporttype AND IsActive = 1)
BEGIN
    RAISERROR ('No valid teams found for sporttype %d. Please check the sporttype parameter.', 16, 1, @sporttype);
    RETURN;
END

if @matchid = 0 begin
	
	-- Select existing active League and Teams from 3 tables based on SportType
	DECLARE @selectedleagueid int = 0, @selectedhomeid int = 0, @selectedawayid int = 0
	
	-- Select a random active league for the sporttype (main leagues only - not in LeagueSetting)
	SELECT TOP 1 @selectedleagueid = l.leagueid
	FROM bodb02.dbo.League l WITH(NOLOCK)
		LEFT JOIN bodb02.dbo.LeagueSetting ls WITH(NOLOCK) ON l.leagueid = ls.Leagueid
	WHERE l.sporttype = @sporttype 
		AND l.IsMainMarket = 1 
		AND l.isTest = 0 
		AND l.IsActive = 1
		AND l.IsDeleted = 0
		AND l.LeagueGroupID NOT IN (42,74,108,113,122,151) -- SABA leagues
		AND l.leaguename NOT LIKE 'Saba%'
		AND ls.Leagueid IS NULL -- Only main leagues (not in LeagueSetting)
	ORDER BY NEWID() -- Random selection
	
	-- Select first team (home team) - exclude set-based teams
	SELECT TOP 1 @selectedhomeid = teamid
	FROM bodb02.dbo.Team WITH(NOLOCK)
	WHERE SportType = @sporttype 
		AND IsActive = 1 
		AND IsDeleted = 0
		AND teamname NOT LIKE '%(1st Set)%'
		AND teamname NOT LIKE '%(2nd Set)%'
		AND teamname NOT LIKE '%(3rd Set)%'
		AND teamname NOT LIKE '%(4th Set)%'
		AND teamname NOT LIKE '%(5th Set)%'
        AND teamname NOT LIKE '%(6th Set)%'
		AND teamname NOT LIKE '%(7th Set)%'
	ORDER BY NEWID()
	
	-- Select second team (away team) - different from home team, exclude set-based teams
	IF @selectedhomeid > 0
	BEGIN
		SELECT TOP 1 @selectedawayid = teamid
		FROM bodb02.dbo.Team WITH(NOLOCK)
		WHERE SportType = @sporttype 
			AND IsActive = 1 
			AND IsDeleted = 0
			AND teamid != @selectedhomeid
			AND teamname NOT LIKE '%(1st Set)%'
			AND teamname NOT LIKE '%(2nd Set)%'
			AND teamname NOT LIKE '%(3rd Set)%'
			AND teamname NOT LIKE '%(4th Set)%'
			AND teamname NOT LIKE '%(5th Set)%'
            AND teamname NOT LIKE '%(6th Set)%'
			AND teamname NOT LIKE '%(7th Set)%'
		ORDER BY NEWID()
	END
	
	-- Get other settings from existing match (like creator, live scores, etc.)
	SELECT TOP 1 @creator = m.creator
			,	@livehomescore = CASE WHEN @liveindicator = 0 THEN 0 ELSE ISNULL(m.livehomescore,0) END
			,	@liveawayscore = CASE WHEN @liveindicator = 0 THEN 0 ELSE ISNULL(m.liveawayscore,0) END
			-- , m.eventdate, m.matchid, l.leaguename, ht.teamname as hometeam, at.teamname as awayteam, m.ParentID, m.ChildMatchType
			--,	@HTHomeScore = m.hthomescore
			--,	@HTAwayScore = m.htawayscore
			--,	@FinalHomeScore = m.finalhomescore
			--,	@FinalAwayScore = m.finalawayscore
	FROM bodb02.dbo.Match m WITH(NOLOCK)	
			INNER JOIN bodb02.dbo.League l WITH(NOLOCK)	ON m.leagueid = l.leagueid
			INNER JOIN bodb02.dbo.Team ht WITH(NOLOCK) ON m.homeid = ht.teamid
			INNER JOIN bodb02.dbo.Team at WITH(NOLOCK) ON m.awayid = at.teamid
	WHERE m.sporttype = @sporttype 
			AND l.IsMainMarket = 1 AND l.isTest = 0 AND l.maxstake > 9 AND l.hdp_min > 0
			AND m.ParentID IS NULL AND m.ChildMatchType IS NULL 
			AND l.LeagueGroupID NOT IN (42,74,108,113,122,151) -- SABA leagues
			AND l.leaguename NOT LIKE 'Saba%' -- AND m.eventstatus = 'Completed'
	ORDER BY NEWID() -- Random
	
	-- Set the league and team IDs from our selection
	SET @leagueid = @selectedleagueid
	SET @homeid = @selectedhomeid
	SET @awayid = @selectedawayid

	-- Validate that we successfully found active league and teams
	IF @leagueid = 0 OR @homeid = 0 OR @awayid = 0
	BEGIN
		RAISERROR ('No active leagues or teams found for sporttype %d. Please check if there are active records in League, LeagueSetting, and Team tables.', 16, 1, @sporttype);
		RETURN;
	END

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

	-- Create Child Matches if requested
	IF @CreateChildMatches = 1 AND @matchid > 0 and @sporttype = 18
	BEGIN
		DECLARE @ChildMatchType int = 0
		DECLARE @childleagueid int = 0
		DECLARE @childhomeid int = 0, @childawayid int = 0
		DECLARE @hometeamname varchar(200), @awayteamname varchar(200)
		
		-- Get home and away team names for child matches
		SELECT @hometeamname = teamname FROM bodb02.dbo.Team WITH(NOLOCK) WHERE teamid = @homeid
		SELECT @awayteamname = teamname FROM bodb02.dbo.Team WITH(NOLOCK) WHERE teamid = @awayid
		
		-- Create child matches for all sets (1st, 2nd, 3rd, 4th, 5th, 6th, 7th) + Points Handicap
		DECLARE @setnumber int = 1
		DECLARE @childmatchtypes TABLE (SetNumber int, ChildMatchType int, SetName varchar(50))
		
		-- Define child match types based on image
		INSERT INTO @childmatchtypes VALUES 
		(1, 12, 'First Set Winner'),
		(2, 14, 'Second Set Winner'),
		(3, 15, 'Third Set Winner'),
		(4, 16, 'Fourth Set Winner'),
		(5, 17, 'Fifth Set Winner'),
		(6, 18, 'Sixth Set Winner'),
		(7, 19, 'Seventh Set Winner'),
		(0, 11, 'Points Handicap') -- Special case for Points Handicap
		
		-- Loop through each set to create child matches
		DECLARE child_cursor CURSOR FOR 
		SELECT SetNumber, ChildMatchType, SetName FROM @childmatchtypes
		
		OPEN child_cursor
		FETCH NEXT FROM child_cursor INTO @setnumber, @ChildMatchType, @hometeamname
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Find child league for this set based on set name pattern
			SELECT TOP 1 @childleagueid = l.leagueid
			FROM bodb02.dbo.League l WITH(NOLOCK)
				INNER JOIN bodb02.dbo.LeagueSetting ls WITH(NOLOCK) ON l.leagueid = ls.Leagueid
			WHERE l.sporttype = @sporttype 
				AND l.leaguename LIKE '%' + CASE 
					WHEN @setnumber = 0 THEN 'Points Handicap'
					WHEN @setnumber = 1 THEN 'First Set Winner'
					WHEN @setnumber = 2 THEN 'Second Set Winner'
					WHEN @setnumber = 3 THEN 'Third Set Winner'
					WHEN @setnumber = 4 THEN 'Fourth Set Winner'
					WHEN @setnumber = 5 THEN 'Fifth Set Winner'
					WHEN @setnumber = 6 THEN 'Sixth Set Winner'
					WHEN @setnumber = 7 THEN 'Seventh Set Winner'
					ELSE 'Set Winner'
				END + '%'
				AND ls.ChildLeagueType IS NOT NULL
				AND l.IsActive = 1
				AND l.IsDeleted = 0
                AND l.isTest = 0
			
			-- Find child teams for this set
			IF @setnumber = 0 -- Points Handicap
			BEGIN
				-- For Points Handicap, use regular teams
				SET @childhomeid = @homeid
				SET @childawayid = @awayid
			END
			ELSE
			BEGIN
				-- For set-based matches, find teams with matching set
				SELECT TOP 1 @childhomeid = teamid
				FROM bodb02.dbo.Team WITH(NOLOCK)
				WHERE SportType = @sporttype 
					AND IsActive = 1 
					AND IsDeleted = 0
					AND teamname LIKE '%(' + CAST(@setnumber AS varchar(10)) + CASE 
						WHEN @setnumber = 1 THEN 'st'
						WHEN @setnumber = 2 THEN 'nd'
						WHEN @setnumber = 3 THEN 'rd'
						ELSE 'th'
					END + ' Set)%'
				
				SELECT TOP 1 @childawayid = teamid
				FROM bodb02.dbo.Team WITH(NOLOCK)
				WHERE SportType = @sporttype 
					AND IsActive = 1 
					AND IsDeleted = 0
					AND teamname LIKE '%(' + CAST(@setnumber AS varchar(10)) + CASE 
						WHEN @setnumber = 1 THEN 'st'
						WHEN @setnumber = 2 THEN 'nd'
						WHEN @setnumber = 3 THEN 'rd'
						ELSE 'th'
					END + ' Set)%'
                    AND teamid != @childhomeid

			END
			
			-- Create child match if we found valid league and teams
			IF @childleagueid > 0 AND @childhomeid > 0 AND @childawayid > 0
			BEGIN
				-- Debug: Print what we're about to insert
				PRINT 'Creating Child Match - Set: ' + CAST(@setnumber AS varchar(10)) + ', Type: ' + CAST(@ChildMatchType AS varchar(10)) + ', League: ' + CAST(@childleagueid AS varchar(10)) + ', Home: ' + CAST(@childhomeid AS varchar(10)) + ', Away: ' + CAST(@childawayid AS varchar(10)) + ', ParentID: ' + CAST(@matchid AS varchar(10))
				
				-- Create child match with ChildMatchType value (11, 12, 14, 15, 16, 17, 18, 19)
				INSERT INTO dbo.match(leagueid, homeid, awayid, eventstatus, eventdate, kickofftime, GlobalShowTime, creator, matchcode, sporttype, livehomescore, liveawayscore, ParentID, ChildMatchType)
				VALUES(@childleagueid, @childhomeid, @childawayid, @eventstatus, @eventdate, @kickofftime, @kickofftime, @creator, @matchcode + '_Child_' + CAST(@setnumber AS varchar(10)), @sporttype, @livehomescore, @liveawayscore, @matchid, @ChildMatchType)
				
				-- Get the auto-generated MatchID of the child match
				DECLARE @childmatchid_new int = SCOPE_IDENTITY()
				
				PRINT 'Child Match Created - MatchID: ' + CAST(@childmatchid_new AS varchar(10)) + ', ChildMatchType: ' + CAST(@ChildMatchType AS varchar(10))
				
				if @bettype1 <> 0 begin
					INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
					SELECT @childmatchid_new,@bettype1,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0;
				END
				if @bettype2 <> 0 begin
					INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
					SELECT @childmatchid_new,@bettype2,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0;
				END
				if @bettype3 <> 0 begin
					INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
					SELECT @childmatchid_new,@bettype3,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0; 
				END
				if @bettype4 <> 0 begin
					INSERT INTO [bodb02].[dbo].[odds] ([matchid],[bettype],oddsstatus,liveindicator,livehomescore, liveawayscore,[sporttype],TBRepKey,[SecAccept],[EnableVirtualRate],[IsDeleted])
					SELECT @childmatchid_new,@bettype4,@oddsstatus,@liveindicator,@livehomescore,@liveawayscore,@sporttype,123456,20,1,0;
				END
			END
			ELSE
			BEGIN
				-- Debug: Print why child match was not created
				PRINT 'Skipping Child Match - Set: ' + CAST(@setnumber AS varchar(10)) + ', Type: ' + CAST(@ChildMatchType AS varchar(10)) + ' - LeagueID: ' + CAST(@childleagueid AS varchar(10)) + ', HomeID: ' + CAST(@childhomeid AS varchar(10)) + ', AwayID: ' + CAST(@childawayid AS varchar(10))
			END
			
			FETCH NEXT FROM child_cursor INTO @setnumber, @ChildMatchType, @hometeamname
		END
		
		CLOSE child_cursor
		DEALLOCATE child_cursor
	END

end

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

--select top 10 * from [bodb02].[dbo].[odds] od WITH(NOLOCK)
--WHERE od.matchid = @matchid

-- =============================================
-- VERIFICATION SECTION - RETURN MAIN MATCH AND CHILD MATCHES
-- =============================================

PRINT '=== MAIN MATCH VERIFICATION ==='
select distinct m.matchid, L.leagueid, l.leaguename, m.homeid, h.teamname, m.awayid, a.teamname, m.eventstatus, m.eventdate, m.kickofftime, m.GlobalShowTime , m.livehomescore, m.liveawayscore, m.ParentID, m.ChildMatchType
from dbo.match m (NOLOCK)
	inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
	inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
	inner join league l (nolock) on l.leagueid = m.leagueid 
where m.matchid = @matchid;

-- Return child matches if they were created
IF @CreateChildMatches = 1 AND @matchid > 0 AND @sporttype = 18
BEGIN
	PRINT '=== CHILD MATCHES VERIFICATION ==='
	select distinct m.matchid, L.leagueid, l.leaguename, m.homeid, h.teamname, m.awayid, a.teamname, m.eventstatus, m.eventdate, m.kickofftime, m.GlobalShowTime , m.livehomescore, m.liveawayscore, m.ParentID, m.ChildMatchType
	from dbo.match m (NOLOCK)
		inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
		inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
		inner join league l (nolock) on l.leagueid = m.leagueid 
	where m.ParentID = @matchid
	order by m.ChildMatchType;
	
	-- Count child matches created
	DECLARE @childmatchcount int = 0
	SELECT @childmatchcount = COUNT(*) FROM dbo.match m (NOLOCK) WHERE m.ParentID = @matchid
	PRINT 'Total Child Matches Created: ' + CAST(@childmatchcount AS varchar(10))
	
	-- Show child match types created
	PRINT '=== CHILD MATCH TYPES CREATED ==='
	select m.ChildMatchType, 
		   CASE m.ChildMatchType
			   WHEN 11 THEN 'Points Handicap'
			   WHEN 12 THEN 'First Set Winner'
			   WHEN 14 THEN 'Second Set Winner'
			   WHEN 15 THEN 'Third Set Winner'
			   WHEN 16 THEN 'Fourth Set Winner'
			   WHEN 17 THEN 'Fifth Set Winner'
			   WHEN 18 THEN 'Sixth Set Winner'
			   WHEN 19 THEN 'Seventh Set Winner'
			   ELSE 'Unknown'
		   END as ChildMatchTypeName,
		   l.leaguename,
		   h.teamname + ' vs ' + a.teamname as Teams
	from dbo.match m (NOLOCK)
		inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
		inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
		inner join league l (nolock) on l.leagueid = m.leagueid 
	where m.ParentID = @matchid
	order by m.ChildMatchType;
END
ELSE
BEGIN
	PRINT '=== NO CHILD MATCHES CREATED ==='
	PRINT 'Reason: CreateChildMatches=' + CAST(@CreateChildMatches AS varchar(1)) + ', MatchID=' + CAST(@matchid AS varchar(10)) + ', SportType=' + CAST(@sporttype AS varchar(10))
END

-- Return all match IDs (main + child matches) separated by comma
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM dbo.match m (NOLOCK) WHERE m.ParentID = @matchid)
        THEN CAST(@matchid AS varchar(10)) + ',' + 
             STUFF((
                 SELECT ',' + CAST(matchid AS varchar(10))
                 FROM dbo.match m (NOLOCK) 
                 WHERE m.ParentID = @matchid
                 ORDER BY m.ChildMatchType
                 FOR XML PATH('')
             ), 1, 1, '')
        ELSE CAST(@matchid AS varchar(10))
    END as AllMatchIDs
WHERE @matchid > 0;

/*
select distinct m.matchid, L.leagueid, l.leaguename, m.homeid, h.teamname, m.awayid, a.teamname, m.eventstatus, m.eventdate, m.kickofftime, m.GlobalShowTime
from dbo.match m (NOLOCK)
	inner join dbo.team a (NOLOCK) on a.teamid = m.awayid 
	inner join dbo.team h (NOLOCK) on h.teamid = m.homeid 
	inner join league l (nolock) on l.leagueid = m.leagueid where m.matchid >= 73558239  and m.matchcode = 'CTS_Test_J01' order by m.matchid desc;
*/