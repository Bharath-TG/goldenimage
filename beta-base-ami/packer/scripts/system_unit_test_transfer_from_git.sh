#!/bin/bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/system_unit_test

git clone -b beta git@github.com:twidpay-global/twid_system.git /twid/deploy/system_unit_test

cp -Rv /twid/deploy/system_unit_test/* /twid/system_unit_test

#cp /twid/config/env.system.beta /twid/system_unit_test/.env

cp /twid/config/env.system.beta.tmp-2 /twid/system_unit_test/.env

chown -R kushal:kushal /twid/system_unit_test
su kushal -c "cd /twid/system_unit_test && composer install && composer dump-autoload"

chmod -R 777 /twid/system_unit_test
chmod -R 777 /twid/system_unit_test/storage/logs
#su kushal -c /twid/system/scripts/refresh_cache
chown -R apache:apache /twid/system_unit_test

#su john.zacharia -c /home/john.zacharia/laravel/make_deploy.sh
#sudo docker system prune -a -f
echo "---------------- ";
echo "Date - $(date)"

cd /twid/system_unit_test
sudo ./vendor/bin/phpunit 2>&1 | tee /root/scripts/system_unit_test_results
if [[ ${PIPESTATUS[0]} -ne 0 ]]
then
        echo "Unit Tests Failed"
                       curl -X POST -H 'Content-type: application/json' --data '{"text":"Unit Tests Failed For System Service"}' https://hooks.slack.com/services/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
	   curl -F file=@/root/scripts/system_unit_test_results -F "initial_comment=Unit Tests Failed For System Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload


#        exit 1
else
        echo "Unit Test Succeeded"
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Unit Tests Succeeded For System Service"}' https://hooks.slack.com/services/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
           curl -F file=@/root/scripts/system_unit_test_results -F "initial_comment=Unit Tests Succeeded For System Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload

fi