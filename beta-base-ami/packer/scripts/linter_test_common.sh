eval "$(ssh-agent -s)"
export linterStatus=0
ssh-add ~/.ssh/id_github_${service}
rm -fR /twid/deploy/${service}
export previousCommitHash=`cat /root/scripts/${service}_commit_log_prev`
git clone -b beta git@github.com:twidpay-global/twid_${service}.git /twid/deploy/${service}
git config --global --add safe.directory '*'
cd /twid/deploy/${service}
git show | grep ^commit | awk '{print $2}' > /root/scripts/${service}_commit_log_prev
export currentCommitHash=`cat /root/scripts/${service}_commit_log_prev`
echo "git diff $previousCommitHash $currentCommitHash --name-only"
export changedFiles=`git diff $previousCommitHash $currentCommitHash --name-only | grep php`
rm /root/scripts/linter_output_${service} || true
for file in $changedFiles
do
        echo "Runnning linter for $file"
        php -l -d display_errors=0 $file 2>&1 >> /root/scripts/linter_output_${service}
	echo "git diff $previousCommitHash $currentCommitHash" >> /root/scripts/linter_output_${service}
        if [[ $? -ne 0 ]]
        then
                echo "Error in $file. Exiting."
		linterStatus=1
        fi
done

cd /root/scripts
if [[ $linterStatus -eq 1 ]]
then
	                       curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Linter Tests Failed For $service Service\"}" https://hooks.slack.com/services/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
           curl -F file=@/root/scripts/linter_output_${service} -F "initial_comment=Linter Tests Failed For $service Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload
exit 1
           curl -F file=@/root/scripts/linter_output_${service} -F "initial_comment=Linter Tests Succeded For $service Service"   -F channels=C06D0JJAEP7 -H "Authorization: Bearer xoxb-2268088717650-6448017953892-W0SHxuFrNCycFodtxHTPkCPr" https://slack.com/api/files.upload

fi
kill $SSH_AGENT_PID