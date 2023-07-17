import aws from "aws-sdk";
export const getSecretValue = async (region: string, secretId: string): Promise<any> => {
  const client = new aws.SecretsManager({
    region: region,
  });
  const getSecretValueCommandResponse = await client.getSecretValue(
    {
      SecretId: secretId,
    }).promise();
  return JSON.parse(getSecretValueCommandResponse.SecretString ?? "");
};
