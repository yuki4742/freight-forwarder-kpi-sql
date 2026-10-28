-- Allow LOAD DATA LOCAL INFILE on the server side.
-- Run once; SET PERSIST keeps the setting after a server restart.
-- The client side must also allow it: start the client with  mysql --local-infile=1
SET PERSIST local_infile = 1;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
