1. Define variable: varCategory = "Hedging";
2. Define variable: varABIDgr = "";
3. Define variable: varIsAffect = "";
4. Go to https://cts.nexdev.net/v1/Home
5. Fill "NAS001M001A003" in input#txtInput and press Enter
6. Click div#btnProfileInsertPA
7. Zoom browser: await page.evaluate(() => { if (document.body) { document.body.style.zoom = '0.8'; } });
8. IF varCategory is "VVIP" THEN click label[for="inputCCVVIP"] 
9. IF varCategory is not "VVIP" THEN click label[for="120200"]
10. IF varIsAffect = "1" THEN click span.checkmark
11. Fill "Auto Mark Hedging - Agent" in textarea#txtCCComment
12. Click button#btnCCMarkSave
13. Refresh page
14. Zoom browser: await page.evaluate(() => { if (document.body) { document.body.style.zoom = '0.8'; } });
15. IF varCategory is "Robot" or is "Robot User" THEN await page.waitForSelector('span.icon-big-Robot.icon-big-bad-robot.hide', { state: 'visible' });
16. IF varCategory is not VVIP" and is not "Robot" and is not "Robot User" THEN await page.waitForSelector('span.icon-flag', { state: 'visible' });
17. Wait border: await page.waitForSelector('div.header-info.border-red', { state: 'visible' });
18. Wait background: await page.waitForSelector('div.header-username.bg-red', { state: 'visible' });
19. Wait color: await page.waitForSelector('span.circle.bg-red', { state: 'visible' });
20. Assert span.circle.bg-red + span.text-status.text-left has text "Hedging"
21. Assert span#spanClass has text "Problem (30000)"
22. Assert span#spanFlagEvidence has text "6.4"
23. IF varCategory is "VVIP" THEN Assert span#spanNextCategoryScanDate has text "None" 
24. IF varCategory is not "VVIP" THEN Assert span#spanNextCategoryScanDate has not text "None"
25. Click li#evidence-tab
26. IF varCategory is "VVIP" or is "Robot" or is "Robot User" THEN Assert the 1st row in table#tblChainToEvidenceFlagged tbody has text "There's no data"
27. IF varCategory is not "VVIP" and is not "Robot" and is not "Robot User" THEN Assert each cell of the 1st row in table#tblChainToEvidenceFlagged tbody with 1st cell has text "6.4 Hedging", 2nd cell has not text "-", 3rd cell has text "Auto Mark Hedging - Agent", 4th cell has text "irena"
28. Click li#customer-class-tab
29. Assert each cell of the 1st row in table#customer-category-table tbody with 1st cell has not text "-", 2nd cell has text "Hedging", 3rd cell has text "30000", 4th cell has text "Problem Account is marked directly | Win loss: 0 | Margin: 0 | Auto Mark Hedging - Agent", 5th cell has text "irena"
30. Go to https://cts.nexdev.net/v1/ProblemAccountManagement
31. Fill "NAS001M001A003" in input#inputUserName and click button#btnGenerate
32. IF varCategory is "VVIP" THEN Assert the 1st row in table#tblProblemAccount tbody has text "There's no data"
33. IF varCategory is not "VVIP" THEN Assert each cell of the 1st row in table#tblProblemAccount tbody with 1st cell has text "NAS001M001A003", 2nd cell has text "y789", 3rd cell has text "Won", 4th cell has text "Hedging", 5th cell has text "Auto Mark Hedging - Agent", 6th cell has not text "-", 7th cell has text "irena"
34. Define variable: ctsCate = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTSCustomerClassification WHERE CustID = 179807024 AND SubscriberID = 169 AND RoleID = 2 AND ParentID = 120000 AND CategoryID = 120200 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048;');
35. Define variable: ctsCateHis = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassification_History WHERE CustID = 179807024 AND ParentID = 120000 anANDd CategoryID = 120200 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND TargetCC = 30000 AND SourceTypeID = 31 AND LastModifiedBy = 170497048 ORDER BY ID DESC LIMIT 1;');
36. Define variable: ctsCateQueue = await executeQuery('mysql', '10.18.200.70', 3307, 'irena.vn', '123456', 'CTS_DataCenter', 'SELECT * FROM CTS_DataCenter.CTSCustomerClassificationQueue WHERE CustID = 179807024 AND SubscriberID = 169 AND RoleID = 2 AND CategoryID = 120200 AND IsFromCTS = 1 AND IsMarkedDirectly = 1 AND CreatedBy = 170497048 AND Remark = "Auto Mark Hedging - Agent" AND ActionType = 3 ORDER BY ID DESC LIMIT 1;');
37. Define variable: custdbClass = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807024 AND CustomerClass = 30000;');
38. Define variable: custdbClassPA = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT * FROM CustDB.dbo.custinfo WHERE CustID = 179807024 AND CustomerClass = 30000 AND Danger2 = ;');
39. Define variable: custdbCateHis = await executeQuery('mssql', '10.18.200.54', 1433, 'testteam', '@quality#', 'CustDB', 'SELECT TOP 1 * FROM CustDB.dbo.CustCategoryHistory WHERE CustID = 179807024 ORDER BY LogID DESC;');
40. Assert ctsCate exists at least 1 row
41. Assert ctsCateHis exists at least 1 row
42. IF varABIDgr is not "" THEN Assert custdbClass exists at least 1 row
43. IF varABIDgr is "" THEN Assert custdbClassPA exists at least 1 row
44. IF varCategory is not "VVIP" THEN Assert custdbCateHis exists at least 1 row
45. IF varIsAffect = "1" THEN Assert ctsCateQueue exists at least 1 row