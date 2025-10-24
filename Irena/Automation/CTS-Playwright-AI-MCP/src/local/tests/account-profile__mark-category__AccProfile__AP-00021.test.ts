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

let varCategory = "Hedging";
let varABIDgr = "";
let varIsAffect = "";
await page.goto('https://cts.nexdev.net/v1/Home');
await page.fill('input#txtInput', 'NAS001M001A003');
await page.press('input#txtInput', 'Enter');
await page.click('div#btnProfileInsertPA');
await page.evaluate(() => { if (document.body) { document.body.style.zoom = '0.8'; } });
if (varCategory === "VVIP") {
    await page.click('label[for="inputCCVVIP"]');
}
if (varCategory !== "VVIP") {
    await page.click('label[for="120200"]');
}
if (varIsAffect === "1") {
    await page.click('span.checkmark');
}
await page.fill('textarea#txtCCComment', 'Auto Mark Hedging - Agent');
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
await expect(page.locator('span.circle.bg-red + span.text-status.text-left')).toHaveText('Hedging');
await expect(page.locator('span#spanClass')).toHaveText('Problem (30000)');
await expect(page.locator('span#spanFlagEvidence')).toHaveText('6.4');
if (varCategory === "VVIP") {
    await expect(page.locator('span#spanNextCategoryScanDate')).toHaveText('None');
}
if (varCategory !== "VVIP") {
    await expect(page.locator('span#spanNextCategoryScanDate')).not.toHaveText('None');
}
await page.click('li#evidence-tab');
if (varCategory === "VVIP" || varCategory === "Robot" || varCategory === "Robot User") {
    await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:nth-child(1)')).toHaveText("There's no data");
}
if (varCategory !== "VVIP" && varCategory !== "Robot" && varCategory !== "Robot User") {
    await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:nth-child(1) td:nth-child(1)')).toHaveText('6.4 Hedging');
    await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:nth-child(1) td:nth-child(2)')).not.toHaveText('-');
    await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:nth-child(1) td:nth-child(3)')).toHaveText('Auto Mark Hedging - Agent');
    await expect(page.locator('table#tblChainToEvidenceFlagged tbody tr:nth-child(1) td:nth-child(4)')).toHaveText('irena');
}
await page.click('li#customer-class-tab');
await expect(page.locator('table#customer-category-table tbody tr:nth-child(1) td:nth-child(1)')).not.toHaveText('-');
await expect(page.locator('table#customer-category-table tbody tr:nth-child(1) td:nth-child(2)')).toHaveText('Hedging');
await expect(page.locator('table#customer-category-table tbody tr:nth-child(1) td:nth-child(3)')).toHaveText('30000');
await expect(page.locator('table#customer-category-table tbody tr:nth-child(1) td:nth-child(4)')).toHaveText('Problem Account is marked directly | Win loss: 0 | Margin: 0 | Auto Mark Hedging - Agent');
await expect(page.locator('table#customer-category-table tbody tr:nth-child(1) td:nth-child(5)')).toHaveText('irena');
await page.goto('https://cts.nexdev.net/v1/ProblemAccountManagement');
await page.fill('input#inputUserName', 'NAS001M001A003');
await page.click('button#btnGenerate');
if (varCategory === "VVIP") {
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1)')).toHaveText("There's no data");
}
if (varCategory !== "VVIP") {
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(1)')).toHaveText('NAS001M001A003');
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(2)')).toHaveText('y789');
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(3)')).toHaveText('Won');
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(4)')).toHaveText('Hedging');
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(5)')).toHaveText('Auto Mark Hedging - Agent');
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(6)')).not.toHaveText('-');
    await expect(page.locator('table#tblProblemAccount tbody tr:nth-child(1) td:nth-child(7)')).toHaveText('irena');
}
let ctsCate = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTSCustomerClassification WHERE CustID = 179807024 AND SubscriberID = 169 AND RoleID = 2 AND ParentID = 120000 AND CategoryID = 120200 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048;');
let ctsCateHis = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = 179807024 AND ParentID = 120000 anANDd CategoryID = 120200 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND TargetCC = 30000 AND SourceTypeID = 31 AND LastModifiedBy = 170497048 ORDER BY ID DESC LIMIT 1;');
let ctsCateQueue = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassificationQueue WHERE CustID = 179807024 AND SubscriberID = 169 AND RoleID = 2 AND CategoryID = 120200 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048 AND Remark = "Auto Mark Hedging - Agent" AND ActionType = 3 ORDER BY ID DESC LIMIT 1;');
let custdbClass = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807024 AND CustomerClass = 30000;');
let custdbClassPA = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807024 AND CustomerClass = 30000 AND Danger2 = ;');
let custdbCateHis = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT TOP 1 * FROM CustDB.dbo.CustCategoryHistory WHERE CustID = 179807024 ORDER BY LogID DESC;');
await expect(ctsCate.length).toBeGreaterThan(0);
await expect(ctsCateHis.length).toBeGreaterThan(0);
if (varABIDgr !== "") {
    await expect(custdbClass.length).toBeGreaterThan(0);
}
if (varABIDgr === "") {
    await expect(custdbClassPA.length).toBeGreaterThan(0);
}
if (varCategory !== "VVIP") {
    await expect(custdbCateHis.length).toBeGreaterThan(0);
}
if (varIsAffect === "1") {
    await expect(ctsCateQueue.length).toBeGreaterThan(0);
}

     } catch (e) {
       result = 'FAILED';
       throw e;
     } finally {
       await writeTestResults('local', 'AccProfile', 'AP-00021', result);
     }
});