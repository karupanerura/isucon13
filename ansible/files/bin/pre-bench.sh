#!/bin/sh
set -uex

sudo systemctl restart isuports.service
sudo logrotate.pl nginx /var/log/nginx/access.log
sudo logrotate.pl mysql /tmp/mysql-slow.log

# notify
echo "[$(hostname)] restarted!" | notify_slack