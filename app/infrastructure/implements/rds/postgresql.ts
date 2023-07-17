import {Pool, PoolClient} from "pg";
import {getSecretValue} from "@infrastructure/secretManager";


export class Postgresql {
  private pgPool: Pool;

  constructor(
    user = "admin",
    password = "admin123",
    host = "localhost",
    database = "admin",
    port = 5432,
    ssl: boolean = false,
  ) {
    try {
      this.pgPool = new Pool({
        user: user,
        password: password,
        host: host,
        database: database,
        port: port,
        ssl: ssl ?? undefined,
      });
    } catch (e) {
      console.error("Pool Failed.");
      console.error(e);
    }
  }

  static async applyBySecret(region: string, secretId: string, host: string, database: string): Promise<Postgresql> {
    const secret = await getSecretValue(region, secretId);
    return new Postgresql(
      secret.username,
      secret.password,
      host,
      database,
      5432,
      true
    );
  }

  async end(): Promise<void> {
    await this.pgPool.end();
  }

  /**
   * トランザクション境界を考慮した汎用関数
   * @param callback トランザクション内で実行する処理を行う関数
   * @returns 処理結果
   */
  async withTx<T>(callback: (client: PoolClient) => Promise<T>): Promise<T> {
    const client = await this.pgPool.connect();
    try {
      await client.query("BEGIN");
      const result = await callback(client);
      await client.query("COMMIT");
      return result;
    } catch (e) {
      await client.query("ROLLBACK"); // トランザクションをロールバックする
      console.error(e);
      throw e;
    } finally {
      client.release();
    }
  }

  replaceNull(value: any): any {
    return value ? `'${value}'` : null;
  }
}