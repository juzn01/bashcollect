#!/bin/sh
############################################
#Scripts check File system space by QuanNP #
############################################

#---------------------------------------------
# Init Parameters
#---------------------------------------------

SUBJECT="`hostname` reports file system space"
RCPT="anh.nt1@shb.com.vn quan.np@shb.com.vn "
FLAG=0
DAILY=0708

LOG_FILE='/tmp/logfile_'

#---------------------------------------------
# log name
#---------------------------------------------

# check sub directory exists or not 
SUB_LOG_FILE=`date +%Y_%m_%d`
LOG_FILE=$LOG_FILE$SUB_LOG_FILE".txt"


#---------------------------------------------
# Get file system space
#---------------------------------------------

df -hP | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $6}' | while read FS_SPACE;
do
	#echo $FS_SPACE
	USED=$(echo $FS_SPACE | awk '{ print $1}' | cut -d'%' -f1 )
	PARTITION=$(echo $FS_SPACE | awk '{ print $2 }')
	#echo "---"
	#echo $USED
	#echo $PARTITION
	if [ $USED -ge 80 ]
	  then
                echo "Warning: file system $PARTITION is running out of space: " > $LOG_FILE
                echo "================================================================================" >> $LOG_FILE
                df -hP >> $LOG_FILE
                echo "===================================== End ========================================" >> $LOG_FILE
                mail -s "$SUBJECT WARNING" $RCPT < $LOG_FILE
                #cat $LOG_FILE
		FLAG=1
	# else
	#	echo " file system ngon " >> $LOG_FILE
	#	more $LOG_FILE
	fi
done

if [ $FLAG == 0 ] && [ `date +%H%M` == $DAILY ]
	then 
		echo " File system space is ok" > $LOG_FILE
                echo "================================================================================" >> $LOG_FILE
                df -hP >> $LOG_FILE
                echo "===================================== End ========================================" >> $LOG_FILE
		mail -s "$SUBJECT OK" $RCPT < $LOG_FILE
		#echo "FS is OK"
fi		

################################# END ####################################

