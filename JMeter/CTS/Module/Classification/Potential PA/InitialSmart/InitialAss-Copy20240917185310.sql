use CTS_DataCenter;

DROP TEMPORARY TABLE IF EXISTS Temp_Customers;
CREATE TEMPORARY TABLE 		Temp_Customers (
		CustID BIGINT UNSIGNED, CTSCustID BIGINT UNSIGNED, SubscriberID INT UNSIGNED
);  
-- Update Info 
set @lv_CustIDs = '980645,791050,791054,832131,832132,832134,832138,835062,835064,835067,835068,835097,835098,858252,871291,871390,875429,876080,881273,888234,888250,888253,907115,907116,907118,907123,915235,916540,916591,916740,925150,925151,925152,927785,927834,927836,927837,927839,928084,928122,928365,928393,929205,932020,932263,932266,932267,932275,932277,932280,932286,932287,932288,932294,932295,932296,932304,932308,932319,932321,932326,932327,932993,933946,934959,945925,973261,973962,974312,977392,979481,979598,980633,980636,980637,980640,980642';
SET @sql = 	CONCAT("INSERT IGNORE INTO Temp_Customers (CustID) VALUES ('", REPLACE(@lv_CustIDs, ",", "'),('"),"');");
PREPARE stmt1 FROM @sql;
EXECUTE stmt1;      
UPDATE Temp_Customers AS temp
	INNER JOIN CTS_DataCenter.CTSCustomer AS cust ON cust.CustID = temp.CustID AND cust.CustSubID = 0
SET temp.CTSCustID = cust.CTSCustID, temp.SubscriberID = cust.SubscriberID;

#===== ASSOCIATION BY DEVICE
set @lv_DeviceID1 = '240606'; 
-- Clean & insert new data    
delete ass from CTS_DataCenter.AssociationByDevice AS ass inner join Temp_Customers AS temp ON ass.CTSCustID = temp.CTSCustID; -- and ass.DCSDeviceID = @lv_DeviceID1;
insert ignore into CTS_DataCenter.AssociationByDevice(CTSCustID,DCSDeviceID,SubscriberID,CreatedTime,InsertTime) 
select temp.CTSCustID,@lv_DeviceID1,temp.SubscriberID,current_timestamp(),current_timestamp() from Temp_Customers AS temp where CustID <> 980645;

#===== ASSOCIATION BY DEVICE (ARCHIVE) --> check rollback ass, Potential PA cannot this action.
set @lv_DeviceID2 = '200606'; 
-- Clean & insert new data    
delete ass from CTS_Archive.AssociationByDevice_Arc AS ass inner join Temp_Customers AS temp ON ass.CTSCustID = temp.CTSCustID; -- and ass.DCSDeviceID = @lv_DeviceID2;
insert ignore into CTS_Archive.AssociationByDevice_Arc(CTSCustID,DCSDeviceID,SubscriberID,AssociationDate,Created) 
select temp.CTSCustID,@lv_DeviceID2,temp.SubscriberID,current_timestamp(),current_timestamp() from Temp_Customers AS temp where temp.CustID IN (791050,832138,980645);