CREATE TABLE IF NOT EXISTS example(
    id                                           SERIAL,
    call_flow                                    VARCHAR,
    queue_arn                                    VARCHAR,
    maximum_call_concurrency                     INTEGER      NOT NULL     DEFAULT 10,
    minimum_service_available_concurrency        INTEGER      NOT NULL     DEFAULT 2,
    time_from                                    TIME         NOT NULL     DEFAULT '09:00:00',
    time_to                                      TIME         NOT NULL     DEFAULT '18:00:00',
    created_at                                   TIMESTAMP                 DEFAULT CURRENT_TIMESTAMP,
    updated_at                                   TIMESTAMP                 DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE INDEX example__created_at_idx ON call_cases (created_at);