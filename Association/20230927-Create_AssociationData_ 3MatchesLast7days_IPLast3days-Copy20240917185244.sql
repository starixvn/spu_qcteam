/*
	Created:	20230927@John.Ngo
	Task :		Create association by 3 Matches(last 7 days)/ IP(last 3 days) 
	DB:			MainDB
*/

/*
https://nexdev.net/projects/customer-tracking-system/wiki/202209_-_Association_Detection_-_Change_IP_Match_Association_Rule
*/

------ Create association by 3 Matches(last 7 days) ------
/* Rule:
- 2 members: have same matches.
- 3 complete matches: at least 1 time with same bet type, bet team, trans time within 3 mins, same score and ticket stake >=1000 RM per match.
- Effective Days: last 7 days.
- Note: excl. Saba
Display:
- In case of having more than 3 matches, show ALL same matches.
*/
-- ###### Step1: 
/* 20230918-Create_NewMatches.sql 
Attention: EXECUTE bodb02.dbo.Age_SelBalanceUpDay; ----> b.winlostdate > @MoveBetsDay

1. @eventstatus varchar(20) = 'Completed'
2. Create 3 Matches between Today - 7 and Today
	a. @eventdate datetime = DATEADD(DD, -1, DATEDIFF(DD, 0, GETDATE()))
	b. @eventdate datetime = DATEADD(DD, -2, DATEDIFF(DD, 0, GETDATE()))
	...
	d. @eventdate datetime = DATEADD(DD, -6, DATEDIFF(DD, 0, GETDATE()))
	e. @eventdate datetime = DATEADD(DD, -7, DATEDIFF(DD, 0, GETDATE()))
*/

-- ###### Step2: 
/* 20230918-Create_NewTicketsByCustIds
1. @matchid int = 73558239 (get matchid from step1)
2. Create ticket for at least 3 matchids (get matchid from step1)
	@stakeRM money = 10000
	@CustIds varchar(2000) = '121124,169695,954103,1411402,1481207,1775698'
	@betteam varchar(10) = 'h'
	...
*/

-- ###### Step3:
-- 10.18.200.56 - TESTDB061
exec CTS_Association_GetBySharedMatches @ListCustId='121124,169695,954103,1411402,1481207,1775698',@RootCustId=0,@QueryType=1
-- Or Using CTS web: https://cts.nexdev.net/main/AssociationDetection


------ Create association by IP(last 3 days) ------
/* Rule:
	- Same IP at least 1 time in last 3 days for ALL bet types, ALL sports.
	- 1 Level (Direct)
*/
-- ###### Step1: 
/* 20230918-Create_NewMatches.sql 
Attention: EXECUTE bodb02.dbo.Age_SelBalanceUpDay; ----> b.winlostdate > @MoveBetsDay

Create 1 Matches between Today - 3 and Today
	a. @eventdate datetime = DATEADD(DD, -1, DATEDIFF(DD, 0, GETDATE()))
	b. @eventdate datetime = DATEADD(DD, -2, DATEDIFF(DD, 0, GETDATE()))
	c. @eventdate datetime = DATEADD(DD, -3, DATEDIFF(DD, 0, GETDATE()))
*/

-- ###### Step2: 
/* 20230918-Create_NewTicketsByCustIds
1. @matchid int = 73558239 (get matchid from step1)
2. Create ticket for 1 matchid (get matchid from step1)
	@stakeRM money = 10000
	@CustIds varchar(2000) = '121124,169695,954103,1411402,1481207,1775698'
	@betteam varchar(10) = 'h'
	...
*/

-- ###### Step3:
-- 10.18.200.56 - TESTDB061
exec bodb02.[dbo].[CTS_Association_IpSharedLast3Days] @ListCustId = '121124,169695,954103,1411402,1481207,1775698';
-- Or Using CTS web: https://cts.nexdev.net/main/AssociationDetection