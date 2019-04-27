*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) The subgroup analysis excludes children whose mother or uncle/aunt has any mental illness ;
*          other than ASD, i.e., excludes MOM_PYSCH2=1 or EXP_PYSCH2=1                               ;   
*----------------------------------------------------------------------------------------------------;
/*Read in data:
data cox_masib; set temp.cox_masib;run;
data cox_muncle; set temp.cox_muncle;run;
data cox_maunt; set temp.cox_maunt;run;
*/

data cox_masib_nopsych; set cox_masib (where=(exp_psych2 =0 & mom_psych2 = 0)); run;
data cox_muncle_nopsych; set cox_muncle (where=(exp_psych2 =0 & mom_psych2 = 0)); run;
data cox_maunt_nopsych; set cox_maunt (where=(exp_psych2 =0 & mom_psych2 = 0)); run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt/uncle;
proc sort data=cox_masib_nopsych; by outcome exp_ASD; run;
ods output summary=personyr_ASD_masib_nopsych;
proc means data=cox_masib_nopsych sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_masib_nopsych;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_masib_nopsych(rename=(exp_ASD=exposed) drop=exp_ASD2); 
exposure='ASD Maternl Aunt/Uncle: No Family History';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal uncle;
proc sort data=cox_muncle_nopsych; by outcome exp_ASD; run;
ods output summary=personyr_ASD_muncle_nopsych;
proc means data=cox_muncle_nopsych sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_muncle_nopsych;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_muncle_nopsych(rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Uncle: No Family History';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt;
proc sort data=cox_maunt_nopsych; by outcome exp_ASD; run;
ods output summary=personyr_ASD_maunt_nopsych;
proc means data=cox_maunt_nopsych sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_maunt_nopsych;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_maunt_nopsych(rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Aunt: No Family History';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine all exposures together;
data personyr_nopsych;
set personyr_muncle_nopsych personyr_maunt_nopsych personyr_masib_nopsych;
run;
proc sort data=personyr_nopsych; by exposed outcome; run;
title 'Person-year printout for eTable 3: No Family History';
proc print data=personyr_nopsych; 
var outcome exposure exposed asd_n yr_fu asd_100k_py;
by exposed;
run;
title;







**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**-------------------------------------------------------------------------------------;
** Subgroup analysis: oldest pair within family (maternal grandparents);
ods listing close;
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib_nopsych, out=estmasib_nopsych1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Crude);
%est_spl(data=cox_masib_nopsych, out=estmasib_nopsych2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0,  by=outcome, lbl=ASD Uncle or Aunt: Adjusted1);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle_nopsych, out=estmuncle_nopsych1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle: Crude);
%est_spl(data=cox_muncle_nopsych, out=estmuncle_nopsych2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=ASD Uncle: Adjusted1);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt_nopsych, out=estmaunt_nopsych1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Aunt: Crude);
%est_spl(data=cox_maunt_nopsych, out=estmaunt_nopsych2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=ASD Aunt: Adjusted1);
ods listing;

*- Combine all estimates in one;
data nopsych_cox_out;
length label $40.;
set estmuncle_nopsych1-estmuncle_nopsych2 estmaunt_nopsych1-estmaunt_nopsych2 estmasib_nopsych1-estmasib_nopsych2;
run;

proc sort data=nopsych_cox_out; by outcome; run;
proc print data=nopsych_cox_out; var outcome label expestimate lowerexp upperexp; run;

