import { test, expect } from '@playwright/test';
import path from 'path';

const envArg = process.argv.find(arg => arg.includes('ENV='));
const env = envArg ? envArg.replace('ENV=', '') : 'local';

const configPath = require(`../src/${env}/config.js`);
const baseURL = configPath.web.baseURL;
const username = configPath.web.usr;
const password = configPath.web.pwd;
const sessionPath = `./src/${env}/session.json`;

test('Login and save session', async ({ page }) => {
  await page.goto(`${baseURL}/UserLogin/Login`);
  await page.fill('input#username', username);
  await page.fill('input#password', password);
  await page.click('button:has-text("Login")');
  await expect(page).toHaveURL(/Home/);

  const sessionPath_ = path.resolve(sessionPath);
  await page.context().storageState({ path: sessionPath_ });
});