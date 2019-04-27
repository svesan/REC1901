*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) The subgroup analysis excludes children whose mother has ASD i.e., excludes MOM_ASD=1     ;
*----------------------------------------------------------------------------------------------------;
/*Read in data:
data cox_masib; set temp.cox_masib;run;
data cox_muncle; set temp.cox_muncle;run;
data cox_maunt; set temp.cox_maunt;run;
*Check if there's missing for mom_ASD:
proc freq data=cox_masib; table mom_ASD/missprint; run;
*/

data cox_masib_noASDmom; set cox_masib (where=(mom_ASD =0)); run;
data cox_muncle_noASDmom; set cox_muncle (where=(mom_ASD =0)); run;
data cox_maunt_noASDmom; set cox_maunt (where=(mom_ASD =0)); run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt/uncle;
proc sort data=cox_masib_noASDmom; by outcome exp_ASD; run;
ods output summary=personyr_ASD_masib_noASDmom;
proc means data=cox_masib_noASDmom sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_masib_noASDmom;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_masib_noASDmom(rename=(exp_ASD=exposed) drop=exp_ASD2); 
exposure='ASD Maternl Aunt/Uncle: ASD-free mothers';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal uncle;
proc sort data=cox_muncle_noASDmom; by outcome exp_ASD; run;
ods output summary=personyr_ASD_muncle_noASDmom;
proc means data=cox_muncle_noASDmom sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_muncle_noASDmom;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_muncle_noASDmom(rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Uncle: ASD-free mothers';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt;
proc sort data=cox_maunt_noASDmom; by outcome exp_ASD; run;
ods output summary=personyr_ASD_maunt_noASDmom;
proc means data=cox_maunt_noASDmom sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_maunt_noASDmom;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_maunt_noASDmom(rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Aunt: ASD-free mothers';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine all exposures together;
data personyr_noASDmom;
set personyr_muncle_noASDmom personyr_maunt_noASDmom personyr_masib_noASDmom;
run;
proc sort data=personyr_noASDmom; by exposed outcome; run;
title 'Person-year printout for eTable 3: ASD-free mothers';
proc print data=personyr_noASDmom; 
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
%est(data=cox_masib_noASDmom, out=estmasib_noASDmom1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Crude);
%est_spl(data=cox_masib_noASDmom, out=estmasib_noASDmom2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0,  by=outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib_noASDmom, out=estmasib_noASDmom3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted2);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle_noASDmom, out=estmuncle_noASDmom1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle: Crude);
%est_spl(data=cox_muncle_noASDmom, out=estmuncle_noASDmom2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=ASD Uncle: Adjusted1);
%est_spl(data=cox_muncle_noASDmom, out=estmuncle_noASDmom3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=ASD Uncle: Adjusted2);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt_noASDmom, out=estmaunt_noASDmom1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Aunt: Crude);
%est_spl(data=cox_maunt_noASDmom, out=estmaunt_noASDmom2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=ASD Aunt: Adjusted1);
%est_spl(data=cox_maunt_noASDmom, out=estmaunt_noASDmom3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=ASD Aunt: Adjusted2);

ods listing;

*- Combine all estimates in one;
data noASDmom_cox_out;
length label $40.;
set estmuncle_noASDmom1-estmuncle_noASDmom3 estmaunt_noASDmom1-estmaunt_noASDmom3 estmasib_noASDmom1-estmasib_noASDmom3;
run;

proc sort data=noASDmom_cox_out; by outcome; run;
proc print data=noASDmom_cox_out; var outcome label expestimate lowerexp upperexp; run;

