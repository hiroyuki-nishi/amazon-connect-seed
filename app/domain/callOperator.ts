export class CallOperator {
  constructor(public readonly queue: string, public readonly metrics: CallOperatorMetrics) {
  }
}

export class CallOperatorMetrics {
  static empty(): CallOperatorMetrics {
    return new CallOperatorMetrics(0.0, 0.0);
  }

  constructor(public readonly online: number, public readonly available: number) {
  }

  isCallAvailable(minimumServiceAvailableConcurrency?: number): boolean {
    return minimumServiceAvailableConcurrency != undefined ? this.online >= minimumServiceAvailableConcurrency && this.available >= minimumServiceAvailableConcurrency : false;
  }
}
