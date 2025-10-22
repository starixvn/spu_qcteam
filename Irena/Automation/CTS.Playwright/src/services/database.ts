import knex, { Knex } from "knex";

/**
 * Database service interface for managing multiple database connections
 * Supports MySQL, PostgreSQL, and MSSQL databases through Knex.js
 */
export interface ServerEntry {
  server: string;
  client: "mysql2" | "mssql" | "postgresql";
  config: Omit<Knex.Config["connection"], "database">;
  dbs: Map<string, Knex>;
}

export interface IDatabaseService {
  connectServer(
    server: string,
    client: "mysql2" | "mssql" | "postgresql",
    host: string,
    port: number,
    username: string,
    password: string
  ): Promise<ServerEntry>;

  disconnectServer(server: string): Promise<void>;
  disconnectAllServers(): Promise<void>;
  isServerConnected(server: string): boolean;

  connectDatabase(server: ServerEntry, dbName: string): Promise<Knex>;
  disconnectDatabase(server: string, dbName: string): Promise<void>;
  isDatabaseConnected(server: string, dbName: string): boolean;

  execQuery<T = any>(dbName: Knex, sql: string, bindings?: any[]): Promise<T[]>;
}

export class DatabaseService implements IDatabaseService {
  protected static servers: Map<string, ServerEntry> = new Map();

  async connectServer(
    server: string,
    client: "mysql2" | "mssql" | "postgresql",
    host: string,
    port: number,
    username: string,
    password: string
  ): Promise<ServerEntry> {
    if (DatabaseService.servers.has(server)) {
      return DatabaseService.servers.get(server)!;
    }

    const config: any = { host, port, user: username, password };
    if (client === "mssql") config.options = { enableArithAbort: true };

    const entry: ServerEntry = { server, client, config, dbs: new Map() };
    DatabaseService.servers.set(server, entry);

    return entry;
  }

  async disconnectServer(server: string): Promise<void> {
    const entry = DatabaseService.servers.get(server);
    if (entry) {
      for (const db of entry.dbs.values()) {
        await db.destroy();
      }
      DatabaseService.servers.delete(server);
    }
  }

  async disconnectAllServers(): Promise<void> {
    for (const server of DatabaseService.servers.keys()) {
      await this.disconnectServer(server);
    }
  }

  isServerConnected(server: string): boolean {
    return DatabaseService.servers.has(server);
  }

  async connectDatabase(server: ServerEntry, dbName: string): Promise<Knex> {
    if (server.dbs.has(dbName)) return server.dbs.get(dbName)!;

    const knexInstance = knex({
      client: server.client,
      connection: { ...server.config, database: dbName },
      pool: { min: 0, max: 10 },
    });

    await knexInstance.raw("SELECT 1"); // test connection
    server.dbs.set(dbName, knexInstance);

    return knexInstance;
  }
  
  async disconnectDatabase(server: string, dbName: string): Promise<void> {
    const entry = DatabaseService.servers.get(server);
    if (entry && entry.dbs.has(dbName)) {
      await entry.dbs.get(dbName)!.destroy();
      entry.dbs.delete(dbName);
    }
  }

  isDatabaseConnected(server: string, dbName: string): boolean {
    const entry = DatabaseService.servers.get(server);
    return !!entry?.dbs.has(dbName);
  }

  async execQuery<T = any>(
    db: Knex,
    sql: string,
    bindings: any[] = []
  ): Promise<T[]> {
    const result = await db.raw(sql, bindings);
    if (result && typeof result === "object" && "rows" in result) {
      return result.rows as T[]; // PostgreSQL / MSSQL
    }
    return result as T[]; // MySQL
  }
}