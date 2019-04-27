*-----------------------------------------------------------------------------;
* Study.......: REC1901                                                       ;
* Name........: dm_transpose_npr2.sas                                         ;
* Date........: 2019-02-21                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Transpose patient register datasets and make them more        ;
* ............: analysis friendly                                             ;
* Note........: 2204-2018 is the diarienr at Socialstyrelsen                  ;
* Note........: Data delivered by Henrik.Passmark                             ;
*-----------------------------------------------------------------------------;
* Data used...: par_relatives_3304_2018 par_parents_3304_2018                 ;
* ............: par_indexchildren_3304_2018  (delivered by SOS)               ;
* Data created: npr_relatives npr_parents npr_children                        ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.04.01M4P110916                               ;
*-----------------------------------------------------------------------------;


*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;
options nocenter nodate;

*----------------------------------------------------------------;
* Login to Matrix and allocate output directoru                  ;
*----------------------------------------------------------------;
%sign(Matrix);

libname  hepp     'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sasdsn\Data_from_SCB_SOS' access=readonly;
filename saspgm   'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';

*-- Libname for VDI;
libname  gnu  'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sasdsn\Data_from_SCB_SOS';

*-- Libname for Linux at MEB;
*libname  gnu  '/home/workspace/projects/0RECAP/0RECAP_Research/sasproj/REC/REC1901/sasdsn/Data_from_SCB_SOS/';
*filename saspgm '/home/workspace/projects/0RECAP/0RECAP_Research/sasproj/REC/REC1901/saspgm';


rsubmit;
options nocenter nodate;


*-- Next the RECAP folder data  directory;
libname study  '/nfs/projects/0RECAP/REC/REC1901/sastmp';
endrsubmit;


*-- Allocate remove server work directory;
libname swork  slibref=work server=matrix;
libname sstudy slibref=study server=matrix;


