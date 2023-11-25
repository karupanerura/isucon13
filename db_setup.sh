 cat webapp/sql/initdb.d/01_reset_database.sql | sudo mysql isupipe
 cat webapp/sql/initdb.d/10_schema.sql | sudo mysql isupipe
 sh webapp/sql/init.sh
