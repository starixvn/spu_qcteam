import { chromium } from 'playwright';
import * as cheerio from 'cheerio';
import fs from 'fs';

export async function captureSnapshot(url: string, outFile = 'snapshot.html') {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto(url);

  // Lấy HTML
  const html = await page.content();

  // Làm sạch
  const $ = cheerio.load(html);
  $('[class]').removeAttr('class');
  $('[style]').removeAttr('style');

  fs.writeFileSync(outFile, $.html(), 'utf-8');
  await browser.close();
}