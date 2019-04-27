
*--------------------------------------------------------------------;
* Repeat main Cox regressions (12 RRs) on paternal uncle(s)/aunt(s)  ;
* Macros and formats from all1.sas are required                      ; 
* variable names 'MGM, MGP, masib' stay unchanged to adapt old codes ;
* After dm_1paternal, all maternal uncle(s)/aunt(s) bacome paternal  ;
* WARNING: No going back to maternal after running this program!!!   ;
*--------------------------------------------------------------------; 

%inc saspgm(dm_1paternal);   *-- This program selects participants and identify paternal uncle/aunt(s);
%inc saspgm(dm_2death_emigration); *-- This program adds censor time: date of death  and  date of emigration;
%inc saspgm(dm_3gt2yr);  *-- This program keeps children lived and not emigrated up to 2 years;
%inc saspgm(dm_4alldiag);  *-- This program derives ASD and all psychiatric diagnoses;
%inc saspgm(dm_5outcome); *-- This program adds outcome information to participants(offspring);
%inc saspgm(dm_6exp_masib); *-- This program adds exposure information to maternal uncle/aunt;
%inc saspgm(dm_7cov_mother); *-- This program adds psychiatric condition (covariates) to mothers;
%inc saspgm(dm_8cov_father); *-- This program adds psychiatric condition (covariates) to fathers;
%inc saspgm(dm_9tte); *-- This program adds time-to-event and censor information for analysis;

*------------------------------------------;
* Summary statistics                       ;
*------------------------------------------;
%inc saspgm(table1_paternal); *-- Table S? for the Appendix;
* %inc saspgm(dm_90clean); *-- !!! This program deletes datasets generated during data management (P3-5, S1-13, H0-4, Ana1-4);
*------------------------------------------;
* Statistical analyses                     ;
*------------------------------------------;
%inc saspgm(main_personyr_paternal); *-- Calculate person-year for all models (paternal side);
%inc saspgm(main_cox_paternal);  *-- Main Cox regressions;
%inc saspgm(sup_1bysex_p); *-- by sex;
%inc saspgm(sup_4boot_p); *-- Bootstrapped 95% CI for main Cox regressions (12RRs);
