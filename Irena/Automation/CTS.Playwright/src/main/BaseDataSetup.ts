import { DatabaseService } from "../services/database";
import { fileConfigs } from "../../playwright.config";

export class BaseDataSetup {
    protected readonly service: DatabaseService;

    constructor() {
        this.service = new DatabaseService();
    }

    async setupDBConnection() {
        const dbConnections = Object.values(fileConfigs[0].database.credentials as any);
        for (const db of dbConnections) {
            await this.service.connectServer(db.client, db.server, db.host, db.port, db.username, db.password);
        }

        console.log('✅ DB connections setup completed');
    }
}