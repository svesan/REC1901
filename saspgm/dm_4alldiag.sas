*---------------------------------------------;
* Derive ASD and all psychiatric diagnoses    ;
*---------------------------------------------;

*-- There're three transposed datasets containing sibling information: npr_children, npr_parents and npr_relatives, 
combine them first to get a complete siblings dataset;

proc sort data=study.npr_children  out=cdiag; by child_id diag_dat; run;
proc sort data=study.npr_parents   out=pdiag; by parent_id diag_dat; run;
proc sort data=study.npr_relatives out=rdiag; by relative_id diag_dat; run;

data p0;
set cdiag(rename=(child_id=lopnr)) pdiag(rename=(parent_id=lopnr)) rdiag(rename=(relative_id=lopnr));
by lopnr;
run;

proc sort data=p0 out=p1 nodupkey;by lopnr diag diag_dat;run;
proc sort data=p1 out=p2 nodupkey;by lopnr diag;run;

data p3;
  length icd 3;
  set p2 (drop=icd index);
  if diag_dat GE '01JAN1997'd then icd=10;
  else if diag_dat GE '01JAN1987'd then icd=9;
  else if diag_dat GE '01JAN1969'd then icd=8;
  else icd=7;
run;

proc datasets lib=work mt=all nolist;delete p0-p2 cdiag pdiag rdiag;quit;
*-- Derive Psychiatry History;
data h0;
  length any_psych 3 lopnr 6;
  retain any_psych 1;
  set p3(keep=lopnr icd diag diag_dat);
  
  *-- Any mental illness;
  if (icd eq 10 and substr(diag,1,1) in ('F')) or 
	 (icd lt 10 and substr(diag,1,3) in ('295','296','297','298','299','300','301','303','304',
                                         '306','308','310','311','312','313','314','315'));
  
run;

*-- Now derive specific diagnostic groups, e.g. ASD;
data h1;
  drop diag2 first_char;
  length asd 3 condition $3 first_char $1;
  set h0(keep=lopnr icd diag diag_dat any_psych);
