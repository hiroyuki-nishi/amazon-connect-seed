import aws from "aws-sdk";

import {Postgresql} from "@infrastructure/implements/rds/postgresql";
import {CallUsersUsecase} from "@usecase/callUsersUsecase";
import {
  OperatorRepositoryOnAmazonConnect
} from "@infrastructure/implements/amazon-connect/operatorRepositoryOnAmazonConnect";

const host = process.env.host;

export const handler = async (event: any, context: any): Promise<any> => {
  const pg = await Postgresql.applyBySecret(
    process.env.region,
    process.env.secretId,
    host,
    process.env.databaseName
  );
  const operatorRepository = new OperatorRepositoryOnAmazonConnect(
    new aws.Connect({ region: process.env.region }),
    process.env.instanceId,
  );
  return new CallUsersUsecase(operatorRepository).run(event).then((v) => {
      pg.end();
      return v;
    }
  ).catch((e) => {
    pg.end();
    console.error(e);
  })
};
