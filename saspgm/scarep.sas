options nosource nosource2;
%macro scarep(__func__,data=,var=,id=,bystmt=,panels=3,syntax=N,missing=Y,skipmiss=N,
              delete=Y,wrap=40,where=,style=0,force=N,exclude=,num=1,
              fixtit=N, progr=, splitwrd=Y, sort=N,print=Y)
              / des='MEB macro SCAREP 2.2';

%sca2util(___mn___=SCAREP, ___mt___=SCA, ___mv___=2.2);
%if %upcase(&__func__)=HELP %then %do;
  %put;
  %put %str( -------------------------------------------------------------------------------);
  %put %str( HELP: SCA macro SCAREP                                                         );
  %put %str( - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -);
  %put %str( A SCA statistical macro to produce standard reports);
  %put %str( -------------------------------------------------------------------------------);
  %put %str( NOTE......: Datasets ___M1___,...,___M7___ are used internally within the macro.);
  %put %str( ..........: No check is made to control that existing datasets and not deleted.);
  %put %str( ------- Parameters ------------------------------------------------------------);
  %put %str( DATA=.....: Input dataset);
  %put %str( BYSTMT=...: By statment);
  %put %str( ID=.......: ID variables. Printed only once for each level);
  %put %str( VAR=......: Variables to be listed. Empty means all);
  %put %str( EXCLUDE=..: Exclude variables when all variables selected (VAR=));
  %put %str( WHERE=....: Where statement);
  %put %str( ------- Report option statements ----------------------------------------------);
  %put %str( SORT=N....: Sort dataset in BYSTMT, ID, VAR order. Y or N.);
  %put %str( PANELS=3..: No of reports printed horizontally on each page);
  %put %str( SYNTAX=N..: Print SAS syntax to SAS log. Yes or No);
  %put %str( MISSING=Y.: Treat missing values as valid levels for ID variables);
  %put %str( SKIPMISS=N: Drop empty/missing variables);
  %put %str( WRAP=40...: Wrap text longer than WRAP onto several lines);
  %put %str( STYLE=1...: Select output style. 0, 1 or 2. See macro documentation);
  %put %str( NUM=1.....: 1:Re-format num variables, 2:Retain numbers);
  %put %str( FORCE=N...: Resize (locally) line size to fit report. When report do not fit.);
  %put %str( FIXTIT=N..: Y or N. If Yes apply the SCA tit macro on titles set.);
  %put %str( PROGR=....: Program name to be used with FIXTIT=Y parameter.);
  %put %str( DELETE=Y..: Debug facility. If DELETE=N then temporary datasets are not deleted.);
  %put %str( PRINT=Y...: PRINT=N supresses all printed output from the macro. Yes or No.);
  %put %str(-------------------------------------------------------------------------------);
  %put;
  %GOTO exit2;
%end;
%else %if "&__func__" ne "" %then %do;
  %put Note: %upcase(&__func__) request not recognised. Macro aborts;
  %GOTO exit2;
%end;

%*-----------------------------------------------------------------------------;
%* 2004-01-30..: Changed function nrquote to bquote (eq to nrbquote)           ;
%* 2008-01-23..: Added bquote function when manageing _varlid_ (row 140)       ;
%*               Change version from 1.0 to 2.0                                ;
%* 2008-09-24..: Minor bug fix when checking if variable in VAR= was in ID=    ;
%*               Change version from 2.0 to 2.1                                ;
%* 2012-11-190.: Minor bug fix when checking if variable in VAR= was in ID=    ;
%*               Change version from 2.1 to 2.2                                ;
%*-----------------------------------------------------------------------------;


%*-----------------------------------------------------------------------------;
%*  MACRO START: Initialize                                                    ;
%*-----------------------------------------------------------------------------;
%local __max__ _nylst_ ___l___ ___d___ temp __ant__ antresp nextgval anychar anynum anyfmt
       organtid antvar i j antid _optset_ _lsset_ __suml__ _varid_ ___tit1 _varnum_ _wsum_
       _sumtmp_ ___y___ a ___e___ ___r___ _complbl ___s1___ ___s2___ ___s3___ ___x___ repl
       antflow check check2 id_i _ant_ ___r1___ ___r2___;

%let __max__=0;%let organtid=0;%let __suml__=0;

