# eSP collector for Solaris
echo "Start eSP collector."
export ORAENV_ASK=NO
 
ORATAB=/var/opt/oracle/oratab
 
db=`egrep -i ":Y|:N" $ORATAB | cut -d":" -f1 | grep -v "\#" | grep -v "\*"`
for i in $db ; do
       export ORACLE_SID=$i
       . oraenv
 

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
