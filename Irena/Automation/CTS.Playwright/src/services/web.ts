import { test, expect, Page, Locator, ViewportSize, BrowserContext, TestInfo } from "@playwright/test";
import { HelperService } from "./helper";

const helperService = new HelperService();

export {
  test,
  expect,
  Page,
  BrowserContext as Context,
  Locator,
  TestInfo,
};

/**
 * Web automation service interface using Playwright
 * Provides comprehensive browser automation capabilities for testing
 */
export interface IWebService {
  // Page
  initPage(page: Page): void;
  getAllPages(): Promise<Page[]>;
  switchToPage(index: number): Promise<Page>;
  closePage(index: number): Promise<void>;
  closeAllPages(): Promise<void>;

  setViewportSize(size: ViewportSize): Promise<void>;
  setScalePercent(percent: number): Promise<void>;
  getViewportSize(): Promise<ViewportSize>;

  saveSessionState(path: string): Promise<void>;
  loadSessionState(path: string): Promise<void>;
  clearSessionState(): Promise<void>;

  // Navigation
  navigate(url: string): Promise<void>;
  goBack(): Promise<void>;
  goForward(): Promise<void>;
  reload(): Promise<void>;
  getURL(): string;
  getTitle(): Promise<string>;
  getPageSource(): Promise<string>;

  // Interaction
  fill(locator: string, value: string, isClear?: boolean): Promise<void>;
  clear(locator: string): Promise<void>;
  click(locator: string): Promise<void>;
  doubleClick(locator: string): Promise<void>;
  rightClick(locator: string): Promise<void>;
  hover(locator: string): Promise<void>;
  focus(locator: string): Promise<void>;
  blur(locator: string): Promise<void>;
  press(locator: string, key: string): Promise<void>;
  selectOption(locator: string, value: string | string[]): Promise<void>;
  check(locator: string): Promise<void>;
  uncheck(locator: string): Promise<void>;
  dragTo(locator: string, target: string): Promise<void>;
  scrollIntoView(locator: string): Promise<void>;

  // Keyboard & mouse
  keyboardType(text: string): Promise<void>;
  keyboardPress(key: string): Promise<void>;
  keyboardDown(key: string): Promise<void>;
  keyboardUp(key: string): Promise<void>;
  mouseMove(x: number, y: number, button?: "left" | "right" | "middle"): Promise<void>;
  mouseClick(x: number, y: number, button?: "left" | "right" | "middle"): Promise<void>;
  mouseDrag(fromX: number, fromY: number, toX: number, toY: number, button?: "left" | "right" | "middle"): Promise<void>;
  mouseDown(button?: "left" | "right" | "middle"): Promise<void>;
  mouseUp(button?: "left" | "right" | "middle"): Promise<void>;

  // File & media
  uploadFile(locator: string, path: string): Promise<void>;
  screenshot(locator: string, path: string, type?: "png" | "jpeg"): Promise<void>;
  startVideoRecording(path: string): Promise<void>;
  stopVideoRecording(): Promise<void>;

  // Waiting
  waitForVisible(locator: string): Promise<void>;
  waitForHidden(locator: string): Promise<void>;
  waitForEnabled(locator: string): Promise<void>;
  waitForDisabled(locator: string): Promise<void>;
  waitForURL(url: string | RegExp): Promise<void>;
  waitForState(state: "load" | "domcontentloaded" | "networkidle"): Promise<void>;

