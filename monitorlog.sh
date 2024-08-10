#!/bin/bash

# Variables
THRESHOLD=80  # Threshold for disk usage in percentage
LOGFILE="/var/log/syslog"  # Log file to store disk usage history
ALERT_EMAIL="monusharma2562002@gmail.com"  # Email address to send alerts

# Function to check disk usage
check_disk_usage() {
    df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
    do
        usage=$(echo $output | awk '{ print $1}' | sed 's/%//g')
        partition=$(echo $output | awk '{ print $2 }')

        if [ $usage -ge $THRESHOLD ]; then
            echo "Disk usage on $partition is at ${usage}% as on $(date)" | tee -a $LOGFILE

            # Sending alert email
            echo "Subject: Disk Usage Alert - $partition" | sendmail $ALERT_EMAIL
        else
            echo "Disk usage on $partition is at ${usage}% as on $(date)" >> $LOGFILE
        fi
    done
}

# Function to rotate logs
rotate_logs() {
    # Rotate logs if they exceed 10MB
    if [ $(du -m $LOGFILE | cut -f1) -gt 10 ]; then
        mv $LOGFILE "${LOGFILE}_$(date +%Y%m%d%H%M%S)"
        touch $LOGFILE
    fi
}

# Main script execution
rotate_logs
check_disk_usage
