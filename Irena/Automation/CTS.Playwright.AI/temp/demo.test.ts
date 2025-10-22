
import { test as base, expect } from '@playwright/test';
import { writeTestResults, executeQuery } from '../utils/helpers';
import fs from 'fs';
const sessionPath = `./src/local/session.json`;
const test = base.extend({
  storageState: fs.existsSync(sessionPath) ? sessionPath :undefined
});

test('Execute Test Scripts by Playwright MCP Gemini', async ({ page }) => { 
 let result = 'PASSED';
 try {


let varCategory = "Group Betting";
let varABIDgr = "1";
let varIsAffect = "";

// MySQL
let ctsCate = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTSCustomerClassification WHERE CustID = 179807094 AND SubscriberID = 169 AND RoleID = 1 AND ParentID = 20000 AND CategoryID = 20100 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048;');
let ctsCateHis = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = 179807094 AND ParentID = 20000 AND CategoryID = 20100 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND TargetCC = 301 AND SourceTypeID = 31 AND LastModifiedBy = 170497048 ORDER BY ID DESC LIMIT 1;');
let ctsCateQueue = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassificationQueue WHERE CustID = 179807094 AND SubscriberID = 169 AND RoleID = 1 AND CategoryID = 20100 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048 AND Remark = "Auto Mark Group Betting - Member" AND ActionType = 3 ORDER BY ID DESC LIMIT 1;');

// MSSQL
let custdbClass = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807094 AND CustomerClass = 301;');
let custdbClassPA = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807094 AND CustomerClass = 301 AND Danger2 = 1;');
let custdbCateHis = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT TOP 1 * FROM CustDB.dbo.CustCategoryHistory WHERE CustID = 179807094 ORDER BY LogID DESC;');


await expect(ctsCate.length).toBeGreaterThan(0); console.log("ctsCate: ", ctsCate);
await expect(ctsCateHis.length).toBeGreaterThan(0); console.log("ctsCateHis: ", ctsCateHis);
if (varABIDgr !== "") {
    await expect(custdbClass.length).toBeGreaterThan(0);
    console.log("custdbClass: ", custdbClass);
}
if (varABIDgr === "") {
    await expect(custdbClassPA.length).toBeGreaterThan(0);
    console.log("custdbClassPA: ", custdbClassPA);
}
if (varCategory !== "VVIP") {
    await expect(custdbCateHis.length).toBeGreaterThan(0);
    console.log("custdbCateHis: ", custdbCateHis);
}
if (varIsAffect === "1") {
    await expect(ctsCateQueue.length).toBeGreaterThan(0);
    console.log("ctsCateQueue: ", ctsCateQueue);
}


     } catch (e) {
       result = 'FAILED';
       throw e;
     } finally {
       //await writeTestResults('local', 'AccProfile', 'AP-00002', result);
     }
});