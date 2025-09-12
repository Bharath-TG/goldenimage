echo "Running linter"
export service=api
/root/scripts/linter_test_common.sh
if [[ $? -ne 0 ]]
then
	echo "Linter failed"
#	exit 1
fi

eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_github_api
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/api

git clone -b beta git@github.com:twidpay-global/twid_api.git /twid/deploy/api
kill $SSH_AGENT_PID

sudo rm -f /twid/deploy/api/.env.local
cp -Rv /twid/deploy/api/* /twid/api
# cp /twid/config/env.api.beta /twid/api/.env
mv /twid/config/env.api.beta.tmp-2 /twid/api/.env
chown -R kushal:kushal /twid/api
su kushal -c "cd /twid/api && composer install --no-dev && composer dump-autoload && php artisan clear-compiled && php artisan optimize"
chmod -R 775 /twid/api
chmod -R 777 /twid/api/storage/logs
su kushal -c /twid/api/scripts/refresh_cache
su kushal -c /twid/api/scripts/update_db
chown -R apache:apache /twid/api
echo "Successfully deployed beta-api";
echo "Date - $(date)"
