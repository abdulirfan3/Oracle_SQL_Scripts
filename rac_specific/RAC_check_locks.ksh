#! /bin/ksh
#  --------------------------------------------------------------------------------------------------
#  Author: Riyaj Shamsudeen @OraInternals, LLC
#          www.orainternals.com
# 
#  Functionality: This script is to print locks in RAC.
#  **************
#  Use Case: 1. Useful to find print locks in RAC. In RAC, gv$lock is almost useless.
#               It doesn't provide much information. GV$ges_enqueue is very slow since
#               it  includes BL locks and with very large SGAs nowadays, queries against gv$ges_enqueus are
#               very slow.
# 
#  Note : 1. Keep window 160 columns for better visibility.
# 
#  Exectution type:  Calls check_lock.sql
# 
#  Please send me an email to rshamsud@orainternals.com, if you enhance this script :-)
#  --------------------------------------------------------------------------------------------------
#

typeset -i COUNT 
typeset -i loopcnt 
loopcnt=0

while [[ $loopcnt -lt 10000 ]];
 do
sqlplus "/ as sysdba " <<EOF
set lines 120 pages 0 echo off feedback off
select 'COUNT '||count(*) cnt from gv\$session_wait where event='enqueue';

spool /tmp/check_lock.lst
/
spool off
EOF

COUNT=`grep -i COUNT /tmp/check_lock.lst|awk '{print $2}'`
echo $COUNT
if [ ${COUNT} -gt 0 ] ; then
        echo  "locks ? " $COUNT
sqlplus "/ as sysdba " <<EOF
spool /tmp/locks2.lst
set lines 120 pages 100 
@check_lock.sql
spool off
EOF
#mailx -s "locks ? "  somebody@somewhere.com <<EOF 
#locks d? : $COUNT
#EOF
fi
sleep  5
done