import { test, request, expect, APIRequestContext, APIResponse, APIRequest, TestInfo } from "@playwright/test";

export {
  test,
  request,
  expect,
  APIRequestContext,
  APIRequest,
  APIResponse,
  TestInfo,
};

/**
 * API service interface for HTTP requests using Playwright's APIRequestContext
 * Provides methods for RESTful API testing with built-in assertions
 */
export interface IAPIService {
  initContext(context: APIRequestContext): void;

  // HTTP methods
  get(url: string, params?: Record<string, any>, headers?: Record<string, string>): Promise<APIResponse>;
  post(url: string, data?: any, headers?: Record<string, string>): Promise<APIResponse>;
  put(url: string, data?: any, headers?: Record<string, string>): Promise<APIResponse>;
  patch(url: string, data?: any, headers?: Record<string, string>): Promise<APIResponse>;
  delete(url: string, headers?: Record<string, string>): Promise<APIResponse>;

  // Utils
  setAuthHeader(token: string): void;
  clearAuthHeader(): void;

  // Assertions
  expectStatus(response: APIResponse, status: number): Promise<void>;
  expectJsonContains(response: APIResponse, expected: any): Promise<void>;
  expectHeader(response: APIResponse, headerName: string, expectedValue: string | RegExp): Promise<void>;
}

export class APIService implements IAPIService {
  protected static context: APIRequestContext;
  protected static defaultHeaders: Record<string, string> = {};

  protected get context(): APIRequestContext {
    if (!APIService.context) {
      throw new Error('APIRequestContext not initialized! Call initContext(context) first.');
    }
    return APIService.context;
  }

  initContext(context: APIRequestContext): void {
    APIService.context = context;
  }

  async get(url: string, params?: Record<string, any>, headers?: Record<string, string>): Promise<APIResponse> {
    try {
      const queryString = params ? `?${new URLSearchParams(params).toString()}` : "";
      return await this.context.get(url + queryString, { 
        headers: { ...APIService.defaultHeaders, ...headers } 
      });
    } catch (error) {
      throw new Error(`GET request failed for '${url}': ${error}`);
    }
  }

  async post(url: string, data?: any, headers?: Record<string, string>): Promise<APIResponse> {
    try {
      return await this.context.post(url, { 
        data, 
        headers: { ...APIService.defaultHeaders, ...headers } 
      });
    } catch (error) {
      throw new Error(`POST request failed for '${url}': ${error}`);
    }
  }

  async put(url: string, data?: any, headers?: Record<string, string>): Promise<APIResponse> {
    try {
      return await this.context.put(url, { 
        data, 
        headers: { ...APIService.defaultHeaders, ...headers } 
      });
    } catch (error) {
      throw new Error(`PUT request failed for '${url}': ${error}`);
    }
  }

  async patch(url: string, data?: any, headers?: Record<string, string>): Promise<APIResponse> {
    try {
      return await this.context.patch(url, { 
        data, 
        headers: { ...APIService.defaultHeaders, ...headers } 
      });
    } catch (error) {
      throw new Error(`PATCH request failed for '${url}': ${error}`);
    }
  }

  async delete(url: string, headers?: Record<string, string>): Promise<APIResponse> {
    try {
      return await this.context.delete(url, { 
        headers: { ...APIService.defaultHeaders, ...headers } 
      });
    } catch (error) {
      throw new Error(`DELETE request failed for '${url}': ${error}`);
    }
  }

  setAuthHeader(token: string): void {
    APIService.defaultHeaders["Authorization"] = `Bearer ${token}`;
  }

  clearAuthHeader(): void {
    delete APIService.defaultHeaders["Authorization"];
  }

  async expectStatus(response: APIResponse, status: number): Promise<void> {
    const actualStatus = response.status();
    expect(actualStatus, `Expected status ${status}, got ${actualStatus} for ${response.url()}`).toBe(status);
  }

  async expectJsonContains(response: APIResponse, expected: any): Promise<void> {
    try {
      const body = await response.json();
      for (const [key, value] of Object.entries(expected)) {
        expect(body[key], `Expected '${key}' to equal '${value}' in response body`).toEqual(value);
      }
    } catch (error) {
      throw new Error(`Failed to parse JSON response from ${response.url()}: ${error}`);
    }
  }

  async expectHeader(response: APIResponse, headerName: string, expectedValue: string | RegExp): Promise<void> {
    const headers = response.headers();
    const header = headers[headerName.toLowerCase()];
    
    if (header === undefined) {
      throw new Error(`Header '${headerName}' not found in response from ${response.url()}. Available headers: ${Object.keys(headers).join(', ')}`);
    }
    
    expect(header, `Expected header '${headerName}' to match '${expectedValue}', got '${header}'`).toMatch(expectedValue);
  }
}