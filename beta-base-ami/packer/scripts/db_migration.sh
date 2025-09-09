#!/bin/bash

# Usage: ./db_migration.sh <source_db> <target_db> <username>

SRC_DB_NAME=$1
DST_DB_NAME=$2
DB_USER=$3

if [ -z "$SRC_DB_NAME" ] || [ -z "$DST_DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo "Usage: $0 <source_db> <target_db> <username>"
    exit 1
fi
read -s -p "Enter DB password for user '$DB_USER': " DB_PASS
echo
read -p "Do you want to take a fresh dump of '$SRC_DB_NAME'? (y/n): " TAKE_DUMP

DUMP_FILE="${SRC_DB_NAME}.sql"
cd /twid/tmp || exit 1

if [[ "$TAKE_DUMP" == [Yy]* ]]; then
    echo "Taking MySQLdump from source DB..."
    mysqldump -h beta.c1wsqg4mqid6.ap-south-2.rds.amazonaws.com -u "$DB_USER" -p"$DB_PASS" --skip-lock-tables "$SRC_DB_NAME" > "$DUMP_FILE"

    if [ $? -eq 0 ]; then
        echo "MySQLdump successful: $DUMP_FILE"
    else
        echo "MySQLdump failed."
        exit 1
    fi
else
    echo "Skipping dump step. Using existing file: $DUMP_FILE"
    if [ ! -f "$DUMP_FILE" ]; then
        echo "Error: Dump file '$DUMP_FILE' does not exist!"
        exit 1
    fi
fi

echo "Migrating dump to target DB..."
mysql -h beta.c1wsqg4mqid6.ap-south-2.rds.amazonaws.com -u "$DB_USER" -p"$DB_PASS" "$DST_DB_NAME" < "$DUMP_FILE"

if [ $? -eq 0 ]; then
    echo "Migration successful: $DST_DB_NAME"
else
    echo "Migration failed."
    exit 1
fi
