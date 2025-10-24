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

await page.goto('https://cts.nexdev.net/v1/Home');
await page.fill('input#txtInput', 'NAS001M001');
await page.press('input#txtInput', 'Enter');
await expect(page).toHaveURL('https://cts.nexdev.net/v1/Account/Index/1001093076');
await expect(page.locator('span.tag-text-left:has-text("Login Name:") + span.tag-text-right')).toHaveText('NAS001M001');
await expect(page.locator('span.tag-text-left:has-text("Account Status:") + span.tag-text-right')).toHaveText('Open');
await expect(page.locator('span.tag-text-left:has-text("Subscriber:") + span.tag-text-right')).toHaveText('Alpha789y');
await expect(page.locator('span.tag-text-left:has-text("Site:") + span.tag-text-right')).toHaveText('y789');
await expect(page.locator('span.tag-text-left:has-text("Level:") + span.tag-text-right')).toHaveText('Master');

     } catch (e) {
       result = 'FAILED';
       throw e;
     } finally {
       await writeTestResults('local', 'Common', 'C-00006', result);
     }
});