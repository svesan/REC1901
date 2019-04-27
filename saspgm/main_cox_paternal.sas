*--------------------------------------------------------------------------------;
* Main analysis: Cox model, on offspring-uncle/aunt pair level                   ;
*--------------------------------------------------------------------------------;

**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), father, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + father's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + father's specific psychs ; 
**-------------------------------------------------------------------------------------;
/* 
data cox_pasib;set temp.cox_pasib;run;
data cox_puncle;set temp.cox_puncle;run;
data cox_paunt;set temp.cox_paunt;run; 
*/

*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD;
ods listing close;
%est(data=cox_pasib, out=estpasib1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Paternal Uncle or Aunt: 0Crude);
%est_spl(data=cox_pasib, out=estpasib2, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr sib_birth_yr, class=, freq=0, by=outcome, lbl=ASD Paternal Uncle or Aunt: Adjusted1);
%est_spl(data=cox_pasib, out=estpasib3, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr sib_birth_yr, class=dad_psych exp_psych,freq=0, by=outcome, lbl=ASD Paternal Uncle or Aunt: Adjusted2 );
%est_spl(data=cox_pasib, out=estpasib4, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr sib_birth_yr, class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd 
                                                                                                                 exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Paternal Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD;
%est(data=cox_puncle, out=estpuncle1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=ASD Paternal Uncle: 0Crude);
%est_spl(data=cox_puncle, out=estpuncle2, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr uncle_birth_yr, class=, freq=0, by=outcome, lbl=ASD Paternal Uncle: Adjusted1);
%est_spl(data=cox_puncle, out=estpuncle3, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr uncle_birth_yr, class=dad_psych exp_psych, freq=0, by=outcome, lbl=ASD Paternal Uncle: Adjusted2);
%est_spl(data=cox_puncle, out=estpuncle4, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr uncle_birth_yr, class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd 
                                                                                                                     exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=ASD Paternal Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD;
%est(data=cox_paunt, out=estpaunt1, exposure=exp_ASD, class=, freq=0, by=outcome, lbl=1ASD Paternal Aunt: 0Crude);
%est_spl(data=cox_paunt, out=estpaunt2, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr aunt_birth_yr, class=, freq=0, by=outcome, lbl=1ASD Paternal Aunt: Adjusted1);
%est_spl(data=cox_paunt, out=estpaunt3, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr aunt_birth_yr, class=dad_psych exp_psych, freq=0, by=outcome, lbl=1ASD Paternal Aunt: Adjusted2);
%est_spl(data=cox_paunt, out=estpaunt4, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr aunt_birth_yr, class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd 
                                                                                                                  exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=outcome, lbl=1ASD Paternal Aunt: Adjusted3);
ods listing;


*- Combine all estimates in one;
data main_cox_paternalout;
length label $40.;
set estpasib1-estpasib4 estpuncle1-estpuncle4 estpaunt1-estpaunt4;
run;

proc sort data=main_cox_paternalout; by outcome label;run;
proc print data=main_cox_paternalout; var outcome label expestimate lowerexp upperexp; run;

data temp.cox_pasib; set cox_pasib; run;
data temp.cox_puncle; set cox_puncle; run;
data temp.cox_paunt; set cox_paunt; run;

/*- Analysis on collapsed data;
proc summary data=Cox_masib nway;
var years;
class child_birth_yr dad_birth_yr sib_birth_yr outcome exp_ASD years censored dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd
    exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd;
output out=Cox_masib_agg n=n;
run;

%est(data=Cox_masib_agg, out=testout1, freq=_freq_, exposure=exp_ASD, class=, by=outcome, lbl=ASD Uncle or Aunt);*/

/** Bootstrap 1000 times for 95% CI: Main Cox regressions; **/
**-Paternal uncle/aunt;
%bootp(data=cox_pasib,out=agg_pasib_boot,exp_by=sib_birth_yr, Npatch=10,reps=100,temp=0); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

%bootcox(data=agg_pasib_boot, coxout=estpasib_boot1, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Paternal Uncle/Aunt Crude);
%bootcox(data=agg_pasib_boot, coxout=estpasib_boot2, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr dad_birth_yr sib_birth_yr,  id=, lbl=ASD Paternal Uncle/Aunt Adjust1);
%bootcox(data=agg_pasib_boot, coxout=estpasib_boot3, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=dad_psych exp_psych, freq=n, 
         spline=child_birth_yr dad_birth_yr sib_birth_yr,  id=, lbl=ASD Paternal Uncle/Aunt Adjust2);
%bootcox(data=agg_pasib_boot, coxout=estpasib_boot4, Npatch=10, by=sampleID outcome, exposure=exp_ASD, freq=n,
         class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr dad_birth_yr sib_birth_yr,  id=, lbl=ASD Paternal Uncle/Aunt Adjust3);
proc datasets lib=work mt=all nolist;delete agg_pasib_boot1-agg_pasib_boot10; quit;

**-Paternal uncle;
%bootp(data=cox_puncle,out=agg_puncle_boot,exp_by=uncle_birth_yr, Npatch=10,reps=100,temp=0); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

%bootcox(data=agg_puncle_boot, coxout=estpuncle_boot1, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Paternal Uncle Crude);
%bootcox(data=agg_puncle_boot, coxout=estpuncle_boot2, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr dad_birth_yr uncle_birth_yr,  id=, lbl=ASD Paternal Uncle Adjust1);
%bootcox(data=agg_puncle_boot, coxout=estpuncle_boot3, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=dad_psych exp_psych, freq=n, 
         spline=child_birth_yr dad_birth_yr uncle_birth_yr,  id=, lbl=ASD Paternal Uncle Adjust2);
%bootcox(data=agg_puncle_boot, coxout=estpuncle_boot4, Npatch=10, by=sampleID outcome, exposure=exp_ASD, freq=n,
         class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr dad_birth_yr uncle_birth_yr,  id=, lbl=ASD Paternal Uncle Adjust3);
proc datasets lib=work mt=all nolist;delete agg_puncle_boot1-agg_puncle_boot10; quit;

**-Paternal aunt;
%bootp(data=cox_paunt,out=agg_paunt_boot,exp_by=aunt_birth_yr, Npatch=10,reps=100,temp=0); /*Bootstrap and aggregate 10 patches, each 100 resamples, total 1000 resamples*/

%bootcox(data=agg_paunt_boot, coxout=estpaunt_boot1, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, spline=0, id=, lbl=ASD Paternal Aunt Crude);
%bootcox(data=agg_paunt_boot, coxout=estpaunt_boot2, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=, freq=n, 
         spline=child_birth_yr dad_birth_yr aunt_birth_yr,  id=, lbl=ASD Paternal Aunt Adjust1);
%bootcox(data=agg_paunt_boot, coxout=estpaunt_boot3, Npatch=10, by=sampleID outcome, exposure=exp_ASD, class=dad_psych exp_psych, freq=n, 
         spline=child_birth_yr dad_birth_yr aunt_birth_yr,  id=, lbl=ASD Paternal Aunt Adjust2);
%bootcox(data=agg_paunt_boot, coxout=estpaunt_boot4, Npatch=10, by=sampleID outcome, exposure=exp_ASD, freq=n,
         class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd,  
         spline=child_birth_yr dad_birth_yr aunt_birth_yr,  id=, lbl=ASD Paternal Aunt Adjust3);
proc datasets lib=work mt=all nolist;delete agg_paunt_boot1-agg_paunt_boot10; quit;

/** Calculate 95%CI from bootstrapped estimates and add to the raw estimates; **/
data estpaunt_boot1; set temp.estpaunt_boot1; run;
data estpaunt_boot2; set temp.estpaunt_boot2; run;
data estpaunt_boot3; set temp.estpaunt_boot3; run;
data estpaunt_boot4; set temp.estpaunt_boot4; run;

data estpuncle_boot1; set temp.estpuncle_boot1; run;
data estpuncle_boot2; set temp.estpuncle_boot2; run;
data estpuncle_boot3; set temp.estpuncle_boot3; run;
data estpuncle_boot4; set temp.estpuncle_boot4; run;

data estpasib_boot1; set temp.estpasib_boot1; run;
data estpasib_boot2; set temp.estpasib_boot2; run;
data estpasib_boot3; set temp.estpasib_boot3; run;
data estpasib_boot4; set temp.estpasib_boot4; run;

*-Main Cox results (12RR) + bootstrapped (1000 resamples) 95% CI, by outcome AD/ASD;
*-Exposure ASD maternal uncle;
%addboot (data=estpuncle1, boot=estpuncle_boot1, out=estpuncle_addbs1, by=outcome);
%addboot (data=estpuncle2, boot=estpuncle_boot2, out=estpuncle_addbs2, by=outcome);
%addboot (data=estpuncle3, boot=estpuncle_boot3, out=estpuncle_addbs3, by=outcome);
%addboot (data=estpuncle4, boot=estpuncle_boot4, out=estpuncle_addbs4, by=outcome);
*-Exposure ASD maternal aunt;
%addboot (data=estpaunt1, boot=estpaunt_boot1, out=estpaunt_addbs1, by=outcome);
%addboot (data=estpaunt2, boot=estpaunt_boot2, out=estpaunt_addbs2, by=outcome);
%addboot (data=estpaunt3, boot=estpaunt_boot3, out=estpaunt_addbs3, by=outcome);
%addboot (data=estpaunt4, boot=estpaunt_boot4, out=estpaunt_addbs4, by=outcome);
*-Exposure ASD maternal uncle/aunt;
%addboot (data=estpasib1, boot=estpasib_boot1, out=estpasib_addbs1, by=outcome);
%addboot (data=estpasib2, boot=estpasib_boot2, out=estpasib_addbs2, by=outcome);
%addboot (data=estpasib3, boot=estpasib_boot3, out=estpasib_addbs3, by=outcome);
%addboot (data=estpasib4, boot=estpasib_boot4, out=estpasib_addbs4, by=outcome);

*- Combine estimates in one and print for tables;
/** Main cox 12RR, exp_ASD by outcome ASD/AD **/
data boot_cox_out_paternal;
length label $40.;
set estpuncle_addbs1-estpuncle_addbs4 estpaunt_addbs1-estpaunt_addbs4 estpasib_addbs1-estpasib_addbs4 
;
run;
proc sort data=boot_cox_out_paternal; by outcome label;run;
proc print data=boot_cox_out_paternal; var outcome label bscitxt;run;
