*----------------------------------------------------------------------------------------------------;
* Supplementary analysis                                                                             ;
* Note: 1) The program runs after Cox_main and used the datasets: cox_pasib, cox_puncle, cox_paunt   ;
*       2) Macro 'est' is required for Cox model                                                     ;
*----------------------------------------------------------------------------------------------------;
*-------------------------------------------------------------------------------;
*  1 - Cox model, on offspring-uncle/aunt pair level, by offspring's sex        ;
*-------------------------------------------------------------------------------;
**-------------------------------------------------------------------------------------;
** Cox Model: 1) Crude HR                                                              ;
**            2) Adjusted: birth year of participant (offspring), father, uncle/aunt   ;
**            3) Adjusted: 2)+ uncle/aunt's any psych + father's any psych             ;
**            4) Adjusted: 2)+ uncle/aunt's specific psychs + father's specific psychs ; 
**-------------------------------------------------------------------------------------;
/* Read in data:
data cox_pasib; set temp.cox_pasib; run;
data cox_puncle; set temp.cox_puncle; run;
data cox_paunt; set temp.cox_paunt; run; */

ods listing close;
*- Exposure ASD affected aunt/uncle, by outcome: ASD and AD, in subgroups: male and female participants (offspring);

%est(data=cox_pasib, out=estpasib_bysex1, exposure=exp_ASD, class=, freq=0, by=child_sex outcome, lbl=ASD Uncle or Aunt: 0Crude);
%est_spl(data=cox_pasib, out=estpasib_bysex2, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr sib_birth_yr, class=, freq=0, by=child_sex outcome, lbl=ASD Uncle or Aunt: Adjusted1);
%est_spl(data=cox_pasib, out=estpasib_bysex3, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr sib_birth_yr, class=dad_psych exp_psych, 
              freq=0,by=child_sex outcome, lbl=ASD Uncle or Aunt: Adjusted2);
%est_spl(data=cox_pasib, out=estpasib_bysex4, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr sib_birth_yr, class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd 
                                                                                                                       exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
              freq=0, by=child_sex outcome, lbl=ASD Uncle or Aunt: Adjusted3);

*- Exposure ASD affected uncle, by outcome: ASD and AD, in subgroups: male and female participants (offspring);

%est(data=cox_puncle, out=estpuncle_bysex1, exposure=exp_ASD, class=, freq=0, by=child_sex outcome,lbl=1ASD Uncle: 0Crude);
%est_spl(data=cox_puncle, out=estpuncle_bysex2, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr uncle_birth_yr, class=, freq=0, by=child_sex outcome, lbl=1ASD Uncle: Adjusted1);
%est_spl(data=cox_puncle, out=estpuncle_bysex3, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr uncle_birth_yr, class=dad_psych exp_psych, 
         freq=0, by=child_sex outcome, lbl=1ASD Uncle: Adjusted2);
%est_spl(data=cox_puncle, out=estpuncle_bysex4, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr uncle_birth_yr, class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd 
                                                                                                                           exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=child_sex outcome, lbl=1ASD Uncle: Adjusted3);

*- Exposure ASD affected aunt, by outcome: ASD and AD, in subgroups: male and female participants (offspring);
%est(data=cox_paunt, out=estpaunt_bysex1, exposure=exp_ASD, class=, freq=0, by=child_sex outcome, lbl=ASD Aunt: 0Crude);
%est_spl(data=cox_paunt, out=estpaunt_bysex2, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr aunt_birth_yr, class=, freq=0, by=child_sex outcome, lbl=ASD Aunt: Adjusted1);
%est_spl(data=cox_paunt, out=estpaunt_bysex3, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr aunt_birth_yr, class=dad_psych exp_psych, 
         freq=0, by=child_sex outcome, lbl=ASD Aunt: Adjusted2);
%est_spl(data=cox_paunt, out=estpaunt_bysex4, exposure=exp_ASD, spline=child_birth_yr dad_birth_yr aunt_birth_yr, class=dad_id dad_dep dad_anx dad_sub dad_bip dad_com dad_adhd dad_aff dad_sch dad_spd 
                                                                                                                        exp_id exp_dep exp_anx exp_sub exp_bip exp_com exp_adhd exp_aff exp_sch exp_spd, 
         freq=0, by=child_sex outcome, lbl=ASD Aunt: Adjusted3);
ods listing;

*- 2019-04-09: save estimates to temp folder;
data temp.estpasib_bysex1; set estpasib_bysex1; run;
data temp.estpasib_bysex2; set estpasib_bysex2; run;
data temp.estpasib_bysex3; set estpasib_bysex3; run;
data temp.estpasib_bysex4; set estpasib_bysex4; run;
data temp.estpuncle_bysex1; set estpuncle_bysex1; run;
data temp.estpuncle_bysex2; set estpuncle_bysex2; run;
data temp.estpuncle_bysex3; set estpuncle_bysex3; run;
data temp.estpuncle_bysex4; set estpuncle_bysex4; run;
data temp.estpaunt_bysex1; set estpaunt_bysex1; run;
data temp.estpaunt_bysex2; set estpaunt_bysex2; run;
data temp.estpaunt_bysex3; set estpaunt_bysex3; run;
data temp.estpaunt_bysex4; set estpaunt_bysex4; run;

*- Combine all estimates in one;
data bysex_cox_out_P;
length label $30.;
set estpasib_bysex1-estpasib_bysex4 estpuncle_bysex1-estpuncle_bysex4 estpaunt_bysex1-estpaunt_bysex4;
run;

proc sort data=bysex_cox_out_P; by descending outcome child_sex label;run;
proc print data=bysex_cox_out_P; var outcome child_sex label expestimate lowerexp upperexp; by descending outcome; run;


