set -uex
cat webapp/sql/initdb.d/00_create_database.sql | sudo mysql -uroot isupipe
cat webapp/sql/initdb.d/01_reset_database.sql | sudo mysql -uroot isupipe
cat webapp/sql/initdb.d/10_schema.sql | sudo mysql -uroot isupipe
sh webapp/sql/init.sh
