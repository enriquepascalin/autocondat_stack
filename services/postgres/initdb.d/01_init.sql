-- Runs only when the data dir is empty. :contentReference[oaicite:3]{index=3}
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Optional seed user/role examples
-- CREATE ROLE readonly NOINHERIT;
-- GRANT CONNECT ON DATABASE ${DB_NAME} TO readonly;