  // Assertions
  expectToBeVisible(locator: string): Promise<void>;
  expectToBeHidden(locator: string): Promise<void>;
  expectToBeEnabled(locator: string): Promise<void>;
  expectToBeDisabled(locator: string): Promise<void>;
  expectToBeChecked(locator: string): Promise<void>;
  expectToBeSelected(locator: string): Promise<void>;
  expectToBeFocused(locator: string): Promise<void>;
  expectToBeEmpty(locator: string): Promise<void>;
  expectToBeEditable(locator: string): Promise<void>;
  expectToHaveText(locator: string, text: string | RegExp): Promise<void>;
  expectToContainText(locator: string, text: string | RegExp): Promise<void>;
  expectToHaveAttribute(locator: string, name: string, value: string | RegExp): Promise<void>;
  expectToHaveClass(locator: string, className: string): Promise<void>;
  expectToHaveValue(locator: string, value: string | RegExp): Promise<void>;
  expectToHaveCount(locator: string, count: number): Promise<void>;
  expectToHaveURL(url: string | RegExp): Promise<void>;
  expectToHaveTitle(title: string | RegExp): Promise<void>;
  expectToContainClass(locator: string, className: string | RegExp): Promise<void>;
  expectToHaveCSS(locator: string, name: string, value: string | RegExp): Promise<void>;
  expectToHaveId(locator: string, id: string | RegExp): Promise<void>;
  expectToHaveRole(locator: string, role: "button" | "article" | "blockquote" | "caption" | "code" | "dialog" | "figure" | "form" | "img" | "link" | "main" | "menu" | "meter" | "option" | "search" | "strong" | "table" | "textbox" | "checkbox" | "radio" | "combobox" | "listbox" | "tree" | "grid" | "tabpanel" | "tab" | "tablist" | "banner" | "complementary" | "contentinfo" | "navigation" | "region" | "alert" | "alertdialog" | "application" | "document" | "feed" | "log" | "marquee" | "presentation" | "status" | "timer" | "tooltip" | "cell" | "columnheader" | "gridcell" | "row" | "rowgroup" | "rowheader" | "group" | "heading" | "list" | "listitem" | "menuitem" | "menuitemcheckbox" | "menuitemradio" | "none" | "note" | "option" | "progressbar" | "scrollbar" | "separator" | "slider" | "spinbutton" | "switch" | "tab" | "tabpanel" | "treeitem"): Promise<void>;
}

export class WebService implements IWebService {
  protected page!: Page;

  initPage(page: Page): void {
    this.page = page;
  }

  async getAllPages(): Promise<Page[]> {
    return this.page.context().pages();
  }

  async switchToPage(index: number): Promise<Page> {
    const pages = await this.getAllPages();
    if (index < 0 || index >= pages.length) {
      throw new Error(`Invalid page index ${index}. Available pages: 0-${pages.length - 1}`);
    }
    this.page = pages[index];
    return this.page;
  }

  async closePage(index: number): Promise<void> {
    const pages = await this.getAllPages();
    if (index < 0 || index >= pages.length) {
      throw new Error(`Invalid page index ${index}. Available pages: 0-${pages.length - 1}`);
    }
    await pages[index].close();
  }

  async closeAllPages(): Promise<void> {
    const pages = await this.getAllPages();
    for (const p of pages) {
      if (!p.isClosed()) await p.close();
    }
  }

  async setViewportSize(size: ViewportSize): Promise<void> {
    await this.page.setViewportSize(size);
  }

  async setScalePercent(percent: number): Promise<void> {
    await this.page.evaluate((p) => {
      document.body.style.zoom = `${p}%`;
    }, percent);
  }

  async getViewportSize(): Promise<ViewportSize> {
    return this.page.viewportSize()!;
  }

  async saveSessionState(path: string): Promise<void> {
    try {
      const cookies = await this.page.context().cookies();
      helperService.writeJSON(path, { cookies });
      console.log(`✅ Cookies saved: ${cookies.length} -> ${path}`);
      return;
    } catch (err) {
      console.error("❌ Failed to save cookies:", err);
      return;
    }
  }

  async loadSessionState(path: string): Promise<void> {
    try {
      if (!helperService.validateJSONFile(path)) {
        console.warn(`⚠️ Cookie file not found: ${path}`);
        return;
      }

      const data = helperService.readJSON<any>(path);

      await this.page.context().addCookies(data.cookies);
      console.log(`✅ Cookies loaded: ${data.cookies.length} -> ${path}`);
      return;
    } catch (err) {
      console.error("❌ Failed to load cookies:", err);
      return;
    }
  }

  async clearSessionState(): Promise<void> {
    await this.page.evaluate(() => {
      localStorage.clear();
      sessionStorage.clear();
    });
    console.log('✅ Storage state cleared');
  }

  async navigate(url: string): Promise<void> {
    await this.page.goto(url);
  }

  async goBack(): Promise<void> {
    await this.page.goBack();
  }

