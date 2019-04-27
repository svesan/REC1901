*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_masib, cox_muncle, cox_maunt   ;
*       2) For each family (mother), only the oldest offspring was selected                          ;
*       3) For each offspring selected in 2), only the oldest uncle/aunt was selected                ;   
*----------------------------------------------------------------------------------------------------;
/*Read in data:
data cox_masib; set temp.cox_masib;run;
data cox_muncle; set temp.cox_muncle;run;
data cox_maunt; set temp.cox_maunt;run;
*/

proc sort data=cox_masib; by outcome mother child_birth_yr sib_birth_yr; run;
proc sort data=cox_masib out=cox_masib1 nodupkey; by outcome mother child_birth_yr; run;
proc sort data=cox_masib1 out=cox_masib2 nodupkey; by outcome mother;run;  

proc sort data=cox_muncle; by outcome  mother child_birth_yr uncle_birth_yr; run;
proc sort data=cox_muncle out=cox_muncle1 nodupkey; by outcome mother child_birth_yr; run;
proc sort data=cox_muncle1 out=cox_muncle2 nodupkey; by outcome mother; run; 

proc sort data=cox_maunt; by outcome mother child_birth_yr aunt_birth_yr; run;
proc sort data=cox_maunt out=cox_maunt1 nodupkey; by outcome mother child_birth_yr; run;
proc sort data=cox_maunt1 out=cox_maunt2 nodupkey; by outcome mother;run; 

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt/uncle;
proc sort data=cox_masib1; by outcome exp_ASD; run;
ods output summary=personyr_ASD_masib1;
proc means data=cox_masib1 sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_masib1;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_masib1(rename=(exp_ASD=exposed) drop=exp_ASD2); 
exposure='ASD Maternl Aunt/Uncle: Oldest Pair';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal uncle;
proc sort data=cox_muncle1; by outcome exp_ASD; run;
ods output summary=personyr_ASD_muncle1;
proc means data=cox_muncle1 sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_muncle1;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_muncle1(in=personyr_ASD_muncle rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Uncle: Oldest Pair';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

* Calculate person-years and ASD/AD rate by exposure: ASD maternal aunt;
proc sort data=cox_maunt1; by outcome exp_ASD; run;
ods output summary=personyr_ASD_maunt1;
proc means data=cox_maunt1 sum;
class exp_ASD;
var years event;
by outcome exp_ASD;
run;

data personyr_maunt1;
drop vname_years vname_event ;
length exposure $40.;
set personyr_ASD_maunt1(in=personyr_ASD_maunt rename=(exp_ASD=exposed) drop=exp_ASD2);
exposure='ASD Maternl Aunt: Oldest Pair';
yr_fu=put(years_sum, comma15.2);
ASD_N=put(event_sum, comma8.);
ASD_100k_py=put(event_sum/years_sum*100000, comma8.2);
run;

*-Combine all exposures together;
data personyr1;
set personyr_masib1 personyr_muncle1 personyr_maunt1;
run;
proc sort data=personyr1; by exposed outcome exposure ; run;
title 'Person-year printout for eTable 3: Oldest Pair';
proc print data=personyr1; 
var outcome exposure exposed asd_n yr_fu asd_100k_py;
by exposed;
run;
title;


**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;
** Subgroup analysis: oldest pair within family (maternal grandparents);
ods listing close;
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib2, out=estmasib_old1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Crude);
%est_spl(data=cox_masib2, out=estmasib_old2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0,  by=outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib2, out=estmasib_old3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych,freq=0,  by=outcome, lbl=ASD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_masib2, out=estmasib_old4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle2, out=estmuncle_old1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle: Crude);
%est_spl(data=cox_muncle2, out=estmuncle_old2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=ASD Uncle: Adjusted1);
%est_spl(data=cox_muncle2, out=estmuncle_old3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, freq=0,by=outcome, lbl=ASD Uncle: Adjusted2);
%est_spl(data=cox_muncle2, out=estmuncle_old4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                          exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt2, out=estmaunt_old1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Aunt: Crude);
%est_spl(data=cox_maunt2, out=estmaunt_old2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=ASD Aunt: Adjusted1);
%est_spl(data=cox_maunt2, out=estmaunt_old3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=ASD Aunt: Adjusted);
%est_spl(data=cox_maunt2, out=estmaunt_old4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                       exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Aunt: Adjusted3);
ods listing;

