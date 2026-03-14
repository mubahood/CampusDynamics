-- Rollback: create_api_tokens_table
-- Logical database: main
-- Warning: This removes all API session tokens.

DROP TABLE IF EXISTS api_tokens;
