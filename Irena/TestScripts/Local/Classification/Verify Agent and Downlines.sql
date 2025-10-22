#===== CTS DataCenter
select * from CTS_DataCenter.CustomerCategoryAgency;
select * from CTS_DataCenter.CustomerCategory;
select * from CTS_DataCenter.CustomerCategorySettings where ParentID = 20000 and FlowConsiderableDangerScan = 1;

-- 1. line agent1
select * from CTS_DataCenter.CTSCustomer where custid in (10382585,10382637,10382680,10595491,11492681,15229955);
select * from CTS_DataCenter.CTSCustomerClassificationAgency where custid in (10382585);
select * from CTS_DataCenter.CTSCustomerClassification where custid in (10382637,10382680,10595491,11492681,15229955);
select * from CTS_DataCenter.CustomerConsiderableDangerQueue where custid in (10382585);
select * from CTS_DataCenter.Customer_ConsiderableDanger where custid in (10382585);
select * from CTS_DataCenter.Customer_ConsiderableDanger_Log where custid in (10382585);

delete from CTS_DataCenter.CTSCustomerClassificationAgency where custid in (10382585);
INSERT INTO CTS_DataCenter.CTSCustomerClassificationAgency (CustID, CTSCustID, SubscriberID, RoleID, ParentID, CategoryID, CreatedDate, CreatedBy, LastScannedDate, LastModifiedDate, LastModifiedBy, IsFromCTS, IsMarkedDirectly) 
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 140000, 140200, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (10382585) and m.CustSubID=0; -- good
delete from CTS_DataCenter.CTSCustomerClassification where custid in (10382637,10382680,10595491,11492681,15229955);
INSERT INTO CTS_DataCenter.CTSCustomerClassification (CustID, CTSCustID, SubscriberID, RoleID, ParentID, CategoryID, CreatedDate, CreatedBy, LastScannedDate, LastModifiedDate, LastModifiedBy, IsFromCTS, IsMarkedDirectly, IsFromAI) 
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 40000, 40100, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (10382637) union all -- new
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 40000, 40400, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (10382680) union all -- prob
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 20000, 30100, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, 0, 1, 1 from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (10595491) union all -- 2800
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 20000, 20200, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, 1, 1, 0 from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (11492681) union all -- hed
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 20000, 20600, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, 1, 1, 0 from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (15229955); -- formula bet

select * from CTS_DataCenter.CTSCustomerClassificationAgency_History where custid in (10382585);

-- 2. line agent2
select * from CTS_DataCenter.CTSCustomer where custid in (195853095,195853105,195853106,195853246,195853355,195853362,195860045);
select * from CTS_DataCenter.CTSCustomerClassificationAgency where custid in (195853095);
select * from CTS_DataCenter.CTSCustomerClassification where custid in (195853105,195853106,195853246,195853355,195853362,195860045);
select * from CTS_DataCenter.CustomerConsiderableDangerQueue where custid in (195853095);
select * from CTS_DataCenter.Customer_ConsiderableDanger where custid in (195853095);
select * from CTS_DataCenter.Customer_ConsiderableDanger_Log where custid in (195853095);



delete from CTS_DataCenter.CTSCustomerClassificationAgency where custid in (195853095);
INSERT INTO CTS_DataCenter.CTSCustomerClassificationAgency (CustID, CTSCustID, SubscriberID, RoleID, ParentID, CategoryID, CreatedDate, CreatedBy, LastScannedDate, LastModifiedDate, LastModifiedBy, IsFromCTS, IsMarkedDirectly) 
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 140000, 140800, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195853095) and m.CustSubID=0; -- prob
delete from CTS_DataCenter.CTSCustomerClassification where custid in (195853105,195853106,195853246,195853355,195853362,195860045);
INSERT INTO CTS_DataCenter.CTSCustomerClassification (CustID, CTSCustID, SubscriberID, RoleID, ParentID, CategoryID, CreatedDate, CreatedBy, LastScannedDate, LastModifiedDate, LastModifiedBy, IsFromCTS, IsMarkedDirectly) 
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 40000, 40300, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195853105) union all -- normal
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 40000, 40600, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195853106) union all -- risky
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 40000, 40700, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, null, null from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195853246) union all -- inactive
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 20000, 20900, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, 1, 1 from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195853355) union all -- cc3101
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 20000, 20300, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, 1, 1 from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195853362) union all -- arb
SELECT m.CustID, m.CTSCustID, m.SubscriberID, m.RoleID, 20000, 20400, NOW(), 10278938, CURRENT_DATE(), NOW(), 10278938, 1, 1 from CTS_DataCenter.CTSCustomer AS m where m.CustID IN (195860045); -- fixed game

select * from CTS_DataCenter.CTSCustomerClassificationAgency_History where custid in (195853095);


#===== SOURCE
Web: https://cts.nexdev.net/v2
Job:  https://spu-main-v3.nexdev.net/quartz/Jobs
CTS_CustomerClassificationAgency_Daily_ConsiderableDangerScan
CTS_CustomerClassificationAgency_Secondly_RealtimeScan 
CTS_CustomerClassificationAgency_Secondly_NormalAccountInsert




