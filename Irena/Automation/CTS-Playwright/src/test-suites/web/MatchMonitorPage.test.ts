import { test, WebService } from "../../services/web";
import { DatabaseService } from "../../services/database";
import { request, Context, APIService } from "../../services/api";
import { HelperService } from "../../services/helper";

const webService = new WebService();
const dbService = new DatabaseService();
const apiService = new APIService();
const helperService = new HelperService();
const baseURL = 'https://cts.nexdev.net/main';

test('Initial Data of Match Monitor Page', async () => {
    let ctsMain = await dbService.connectServer('ctsMain', 'mysql2', '10.18.200.70', 3307, helperService.base64Decode('aXJlbmEudm4='), helperService.base64Decode('MTIzNDU2'));
    let dbProd = await dbService.connectServer('dbProd', 'mssql', '10.18.200.17', 1433, helperService.base64Decode('dGVzdHRlYW0='), helperService.base64Decode('QHF1YWxpdHkj'));
    let dbTrans = await dbService.connectServer('dbTrans', 'mssql', '10.18.200.55', 1433, helperService.base64Decode('dGVzdHRlYW0='), helperService.base64Decode('QHF1YWxpdHkj'));
    let db061 = await dbService.connectServer('db061', 'mssql', '10.18.200.56', 1433, helperService.base64Decode('c3B1dGVhbQ=='), helperService.base64Decode('QHNwdXRlYW0j'));

    let ctsDataCenter = await dbService.connectDatabase(ctsMain, 'CTS_DataCenter');
    let bodb02Match = await dbService.connectDatabase(dbProd, 'bodb02');
    let bodb02Trans = await dbService.connectDatabase(dbTrans, 'bodb02');
    let bodb02MM = await dbService.connectDatabase(db061, 'bodb02');

    await dbService.execQuery(ctsDataCenter, 'select * from SystemParameter where ParameterID IN (20,29, 47,48, 120,121, 100,101, 128, 125, 162,163, 171,172,173,174);');
    await dbService.execQuery(ctsDataCenter, 'update SystemParameter set ParameterValue = 0 where ParameterID IN (20,29, 47,48, 120,121, 100,101, 128, 125, 162,163, 171,172,173,174);');
    await dbService.execQuery(bodb02Match, "select * from dbo.match with(nolock) where MatchCode like 'Match Monitor%'");
    await dbService.execQuery(bodb02Match, "delete from dbo.match where MatchCode like 'Match Monitor%'");
    await dbService.execQuery(bodb02Trans, "select * from dbo.match with(nolock) where MatchCode like 'Match Monitor%'");
    await dbService.execQuery(bodb02MM, "select * from dbo.match with(nolock) where MatchCode like 'Match Monitor%'");
});

test('Redirect to Match Monitor Page', async ({ page }) => {
    await webService.initPage(page);
    await webService.navigate(`${baseURL}/UserLogin/Login`);
    await webService.fill('#username', 'sa', true);
    await webService.fill('#password', '1234aa', true);
    await webService.click('button:has-text("Login")');  
    await webService.navigate(`${baseURL}/MatchMonitor`);
    await webService.click('#btnGenerate');
    await webService.screenshot('#tblMonitor_wrapper > div.dataTables_scroll > div.dataTables_scrollHead > div > table', 'image', 'jpeg');
});

test("call API", async () => {
  const requestContext = await request.newContext({
    baseURL: "https://cts-api.nexdev.net",
    extraHTTPHeaders: {
      "Content-Type": "application/json"
    }
  });

  apiService.initContext(Context);

  const response = await apiService.get("/v1/api/Cts/GetCustomerClassification", {
    custIdList: "178951467,179808501,206735244"
  });

  await apiService.expectStatus(response, 200);
  const body = await response.json();
  console.log(body);
});