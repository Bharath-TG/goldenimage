#!/bin/bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_github_api
rm -fR /twid/deploy/api

git clone -b beta git@github.com:twidpay-global/twid_api.git /twid/deploy/api
kill $SSH_AGENT_PID
cp -Rv /twid/deploy/api/* /twid/api_unittest


# cp /twid/config/env.api.beta /twid/api_unittest/.env
cp /twid/config/env.api.beta.tmp-2 /twid/api_unittest/.env
chown -R kushal:kushal /twid/api_unittest
su kushal -c "cd /twid/api_unittest && composer install && composer dump-autoload"
chmod -R 775 /twid/api_unittest
chmod -R 777 /twid/api_unittest/storage/logs
su kushal -c /twid/api_unittest/scripts/refresh_cache
su kushal -c /twid/api_unittest/scripts/update_db
chown -R apache:apache /twid/api_unittest
echo "---------------- ";
echo "Date - $(date)"

cd /twid/api_unittest

sudo ./vendor/bin/phpunit 2>&1 | tee /root/scripts/api_unit_test_results
if [[ ${PIPESTATUS[0]} -ne 0 ]]
then
        echo "Unit Tests Failed"
                       curl -X POST -H 'Content-type: application/json' --data '{"text":"Unit Tests Failed For Api Service"}' https://hooks.slack.com/services/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
           curl -F file=@/root/scripts/api_unit_test_results -F "initial_comment=Unit Tests Failed For Api Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload


#        exit 1
else
        echo "Unit Test Succeeded"
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Unit Tests Succeeded For Api Service"}' https://hooks.slack.com/services/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
           curl -F file=@/root/scripts/api_unit_test_results -F "initial_comment=Unit Tests Succeeded For Api Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload

fi