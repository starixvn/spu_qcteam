/*
	Created:	20240513@Randy.Nguyen
	Task :		Create script prepare data to run service: Mark PA/Robot from AI, TVS, TW, System Detection ...
	DB:			CTS_DataCenter
	
	Revisions:
			-   20240513@Randy.Nguyen: Created 
*/
########################################################################################################################################################################
###		Mark robot from AI
-- Step 1: Run script in mysql DB - CTS_DataCenter

	SET @ip_CustID = 1838970 ;
	DELETE FROM `CTS_DataCenter`.`RobotDetection`WHERE CustID = @ip_CustID;
	INSERT INTO `CTS_DataCenter`.`RobotDetection` (`CustID`, `PeriodRangeType`, `CreatedDate`, `LastModifiedDate`) VALUES (@ip_CustID, '1', NOW(), NOW());
	SET @LastRD_ID = (SELECT ID FROM `CTS_DataCenter`.`RobotDetection`WHERE CustID = @ip_CustID ORDER BY ID DESC LIMIT 1) - 1;
	UPDATE `CTS_DataCenter`.`SystemParameter` SET ParameterValue = @LastRD_ID WHERE ParameterID = 94;

	-- SELECT * FROM `CTS_DataCenter`.`RobotDetection` ORDER BY ID DESC;
	-- SELECT * FROM SystemParameter WHERE ParameterID IN (94);

-- Step 2: Trigger service: CTS_RobotAIImperva_Minutely_Classification

########################################################################################################################################################################
###		Mark robot from TW:
-- Step 1: Run script in mainDB - server: 10.18.200.58 - db: ON_USER

  DECLARE @ip_CustID INT = 1838970;
  
  SELECT *,  CAST(CONVERT(BIGINT, TSTAMP) AS INT) AS "TSTAMP_INT" FROM [ON_USER].[dbo].[RobotUsers] ;
  UPDATE  [ON_USER].[dbo].[RobotUsers] SET custid = @ip_CustID  where tstamp = ....; -- RowVersionAsBigInt = 650001

-- Step 2: Run script in mysql DB - CTS_DataCenter

	UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = .... WHERE (`ParameterID` = '3');
	-- SELECT * FROM CTS_DataCenter.SystemParameter where ParameterID = 3;

-- Step 3: Trigger service: CC.CTS_CustomerClassification_Minutely_RobotTWScan

########################################################################################################################################################################
###		Mark PA from TVS:

-- Step 1: Run script in mainDB - server: TESTDB061 - db: bodb02

Declare @custid int = 1841357;

INSERT INTO [bodb02].[dbo].[TicketVoiding_Request] (Sporttype,ActionId,DecidedBy,Remark,UserId,CreatedDate,LastModifiedBy,LastModifiedDate,IsTest,IssueTypeId) Values
(1,1,'starix3','qc test',169368,getdate(),169368,getdate(),0,11);

Declare @RequestId int = (select top 1 (RequestId) from  [bodb02].[dbo].[TicketVoiding_Request] where UserId = 169368 order by CreatedDate desc);

INSERT INTO [bodb02].[dbo].[TicketVoiding_RequestDetail]  (RequestId,MatchId,LeagueId,HomeId,AwayId,RequestType,SubIssueTypeId) values
(@RequestId,70087703,3,5,8,0,28);

Declare @RequestDetailId int = (select top 1 ID from  [bodb02].[dbo].[TicketVoiding_RequestDetail] where requestid = @RequestId);

INSERT INTO [bodb02].[dbo].[TicketVoiding_RequestDetailTicket_single] (RequestId,IssueTypeId,SubIssueTypeId,TransId,MatchId,RequestDetailId,Bettype,BetId,CustId,SiteDBGroupID,IsProcessed) values
(@RequestId,11,28,102857169589764096,70087703,@RequestDetailId,1,0,@custid,3,1);

SELECT TOP (1000) *  FROM [bodb02].[dbo].[TicketVoiding_Request]					where RequestId = @RequestId;
SELECT TOP (1000) *  FROM [bodb02].[dbo].[TicketVoiding_RequestDetail]				where RequestId = @RequestId;
select TOP (1000) *  FROM [bodb02].[dbo].[TicketVoiding_RequestDetailTicket_single] where RequestId = @RequestId;

/*## Delete test data
 Declare @RequestId int = (select top 1 (RequestId) from  [bodb02].[dbo].[TicketVoiding_Request] where UserId = 169368 order by CreatedDate desc);
 delete from [bodb02].[dbo].[TicketVoiding_Request] where RequestId = @RequestId;
 delete from [bodb02].[dbo].[TicketVoiding_RequestDetail] where RequestId = @RequestId;
 delete from [bodb02].[dbo].[TicketVoiding_RequestDetailTicket_single] where RequestId = @RequestId;
 */

-- Step 2: Run script in mysql DB - CTS_DataCenter

SELECT @LastScannedTVS := DATE_ADD(NOW(), INTERVAL -5 Minute);
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` =  @LastScannedTVS WHERE (`ParameterID` = '2');

-- Step 3: Trigger service: CTS_CC.CTS_CustomerClassification_Secondly_TVSProblemAccountInsert

########################################################################################################################################################################
###		Mark System Dectect Group Betting:

-- Step 1: Run script in mysql DB - CTS_DataCenter:

SET @Custid = 1838970;
SET @matchid := (
    SELECT mm.MatchID
    FROM CTS_DataCenter.MatchMonitor AS mm
    INNER JOIN CTS_DataCenter.MatchMonitorDetails AS mmd ON mm.MatchID = mmd.MatchID
    WHERE mm.SportType IN (1, 2) AND mmd.Reason = 0 and mm.reason= 0
    ORDER BY mm.KickOffTime ASC
    LIMIT 1
);
SET @mmid := ( SELECT ID FROM CTS_DataCenter.MatchMonitor where matchid = @matchid and reason= 0 ORDER BY ID LIMIT 1 ) ;
SET @mmdid := ( SELECT ID FROM CTS_DataCenter.MatchMonitorDetails where matchid = @matchid and reason= 0 ORDER BY ID LIMIT 1 ) ;
UPDATE CTS_DataCenter.MatchMonitor SET ClassifyStatus = 2 where ID = @mmid;
UPDATE CTS_DataCenter.MatchMonitorDetails SET ClassifyStatus = 0, HighStakeLicCustList = @custid where ID = @mmdid;
UPDATE `CTS_DataCenter`.`SystemParameter` SET `ParameterValue` = '0' WHERE (`ParameterID` = '96');

-- Step 2: Trigger service: CTS_CC.CTS_CustomerClassification_Secondly_MatchMonitorGBClassify