proc sql noprint;
  select setting into : temp from dictionary.options where (optname='NOTES')
  ;
quit;
%let _optset_=&temp;

options nonotes;


%*-----------------------------------------------------------------------------;
%*  MACRO START: CHECK                                                         ;
%*-----------------------------------------------------------------------------;

%*---  Check:DATA statement --------------------------------------------------;
%if "&data" eq "" %then %do;
  %put Error: Please specify DATA dataset. Macro aborts.;
  %goto exit2;
%end;
%else %do;
  %*--- Temporarily check because SCA2UTIL does not handle the following DATAcheck;
  %sca2util(__dsn__=&data,_exist_=Y);
  %if &__err__=ERROR %then %goto exit;
%end;

%*---  Check:Various ----------------------------------------------------------;
%sca2util(_yesno_=force missing syntax skipmiss fixtit splitwrd sort delete print,
          _upcase_=data id var exclude bystmt,___mc___=&id,
          __dsn__=&data,__lst__=&id &var &bystmt &exclude,_exist_=Y,_vexist_=Y);
%if &__err__=ERROR %then %goto exit;
%let organtid=&_nmvar_;

%*---  Check:WHERE statement --------------------------------------------------;
%if "&where" ne "" %then %do;
  %sca2util(__dsn__=&data,_where_=&where,__out__=___m4___);
  %if &__err__=ERROR %then %goto exit;
%end;
%else %do;
  proc sql noprint;
    create table ___m4___ as select * from &data
    ;
  quit;
%end;

%*---  Check:parameter INTEGER input ------------------------------------------;
%sca2util(_mexist_=wrap style panels num,_mtype_=INTEGER);
%if &__err__=ERROR %then %goto exit;
%else %do;
  %if &style<0 or &style>2 %then %put Warning: STYLE=&style not accepted. STYLE set to 0.;
  %if &wrap <1 %then %put Warning: WRAP=&wrap not accepted. WRAP set to 40.;
  %if &num <0 or &num>2 %then %put Warning: NUM=&num not accepted. NUM set to 1.;
  %else %if &num=0 %then %put Warning: NUM=&num is no longer accepted. NUM set to 2.;
  %if &panels <1 %then %put Warning: PANELS=&panels not accepted. PANELS set to 3.;
%end;


%*--- Creating _ant_ as number of BYSTMT-items --------------------------------------;
%if "&bystmt" ne "" %then %do;
  %sca2util(___mc___=&bystmt); %let _ant_=&_nmvar_; %let _nylst_=&bystmt;
%end;


%*-----------------------------------------------------------------------------------;
%*  Select all variables                                                             ;
%*-----------------------------------------------------------------------------------;
%if "&exclude"^="" and "&var"^="" %then %do;
  %put Warning: EXCLUDE variables not allowed when VAR parameter not empty.;
  %let exclude=;
%end;

%*-- Cleaning ID variables from VAR parameter ---------------------------------------;
%*-- Code added 010212 MWESTIN -----------------;
%if "&id"^="" and "&var"^="" %then %do;
  %sca2util(___mc___=&var);
  %do j = 1 %to &_nmvar_;
    %if %sysfunc(indexw(&id, %scan(&var,&j))) = 0 %then %let _varid_ = &_varid_ %scan(&var,&j);
  %end;

  %* updated 24sep2008 svesan: macro apersand missing in _varid_. Minor bug fix. *%;
  %* updated 19nov2012 svesan: remove blanks as blank will report that VAR includes ID;
  %if %bquote(%qsysfunc(compress(&_varid_))) ne %bquote(%qsysfunc(compress(&var))) %then %do;
    %put Warning: VAR parameter includes ID variables. Variables removed from VAR.;
    %let var = &_varid_;
  %end;
%end;


