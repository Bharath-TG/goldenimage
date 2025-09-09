#!/bin/bash

export AWS_SHARED_CREDENTIALS_FILE=/dev/null
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE

AWS_REGION="ap-south-2"
SECRET_NAME="twid_beta/beta"

aws secretsmanager list-secret-version-ids  --secret-id "$SECRET_NAME"  --include-deprecated  --output json  --region "$AWS_REGION" | jq -r '
 .Versions | sort_by(.CreatedDate) | reverse |
 to_entries |
 map({
  Serial: (.key + 1),
  CreatedDate: (.value.CreatedDate | strflocaltime("%Y-%m-%d %H:%M:%S %Z")),
  VersionId: .value.VersionId
 }) |
 (["Version", "CreatedDate     ", "VersionId"], (.[] | [.Serial, .CreatedDate, .VersionId])) |
 @tsv
'