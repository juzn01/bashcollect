#############################################
#Scripts check system performance by QuanNP #
#############################################
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/local/bin
#---------------------------------------------
# Init Parameters
#---------------------------------------------
SUBJECT="`hostname` REPORTS SYSTEM WARNING"
RCPT="quan.np@shb.com.vn"

LOG_FILE='/tmp/logfile_'

THRE_LOAD=6
THRE_WAIT=3
TRUE="1"

#---------------------------------------------
# log name
#---------------------------------------------

# check sub directory exists or not 
SUB_LOG_FILE=`date +%Y_%m_%d`
LOG_FILE=$LOG_FILE$SUB_LOG_FILE".txt"

#---------------------------------------------
# Get load average 1st minute, wait info
#---------------------------------------------

LOAD1M=`(uptime | awk -F "average" '{ print $2 }' | cut -d, -f1) | sed 's/: //g'`
WAIT=`sar 1 | sed -n 4p | awk '{print $6}'`

#---------------------------------------------
# Compare load, wait with threshold and send mail
#---------------------------------------------

RESULT_LOAD=$(echo "$LOAD1M >= $THRE_LOAD" | bc)
RESULT_WAIT=$(echo "$WAIT >= $THRE_WAIT" | bc)

if [ "$RESULT_LOAD" == "$TRUE" ] || [ "$RESULT_WAIT" == "$TRUE" ]

   then
        echo "SYSTEM IS OVERLOAD, LOAD AVERAGE OR WAITIO IS ACROSSED THE LIMIT: " >> $LOG_FILE
        echo "  LOAD AVERAGE IS : $LOAD1M|LIMIT IS: $THRE_LOAD" >> $LOG_FILE
        echo "  %WAIT IS                : $WAIT|LIMIT IS: $THRE_WAIT" >> $LOG_FILE

        echo "================================================================================" >> $LOG_FILE
        echo "LOAD AVERAGE:" >> $LOG_FILE
        uptime >> $LOG_FILE

        echo "================================================================================" >> $LOG_FILE
        echo "CPU STATUS AND IO STATUS" >> $LOG_FILE
        iostat >> $LOG_FILE

        echo "================================================================================" >> $LOG_FILE
        echo "MEMORY STATUS" >> $LOG_FILE
        vmstat >> $LOG_FILE

        mail -s "$SUBJECT WARNING" $RCPT < $LOG_FILE

   elif [ `date +%H%M` == $DAILY1 ] || [ `date +%H%M` == $DAILY2 ]
        then
        echo "SYSTEM IS OK: " >> $LOG_FILE
        echo "  LOAD AVERAGE IS : $LOAD1M | LIMIT IS: $THRE_LOAD" >> $LOG_FILE
        echo "  %WAIT IS        :  $WAIT  | LIMIT IS: $THRE_WAIT" >> $LOG_FILE
        echo "================================================================================" >> $LOG_FILE
        echo "LOAD AVERAGE:" >> $LOG_FILE
        uptime >> $LOG_FILE
		
        mail -s "$SUBJECT OK" $RCPT < $LOG_FILE
fi

################################# END ####################################
