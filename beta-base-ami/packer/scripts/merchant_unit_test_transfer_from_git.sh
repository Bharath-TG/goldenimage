eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_github_merchant
rm -fR /twid/deploy/merchant_unit_test || true

git clone -b beta git@github.com:twidpay-global/twid_merchant.git /twid/deploy/merchant_unit_test

cp -Rv /twid/deploy/merchant/* /twid/merchant_unit_test


# cp /twid/merchant_unit_test/.env_bkup /twid/merchant_unit_test/.env
cp /twid/config/env.merchant.beta.tmp-2 /twid/merchant_unit_test/.env
chown -R kushal:kushal /twid/merchant_unit_test
su kushal -c "cd /twid/merchant_unit_test && composer install && composer dump-autoload"
chmod -R 777 /twid/merchant_unit_test
chmod -R 777 /twid/merchant_unit_test/storage/logs
#su kushal -c /twid/merchant_unit_test/scripts/refresh_cache
chown -R apache:apache /twid/merchant_unit_test
echo "---------------- ";
echo "Date - $(date)"

cd /twid/merchant_unit_test
sudo ./vendor/bin/phpunit 2>&1 | tee /root/scripts/merchant_unit_test_results
if [[ ${PIPESTATUS[0]} -ne 0 ]]
then
        echo "Unit Tests Failed"
                       curl -X POST -H 'Content-type: application/json' --data '{"text":"Unit Tests Failed For Merchant Service"}' https://hooks.slack.com/services/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
           curl -F file=@/root/scripts/merchant_unit_test_results -F "initial_comment=Unit Tests Failed For Merchant Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload


#        exit 1
fi