cd /Backup/mysql_backup
#rm -rf *

USER="root"
PASSWORD="password"
HOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
OUTPUT_DIR="/Backup/mysql_backup"

# Parse options
while getopts ":u:p:h:o:" opt; do
    case $opt in
        u)
            USER=$OPTARG
            ;;
        p)
            PASSWORD=$OPTARG
            ;;
        h)
            HOST=$OPTARG
            ;;
        o)
            OUTPUT_DIR=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
VALIDATION_ERROR=false

if [ -z "$USER" ]; then
    echo "User has not been specified" >&2
    VALIDATION_ERROR=true
fi
if [ -z "$PASSWORD" ]; then
    echo "Password has not been specified" >&2
    VALIDATION_ERROR=true
fi

if [ -z "$OUTPUT_DIR" ]; then
    echo "Output dir has not been specified" >&2
    VALIDATION_ERROR=true
fi

if $VALIDATION_ERROR ; then
    exit 1
fi

dd=`date +%Y%m%d`

DBS="$($MYSQL -u $USER -h $HOST -p$PASSWORD -Bse 'show databases')"
for db in $DBS
do
#    if [ $db != "information_schema" ]; then
if [ $db != "information_schema" ] && [ $db != "performance_schema" ] ; then
  FILE=$OUTPUT_DIR/$db.sql.gz
        $MYSQLDUMP -u $USER -h $HOST -p$PASSWORD --skip-lock-tables --force --routines --events --triggers  --single-transaction $db  > $FILE
    fi
done
echo -e "----------------------------------\n   `date`   \n----------------------------------" > /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Successfully completed backup of all databases of server" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Generated backup files are as below:" >> /tmp/backupdata.txt
#cd /Backup/mysqlbackup
ls -lh | awk '{print $5, $9}' >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Total backup files are : `ls -lh|wc -l `" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Total backup size : `du -h`" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Disk usage report is as below :" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "`df -h`" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Memory report is as below :" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "`free -m`" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "Uptime report is as below :" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt
echo "`uptime`" >> /tmp/backupdata.txt
echo "" >> /tmp/backupdata.txt

mail -s "Successfully completed backup of all databases `date`" emailid@example.com  < /tmp/backupdata.txt
mkdir /Backup/mysql_backup/`date +%Y%m%d`
sleep 1
mv /Backup/mysql_backup/*.sql.gz /Backup/mysql_backup/`date +%Y%m%d`
sleep 10
/bin/sync
sleep 2
/bin/echo 3 > /proc/sys/vm/drop_caches

# remove older backup
find /Backup/mysql_backup/* -type d -ctime +5 -exec rm -rf {} \;
