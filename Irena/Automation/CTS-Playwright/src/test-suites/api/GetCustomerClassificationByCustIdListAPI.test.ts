import { test } from "../../services/api";
import { BaseAPITest } from "../../test-suites/BaseAPI.test";

test.describe("Customer API", () => {
    test("Get customer classification", async ({}, testInfo) => {
        const baseTest = new (class extends BaseAPITest {})();
        await baseTest.initAPI(testInfo);

        const response = await baseTest.apiService.get(
        "/api/Cts/GetCustomerClassification",
        { custIdList: "178951467,179808501" }
        );

        await baseTest.apiService.expectStatus(response, 200);
    });
});