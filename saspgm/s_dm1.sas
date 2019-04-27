libname study   'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sasdsn\Data_from_SCB' access=readonly;
filename saspgm 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';

proc format;
  value sexfmt 1='Male' 2='Female';
  value yesno  1='Yes' 0='No';
run;



*-- Dataset for family members: Parents and grand parents;
proc sql;
  create table family1 as
  select lopnr_indexperson as lopnr length=6,
         lopnrbiofar as father length=6,
         lopnrbiomor as mother length=6,
         lopnrmormor as ma_gma length=6,
         lopnrmorfar as ma_gpa length=6,
         lopnrfarfar as pa_gma length=6,
         lopnrfarmor as pa_gpa length=6
  from study.kisvens_lev_foraldrar(obs=1000)
  ;
quit;


*-- Cousins. Not needed at the moment;
proc sql;
  create table cousins as
  select lopnr_indexperson as lopnr length=6, lopnr_kusin length=6,
         kusintyp as cousin_type label='Type of Cousin'
  from study.kisvens_lev_kusiner(obs=100)
  ;
quit;


*-- Siblings. Full and half (maternal and paternal);
*-- Swedish Helsyskon=Full sibling, HalvsyskonMor=Maternal halfsib, HalvsyskonFar=Paternal halfsib;
proc sql;
  create table siblings as
  select lopnr_indexperson as lopnr length=6, lopnr_sibling length=6,
         syskontyp as sibling_type label='Type of Sibling'
  from study.kisvens_lev_syskon
  ;
quit;


/***

*-- Join information about sibling type (half or full) to the family dataset;
proc sql;
  create table family as
  select a.*,
         b.lopnr_sibling as fsibid length=6 label='Full sibling',
         c.lopnr_sibling as hsibid length=6,
         syskontyp as sibling_type label='Type of Sibling'
  from study.kisvens_lev_syskon
  ;
quit;
***/



*-- Child info: sex, birth year, birth year, date of death;
proc sql;
  create table childdsn1 as
  select a.lopnr length=6, a.kon as sex length=3 label='Sex' format=sexfmt.,
         input(compress(a.fodelsedatum_manad)||'01', yymmdd8.) as birth_dat length=4 format=yymmdd10. label='Date of birth',
         input(substr(compress(a.fodelsedatum_manad), 1, 4), 8.) as birth_yr length=4 label='Birth year',
         input(compress(b.doddatum), yymmdd8.) as death_dat length=4 format=yymmdd10. label='Date of death'
  from study.kisvens_lev_fodelsedata as a
  left join study.kisvens_lev_doda as b
    on a.lopnr = b.lopnr
  ;
quit;

proc sort data=childdsn1;by lopnr birth_dat;run;
data check;
  set childdsn1;
  if year(birth_dat)=year(death_dat) and month(birth_dat)=month(death_dat);
run;


*-- Emigration;
data emig1 slask;
  drop datum;
  attrib lopnr length=6 emig_dat length=4 format=yymmdd10. label='Date of emigration';
  set study.kisvens_lev_migration(keep=lopnr datum posttyp where=(posttyp='Utv'));
  if length(datum)=8 then do;
    emig_dat=input(datum, yymmdd8.); output emig1;
  end;
  else output slask;
run;
proc sort data=emig1;by lopnr emig_dat;run;

data emig2;
  length check 3;
  merge emig1(in=emig keep=lopnr emig_dat) childdsn1(in=born keep=lopnr birth_dat); by lopnr;
  if emig and born then do;
    if emig_dat < birth_dat then check=0;
    if year(birth_dat)=year(emig_dat) and month(birth_dat)=month(emig_dat) then check=1;
    else if emig_dat > birth_dat then check=2;
  end;
  else delete;
run;
proc sort data=emig2(where=(check GE 1));by lopnr emig_dat;run;
proc sort data=emig2 out=emig3(drop=check) nodupkey;by lopnr;run;

*-- Now, add emigration to the child info dataset;
data childdsn2;
  merge childdsn1(in=born) emig3(in=emig keep=lopnr emig_dat);by lopnr;
  if born;
run;




/*** Data listings
title1 'Children by birth year ';
proc freq data=childdsn1;
table birth_yr;format birth_yr 8.;
run;
***/