%if "&var"="" %then %do;
  %put Note: Selects all variables.;

  %let ___l___=%scan(&data,1,'.');
  %let ___d___=%scan(&data,2,'.');
  %if %length(%bquote(&___d___))=0 %then %do;
    %let ___d___=%scan(&data,1,'.');
    %let ___l___=WORK;
  %end;

  %*-- ID, EXCLUDE and BYSTMT parameter removed from VAR-list -------------------;
  %if "&id" ne "" %then %let exclude=&id &exclude;
  %if "&bystmt" ne "" %then %let exclude = &exclude &bystmt;
  %sca2util(___mc___=&exclude);

  proc sql noprint;
    select name into :var separated by ' '
      from DICTIONARY.columns
    where (libname="&___l___" and memname="&___d___")
    %do j = 1 %to &_nmvar_;
      and upcase(name) ne "%upcase(%scan(&exclude,&j,' '))"
    %end;
    ;
  quit;

   %if &var =  %then %do;
     %put Error: No variables selected after exclusion.Macro Aborts.;
     %goto exit;
   %end;
%end;

%sca2util(___mc___=&id);
%let antid=&_nmvar_;
%sca2util(___mc___=&var);
%let antresp=&_nmvar_;
%let antvar=%eval(&antid+&antresp);

%*---  CHECK: No of columns<=60 ------------------------------------------------;
%if &antvar>60 %then %do;
  %put Error: Macro do only allow LE 60 variables. Macro aborts.;
  %let __err__=ERROR; %let _reason_=SCAREP;
  %goto exit;
%end;

%*---  Skipmiss: Remove all empty variables from VAR-list ----------------------;
%if "&skipmiss"="Y" %then %do;
  %put Note: Removing all empty (num and char) variables from VAR parameter list;
  proc sql noprint;
    create table ___m6___ as select
    %do i=1 %to &antresp;
      %let ___y___=%scan(&var,&i,' ');
      %if &i<&antresp %then count(&___y___) as &___y___,;
      %else count(&___y___) as &___y___;
    %end;
    from ___m4___;
    ;
  quit;
  proc transpose data=___m6___ out=___m7___(where=(col1>0));
    var &var;
  run;
  proc sql noprint;
    select _name_, count(*) into :var separated by ' ', :antresp
       from ___m7___
    ;
  quit;

  %let antvar=%eval(&antid+&antresp);

  %if &antresp = 0 %then %do;
    %put Error: All variables are empty. Macro aborts.;
    %goto exit;
  %end;
%end;


%*------------------------------------------------------------------------------------;
%*  Calculate minimal label length (single word): Store length into L1, L2 etc        ;
%*------------------------------------------------------------------------------------;

%put Note: Calculate minimal label length;

%do i=1 %to &antvar;
  %let a=%scan(&id &var,&i,' ');
  proc sql noprint;
    select label into : ___e___
    from dictionary.columns
    where (libname = "WORK" and memname = "___M4___" and
           memtype in ('DATA') and upcase(name)=upcase("&a"));   /* V8 MWI upcase on name */
  quit;
  %let ___e___=&___e___;
  %let ___r___=%length(%bquote(&___e___));
  %if &___r___>0 %then %let ___e___=%substr(%bquote(&___e___),1,&___r___);
  %else %let ___e___=&a;
  %let ____l&i=&___e___;

  %*-- Save labels for first ID for use in compute block -----;
  %if &i=1 %then %let _complbl=&___e___;

  %let _nmvar_=;
  %sca2util(___mc___=%bquote(&___e___));
  *-- if label counting does not work --*;*-- #TEMPKOD# --*;
  %if &_nmvar_ eq  %then %do;
    %put Error: Counting of labels went wrong. Macro Aborts.;
    %goto exit;
  %end;
  %let L&i=3;
  %do j=1 %to &_nmvar_;

    %let temp=%scan(%bquote(&___e___),&j,' ');
    %if "&temp"="" %then %let temp=&___e___;

    %if "&temp"^="" %then %if %length(%bquote(&temp))>&&L&i %then %let L&i=%length(%bquote(&temp));

  %end;
  %let __suml__=%eval(&__suml__+&&l&i);

%end;
%*------------------------------------------------------------------------------------;
%*  CHECK: Exit if sum of labels>256                                                  ;
%*------------------------------------------------------------------------------------;
%if %eval(&antvar-1+&__suml__) > 255 %then %do;
  %put Error: Total length report header > 255. Macro Aborts.;
  %goto exit;
%end;


%*------------------------------------------------------------------------------------;
%*  Calculate variable output length                                                  ;
%*------------------------------------------------------------------------------------;
%put Note: Calculate output variable length;
%*--- Store variable names into V1, V2 setc ----------------------------;
%do i=1 %to &antvar;
  %let v&i=%scan(&id &var,&i,' ');
