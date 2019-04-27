libname  hepp     'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sasdsn\Data_from_SCB_SOS' access=readonly;
filename saspgm   'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';
libname  gnu  'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sasdsn\Data_from_SCB_SOS';
*filename saspgm '/home/workspace/projects/0RECAP/0RECAP_Research/sasproj/REC/REC1901/saspgm';


*----------------------------------------------------------------;
* Login to Matrix and allocate output directoru                  ;
*----------------------------------------------------------------;
%sign(Matrix);

rsubmit;
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
  select max(indatum) as max format=yymmdd8.
  from hepp.par_relatives_3304_2018;
quit;

proc sort data=hepp.par_relatives_3304_2018(keep=lopnr indatum hdia dia1-dia30) out=t1(where=(hdia ne ''));
  by lopnr indatum;
run;

data t2;
  length index 3 indatum 4;
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

data gnu.npr_relatives(label='NPR relatives' sortedby=lopnr index diag_dat);
  rename indatum=diag_dat;
  drop col1 _name_ yr;

  attrib diag length=&ml label='Diagnosis code' diag_id length=$2 label='Diagnosis order (Main and secondary)'
         icd        length=$3. label='ICD'
  ;

  set t3;

  *-- Derive ICD code;
  yr=year(diag_dat);
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
  length index 3 indatum 4;
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

data gnu.npr_parents(label='NPR parents' sortedby=lopnr index diag_dat);
  rename indatum=diag_dat;
  drop col1 _name_ yr;

  attrib diag length=&ml label='Diagnosis code' diag_id length=$2 label='Diagnosis order (Main and secondary)'
         icd        length=$3. label='ICD'
  ;

  set t3;

  *-- Derive ICD code;
  yr=year(diag_dat);
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
  length index 3 indatum 4;
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

data gnu.npr_children(label='NPR children' sortedby=lopnr index diag_dat);
  rename indatum=diag_dat;
  drop col1 _name_ yr;

  attrib diag length=&ml label='Diagnosis code' diag_id length=$2 label='Diagnosis order (Main and secondary)'
         icd        length=$3. label='ICD'
  ;

  set t3;

  *-- Derive ICD code;
  yr=year(diag_dat);
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
proc upload data=gnu.npr_parents out=study.npr_parents;run;
proc upload data=gnu.npr_children out=study.npr_children;run;
endrsubmit;

rsubmit;
proc upload data=gnu.kisvens_lev_foraldrar       out=study.kisvens_lev_foraldrar        ;run;
proc upload data=gnu.kisvens_lev_kusiner         out=study.kisvens_lev_kusiner          ;run;
proc upload data=gnu.kisvens_lev_biomor_syskon   out=study.kisvens_lev_biomor_syskon    ;run;
proc upload data=gnu.kisvens_lev_biofar_syskon   out=study.kisvens_lev_biofar_syskon    ;run;
proc upload data=gnu.kisvens_lev_syskon          out=study.kisvens_lev_syskon           ;run;
proc upload data=gnu.kisvens_lev_fodelsedata     out=study.kisvens_lev_fodelsedata      ;run;
proc upload data=gnu.kisvens_lev_doda            out=study.kisvens_lev_doda             ;run;
proc upload data=gnu.kisvens_lev_migration_ny    out=study.kisvens_lev_migration_ny     ;run;
endrsubmit;
