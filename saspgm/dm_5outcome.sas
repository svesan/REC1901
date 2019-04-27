*--------------------------------------------------------------------------------;
* Add information about family psychiatric history                               ;
*--------------------------------------------------------------------------------;
*-Add ASD diagnosis for each child;
proc sort data=s10; by child; run;
data s11;
drop icd diag diag_dat any_psych condition;
merge s10 (in=s10) h4 (in=h4 rename=(lopnr=child asd=child_asd0));
by child;
if s10;
run;

data s11;
set s11;
if child_asd0 <.z then child_asd0=0;
run;

*-Outcome among children;
data ana0;
 length outcome $3;
 set s11;
 outcome='ASD';output;
 outcome='AD';output;
run;

proc sort data=ana0; by outcome child; run;
proc sort data=h2; by condition lopnr; run;
data ana1;
 drop icd diag any_psych asd;
 length event 3;
 merge ana0 (in=ana0) h2 (in=h2 rename=(lopnr=child condition=outcome diag_dat=child_diagdat) where=(outcome in ('ASD','AD')));
 by outcome child;
 if h2 then event=1; else event=0;
 if ana0;
run;


*For descriptive statistics: psychiatric conditions among participants;
proc sort data=ana1; by child; run;

*- ASD among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_ASD 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'ASD'));
 by child;
 if h2 then child_ASD=1; 
 else child_ASD=0;
 if ana1;
run;

*- AD among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_AD 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'AD'));
 by child;
 if h2 then child_AD=1; 
 else child_AD=0;
 if ana1;
run;

*- Asperger among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_AS 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'AS'));
 by child;
 if h2 then child_AS=1; 
 else child_AS=0;
 if ana1;
run;

*- PDD-NOS among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_PDD 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'PDD'));
 by child;
 if h2 then child_PDD=1; 
 else child_PDD=0;
 if ana1;
run;

*- Intellectual disability among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_ID 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'ID'));
 by child;
 if h2 then child_ID=1; 
 else child_ID=0;
 if ana1;
run;

*- Severe intellectual disability among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_SID 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'SID'));
 by child;
 if h2 then child_SID=1; 
 else child_SID=0;
 if ana1;
run;

*- Depression among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_DEP 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'DEP'));
 by child;
 if h2 then child_DEP=1; 
 else child_DEP=0;
 if ana1;
run;

*- Anxiety disorder among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_ANX 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'ANX'));
 by child;
 if h2 then child_ANX=1; 
 else child_ANX=0;
 if ana1;
run;

*- Substance use disorder among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_SUB 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'SUB'));
 by child;
 if h2 then child_SUB=1; 
 else child_SUB=0;
 if ana1;
run;

*- Bipolar disorder among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_BIP 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'BIP'));
 by child;
 if h2 then child_BIP=1; 
 else child_BIP=0;
 if ana1;
run;

*- Compulsive disorder among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_COM 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'COM'));
 by child;
 if h2 then child_COM=1; 
 else child_COM=0;
 if ana1;
run;

*- ADHD among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_ADH 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'ADH'));
 by child;
 if h2 then child_ADH=1; 
 else child_ADH=0;
 if ana1;
run;

*- Affective disorder among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_AFF 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'AFF'));
 by child;
 if h2 then child_AFF=1; 
 else child_AFF=0;
 if ana1;
run;

*- Schizophrenia among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_SCH 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'SCH'));
 by child;
 if h2 then child_SCH=1; 
 else child_SCH=0;
 if ana1;
run;

*- Schizoid personality disorder among participants;
data ana1;
 drop icd diag any_psych condition diag_dat asd;
 length child_SPD 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=child) where=(condition = 'SPD'));
 by child;
 if h2 then child_SPD=1; 
 else child_SPD=0;
 if ana1;
run;

*- Any mental illness among participants;
proc sort data=h3; by lopnr; run;
data ana1;
 drop icd diag any_psych diag_dat;
 length child_PSYCH 3;
 merge ana1 (in=ana1) h3 (in=h3 rename=(lopnr=child));
 by child;
 if h3 then child_PSYCH=1; 
 else child_PSYCH=0;
 if ana1;
run; 

*- 2019-03-10: 'Any mental illness other than ASD' among participants;
proc sort data=hnew; by lopnr; run;
data ana1;
 drop icd diag any_psych any_psych2 diag_dat;
 length child_PSYCH2 3;
 merge ana1 (in=ana1) hnew (in=hnew rename=(lopnr=child));
 by child;
 if hnew then child_PSYCH2=1; 
 else child_PSYCH2=0;
 if ana1;
run; 
