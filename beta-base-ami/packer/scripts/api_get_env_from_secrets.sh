#!/bin/bash

set -e

TEMPLATE_FILE="/twid/config/env.api.beta.tmp-1"
OUTPUT_FILE="/twid/config/env.api.beta.tmp-2"
SECRET_NAME="twid_beta/beta"
REGION="ap-south-2"

MODE=$1
STAGE_LABEL=$2
VERSION_ID=$3

if [ -z "$MODE" ] || [ -z "$STAGE_LABEL" ] || [ -z "$VERSION_ID" ]; then
  echo "Usage: $0 <regular|rollback> <AWSPREVIOUS|NA> <version-id|NA>"
  exit 1
fi

echo "Fetching secrets from AWS Secrets Manager..."

if [ "$MODE" == "regular" ]; then
  # Regular fetch using current version
  SECRET_JSON=$(aws secretsmanager get-secret-value \
    --region "$REGION" \
    --secret-id "$SECRET_NAME" \
    --query SecretString \
    --output text)
  echo "Fetched current version (AWSCURRENT)."

elif [ "$MODE" == "rollback" ]; then
  # Rollback mode
  if [ "$STAGE_LABEL" != "NA" ]; then
    echo "Rolling back using version stage: $STAGE_LABEL"
    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --region "$REGION" \
      --secret-id "$SECRET_NAME" \
      --version-stage "$STAGE_LABEL" \
      --query SecretString \
      --output text)

  elif [ "$VERSION_ID" != "NA" ]; then
    echo "Rolling back using version ID: $VERSION_ID"
    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --region "$REGION" \
      --secret-id "$SECRET_NAME" \
      --version-id "$VERSION_ID" \
      --query SecretString \
      --output text)
  else
    echo "Invalid rollback parameters: either STAGE_LABEL or VERSION_ID must be set."
    exit 1
  fi

else
  echo "Invalid mode. Use 'regular' or 'rollback'."
  exit 1
fi

echo "Exporting secrets as environment variables..."
while IFS="=" read -r key value; do
  export "$key=$value"
done < <(echo "$SECRET_JSON" | jq -r 'to_entries[] | "\(.key)=\(.value)"')

# Build the list of variables to substitute in the template
VAR_LIST=$(echo "$SECRET_JSON" | jq -r 'keys_unsorted[]' | sed 's/^/\$/g' | tr '\n' ' ')

# Substitute variables in the template using envsubst
echo "Substituting variables into $OUTPUT_FILE..."
envsubst "$VAR_LIST" < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Done. Created: $OUTPUT_FILE"