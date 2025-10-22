/*Live: @ip_PoolType:=1001; Non-Live: @ip_PoolType:=2001
3687509,3689373,3691244 (device lv1)
3691760,3694852 (ip last 3d)
3695428,3698112 (device lv2)
*/
update CTS_DataCenter.SystemParameter set ParameterValue = 0  where ParameterID IN (171, 172, 173, 174); 
DELETE FROM CTS_DataCenter.MatchMonitor where MatchID IN (95082201,95082202,95082203);
DELETE FROM CTS_DataCenter.MatchMonitorDetails where MatchID IN (95082201,95082202,95082203);
DELETE FROM CTS_DataCenter.MatchMonitorParlayStagingGroupBettingLive where MatchID IN (95082201,95082202,95082203);
DELETE FROM CTS_DataCenter.MatchMonitorParlayStagingGroupBettingNonLive where MatchID IN (95082201,95082202,95082203);

SELECT * FROM CTS_DataCenter.SystemParameter where ParameterID IN (171, 172, 173, 174); 
SELECT * FROM CTS_DataCenter.MatchMonitor where MatchID IN (95082201,95082202,95082203);
SELECT * FROM CTS_DataCenter.MatchMonitorDetails where MatchID IN (95082201,95082202,95082203);
SELECT * FROM CTS_DataCenter.MatchMonitorParlayStagingGroupBettingLive where MatchID not IN (95082201,95082202,95082203);
SELECT * FROM CTS_DataCenter.MatchMonitorParlayStagingGroupBettingNonLive where MatchID IN (95082201,95082202,95082203);

