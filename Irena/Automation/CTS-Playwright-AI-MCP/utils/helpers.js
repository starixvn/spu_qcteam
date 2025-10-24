const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');
const { google } = require('googleapis');
const { DateTime } = require('luxon');
const mysql = require('mysql2/promise');
const sql = require('mssql');

function handleNone(value) {
  return value === 'null' ? null : value;
}

function readCsv(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const records = parse(content, { columns: true, skip_empty_lines: true });
  records.sort((a, b) => parseInt(a.no) - parseInt(b.no));
  return records;
}

function readJson(filePath) {
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  return Array.isArray(data) ? data : [data];
}

function getFullPath(relativePath) {
  return path.resolve(__dirname, relativePath);
}

function colToLetter(colIndex) {
  let letter = '';
  while (colIndex > 0) {
    let remainder = (colIndex - 1) % 26;
    letter = String.fromCharCode(65 + remainder) + letter;
    colIndex = Math.floor((colIndex - 1) / 26);
  }
  return letter;
}

function loadConfig(relativePath, env) {
  const fullPath = getFullPath(relativePath);
  const data = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
  return data[env] || {};
}

async function setZoom(page, ratio = '0.8') {
 await page.evaluate(() => {document.body.style.zoom = ratio;});
}

async function writeTestResults(env, module, code, result) {
  const credsPath = __dirname + '/google-sheets-key.json';
  const credentials = require(credsPath);
  const scopes = ['https://www.googleapis.com/auth/spreadsheets'];
  const auth = new google.auth.GoogleAuth({ credentials, scopes });
  const sheets = google.sheets({ version: 'v4', auth });
  const spreadsheetId = '1Xp4x67JuX6ldv36dE5JUgQkT8kENn655jIbnds9SkZw';
  const sheet = module;
  const getRows = await sheets.spreadsheets.values.get({
    spreadsheetId,
    range: `${sheet}`
  });
  const rows = getRows.data.values;
  if (!rows || rows.length < 8) return; // Not enough data
  const headers = Array.from(new Set(rows[6])); // Header row (row 7, index 6)
  const records = rows.slice(7); // Data rows start from row 8 (index 7)

  const envMapping = {
    local: ['LOCALResult', 'LOCALDate'],
    sit: ['SITResult', 'SITDate'],
    uat: ['UATResult', 'UATDate'],
    prod: ['PRODResult', 'PRODDate'],
  };
  const [lblResult, lblDate] = envMapping[env] || envMapping['local'];
  const idxResult = headers.indexOf(lblResult);
  const idxDate = headers.indexOf(lblDate);
  const idxCode = headers.indexOf('Code');
  if (idxResult === -1 || idxDate === -1 || idxCode === -1) return;

  const colLetterResult = colToLetter(idxResult + 1);
  const colLetterDate = colToLetter(idxDate + 1);
  const currentDate = DateTime.now().toFormat('yyyy-MM-dd');

  for (let i = 0; i < records.length; ++i) {
    const record = records[i];
    if (record[idxCode] === code) {
      const rowNum = i + 8; // Sheet row number (1-based)
      const prevResult = record[idxResult];
      const prevDate = record[idxDate];
      if (prevResult === 'PASSED' && prevDate === currentDate) return; // No update needed
      await sheets.spreadsheets.values.batchUpdate({
        spreadsheetId,
        requestBody: {
          valueInputOption: 'RAW',
          data: [
            {
              range: `${sheet}!${colLetterResult}${rowNum}`,
              values: [[result]]
            },
            {
              range: `${sheet}!${colLetterDate}${rowNum}`,
              values: [[currentDate]]
            }
          ]
        }
      });
      break;
    }
  }
}

async function executeQuery(type, host, port, usr, pwd, db, q) {
  if (type === 'mysql') {
    const conn = await mysql.createConnection({ host: host, port: port, user: usr, password: pwd, database: db });
    const rows = await conn.execute(q);
    await conn.end();
    return rows;
  } else if (type === 'mssql') {
    const conn = await sql.connect({ server: host, port: port, user: usr, password: pwd, database: db, options: { trustServerCertificate: true } });
    const rows = await conn.request().query(q);
    await conn.close();
    return rows.recordset;
  } else {
    throw new Error('Unsupported DB type');
  }
}

module.exports = {
  handleNone,
  readCsv,
  readJson,
  getFullPath,
  colToLetter,
  loadConfig,
  setZoom,
  writeTestResults,
  executeQuery,
};