%end;
%*--- Set C1, C2 vars to variable name if character --------------------;
%let anychar=NO; %let anynum=NO;
%*sca2util(__dsn__=&data,__lst__=&id &var,__mout__=type);

%do i=1 %to &antvar;
  %let a=%scan(&id &var,&i,' ');
  proc sql noprint;
    select type into : ___e___
    from dictionary.columns
    where (libname = "WORK" and memname = "___M4___" and
           memtype in ('DATA') and upcase(name)=upcase("&a")); /* V8 MWI upcase on name */
  quit;
  %let ___e___=&___e___;

  %let ___r___=%length(%bquote(&___e___));
  %if &___r___>0 %then %let ___e___=%substr(%bquote(&___e___),1,&___r___);

  %if "&___e___" ne "" %then %do;
    %if "&___e___"="char" %then %let anychar=YES;
    %if "&___e___"="num" %then %let anynum=YES;
    %let c&i=&___e___;
  %end;
  %else %let c&i=;
%end;

%*--- Set F1, F2 vars to variable name if format present ---------------;
%let anyfmt=NO;
%*sca2util(__dsn__=&data,__lst__=&id &var,__mout__=format);

%do i=1 %to &antvar;
  %let a=%scan(&id &var,&i,' ');
  proc sql noprint;
    select format into : ___e___
    from dictionary.columns
    where (libname = "WORK" and memname = "___M4___" and
           memtype in ('DATA') and upcase(name)=upcase("&a")); /* V8 MWI upcase on name */
  quit;
  %let ___e___=&___e___;

  %let ___r___=%length(%bquote(&___e___));
  %if &___r___>0 %then %let ___e___=%substr(%bquote(&___e___),1,&___r___);

  %if %length(%bquote(&___e___))>0  %then %do;
    %let anyfmt=YES;
    %let f&i=&___e___;
  %end;
  %else %let f&i=;
%end;


%*---  Initialize LL and FMT macro variables -----------------------------------------;
%***** OBS, OBS: Skall alla dessa s�ttas till 0 ????;
%do i=1 %to &antvar;
  %local LL&i OLT&i OL&i NL&i fmt&i cfv&i ML&i WL&i;

  %let LL&i=0; %let OLT&i=; %let OL&i=; %let NL&i=0;
  %let fmt&i=; %let cfv&i=; %let ML&i=; %let WL&i=0; %let cwv&i=;
%end;

%*---  Output LL variables: Length of output variables -------------------------------;
%if &anychar=YES or &anyfmt=YES %then %do;
  %put Note: Analyze content of character and/or formatted variables.;

  data ___m1___;
    length tmp1 $ 200;
    drop %do i=1 %to &antvar;  %if "&&c&i"="char" or "&&f&i" ne "" %then %str(&&v&i); %end;;
    set ___m4___(keep=%do i=1 %to &antvar;  %if "&&c&i"="char" or "&&f&i" ne "" %then %str(&&v&i); %end;);

    %do i=1 %to &antvar;
      %*if "&&c&i"="char" and "&&f&i" ne "" %then %do;  %*---- If character var. with format --*;
      %if "&&f&i" ne "" %then %do;  %*---- If character var. with format --*;
        ____C&i=length(trim(put(&&v&i,&&f&i)));
        call symput("cfv&i","____C&i");

        %if "&splitwrd"="N" %then %do;
          %*-- Search word of maximum length ------------------------------*;
          tmp='X'; __len__=0; i=0;
          do until(tmp1='');
            i=i+1;
            tmp1='';
            tmp1=scan(put(&&v&i,&&f&i), i, ' ');
            __len0__=length(compress(tmp1));
            if tmp1 ne '' then do;
              if __len0__>__len__ then __len__=__len0__;
            end;
          end;
          if __len__=0 then ____W&i=1; %*--- OBS: Is this line needed ?? ----------;
          if __len__>0 then ____W&i=__len__;
          call symput("cwv&i","____W&i");

        %end;
      %end;
      %else %if "&&c&i"="char" and "&&f&i"="" %then %do;  %*---- If character var without format --*;
        ____C&i=length(trim(&&v&i));
        call symput("cfv&i","____C&i");

        %if "&splitwrd"="N" %then %do;
          %*-- Search word of maximum length ------------------------------;
          tmp='X'; __len__=0; i=0;
          do until(tmp1='');
            i=i+1;
            tmp1='';
            tmp1=scan(&&v&i, i, ' ');
            __len0__=length(compress(tmp1));
            if tmp1 ne '' then do;
              if __len0__>__len__ then __len__=__len0__;
            end;
          end;
          if __len__=0 then ____W&i=1; %*--- OBS: Is this line needed ?? ----------;
          if __len__>0 then ____W&i=__len__;
          call symput("cwv&i","____W&i");

        %end;
      %end;
      %else call symput("cfv&i",compress(""));;
    %end;
  run;

  %*-- Store output length in macro variables LL --------------------------;
  proc summary data=___m1___ nway;
    var %do i=1 %to &antvar; %str(&&cfv&i) %end;;
    output out=___m2___(drop=_freq_ _type_) max=;
    run;
  data _null_;
    set ___m2___;
    %do i=1 %to &antvar;
      %if &&cfv&i^= %then call symput("LL&i",compress(put(&&cfv&i,8.)));;
    %end;
    run;

  %*-- Store max word length in macro variables WL ------------------------;
  %if "&splitwrd"="N" %then %do;
    proc summary data=___m1___ nway;
      var %do i=1 %to &antvar; %str(&&cwv&i) %end;;
      output out=__m2b__(drop=_freq_ _type_) max=;
      run;
    data _null_;
      set __m2b__;
      %do i=1 %to &antvar;
        %if &&cwv&i^= %then call symput("WL&i",compress(put(&&cwv&i,8.)));;
      %end;
      run;
  %end;