-- Start 2 service Parlay GB Rule --> After execute each round.
-- Round 1: Sliding transtime <= 3 mins 
-- "MatchID":"95082201"(300000000000000011,300000000000000021); "MatchID":"95082202"(300000000000000012,300000000000000022,300000000000000032); "MatchID":"95082203"(300000000000000013,300000000000000031)
CALL CTS_DataCenter.CTS_DC_MatchMonitorParlay_Staging_Insert_xtest(
              @ip_LiveIndicator:=1
            , @ip_PoolType:=1001
            , @ip_TransList:='[
					 {"SequenceID":"300000000001","TransID":"300000000000000001","Refno":"30000001","TransIDm":"300000000000000011","TransDate":"2024-09-24 00:01:01.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3687509","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
					,{"SequenceID":"300000000001","TransID":"300000000000000001","Refno":"30000001","TransIDm":"300000000000000012","TransDate":"2024-09-24 00:01:02.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3687509","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
					,{"SequenceID":"300000000001","TransID":"300000000000000001","Refno":"30000001","TransIDm":"300000000000000013","TransDate":"2024-09-24 00:01:03.000","MatchID":"95082203","SportType":"1","LiveHomeScore":"2","LiveAwayScore":"0","BetTypeID":"8","BetID":"","BetTeam":"a","CustID":"3687509","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"19","AwayID":"20","LeagueID":"42","LeagueName":"GERMANY CUP"}
					
                    ,{"SequenceID":"300000000002","TransID":"300000000000000002","Refno":"30000002","TransIDm":"300000000000000021","TransDate":"2024-09-24 00:04:01.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3689373","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
                    ,{"SequenceID":"300000000002","TransID":"300000000000000002","Refno":"30000002","TransIDm":"300000000000000022","TransDate":"2024-09-24 00:04:02.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3689373","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
                
                    ,{"SequenceID":"300000000003","TransID":"300000000000000003","Refno":"30000003","TransIDm":"300000000000000031","TransDate":"2024-09-24 00:04:03.000","MatchID":"95082203","SportType":"1","LiveHomeScore":"2","LiveAwayScore":"0","BetTypeID":"8","BetID":"","BetTeam":"a","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"19","AwayID":"20","LeagueID":"42","LeagueName":"GERMANY CUP"}
                    ,{"SequenceID":"300000000003","TransID":"300000000000000003","Refno":"30000003","TransIDm":"300000000000000032","TransDate":"2024-09-24 00:04:04.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
                ]'
            );		
-- Round 2: Sliding transtime > 3 mins --> IGNORE with round 1
CALL CTS_DataCenter.CTS_DC_MatchMonitorParlay_Staging_Insert_xtest(
              @ip_LiveIndicator:=1
            , @ip_PoolType:=1001
            , @ip_TransList:='[
                     {"SequenceID":"300000000004","TransID":"300000000000000004","Refno":"30000004","TransIDm":"300000000000000041","TransDate":"2024-09-24 00:07:02.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3687509","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
					,{"SequenceID":"300000000004","TransID":"300000000000000004","Refno":"30000004","TransIDm":"300000000000000042","TransDate":"2024-09-24 00:07:05.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3687509","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
                ]'
            );		
-- Round 3: Only 1 cust --> IGNORE with round 1 & 2
CALL CTS_DataCenter.CTS_DC_MatchMonitorParlay_Staging_Insert_xtest(
              @ip_LiveIndicator:=1
            , @ip_PoolType:=1001
            , @ip_TransList:='[
					 {"SequenceID":"300000000005","TransID":"300000000000000005","Refno":"30000005","TransIDm":"300000000000000051","TransDate":"2024-09-24 00:08:03.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3691760","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
					,{"SequenceID":"300000000005","TransID":"300000000000000005","Refno":"30000005","TransIDm":"300000000000000052","TransDate":"2024-09-24 00:08:04.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3691760","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
					,{"SequenceID":"300000000006","TransID":"300000000000000006","Refno":"30000006","TransIDm":"300000000000000061","TransDate":"2024-09-24 00:08:05.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3695428","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
					,{"SequenceID":"300000000006","TransID":"300000000000000006","Refno":"30000006","TransIDm":"300000000000000062","TransDate":"2024-09-24 00:08:06.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3695428","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
                ]'
            );	
-- Round 4: Sliding transtime <= 3 mins
-- "MatchID":"95082201"(300000000000000041,300000000000000071); "MatchID":"95082202"(300000000000000042,300000000000000072)
-- Ass by IP last 3d, Ass by Device lv2 --> IGNORE
CALL CTS_DataCenter.CTS_DC_MatchMonitorParlay_Staging_Insert_xtest(
              @ip_LiveIndicator:=1
            , @ip_PoolType:=1001
            , @ip_TransList:='[
					 {"SequenceID":"300000000007","TransID":"300000000000000007","Refno":"30000007","TransIDm":"300000000000000071","TransDate":"2024-09-24 00:10:02.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3689373","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
                    ,{"SequenceID":"300000000007","TransID":"300000000000000007","Refno":"30000007","TransIDm":"300000000000000072","TransDate":"2024-09-24 00:10:05.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3689373","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
					,{"SequenceID":"300000000008","TransID":"300000000000000008","Refno":"30000008","TransIDm":"300000000000000081","TransDate":"2024-09-24 00:11:03.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3694852","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
                    ,{"SequenceID":"300000000008","TransID":"300000000000000008","Refno":"30000008","TransIDm":"300000000000000082","TransDate":"2024-09-24 00:11:04.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3694852","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
					,{"SequenceID":"300000000009","TransID":"300000000000000009","Refno":"30000009","TransIDm":"300000000000000091","TransDate":"2024-09-24 00:11:05.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3698112","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
                    ,{"SequenceID":"300000000009","TransID":"300000000000000009","Refno":"30000009","TransIDm":"300000000000000092","TransDate":"2024-09-24 00:11:06.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"h","CustID":"3698112","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
               ]'
            );	
-- Round 5: Differ: Sporttype / Bettype / BetID / ScoreDiff / Betteam --> IGNORE
CALL CTS_DataCenter.CTS_DC_MatchMonitorParlay_Staging_Insert_xtest(
              @ip_LiveIndicator:=1
            , @ip_PoolType:=1001
            , @ip_TransList:='[
					 {"SequenceID":"300000000010","TransID":"300000000000000010","Refno":"30000010","TransIDm":"300000000000000110","TransDate":"2024-09-24 00:12:01.000","MatchID":"95082204","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"610","BetID":"802","BetTeam":"h","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
                    ,{"SequenceID":"300000000011","TransID":"300000000000000011","Refno":"30000011","TransIDm":"300000000000000111","TransDate":"2024-09-24 00:12:02.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"610","BetID":"802","BetTeam":"o","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
					,{"SequenceID":"300000000012","TransID":"300000000000000012","Refno":"30000012","TransIDm":"300000000000000112","TransDate":"2024-09-24 00:12:03.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"803","BetTeam":"h","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
					,{"SequenceID":"300000000013","TransID":"300000000000000013","Refno":"30000013","TransIDm":"300000000000000113","TransDate":"2024-09-24 00:12:04.000","MatchID":"95082201","SportType":"1","LiveHomeScore":"1","LiveAwayScore":"1","BetTypeID":"1","BetID":"","BetTeam":"h","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"5","AwayID":"6","LeagueID":"3","LeagueName":"*ENGLISH PREMIER LEAGUE"}
					,{"SequenceID":"300000000014","TransID":"300000000000000014","Refno":"30000014","TransIDm":"300000000000000114","TransDate":"2024-09-24 00:12:05.000","MatchID":"95082202","SportType":"2","LiveHomeScore":"1","LiveAwayScore":"0","BetTypeID":"609","BetID":"802","BetTeam":"a","CustID":"3691244","EventDate":"2024-09-24 00:00:00.000","KickOffTime":"2024-09-24 03:36:00","EventStatus":"running","HomeID":"7","AwayID":"8","LeagueID":"4","LeagueName":"*ITALY SERIE A"}
                ]'
            );	