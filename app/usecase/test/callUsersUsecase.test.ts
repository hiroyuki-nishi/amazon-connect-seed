import {ContactFlowId} from "aws-sdk/clients/connect";
import {CallUsersUsecase} from "../callUsersUsecase";
import {
  OperatorRepositoryOnAmazonConnect
} from "../../infrastructure/implements/amazon-connect/operatorRepositoryOnAmazonConnect";

jest.setTimeout(10000);

jest.mock("../../infrastructure/implements/amazon-connect/operatorRepositoryOnAmazonConnect");
const MockOperatorRepository = OperatorRepositoryOnAmazonConnect as jest.Mock;

describe("CallUsersUsecaseTest", () => {
  test("テスト名:xxx", async () => {
    MockOperatorRepository.mockImplementationOnce(() => {
      return {
        calls: (callUsers: any[], contactFlowId?: ContactFlowId, queues?: string): Promise<any[]> => {
          return Promise.resolve([]);
        }
      }
    })
    const callUsersUsecase = new CallUsersUsecase(
      new MockOperatorRepository(),
    );
    const result = await callUsersUsecase.run(undefined)
    expect(result).toBe("SUCCESS");
  });
});
