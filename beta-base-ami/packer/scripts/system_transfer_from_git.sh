echo "Running linter"
export service=system
/root/scripts/linter_test_common.sh

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/system

git clone -b beta git@github.com:twidpay-global/twid_system.git /twid/deploy/system
kill $SSH_AGENT_PID
sudo rm -f /twid/deploy/system/.env.local

cp -Rv /twid/deploy/system/* /twid/system
#cp /twid/config/env.system.beta /twid/system/.env
mv /twid/config/env.system.beta.tmp-2 /twid/system/.env
chown -R kushal:kushal /twid/system
su kushal -c "cd /twid/system && composer install --no-dev && composer dump-autoload && php artisan clear-compiled && php artisan optimize"

chmod -R 777 /twid/system
chmod -R 777 /twid/system/storage/logs
su kushal -c /twid/system/scripts/refresh_cache
chown -R apache:apache /twid/system
echo "successfully deployed beta-system";
echo "Date - $(date)"