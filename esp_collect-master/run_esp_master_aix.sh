# eSP collector for aix
echo "Start eSP collector."
for INST in $(ps -ef | grep ora_pmon | grep -v 'grep ' | awk -F '_' '{print $3}'); do
        if [ $INST = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $INST )" ]; then
                echo "$INST: instance name = db_unique_name (single instance database)"
                export ORACLE_SID=$INST; export ORAENV_ASK=NO; . oraenv
        else
                # remove last char (instance nr) and look for name again
                typeset -L$((${#INST}-1)) LAST_REMOVED=$INST
                if [ $LAST_REMOVED = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $LAST_REMOVED )" ]; then
                        echo "$INST: instance name with last char removed = db_unique_name (RAC: instance number added)"
                        export ORACLE_SID=$LAST_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                elif [[ "$(echo $INST | sed 's/.*\(_[12]\)/\1/')" == "_[12]" ]]; then
                        # remove last two chars (rac one node addition) and look for name again
                        typeset -L$((${#INST}-2)) LAST_TWO_REMOVED=$INST
                        if [ $LAST_TWO_REMOVED = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $LAST_TWO_REMOVED )" ]; then
                                echo "$INST: instance name with either _1 or _2 removed = db_unique_name (RAC one node)"
                                export ORACLE_SID=$LAST_TWO_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                        fi
                else
                        echo "couldn't find instance $INST in oratab"
                        continue
                fi
        fi

sqlplus -s /nolog <<EOF
connect / as sysdba

@sql/esp_master.sql
EOF

done

zip -qm esp_recycle_bin.zip cpuinfo_model_name_*.txt 
zip -qm esp_recycle_bin.zip escp_*_*.csv 
zip -qm esp_recycle_bin.zip esp_requirements_*_*_*.csv 
zip -qm esp_recycle_bin.zip res_requirements_*_*_*.txt 
rm esp_recycle_bin.zip

echo "End eSP collector. Output: esp_output_hostname_yyyymmdd.zip"



