import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";
import {OperatorRepository} from "@infrastructure/operatorRepository";

export class CallUsersUsecase {
  constructor(
    private operatorRepository: OperatorRepository,
  ) {
    dayjs.extend(utc);
    dayjs.extend(timezone);
    dayjs.tz.setDefault('Asia/Tokyo');
  }

  async run(_event: any): Promise<string> {
    // const currentTime = dayjs().tz().format('HH:mm:ss');
    await this.operatorRepository.calls([""])
    return Promise.name;
  }
}