/*  asd=0; id=0; sid=0; depress=0; anxiety=0; subuse=0; bipolar=0; compuls=0; ADHD=0; affective=0; sc=0; spd=0;*/
  asd = 0;
  condition = 'OTH';
  diag = tranwrd(diag, ',', '.');
  diag2 = compress(diag,'ABWXEP');
  first_char = substr(diag,1,1);
  *-- Autism as a separate variable;
  if diag_dat GT '01JAN1987'd then do;
    if diag in: ('F840') then asd=1;
    if diag in: ('F845') then asd=2;
    if diag in: ('F841','F848','F849') then asd=3;
    if icd=9 and diag in: ('299A') then asd=1; ** Childhood autism **;
  end;

  *-- ASD and subtypes;
  if diag_dat GT '01JAN1987'd then do;
    if diag in: ('F840')               or
       diag in: ('F845')               or
       diag in: ('F841','F848','F849') or
       icd=9 and diag in: ('299A')     then do; ** Childhood autism **;
	   condition='ASD'; output;
	end;
  end;
  *-- AD;
  if diag_dat GT '01JAN1987'd then do;
    if diag in: ('F840')             or
     icd=9 and diag in: ('299A')   then do;
     condition='AD'; output;
    end;
  end;
   *-- Asperger;
  if diag_dat GT '01JAN1987'd then do;
    if diag in: ('F845')  then do;
     condition='AS'; output;
    end;
  end; 
   *-- PDD-NOS;
  if diag_dat GT '01JAN1987'd then do;
    if diag in: ('F841','F848','F849')  then do;
     condition='PDD'; output;
    end;
  end; 

  *-- Intellectual disability;
  if icd eq 10 and diag in: ('F7')                                          or
	 icd eq 9 and substr(diag,1,3) in ('317','318','319')                   or
	 icd eq 8 and substr(diag,1,3) in ('310','311','312','313','314','315') then do;
	 condition='ID'; output;
  end;
 
  *-- Severe intellectual disability;
  if icd eq 10 and diag in: ('F72','F73')           or
	 icd eq 9 and diag in ('318.1','318.2')         or
	 icd eq 8 and substr(diag,1,3) in ('313','314') then do;
     condition='SID'; output;
  end;
 
  *-- Depression;
  if icd eq 10 and diag in:('F32','F33','F341','F348','F349','F4321')            or
     icd eq 9 and diag in: ('296.2','296.3','300.4','301.12','309.1','311','296.82') or
     icd eq 8 and substr(diag,1,5) in ('298.0','300.4')                              then do;
	 condition='DEP'; output;
  end;

  *-- Anxiety disorder;
  if icd eq 10 and diag in:('F40','F41')     or
     icd eq 9 and diag in: ('300.0','300.2') or
     icd eq 8 and diag in: ('300.0','300.2') then do;
	 condition='ANX'; output;
  end;
  
  *--Substance use disorder;
  if icd eq 10 and diag in: ('F1') or
	 icd eq 9 and diag in: ('303','304','305')                      or
	 icd eq 8 and diag in: ('303','304')                            then do;
	 condition='SUB'; output;
  end;

  *--Bipolar disorder;
  if icd eq 10 and diag in:('F30','F31','F340')                       or
	 icd eq 9 and diag in: ('296.0','296.1','296.4','296.5','296.6',
                            '296.7','296.80','296.81','296.89','298B') or
	 icd eq 8 and diag in: ('296','298.1')                             then do;
	 condition='BIP';  output;
  end;

  *--Compulsive disorder;
  if icd eq 10 and diag in:('F42')  or
	 icd eq 9 and diag in ('300.3') or
	 icd eq 8 and diag in ('300.3') then do;
	 condition='COM'; output;
  end;

  *--ADHD;
  if icd eq 10 and diag in:('F90') or
	 icd eq 9 and diag in:('314')  then do;
	 condition='ADH'; output;
  end;

  *--Affective disorder;
  if icd eq 10 and diag in:('F38','F39') then do;
     condition='AFF';  output;
  end;

  *--Schizophrenia;
  if icd eq 10 and diag in:('F20','F22','F23','F24','F25','F28','F29') or
     icd eq 9 and diag in: ('295','297','298')                         or
     icd eq 9 and diag in ('298C','298E','298W','298X')                or
     icd eq 8 and diag in: ('295','297','299','298.2','298.3','298.9') then do;
	 condition='SCH'; output;
  end;  

  *--Schizoid personality disorder;
  if icd eq 10 and diag in ('F601') or
     icd eq 9 and diag in: ('301.2') then do;
	 condition='SPD'; output;
  end;
 
run;

/* proc freq data=h1; table condition; run; */

*-Keep first diagnosis date of each condition;
proc sort data=h1; by lopnr condition diag_dat;run;
data h2;
  set h1;
  by lopnr condition diag_dat;
  if first.condition;
run;

*-Keep first diagnosis date of 'any mental illness';
proc sort data=h0; by lopnr diag_dat; run;
data h3;
  set h0;
  by lopnr diag_dat;
  if first.lopnr;
run;


*-- 2019-03-10: add a new condition 'any mental illness other than ASD';
data hnew0;
length any_psych2 3;
retain any_psych2 1;
set h0;
if diag_dat GT '01JAN1987'd then do;
    if diag in: ('F840') then delete;
    if diag in: ('F845') then delete;
    if diag in: ('F841','F848','F849') then delete;
    if icd=9 and diag in: ('299A') then delete; ** Childhood autism **;
  end;
run;
*-2019-03-10: Keep first diagnosis date of 'any mental illness other than ASD';
proc sort data=hnew0; by lopnr diag_dat; run;
proc sort data=hnew0 out=hnew nodupkey; by lopnr; run;


*-Keep first diagnosis date and subtype for ASD;
proc sql;
create table h4 as select * from h2 (where=(condition='ASD'));
quit;
proc sort data=h4; by lopnr diag_dat;
data h4;
set h4;
by lopnr diag_dat;
if first.lopnr;
run;

