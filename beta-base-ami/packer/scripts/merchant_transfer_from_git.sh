echo "Running linter"
export service=merchant
/root/scripts/linter_test_common.sh
if [[ $? -ne 0 ]]
then
        echo "Linter failed"
        #exit 1
fi

eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_github_merchant
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/merchant
git clone -b beta git@github.com:twidpay-global/twid_merchant.git /twid/deploy/merchant
kill $SSH_AGENT_PID

sudo rm -f /twid/deploy/merchant/.env.local
cp -Rv /twid/deploy/merchant/* /twid/merchant
# cp /twid/config/env.merchant.beta /twid/merchant/.env
mv /twid/config/env.merchant.beta.tmp-2 /twid/merchant/.env
chown -R kushal:kushal /twid/merchant

su kushal -c "cd /twid/merchant && composer install --no-dev && composer dump-autoload && php artisan clear-compiled && php artisan optimize"

chmod -R 777 /twid/merchant
chmod -R 777 /twid/merchant/storage/logs
su kushal -c /twid/merchant/scripts/refresh_cache
chown -R apache:apache /twid/merchant
echo "successfully deployed beta-merchant ";
echo "Date - $(date)"
