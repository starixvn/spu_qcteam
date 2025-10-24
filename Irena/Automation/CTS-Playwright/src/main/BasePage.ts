import { WebService } from "../services/web";
import { BaseLocator } from "../main/BaseLocator";
import { DateTime } from "luxon";

export abstract class BasePage {
  protected readonly service: WebService = new WebService();
  protected readonly locator: BaseLocator = new BaseLocator();
  protected readonly pageTitle: string;
  protected readonly pageEndpoint: string;
  
  constructor(pageTitle: string, pageEndpoint: string) {
    this.pageTitle = pageTitle;
    this.pageEndpoint = pageEndpoint;
  }

  getServices(): WebService {
    return this.service;
  }
  
  getLocators(): BaseLocator {
    return this.locator;
  }

  getPageTitle(): string {
    return this.pageTitle;
  }

  getPageEndpoint(): string {
    return this.pageEndpoint;
  }

  getCurrentDate(): string {
    return DateTime.now().toFormat("MMM dd, yyyy");
  }

  async navigateToPage(baseURL: string): Promise<void> {
    const fullURL = new URL(this.pageEndpoint, baseURL).toString();
    await this.service.navigate(fullURL);
    console.log(`✅ Navigated to: ${fullURL}`);
  }

  async verifyHeader(): Promise<void> {    
    const headLocators = Object.values(this.locator.header);
    for (const locator of headLocators) {
      await this.service.waitForVisible(locator);
    }
    
    console.log('✅ Header locators verified');
  }

  async verifyPanelsMenu(): Promise<void> {        
    const navLocators = Object.values(this.locator.navigation);
    for (const locator of navLocators) {
      await this.service.waitForVisible(locator);
    }
    
    console.log('✅ Navigation panels menu verified');
  }

  async verifyPageTitle(): Promise<void> {
    const titleSelector = this.locator.page.title_Page.replace("{pageTitle}", this.pageTitle);
    await this.service.waitForVisible(titleSelector);
    console.log("✅ Page title verified");
  }

  async waitForPageLoad(): Promise<void> {
    await this.verifyPageTitle();
    await this.service.waitForState('networkidle');

    console.log('✅ Page title verified and Loaded');
  }

  async validatePageState(): Promise<boolean> {
    try {
      await this.waitForPageLoad();
      return true;
    } catch (error) {
      console.error(`❌ Page validation failed for ${this.pageTitle}:`, error);
      return false;
    }
  }
}