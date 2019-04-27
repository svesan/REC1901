/**  
* Note: Cox_mXX datasets have more variables, but the Forbs_mXX datasets have exp_EXT and all covariates used in the models;
data cox_masib; set temp.cox_masib;run;  
data cox_muncle; set temp.cox_muncle; run;
data cox_maunt; set temp.cox_maunt; run;
**/

*-Read in analytic datasets from the 'temp' library; 
data cox_masib; set temp.forbs_masib;run;  
data cox_muncle; set temp.forbs_muncle; run;
data cox_maunt; set temp.forbs_maunt; run;
*-Calculate event from variable censored: 1=0, 0=1;
data cox_masib; event=0; set cox_masib; if censored=0 then event=1; run;
data cox_muncle; event=0; set cox_muncle; if censored=0 then event=1; run;
data cox_maunt; event=0; set cox_maunt; if censored=0 then event=1; run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt/uncle;
proc sort data=cox_masib; by outcome exp_ASD; run;
ods output summary=personyr_ASD_masib;
proc means data=cox_masib sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

* Calculate person-years and ASD/AD rate by exposure: AD maternal aunt/uncle;
proc sort data=cox_masib; by outcome exp_AD; run;
ods output summary=personyr_AD_masib;
proc means data=cox_masib sum;
class exp_AD;
var years event;
by outcome exp_AD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/SCH/ID/SPD maternal aunt/uncle;
proc sort data=cox_masib; by outcome exp_EXT; run;
ods output summary=personyr_EXT_masib;
proc means data=cox_masib sum;
class exp_EXT;
var years event;
by outcome exp_EXT;
run;


data personyr_masib;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_masib(in=personyr_ASD_masib rename=(exp_ASD=exposed) drop=exp_ASD2) 
    personyr_AD_masib(in=personyr_AD_masib rename=(exp_AD=exposed) drop=exp_AD2)
    personyr_EXT_masib(in=personyr_EXT_masib rename=(exp_EXT=exposed) drop=exp_EXT2);
if personyr_ASD_masib then exposure='ASD Maternl Aunt/Uncle';
else if personyr_AD_masib then exposure='AD Maternl Aunt/Uncle';
else if personyr_EXT_masib then exposure='ASD/ID/SZ/SPD Aunt/Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal uncle;
proc sort data=cox_muncle; by outcome exp_ASD; run;
ods output summary=personyr_ASD_muncle;
proc means data=cox_muncle sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

* Calculate person-years and ASD/AD rate by exposure: AD maternal uncle;
proc sort data=cox_muncle; by outcome exp_AD; run;
ods output summary=personyr_AD_muncle;
proc means data=cox_muncle sum;
class exp_AD;
var years event;
by outcome exp_AD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/SCH/ID/SPD maternal uncle;
proc sort data=cox_muncle; by outcome exp_EXT; run;
ods output summary=personyr_EXT_muncle;
proc means data=cox_muncle sum;
class exp_EXT;
var years event;
by outcome exp_EXT;
run;

data personyr_muncle;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_muncle(in=personyr_ASD_muncle rename=(exp_ASD=exposed) drop=exp_ASD2) 
    personyr_AD_muncle(in=personyr_AD_muncle rename=(exp_AD=exposed) drop=exp_AD2)
	personyr_EXT_muncle(in=personyr_EXT_muncle rename=(exp_EXT=exposed) drop=exp_EXT2);
if personyr_ASD_muncle then exposure='ASD Maternl Uncle';
else if personyr_AD_muncle then exposure='AD Maternl Uncle';
else if personyr_EXT_muncle then exposure='ASD/ID/SZ/SPD Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt;
proc sort data=cox_maunt; by outcome exp_ASD; run;
ods output summary=personyr_ASD_maunt;
proc means data=cox_maunt sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

* Calculate person-years and ASD/AD rate by exposure: AD maternal aunt;
proc sort data=cox_maunt; by outcome exp_AD; run;
ods output summary=personyr_AD_maunt;
proc means data=cox_maunt sum;
class exp_AD;
var years event;
by outcome exp_AD;
run;

* Calculate person-years and ASD/AD rate by exposure: ASD/SCH/ID/SPD maternal aunt;
proc sort data=cox_maunt; by outcome exp_EXT; run;
ods output summary=personyr_EXT_maunt;
proc means data=cox_maunt sum;
class exp_EXT;
var years event;
by outcome exp_EXT;
run;

data personyr_maunt;
drop vname_years vname_event ;
length exposure $30.;
set personyr_ASD_maunt(in=personyr_ASD_maunt rename=(exp_ASD=exposed) drop=exp_ASD2) 
    personyr_AD_maunt(in=personyr_AD_maunt rename=(exp_AD=exposed) drop=exp_AD2)
	personyr_EXT_maunt(in=personyr_EXT_maunt rename=(exp_EXT=exposed) drop=exp_EXT2);
if personyr_ASD_maunt then exposure='ASD Maternl Aunt';
else if personyr_AD_maunt then exposure='AD Maternl Aunt';
else if personyr_EXT_maunt then exposure='ASD/ID/SZ/SPD Aunt';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine all exposures together;
data personyr;
set personyr_masib personyr_muncle personyr_maunt;
run;
proc sort data=personyr; by exposed outcome exposure ; run;
title 'Person-year printout for table 2';
proc print data=personyr; 
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

**** Person-years for outcome ASD/AD by exposure ASD  ******;
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
set personyr_ASD_masib_bysex personyr_ASD_muncle_bysex personyr_ASD_maunt_bysex;
run;
proc sort data=personyr_ASD_bysex; by child_sex exposed outcome exposure ; run;
title 'Person-year printout for table 2';
proc print data=personyr_ASD_bysex; 
var outcome exposure exposed asd_n yr_fu asd_100k_py;
by child_sex exposed;
run;
title;



*Reverse Kaplan-Meier curves by exposure;
%km (data=cox_masib (where=(outcome='ASD')), outcome=ASD, exposure=exp_ASD, lbl=Maternal Aunt or Uncle, max=0.08, expfmt=masib.);
*%km (data=cox_muncle(where=(outcome='ASD')), outcome=ASD, exposure=exp_ASD, lbl=Maternal Uncle, max=0.08, expfmt=muncle.);
*%km (data=cox_maunt (where=(outcome='ASD')), outcome=ASD, exposure=exp_ASD, lbl=Maternal Aunt, max=0.08, expfmt=maunt.);
%km (data=cox_masib (where=(outcome='AD')), outcome=AD, exposure=exp_ASD, lbl=Maternal Aunt or Uncle, max=0.06, expfmt=masib.);
*%km (data=cox_muncle(where=(outcome='AD')), outcome=AD, exposure=exp_ASD, lbl=Maternal Uncle, max=0.06, expfmt=muncle.);
*%km (data=cox_maunt (where=(outcome='AD')), outcome=AD, exposure=exp_ASD, lbl=Maternal Aunt, max=0.06, expfmt=maunt.);
