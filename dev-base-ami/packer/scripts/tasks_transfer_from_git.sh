echo "Running linter"
export service=tasks
/root/scripts/linter_test_common.sh
if [[ $? -ne 0 ]]
then
        echo "Linter failed"
     #   exit 1
fi

eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_github_tasks
ssh-add ~/.ssh/id_github
rm -fR /twid/deploy/tasks

git clone -b development git@github.com:twidpay-global/twid_tasks.git /twid/deploy/tasks

sudo rm -f /twid/deploy/tasks/.env.local
cp -Rv /twid/deploy/tasks/* /twid/tasks

echo "Killing Ssh agent"
kill $SSH_AGENT_PID

#cp /twid/config/env.tasks.dev /twid/tasks/.env

mv /twid/config/env.tasks.dev.tmp-2 /twid/tasks/.env
chown -R kushal:kushal /twid/tasks
su kushal -c "cd /twid/tasks && composer install --no-dev && composer dump-autoload"

chmod -R 777 /twid/tasks
chmod -R 777 /twid/tasks/storage/logs
#su kushal -c /twid/tasks/scripts/refresh_cache
chown -R apache:apache /twid/tasks
service supervisord restart
echo "successfully deployed dev-tasks";
echo "Date - $(date)"
