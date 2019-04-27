*--------------------------------------------------------------------------------;
* Add information about family psychiatric history                               ;
*--------------------------------------------------------------------------------;

*-Exposure: ASD conditions among mother's siblings + Covariate: psychiatric conditions among mother's siblings;
proc sort data=ana1; by masib; run;
proc sort data=h2; by lopnr; run;

*- ASD among mother's siblings;
data ana2;
 drop icd diag any_psych condition asd;
 length exp_ASD 3;
 merge ana1 (in=ana1) h2 (in=h2 rename=(lopnr=masib diag_dat=masib_diagdat) where=(condition = 'ASD'));
 by masib;
 * if h2 then exp_ASD=1; 
 if h2 and masib_diagdat lt child_birth_dat then exp_ASD=1; **Select those diagnosed before child's birth date**;
 else exp_ASD=0;
 if ana1;
run;

*- AD among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_AD 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'AD'));
 by masib;
 * if h2 then exp_AD=1; 
 if h2 and diag_dat lt child_birth_dat then exp_AD=1; **Select those diagnosed before child's birth date**;
 else exp_AD=0;
 if ana2;
run;

*- Asperger among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_AS 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'AS'));
 by masib;
 * if h2 then exp_AS=1; 
 if h2 and diag_dat lt child_birth_dat then exp_AS=1; **Select those diagnosed before child's birth date**;
 else exp_AS=0;
 if ana2;
run; 

*- PDD-NOS among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_PDD 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'PDD'));
 by masib;
 * if h2 then exp_PDD=1; 
 if h2 and diag_dat lt child_birth_dat then exp_PDD=1; **Select those diagnosed before child's birth date**;
 else exp_PDD=0;
 if ana2;
run; 

*- Intellectual disability among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_ID 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'ID'));
 by masib;
 * if h2 then exp_ID=1; 
 if h2 and diag_dat lt child_birth_dat then exp_ID=1; **Select those diagnosed before child's birth date**;
 else exp_ID=0;
 if ana2;
run; 

*- Severe intellectual disability among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_SID 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'SID'));
 by masib;
 * if h2 then exp_SID=1; 
 if h2 and diag_dat lt child_birth_dat then exp_SID=1; **Select those diagnosed before child's birth date**;
 else exp_SID=0;
 if ana2;
run; 

*- Depression among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_DEP 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'DEP'));
 by masib;
 * if h2 then exp_DEP=1; 
 if h2 and diag_dat lt child_birth_dat then exp_DEP=1; **Select those diagnosed before child's birth date**;
 else exp_DEP=0;
 if ana2;
run; 

*- Anxiety disorder among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_ANX 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'ANX'));
 by masib;
 * if h2 then exp_ANX=1; 
 if h2 and diag_dat lt child_birth_dat then exp_ANX=1; **Select those diagnosed before child's birth date**;
 else exp_ANX=0;
 if ana2;
run; 

*- Substance use disorder among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_SUB 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'SUB'));
 by masib;
 * if h2 then exp_SUB=1; 
 if h2 and diag_dat lt child_birth_dat then exp_SUB=1; **Select those diagnosed before child's birth date**;
 else exp_SUB=0;
 if ana2;
run; 

*- Bipolar disorder among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_BIP 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'BIP'));
 by masib;
 * if h2 then exp_BIP=1; 
 if h2 and diag_dat lt child_birth_dat then exp_BIP=1; **Select those diagnosed before child's birth date**;
 else exp_BIP=0;
 if ana2;
run; 

*- Compulsive disorder among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_COM 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'COM'));
 by masib;
 * if h2 then exp_COM=1; 
 if h2 and diag_dat lt child_birth_dat then exp_COM=1; **Select those diagnosed before child's birth date**;
 else exp_COM=0;
 if ana2;
run; 

*- ADHD among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_ADHD 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'ADH'));
 by masib;
 * if h2 then exp_ADHD=1; 
 if h2 and diag_dat lt child_birth_dat then exp_ADHD=1; **Select those diagnosed before child's birth date**;
 else exp_ADHD=0;
 if ana2;
run; 

*- Affective disorder among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_AFF 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'AFF'));
 by masib;
 * if h2 then exp_AFF=1; 
 if h2 and diag_dat lt child_birth_dat then exp_AFF=1; **Select those diagnosed before child's birth date**;
 else exp_AFF=0;
 if ana2;
run; 

*- Schizophrenia among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_SCH 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'SCH'));
 by masib;
 * if h2 then exp_SCH=1; 
 if h2 and diag_dat lt child_birth_dat then exp_SCH=1; **Select those diagnosed before child's birth date**;
 else exp_SCH=0;
 if ana2;
run; 

*- Schizoid personality disorder among mother's siblings;
data ana2;
 drop icd diag any_psych condition diag_dat asd;
 length exp_SPD 3;
 merge ana2 (in=ana2) h2 (in=h2 rename=(lopnr=masib) where=(condition = 'SPD'));
 by masib;
 * if h2 then exp_SPD=1; 
 if h2 and diag_dat lt child_birth_dat then exp_SPD=1; **Select those diagnosed before child's birth date**;
 else exp_SPD=0;
 if ana2;
run; 

*- Any mental illness among mother's siblings;
proc sort data=h3; by lopnr; run;
data ana2;
 drop icd diag any_psych diag_dat;
 length exp_PSYCH 3;
 merge ana2 (in=ana2) h3 (in=h3 rename=(lopnr=masib));
 by masib;
 * if h3 then exp_PSYCH=1; 
 if h3 and diag_dat lt child_birth_dat then exp_PSYCH=1; **Select those diagnosed before child's birth date**;
 else exp_PSYCH=0;
 if ana2;
run; 

*- 2019-03-10: 'Any mental illness other than ASD' among mother's siblings;
proc sort data=hnew; by lopnr; run;
data ana2;
 drop icd diag any_psych2 any_psych diag_dat;
 length exp_PSYCH2 3;
 merge ana2 (in=ana2) hnew (in=hnew rename=(lopnr=masib));
 by masib;
 if hnew and diag_dat lt child_birth_dat then exp_PSYCH2=1; **Select those diagnosed before child's birth date**;
 else exp_PSYCH2=0;
 if ana2;
run; 
