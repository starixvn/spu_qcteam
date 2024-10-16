/*
	Created:	20240513@Randy.Nguyen
	Task :		Create script to create CC2600 - Initial Group Betting
	DB:			TESTDB053 (bodb_VR2Model)
	
	Revisions:
			-   20240513@Randy.Nguyen: Created
*/

-- Step1:
-- SQL SERVER - MainDB Local: TESTDB053 (10.18.200.58) (DB DW)
/* SELECT TOP (1000) c.site, c.username, c.custid, c.currency, c.srecommend, c.mrecommend, c.recommend, i.Enabled, i.reject, i.closed, c.roleid FROM bodb02.dbo.customer c WITH (NOLOCK) 
INNER JOIN bodb02.dbo.custInfo i (NOLOCK) ON c.custid = i.custid 
INNER JOIN bodb02.dbo.Dep_CustSuper AS d WITH(NOLOCK) ON c.srecommend = d.custid
where c.currency NOT IN (20, 27, 28)  AND c.roleid = 1  AND c.site IN ('haifa', '12bet')
order by i.custid desc;
*/
Use bodb_VR2Model;
DECLARE 
@custid int  = 1015441,
@sporttype int = 2            -- 1: Soccer, 2: Basketball, NULL: Soccer/Basketball (mix sports)
; 

DELETE from dbo.CustomerClassification_ScannedNewCust  where CustId in (@custid);

DECLARE @Today									DATETIME2 = GETDATE();
select  c.username, c.custid, c.currency, c.site, @Today AS 'Current time' FROM bodb02.dbo.customer c WITH (NOLOCK) INNER JOIN bodb02.dbo.custInfo i (NOLOCK) ON c.custid = i.custid  where c.custid = @custid ;
INSERT INTO dbo.CustomerClassification_ScannedNewCust (CustId,TotalTicketCount,GBTicketCount,SportType,CreatedTime,JobScannedType,LastJobScannedTime)
values
(@custid,6,4,@sporttype,@Today,2,@Today)
;

Update CustomerClassification_Parameter set Value =  @Today	 where DataId = 7;
Update CustomerClassification_Parameter set Value = 0 where DataId = 14;


SELECT TOP (100) * FROM [bodb_VR2Model].[dbo].[CustomerClassification_ScannedNewCust] order by LastJobScannedTime desc;
select DataID,Value from CustomerClassification_Parameter where dataid in (7,14);

--Step 2: Start Job "CTS_CC.CTS_CustomerClassification_Secondly_TWInitialGBToCCScan"

--Step 3 : Check Username in CTS
