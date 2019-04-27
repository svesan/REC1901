/**  
* Note: Cox_mXX datasets have more variables, but the Forbs_mXX datasets have exp_EXT and all covariates used in the models;
data cox_masib; set temp.cox_masib;run;  
data cox_muncle; set temp.cox_muncle; run;
data cox_maunt; set temp.cox_maunt; run;
**/

*-Select data for Cox models;
data cox_pasib(label='Cox analysis dataset for paternal aunts and uncles');
  keep child_birth_yr dad_birth_yr sib_birth_yr outcome child_sex exp_ASD exp_AD exp_EXT years censored dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd dad_psych
       exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;
  set ana6(where = (masib_typ='Full'));
  
  array values exp_ASD exp_ID exp_SCH exp_SPD;
  exp_EXT = max(of values[*]);
  years=round(tte/365.25, 0.01);
  censored=0;
  if cens_type in ('D','E','F') then censored=1;
  child_birth_yr=year(child_birth_dat);
  dad_birth_yr=year(fab_dat);
  sib_birth_yr=year(sib_birth_dat);
run;


data cox_puncle(label='Cox analysis dataset for paternal uncles');
keep child_birth_yr dad_birth_yr uncle_birth_yr outcome child_sex exp_ASD exp_AD exp_EXT years censored dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd dad_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;

set ana6 (where=(masib_typ='Full' and masib_sex=1));

array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
years=round(tte/365.25, 0.01);
censored=0;
if cens_type in ('D','E','F') then censored=1;
child_birth_yr=year(child_birth_dat);
dad_birth_yr=year(fab_dat);
uncle_birth_yr=year(sib_birth_dat);
run;

data cox_paunt(label='Cox analysis dataset for paternal aunts');
keep child_birth_yr dad_birth_yr aunt_birth_yr outcome child_sex exp_ASD exp_AD exp_EXT years censored dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd dad_psych
     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd exp_psych;

set ana6(where=(masib_typ='Full' and masib_sex=2));

array values exp_ASD exp_ID exp_SCH exp_SPD;
exp_EXT = max(of values[*]);
years=round(tte/365.25, 0.01);
censored=0;
if cens_type in ('D','E','F') then censored=1;
child_birth_yr=year(child_birth_dat);
dad_birth_yr=year(fab_dat);
aunt_birth_yr=year(sib_birth_dat);

run;


*-Calculate event from variable censored: 1=0, 0=1;
data cox_pasib; event=0; set cox_pasib; if censored=0 then event=1; run;
data cox_puncle; event=0; set cox_puncle; if censored=0 then event=1; run;
data cox_paunt; event=0; set cox_paunt; if censored=0 then event=1; run;

* Calculate person-years and ASD/AD rate by exposure: ASD paternal aunt/uncle;
proc sort data=cox_pasib; by outcome exp_ASD; run;
ods output summary=personyr_ASD_pasib;
proc means data=cox_pasib sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

* Calculate person-years and ASD/AD rate by exposure: AD paternal aunt/uncle;
proc sort data=cox_pasib; by outcome exp_AD; run;
ods output summary=personyr_AD_pasib;
proc means data=cox_pasib sum;
class exp_AD;
var years event;
by outcome exp_AD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/SCH/ID/SPD paternal aunt/uncle;
proc sort data=cox_pasib; by outcome exp_EXT; run;
ods output summary=personyr_EXT_pasib;
proc means data=cox_pasib sum;
class exp_EXT;
var years event;
by outcome exp_EXT;
run;


data personyr_pasib;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_pasib(in=personyr_ASD_pasib rename=(exp_ASD=exposed) drop=exp_ASD2) 
    personyr_AD_pasib(in=personyr_AD_pasib rename=(exp_AD=exposed) drop=exp_AD2)
    personyr_EXT_pasib(in=personyr_EXT_pasib rename=(exp_EXT=exposed) drop=exp_EXT2);
if personyr_ASD_pasib then exposure='ASD Paternl Aunt/Uncle';
else if personyr_AD_pasib then exposure='AD Paternl Aunt/Uncle';
else if personyr_EXT_pasib then exposure='ASD/ID/SZ/SPD Paternal Aunt/Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD paternal uncle;
proc sort data=cox_puncle; by outcome exp_ASD; run;
ods output summary=personyr_ASD_puncle;
proc means data=cox_puncle sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/AD paternal uncle;
proc sort data=cox_puncle; by outcome exp_AD; run;
ods output summary=personyr_AD_puncle;
proc means data=cox_puncle sum;
class exp_AD;
var years event;
by outcome exp_AD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/SCH/ID/SPD paternal uncle;
proc sort data=cox_puncle; by outcome exp_EXT; run;
ods output summary=personyr_EXT_puncle;
proc means data=cox_puncle sum;
class exp_EXT;
var years event;
by outcome exp_EXT;
run;

