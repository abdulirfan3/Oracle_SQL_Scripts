COLUMN namespace                        heading "Library Object"
COLUMN gets             format 999,999,999,999   heading " Gets"
COLUMN gethitratio      format 999.99   heading " Get Hit%"
COLUMN pins             format 999,999,999,999   heading " Pins"
COLUMN pinhitratio      format 999.99   heading " Pin Hit%"
COLUMN reloads          format 999,999,999,999   heading " Reloads"
COLUMN invalidations    format 999,999,999,999   heading " Invalidations"
COLUMN db               format a10
SELECT namespace, gets, gethitratio * 100 gethitratio, pins,
       pinhitratio * 100 pinhitratio, reloads, invalidations
  FROM v$librarycache
/