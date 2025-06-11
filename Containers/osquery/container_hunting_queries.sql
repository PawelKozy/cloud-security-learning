-- Container Security Hunting Queries for osquery
--
-- This file consolidates common checks for discovering risky container activity.

-- 1. Detect containers running with the --privileged flag
SELECT * FROM processes WHERE name='docker' AND cmdline LIKE '%--privileged%';

-- 2. List containers that have host paths mounted
SELECT * FROM mounts WHERE path LIKE '/host%';

-- 3. Identify environment variables that might contain secrets
SELECT name, value FROM environment WHERE name LIKE '%KEY%' OR name LIKE '%TOKEN%';
