select * from CTS_DataCenter.SystemParameter where ParameterID IN (147,148,149,150,  3, 94,   153,154,155,156,157,158, 159,160,161,64,65,66); -- 2024-07-16 05:22:50.070

SELECT * FROM CTS_DataCenter.CTSCustomer where custid in (148629875,148629877,148628993,148628994, 8078245,791050,791054, 148629869);
SELECT * FROM CTS_DataCenter.TVSVoidRequest where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.CustomerLoginInfoDetection where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.RobotDetection where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.CTSRobotUser where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.TWRobotUser where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.Customer_DangerousScore where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.Customer_InitialSmart where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.Customer_InitialGroupBetting where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.CTSCustomerClassification where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_Log where custid IN (148629875,148629877,148628993,148628994, 8078245,791050,791054); 
select * from CTS_DataCenter.CustEvidence where CTSCustID IN (1000930241,1000930242,2607636,1001067147,1001067148,1001068006,1001068008);
select * from CTS_DataCenter.AssociationByDevice where DCSDeviceID = 2024082001;

-- CC305
where custid in (791050,791054,832131,832132,832134,832138,835062,835064,
  8078245,8078256,8094971,8095010,8106514,8305518,8311309,8311318,8311321,8311324,8311900,8311925)
 order by custid asc, FirstbetDate asc;
                        
-- CC300/3100 (AI, TW)
insert ignore into CTS_DataCenter.RobotDetection (CustID, PeriodRangeType, CreatedDate, IsDisabled) 
SELECT c.CustID,100,current_timestamp(),0 FROM CTS_DataCenter.CTSCustomer AS c where custid IN (148629875,148629877,148628993,148628994); -- ocrd: 200, 100

/*
INSERT INTO ON_USER.dbo.RobotUsers (custid, IP, LastChangeTime, site, counter, serverip, RobotDate, remark, Creator, countryLONG, ipREGION) 
SELECT c.CustID,'N/A',getdate(),c.site,11,NULL,getdate(),NULL,8,NULL,NULL from bodb02.dbo.customer as c with(nolock) where c.custid IN (148629875,148629877,148628993,148628994); 
*/
-- CC2800
insert ignore into CTS_DataCenter.Customer_DangerousScore (CustID, IsLicensee, DangerousScore, ClassifiedScore, ClassifiedDate, CreatedDate, LastModifiedDate) 
select c.CustID,c.IsLicensee,'0.9522','0.9522',current_timestamp(),current_timestamp(),current_timestamp() FROM CTS_DataCenter.CTSCustomer AS c where c.custid IN (148629875,148629877,148628993,148628994); 

-- CC2700
insert ignore into CTS_DataCenter.Customer_InitialSmart (CustID, Probability, SourceCreatedDate, InsertedTime)
select c.CustID,'0.7522',current_timestamp(),current_timestamp() FROM CTS_DataCenter.CTSCustomer AS c where c.custid IN (148628993,148628994); 

-- CC2600
insert ignore into CTS_DataCenter.Customer_InitialGroupBetting (CustID, GBTicketCount, SportType, SourceCreatedDate, CreatedDate) 
select c.CustID,4,1,current_timestamp(),current_timestamp() FROM CTS_DataCenter.CTSCustomer AS c where c.custid IN (148628993,148628994); 

/*
update dbo.custinfo set CustomerClass = null, danger2 = 0 
where custid IN (148629875,148629877,148628993,148628994); 
delete from dbo.Dep_CustCategoryHistory 
where custid IN (148629875,148629877,148628993,148628994); 
delete from dbo.CustCategoryHistory 
where custid IN (148629875,148629877,148628993,148628994); 
delete from dbo.ProblemAccountClassification 
where custid IN (148629875,148629877,148628993,148628994); 

select CustID, customerclass, danger2 from dbo.custinfo with(nolock) 
where custid IN (148629875,148629877,148628993,148628994); 
select * from dbo.Dep_CustCategoryHistory with(nolock) 
where custid IN (148629875,148629877,148628993,148628994); 
select * from dbo.CustCategoryHistory with(nolock) 
where custid IN (148629875,148629877,148628993,148628994); 
select * from dbo.ProblemAccountClassification with(nolock) 
where custid IN (148629875,148629877,148628993,148628994); 
 
   insert into [bodb_VR2Model].[dbo].[CustomerClassification_LatestActiveDay] values
(148629877,'2024-08-20','2024-08-20 01:33:33.000','2024-08-20 01:33:33.000');
  insert into [bodb_VR2Model].[dbo].[CustomerClassification_BySport_LatestActiveDay] values
(148629877,1,'2024-08-20','2024-08-20 01:33:33.000','2024-08-20 01:33:33.000'),
(148629877,2,'2024-08-20','2024-08-20 01:33:33.000','2024-08-20 01:33:33.000'),
(148629877,43,'2024-08-20','2024-08-20 01:33:33.000','2024-08-20 01:33:33.000'),
(148629877,99,'2024-08-20','2024-08-20 01:33:33.000','2024-08-20 01:33:33.000'),
(148629877,229,'2024-08-20','2024-08-20 01:33:33.000','2024-08-20 01:33:33.000');


  insert into  [bodb_VR2Model].[dbo].[CustomerClassification_NormalPool] (CustId, Priority, FunctionId, CreatedTime) values
  (8078245,10,4,GETDATE()),
  (791050,10,4,GETDATE()),
  (791054,10,4,GETDATE());
*/