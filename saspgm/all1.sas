*-----------------------------------------------------------------------------;
* Study.......: MIN1901/RECAP1901                                             ;
* Name........: all1.sas                                                      ;
* Date........: 2019-02-18                                                    ;
* Author......: danbai                                                        ;
* Purpose.....: This program runs all programs needed for analysing the study ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...:                                                               ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.04.01M4P110916                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;
*--- Initialize page with and height (43) for output etc;
options ls=130 ps=43 nodate nonumber nocenter source source2 msglevel=N
        notes dsnferr serror fmterr details
        mautosource nomstored mrecall
        nomacrogen nosymbolgen nomtrace nomlogic nomprint
        mergenoby=WARN validvarname=upcase
        formchar='|----|+|---+=|-//<>*'
;

*-- Create output formats. These lables will be PRINTED instead of the codes;
proc format;
  value masib  0='Paticipants with ASD-free uncle(s)/aunt(s)'
		       1='Paticipants with ASD-affected uncle(s)/aunt(s)';
  value muncle 0='Paticipants with ASD-free uncle(s)'
		       1='Paticipants with ASD-affected uncle(s)';
  value maunt  0='Paticipants with ASD-free aunt(s)'
		       1='Paticipants with ASD-affected aunt(s)';
  value sexfmt 1='Male' 2='Female';
  value yesno  1='Yes' 0='No';
  value MGload 0='Reference'
               1='Moderate'
			   2='High';
run;

*-- Main program -------------------------------------------------------------;
* On desktop;
libname study   'P:\0RECAP\0RECAP_Research\sasproj\REC\sasdsn\Data_from_SCB_SOS' access=readonly;
filename saspgm 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';

* On Matrix;
* filename saspgm '/nfs/projects/MINERVA/MIN/MIN1901/saspgm/';
filename log    '/home/workspace/projects/Minerva/Minerva_Research/sasproj/MIN/MIN1901/saslog';
filename result '/nfs/home/danbai/MIN1901/sasout/';
filename mall   '/home/workspace/projects/Minerva/Minerva_Research/sasproj/MIN/MIN1901/saspgm/mall.sas';
filename saspgm '/nfs/projects/0RECAP/REC/REC1901/saspgm';

*-- SAS macros ---------------------------------------------------------------;
%inc saspgm(allmacro);

*-- Allocate the database using this code on Unix/Linux, i.e. matrix;
libname study '/nfs/projects/0RECAP/REC/REC1901/sastmp' access = readonly ;
libname temp '/nfs/projects/0RECAP/REC/REC1901/temp';

*-- Allocate remove server work directory;
libname swork  slibref=work server=matrix;
libname sstudy slibref=study server=matrix;
libname stemp slibref=temp server=matrix;
*------------------------------------------;
* Data management                          ;
*------------------------------------------;

%inc saspgm(dm_1);   *-- This program selects participants and identify maternal uncle/aunt(s);
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
%inc saspgm(table1); *-- Table 1 for the manuscript;
* %inc saspgm(dm_90clean); *-- !!! This program deletes datasets generated during data management (P3-5, S1-13, H0-4, Ana1-4);

*------------------------------------------;
* Statistical analyses                     ;
*------------------------------------------;
%inc saspgm(main_personyr); *-- Calculate person-year for all models;
%inc saspgm(main_cox);  *-- Main Cox regressions;
%inc saspgm(sup_1bysex);  *-- Cox regression on subgroups: by participant's sex;
%inc saspgm(sup_2ext);  *-- Cox regression on extended exposure: a-ASD/SCH/ID b-ASD/SCH/ID/SPD;
%inc saspgm(sup_3cluster); *-- Cox regression stratified by a-mother b-grandfather and grandmother;
%inc saspgm(sup_4boot);    *-- Bootstrapped 95% CI for main Cox regressions;
%inc saspgm(sup_5paternal); *-- Repeat main Cox regressions on paternal uncle(s)/aunt(s); *!!!NO GOING BACK to MATERNAL after this!!!; 

proc print data=personyr; var exposure exposed yr_fu asd_n asd_100k_py; where outcome='ASD'; run; *--Print person-years by exposure;
proc print data=main_cox_out; var LABEL EXPESTIMATE LOWEREXP UPPEREXP; where outcome='ASD'; run; *-- Print main Cox results (12RRs) for ASD;
proc print data=main_cox_out; var LABEL EXPESTIMATE LOWEREXP UPPEREXP; where outcome='AD'; run; *-- Print main Cox results (12RRs) for AD;
proc print data=bysex_cox_out; var CHILD_SEX LABEL EXPESTIMATE LOWEREXP UPPEREXP; where outcome='ASD'; run; *-- Print by sex main Cox results (12RRs) ;
proc print data=ext_cox_out; var LABEL EXPESTIMATE LOWEREXP UPPEREXP; where outcome='ASD'; run; *-- Print main Cox results (12RRs) on extended exposure;
proc print data=cluster_cox_out;var LABEL EXPESTIMATE LOWEREXP UPPEREXP; where outcome='ASD'; run; *-- Print main Cox results (12RRs) stratified by mother or grandparents;
proc print data=boot_cox_out; var LABEL EXPESTIMATE LOWEREXP UPPEREXP BSLOWER BSUPPER; where outcome='ASD'; run; *-- Print main Cox results (12RRs) with bootstrapped 95% CI;

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
delete _null_;
quit;

*-- End of File --------------------------------------------------------------;













