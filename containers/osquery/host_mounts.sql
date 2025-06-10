-- List containers that have host paths mounted
SELECT * FROM mounts WHERE path LIKE '/host%';