  async goForward(): Promise<void> {
    await this.page.goForward();
  }

  async reload(): Promise<void> {
    await this.page.reload();
  }

  getURL(): string {
    return this.page.url();
  }

  async getTitle(): Promise<string> {
    return this.page.title();
  }

  async getPageSource(): Promise<string> {
    return this.page.content();
  }

  async fill(locator: string, value: string, isClear: boolean = false): Promise<void> {
    if (isClear) {
      await this.clear(locator);
    }
    await this.page.fill(locator, value);
  }

  async clear(locator: string): Promise<void> {
    await this.page.fill(locator, '');
  }

  async click(locator: string): Promise<void> {
    await this.page.click(locator);
  }

  async doubleClick(locator: string): Promise<void> {
    await this.page.dblclick(locator);
  }

  async rightClick(locator: string): Promise<void> {
    await this.page.click(locator, { button: "right" });
  }

  async hover(locator: string): Promise<void> {
    await this.page.hover(locator);
  }

  async focus(locator: string): Promise<void> {
    await this.page.focus(locator);
  }

  async blur(locator: string): Promise<void> {
    await this.page.evaluate((sel) => {
      const el = document.querySelector(sel) as HTMLElement;
      el?.blur();
    }, locator);
  }

  async press(locator: string, key: string): Promise<void> {
    await this.page.press(locator, key);
  }

  async selectOption(locator: string, value: string | string[]): Promise<void> {
    await this.page.selectOption(locator, value);
  }

  async check(locator: string): Promise<void> {
    await this.page.check(locator);
  }

  async uncheck(locator: string): Promise<void> {
    await this.page.uncheck(locator);
  }

  async dragTo(locator: string, target: string): Promise<void> {
    await this.page.dragAndDrop(locator, target);
  }

  async scrollIntoView(locator: string): Promise<void> {
    await this.page.locator(locator).scrollIntoViewIfNeeded();
  }

  async keyboardType(text: string): Promise<void> {
    await this.page.keyboard.type(text);
  }

  async keyboardPress(key: string): Promise<void> {
    await this.page.keyboard.press(key);
  }

  async keyboardDown(key: string): Promise<void> {
    await this.page.keyboard.down(key);
  }

  async keyboardUp(key: string): Promise<void> {
    await this.page.keyboard.up(key);
  }

  async mouseMove(x: number, y: number, button?: "left" | "right" | "middle"): Promise<void> {
    await this.page.mouse.move(x, y, { steps: 5 });
  }

  async mouseClick(x: number, y: number, button: "left" | "right" | "middle" = "left"): Promise<void> {
    await this.page.mouse.click(x, y, { button });
  }

  async mouseDrag(fromX: number, fromY: number, toX: number, toY: number, button: "left" | "right" | "middle" = "left"): Promise<void> {
    await this.page.mouse.move(fromX, fromY);
    await this.page.mouse.down({ button });
    await this.page.mouse.move(toX, toY);
    await this.page.mouse.up({ button });
  }

  async mouseDown(button: "left" | "right" | "middle" = "left"): Promise<void> {
    await this.page.mouse.down({ button });
  }

  async mouseUp(button: "left" | "right" | "middle" = "left"): Promise<void> {
    await this.page.mouse.up({ button });
  }

  async uploadFile(locator: string, path: string): Promise<void> {
    await this.page.setInputFiles(locator, path);
  }

  async screenshot(locator: string, path: string, type: "png" | "jpeg" = "png"): Promise<void> {
    try {
      await this.page.locator(locator).screenshot({ path, type });
    } catch (error) {
      throw new Error(`Failed to take screenshot of '${locator}' to '${path}': ${error}`);
    }
  }

  async startVideoRecording(path: string): Promise<void> {
    console.warn("Playwright does not support manual start/stop video recording. Configure in context instead.");
  }

  async stopVideoRecording(): Promise<void> {
    console.warn("Playwright stops video recording automatically when context is closed.");
  }

  async waitForVisible(locator: string): Promise<void> {
    await this.page.waitForSelector(locator, { state: "visible" });
  }

  async waitForHidden(locator: string): Promise<void> {
    await this.page.waitForSelector(locator, { state: "hidden" });
  }

