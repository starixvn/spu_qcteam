/*
	Created:	20230929@Lisa.Phan
	Task :		Create Account with Category New/Good/Normal/Probation/Smart/Risky 
	DB:			TESTDB053(10.18.200.58),  TESTDBCUST(10.18.200.54)
*/

-- Margin = WL/TurnOver * 100

--# Standard:
-- New: 		CategoryID = 201, CC = 200, BetCount < 10
-- Normal:		CategoryID = 202, CC = 202, BC >=10, -2%< Margin < 0
-- Good: 		CategoryID = 205, CC = 201, BC >300, Margin <-2%, Turnover>150K(RM), ActiveDays >=8
-- Smart:		CategoryID = 203, CC = 204, BC >=20, 0 <= Margin <=1%, WL > 15K(RM)
-- Risky:		CategoryID = 204, CC = 205, BC >=20, Margin > 1%, WL > 15K(RM)
-- Probation:	CategoryID = 206, CC = 203
-- Smart --> Probation: BC >=20, 0<=Margin<=1%, WL <=10K (RM)
-- Risky --> Probation: BC >=20, 0<=Margin<=1%, WL <=15K (RM)
-- New/Good/Normal --> Probation: BC >=10, Margin >=0, WL > 15K(RM)

--# Sample value:
-- New: Betcount = 9, Turnover = 10123, WL = -4123  
-- Good: BetCount = 310, TurnOver = 250123, WL=-10123 (Margin= = -4), ActiveDays = 11 
-- Normal: Betcount=21, WL = -6123, TO=1012345 (Margin=-0.6)   
-- Smart: Betcount=21, WL=16123, TO=10123456 (Margin=0.16)  
-- Risky: Betcount=21, WL=17123, TO=1012345 (Margin=1.68) 
-- Probation:
-- Null/Inactive/New/Good/Normal -> Probation: Betcount=11, WL=10123, TO=101234 (Margin=15.9)
-- Smart -> Probation: BC=21, WL=5123, TO=1012345 (M=0.5) -- 1287,233733
-- Risky -> Probation: BC=21, WL=14123, TO=10123456 (M=0.15)

--# 1. Set value: cust must exist in both CTS and mainDB
declare @CustId int = 98426571, 
		@SportId int = 200, 
		@CategoryId smallint = 205, 
		@CreatedDate date = CAST( GETDATE() AS Date ), @IsApplied bit = 0, @CreatedTime datetime = GETDATE(), 
		@TurnoverRM decimal(19, 4) = 250123, 
		@WinlossRM decimal(19, 4) = -10123, 
		@BetCount bigint = 310, 
		@ActiveDays int = 1,
		@PerformanceTime datetime = GETDATE(), @CurrentCategoryId smallint = 201, @ScanTaggingType int = 1;

/*
	-- pick a random cust
	select	@CustId = ci.CustId 
	from bodb02.dbo.custinfo ci
		 inner join bodb02.dbo.Customer c on c.CustId = ci.CustId
		 inner join bodb02.dbo.Site s on s.site = c.site
	where c.currency not in (20, 27, 28) -- exclude test account
	-- and ci.Enabled = 1
	and c.roleid = 1 -- 1: Member, 2: Agent, 3: Master, 4: Super
	and s.isDeposit=0 --- 1: Licensee/ Deposit, 2: Credit
	order by NEWID(); -- Random
	-- check if username exists in CTS Web? 
	select Username from bodb02.dbo.custinfo WHERE CUSTID= @CustId;
*/

--# 2. Insert CategoryID to table CustomerClassification
INSERT INTO [bodb_VR2Model].[dbo].[CustomerClassification](CustId,SportId,CategoryId,CreatedDate,IsApplied,CreatedTime,TurnoverRM,WinlossRM,BetCount,ActiveDays,PerformanceTime,CurrentCategoryId,ScanTaggingType)
VALUES (@CustId, @SportId, @CategoryId, @CreatedDate, @IsApplied, @CreatedTime, @TurnoverRM, @WinlossRM, @BetCount, @ActiveDays, @PerformanceTime, @CurrentCategoryId, @ScanTaggingType);

SELECT * FROM bodb_VR2Model.dbo.CustomerClassification WHERE CUSTID = @CustId ORDER BY CreatedTime DESC;
select Username from bodb02.dbo.custinfo WHERE CUSTID= @CustId;

--# 3. Trigger service Insert New: to insert Category to CTS then push CC to maindb
-- service: CTS_CustomerClassification_Secondly_NormalAccountInsert_Renovate
-- check 
-- SELECT IsApplied, * FROM bodb_VR2Model.dbo.CustomerClassification WHERE CUSTID = 98426571  ORDER BY CreatedTime;

--# 4. Check CTS Web or table CTS_DataCenter.CTSCustomerClassification
-- SELECT * FROM `CTS_DataCenter`.`CTSCustomerClassification` WHERE CustID = 98426571;

--# 5. Check CC in maindb: 
-- TESTDBCUST (10.18.200.54)/ acc: sputeam
-- SELECT TOP (1000) [username],[custid],[CustomerClass],[danger2], danger, roleid FROM CustDB.[dbo].[custInfo] where custid = @custid;









