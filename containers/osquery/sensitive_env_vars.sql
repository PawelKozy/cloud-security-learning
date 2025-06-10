-- Identify environment variables that might contain secrets
SELECT name, value FROM environment WHERE name LIKE '%KEY%' OR name LIKE '%TOKEN%';
