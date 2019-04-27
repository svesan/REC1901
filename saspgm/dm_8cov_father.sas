*--------------------------------------------------------------------------------;
* Add information about family psychiatric history                               ;
*--------------------------------------------------------------------------------;



*-Exposure: ASD conditions among fathers + Covariate: psychiatric conditions among fathers;
proc sort data=ana3; by father; run;

*- ASD among fathers;
data ana4;
 drop icd diag any_psych condition asd;
 length dad_ASD 3;
 merge ana3 (in=ana3) h2 (in=h2 rename=(lopnr=father diag_dat=dad_diagdat) where=(condition = 'ASD'));
 by father;
 * if h2 then dad_ASD=1; 
 if h2 and dad_diagdat lt child_birth_dat then dad_ASD=1; **Select those diagnosed before child's birth date**;
 else dad_ASD=0;
 if ana3;
run;

*- AD among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_AD 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'AD'));
 by father;
 * if h2 then dad_AD=1; 
 if h2 and diag_dat lt child_birth_dat then dad_AD=1; **Select those diagnosed before child's birth date**;
 else dad_AD=0;
 if ana4;
run;

*- Asperger among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_AS 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'AS'));
 by father;
 * if h2 then dad_AS=1; 
 if h2 and diag_dat lt child_birth_dat then dad_AS=1; **Select those diagnosed before child's birth date**;
 else dad_AS=0;
 if ana4;
run; 

*- PDD-NOS among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_PDD 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'PDD'));
 by father;
 * if h2 then dad_PDD=1; 
 if h2 and diag_dat lt child_birth_dat then dad_PDD=1; **Select those diagnosed before child's birth date**;
 else dad_PDD=0;
 if ana4;
run; 

*- Intellectual disability among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_ID 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'ID'));
 by father;
 * if h2 then dad_ID=1; 
 if h2 and diag_dat lt child_birth_dat then dad_ID=1; **Select those diagnosed before child's birth date**;
 else dad_ID=0;
 if ana4;
run; 

*- Severe intellectual disability among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_SID 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'SID'));
 by father;
 * if h2 then dad_SID=1; 
 if h2 and diag_dat lt child_birth_dat then dad_SID=1; **Select those diagnosed before child's birth date**;
 else dad_SID=0;
 if ana4;
run; 

*- Depression among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_DEP 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'DEP'));
 by father;
 * if h2 then dad_DEP=1; 
 if h2 and diag_dat lt child_birth_dat then dad_DEP=1; **Select those diagnosed before child's birth date**;
 else dad_DEP=0;
 if ana4;
run; 

*- Anxiety disorder among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_ANX 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'ANX'));
 by father;
 * if h2 then dad_ANX=1; 
 if h2 and diag_dat lt child_birth_dat then dad_ANX=1; **Select those diagnosed before child's birth date**;
 else dad_ANX=0;
 if ana4;
run; 

*- Substance use disorder among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_SUB 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'SUB'));
 by father;
 * if h2 then dad_SUB=1; 
 if h2 and diag_dat lt child_birth_dat then dad_SUB=1; **Select those diagnosed before child's birth date**;
 else dad_SUB=0;
 if ana4;
run; 

*- Bipolar disorder among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_BIP 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'BIP'));
 by father;
 * if h2 then dad_BIP=1; 
 if h2 and diag_dat lt child_birth_dat then dad_BIP=1; **Select those diagnosed before child's birth date**;
 else dad_BIP=0;
 if ana4;
run; 

*- Compulsive disorder among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_COM 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'COM'));
 by father;
 * if h2 then dad_COM=1; 
 if h2 and diag_dat lt child_birth_dat then dad_COM=1; **Select those diagnosed before child's birth date**;
 else dad_COM=0;
 if ana4;
run; 

*- ADHD among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_ADHD 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'ADH'));
 by father;
 * if h2 then dad_ADHD=1; 
 if h2 and diag_dat lt child_birth_dat then dad_ADHD=1; **Select those diagnosed before child's birth date**;
 else dad_ADHD=0;
 if ana4;
run; 

*- Affective disorder among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_AFF 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'AFF'));
 by father;
 * if h2 then dad_AFF=1; 
 if h2 and diag_dat lt child_birth_dat then dad_AFF=1; **Select those diagnosed before child's birth date**;
 else dad_AFF=0;
 if ana4;
run; 

*- Schizophrenia among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_SCH 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'SCH'));
 by father;
 * if h2 then dad_SCH=1; 
 if h2 and diag_dat lt child_birth_dat then dad_SCH=1; **Select those diagnosed before child's birth date**;
 else dad_SCH=0;
 if ana4;
run; 

*- Schizoid personality disorder among fathers;
data ana4;
 drop icd diag any_psych condition diag_dat asd;
 length dad_SPD 3;
 merge ana4 (in=ana4) h2 (in=h2 rename=(lopnr=father) where=(condition = 'SPD'));
 by father;
 * if h2 then dad_SPD=1; 
 if h2 and diag_dat lt child_birth_dat then dad_SPD=1; **Select those diagnosed before child's birth date**;
 else dad_SPD=0;
 if ana4;
run; 

*- Any mental illness among fathers;
proc sort data=h3; by lopnr; run;
data ana4;
 drop icd diag any_psych diag_dat;
 length dad_PSYCH 3;
 merge ana4 (in=ana4) h3 (in=h3 rename=(lopnr=father));
 by father;
 * if h3 then dad_PSYCH=1; 
 if h3 and diag_dat lt child_birth_dat then dad_PSYCH=1; **Select those diagnosed before child's birth date**;
 else dad_PSYCH=0;
 if ana4;
run; 

*- 2019-03-10: 'Any mental illness other than ASD' among fathers;
proc sort data=hnew; by lopnr; run;
data ana4;
 drop icd diag any_psych2 any_psych diag_dat;
 length dad_PSYCH2 3;
 merge ana4 (in=ana4) hnew (in=hnew rename=(lopnr=father));
 by father;
 if hnew and diag_dat lt child_birth_dat then dad_PSYCH2=1; **Select those diagnosed before child's birth date**;
 else dad_PSYCH2=0;
 if ana4;
run; 

