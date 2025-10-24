import { test, expect } from '@playwright/test';
import { writeTestResults } from '../../../utils/helpers';

test('Execute Test Scripts by Playwright Test Gemini', async ({ page }) => { 
 let result = 'PASSED';
 try {

await page.goto('https://cts.nexdev.net/v1/UserLogin/Login');
await page.fill('input#username', 'sa000');
await page.fill('input#password', '1234aa');
await page.click('button:has-text("Login")');
await expect(page).toHaveURL('https://cts.nexdev.net/v1/UserLogin/Login');

     } catch (e) {
       result = 'FAILED';
       throw e;
     } finally {
       await writeTestResults('local', 'Common', 'C-00002', result);
     }
});