data personyr_puncle;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_puncle(in=personyr_ASD_puncle rename=(exp_ASD=exposed) drop=exp_ASD2) 
    personyr_AD_puncle(in=personyr_AD_puncle rename=(exp_AD=exposed) drop=exp_AD2)
	personyr_EXT_puncle(in=personyr_EXT_puncle rename=(exp_EXT=exposed) drop=exp_EXT2);
if personyr_ASD_puncle then exposure='ASD Paternl Uncle';
else if personyr_AD_puncle then exposure='AD Paternl Uncle';
else if personyr_EXT_puncle then exposure='ASD/ID/SZ/SPD Paternal Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD paternal aunt;
proc sort data=cox_paunt; by outcome exp_ASD; run;
ods output summary=personyr_ASD_paunt;
proc means data=cox_paunt sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/AD paternal aunt;
proc sort data=cox_paunt; by outcome exp_AD; run;
ods output summary=personyr_AD_paunt;
proc means data=cox_paunt sum;
class exp_AD;
var years event;
by outcome exp_AD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/SCH/ID/SPD paternal aunt;
proc sort data=cox_paunt; by outcome exp_EXT; run;
ods output summary=personyr_EXT_paunt;
proc means data=cox_paunt sum;
class exp_EXT;
var years event;
by outcome exp_EXT;
run;

data personyr_paunt;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_paunt(in=personyr_ASD_paunt rename=(exp_ASD=exposed) drop=exp_ASD2) 
    personyr_AD_paunt(in=personyr_AD_paunt rename=(exp_AD=exposed) drop=exp_AD2)
	personyr_EXT_paunt(in=personyr_EXT_paunt rename=(exp_EXT=exposed) drop=exp_EXT2);
if personyr_ASD_paunt then exposure='ASD Paternl Aunt';
else if personyr_AD_paunt then exposure='AD Paternl Aunt';
else if personyr_EXT_paunt then exposure='ASD/ID/SZ/SPD Paternal Aunt';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine all exposures together;
data personyr_paternal;
set personyr_pasib personyr_puncle personyr_paunt;
run;
proc sort data=personyr_paternal; by exposed outcome exposure ; run;
title 'Person-year printout for table 2';
proc print data=personyr_paternal; 
var outcome exposure exposed asd_n yr_fu asd_100k_py;
by exposed;
run;
title;

/**
data personyr2;
  set personyr;
  txt = put(yr_fu, 14.2) || ',' || put(asd_100k_py, 8.2) ;
run;

proc transpose data=personyr2 out=personyr3;
  var txt;
  id exposed;
  by outcome exposure ;
run;
**/

/**** Person-years for outcome ASD/AD by exposure ASD and by sex ******;
* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt/uncle;
proc sort data=cox_masib; by outcome child_sex exp_ASD; run;
ods output summary=personyr_ASD_masib_bysex;
proc means data=cox_masib sum;
class exp_ASD;
var years event;
by outcome child_sex exp_ASD;
run;

data personyr_ASD_masib_bysex;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_masib_bysex(in=personyr_ASD_masib rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Aunt/Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal uncle;
proc sort data=cox_muncle; by outcome child_sex exp_ASD; run;
ods output summary=personyr_ASD_muncle_bysex;
proc means data=cox_muncle sum;
class exp_ASD;
var years event;
by outcome child_sex exp_ASD;
run;

data personyr_ASD_muncle_bysex;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_muncle_bysex(in=personyr_ASD_muncle rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt;
proc sort data=cox_maunt; by outcome child_sex exp_ASD; run;
ods output summary=personyr_ASD_maunt_bysex;
proc means data=cox_maunt sum;
class exp_ASD;
var years event;
by outcome child_sex exp_ASD;
run;

data personyr_ASD_maunt_bysex;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_maunt_bysex(in=personyr_ASD_maunt rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Aunt';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine uncle, aunt, uncle/aunt together;
data personyr_ASD_bysex;
set personyr_ASD_pasib_bysex personyr_ASD_muncle_bysex personyr_ASD_maunt_bysex;
run;
proc sort data=personyr_ASD_bysex; by child_sex exposed outcome exposure ; run;
title 'Person-year printout for table 2';
proc print data=personyr_ASD_bysex; 
var outcome exposure exposed asd_n yr_fu asd_100k_py;
by child_sex exposed;
run;
title;


*/
