CREATE DATABASE IF NOT EXISTS gazprombank_test_task;
USE gazprombank_test_task;


CREATE TABLE message (
--	created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
	created TIMESTAMP(0) NOT NULL,
	id VARCHAR(256) NOT NULL,
	int_id CHAR(16) NOT NULL,
	str VARCHAR(1024) NOT NULL,
	status BOOL,
	CONSTRAINT message_id_pk PRIMARY KEY(id)
);

CREATE INDEX message_created_idx ON message (created);
CREATE INDEX message_int_id_idx ON message (int_id);


CREATE TABLE log (
--	created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
	created TIMESTAMP(0) NOT NULL,
	int_id CHAR(16) NOT NULL,
--	str VARCHAR,
	str VARCHAR(1024),
--	address VARCHAR
	address VARCHAR(256)
);

CREATE INDEX log_address_idx ON log (address) USING hash;
