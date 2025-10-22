USE [bodb_VR2Model]
GO
/****** Object:  StoredProcedure [dbo].[CTS_ProblemAccountsClassification_Daily]    Script Date: 6/6/2024 8:30:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBVR2-bodb_VR2Model" executers="bodbSPUNet" isFunction="0" isNested="0"></info>*/  
ALTER PROCEDURE [dbo].[CTS_ProblemAccountsClassification_Daily]  
 @ListCustIds   VARCHAR(MAX),  
 @FunctionId    SMALLINT = 12  
AS  
/*  
 Created: 20220328@Long.Luu  
 Task : Classify Problem Account -  Daily  
 DB: bodb_VR2Model  
 Original:  
  
 Revisions:  
  - 20220328@Long.Luu: Created [Redmine ID: #170468]  
  - 20221118@Jonas.Huynh: Update parameter of DW SP GetCustAccumulatedInfo [Redmine ID: #179500]  
  - 20230601@Jonas.Huynh: Update SP get accumulated performance (Renovate Phase2) [Redmine ID: #186684]  
  - 20230627@Jonas.Huynh: Reset Balance for Credit with Inactive Normal with new place-bet [Redmine ID: #189876]  
  - 20230807@Jonas.Huynh: HF exclude Non-sport for General [Redmine ID: #192388]  
  - 20230726@Jonas.Huynh: Saba Classification [Redmine ID: #185320]  
  
 Param's Explanation:  
*/  
BEGIN  
   
 SET NOCOUNT ON;  
  
 DECLARE @PROBLEMACCOUNT_LOSING  INT = 0  
  , @PROBLEMACCOUNT_KEEPSTATE INT = 1  
  , @PROBLEMACCOUNT_WINNING  INT = 2;  
  
 DECLARE @CurrentDateTime   DATETIME = GETDATE();  
 DECLARE @CurrentDate    DATE  = GETDATE();  
  
 DECLARE @SportGroup_SabaVRSoccer  SMALLINT = 145,  
   @SportGroup_SabaVRBasketball SMALLINT = 912,  
   @SportGroup_NonSport   SMALLINT = 229;  
  
 IF OBJECT_ID('tempdb..#tmpRawData') IS NOT NULL  
  DROP TABLE #tmpRawData;  
  
 CREATE TABLE #tmpRawData(  
  CustId     INT   NOT NULL,  
  SportGroup    INT   NOT NULL,  
  TurnoverRM    DECIMAL(19, 4) NOT NULL,  
  WinlossRM    DECIMAL(19, 4) NOT NULL,  
  TurnoverORG    DECIMAL(19, 4) NOT NULL,  
  WinlossORG    DECIMAL(19, 4) NOT NULL,  
  BetCount    BIGINT   NOT NULL,  
  ActiveDaysCustID  INT   NOT NULL,  
	ActiveDaysSportGroup INT   NOT NULL,  
	WindaysCustID   INT   NOT NULL,  
	WinDaysSportGroup  INT   NOT NULL,  
  ProcessedTime        DATETIME       NOT NULL  
  PRIMARY KEY CLUSTERED (CustId, SportGroup)  
 );  
  
 IF OBJECT_ID('tempdb..#tmpCustomerAccummulatedInfo') IS NOT NULL  
  DROP TABLE #tmpCustomerAccummulatedInfo;  
  
 CREATE TABLE #tmpCustomerAccummulatedInfo(  
  [CustId]   INT NOT NULL,  
  [TurnoverRM]  MONEY NULL,  
  [WinlossRM]   MONEY NULL,  
  [BetCount]   BIGINT NULL,  
  [ActiveDays]  INT NULL  
 );  
  
 IF OBJECT_ID('tempdb..#tmpCustomers') IS NOT NULL  
 BEGIN  
  DROP TABLE #tmpCustomers;  
 END  
   
 CREATE TABLE #tmpCustomers(  
   CustId   INT  
 );  
  
 CREATE CLUSTERED INDEX IX_#mpCustomers_CustId ON #tmpCustomers(  
  [CustId]   ASC  
 );  
  
 -- #0: Distinct custid  
 INSERT INTO #tmpCustomers(CustId)  
 SELECT val FROM dbo.SPU_StrSplit(@ListCustIds, ',');  
  
 SELECT @ListCustIds = STUFF((SELECT ',', CONVERT(VARCHAR(15), t.CustId)   
        FROM (SELECT DISTINCT CustId FROM #tmpCustomers WITH (NOLOCK)) AS t  
        FOR XML PATH('')), 1, 1, '');  
  
     -- #1: GetCustomer Accummulated data  
  INSERT INTO #tmpRawData(CustId, SportGroup, TurnoverRM, WinlossRM, TurnoverORG, WinlossORG, BetCount, ActiveDaysCustID, ActiveDaysSportGroup, WindaysCustID, WinDaysSportGroup, ProcessedTime)  
  EXEC bodb_dwrs.dbo.Acc_Rpt_CTS_GetCustAccumulatedInfo @ListCustID = @ListCustIds, @isResetBalance = 1;  
  
 DELETE a WITH (ROWLOCK)  
 FROM #tmpRawData AS a  
 WHERE a.SportGroup IN (@SportGroup_NonSport, @SportGroup_SabaVRSoccer, @SportGroup_SabaVRBasketball);  
  
   
  
  
 -- #2: Sum data by custid  
 INSERT INTO #tmpCustomerAccummulatedInfo(CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT a.CustId  
  , SUM(a.TurnoverRM)  
  , SUM(a.WinlossRM)  
  , SUM(a.BetCount)  
  , MAX(a.ActiveDaysCustID)  
 FROM #tmpRawData AS a WITH(NOLOCK)  
 GROUP BY a.CustId;  
  
 -- NA TEST  
 -- WINNING  
 DELETE a WITH (ROWLOCK)  
 FROM #tmpCustomerAccummulatedInfo AS a  
 WHERE Custid in (791050,791054,832131,832132,832134,835097,835098,871390,875429,876080,888253,907115,907116,916540,
 916740,925150,925151,925152,927785,927834,927836,927837,927839,928084,928122,928365,
 932294,932295,932296,932304,932308,932319,932321,932326,932327,932993,933946,934959
 );  
  
 INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,4000,11,5   
 FROM #tmpCustomers  
 WHERE CustID IN (791050,791054,832131,835097,835098,871390,875429,876080,888253,907115,907116,916540,916740,925150,925151,932294,932295,932296)  
 ;  -- cust1,cust2,cust3
 INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,-9000,51,5   
 FROM #tmpCustomers  
 WHERE CustID IN (832132,832134,925152,927785,927834,932304,932308,932319)  
 ;  -- cust4,cust5,cust6
 INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,-4000,31,5   
 FROM #tmpCustomers  
 WHERE CustID IN (927836,927837,927839,928084,928122,928365,932321,932326,932327,932993,933946,934959)  
 ;  -- cust7,cust8,cust9,cust10,cust11,cust12

 -- LOSING  
 DELETE a WITH (ROWLOCK)  
 FROM #tmpCustomerAccummulatedInfo AS a  
 WHERE Custid in (832138,835062,835064,835067,835068,858252,871291,881273,888234,888250,907118,907123,915235,916591,
928393,929205,932020,932263,932266,932267,932275,932277,932280,932286,932287,932288,
945925,973261,973962,974312,977392,979481,979598,980633,980636,980637,980640,980642
 );  
  
 INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,-11000,71,5   
 FROM #tmpCustomers  
 WHERE CustID IN (832138,835062,835064,858252,871291,881273,888234,888250,907118,907123,915235,916591,928393,929205,932020,945925,973261,973962)   
 ;  -- cust1,cust2,cust3
 INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,-15000,101,5   
 FROM #tmpCustomers  
 WHERE CustID IN (835067,835068,932263,932266,932267,974312,977392,979481)  
 ;  -- cust4,cust5,cust6
  INSERT INTO #tmpCustomerAccummulatedInfo (CustId, TurnoverRM, WinlossRM, BetCount, ActiveDays)  
 SELECT CustID,100000,-12000,91,5   
 FROM #tmpCustomers  
 WHERE CustID IN (932275,932277,932280,932286,932287,932288,979598,980633,980636,980637,980640,980642)  
 ;  -- cust7,cust8,cust9,cust10,cust11,cust12

 -- #3: Classify new members  
 SELECT r.CustId  
  , CASE  
    WHEN (r.WinlossRM < -10000) THEN @PROBLEMACCOUNT_LOSING  
    WHEN (r.WinlossRM >= -5000) THEN @PROBLEMACCOUNT_WINNING  
    ELSE @PROBLEMACCOUNT_KEEPSTATE  
   END AS WinlossStatus  
  , r.TurnoverRM  
  , r.WinlossRM  
  , r.BetCount  
  , r.ActiveDays  
 FROM #tmpCustomerAccummulatedInfo AS r WITH(NOLOCK)  
END;  