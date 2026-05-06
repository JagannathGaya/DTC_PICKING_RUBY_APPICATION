SQL> -- be sure to hit template schema
SQL> select 'spool c:\temp\tbdash_pinne_all_clients' from dual
  2  /
spool c:\temp\tbdash_pinne_all_clients                                          

SQL> select '@@do_pinne template/template@&&db_connection' from dual
  2    where '&&db_connection' = 'tb10g'
  3  union all
  4  select '@@do_pinne '||cust_no||' '||cust_no||' '||'&&db_connection'
  5  from custmast a, all_users b
  6  	    where a.cust_no = b.username
  7  	    and a.status_code = 'A'
  8  	    and a.cust_no != user
  9  	    order by 1
 10  /
@@do_pinne ADA860 ADA860 tb10g                                                  
@@do_pinne AIS865 AIS865 tb10g                                                  
@@do_pinne ARC805 ARC805 tb10g                                                  
@@do_pinne ATT630 ATT630 tb10g                                                  
@@do_pinne BLU830 BLU830 tb10g                                                  
@@do_pinne CAB815 CAB815 tb10g                                                  
@@do_pinne CAR800 CAR800 tb10g                                                  
@@do_pinne CRB840 CRB840 tb10g                                                  
@@do_pinne CRY900 CRY900 tb10g                                                  
@@do_pinne DES875 DES875 tb10g                                                  
@@do_pinne DWR540 DWR540 tb10g                                                  
@@do_pinne FAB810 FAB810 tb10g                                                  
@@do_pinne FIL904 FIL904 tb10g                                                  
@@do_pinne FOU903 FOU903 tb10g                                                  
@@do_pinne FRI855 FRI855 tb10g                                                  
@@do_pinne FYP200 FYP200 tb10g                                                  
@@do_pinne HAR835 HAR835 tb10g                                                  
@@do_pinne HAW440 HAW440 tb10g                                                  
@@do_pinne HBF845 HBF845 tb10g                                                  
@@do_pinne HDC470 HDC470 tb10g                                                  
@@do_pinne HDH170 HDH170 tb10g                                                  
@@do_pinne HMI100 HMI100 tb10g                                                  
@@do_pinne HUM480 HUM480 tb10g                                                  
@@do_pinne INS895 INS895 tb10g                                                  
@@do_pinne INT901 INT901 tb10g                                                  
@@do_pinne KIC400 KIC400 tb10g                                                  
@@do_pinne KNL520 KNL520 tb10g                                                  
@@do_pinne KNT530 KNT530 tb10g                                                  
@@do_pinne LEB740 LEB740 tb10g                                                  
@@do_pinne MAI885 MAI885 tb10g                                                  
@@do_pinne MNC905 MNC905 tb10g                                                  
@@do_pinne NAS890 NAS890 tb10g                                                  
@@do_pinne NOM420 NOM420 tb10g                                                  
@@do_pinne OMN880 OMN880 tb10g                                                  
@@do_pinne PAZ220 PAZ220 tb10g                                                  
@@do_pinne POB250 POB250 tb10g                                                  
@@do_pinne RAB750 RAB750 tb10g                                                  
@@do_pinne SER825 SER825 tb10g                                                  
@@do_pinne SIT160 SIT160 tb10g                                                  
@@do_pinne SOU850 SOU850 tb10g                                                  
@@do_pinne SPL780 SPL780 tb10g                                                  
@@do_pinne SRC902 SRC902 tb10g                                                  
@@do_pinne STL380 STL380 tb10g                                                  
@@do_pinne STX870 STX870 tb10g                                                  
@@do_pinne TEN130 TEN130 tb10g                                                  
@@do_pinne TRE510 TRE510 tb10g                                                  
@@do_pinne ULA360 ULA360 tb10g                                                  
@@do_pinne ZAV790 ZAV790 tb10g                                                  
@@do_pinne template/template@tb10g                                              

49 rows selected.

SQL> select 'spool off' from dual
  2  /
spool off                                                                       

SQL> spool off
