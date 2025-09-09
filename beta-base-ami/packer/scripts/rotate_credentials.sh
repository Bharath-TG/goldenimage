#!/bin/bash

export AWS_SHARED_CREDENTIALS_FILE=/dev/null
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE

# Set AWS region
AWS_REGION="ap-south-2"

# Secret names
SECRET_BETA="twid_beta/beta"
SECRET_TMP="twid_beta/tmp"

# Function to generate a random password
generate_password() {
    length=16
    chars='A-Za-z0-9!@#$%^&*()'
    tr -dc "$chars" < /dev/urandom | fold -w $length | head -n 1
}

# Function to fetch a secret from AWS Secrets Manager
get_secret() {
    secret_name=$1
    aws secretsmanager get-secret-value \
        --region "$AWS_REGION" \
        --secret-id "$secret_name" \
        --query SecretString \
        --output text
}

# Function to update a secret in AWS Secrets Manager
update_secret() {
    secret_name=$1
    secret_value=$2
    aws secretsmanager put-secret-value \
        --region "$AWS_REGION" \
        --secret-id "$secret_name" \
        --secret-string "$secret_value"
}

# Function to create and verify a new MySQL user
create_and_verify_user() {
    host=$1
    db=$2
    admin_user=$3
    admin_pass=$4
    new_user=$5
    new_pass=$6
    privileges=$7

    mysql -h "$host" -u "$admin_user" -p"$admin_pass" -e "CREATE USER IF NOT EXISTS '$new_user'@'%' IDENTIFIED BY '$new_pass';"
    mysql -h "$host" -u "$admin_user" -p"$admin_pass" -e "GRANT $privileges ON \`$db\`.* TO '$new_user'@'%';"
    mysql -h "$host" -u "$admin_user" -p"$admin_pass" -e "FLUSH PRIVILEGES;"

    # Try logging in with new user
    mysql -h "$host" -u "$new_user" -p"$new_pass" "$db" -e "SELECT 1;" > /dev/null 2>&1
    return $?
}

# Start of main script
rotate_credentials() {
    echo "Fetching current secrets..."

    beta_secret_json=$(get_secret "$SECRET_BETA")
    tmp_secret_json=$(get_secret "$SECRET_TMP")

    timestamp=$(date +%y%m%d%H%M%S)
    new_pass=$(generate_password)

    declare -A ROLES=(
        ["SYSTEM"]="SYSTEM_DB_HOST SYSTEM_DB_USERNAME SYSTEM_DB_PASSWORD SYSTEM_DB_DATABASE twid_system SELECT,INSERT,UPDATE"
        ["API"]="API_DB_HOST API_DB_USERNAME API_DB_PASSWORD API_DB_DATABASE twid_api SELECT,INSERT,UPDATE"
        ["TASKS"]="TASKS_DB_HOST TASKS_DB_USERNAME TASKS_DB_PASSWORD TASKS_DB_DATABASE twid_tasks SELECT,INSERT,UPDATE"
        ["MERCHANT"]="MERCHANT_DB_HOST MERCHANT_DB_USERNAME MERCHANT_DB_PASSWORD MERCHANT_DB_DATABASE twid_merchant SELECT,INSERT,UPDATE"
        #["READ"]="DB_HOST_READ DB_USERNAME_READ DB_PASSWORD_READ DB_DATABASE_READ twid_read_system SELECT"
        #["LOG"]="DB_HOST_LOG DB_USERNAME_LOG DB_PASSWORD_LOG DB_DATABASE_LOG twid_log_system SELECT,INSERT"
    )

    for role in "${!ROLES[@]}"; do
        echo "Rotating credentials for role: $role"

        # Fetch admin user/pass for this role from tmp secret
        admin_user_key="BETA_ADMIN_USERNAME"
        admin_pass_key="BETA_ADMIN_PASSWORD"
        #admin_user_key="${role}_BETA_ADMIN_USERNAME"
        #admin_pass_key="${role}_BETA_ADMIN_PASSWORD"
        admin_user=$(echo "$tmp_secret_json" | jq -r ".${admin_user_key}")
        admin_pass=$(echo "$tmp_secret_json" | jq -r ".${admin_pass_key}")

        IFS=' ' read -r host_key user_key pass_key db_key prefix privileges <<< "${ROLES[$role]}"

        host=$(echo "$beta_secret_json" | jq -r ".${host_key}")
        db=$(echo "$beta_secret_json" | jq -r ".${db_key}")
        old_user=$(echo "$beta_secret_json" | jq -r ".${user_key}")
        old_pass=$(echo "$beta_secret_json" | jq -r ".${pass_key}")
        new_user="${prefix}_${timestamp}"

        if create_and_verify_user "$host" "$db" "$admin_user" "$admin_pass" "$new_user" "$new_pass" "$privileges"; then
            echo "User $new_user created and verified successfully."

            # Update tmp secret with old credentials
            tmp_secret_json=$(echo "$tmp_secret_json" | jq --arg k1 "BETA_${user_key}" --arg v1 "$old_user" \
                                                            --arg k2 "BETA_${pass_key}" --arg v2 "$old_pass" \
                                                            '. + {($k1): $v1, ($k2): $v2}')

            # Update beta secret with new credentials
            beta_secret_json=$(echo "$beta_secret_json" | jq --arg uk "$user_key" --arg uv "$new_user" \
                                                                  --arg pk "$pass_key" --arg pv "$new_pass" \
                                                                  '. + {($uk): $uv, ($pk): $pv}')
        else
            echo "Failed to create or verify user $new_user, skipping update for role $role."
        fi

        sleep 2
    done

    echo "Updating AWS Secrets..."
    update_secret "$SECRET_BETA" "$beta_secret_json"
    update_secret "$SECRET_TMP" "$tmp_secret_json"
    echo "Rotation complete."
}

rotate_credentials