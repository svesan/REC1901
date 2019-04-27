*-- Repeat main Cox regressions on paternal uncle(s)/aunt(s);

*-- dm_1 with mothers replaced by fathers;
*-- now the variable 'masib' means 'pasib', 'MGP' means 'PGP', 'MGM' means 'PGM'
*-- but we keep the variable names unchanged for ease to use the old codes;

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
  from study.kisvens_lev_foraldrar
  ;
quit;

*-- Siblings. Full and half (maternal and paternal);
*-- Swedish Helsyskon=Full sibling, HalvsyskonMor=Maternal halfsib, HalvsyskonFar=Paternal halfsib;
*-- There're three datasets containing sibling information: Kisvens_lev_biofar_syskon, Kisvens_lev_biomor_syskon, and Kisvens_lev_syskon, combine them first to get a complete siblings dataset;
data msibling; set study.kisvens_lev_biomor_syskon; run;
data psibling; set study.kisvens_lev_biofar_syskon; run;
data csibling; set study.kisvens_lev_syskon; run;

proc sort data=msibling; by lopnr_biomor; run;
proc sort data=psibling; by lopnr_biofar; run;
proc sort data=csibling; by lopnr_indexperson; run;

data sibling0;
set msibling(rename=(lopnr_biomor=lopnr lopnr_biomor_syskon=lopnr_syskon)) 
      psibling(rename=(lopnr_biofar=lopnr lopnr_biofar_syskon=lopnr_syskon));
run;

*Combining all siblings independent from which genereations;
data sibling1;
set csibling(rename=(lopnr_indexperson=lopnr)) sibling0;
run;

* Remove duplicates;
proc sql;
create table sibling2 as select
distinct lopnr, lopnr_syskon, syskontyp from sibling1;
quit;

data sibling3;
drop syskontyp;
length sibtype $5;
set sibling2;
if syskontyp='Helsyskon' then sibtype='Full';
else if syskontyp in: ('Halvsyskon') then sibtype='Half';
else sibtype='Other';
run;

*One sibling pair may have more than one sibtype, sort the sibling and select the first one (Full>Half>Other);
proc sort data=sibling3; by lopnr lopnr_syskon sibtype; run;
data sibling4; set sibling3; by lopnr lopnr_syskon sibtype; if first.lopnr_syskon; run;

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
	order by lopnr, birth_dat
  ;
quit;

data check; /**Children died within a month after born;**/
  set childdsn1;
  if year(birth_dat)=year(death_dat) and month(birth_dat)=month(death_dat);
run;


*-- Emigration;
data emig1 slask;
  drop datum;
  attrib lopnr length=6 emig_dat length=4 format=yymmdd10. label='Date of emigration';
  set study.kisvens_lev_migration_ny(keep=lopnr datum posttyp where=(posttyp='Utv'));
  if length(datum)=8 then do;
    emig_dat=input(datum, yymmdd8.); output emig1;
  end;
  else output slask;
run;
**There's one person (lopnr=11557730) has two emigration dates (first date 19670200, not invalid), hard coded as 19670201;
data emig1;
set emig1;
if lopnr=11557730 then emig_dat=input('19670201',yymmdd8.);
run;

proc sort data=emig1;by lopnr emig_dat;run;

data emig2; /**Keep the first emigration date**/
  length check 3;
  merge emig1(in=emig keep=lopnr emig_dat) childdsn1(in=born keep=lopnr birth_dat); by lopnr;
  if emig and born then do;
    if emig_dat < birth_dat then check=0;
    if year(birth_dat)=year(emig_dat) and month(birth_dat)=month(emig_dat) then check=1;
    else if emig_dat > birth_dat then check=2;
  end;
  else delete;
run;
proc sort data=emig2(where=(check GE 1));by lopnr emig_dat;run; /**Remove those emigrated before or at birth**/
proc sort data=emig2 out=emig3(drop=check) nodupkey;by lopnr;run; /**Remove duplicates**/

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