%end;

%*---  Numeric unformatted values: set formats ---------------------------------------;
%if &anynum=YES %then %do;
  %put Note: Analyzing content of numerical variables.;
  %do i=1 %to &antvar;
    %if "&&cfv&i"="" and &num=2 %then %do;
      %let temp=%scan(&id &var,&i,' ');
      %put Note: Numeric data will be printed without truncation;
      proc sql noprint;
        select max(length(compress(put(&temp,best32.)))) into : NL&i
        from ___m4___;
      quit;
      %let NL&i=&&NL&i; /* V8 MWI Remove trailing blanks */
      %let fmt&i=format=best%scan(&&NL&i,1).;
      %if &&NL&i GE 16 %then %put Warning: Data might be truncated. Please check output. Variable=%upcase(&temp).;
    %end;
    %else %if "&&cfv&i"="" and &num=1 %then %do;
      %let temp=%scan(&id &var,&i,' ');

      %if &&C&i=num %then %do;
        proc sql noprint;
          create table ___m5___ as
          select &temp, &temp-int(&temp) as frac,int(&temp) as int
          from ___m4___
          ;
          select max(abs(frac))   into : ___r1___ from ___m5___;  %* Fraction: 0.00x *;
          select min(abs(frac))   into : ___r2___ from ___m5___;  %* Needed to prevent overflow ;
          select max(abs(&temp))  into : ___s1___ from ___m5___;  %* Needed to prevent overflow ;
          select min(abs(&temp))  into : ___s2___ from ___m5___;  %* Needed to prevent overflow ;
          select sign(min(&temp)) into : ___s3___ from ___m5___;
        quit;

        %if %length(%bquote(&___r1___))>0 %then %do;

          data _null_;
            if &___s3___<0 then sign=1;else sign=0;
            x=&___s1___;
            int=int(x);
            rest=&___r1___;
            i_l=length(compress(put(int,25.)));
            if rest>0 then do;
              r_l=length(compress(scan(put(1/rest,25.),1,'.')));
              if int GE 100 then do;   ** Values >= 100 **;
                w=i_l+sign;
                call symput("fmt&i",'format='||compress(put(w,25.))||'.');
              end;
              else if int GE 10 and int <100 then do;   ** Values >= 10 **;
                w=4+sign;
                call symput("fmt&i",'format='||compress(put(w,25.))||'.1');
              end;
              else if int GE 1 and int < 10 then do;   ** Values < 9 **;
                if r_l>1 then do;
                  w=r_l+2+sign;
                  call symput("fmt&i",'format='||compress(put(w,25.))||'.2');
                end;
                else if r_l=1 then do;
                  w=r_l+2+sign;
                  call symput("fmt&i",'format='||compress(put(w,25.))||'.1');
                end;
                else abort;
              end;
              else if int<1 then do; ** Values < 1 **;
                rest=&___r2___;
                r_l=length(compress(scan(put(1/rest,25.),1,'.')));
                w=r_l+2+sign;
                if w < max(&&L&i,&&LL&i) then do; %* add a decimal if there is place;
                  r_l=r_l+1;w=w+1;
                end;
                call symput("fmt&i",'format='||compress(put(w,25.))||"."||compress(put(r_l,23.)));
              end;
            end;
            else do;
              w=i_l+sign;
              call symput("fmt&i",'format='||compress(put(w,25.))||".");
            end;

            call symput("NL&i",compress(put(w,25.)));
          run;

        %end;
        %else %do;
          %put Note: Variable &temp contain only missing values.;
          %let fmt&i=;
        %end;
      %end;
      %else %let fmt&i=;
    %end;
    %else %let fmt&i=;
  %end;
