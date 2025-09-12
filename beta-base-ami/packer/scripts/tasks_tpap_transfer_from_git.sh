eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_github_tpap_tasks
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/tasks_tpap

git clone -b beta git@github.com:twidpay-global/twid_tasks_tpap.git /twid/deploy/tasks_tpap

cp -Rv /twid/deploy/tasks_tpap/* /twid/tasks_tpap

echo "Killing Ssh agent"
kill $SSH_AGENT_PID

cp /twid/config/tasks_tpap_config_twid.php /twid/tasks_tpap/config/twid.php
cp /twid/config/tasks_tpap_config_database.php /twid/tasks_tpap/config/database.php
cp /twid/config/tasks_tpap_config_queue.php /twid/tasks_tpap/config/queue.php
chown -R kushal:kushal /twid/tasks_tpap
su kushal -c "cd /twid/tasks_tpap && composer install && composer dump-autoload"

chmod -R 777 /twid/tasks_tpap
chmod -R 777 /twid/tasks_tpap/storage/logs
#su kushal -c /twid/tasks_tpap/scripts/refresh_cache

chown -R apache:apache /twid/tasks_tpap

service supervisord restart
echo "---------------- ";
echo "Date - $(date)"
