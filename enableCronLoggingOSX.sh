#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# enableCronLoggingOSX.sh
#
# Enable the logging of cron jobs in OSX in /var/log/cron.log
#
# Usage: bash enableCronLoggingOSX.sh
#
# Author: Jayson Grace, jayson.e.grace@gmail.com, 8/16/2017
# ----------------------------------------------------------------------------
echo 'cron.*              /var/log/cron.log' | sudo tee -a /etc/syslog.conf
