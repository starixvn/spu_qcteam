import { BasePage } from "../../BasePage";
import { LoginLocator } from "../locator/LoginLocator";
import { WebService } from "../../../services/web";
import { fileConfigs } from "../../../../playwright.config";

export class LoginPage extends BasePage {
    protected readonly service: WebService = new WebService();
    protected readonly locator: LoginLocator = new LoginLocator();

    constructor() {
        super('Login', '/UserLogin/Login');
    }

    async verifyLoginForm(): Promise<void> { 
        await super.navigateToPage(fileConfigs[0].web.baseURL);
        await this.service.waitForVisible(this.locator.form.txt_Username);
        await this.service.waitForVisible(this.locator.form.txt_Password);
        await this.service.waitForVisible(this.locator.form.btn_Login);

        console.log('✅ Login form elements verified and enabled');
    }

    async performLogin(username: string, password: string, isSaveSession: boolean = false): Promise<void> {
        await this.verifyLoginForm();
        await this.service.fill(this.locator.form.txt_Username, username, true);
        await this.service.fill(this.locator.form.txt_Password, password, true);
        await this.service.click(this.locator.form.btn_Login);
        if (isSaveSession) {
            await this.service.saveSessionState(fileConfigs[0].session.sessionFile);
        }

        console.log(`✅ Login action completed for user: ${username}`);
    }

    async adminLogin(isSaveCookies: boolean): Promise<void> {   
        await this.performLogin(fileConfigs[0].web.credentials.admin.username, fileConfigs[0].web.credentials.admin.password, isSaveCookies);
        
        console.log(`✅ Login action completed for user: ${fileConfigs[0].web.credentials.admin.username}`);
    }

    async userLogin(isSaveCookies: boolean): Promise<void> {   
        await this.performLogin(fileConfigs[0].web.credentials.user.username, fileConfigs[0].web.credentials.user.password, isSaveCookies);
        
        console.log(`✅ Login action completed for user: ${fileConfigs[0].web.credentials.user.username}`);
    }

    async validatePageState(): Promise<boolean> {
        try {
            await this.verifyLoginForm();
            return true;
        } catch (error) {
            console.error(`❌ Login page validation failed:`, error);
            return false;
        }
    }
}