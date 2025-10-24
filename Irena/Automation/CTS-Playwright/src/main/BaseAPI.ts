import { APIService } from "../services/api";

export class BaseAPI {
    protected readonly service: APIService;

    constructor() {
        this.service = new APIService();
    }

}