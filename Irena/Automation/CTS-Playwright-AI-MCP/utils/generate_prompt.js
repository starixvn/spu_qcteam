// Run CMD: node utils/generate_prompt.js ENV=<env>

const fs = require('fs');
const path = require('path');
const helpers = require('./helpers');

const envArg = process.argv.find(arg => arg.includes('ENV='));
const env = envArg ? envArg.replace('ENV=', '') : 'local';


const templatesDir = path.join(__dirname, '../core-prompts');
const envDir = path.join(__dirname, '../src', env);
const testDataDir = path.join(envDir, 'test-data');
const promptsDir = path.join(envDir, 'prompts');
if (!fs.existsSync(envDir)) fs.mkdirSync(envDir, { recursive: true });
if (!fs.existsSync(promptsDir)) fs.mkdirSync(promptsDir, { recursive: true });

let globalVars = {};
globalVars.env = env;

try {
  const envConfig = require(path.join(envDir, 'config.js'));

  if (envConfig.web) 
    globalVars.baseURL = envConfig.web.baseURL; 
    globalVars.usr = envConfig.web.usr;
    globalVars.pwd = envConfig.web.pwd;
  if (envConfig.db.ctsmain) 
    globalVars.ctsmainHost = envConfig.db.ctsmain.host;
    globalVars.ctsmainPort = envConfig.db.ctsmain.port;
    globalVars.ctsmainUsr = envConfig.db.ctsmain.usr;
    globalVars.ctsmainPwd = envConfig.db.ctsmain.pwd;
  if (envConfig.db.ctsarchive) 
    globalVars.ctsarchiveHost = envConfig.db.ctsarchive.host;
    globalVars.ctsarchivePort = envConfig.db.ctsarchive.port;
    globalVars.ctsarchiveUsr = envConfig.db.ctsarchive.usr;
    globalVars.ctsarchivePwd = envConfig.db.ctsarchive.pwd;
  if (envConfig.db.dbcust) 
    globalVars.dbcustHost = envConfig.db.dbcust.host;
    globalVars.dbcustPort = envConfig.db.dbcust.port;
    globalVars.dbcustUsr = envConfig.db.dbcust.usr;
    globalVars.dbcustPwd = envConfig.db.dbcust.pwd;  
  if (envConfig.db.db053) 
    globalVars.db053Host = envConfig.db.db053.host;
    globalVars.db053Port = envConfig.db.db053.port;
    globalVars.db053Usr = envConfig.db.db053.usr;
    globalVars.db053Pwd = envConfig.db.db053.pwd;
  if (envConfig.db.dbpro) 
    globalVars.dbproHost = envConfig.db.dbpro.host;
    globalVars.dbproPort = envConfig.db.dbpro.port;
    globalVars.dbproUsr = envConfig.db.dbpro.usr;
    globalVars.dbproPwd = envConfig.db.dbpro.pwd;
  if (envConfig.db.dbtrans) 
    globalVars.dbtransHost = envConfig.db.dbtrans.host;
    globalVars.dbtransPort = envConfig.db.dbtrans.port;
    globalVars.dbtransUsr = envConfig.db.dbtrans.usr;
    globalVars.dbtransPwd = envConfig.db.dbtrans.pwd;
  if (envConfig.db.db061) 
    globalVars.db061Host = envConfig.db.db061.host;
    globalVars.db061Port = envConfig.db.db061.port;
    globalVars.db061Usr = envConfig.db.db061.usr;
    globalVars.db061Pwd = envConfig.db.db061.pwd;
  if (envConfig.db.db055) 
    globalVars.db055Host = envConfig.db.db055.host;
    globalVars.db055Port = envConfig.db.db055.port;
    globalVars.db055Usr = envConfig.db.db055.usr;
    globalVars.db055Pwd = envConfig.db.db055.pwd;
  if (envConfig.db.dbgrp01l) 
    globalVars.dbgrp01lHost = envConfig.db.dbgrp01l.host;
    globalVars.dbgrp01lPort = envConfig.db.dbgrp01l.port;
    globalVars.dbgrp01lUsr = envConfig.db.dbgrp01l.usr;
    globalVars.dbgrp01lPwd = envConfig.db.dbgrp01l.pwd;
  } catch (e) {
  console.error('Error loading environment config:', e.message);
  process.exit(1);
}

if (!fs.existsSync(templatesDir)) {
  console.error('Templates folder not found:', templatesDir);
  process.exit(1);
}
if (!fs.existsSync(testDataDir)) {
  console.error('Test-data folder for env not found:', testDataDir);
  process.exit(1);
}

const templateFiles = fs.readdirSync(templatesDir).filter(f => f.endsWith('.txt'));
for (const templateFile of templateFiles) {
  const templatePath = path.join(templatesDir, templateFile);
  const template = fs.readFileSync(templatePath, 'utf8');
  const baseName = templateFile.replace(/\.txt$/, '');
  const jsonFile = fs.readdirSync(testDataDir).find(f => f.startsWith(baseName) && f.endsWith('.json'));
  if (!jsonFile) continue;
  const jsonPath = path.join(testDataDir, jsonFile);
  const rows = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
  rows.forEach((row) => {
    const rowVars = { ...globalVars };
    if (row.module) rowVars.module = row.module;
    if (row.code) rowVars.code = row.code;
    const promptContent = helpers.fillTemplate ? helpers.fillTemplate(template, row, rowVars) : template.replace(/\{\{(\w+)\}\}/g, (_, key) => row[key] || rowVars[key] || '');
    const promptFileName = `${baseName}__${row.module || 'module'}__${row.code || 'code'}.md`;
    const promptFilePath = path.join(promptsDir, promptFileName);
    fs.writeFileSync(promptFilePath, promptContent, 'utf8');
    console.log('Generated prompt:', promptFilePath);
  });
}