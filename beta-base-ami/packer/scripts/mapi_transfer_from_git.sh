eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_github_mapi
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/mapi

git clone -b beta git@github.com:twidpay-global/twid_mapi.git /twid/deploy/mapi

cp -Rv /twid/deploy/mapi/* /twid/mapi


cp /twid/config/mapi_config_twid.php /twid/mapi/config/twid.php
cp /twid/config/mapi_config_queue.php /twid/mapi/config/queue.php
cp /twid/config/mapi_config_database.php /twid/mapi/config/database.php
cp /twid/config/firebase-service-account.json /twid/mapi/config/firebase-service-account.json

chown -R kushal:kushal /twid/mapi
su kushal -c "cd /twid/mapi && composer install && composer dump-autoload && php artisan clear-compiled && php artisan optimize"
chmod -R 775 /twid/mapi
chmod -R 777 /twid/mapi/storage/logs
# su kushal -c "cd /twid/mapi/go && /usr/local/go/bin/go mod init firebase-app-check && /usr/local/go/bin/go mod tidy && /usr/local/go/bin/go build -o firebase_app_check_validator firebase_app_check_validator.go"
# su kushal -c "export PATH=\$PATH:/usr/local/go/bin && cd /twid/mapi/go && [ ! -f go.mod ] && go mod init firebase-app-check; go mod tidy && go build -o firebase_app_check_validator firebase_app_check_validator.go"
su kushal -c "cd /twid/mapi/go \
  [ ! -f go.mod ] && echo 'go.mod not found, initializing' && go mod init firebase-app-check || echo 'go.mod already exists'; \
  go mod tidy && echo 'go mod tidy done'; \
  go build -o firebase_app_check_validator firebase_app_check_validator.go && echo 'go build done'"
su kushal -c /twid/mapi/scripts/refresh_cache

chown -R apache:apache /twid/mapi
echo "---------------- ";
echo "Date - $(date)"
