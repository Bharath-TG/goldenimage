eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_github_tpap
ssh-add ~/.ssh/id_github
exec {LOCK}> /tmp/tpapdeploymentlock
flock -x ${LOCK}

rm -fR /twid/deploy/tpap

git clone -b beta git@github.com:twidpay-global/twid_tpap.git /twid/deploy/tpap

cp -Rv /twid/deploy/tpap/* /twid/tpap


cp /twid/config/tpap_config_twid.php /twid/tpap/config/twid.php
cp /twid/config/tpap_config_queue.php /twid/tpap/config/queue.php
cp /twid/config/tpap_config_database.php /twid/tpap/config/database.php
chown -R apache:apache /twid/tpap
chmod -R 775 /twid/tpap
chmod -R 777 /twid/tpap/storage/logs
su kushal -c "cd /twid/tpap && composer install && composer dump-autoload && php artisan clear-compiled && php artisan optimize"
#echo "running migration"
#su kushal -c /twid/tpap/scripts/update_db
echo "---------------- ";
echo "Date - $(date)"
