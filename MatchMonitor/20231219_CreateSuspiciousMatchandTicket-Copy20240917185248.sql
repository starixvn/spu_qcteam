/*
	Created:	20231218@Randy.Nguyen
	Task :		Create script to create Suspicious Match/Ticket
	DB:			CTS_DataCenter, 10.18.200.17 (TESTDBPRO), 10.18.200.55 (TESTDBTRANS )
	
	
	Revisions:
			- 20231218@Randy.Nguyen: Created
			- 20240228@Lisa.Phan: Update LB
			- 20240701@Lisa.Phan: add LeagueGroupID for Saba 
*/


SELECT  
-- MatchMonitor
	@MatchID :=	77254707		
,	@SportType :=	1, 	@LeagueID :=	5 ,	@LeagueName := '*GERMANY-BUNDESLIGA I',	@HomeID :=	8 , @AwayID :=	9
,   @LeagueGroupID := NULL -- Saba: 42, Others: NULL
,	@EventStatus  := 'running'
,	@BettypeID :=	1	
, 	@BetID := 0 		-- Soccer: 0, Basketball: 0/80X, Esports: 0/80X/80XYY 
,	@LiveIndicator  := 0	,	@Reason := 2		-- 0: GB , 1: HED, 2: ARB, 3: FG, 58: IRR, 4: LB
, 	@EventDate := '2023-12-11 00:00:00.000'	,	@KickOffTime := '2023-12-11 01:30:00'  	-- define "match setion"
,	@IsVerified := 0
-- MatchMonitorDetail
,	 @GroupID := 2 -- 0: FG, LB | >=1: GB, HED, ARB, IRR
,	@ListTransID := '196111221802401799,196111221802401811,196111221802401823'
		-- select transid from maindb: select top 500  transid from dbo.bettrans where matchid = 77254707 and bettype =1 ; 
,	@ListCustID := '1284,4359501,4359569'			-- 	102572090,101993845,76309594,49705225			
		-- From maindb:	select  distinct top 500  custid from dbo.bettrans where transid in (@ListTransID);
,	@HDP := 0.75
,	@LiveHomeScore := 0	,	@LiveAwayScore := 0
,	@Betteam := ''  -- 0: GB , 1: HED, 58: IRR betteam depended on bettype, 2: ARB, 3: FG betteam is NULL
,	@ScoreDiff := @LiveHomeScore*10000 + @LiveAwayScore
,   @InsertDate :=  date_sub(cast(Now() as date), interval 1 day), @InsertTime :=  date_sub(Now(), interval 1 day) -- default generate is current time/date
;

/*=====================================================================================================================================================================================*/	

-- insert match in cts
INSERT IGNORE INTO `CTS_DataCenter`.`MatchMonitor` 
(`EventDate`, `BettypeID`, `MatchID`, `IsMajorLeague`, `LiveIndicator`, `Reason`, `KickOffTime`, `EventStatus`, `HomeID`, `AwayID`, `LeagueID`, `IsVerified`, `LeagueName`, `SportType`, `BetID`, `ClassifyStatus`, `InsertTime`, `InsertDate`, `LeagueGroupID`) VALUES 
(@EventDate, @BettypeID, @MatchID, '1', @LiveIndicator , @Reason, @KickOffTime, @EventStatus , @HomeID, @AwayID, @LeagueID,@IsVerified,@LeagueName,@SportType, @BetID, '0', @InsertTime, @InsertDate, @LeagueGroupID);

INSERT INTO `CTS_DataCenter`.`MatchMonitorDetails` 
(`MatchID`, `IsMajorLeague`, `LiveIndicator`, `BettypeID`, `HDP`, `GroupID`, `Reason`, `ListCustID`, `ListTransID`, `EventDate`, `LiveHomeScore`, `LiveAwayScore`, `BetID`, `ClassifyStatus`, `Betteam`, `InsertTime`, `ScoreDiff`) VALUES 
(@MatchID, '1', @LiveIndicator, @BettypeID, @HDP, @GroupID, @Reason, @ListCustID , @ListTransID, @EventDate, @LiveHomeScore, @LiveAwayScore, @BetID, '0', @Betteam, @InsertTime, @ScoreDiff);

 SELECT * from `CTS_DataCenter`.`MatchMonitor` where MatchID = @MatchID;
 SELECT * from `CTS_DataCenter`.`MatchMonitorDetails` where MatchID = @MatchID;
