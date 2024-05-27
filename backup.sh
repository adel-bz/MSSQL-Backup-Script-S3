#!/bin/bash

### Reading ENV ###
source $(dirname $BASH_SOURCE)/.env

### To Find the AWS Command ###
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

### Database Backup ###
printf ""$GREEN"......... BACKUP HAS BEEN STARTED ......... "$NC" \t "$date" \t Done\n"
printf ""$GREEN"......... DATABASE BACKUP ......... "$NC" \t \t Done\n"

for DB_NAME in "${DB_NAMES[@]}"; do
    EXPORT_NAME_FINAL="${DB_NAME}_full_${DATE}"
    CONTAINER_PATH="/var/opt/mssql/backup/${DB_NAME}.bak"

    echo "Perform backup of $DB_NAME in docker container $CONTAINER_NAME ..."
    sudo docker exec -i $CONTAINER_NAME /opt/mssql-tools/bin/sqlcmd \
         -S localhost -U SA -P $SA_PASSWORD \
         -Q "BACKUP DATABASE [$DB_NAME] TO DISK = N'$CONTAINER_PATH' WITH NOFORMAT, NOINIT, NAME = '$EXPORT_NAME_FINAL', SKIP, NOREWIND, NOUNLOAD, STATS = 10" &
         sleep 2

    if [ $? -eq 0 ]; then
         echo "✅ Extracts backup for $DB_NAME from container to host..."
         sudo docker cp $CONTAINER_NAME:$CONTAINER_PATH $DB_BAK_HOST_DIR &
         sleep 2
         docker exec -i $CONTAINER_NAME rm $CONTAINER_PATH

    else
         echo "❌ Failed to create backup for $DB_NAME"
    fi
    done
    wait

tar -czvf "$DB_BAK_HOST_DIR""$DB_PREFIXNAME"_"$date".tar.gz --absolute-names "$DB_BAK_HOST_DIR"

### Uploading Backup to S3 && Sending Alert to Discord ###
printf ""$GREEN"......... UPLOADING ......... "$NC" \t "$date" \t Done\n"
aws s3 cp "$DB_BAK_HOST_DIR""$DB_PREFIXNAME"_"$date".tar.gz s3://$BUCKET_NAME/
if [ $? == 0 ]
then
  printf ""$GREEN"####### DATABASE UPLOADING HAS BEEN SUCSSESFUL "$NC""
  echo ".........."
  curl -X POST -H 'Content-type: application/json' -d '{"content":"**\n-----\nDanaa Database Backup Has Been Sucssesful \nTime: '"${date}"'\n----- **"}' "$discord_url"

else
  curl -X POST -H 'Content-type: application/json' -d '{"content":"*#### Backup - Danaa Database Backup Has Been Faild "}' "$discord_url"
  printf ""$RED"####### DANAA DATABASE UPLOADING HAS NOT BEEN SUCSSESFUL"
  echo ".........."
fi

### Remove files ###
rm -rf "$DB_BAK_HOST_DIR"*
printf ""$GREEN"####### ClEANED "$NC" \t "$date" \t Done\n"
sleep 1
printf ""$GREEN"......... DANAA BACKUP HAS BEEN FINISHED ......... "$NC" \t "$date" \t Done\n"