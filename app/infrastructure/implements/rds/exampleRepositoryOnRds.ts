import {Postgresql} from "./postgresql";

export class XXXRepositoryOnRds implements XXXRepository {
  constructor(
    private readonly pg: Postgresql
  ) {
  }

  async findByNames(xxx: string[]): Promise<any[]> {
    try {
      const result = await this.pg.withTx(async (client) => {
          const r = await client.query(`
                      SELECT 
                          id,
                      FROM call_cases WHERE case_name = ANY($1)
            `, [xxx]
          );
        return r.rows.map(x =>
          new XXX(x?.id));
      });
      return result;
    } catch (e) {
      throw e;
    } finally {
    }
  }

  async save(xxx: any[]): Promise<void> {
    try {
      await this.pg.withTx(async (client) => {
        for await (const c of xxx) {
          await client.query(`
            INSERT INTO xxx(case_name) VALUES('${c.name}')
         `);
        }
      });
    } catch (e) {
      throw e;
    } finally {
    }
    return;
  }
}
