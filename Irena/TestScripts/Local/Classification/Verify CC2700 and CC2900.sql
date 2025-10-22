select * from CTS_DataCenter.SystemParameter where ParameterID IN (88, 92, 151, 159, 160, 161, 196, 197, 198);

SELECT ParentID, CategoryID, CategoryName, ColorTypeID FROM CTS_DataCenter.CustomerCategory where Categoryid in (40401,40501,40601,40402,40502,40602,40403,40503,40603);
SELECT * FROM CTS_DataCenter.CustomerCategorySettings;
-- 4345542,4356533,4357127,4357137,4357141,4359569
SELECT * FROM CTS_DataCenter.Customer_InitialSmart order by InsertedTime desc;
SELECT * FROM CTS_DataCenter.Customer_InitialSmart_Log order by InsertedTime desc;

SELECT * FROM CTS_DataCenter.CTSCustomer WHERE site = '611111' and custsubid=0 limit 20; 
SELECT * FROM CTS_DataCenter.CTSCustomer WHERE site = '12bet' and custsubid=0 limit 20; 

CustID in (4345542,4356533,4357127,4357137); 
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_DailyPAQueue  WHERE CustID in (4345542,4356533);
SELECT * FROM CTS_DataCenter.Customer_InitialSmart_BySport_Log order by InsertedTime desc;

SELECT * FROM CTS_DataCenter.JobMonitoring_IncorrectData order by ID desc;
SELECT * FROM CTS_DataCenter.CTSCustomerClassification where CustID in (4345542,4356533,4357127,4357137); 
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID in (4345542,4356533,4357127,4357137) order by id desc;
SELECT * FROM CTS_DataCenter.CTSCustomerClassification_Log WHERE CustID in (4345542,4356533,4357127,4357137) order by id desc;

select * from CTS_DataCenter.SystemParameter where ParameterID IN (88, 196, 197, 198);-- 2025-09-23 03:15:49.205
SELECT * FROM CTS_DataCenter.Customer_InitialSmart_BySport WHERE CustID in (4345542,4356533,4357127,4357137) order by InsertedTime asc;
SELECT * FROM CTS_DataCenter.TVSVoidRequest WHERE CustID in (4345542,4356533);
SELECT * FROM CTS_DataCenter.Customer_DangerousScore WHERE CustID in (4345542,4356533);
SELECT * FROM CTS_DataCenter.RobotDetection WHERE CustID in (4345542,4356533);





set @op_NextScannedDateTime = '0';
set @op_NextScannedCustID = 0;
call CTS_DataCenter.CTS_DC_CustClassification_InitialSmart_BySport_Get_xpre(500, @op_NextScannedDateTime, @op_NextScannedCustID);
select @op_NextScannedDateTime, @op_NextScannedCustID;

delete FROM CTS_DataCenter.CTSCustomerClassification WHERE CustID in (4345542,4356533,4357127,4357137);
delete FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID in (4345542,4356533,4357127) order by id desc;
delete FROM CTS_DataCenter.CTSCustomerClassification_Log WHERE CustID in (4345542,4356533,4357127) order by id desc;


insert into CTS_DataCenter.CTSCustomerClassification_DailyPAQueue (CustID, CreatedTime)
select CustID, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542,4356533);

insert into CTS_DataCenter.CTSCustomerClassification (CTSCustID, CustID, SubscriberID, RoleID, ParentID, CategoryID, CreatedDate)
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 30200, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 30400, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 35200, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 30400, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533)
;

insert into CTS_DataCenter.CTSCustomerClassification (CTSCustID, CustID, SubscriberID, RoleID, ParentID, CategoryID, CreatedDate)
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 35100, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 21100, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 25100, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 30300, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 26200, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533)
union all
select CTSCustID, CustID, SubscriberID, RoleID, 20000, 20200, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533)
;

insert into CTS_DataCenter.Customer_InitialSmart_BySport (CustID, SportType, Probability, SourceCreatedDate) 
select CustID, 1, 0.75, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542,4356533) union all
select CustID, 2, 0.85, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542,4356533);

insert into CTS_DataCenter.TVSVoidRequest (CustID, TVSReasonID, IssueTypeID, CategoryID, RequestTypeID, CreatedDate, IsDisabled) 
select CustID, 28, 11, 20100, 1, NOW(), 0 from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542) union all
select CustID, 29, 11, 20200, 1, NOW(), 0 from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533);

insert into CTS_DataCenter.Customer_DangerousScore (CustID, IsLicensee, DangerousScore, CreatedDate, LastModifiedDate, ClassifiedScore, ClassifiedDate) 
select CustID, 1, 0.95, NOW(), NOW(), 0.94, NOW() from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542,4356533);

insert into CTS_DataCenter.RobotDetection (CustID, PeriodRangeType, CreatedDate, IsDisabled) 
select CustID, 100, NOW(), 0 from CTS_DataCenter.CTSCustomer  WHERE CustID in (4345542) union all
select CustID, 200, NOW(), 0 from CTS_DataCenter.CTSCustomer  WHERE CustID in (4356533);


