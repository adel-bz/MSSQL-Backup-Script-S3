# MSSQL-Backup-Script-S3

# Introduction
This repository contains a script for backing up MSSQL databases and sending them to an AWS S3 bucket. The script is designed to automate the backup process, making it easy to ensure that your MSSQL data is regularly backed up and stored securely on AWS S3.

# Features
- Automated backup of MSSQL databases.
- Support for sending backups directly to an AWS S3 bucket.
- Easy setup and configuration.
- Monitoring the backup process by sending the alert to Discord.

# Prerequisites
Before using this script, ensure you have the following prerequisites installed:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and configured IAM user
- [MSSQL Container](https://github.com/adel-bz/MSSQL-Database) on an Ubuntu server

# Usage
1. Clone this repository to your local machine:

``` 
git clone https://github.com/adel-bz/MSSQL-Backup-Script-S3.git 
```
2. Configure the script by editing the ```.env``` file:
```
## Container & Database Environments
CONTAINER_NAME="database_container_name"
SA_PASSWORD="database_password"
DB_NAMES=("master" "dbname_1" "dbname_2" "dbname3" "dbname4") # doesn't delete/change "master"
DB_BAK_HOST_DIR="/srv/backup/db/"
DB_PREFIXNAME="db_backup_file_prefixname_"

## S3 Environments
BUCKET_NAME="your_bucket_name"

## Other ENV
date=$(date +%Y-%m-%d_%Hh%Mm)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
discord_url='discord_webhook_url'
```
3. Run the script manualy:
```
sudo bash backup.sh
```
- Or use crontab
```
0 */12 * * * bash /srv/backup-script/backup.sh >> /var/log/backup.log
```

4. Verify that the backups have been successfully uploaded to the specified S3 bucket.
#

Feel free to customize this template according to your specific requirements and preferences. Let me know if you need further assistance!