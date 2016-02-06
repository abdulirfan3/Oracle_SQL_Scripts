echo off 
set /p x=Enter DB Name(rcatprd or rcatdev): 
echo you entered %x% 

sqlplus system/Winter4all1@%x%