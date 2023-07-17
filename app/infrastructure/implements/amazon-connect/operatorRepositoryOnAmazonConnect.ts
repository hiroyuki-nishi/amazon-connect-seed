import {OperatorRepository} from "@infrastructure/operatorRepository";
import aws from "aws-sdk";
import {CallOperatorMetrics} from "@domain/callOperator";
import {ContactFlowId, InstanceId} from "aws-sdk/clients/connect";
import {CallUser} from "@domain/callUser";
import {SourcePhoneNumber} from "aws-sdk/clients/connectcampaigns";

export class OperatorRepositoryOnAmazonConnect implements OperatorRepository {
  constructor(
    private connect: aws.Connect,
    private instanceId: InstanceId,
  ) {
  }

  async findAvailableOperatorMetrics(queues: string): Promise<CallOperatorMetrics> {
    try {
      const getCurrentMetricDataParams = {
        InstanceId: this.instanceId,
        Filters: {
          Queues: [queues]
        },
        CurrentMetrics: [
          {
            Name: 'AGENTS_AVAILABLE',
            Unit: 'COUNT'
          },
          {
            Name: 'AGENTS_ONLINE',
            Unit: 'COUNT'
          }
        ]
      };

      const getCurrentMetricDataResponse = await this.connect.getCurrentMetricData(getCurrentMetricDataParams).promise();
      const callOperatorMetrics = new CallOperatorMetrics(
        getCurrentMetricDataResponse?.MetricResults?.[0]?.Collections?.[1]?.Value ?? 0,
        getCurrentMetricDataResponse?.MetricResults?.[0]?.Collections?.[0]?.Value ?? 0
      )
      return callOperatorMetrics;
    } catch (e) {
      throw e;
    } finally {
    }
  }

  async calls(
    callUsers: CallUser[],
    sourcePhoneNumber: SourcePhoneNumber,
    contactFlowId: ContactFlowId,
    queues: string
  ): Promise<CallUser[]> {
    let errorUsers: CallUser[] = [];
    for await (const callUser of callUsers) {
      try {
        // NOTE: attributesのキーには英数字と一部記号しか含められないためエラーになる可能性がある
        await this.connect.startOutboundVoiceContact({
            DestinationPhoneNumber: callUser.destinationPhoneNumberE164.value,
            ContactFlowId: contactFlowId,
            InstanceId: this.instanceId,
            QueueId: queues,
            SourcePhoneNumber: sourcePhoneNumber,
            Attributes: callUser.attributes
          }, (err, data) => {
            if (err) {
              console.log("calls Failed." + JSON.stringify(err))
            } else {
              console.info("calls Success." + JSON.stringify(data))
            }
          }
        ).promise();
      } catch (e) {
        console.error(`call Failed. userId = ${callUser.id}`)
        errorUsers = errorUsers.concat(callUser);
      }
    }
    return errorUsers;
  }
}