  async waitForEnabled(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeEnabled();
  }

  async waitForDisabled(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeDisabled();
  }

  async waitForURL(url: string | RegExp): Promise<void> {
    await this.page.waitForURL(url);
  }

  async waitForState(state: "load" | "domcontentloaded" | "networkidle"): Promise<void> {
    await this.page.waitForLoadState(state);
  }

  async expectToBeVisible(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeVisible();
  }

  async expectToBeHidden(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeHidden();
  }

  async expectToBeEnabled(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeEnabled();
  }

  async expectToBeDisabled(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeDisabled();
  }

  async expectToBeChecked(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeChecked();
  }

  async expectToBeSelected(locator: string): Promise<void> {
    const element = this.page.locator(locator);
    const tagName = await element.evaluate(el => el.tagName.toLowerCase());
    
    if (tagName === 'option') {
      await expect(element).toHaveAttribute('selected', '');
    } else {
      await expect(element).toBeChecked();
    }
  }

  async expectToBeFocused(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeFocused();
  }

  async expectToBeEmpty(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeEmpty();
  }

  async expectToBeEditable(locator: string): Promise<void> {
    await expect(this.page.locator(locator)).toBeEditable();
  }

  async expectToHaveText(locator: string, text: string | RegExp): Promise<void> {
    await expect(this.page.locator(locator)).toHaveText(text);
  }

  async expectToContainText(locator: string, text: string | RegExp): Promise<void> {
    await expect(this.page.locator(locator)).toContainText(text);
  }

  async expectToHaveAttribute(locator: string, name: string, value: string | RegExp): Promise<void> {
    await expect(this.page.locator(locator)).toHaveAttribute(name, value);
  }

  async expectToHaveClass(locator: string, className: string): Promise<void> {
    await expect(this.page.locator(locator)).toHaveClass(className);
  }

  async expectToHaveValue(locator: string, value: string | RegExp): Promise<void> {
    await expect(this.page.locator(locator)).toHaveValue(value);
  }

  async expectToHaveCount(locator: string, count: number): Promise<void> {
    await expect(this.page.locator(locator)).toHaveCount(count);
  }

  async expectToHaveURL(url: string | RegExp): Promise<void> {
    await expect(this.page).toHaveURL(url);
  }

  async expectToHaveTitle(title: string | RegExp): Promise<void> {
    await expect(this.page).toHaveTitle(title);
  }

  async expectToContainClass(locator: string, className: string | RegExp): Promise<void> {
    const classes = await this.page.locator(locator).getAttribute("class");
    if (!classes || !new RegExp(className.toString()).test(classes)) {
      throw new Error(`Class ${className} not found in ${classes}`);
    }
  }

  async expectToHaveCSS(locator: string, name: string, value: string | RegExp): Promise<void> {
    await expect(this.page.locator(locator)).toHaveCSS(name, value);
  }

  async expectToHaveId(locator: string, id: string | RegExp): Promise<void> {
    await expect(this.page.locator(locator)).toHaveId(id);
  }

  async expectToHaveRole(locator: string, role: "button" | "article" | "blockquote" | "caption" | "code" | "dialog" | "figure" | "form" | "img" | "link" | "main" | "menu" | "meter" | "option" | "search" | "strong" | "table" | "textbox" | "checkbox" | "radio" | "combobox" | "listbox" | "tree" | "grid" | "tabpanel" | "tab" | "tablist" | "banner" | "complementary" | "contentinfo" | "navigation" | "region" | "alert" | "alertdialog" | "application" | "document" | "feed" | "log" | "marquee" | "presentation" | "status" | "timer" | "tooltip" | "cell" | "columnheader" | "gridcell" | "row" | "rowgroup" | "rowheader" | "group" | "heading" | "list" | "listitem" | "menuitem" | "menuitemcheckbox" | "menuitemradio" | "none" | "note" | "option" | "progressbar" | "scrollbar" | "separator" | "slider" | "spinbutton" | "switch" | "tab" | "tabpanel" | "treeitem"): Promise<void> {
    await expect(this.page.locator(locator)).toHaveRole(role);
  }
}