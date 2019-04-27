/**  
* Read in data:
data cox_masib; set temp.cox_masib;run;  
data cox_muncle; set temp.cox_muncle; run;
data cox_maunt; set temp.cox_maunt; run;
**/

**** Person-years for outcome ASD/AD by exposure AD  ******;
* Calculate person-years and ASD/AD rate by exposure: AD maternal aunt/uncle;
proc sort data=cox_masib; by outcome child_sex exp_AD; run;
ods output summary=personyr_AD_masib_bysex;
proc means data=cox_masib sum;
class exp_AD;
var years event;
by outcome child_sex exp_AD;
run;

data personyr_AD_masib_bysex;
drop vname_years vname_event ;
length exposure $30.;
set personyr_AD_masib_bysex(in=personyr_AD_masib rename=(exp_AD=exposed) drop=exp_AD2);
exposure='AD Maternl Aunt/Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: AD maternal uncle;
proc sort data=cox_muncle; by outcome child_sex exp_AD; run;
ods output summary=personyr_AD_muncle_bysex;
proc means data=cox_muncle sum;
class exp_AD;
var years event;
by outcome child_sex exp_AD;
run;

data personyr_AD_muncle_bysex;
drop vname_years vname_event ;
length exposure $30.;
set personyr_AD_muncle_bysex(in=personyr_AD_muncle rename=(exp_AD=exposed) drop=exp_AD2);
exposure='AD Maternl Uncle';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: AD maternal aunt;
proc sort data=cox_maunt; by outcome child_sex exp_AD; run;
ods output summary=personyr_AD_maunt_bysex;
proc means data=cox_maunt sum;
class exp_AD;
var years event;
by outcome child_sex exp_AD;
run;

data personyr_AD_maunt_bysex;
drop vname_years vname_event ;
length exposure $30.;
set personyr_AD_maunt_bysex(in=personyr_ASD_maunt rename=(exp_AD=exposed) drop=exp_AD2);
exposure='AD Maternl Aunt';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine uncle, aunt, uncle/aunt together;
data personyr_AD_bysex;
set personyr_AD_muncle_bysex personyr_AD_maunt_bysex personyr_AD_masib_bysex;
run;
proc sort data=personyr_AD_bysex; by child_sex exposed outcome; run;
title 'Person-year printout for table 2';
proc print data=personyr_AD_bysex; 
var outcome exposure exposed asd_n yr_fu asd_100k_py;
by child_sex exposed;
run;
title;