*----------------------------------------------------------------;
* First process the patient register for relatives (then parents ;
* and next for the children                                      ;
*----------------------------------------------------------------;
proc sql;
*  select max(indatum) as max format=yymmdd8.
  from hepp.par_relatives_3304_2018;
quit;

proc sort data=hepp.par_relatives_3304_2018(keep=lopnr indatum hdia dia1-dia30) out=t1(where=(hdia ne ''));
  by lopnr indatum;
run;

data t2;
  length lopnr 5 index 3 indatum 4;
  retain index 0;
  set t1;
  by lopnr indatum;
  if first.lopnr then index=1;
  else index=index+1;
run;


proc transpose data=t2 out=t3(where=(col1 ne '') drop=_label_);
  var hdia dia1-dia30;
  by lopnr index indatum;
run;

*-- Find longest diagnosis code and use this to minimize variable length;
proc sql noprint;select compress('$'||put(max(length(compress(hdia))), 2.)) into : ml from t1(obs=25);quit;

data gnu.npr_relatives(label='NPR relatives' sortedby=relative_id index diag_dat);
  rename indatum=diag_dat lopnr=relative_id;
  drop col1 _name_ yr;

  attrib diag length=&ml label='Diagnosis code' diag_id length=$2 label='Diagnosis order (Main and secondary)'
         icd        length=$3. label='ICD'
         lopnr      label='ID if relatives'
         indatum    label='Diagnosis date'
         index      label='Diagnosis order for each date'
  ;

  set t3;

  *-- Derive ICD code;
  yr=year(indatum);
  if yr <= 1968 then icd = '7';
  else if 1969 <= yr <= 1986 then icd = '8';
  else if 1987 <= yr <= 1996 then icd = '9';
  else if 1997 <= yr then icd = '10';

  diag=col1;

  if _name_='HDIA' then diag_id='0';
  else diag_id=compress(tranwrd(_name_, 'DIA', ''));
run;


*----------------------------------------------------------------;
* Now do the same for parents                                    ;
*----------------------------------------------------------------;
proc datasets lib=work mt=data nolist;
  delete t1 t2 t3;
quit;

proc sort data=hepp.par_parents_3304_2018(keep=lopnr indatum hdia dia1-dia30) out=t1(where=(hdia ne ''));
  by lopnr indatum;
run;

data t2;
  length lopnr 5 index 3 indatum 4;
  retain index 0;
  set t1;
  by lopnr indatum;
  if first.lopnr then index=1;
  else index=index+1;
run;


proc transpose data=t2 out=t3(where=(col1 ne '') drop=_label_);
  var hdia dia1-dia30;
  by lopnr index indatum;
run;

*-- Find longest diagnosis code and use this to minimize variable length;
proc sql noprint;select compress('$'||put(max(length(compress(hdia))), 2.)) into : ml from t1(obs=25);quit;

data gnu.npr_parents(label='NPR parents' sortedby=parent_id index diag_dat);
  rename indatum=diag_dat lopnr=parent_id;
  drop col1 _name_ yr;

  attrib diag length=&ml label='Diagnosis code' diag_id length=$2 label='Diagnosis order (Main and secondary)'
         icd        length=$3. label='ICD'
         lopnr      label='Parent ID'
         indatum    label='Diagnosis date'
         index      label='Diagnosis order for each date'
  ;

  set t3;

  *-- Derive ICD code;
  yr=year(indatum);
  if yr <= 1968 then icd = '7';
  else if 1969 <= yr <= 1986 then icd = '8';
  else if 1987 <= yr <= 1996 then icd = '9';
  else if 1997 <= yr then icd = '10';

  diag=col1;

  if _name_='HDIA' then diag_id='0';
  else diag_id=compress(tranwrd(_name_, 'DIA', ''));
run;


*----------------------------------------------------------------;
* Now do the same for children                                   ;
*----------------------------------------------------------------;
proc datasets lib=work mt=data nolist;
  delete t1 t2 t3;
quit;

proc sort data=hepp.par_indexchild_3304_2018(keep=lopnr indatum hdia dia1-dia30) out=t1(where=(hdia ne ''));
  by lopnr indatum;
run;

data t2;
  length lopnr 5 index 3 indatum 4;
  retain index 0;
  set t1;
  by lopnr indatum;
  if first.lopnr then index=1;
  else index=index+1;
run;


proc transpose data=t2 out=t3(where=(col1 ne '') drop=_label_);
  var hdia dia1-dia30;
  by lopnr index indatum;
run;

*-- Find longest diagnosis code and use this to minimize variable length;
proc sql noprint;select compress('$'||put(max(length(compress(hdia))), 2.)) into : ml from t1(obs=25);quit;

data gnu.npr_children(label='NPR children' sortedby=child_id index diag_dat);
  rename indatum=diag_dat lopnr=child_id;
  drop col1 _name_ yr;

  attrib diag length=&ml label='Diagnosis code' diag_id length=$2 label='Diagnosis order (Main and secondary)'
         icd        length=$3. label='ICD'
         lopnr      label='Child ID'
         indatum    label='Diagnosis date'
         index      label='Diagnosis order for each date'
  ;

  set t3;

  *-- Derive ICD code;
  yr=year(indatum);
  if yr <= 1968 then icd = '7';
  else if 1969 <= yr <= 1986 then icd = '8';
  else if 1987 <= yr <= 1996 then icd = '9';
  else if 1997 <= yr then icd = '10';

  diag=col1;

  if _name_='HDIA' then diag_id='0';
  else diag_id=compress(tranwrd(_name_, 'DIA', ''));
run;


*----------------------------------------------------------------;
* Upload data                                                    ;
*----------------------------------------------------------------;
rsubmit;
proc upload data=gnu.npr_relatives out=study.npr_relatives;run;
proc upload data=gnu.npr_parents   out=study.npr_parents;run;
proc upload data=gnu.npr_children  out=study.npr_children;run;

proc sort data=study.npr_relatives; by relatives_id diag_dat index;run;
proc sort data=study.npr_parents;   by parents_id diag_dat index;run;
proc sort data=study.npr_child;     by child_id diag_dat index;run;



*----------------------------------------------------------------;
* Create index                                                   ;
*----------------------------------------------------------------;
proc sql;
  create index diag on study.npr_relatives(diag);
  create index diag on study.npr_parents(diag);
  create index diag on study.npr_children(diag);

  create index icddiag on study.npr_relatives(icd,diag);
  create index icddiag on study.npr_parents(icd,diag);
  create index icddiag on study.npr_children(icd,diag);
quit;


proc contents data=study.npr_relatives;run;
proc contents data=study.npr_parents;run;
proc contents data=study.npr_children;run;


*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;

*-- End of File --------------------------------------------------------------;
