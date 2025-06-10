-- Detect containers running with the --privileged flag
SELECT * FROM processes WHERE name='docker' AND cmdline LIKE '%--privileged%';