%end;


%*-- Set output length to max of label and output variable length --------;
%do i=1 %to &antvar;
  %if (&&L&i GE &&LL&i and &&L&i GE &&NL&i)  %then %let OL&i=&&L&i;
  %else %if (&&L&i GE &&LL&i and &&L&i LE &&NL&i)  %then %let OL&i=&&NL&i;
  %else %if (&&L&i LE &&LL&i and &&LL&i GE &&NL&i) %then %let OL&i=&&LL&i;
  %else %if (&&L&i LE &&LL&i and &&LL&i LE &&NL&i) %then %let OL&i=&&NL&i;
  %else %if (&&L&i GE &&NL&i and &&L&i GE &&LL&i)  %then %let OL&i=&&L&i;
  %else %if (&&L&i GE &&NL&i and &&L&i LE &&LL&i)  %then %let OL&i=&&LL&i;
  %else %let OL&i=&&LL&i;
%end;


%*-- Max of label and numeric output length as min for flowing -----------;
%**** OBS, OBS: Funkar detta om icke-numeriska variabler ??? ;
%do i=1 %to &antvar;
  %if "&splitwrd"="Y" %then %let ML&i=%sysfunc(max(&&L&i,&&NL&i));
  %else %let ML&i=%sysfunc(max(&&L&i,&&NL&i,&&WL&i));
%end;


%*------------------------------------------------------------------------------------;
%*  Decide appropriate length: Label or output                                        ;
%*------------------------------------------------------------------------------------;
%put Note: Column width setting.;
%let repl=%eval(&antvar); %let antflow=0;
%*-- Get Linesize length ------------;
proc sql noprint;
  select setting into : _lsset_ from dictionary.options where (optname='LINESIZE')
  ;
quit;
%let _lsset_=&_lsset_;    /* V8 MWI Removing trailing blanks */
%let _optset_=&_optset_ LS=&_lsset_;


%*-- Count total report length ------;
%do i=1 %to &antvar;
  %let repl=%eval(&repl+&&OL&i);
%end;
%if &style>0 %then %let repl=%eval(&repl-&OL1);


%*-- If report length>LS: Flow columns and re-calc report length and next greatest col length;
%if &repl>&_lsset_ %then %do;
  %put Note: Report too wide to fit. Analyzing text strings.;
  %let repl=%eval(&antvar);%let nextgval=0;
  %do i=1 %to &antvar;
