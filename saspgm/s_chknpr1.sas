*-----------------------------------------------------------------------------;
* Study.......: REC1901                                                       ;
* Name........: s_chknpr1.sas                                                 ;
* Date........: 2019-03-04                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Print unique codes from NPR                                   ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...: npr_children, npr_parents, npr_relatives                      ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.04.01M4P110916                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;
libname  hepp     'P:\0RECAP\0RECAP_Research\sasproj\REC\sasdsn\Data_from_SCB_SOS' access=readonly;
filename saspgm   'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';

*-- SAS macros ---------------------------------------------------------------;
%inc saspgm(sca2util)/nosource;
%inc saspgm(scarep)  /nosource;
%inc saspgm(tit)     /nosource;


*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;
options ls=130 ps=43 nodate nonumber nocenter source source2 nostimer msglevel=N
        notes dsnferr serror fmterr details
        mautosource nomstored mrecall
        sasautos=("P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm")
        fmtsearch=(work psfmt rsfmt)
        nomacrogen nosymbolgen nomtrace nomlogic nomprint
        mergenoby=WARN validvarname=upcase
        formchar='|----|+|---+=|-//<>*'
        comamid=tcp remote=matrix
;

proc sql;
  create table t1 as
  select distinct child_id, icd, diag
  from hepp.npr_children
;
  *where diag_id='0';
quit;

proc freq data=t1;
  table icd * diag / nocol nopercent out=t2 noprint;
run;

title1 'Available ICD codes in children (Main or 2nd diagnosis)';
%tit(REC1901,us=sven.sandin@ki.se,prog=s_chknpr1);
%scarep(data=t2,id=icd,var=diag count,panels=7);


*-- Repeat for parents;
proc sql;
  create table t3 as
  select distinct parent_id, icd, diag
  from hepp.npr_parents
;
  *where diag_id='0';
quit;

proc freq data=t3;
  table icd * diag / nocol nopercent out=t4 noprint;
run;

title1 'Available ICD codes in parents (Main or 2nd diagnosis)';
%tit(REC1901,us=sven.sandin@ki.se,prog=s_chknpr1);
%scarep(data=t4, id=icd, var=diag count, panels=7);


*-- Repeat for relatives ;
proc sql;
  create table t5 as
  select distinct relative_id, icd, diag
  from hepp.npr_relatives
;
  *where diag_id='0';
quit;

proc freq data=t5;
  table icd * diag / nocol nopercent out=t6 noprint;
run;

title1 'Available ICD codes in relatives (Main or 2nd diagnosis)';
%tit(REC1901,us=sven.sandin@ki.se,prog=s_chknpr1);
%scarep(data=t6, id=icd, var=diag count, panels=7);




*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete t1-t6;
quit;

*-- End of File --------------------------------------------------------------;
