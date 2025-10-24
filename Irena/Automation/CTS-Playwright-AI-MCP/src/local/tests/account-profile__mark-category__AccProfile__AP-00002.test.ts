import { test as base, expect } from '@playwright/test';
import { writeTestResults, executeQuery } from '../../../utils/helpers';

import fs from 'fs';
const sessionPath = `./src/local/session.json`;
const test = base.extend({
  storageState: fs.existsSync(sessionPath) ? sessionPath :undefined
});

test('Execute Test Scripts by Playwright Test Gemini', async ({ page }) => { 
 let result = 'PASSED';
 try {

let varCategory = "Group Betting";
let varABIDgr = "1";
let varIsAffect = "";
await page.goto('https://cts.nexdev.net/v1/Home');
await page.fill('input#txtInput', 'NAS001M001A001MEM002');
await page.press('input#txtInput', 'Enter');
await page.click('div#btnProfileInsertPA');
await page.evaluate(() => { if (document.body) { document.body.style.zoom = '0.8'; } });
if (varCategory === "VVIP") {
await page.click('label[for="inputCCVVIP"]');
}
if (varCategory !== "VVIP") {
await page.click('label[for="20100"]');
}
if (varIsAffect === "1") {
await page.click('span.checkmark');
}
await page.fill('textarea#txtCCComment', 'Auto Mark Group Betting - Member');
await page.click('button#btnCCMarkSave');
await page.reload();
await page.evaluate(() => { if (document.body) { document.body.style.zoom = '0.8'; } });
if (varCategory === "Robot" || varCategory === "Robot User") {
await page.waitForSelector('span.icon-big-Robot.icon-big-bad-robot.hide', { state: 'visible' });
}
if (varCategory !== "VVIP" && varCategory !== "Robot" && varCategory !== "Robot User") {
await page.waitForSelector('span.icon-flag', { state: 'visible' });
}
await page.waitForSelector('div.header-info.border-red', { state: 'visible' });
await page.waitForSelector('div.header-username.bg-red', { state: 'visible' });
await page.waitForSelector('span.circle.bg-red', { state: 'visible' });
await expect(page.locator('span.circle.bg-red + span.text-status.text-left')).toHaveText('Group Betting');
await expect(page.locator('span#spanClass')).toHaveText('Problems (301)');
await expect(page.locator('span#spanFlagEvidence')).toHaveText('6.1');
if (varCategory === "VVIP") {
await expect(page.locator('span#spanNextCategoryScanDate')).toHaveText('None');
}
if (varCategory !== "VVIP") {
await expect(page.locator('span#spanNextCategoryScanDate')).not.toHaveText('None');
}
await page.click('li#evidence-tab');
if (varCategory === "VVIP" || varCategory === "Robot" || varCategory === "Robot User") {
await expect(page.locator('table#tblChainToEvidenceFlagged tbody')).toHaveText("There's no data");
}
if (varCategory !== "VVIP" && varCategory !== "Robot" && varCategory !== "Robot User") {
await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:first-child td:nth-child(1)')).toHaveText('6.1 Group Betting');
await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:first-child td:nth-child(2)')).not.toHaveText('-');
await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:first-child td:nth-child(3)')).toHaveText('Auto Mark Group Betting - Member');
await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:first-child td:nth-child(4)')).toHaveText('irena');
}
await page.click('li#customer-class-tab');
await expect(page.locator('table#customer-category-table tbody tr:first-child td:nth-child(1)')).not.toHaveText('-');
await expect(page.locator('table#customer-category-table tbody tr:first-child td:nth-child(2)')).toHaveText('Group Betting');
await expect(page.locator('table#customer-category-table tbody tr:first-child td:nth-child(3)')).toHaveText('301');
await expect(page.locator('table#customer-category-table tbody tr:first-child td:nth-child(4)')).toHaveText('Problem Account is marked directly | Win loss: 0 | Auto Mark Group Betting - Member');
await expect(page.locator('table#customer-category-table tbody tr:first-child td:nth-child(5)')).toHaveText('irena');
await page.goto('https://cts.nexdev.net/v1/ProblemAccountManagement');
await page.fill('input#inputUserName', 'NAS001M001A001MEM002');
await page.click('button#btnGenerate');
if (varCategory === "VVIP") {
await expect(page.locator('table#tblProblemAccount tbody')).toHaveText("There's no data");
}
if (varCategory !== "VVIP") {
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(1)')).toHaveText('NAS001M001A001MEM002');
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(2)')).toHaveText('y789');
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(3)')).toHaveText('Won');
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(4)')).toHaveText('Group Betting');
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(5)')).toHaveText('Auto Mark Group Betting - Member');
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(6)')).not.toHaveText('-');
await expect(page.locator('table#tblProblemAccount tbody tr:first-child td:nth-child(7)')).toHaveText('irena');
}
const ctsCate = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTSCustomerClassification WHERE CustID = 179807094 AND SubscriberID = 169 AND RoleID = 1 AND ParentID = 20000 AND CategoryID = 20100 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048;');
const ctsCateHis = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = 179807094 AND ParentID = 20000 AND CategoryID = 20100 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND TargetCC = 301 AND SourceTypeID = 31 AND LastModifiedBy = 170497048 ORDER BY ID DESC LIMIT 1;');
const ctsCateQueue = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassificationQueue WHERE CustID = 179807094 AND SubscriberID = 169 AND RoleID = 1 AND CategoryID = 20100 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048 AND Remark = "Auto Mark Group Betting - Member" AND ActionType = 3 ORDER BY ID DESC LIMIT 1;');
const custdbClass = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807094 AND CustomerClass = 301;');
const custdbClassPA = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807094 AND CustomerClass = 301 AND Danger2 = 1;');
const custdbCateHis = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT TOP 1 * FROM CustDB.dbo.CustCategoryHistory WHERE CustID = 179807094 ORDER BY LogID DESC;');
await expect(ctsCate.length).toBeGreaterThanOrEqual(1);
await expect(ctsCateHis.length).toBeGreaterThanOrEqual(1);
if (varABIDgr !== "") {
await expect(custdbClass.length).toBeGreaterThanOrEqual(1);
}
if (varABIDgr === "") {
await expect(custdbClassPA.length).toBeGreaterThanOrEqual(1);
}
if (varCategory !== "VVIP") {
await expect(custdbCateHis.length).toBeGreaterThanOrEqual(1);
}
if (varIsAffect === "1") {
await expect(ctsCateQueue.length).toBeGreaterThanOrEqual(1);
}

     } catch (e) {
       result = 'FAILED';
       throw e;
     } finally {
       await writeTestResults('local', 'AccProfile', 'AP-00002', result);
     }
});