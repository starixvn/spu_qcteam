import { test, expect } from '@playwright/test';
import { writeTestResults } from '../../../utils/helpers';

test('Execute Test Scripts by Playwright Test Gemini', async ({ page }) => { 
 let result = 'PASSED';
 try {

await page.goto('https://cts.nexdev.net/v1/UserLogin/Login');
await page.fill('input#username', 'sa000');
await page.fill('input#password', '1234aa000');
await page.locator('button:has-text("Login")').click();
await expect(page).toHaveURL('https://cts.nexdev.net/v1/UserLogin/Login');

     } catch (e) {
       result = 'FAILED';
       throw e;
     } finally {
       await writeTestResults('local', 'Common', 'C-00004', result);
     }
});