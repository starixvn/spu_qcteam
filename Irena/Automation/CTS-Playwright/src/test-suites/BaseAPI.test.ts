import { APIService, APIRequestContext, request } from "../services/api";
import { testApiConfig } from "../../playwright.config";

export class BaseAPITest {
  public apiService!: APIService;

  async  runAllEnv(){
    for (const project of testApiConfig.projects || []) {
        const envName = project.name;
        const baseURL = project.use?.baseURL;

        console.log(`🚀 Running API tests for [${envName}] -> ${baseURL}`);
    }
  }


  async initAPI(config: testApiConfig): Promise<void> {
    const baseURL = testApiConfig.projects?.find(p => p.name === "uat");
    if (!baseURL) {
      throw new Error(`❌ baseURL not defined in config for project ${config.project.name}`);
    }

    const context: APIRequestContext = await request.newContext({
      baseURL,
      extraHTTPHeaders: {
        "Content-Type": "application/json"
      }
    });

    this.apiService = new APIService();
    this.apiService.initContext(context);
  }
}
