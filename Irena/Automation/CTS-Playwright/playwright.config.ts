import { defineConfig, devices } from '@playwright/test';
import type { PlaywrightTestConfig } from '@playwright/test';
import * as dotenv from 'dotenv';
import { HelperService } from './src/services/helper';

const helperService = new HelperService();

// Load environment variables from .env file
dotenv.config({ path: '.env' });

// Interfaces
export interface FileConfig {
  environment: string;
  web: {
    browserList: string;
    baseURL: string;
    headless: boolean;
    parallel: boolean;
    retries: number;
    workers: number;
    ci_mode: boolean;
    credentials: {
      admin: { username: string; password: string };
      user: { username: string; password: string };
    };
  };
  api: {
    baseURL: string;
  };
  database: {
    credentials: {
      [key: string]: {
        client: string;
        server: string;
        host: string;
        port: number;
        username: string;
        password: string;
      };
    };
  };
  session: Record<string, any>;
}

// Constants
export const envConfig = {
  envList: process.env.ENV_LIST ? process.env.ENV_LIST.split(',') : ['local'],
  webTimeout: Number(process.env.WEB_TIMEOUT) || 30000,
  webViewportWidth: Number(process.env.WEB_VIEWPORT_WIDTH) || 1366,
  webViewportHeight: Number(process.env.WEB_VIEWPORT_HEIGHT) || 768,
  webScalePercent: Number(process.env.WEB_SCALE_PERCENT) || 0.8,
  webFile: process.env.WEB_FILE || './src/configs/web.json',
  apiTimeout: Number(process.env.API_TIMEOUT) || 10000,
  apiFile: process.env.API_FILE || './src/configs/api.json',
  databaseFile: process.env.DATABASE_FILE || './src/configs/database.json',
  sessionFile: process.env.SESSION_FILE || './src/configs/session.json',
  initDataDir: process.env.INITDATA_DIR || './src/data/init-data/',
  testDataDir: process.env.TESTDATA_DIR || './src/data/test-data/',
  testSuitesDir: process.env.TESTSUITES_DIR || './src/test-suites/',
  testResultsDir: process.env.TESTRESULTS_DIR || './src/test-results/',
  googleKey: process.env.GOOGLE_KEY || './src/keys/google.json',
  n8nKey: process.env.N8N_KEY || './src/keys/n8n.json',
  slackKey: process.env.SLACK_KEY || './src/keys/slack.json',
}

console.log(envConfig);

// Utilites
function loadFileConfigs(): FileConfig[] {
  const configs: FileConfig[] = [];
  const webJson = helperService.readJSON(envConfig.webFile);
  const apiJson = helperService.readJSON(envConfig.apiFile);
  const dbJson = helperService.readJSON(envConfig.databaseFile);
  const sessionJson = helperService.readJSON(envConfig.sessionFile);

  envConfig.envList.forEach(env => {
    const parsedConfig = {
      web: webJson[env],
      api: apiJson[env],
      database: dbJson[env],
      session: sessionJson[env],
    };

    // Decode web credentials
    const webCreds: any = {};
    if (parsedConfig.web?.credentials?.admin) {
      webCreds.admin = {
        username: parsedConfig.web.credentials.admin.username ? 
          helperService.base64Decode(parsedConfig.web.credentials.admin.username) : '',
        password: parsedConfig.web.credentials.admin.password ? 
          helperService.base64Decode(parsedConfig.web.credentials.admin.password) : '',
      };
    }
    if (parsedConfig.web?.credentials?.user) {
      webCreds.user = {
        username: parsedConfig.web.credentials.user.username ? 
          helperService.base64Decode(parsedConfig.web.credentials.user.username) : '',
        password: parsedConfig.web.credentials.user.password ? 
          helperService.base64Decode(parsedConfig.web.credentials.user.password) : '',
      };
    }

    // Decode database credentials
    const dbCreds: any = {};
    if (parsedConfig.database?.credentials) {
      Object.entries(parsedConfig.database.credentials).forEach(([key, cred]: [string, any]) => {
        dbCreds[key] = {
          ...cred,
          username: cred.username ? helperService.base64Decode(cred.username) : cred.username,
          password: cred.password ? helperService.base64Decode(cred.password) : cred.password,
        };
      });
    }

    configs.push({
      environment: env,
      web: {
        browserList: parsedConfig.web?.browserList || '',
        baseURL: parsedConfig.web?.baseURL || '',
        headless: parsedConfig.web?.headless || false,
        parallel: parsedConfig.web?.parallel || false,
        retries: parsedConfig.web?.retries || 2,
        workers: parsedConfig.web?.workers || 1,
        ci_mode: parsedConfig.web?.ci_mode || false,
        credentials: webCreds,
      },
      api: {
        baseURL: parsedConfig.api?.baseURL || '',
      },
      database: {
        credentials : dbCreds,
      },
      session: parsedConfig.session || {},
    });
  });

  return configs;
}

export const fileConfigs = loadFileConfigs();
console.log(fileConfigs);

export const testWebConfig: PlaywrightTestConfig = defineConfig({
  testDir: `${envConfig.testSuitesDir}/web`,
  outputDir: `${envConfig.testResultsDir}/web`,
  reporter: [['html'], ['list']],
  timeout: envConfig.webTimeout,

  use: {
    viewport: { 
      width: envConfig.webViewportWidth, 
      height: envConfig.webViewportHeight 
    },
    deviceScaleFactor: envConfig.webScalePercent,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: fileConfigs.flatMap(fc =>
    fc.web.browserList.split(',').map(browser => {
      const browserName = browser.trim();
      const deviceKey =
        browserName.toLowerCase() === 'chrome'
          ? 'Desktop Chrome'
          : browserName.toLowerCase() === 'firefox'
          ? 'Desktop Firefox'
          : browserName.toLowerCase() === 'msedge'
          ? 'Desktop Edge'
          : browserName.toLowerCase() === 'webkit'
          ? 'Desktop Safari'
          : 'Desktop Chrome';

      return {
        name: `${fc.environment}-${browserName}`,
        use: {
          ...devices[deviceKey],
          baseURL: fc.web.baseURL,
          headless: fc.web.headless,
          parallel: fc.web.parallel,
          retries: fc.web.retries,
          workers: fc.web.workers,
          ci_mode: fc.web.ci_mode,
        },
      };
    })
  ),
});
console.log(testWebConfig);

export const testApiConfig: PlaywrightTestConfig = defineConfig({
  testDir: `${envConfig.testSuitesDir}/api`,
  outputDir: `${envConfig.testResultsDir}/api`,
  reporter: [['html'], ['list']],
  timeout: envConfig.apiTimeout,

  use: {
    extraHTTPHeaders: { 'Content-Type': 'application/json' },
    trace: 'on-first-retry',
  },

  projects: fileConfigs.map(fc => ({
    name: fc.environment,
    use: {
      baseURL: fc.api.baseURL,
    },
  })),
});
console.log(testApiConfig);