*------------------------------------------------------------;                                                                          
* Select participants and identify paternal uncle/aunt(s)    ;                                                                          
*------------------------------------------------------------;                                                                                                                                                                                                                                                                                                         
proc sql;                                                                                                                               
  create table s1 as                                                                                                                    
  select lopnr as child, sex as child_sex,                                                                             
         birth_dat as child_birth_dat length=4 format=yymmdd8. label='Date of Birth'                       
  from childdsn2 
  where birth_yr ge 2003 and birth_yr le 2012; 
  /**where birth_yr ge 1991 and birth_yr le 2002; Select all children born 1991-2002, just to compare with old data**/                                                                                                                                          
  *select year(birth_dat) as year, count(*) from s1 group by year;                                                                      
quit;                                                                                                                                   
                                                                                                                                        
                                                                                                                                        
*-- Join in mother and father id (also paternal grandparents for family id);                                                                                                       
proc sql;                                                                                                                               
  create table s2 as                                                                                                                    
  select a.*, b.mother as mother, b.father as father, b.pa_gma as MGM, b.pa_gpa as MGP                                                                                
  from s1 as a                                                                                                                          
  left join family1 as b                                                                                             
    on a.child = b.lopnr                                                                                                                
  ;                                                                                                                                     
quit;                                                                                                                                   
                                                                                                                                        
*-- Subset to families where both mother and father is known;                                                                           
proc sql;                                                                                                                               
  create table s3 as select * from s2 where mother > .z and father > .z;                                                                
quit;                                                                                                                                   
                                                                                                                                        
*-- Fathers' siblings and birth info;                                                                                                    
proc sql;                                                                                                                               
  create table s4(label='Fathers siblings') as                                                                                          
  select a.child, a.child_birth_dat, a.child_sex, a.mother, a.father, a.MGM, a.MGP, b.lopnr_syskon as masib1 label='Mothers sibling', b.sibtype as sibling_type,                                                                                                  
         c.birth_dat as mob_dat length=4 format=yymmdd8. label='Mothers birth date',                 
         d.birth_dat as fab_dat length=4 format=yymmdd8. label='Fathers birth date'          
  from s3 as a                                                                                                                          
  left join sibling4 as b                                                                                                   
    on a.father = b.lopnr    /**Father's siblings**/                                                                                                            
  left join childdsn2 as c                                                                                                    
    on a.mother = c.lopnr                                                                                                                                                                                                                                                                                                                                        
  left join childdsn2 as d                                                                                                    
    on a.father = d.lopnr                                                                                                               
  ;                                                                                                                                     
quit;    
                                                                                                                                        
data s5;                                                                                                                                
  drop masib1 sibling_type;                                                                                                    
  format child mother father ;                                                                                                          
  informat child mother father ;                                                                                                        
  attrib masib_typ length=$16 label='Sibling type' masib length=8 label='Paternal sibling ID';                                                                                                                                                                                

  set s4;                                                                                                                               

  if masib1 GT .z then do; 
  masib_typ=sibling_type; masib=masib1; output; 
  end;                                                                                                                                                                                                                                                                 
run; 
 
*----------------------------------------------------------------;                                                      
* Add information about parental siblings sex                    ;                                                      
*----------------------------------------------------------------;                                                                                                                                                                                      
                                                                                                                                        
proc sql;                                                                                                                               
  create table s6 as                                                                                                                    
  select a.*, b.sex as masib_sex,                                                                                        
         b.birth_dat as sib_birth_dat length=4 format=yymmdd8. label='Sib Date of Birth'             
  from s5 as a                                                                                                                          
  left join childdsn2 as b                                                                                                    
    on a.masib=b.lopnr                                                                                                                  
  ;                                                                                                                                     
quit;                                                                                                                                   
                                                                                                                                        
*--Keep distinct child-masib pair, i.e., one pair one row;                                                                              
proc summary data=s6 nway;
  var child;
  class child mother father masib child_birth_dat child_sex MGM MGP MOB_DAT FAB_DAT MASIB_SEX SIB_BIRTH_DAT masib_typ;
  output out=test n=n;
  run;

data _null_;
  set test;
  if n > 1 then put 'ERROR: SEVERE PROBLEMS IN THE DATASET S6. ROWS NOT UNIQUE';
run;
                                                
proc sql; create table s7 as select distinct * from s6; quit;