*- Combine all estimates in one;
data oldest_cox_out;
length label $40.;
set estmuncle_old1-estmuncle_old4 estmaunt_old1-estmaunt_old4 estmasib_old1-estmasib_old4;
run;

proc sort data=oldest_cox_out; by outcome; run;
proc print data=oldest_cox_out; var outcome label expestimate lowerexp upperexp; run;

/*
*-Try youngest pair instead;

proc sort data=cox_masib; by outcome mother desending child_birth_yr descending sib_birth_yr; run;
proc sort data=cox_masib out=cox_masib1 nodupkey; by outcome mother desending child_birth_yr; run;
proc sort data=cox_masib1 out=cox_masib3 nodupkey; by outcome mother;run;  

proc sort data=cox_muncle; by outcome mother desending child_birth_yr desending uncle_birth_yr; run;
proc sort data=cox_muncle out=cox_muncle1 nodupkey; by outcome mother desending child_birth_yr; run;
proc sort data=cox_muncle1 out=cox_muncle3 nodupkey; by outcome mother; run; 

proc sort data=cox_maunt; by outcome mother desending child_birth_yr desending aunt_birth_yr; run;
proc sort data=cox_maunt out=cox_maunt1 nodupkey; by outcome mother desending child_birth_yr; run;
proc sort data=cox_maunt1 out=cox_maunt3 nodupkey; by outcome mother;run; 

**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), mother, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + mother's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + mother's specific psychs ; 
**-------------------------------------------------------------------------------------;
** Subgroup analysis: oldest pair within family (maternal grandparents);

*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
%est(data=cox_masib3, out=estmasib_young1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle or Aunt: Crude);
%est_spl(data=cox_masib3, out=estmasib_young2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=, freq=0,  by=outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_masib3, out=estmasib_young3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_psych exp_psych,freq=0,  by=outcome, lbl=ASD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_masib3, out=estmasib_young4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr sib_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                      exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_muncle2, out=estmuncle_young1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Uncle: Crude);
%est_spl(data=cox_muncle2, out=estmuncle_young2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=ASD Uncle: Adjusted1);
%est_spl(data=cox_muncle2, out=estmuncle_young3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_psych exp_psych, freq=0,by=outcome, lbl=ASD Uncle: Adjusted2);
%est_spl(data=cox_muncle2, out=estmuncle_young4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr uncle_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                          exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_maunt2, out=estmaunt_young1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Aunt: Crude);
%est_spl(data=cox_maunt2, out=estmaunt_young2, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=ASD Aunt: Adjusted1);
%est_spl(data=cox_maunt2, out=estmaunt_young3, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_psych exp_psych, freq=0, by=outcome, lbl=ASD Aunt: Adjusted2);
%est_spl(data=cox_maunt2, out=estmaunt_young4, exposure=exp_ASD, spline=child_birth_yr mom_birth_yr aunt_birth_yr, class=mom_id mom_dep mom_anx mom_sub mom_bip mom_com mom_adhd mom_aff mom_sch mom_spd 
                                                                                                                       exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Aunt: Adjusted3);

*- Combine all estimates in one;
data young_cox_out;
length label $40.;
set estmuncle_young1-estmuncle_young4 estmaunt_young1-estmaunt_young4 estmasib_young1-estmasib_young4;
run;

proc sort data=young_cox_out; by outcome; run;
proc print data=young_cox_out; var outcome label expestimate lowerexp upperexp; run;
*/