/*    %if (&&OL&i>&wrap and "&&fmt&i"="") %then %do;*/
    %if (&&OL&i>&wrap) %then %do;

      %*- If WRAP GE than max length of label and numeric output -----;
      %*- (and max word length if SPLITWRD=N has been set        -----;
      %if &wrap GE &&ml&i %then %do;
        %put Note: Wrapping variable &&v&i;
        %let OL&i=&wrap; %let OLT&i=FLOW; %let antflow=%eval(&antflow+1);
      %end;
      %else %do;
%*;        %put Note: Variable &&v&i wrapped to &&ML&i to protect label or numeric output length;
%*;        %let OL&i=&&ML&i; %let OLT&i=FLOW; %let antflow=%eval(&antflow+1);
      %end;
    %end;
    %else %let olt&i=;
    %let repl=%eval(&repl+&&OL&i);
    %if &&OL&i>&nextgval and &&OL&i ne &wrap %then %let nextgval=&&OL&i;
  %end;
  %if &style>0 %then %let repl=%eval(&repl-&OL1);
%end;

%*-- If report still>LS: Decrease flow-columns to size of next greateset col length --------;
%let check=NO;
%let check2=YES;
%if &repl>&_lsset_ %then %put Note: Report still too wide to fit. Re-analyzing variables.;
%if &repl>&_lsset_ %then %do %until(&check=YES or &check2=NO);
  %let check2=NO;
  %do i=1 %to &antvar;
/*    %if (&&OLT&i=FLOW and &&OL&i>&nextgval and "&&fmt&i"="") %then %do;*/
    %if (&&OLT&i=FLOW and &&OL&i>&nextgval and &&OL&i>&&ML&i) %then %do;
      %let OL&i=%eval(&&OL&i-1);
      %let repl=%eval(&repl-1);
      %let check2=YES;
    %end;
    %else %if (&&OLT&i=FLOW and (&&OL&i LE &nextgval or &&OL&i=&&ML&i)) %then %do;
      %let check=YES;
      %let check2=YES;
    %end;
  %end;

  %*if &repl>&_lsset_ and &check=YES %then %do;
  %if &repl>&_lsset_ %then %do;
    %put Note: Report %eval(&repl-&_lsset_) characters too wide.;
    %put Note: Change LS option to LS=&repl, drop variables or change WRAP parameter;
    %if &force=Y %then %do;
      %if &repl LE 256 %then %do;
        %put Note: FORCE=Y will temporarily resize line size.;
        %let force=LS=&repl;%let repl=1;
      %end;
      %else %do;
        %put Note: FORCE=Y suppressed. LS>256. Change WRAP parameter to WRAP<<&wrap;
        %goto exit;
      %end;
    %end;
    %else %let force=;
  %end;
  %if &repl<&_lsset_ %then %do;
    %put Note: Report column width resized to fit;
    %let check=YES;
  %end;
%end;

%if &repl>&_lsset_ %then %do;
  %put Error: Report too wide to fit. Macro aborts.;
  %goto exit;
%end;

%if "&bystmt" ne "" %then %do;
  %*------------------------------------------------------------------------;
  %*  Generate title lines                                                  ;
  %*------------------------------------------------------------------------;

  %*-- Store no of titles into macro variable __max__ ;
  proc sql noprint;
    select count(*) into : __max__
       from DICTIONARY.titles
    where (type="T");
  quit;
  %if &__max__>0 %then %do i=1 %to &__max__;
    proc sql noprint;
      select text into : ___t&i
         from DICTIONARY.titles
      where (type="T" and number=&i);
    quit;
    %let ___t&i=&&___t&i;

    %let ___r___=%length(%bquote(&&___t&i));
    %if &___r___>0 %then %let ___t&i=%substr(%bquote(&&___t&i),1,&___r___);
    %else %let ___t&i=;
  %end;


  %*-- Set titles ------------------------------------------------------;
  %do i=1 %to &_ant_;
    %let ___tit1= &___tit1 %str(#byvar&i=#byval&i );
  %end;

  %if "&___tit1"^="" %then title%eval(&__max__+2) "&___tit1";;


  %*--- Close by-line --------------------------------------------------;
  proc sql noprint;
    select setting into : temp from dictionary.options where (optname='BYLINE');
    %let _optset_=&_optset_ &temp;
    quit;
  options nobyline;
%end;


%*------------------------------------------------------------------------------------;
%*  Produce report                                                                    ;
%*------------------------------------------------------------------------------------;
%let id_i=0; %if "&force"="N" or "&force"="Y" %then %let force=;

%if &style=1 or &style=2 and "&f1"="" %then %do;
  %*---- Calculate free space round num output for style>0 output ----------------------;
  data _null_;
    if "&c1"="num" then r1=input(scan("&fmt1",2,'=.'),8.);
    else if &LL1>0 then r1=&LL1;
    else put 'ERROR: Unforeseen macro error. Please check';
    r2=min(int((&repl-2-r1)/2),10);
    if r2>0 then call symput('___x___',repeat('-',r2-1));
    else call symput('___x___','');
    run;
%end;

  %if "&_nylst_" ne "" %then %str(proc sort data=___m4___;by &_nylst_;run;);

  %if "&fixtit"="Y" %then %do;
    %if "&progr"="" %then %let progr=<Unknown>;
    %tit(prog=&progr, type=2);
  %end;
  %else %if &progr ne  %then %do;
    %put Warning: FIXTIT parameter missing. PROGR parameter has no effect.;
  %end;

  %if &sort=Y %then %do;
    %put Note: Sorting dataset;
    proc sort data=___m4___;by &_nylst_ &id &var;run;
  %end;

  %if &print=N %then %do;
    %put Note: No report to output;
  %end;
  %else %do;
    %put Note: Printing report;
  %end;

  %*-- Check if first ID-variable is longer than the rest of report ------;
  %*-- if so, width is changed in report until ID-variable fits ----------;
  %if &style=1 or &style=2 %then %do;
    %let _wsum_=0;
    %do i = 2 %to &antvar;
      %let _wsum_ = %eval(&_wsum_+&&ol&i);
    %end;
    %if &_wsum_ < &ll1 %then %do;
      %do %while(&_wsum_< &ll1);
        %let _sumtmp_=0;
        %do i = 2 %to &antvar;
          %let ol&i = %eval(&&ol&i+1);
          %let _sumtmp_ = %eval(&_sumtmp_+&&ol&i);
        %end;
        %let _wsum_ = &_sumtmp_;
      %end;
    %end;
  %end;

  proc report data=___m4___ nowd headline spacing=1 split=' ' &force
    %if "&syntax"="Y" %then %str(LIST);
    %if "&missing"="Y" %then %str(MISSING);
    %if "&print"="N" %then %str(NOEXEC);
    %if "&panels" ne "" %then %str(panels=&panels;);
    /* ---- V8 MWI Proc report can not write character above column ----*/
    /*------headers for both id- and display variables              ----*/
    /*column ('--' &id &var);*/
    %IF %QUOTE(&ID) NE %QUOTE() %THEN %DO;
      column ('--' &ID) ('--' &VAR);
        %END;
        %ELSE %DO;
       column ('--' &var);
        %END;
  %do i=1 %to &antvar;
    %let temp=%scan(&id &var,&i,' ');
    %if &i LE &antid %then %do;
      %let id_i=&id_i+1;
      %if &id_i=1 %then break after &temp / skip;;
      define &temp / order ID &&fmt&i order=internal width=&&OL&i %if &&OLT&i^= %then &&OLT&i;
                     %if (&style=1 or &style=2) and &i=1 %then %str(noprint);;
      %if (&style=1 or &style=2) and &i=1 %then %do;

        compute before &temp;
          %if &style=2 %then %str(line @2 "&_complbl:";);
          %if "&&f&i" ne "" %then %str(line &temp &&f&i;);
          %else %if "&&c&i"="char" %then %do;
            _______x=put(left(&temp),$char&LL1..);
            %if "&___x___" ne "" %then %let ___y___=line @2 "&___x___" _______x $char&LL1.. "&___x___";
            %else %let ___y___=line @2 _______x $char&LL1..;
            %str(&___y___;);
          %end;
          %else %if "&&c&1"="num" %then %do;
            %if "&___x___" ne "" %then %let ___y___=line @2 "&___x___" &temp %scan(&&fmt&i,2,'=') "&___x___";
            %else %let ___y___=line &temp @2 %scan(&&fmt&i,2,'=');
            %str(&___y___;);
          %end;
        endcomp;

      %end;
    %end;
    %else %do;
      define &temp / display &&fmt&i order=internal width=&&OL&i %if &&OLT&i^= %then &&OLT&i;;
    %end;
  %end;
  %if "&_nylst_" ne "" %then %str(by &_nylst_;);
    run ;quit;

  title%eval(&__max__+1);

%EXIT:
  %if &delete=Y %then %do;
    %put Note: Cleanup;
    proc datasets lib=work mt=data nolist;
      delete ___m1___ ___m2___ ___m4___ ___m5___ ___m6___ ___m7___ __m2b__;
      quit;
  %end;
  footnote;

  options &_optset_;

%EXIT2:
  %put Note: Macro SCAREP finished execution;

%mend scarep;
options source;
