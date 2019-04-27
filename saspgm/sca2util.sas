options source;
                                                                                                                                        
%macro sca2util(__func__,   ___mn___ =, ___mv___ =,  ___mt___ =,                                                                        
                __dsn__  =,  __lst__ =,  _exist_ =N, __mmsg__ =Y,                                                                       
                _vtype_  =,  __use__ =, _vexist_ =N,  _yesno_ =,                                                                        
                __vlst__ =, _mexist_ =,  _mtype_ =,                                                                                     
                _upcase_ =,  _oblig_ =, ___mc___ =,   __lib__ =,                                                                        
                ___id___ =, __mout__ =,  __cat__ =,   _ctype_ =,                                                                        
                _where_  =,  __out__ =, __ulst__ =,  ___dm___ =,                                                                        
                __file__ =,  _sname_ =,  __amsg__=Y, _vnlen_ = 8)                                                                       
                / des='MEP macro SCA2UTIL 1.0';                                                                                         
                                                                                                                                        
* 050602  1) Updated code to comply with AIX on mimir. Simply added the sysscpl macro variable          ;

%if %upcase(&__func__)=HELP %then %do;                                                                                                  
  %put;                                                                                                                                 
  %put %str( ------------------------------------------------------------------------------);                                           
  %put %str( HELP: MEP macro SCA2UTIL                                                      );                                           
  %put %str( ------------------------------------------------------------------------------);                                           
  %put %str( A MEP utility macro: Check existance of datasets, variables, values etc. The);                                             
  %put %str( macro is defined by the following set of parameters:);                                                                     
  %put %str( ___MN___..: Parent macro name);                                                                                            
  %put %str( ___MV___..: Parent macro version);                                                                                         
  %put %str( ___MT___..: Parent macro type);                                                                                            
  %put %str( __DSN__...: Name of dataset to check);                                                                                     
  %put %str( __LST__...: List of variables to check);                                                                                   
  %put %str( __ULST__..: Output list corresponding to __LST__);                                                                         
  %put %str( _EXIST_=N.: Y/N to check existence of dataset or not. At the same time a check);                                           
  %put %str( ..........: is made that dataset is not empty. REASON = DSNEXIST or DSNEMPTY  );                                           
  %put %str( _VTYPE_...: NUM/CHAR check that variables in __LST__ are of a certain type);                                               
  %put %str(           : REASON = VAREXIST, VARNOTN, VARNOTC as appropriate );                                                          
  %put %str( __USE__...: Indicate USE=DATASTEP if used within datastep, REASON=SYNTAX);                                                 
  %put %str( _VEXIST_=N: Check existence of variables __LST__ in dataset __DSN__, REASON=VAREXIST);                                     
  %put %str( _UPCASE_..: Transforms list of macro variables to uppercase);                                                              
  %put %str( _YESNO_...: Check that macro variables are Y, N, YES, NO);                                                                 
  %put %str( __VLST__..: List of values corresponding to vars list in __LST__. Valid parameter values:);                                
  %put %str( ..........: <k, <=k, >k, >=k, (k1_k2_..._k) or integer);                                                                   
  %put %str( _OBLIG_...: List of variables that must be non-blank, REASON = OBLIGVAR);                                                  
  %put %str( ___MC___..: Text string. No of words in __MC__ sent to global variable _NMVAR_);                                           
  %put %str( _MEXIST_..: List of macro variables. Test that vars are defined);                                                          
  %put %str( __MMSG__=Y: Print messages (Notes, Warning, Error) to log: Y/N);                                                           
  %put %str( __AMSG__=Y: Use string "Macro aborts." in the SAS log: Y/N);                                                               
  %put %str( __LIB__...: Libname expected. Test for existence, reason=LIBEXIST );                                                       
  %put %str( ..........:                   count no of datasets _NLIB_         );                                                       
  %put %str( ___ID___..: Id variables expected. Test for replicate levels in __DSN__);                                                  
  %put %str( __CAT__...: Catalog name. Test for existence, reason=CATEXIST,         );                                                  
  %put %str(           :               count no of members into global var __ncat__);                                                   
  %put %str( _CTYPE_...: Member type to count in __CAT__. Empty means all);                                                             
  %put %str( _MOUT_....: Controls global macro vars to __LST__ (LABEL FORMAT TYPE LEVEL N NMISS));                                      
  %put %str( ..........: MEAN STD MIN MAX) );
  %put %str( _WHERE_...: Check where statement and subset data into __OUT__ dataset);                                                   
  %put %str( ___DM___..: Modify __DSN__: LOWCASE, UPCASE);                                                                              
  %put %str(           : The method may fail if too many character variables, REASON=CHAR);                                             
  %put %str( __OUT__...: Output dataset for parameters WHERE and ___DM___);                                                             
  %put %str( __FILE__..: Name of external file. Test for existence);                                                                    
  %put %str( _SNAME_ ..: A Word. Check if word is a valid SAS name);                                                                    
  %put %str( _VNLEN_...: Maximum length of SAS variable name. Default 8, also in SAS v8);                                               
  %put %str(-------------------------------------------------------------------------------);                                           
  %put;                                                                                                                                 
  %goto exit2;                                                                                                                          
%end;                                                                                                                                   
%else %if "&__func__" NE "" %then %do;                                                                                                  
  %if &__mmsg__=Y %then %put Error: %upcase(&__func__) request not recognised. Macro aborts.;                                           
  %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                             
  %goto exit2;                                                                                                                          
%end;                                                                                                                                   
                                                                                                                                        
%*---- Test Operating System -------------------------------------------------;                                                         
%if "&sysscp" NE "WIN" and "&sysscp" NE "VMS" and "&sysscp" ne "LINUX" and "&sysscp" ne "SUN 4" and "&sysscpl" ne "AIX" and "&sysscpl" ne "Linux" %then %do;
  %put Note: Operating system WIN, VMS, Solaris, AIX or LINUX required.;
  %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                             
  %goto exit2;
%end;                                                                                                                                   
                                                                                                                                        
%global __err__ _reason_ __nobs__ _wnobs_ __nvar__ __nlib__ _nmvar_ __ncat__;                                                           
%local __temp__ __opt1__ ___a___ ___b___ ___r___ __func__ __dsn__                                                                       
       __lst__ _exist_ __mmsg__ _vtype_ __use__ _vexist_ _yesno_ __vlst__ _mexist_                                                      
       _upcase_ _oblig_ ___mc___ __lib__ ___id___ __mout__ __cat__ _ctype_ _sname_                                                      
       ___l___ ___d___ _iiiiii_ _jjjjjj_  ___t___                                                                                       
       ___c1___ ___c2___ ___ag___ __dsid__                                                                                              
       ___mn___  ___mv___ __ulst__ ___dm___ __file__ __long__;                                                                          
                                                                                                                                        
%*-- Save option setting: reset when closing macro ------------------------------;                                                      
%*-- NB: FOR SEARCH OF POSSIBLE ERRORS CHANGE TO SERROR -------------------------;                                                      
%if "%upcase(&__use__)" NE "DATASTEP" and                                                                                               
     (%scan(&sysver,1,'.') LT 6 OR                                                                                                      
      (%scan(&sysver,1,'.') EQ 6 and %scan(&sysver,2,'.') LT 12) ) %then %do;                                                           
  proc sql noprint;                                                                                                                     
                                                                                                                                        
    select setting into : ___a___ from dictionary.options where optname='MPRINT';                                                       
    %let __opt1__=&___a___;                                                                                                             
    options nomprint;                                                                                                                   
                                                                                                                                        
    select setting into : ___a___ from dictionary.options where optname='SYMBOLGEN';                                                    
    %let __opt1__=&__opt1__ &___a___;                                                                                                   
    options nosymbolgen;
                                                                                                                                        
    select setting into : ___a___ from dictionary.options where optname='MLOGIC';                                                       
    %let __opt1__=&__opt1__ &___a___;                                                                                                   
    options nomlogic;                                                                                                                   
                                                                                                                                        
    select setting into : ___a___ from dictionary.options where optname='NOTES';                                                        
    %let __opt1__=&__opt1__ &___a___;                                                                                                   
    select setting into : ___a___ from dictionary.options where optname='SERROR';                                                       
    %let __opt1__=&__opt1__ &___a___;                                                                                                   
    quit;                                                                                                                               
    options noserror;                                                                                                                   
%end;                                                                                                                                   
%else %if "%upcase(&__use__)" NE "DATASTEP" and                                                                                         
          ((%scan(&sysver,1,'.') GT 6) OR                                                                                               
           (%scan(&sysver,1,'.') EQ 6 and %scan(&sysver,2,'.') GE 12)) %then %do;                                                       
  %let __opt1__=%qsysfunc(getoption(mprint));                                                                                           
  options nomprint;                                                                                                                     
  %let __opt1__=&__opt1__ %qsysfunc(getoption(symbolgen));                                                                              
  options nosymbolgen;                                                                                                                  
  %let __opt1__=&__opt1__ %qsysfunc(getoption(mlogic));                                                                                 
  options nomlogic;                                                                                                                     
  %let __opt1__=&__opt1__ %qsysfunc(getoption(macrogen));                                                                               
  %let __opt1__=&__opt1__ %qsysfunc(getoption(mtrace));                                                                                 
  %let __opt1__=&__opt1__ %qsysfunc(getoption(notes));                                                                                  
  %let __opt1__=&__opt1__ %qsysfunc(getoption(serror));                                                                                 
  options NOMPRINT NOMACROGEN NOMTRACE NONOTES NOSERROR;                                                                                
%end;                                                                                                                                   
                                                                                                                                        
%let __err__ =; %let _reason_=; %let __nobs__=; %let __nvar__=;                                                                         
%let __nlib__=; %let _nmvar_ =; %let __ncat__=; %let _wnobs_ =;                                                                         
                                                                                                                                        
%*-------------------------------------------------------------------------------;                                                      
%* Remove multiple blanks in macro variables                                     ;                                                      
%*-------------------------------------------------------------------------------;                                                      
                                                                                                                                        
                                                                                                                                        
%**v8** 200 char limit removed in the datastep statements below ***;                                                                    
%**v8** 200 char limit removed in the datastep statements below ***;                                                                    
%**v8** 200 char limit removed in the datastep statements below ***;                                                                    
%** cmpres is unfortunately an autocall routine which we cannot access **;                                                              
                                                                                                                                        
    %*if %length(&__lst__) ne 0 %then %let __lst__ = %cmpres(&__lst__);                                                                 
    %*if %length(&__ulst__) ne 0 %then %let __ulst__ = %cmpres(&__ulst__);                                                              
    %*if %length(&__vlst__) ne 0 %then %let __vlst__ = %cmpres(&__vlst__);                                                              
    %*if %length(&_upcase_) ne 0 %then %let _upcase_ = %cmpres(&_upcase_);                                                              
    %*if %length(&_oblig_) ne 0 %then %let _oblig_ = %cmpres(&_oblig_);                                                                 
    %*if %length(&_yesno_) ne 0 %then %let _yesno_ = %cmpres(&_yesno_);
    %*if %length(&_mexist_) ne 0 %then %let _mexist_ = %cmpres(&_mexist_);                                                              
    %*if %length(&___id___) ne 0 %then %let ___id___ = %cmpres(&___id___);                                                              
    %*if %length(&_sname_) ne 0 %then %let _sname_ = %cmpres(&_sname_);                                                                 
    %*if %length(&___mc___) ne 0 %then %let ___mc___ = %cmpres(&___mc___);                                                              
%if "%upcase(&__use__)" ne "DATASTEP" %then %do;                                                                                        
   /*****************                                                                                                                   
    ** The compression of blanks has been removed.        **                                                                            
    ** We want to avoid having to  put " around the macro **                                                                            
    ** since this will lead to warnings if the string is  **                                                                            
    ** longer than 262 characters.                        **                                                                            
   data _null_;                                                                                                                         
                                                                                                                                        
    call symput('__lst__', compbl("&__lst__"));                                                                                         
    call symput('__ulst__', compbl("&__ulst__"));                                                                                       
    call symput('__vlst__', compbl("&__vlst__"));                                                                                       
    call symput('_upcase_', compbl("&_upcase_"));                                                                                       
    call symput('_yesno_', compbl("&_yesno_"));                                                                                         
    call symput('_oblig_', compbl("&_oblig_"));                                                                                         
    call symput('_mexist_', compbl("&_mexist_"));                                                                                       
    call symput('___id___', compbl("&___id___"));                                                                                       
    call symput('_sname_', compbl("&_sname_"));                                                                                         
    call symput('___mc___', compbl("&___mc___"));                                                                                       
   run;                                                                                                                                 
        ****************************/                                                                                                   
%* This will remove trailing blanks *;                                                                                                  
    %let __lst__  = &__lst__;                                                                                                           
    %let __ulst__ = &__ulst__;                                                                                                          
    %let __vlst__ = &__vlst__;                                                                                                          
    %let _upcase_ = &_upcase_;                                                                                                          
    %let _yesno_  = &_yesno_;                                                                                                           
    %let _oblig_  = &_oblig_;                                                                                                           
    %let _mexist_ = &_mexist_;                                                                                                          
    %let ___id___ = &___id___;                                                                                                          
    %let _sname_ = &_sname_;                                                                                                            
    %let ___mc___ = &___mc___;                                                                                                          
    *call symput('_where_',compbl("&_where_"));;                                                                                        
                                                                                                                                        
    %*-- WHERE statement is not included since this is expected to include ;                                                            
    %*-- quotation marks.                                                  ;                                                            
                                                                                                                                        
  %if %length(&__lst__) EQ 1 %then %do;                                                                                                 
     %if "&__lst__" = " " %then %let __lst__ = ;                                                                                        
  %end;                                                                                                                                 
  %if %length(&__ulst__) EQ 1 %then %do;                                                                                                
    %if "&__ulst__" = " " %then %let __ulst__ = ;                                                                                       
  %end;                                                                                                                                 
  %if %length(&_upcase_) EQ 1 %then %do;
     %if "&_upcase_" = " " %then %let _upcase_ = ;                                                                                      
  %end;                                                                                                                                 
  %if %length(&_oblig_) EQ 1 %then %do;                                                                                                 
     %if "&_oblig_" = " " %then %let _oblig_ = ;                                                                                        
  %end;                                                                                                                                 
  %if %length(&_yesno_) EQ 1 %then %do;                                                                                                 
     %if "&_yesno_" = " " %then %let _yesno_ = ;                                                                                        
  %end;                                                                                                                                 
  %if %length(&___mc___) EQ 1 %then %do;                                                                                                
     %if "&___mc___" = " " %then %let ___mc___ = ;                                                                                      
  %end;                                                                                                                                 
  %if %length(&__vlst__) EQ 1 %then %do;                                                                                                
     %if "&__vlst__" = " " %then %let __vlst__ = ;                                                                                      
  %end;                                                                                                                                 
  %if %length(&_mexist_) EQ 1 %then %do;                                                                                                
     %if "&_mexist_" = " " %then %let _mexist_ = ;                                                                                      
  %end;                                                                                                                                 
  %if %length(&___id___) EQ 1 %then %do;                                                                                                
     %if "&___id___" = " " %then %let ___id___ = ;                                                                                      
  %end;                                                                                                                                 
  %if %length(&_sname_) EQ 1 %then %do;                                                                                                 
     %if "&_sname_" = " " %then %let _sname_ = ;                                                                                        
  %end;                                                                                                                                 
  %*if "&_where_" = " " %then %let _where_ = ;                                                                                          
%end;                                                                                                                                   
%*===============================================================================;                                                      
%* Internal logical checks                                                       ;                                                      
%*===============================================================================;                                                      
                                                                                                                                        
%*-------------------------------------------------------------------------------;                                                      
%* __AMSG__ and __MMSG__ should handle Yes and No as Y and N                     ;                                                      
%*-------------------------------------------------------------------------------;                                                      
%if       "%upcase(&__amsg__)" = "YES" %then %let __amsg__=Y;                                                                           
%else %if "%upcase(&__amsg__)" = "NO"  %then %let __amsg__=N;                                                                           
                                                                                                                                        
%if       "%upcase(&__mmsg__)" = "YES" %then %let __mmsg__=Y;                                                                           
%else %if "%upcase(&__mmsg__)" = "NO"  %then %let __mmsg__=N;                                                                           
                                                                                                                                        
%if %length(&__mmsg__) ne 0 and %upcase(&__mmsg__) NE Y and %upcase(&__mmsg__) NE N %then %do;                                          
   %put Invalid parameter for __mmsg__. Default value Y will be used.;                                                                  
   %let __mmsg__ = Y;                                                                                                                   
%end;                                                                                                                                   
%if %length(&__amsg__) ne 0 and %upcase(&__amsg__) NE Y and %upcase(&__amsg__) NE N %then %do;                                          
   %put Invalid parameter for __amsg__. Default value N will be used.;                                                                  
   %let __amsg__ = N;                                                                                                                   
%end;                                                                                                                                   

                                                                                                                                        
%*-------------------------------------------------------------------------------;                                                      
%* If __AMSG__=Y send Macro abort. string to SAS log else not                    ;                                                      
%*-------------------------------------------------------------------------------;                                                      
%if "%upcase(&__amsg__)" = "Y" %then %let __amsg__=%str( Macro aborts.);                                                                
%else %let __amsg__=;                                                                                                                   
                                                                                                                                        
                                                                                                                                        
%*-- Translate input parameters to uppercase ------------------------------------;                                                      
%*-- NB: _WHERE_ statement must not be converted to uppercase -------------------;                                                      
%*-- NB: By setting uppercases blank set by compblb above is removed ------------;                                                      
%let __dsn__ =%upcase(&__dsn__);           %let __lst__ =%upcase(&__lst__);                                                             
%let _exist_ =%upcase(&_exist_);           %let _vexist_=%upcase(&_vexist_);                                                            
%let __mmsg__=%upcase(&__mmsg__);          %let _vtype_ =%upcase(&_vtype_);                                                             
%let __use__ =%upcase(&__use__);           %let _yesno_ =%upcase(&_yesno_);                                                             
%let __vlst__=%upcase(&__vlst__);          %let _mexist_=%upcase(&_mexist_);                                                            
%let _upcase_=%upcase(&_upcase_);          %let _oblig_ =%upcase(&_oblig_);                                                             
%let ___mc___=%upcase(%bquote(&___mc___)); %let __lib__ =%upcase(&__lib__);                                                             
%let ___id___=%upcase(&___id___);          %let __mout__=%upcase(&__mout__);                                                            
%let __cat__ =%upcase(&__cat__);           %let _ctype_ =%upcase(&_ctype_);                                                             
%let __out__ =%upcase(&__out__);           %let _mtype_ =%upcase(&_mtype_);                                                             
%let __ulst__=%upcase(&__ulst__);          %let ___dm___=%upcase(&___dm___);                                                            
%let __file__=%upcase(&__file__);          %let _sname_ =%upcase(&_sname_);                                                             
                                                                                                                                        
%*--  __USE__ only blank or DATASTEP  --------------------------------------------;                                                     
%if ("&__use__" NE "" and "&__use__" NE "DATASTEP") %then %do;                                                                          
  %put Error: __USE__ must be blank or DATASTEP. &__amsg__;                                                                             
  %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                             
  %goto exit;                                                                                                                           
%end;                                                                                                                                   
                                                                                                                                        
%*--  __DSN__ not blank when _exist_ or ___id___ not blank ---;                                                                         
%if (%length(&__dsn__) = 0 ) and                                                                                                        
    ("&_exist_" = "Y"  or                                                                                                               
     %length(&___id___) ne 0 ) %then %do;                                                                                               
  %put Error: Please specify dataset SCA2UTIL(__DSN__=). &__amsg__;                                                                     
  %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                             
  %goto exit;                                                                                                                           
%end;                                                                                                                                   
                                                                                                                                        
%if (%length(&__vlst__) ne 0 and %length(&__lst__) eq 0 ) %then %do;                                                                    
   %put Error: Please specify variable list __LST__ when _VLST_ is specified. &__amsg__;                                                
   %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                            
   %goto exit;                                                                                                                          
%end;                                                                                                                                   
                                                                                                                                        
%if &_vexist_=Y and (%length(__lst__) eq 0 or %length(&__dsn__) eq 0 )                                                                  
    %then %do;                                                                                                                          
       %put Error: Please specify both __LST__ and __DSN__ when _VEXIST_ = Y. &__amsg__;                                                
       %let __err__ = ERROR; %let _reason_=SYNTAX;                                                                                      
       %goto exit;                                                                                                                      
%end;                                                                                                                                   
                                                                                                                                        
%if %length(&_vtype_) ne 0 and %length(&__lst__) = 0 %then %do;                                                                         
   %put Error: Please specify __LST__ when _VTYPE_ is specified. &__amsg__;                                                             
   %let __err__ = ERROR; %let _reason_ = SYNTAX;                                                                                        
   %goto exit;                                                                                                                          
%end;                                                                                                                                   
                                                                                                                                        
%*--  __MOUT__ only takes allowed values -----------------------------------------;                                                     
%*-- test existence first of all GSK 2001-02-28                                   ;                                                     
%if "&__mout__" ne "" %then %do;                                                                                                        
   %if ("&__mout__" ne "LABEL" and "&__mout__" ne "FORMAT" and                                                                          
        "&__mout__" ne "TYPE"  and "&__mout__" ne "LEVEL"  and                                                                          
        "&__mout__" ne "MIN"   and "&__mout__" ne "MAX"    and                                                                          
        "&__mout__" ne "NMISS" and "&__mout__" ne "MEAN"   and                                                                          
        "&__mout__" ne "STD"   and "&__mout__" ne "N"      ) %then %do;                                                                 
     %put Error: Value of __MOUT__ not valid. &__amsg__;                                                                                
     %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                          
     %goto exit;                                                                                                                        
   %end;                                                                                                                                
%end;                                                                                                                                   
                                                                                                                                        
%*--  _VTYPE_ only takes allowed values ------------------------------------------;                                                     
%*-- Check existence first GSK 2001-02-28                                         ;                                                     
%if "&_vtype_" ne "" %then %do;                                                                                                         
   %if (&_vtype_ ne NUM and &_vtype_ ne CHAR ) %then %do;                                                                               
     %put Error: Parameter _VTYPE_ must be NUM, CHAR or blank. &__amsg__;                                                               
     %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                          
     %goto exit;                                                                                                                        
   %end;                                                                                                                                
%end;                                                                                                                                   
                                                                                                                                        
%*--  _EXIST_only takes allowed values -------------------------------------------;                                                     
%if (&_exist_ ne Y  and &_exist_ ne N) or                                                                                               
    (&_vexist_ ne N and &_vexist_ ne Y) %then %do;                                                                                      
  %put Error: Parameters _EXIST_ and _VEXIST_ must be Y or N. &__amsg__;                                                                
  %let __err__=ERROR; %let _reason_=SYNTAX;                                                                                             
  %goto exit;                                                                                                                           
%end;                                                                                                                                   
                                                                                                                                        
%*--  _MTYPE_only takes allowed values -------------------------------------------;                                                     
%*-- Check existence first GSK 2001-02-28                                         ;                                                     
%if "&_mtype_" NE "" %then %do;                                                                                                         
   %if ("&_mtype_" ne "INTEGER" and "&_mtype_" ne "INTEGER2" and
        "&_mtype_" ne "NUM"     and "&_mtype_" ne "NUM2" ) %then %do;
     %put Error: Parameters _MTYPE_ must be NUM, NUM2, INTEGER or INTEGER2. &__amsg__;
     %let __err__=ERROR; %let _reason_=SYNTAX;
     %goto exit;
   %end;                                                                                                                                
%end;                                                                                                                                   
                                                                                                                                        
%*-------------------------------------------------------------------------------;                                                      
%* Check: The same no of words in __lst__ as in _ulst_                         ;                                                        
%*-------------------------------------------------------------------------------;                                                      
                                                                                                                                        
%if %length(&__lst__) ne 0  and %length(&__ulst__) ne 0 %then %do;                                                                      
  %let __temp__=;                                                                                                                       
  %let _iiiiii_=0;                                                                                                                      
  %do %until("&__temp__" NE "");                                                                                                        
    %let _iiiiii_=%eval(&_iiiiii_+1);                                                                                                   
    %if ("%scan(%bquote(&__lst__),&_iiiiii_,' ')"  EQ "" and                                                                            
         "%scan(%bquote(&__ulst__),&_iiiiii_,' ')" NE "")   or                                                                          
        ("%scan(%bquote(&__lst__),&_iiiiii_,' ')"  NE "" and                                                                            
         "%scan(%bquote(&__ulst__),&_iiiiii_,' ')" EQ "")                                                                               
        %then %let __temp__=X;                                                                                                          
    %else %if ("%scan(%bquote(&__lst__),&_iiiiii_,' ')"="" and                                                                          
               "%scan(%bquote(&__ulst__),&_iiiiii_,' ')"="")                                                                            
        %then %let __temp__=XXX;                                                                                                        
  %end;                                                                                                                                 
%end;                                                                                                                                   
%if "&__temp__"="X" %then %do;                                                                                                          
  %put Error: Not equal no of words in __LST__ and __ULST__ parameters. &__amsg__;                                                      
  %let __err__=ERROR; %let _reason_=EQLST;                                                                                              
  %goto exit;                                                                                                                           
%end;                                                                                                                                   
%else %let __temp__=;                                                                                                                   
                                                                                                                                        
%*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<;                                                      
%*           START MACRO EXECUTION                                               ;                                                      
%*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;                                                      
                                                                                                                                        
%*===============================================================================;                                                      
%* Send time stamp to log                                                       *;                                                      
%*===============================================================================;                                                      
%if "&___mn___" ne "" %then %do;                                                                                                        
  %if "&___mv___" ne "" %then %let ___mn___=%upcase(&___mn___ v&___mv___);                                                              
  %else %let ___mn___=%upcase(&___mn___);                                                                                               
  %let ___mt___=%upcase(&___mt___);                                                                                                     
  %if "&__use__" eq "" %then %do;               %**-- For use outside datastep --*;                                                     
    data _null_;                                                                                                                        
      call symput('___a___',put(date(),yymmdd6.));                                                                                      
      call symput('___b___',put(time(),hhmm5.));                                                                                        
      run;                                                                                                                              
  %end;                                                                                                                                 
                                                                                                                                        
  %if "&___mt___" ne "" %then                                                                                                           
        %put Note: &___mt___ macro &___mn___ started &___a___ &___b___ / SAS&sysver /&sysscpl;                                          
  %else %put Note: Macro &___mn___ started &___a___ &___b___ / SAS&sysver /&sysscpl;                                                    
  %let ___a___=;                                                                                                                        
  %let ___b___=;                                                                                                                        
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that macro variables are defined                                       *;                                                      
%*   99-loop has been changed to do until, SAS v8.                              *;                                                      
%*===============================================================================;                                                      
%let __temp__=&_mexist_ &_oblig_ &_yesno_ &_upcase_;                                                                                    
                                                                                                                                        
%if %bquote(&__temp__) NE %then %do ;                                                                                                   
  %let _iiiiii_= 1;                                                                                                                     
  %let ___a___=%scan(&__temp__,&_iiiiii_,' ');                                                                                          
  %do %until( "&___a___" EQ "" );                                                                                                       
     %if %nrbquote(&&&___a___) eq %nrstr(&)&___a___ %then %do;                                                                          
        %if &__mmsg__=Y %then                                                                                                           
           %put Error: Macro variable &___a___ not resolved. Macro aborts.;                                                             
        %let __err__=ERROR;                                                                                                             
        %let _reason_=RESOLVE;                                                                                                          
        %goto exit;                                                                                                                     
     %end;                                                                                                                              
     %let _iiiiii_ = %eval(&_iiiiii_+1);                                                                                                
     %let ___a___=%scan(&__temp__,&_iiiiii_,' ');                                                                                       
  %end;                                                                                                                                 
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Count no of words in text string                                              ;                                                      
%*   99-loop has been changed to do until, SAS v8.                               ;                                                      
%*===============================================================================;                                                      
%if %bquote(&___mc___) NE %then %do;                                                                                                    
  %let _nmvar_=;                                                                                                                        
  %let _iiiiii_ = 1;                                                                                                                    
  %do %until( "%scan(%bquote(&___mc___),&_iiiiii_,' ')" = "" );                                                                         
      %let _iiiiii_ = %eval(&_iiiiii_+1);                                                                                               
  %end;                                                                                                                                 
  %let _nmvar_=%eval(&_iiiiii_-1);                                                                                                      
%end;                                                                                                                                   
%else %let _nmvar_=0;                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Change resolved macro variables to uppercase                                 *;                                                      
%*   99-loop has been changed to do until                                       *;                                                      
%*===============================================================================;                                                      
%if %length(&_upcase_) NE 0 %then %do;                                                                                                  
   %let _jjjjjj_ = 1;                                                                                                                   
   %let ___a___  =%scan(&_upcase_,&_jjjjjj_,' ');                                                                                       
   %do %until( "&___a___" EQ "");                                                                                                       
      %let &___a___ = %upcase(&&&___a___);                                                                                              
      %let _jjjjjj_ = %eval(&_jjjjjj_+1);                                                                                               
      %let ___a___  = %scan(&_upcase_,&_jjjjjj_,' ');                                                                                   
   %end;                                                                                                                                
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that mandatory variables have been specified                           *;                                                      
%*   99-loop that has been changed to until  GSK 2001-01-30                     *;                                                      
%*===============================================================================;                                                      
%if %length(&_oblig_) ne 0 %then %do;                                                                                                   
   %if &__mmsg__=Y %then %put Note: Checking mandatory variables.;                                                                      
   %let _iiiiii_ = 1;                                                                                                                   
   %let ___a___=%scan(&_oblig_,&_iiiiii_,' ');                                                                                          
   %do %until( "&___a___" EQ "");                                                                                                       
      %if "&&&___a___"="" %then %do;                                                                                                    
         %if &__mmsg__=Y %then                                                                                                          
            %put Error: Variable &___a___ must be specified. &__amsg__;                                                                 
         %let __err__=ERROR;                                                                                                            
         %let _reason_=OBLIGVAR;                                                                                                        
      %end;                                                                                                                             
      %let _iiiiii_ = %eval(&_iiiiii_+1);                                                                                               
      %let ___a___  = %scan(&_oblig_,&_iiiiii_,' ');                                                                                    
   %end;                                                                                                                                
   %if "&__err__" = "ERROR" %then %goto exit;                                                                                           
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that boolean variables are Y, YES, N or NO                             *;                                                      
%*   20-loop that should be changed to until. SAS v8                            *;                                                      
%*===============================================================================;                                                      
%if %length(&_yesno_) ne 0 %then %do;                                                                                                   
  %if &__mmsg__=Y %then %put Note: Checking boolean var(s) &_yesno_.;                                                                   
  %let _iiiiii_ = 1;                                                                                                                    
  %let ___a___=%scan(&_yesno_,&_iiiiii_,' ');                                                                                           
  %do %until( "&___a___" EQ "");                                                                                                        
      %let &___a___=%upcase(&&&___a___);                                                                                                
      %if (("&&&___a___" ne "YES") and                                                                                                  
           ("&&&___a___" ne "Y")   and                                                                                                  
           ("&&&___a___" ne "NO")  and                                                                                                  
           ("&&&___a___" ne "N")) %then %do;                                                                                            
         %if &__mmsg__=Y %then %put Error: Boolean variable &___a___ must be Y, N, YES or NO. &__amsg__;                                
         %let __err__=ERROR;                                                                                                            
         %let _reason_=YESNO;                                                                                                           
         %goto exit;                                                                                                                    
      %end;                                                                                                                             
      %let &___a___=%substr(&&&___a___,1,1);                                                                                            
      %let _iiiiii_ = %eval(&_iiiiii_+1);                                                                                               
      %let ___a___  = %scan(&_yesno_,&_iiiiii_,' ');                                                                                    
  %end;                                                                                                                                 
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that macro variables define a valid SAS name                           *;                                                      
%*===============================================================================;                                                      
                                                                                                                                        
                                                                                                                                        
%**v8** Check if name lengths <= 32 instead of <= 8       ***;                                                                          
%**v8** Check if validvarname option = ANY. If so: Abort. ***;                                                                          
                                                                                                                                        
%if %length(&_sname_) ne 0 %then %do;                                                                                                   
  %if &__mmsg__=Y %then %put Note: Checking &_sname_ define valid SAS names;                                                            
                                                                                                                                        
  %*--- Get VALIDVARNAME option             ---*;                                                                                       
  %if %scan(&sysver,1,'.') GE 8 %then %do;                                                                                              
     proc sql noprint;                                                                                                                  
       select setting into : ___a___                                                                                                    
       from dictionary.options                                                                                                          
       where optname = 'VALIDVARNAME';                                                                                                  
     quit;                                                                                                                              
     %let ___a___=&___a___;  ** added to 3.0 **;                                                                                        
                                                                                                                                        
     %*--- Check if VALIDVARNAME option is ANY ---*;                                                                                    
     %*--- If ANY: error message, abort.       ---*;                                                                                    
     %if "&___a___"="ANY" %then %do;                                                                                                    
       %put Error: Macro not validated for SAS option setting: VALIDVARNAME=ANY. &__amsg__;                                             
       %let __err__=ERROR;                                                                                                              
       %let _reason_=SASNAME;                                                                                                           
       %goto exit;                                                                                                                      
     %end;                                                                                                                              
  %end;                                                                                                                                 
                                                                                                                                        
%* _vnlen_ is given maximum length of SAS variable name;                                                                                
                                                                                                                                        
  %*--------- check valid SAS variable name -----------------;                                                                          
  %let _iiiiii_ = 1;                                                                                                                    
  %let ___a___ = %scan(&_sname_, &_iiiiii_, ' ');                                                                                       
  %do %until( "&___a___" EQ "");                                                                                                        
      %if %length(&___a___) > &_vnlen_ %then %do;                                                                                       
          %put Error: &___a___ not a valid SAS name. &__amsg__;                                                                         
          %let __err__=ERROR;                                                                                                           
          %let _reason_=SASNAME;                                                                                                        
          %goto exit;                                                                                                                   
      %end;                                                                                                                             
      %else %if %length(&___a___)=1 and                                                                                                 
            "%sysfunc(compress(&___a___,0123456789&$+/\?=-*.:' ''('')'@#!))"=""                                                  
            %then %do;                                                                                                                  
                %*--- Check name if length=1 ------------------------------------;                                                      
                %put Error: &___a___ not a valid SAS name. &__amsg__;                                                                   
                %let __err__=ERROR;                                                                                                     
                %let _reason_=SASNAME;                                                                                                  
                %goto exit;                                                                                                             
      %end;                                                                                                                             
      %else %if "%sysfunc(compress(%substr(&___a___,1,1),0123456789&$+/\?=-*.:' ''('')'@#!))"=""                                 
            %then %do;                                                                                                                  
                %*--- Check first character in name -----------------------------;                                                      
                %put Error: &___a___ not a valid SAS name. &__amsg__;                                                                   
                %let __err__=ERROR;                                                                                                     
                %let _reason_=SASNAME;                                                                                                  
                %goto exit;                                                                                                             
      %end;                                                                                                                             
      %else %do;                                                                                                                        
        %*--- Check name besides first character ------------------------;                                                              
        %if %length(&___a___) > 1 %then %do;                                                                                            
           %let ___b___=%bquote(%substr(&___a___,2,%length(&___a___)-1));                                                               
           %if %length(%sysfunc(compress(&___b___,&$+/\?=-*.:' ''('')'@#!))) ne                                                  
               %length(&___b___) %then %do;                                                                                             
                  %put Error: &___a___ not a valid SAS name. &__amsg__;                                                                 
                  %let __err__=ERROR;                                                                                                   
                  %let _reason_=SASNAME;                                                                                                
                  %goto exit;                                                                                                           
           %end;                                                                                                                        
        %end; %*-End of length > 1 section -*;                                                                                          
      %end;                                                                                                                             
      %let _iiiiii_ = %eval(&_iiiiii_+1);                                                                                               
      %let ___a___ = %scan(&_sname_, &_iiiiii_, ' ');                                                                                   
   %end; %* until loop ends *;                                                                                                          
                                                                                                                                        
  %let ___a___=; %let ___b___=;                                                                                                         
%end;    %* sname check ends *;                                                                                                         
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that macro variables are of certain type                               *;                                                      
%*===============================================================================;                                                      
                                                                                                                                        
%**v8** $40 here only states that the first 40 characters are used in the input. OK for v8, no update ****;                             
%**v8** $40 here only states that the first 40 characters are used in the input. OK for v8, no update ****;                             
%**v8** $40 here only states that the first 40 characters are used in the input. OK for v8, no update ****;                             
                                                                                                                                        
%if %length(&_mexist_) ne 0 and %length(&_mtype_) ne 0 %then %do;                                                                       
  %let _iiiiii_=1;                                                                                                                      
  %let ___a___=%upcase(%scan(&_mexist_,&_iiiiii_,' '));                                                                                 
  data _null_;                                                                                                                          
    length _b_ _c_ $ 40;                                                                                                                
                                                                                                                                        
    %do %until("&__err__"="ERROR" or "&___a___"="");                                                                                    
                                                                                                                                        
      _b_="&&&___a___";                                                                                                                 
      _c_=compress(_b_);                                                                                                                
                                                                                                                                        
      if _c_ NE '' then do;                                                                                                             
        %if ("&_mtype_"="NUM" or  "&_mtype_"="NUM2" or                                                                                  
             "&_mtype_"="INTEGER" or "&_mtype_"="INTEGER2") %then %do;
           a=input(_b_,?? 32.);
           %if ("&_mtype_"="NUM" or "&_mtype_"="NUM2") %then %do;
             if a=. then do;
               %if "&__mmsg__"="Y" %then
                  %str(put "Error: Value of &___a___ not numeric. &__amsg__";);
               call symput('__err__','ERROR');
               call symput('_reason_','MNOTNUM');
             end;
           %end;
           %if ("&_mtype_"="INTEGER" or "&_mtype_"="INTEGER2") %then %do;
              if a=. or abs(a)-int(abs(a))>0 then do;
                %if "&__mmsg__"="Y" %then
                   %str(put "Error: Value of &___a___ not integer. &__amsg__";);
                call symput('__err__','ERROR');
                call symput('_reason_','MNOTINT');
              end;
           %end;
        %end;
      end;
      else do;
        %if "&_mtype_"="INTEGER" %then %do; /* 030826 removed  or "&_mtype_"="INTEGER2" */
          %if "&__mmsg__"="Y" %then
             %str(put "Error: Value of &___a___ not integer. &__amsg__";);
          call symput('__err__','ERROR');
          call symput('_reason_','MNOTINT');
        %end;
        %else %if "&_mtype_"="NUM" %then %do;  /* 030826 removed  or "&_mtype_"="NUM2" */
          %if "&__mmsg__"="Y" %then
             %str(put "Error: Value of &___a___ not numeric. &__amsg__";);
          call symput('__err__','ERROR');
          call symput('_reason_','MNOTNUM');
        %end;
      end;                                                                                                                              
      %let _iiiiii_ = %eval(&_iiiiii_+1);                                                                                               
      %let ___a___  = %upcase(%scan(&_mexist_,&_iiiiii_,' '));                                                                          
                                                                                                                                        
    %end; %*-UNTIL-loop ends-*;                                                                                                         
                                                                                                                                        
    run;                                                                                                                                
    %if &__err__=ERROR %then %goto EXIT;                                                                                                
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Test that libname exist and count no of datasets                              ;                                                      
%*===============================================================================;                                                      
%if (%length(&__lib__) ne 0 and "&__use__"="") %then %do;                                                                               
  %if &__mmsg__=Y %then                                                                                                                 
     %put Note: Check that libname &__lib__ exist.;                                                                                     
  %if %qsysfunc(libref(&__lib__)) ne 0 %then %do;                                                                                       
    %if &__mmsg__=Y %then                                                                                                               
       %put Error: Libname &__lib__ does not exist. &__amsg__;                                                                          
    %let __err__=ERROR;                                                                                                                 
    %let _reason_=LIBEXIST;                                                                                                             
    %goto exit;                                                                                                                         
  %end;                                                                                                                                 
  %else %do;                                                                                                                            
    proc sql noprint;                                                                                                                   
      select count(*) into : __nlib__                                                                                                   
      from sashelp.vstabvw                                                                                                              
      where (libname = "&__lib__" and                                                                                                   
             memtype in ('DATA','VIEW'));                                                                                               
    quit;                                                                                                                               
  %end;                                                                                                                                 
  %let __nlib__=&__nlib__;                                                                                                              
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Test that catalog exist and count no of members                                                                                      
%*===============================================================================;                                                      
%if (%length(&__cat__) ne 0 and "&__use__"="") %then %do;                                                                               
                                                                                                                                        
  %let ___l___=%scan(&__cat__,1,'.');                                                                                                   
  %let ___d___=%scan(&__cat__,2,'.');                                                                                                   
  %if %length(&___d___)=0 %then %do;                                                                                                    
    %let ___d___=%scan(&__cat__,1,'.');                                                                                                 
    %let ___l___=WORK;                                                                                                                  
  %end;                                                                                                                                 
                                                                                                                                        
  %if &__mmsg__=Y %then %put Note: Check that catalog &__cat__ exist.;                                                                  
  %*-- Check for catalog existence ----------------------------------;                                                                  
  proc sql noprint;                                                                                                                     
    select count(memname) into : __ncat__                                                                                               
    from dictionary.members                                                                                                             
    where (libname = "&___l___" and                                                                                                     
           memname = "&___d___" and                                                                                                     
           memtype = 'CATALOG');                                                                                                        
    quit;                                                                                                                               
                                                                                                                                        
  %let __ncat__=&__ncat__;  ** added to 3.0 **;                                                                                         
                                                                                                                                        
  %if &__ncat__=0  %then %do;                                                                                                           
    %if &__mmsg__=Y %then %put Error: Catalog &__cat__ do not exist. &__amsg__;                                                         
    %let __err__=ERROR; %let _reason_=CATEXIST; %let __ncat__=;                                                                         
    %goto exit;                                                                                                                         
  %end;                                                                                                                                 
  %else %do;                                                                                                                            
    %*-- Count no of members ------------------------------------------;                                                                
    %let _ctype_=&_ctype_;                                                                                                              
    proc sql noprint;                                                                                                                   
      select count(memname) into : __ncat__                                                                                             
      from dictionary.catalogs                                                                                                          
      where (libname = "&___l___" and                                                                                                   
             memname = "&___d___" and                                                                                                   
             memtype = 'CATALOG'                                                                                                        
             %if "&_ctype_" ne "" %then %do;                                                                                            
                and upcase(objtype) = upcase("&_ctype_")                                                                                
             %end;                                                                                                                      
             );                                                                                                                         
      quit;                                                                                                                             
                                                                                                                                        
      %let __ncat__=&__ncat__;  ** added to 3.0 **;                                                                                     
                                                                                                                                        
    %if &__ncat__=0 %then %do;                                                                                                          
      %let _reason_=CATEMPTY;                                                                                                           
      %let __err__=ERROR;                                                                                                               
      %if &__mmsg__=Y %then %put Note: Catalog &__cat__ is empty.;                                                                      
    %end;                                                                                                                               
  %end;                                                                                                                                 
  %let __ncat__=%scan(&__ncat__,1);                                                                                                     
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that dataset exist;                                                                                                            
%*===============================================================================;                                                      
%if ("&_exist_"="Y" and "&__dsn__" ne "" and "&__use__"="") %then %do;                                                                  
  %if &__mmsg__=Y %then %put Note: Check that dataset &__dsn__ exist.;                                                                  
                                                                                                                                        
  %let ___l___=%scan(&__dsn__,1,'.');                                                                                                   
  %let ___d___=%scan(&__dsn__,2,'.');                                                                                                   
  %if %length(&___d___)=0 %then %do;                                                                                                    
    %let ___d___=%scan(&__dsn__,1,'.');                                                                                                 
    %let ___l___=WORK;                                                                                                                  
  %end;                                                                                                                                 
%* Using open function did not work because of open with V-option in START;                                                             
%* This code has never been in production                                 ;                                                             
%macro bort1;                                                                                                                           
  %let ___d___ = &___l___..&___d___;                                                                                                    
                                                                                                                                        
  %if %sysfunc(exist(&___d___)) %then %let __dsid__ = %sysfunc(open(&___d___));                                                         
  %else %do;                                                                                                                            
      %let __err__=ERROR; %let _reason_=DSNEXIST;%let __dsid__ = 0;                                                                     
      %goto exitbort;                                                                                                                   
  %end;                                                                                                                                 
  %let __nobs__ = %sysfunc( attrn( &__dsid__, nlobs));                                                                                  
  %let __nvar__ = %sysfunc( attrn( &__dsid__, nvar));                                                                                   
                                                                                                                                        
  %if &__nobs__=0 and                                                                                                                   
      %length(%str(%bquote(&_where_))) GT 0                                                                                             
      %then %let _wnobs_=0;                                                                                                             
                                                                                                                                        
  %if (&__nvar__=0) %then %do;                                                                                                          
    %if &__mmsg__=Y %then                                                                                                               
      %put Error: No variables in dataset &___x___;                                                                                     
    %let __err__=ERROR;                                                                                                                 
    %let _reason_=VAREXIST;                                                                                                             
    %let __dsid__ = 0;                                                                                                                  
    %goto exitbort;                                                                                                                     
  %end;                                                                                                                                 
  %else %if (&__nobs__=0) %then %do;                                                                                                    
    %if &__mmsg__=Y %then                                                                                                               
       %put Error: Dataset &___x___ is empty. &__amsg__;                                                                                
    %let __err__=ERROR;                                                                                                                 
    %let _reason_=DSNEMPTY;                                                                                                             
    %let __dsid__ = 0;                                                                                                                  
    %goto exitbort;                                                                                                                     
  %end;                                                                                                                                 
  %if &__dsid__ ne 0 %then %let __dsid__ = %sysfunc( close( &__dsid__ ));                                                               
  %exitbort:                                                                                                                            
%mend;                                                                                                                                  
                                                                                                                                        
%*****macro bort1;                                                                                                                      
 %*  this code should have been replaced by function calls above ;                                                                      
 %*  GSK 2001-03-02                                              ;                                                                      
  proc sql noprint;                                                                                                                     
    select memtype into : __temp__                                                                                                      
    from dictionary.members                                                                                                             
    where (libname = "&___l___" and                                                                                                     
           memname = "&___d___" and                                                                                                     
           memtype in ('DATA','VIEW'));                                                                                                 
  run;quit;                                                                                                                             
                                                                                                                                        
  %let __temp__=&__temp__;  ** added to 3.0 **;                                                                                         
                                                                                                                                        
  %if &__temp__= %then %do;                                                                                                             
    %if &__mmsg__=Y %then %put Error: Dataset &__dsn__ does not exist. &__amsg__;                                                       
    %let __err__=ERROR; %let _reason_=DSNEXIST;                                                                                         
    %*goto exit;                                                                                                                        
    %goto exitbort;                                                                                                                     
  %end;                                                                                                                                 
  %else %do;                                                                                                                            
    proc sql noprint;                                                                                                                   
      select nvar into :__nvar__                                                                                                        
      from dictionary.tables                                                                                                            
      where (libname = "&___l___" and                                                                                                   
             memname = "&___d___" and                                                                                                   
             memtype in ('DATA','VIEW'));                                                                                               
                                                                                                                                        
      select nobs into :__nobs__                                                                                                        
      from dictionary.tables                                                                                                            
      where (libname ="&___l___" and                                                                                                    
             memname ="&___d___" and                                                                                                    
             memtype in ('DATA','VIEW'));                                                                                               
    quit;                                                                                                                               
    run;                                                                                                                                
                                                                                                                                        
    %let __nobs__=&__nobs__;  ** added to 3.0 **;                                                                                       
    %let __nvar__=&__nvar__;                                                                                                            
  %end;                                                                                                                                 
  %if &__nobs__=0 and                                                                                                                   
      %length(%str(%bquote(&_where_))) GT 0                                                                                             
      %then %let _wnobs_=0;                                                                                                             
                                                                                                                                        
  %if (&__temp__^= and &__nvar__=0) %then %do;                                                                                          
    %if &__mmsg__=Y %then                                                                                                               
      %put Error: No variables in dataset &__dsn__. &__amsg__;                                                                          
    %let __err__=ERROR;                                                                                                                 
    %let _reason_=VAREXIST;                                                                                                             
    %*goto exit;                                                                                                                        
    %goto exitbort;                                                                                                                     
  %end;                                                                                                                                 
  %else %if (&__temp__ NE  and &__nobs__=0) %then %do;                                                                                  
    %if &__mmsg__=Y %then                                                                                                               
       %put Error: Dataset &__dsn__ is empty. &__amsg__;                                                                                
    %let __err__=ERROR;                                                                                                                 
    %let _reason_=DSNEMPTY;                                                                                                             
    %*goto exit;                                                                                                                        
    %goto exitbort;                                                                                                                     
  %end;                                                                                                                                 
%exitbort:                                                                                                                              
%***mend;                                                                                                                               
                                                                                                                                        
%if &__err__ = ERROR %then %goto exit;                                                                                                  
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that input variables in macro variable __lst__ exists in dataset and    ;                                                      
%* are of a certain type                                                         ;                                                      
%*===============================================================================;                                                      
                                                                                                                                        
%if ("&_vexist_"="Y" and %bquote(&__lst__) NE and "&__use__"="") %then %do;                                                             
                                                                                                                                        
  %if &__mmsg__=Y %then %do;                                                                                                            
    %if &_vtype_= %then                                                                                                                 
       %put Note: Check that var(s) &__lst__ exist in &__dsn__.;                                                                        
    %else                                                                                                                               
       %put Note: Check that var(s) &__lst__ exist in &__dsn__ and are of &_vtype_ type.;                                               
  %end;                                                                                                                                 
                                                                                                                                        
  %let ___l___=%scan(&__dsn__,1,'.');                                                                                                   
  %let ___d___=%scan(&__dsn__,2,'.');                                                                                                   
                                                                                                                                        
  %if %length(&___d___)=0 %then %do;                                                                                                    
    %let ___d___=%scan(&__dsn__,1,'.');                                                                                                 
    %let ___l___=WORK;                                                                                                                  
  %end;                                                                                                                                 
                                                                                                                                        
%* move this select out of the loop;                                                                                                    
                                                                                                                                        
    proc sql;                                                                                                                           
      create table dummy as                                                                                                             
      select libname, memname, memtype, name, type                                                                                      
      from dictionary.columns                                                                                                           
      where (libname = "&___l___" and                                                                                                   
             memname = "&___d___" and                                                                                                   
             memtype in ('DATA', 'VIEW') );                                                                                             
    quit;                                                                                                                               
    run;                                                                                                                                
                                                                                                                                        
                                                                                                                                        
%* make tests against dummy below;                                                                                                      
                                                                                                                                        
  %let _iiiiii_=1;                                                                                                                      
  %let ___a___=%scan(&__lst__,&_iiiiii_,' ');                                                                                           
  %do %until("&___a___"="");                                                                                                            
    %let ___t___=;                                                                                                                      
                                                                                                                                        
                                                                                                                                        
%**v8** The name comparison is done with the UPCASE function to override mixed case in dictionary**;                                    
%**v8** The name comparison is done with the UPCASE function to override mixed case in dictionary**;                                    
%**v8** The name comparison is done with the UPCASE function to override mixed case in dictionary**;                                    
                                                                                                                                        
    proc sql noprint;                                                                                                                   
      select upcase(type) into : ___t___                                                                                                
      from dummy                                                                                                                        
      where ( upcase(name) = upcase("&___a___"));                                                                                       
    quit;                                                                                                                               
                                                                                                                                        
    %let ___t___=&___t___; ** added to 3.0 **;                                                                                          
                                                                                                                                        
    %if &___t___= %then %do;                                                                                                            
      %if &__mmsg__=Y %then                                                                                                             
         %put Error: Variable &___a___ not in dataset &__dsn__. &__amsg__;                                                              
      %let __err__=ERROR;                                                                                                               
      %let _reason_=VAREXIST;                                                                                                           
    %end;                                                                                                                               
    %else %if (&_vtype_ ne ) %then %do;                                                                                                 
      %if &___t___ NE &_vtype_ %then %do;                                                                                               
        %if &__mmsg__=Y %then                                                                                                           
           %put Error: Variable &___a___ not of &_vtype_ type. &__amsg__;                                                               
        %if &_vtype_=NUM %then %let _reason_=VARNOTN;                                                                                   
        %else %if &_vtype_=CHAR %then %let _reason_=VARNOTC;                                                                            
        %let __err__=ERROR;                                                                                                             
      %end;                                                                                                                             
    %end;                                                                                                                               
    %if "&__err__"="ERROR" %then %do;                                                                                                   
       %goto exit;                                                                                                                      
       proc datasets lib=work mt=data nolist;                                                                                           
          delete dummy;                                                                                                                 
       quit;                                                                                                                            
    %end;                                                                                                                               
    %let _iiiiii_=%eval(&_iiiiii_+1);                                                                                                   
    %let ___a___=%scan(&__lst__,&_iiiiii_,' ');                                                                                         
  %end;                                                                                                                                 
  proc datasets lib=work mt=data nolist;                                                                                                
  delete dummy;                                                                                                                         
  quit;                                                                                                                                 
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check that replicte records do not exist in dataset                          *;                                                      
%* attrn-call tried GSK 2001-03-02                                              *;                                                      
%*===============================================================================;                                                      
%if (%length(&__dsn__) NE 0 and %length(&___id___) NE 0  and "&__use__" = "")%then %do;                                                 
  %if &__mmsg__=Y %then                                                                                                                 
    %put Note: Checking &__dsn__ for replicate levels of &___id___ variables;                                                           
  %let ___l___=%scan(&__dsn__,1,'.');                                                                                                   
  %let ___d___=%scan(&__dsn__,2,'.');                                                                                                   
  %if %length(&___d___)=0 %then %do;                                                                                                    
    %let ___d___=&___l___;                                                                                                              
    %let ___l___=WORK;                                                                                                                  
  %end;                                                                                                                                 
                                                                                                                                        
  proc sort data=&__dsn__ out=___X___(keep=&___id___) nodupkey;                                                                         
     by &___id___;                                                                                                                      
  run;                                                                                                                                  
                                                                                                                                        
%* This code has never been in production due to problems with the open function ;                                                      
%macro bort2;                                                                                                                           
%* attrn introduced GSK 2001-03-01;                                                                                                     
  %let ___d___ = &___l___..&___d___;                                                                                                    
                                                                                                                                        
  %let  __dsid__ = %sysfunc(open(&___d___, i));                                                                                         
  %let ___a___ = %sysfunc( attrn( &__dsid__, nlobs));                                                                                   
  %if &__dsid__ > 0 %then %let rc=%sysfunc(close(&__dsid__));                                                                           
                                                                                                                                        
  %let __dsid__ = %sysfunc( open(&___X___));                                                                                            
  %let ___b___ =%sysfunc( attrn(&__dsid__, nlobs));                                                                                     
  %if &__dsid__ ne 0 %then %let __dsid__ = %sysfunc( close(&__dsid__));                                                                 
%mend;                                                                                                                                  
                                                                                                                                        
%*******macro bort2;                                                                                                                    
                                                                                                                                        
  %*This code should have been replaced by the code above GSK 2001-03-02;                                                               
  proc sql noprint;                                                                                                                     
    select nobs into :___a___ from dictionary.tables                                                                                    
    where (libname = upcase("&___l___") and                                                                                             
           memname = upcase("&___d___") and                                                                                             
           memtype in ('DATA','VIEW'));                                                                                                 
  proc sql noprint;                                                                                                                     
    select nobs into :___b___ from dictionary.tables                                                                                    
    where (libname = "WORK" and                                                                                                         
           memname = "___X___" and                                                                                                      
           memtype in ('DATA','VIEW'));                                                                                                 
  quit;                                                                                                                                 
  run;                                                                                                                                  
                                                                                                                                        
%****mend;                                                                                                                              
                                                                                                                                        
    %let ___a___=&___a___;  ** added to 3.0 **;                                                                                         
    %let ___b___=&___b___;  ** added to 3.0 **;                                                                                         
                                                                                                                                        
  proc datasets lib=work mt=data nolist;                                                                                                
     delete ___X___;                                                                                                                    
  quit;                                                                                                                                 
                                                                                                                                        
  %if &___a___ NE &___b___ %then %do;                                                                                                   
    %if &__mmsg__=Y %then %do;                                                                                                          
        %put Error: Replicate &___id___ levels in dataset &__dsn__.. &__amsg__;                                                         
        %put .      Total no of obs &___a___ , no of unique obs &___b___ . ;                                                            
    %end;                                                                                                                               
    %let __err__=ERROR;                                                                                                                 
    %let _reason_=REPLREC;                                                                                                              
    %goto exit;                                                                                                                         
  %end;                                                                                                                                 
                                                                                                                                        
%end;                                                                                                                                   
                                                                                                                                        
%if (%bquote(&__lst__) NE and %length(&__vlst__) NE 0 and &__use__= ) %then %do;                                                        
  %*=============================================================================;                                                      
  %* Check that numeric variable list in variable __lst__ are within the ranges  ;                                                      
  %* determined by the list of ranges in variable __vlst__                       ;                                                      
  %*                                                                             ;                                                      
  %* Valid values for __vlst__ is                                                ;                                                      
  %* <5 <=5 >5 >=5 =5                                                            ;                                                      
  %* (1_2_3_4)                                                                   ;                                                      
  %* 1<*<2 1<=*<2 1<*<=2 1<=*<=2                                                 ;                                                      
  %* integer                                                                     ;                                                      
  %*=============================================================================;                                                      
                                                                                                                                        
  %if &__mmsg__=Y %then                                                                                                                 
     %put Note: Check that variables &__lst__ are of type &__vlst__;                                                                    
                                                                                                                                        
  %let ___c1___= ;                                                                                                                      
  %let ___c2___= ;                                                                                                                      
                                                                                                                                        
  %do _iiiiii_=1 %to 99;                                                                                                                
                                                                                                                                        
    %let ___a___=%scan(&__lst__,&_iiiiii_,' ');                                                                                         
    %let ___b___=%scan(&__vlst__,&_iiiiii_,' ');                                                                                        
    %if "&___a___"="" %then %let _iiiiii_=99;                                                                                           
    %else %if "&___b___"="INTEGER" %then %do;                                                                                           
      %if "&___a___"="__CHK1__" %then %do;                                                                                              
        %put Error: Variable name __CHK1__ can not be used with __VLST__=INTEGER. &__amsg__;                                            
        %let __err__=ERROR;                                                                                                             
        %let _reason_=SYNTAX;                                                                                                           
        %goto exit;                                                                                                                     
      %end;                                                                                                                             
      data _null_;                                                                                                                      
        retain __chk1__ 0;                                                                                                              
        set &__dsn__(keep=&___a___) end=eof;                                                                                            
        if &___a___ - int(&___a___) GT 0 then __chk1__=1;                                                                               
        if eof then do;                                                                                                                 
          if __chk1__=1 then do;                                                                                                        
            if "&__mmsg__"="Y" then                                                                                                     
               put "Error: Variable &___a___ contains non-integer value(s). &__amsg__";                                                 
            call symput('__err__','ERROR');                                                                                             
            call symput('_reason_','VLST');                                                                                             
          end;                                                                                                                          
        end;                                                                                                                            
        run;                                                                                                                            
      %if "&__err__"="ERROR" %then %goto exit;                                                                                          
    %end;                                                                                                                               
    %else %do;                                                                                                                          
      %if "%substr(&___b___,1,1)"="(" %then %do;                                                                                        
        data _null_;                                                                                                                    
          call symput('___b___',translate("&___b___",',','_'));                                                                         
          run;                                                                                                                          
      %end;                                                                                                                             
      %let ___c2___=%scan(&___b___,2,'*');                                                                                              
      %if "&___c2___" ne "" %then %let ___c1___=%scan(&___b___,1,'*');                                                                  
      data _null_;                                                                                                                      
        retain __chk1__ 0;                                                                                                              
        set &__dsn__(keep=&___a___) end=eof;                                                                                            
                                                                                                                                        
        %if "&___c1___" ne "" and "&___c2___" ne "" %then %do;                                                                          
          if NOT (&___a___ &___c2___) OR NOT (&___c1___ &___a___) then __chk1__=1;                                                      
        %end;                                                                                                                           
        %else %if "%substr(&___b___,1,1)"="(" %then %do;                                                                                
          if &___a___ not in &___b___ then __chk1__=2;                                                                                  
        %end;                                                                                                                           
        %else %do;                                                                                                                      
          if &___a___ not &___b___ then __chk1__=3;                                                                                     
        %end;                                                                                                                           
                                                                                                                                        
        if eof then do;                                                                                                                 
          if __chk1__=1 then do;                                                                                                        
            if "&__mmsg__"="Y" then put "Error: Variable &___a___ not in list of valid values &___b___. &__amsg__";                     
            call symput('__err__','ERROR'); call symput('_reason_','VLST');                                                             
          end;                                                                                                                          
          else if __chk1__=2 then do;                                                                                                   
            if "&__mmsg__"="Y" then put "Error: Variable &___a___ not in list of valid values &___b___. &__amsg__";                     
            call symput('__err__','ERROR'); call symput('_reason_','VLST');                                                             
          end;                                                                                                                          
          else if __chk1__=3 then do;                                                                                                   
            if "&__mmsg__"="Y" then put "Error: Variable &___a___ not in list of valid values &___a___ &___b___. &__amsg__";            
            call symput('__err__','ERROR'); call symput('_reason_','VLST');                                                             
          end;                                                                                                                          
        end;                                                                                                                            
        run;                                                                                                                            
      %if "&__err__"="ERROR" %then %goto exit;                                                                                          
                                                                                                                                        
    %end;                                                                                                                               
    %let ___a___= ;                                                                                                                     
    %let ___b___= ;                                                                                                                     
  %end;                                                                                                                                 
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check where statement                                                         :                                                      
%*===============================================================================;                                                      
%if (%length(%str(%bquote(&_where_))) GT 0 and                                                                                          
     "&__dsn__" ne "" and "&__use__"="") %then %do;                                                                                     
  %if &__mmsg__=Y %then %do;                                                                                                            
    %if "&__out__"="" %then                                                                                                             
       %put Note: Checking where statement: SET &__dsn__(where=(&_where_)).;                                                            
    %else                                                                                                                               
       %put Note: Subsetting dataset &__dsn__(where=(&_where_)).;                                                                       
  %end;                                                                                                                                 
  proc sql noprint;                                                                                                                     
    select setting into : ___a___                                                                                                       
    from dictionary.options                                                                                                             
    where optname = 'DSNFERR';                                                                                                          
                                                                                                                                        
    %let ___a___=&___a___;  ** added to 3.0 **;                                                                                         
                                                                                                                                        
    %if &___a___ NE DSNFERR %then %str(option dsnferr;);                                                                                
    %if "&__out__" ne "" %then %str(create table &__out__ as select *);                                                                 
    %else %str(select *);                                                                                                               
    from &__dsn__                                                                                                                       
    where &_where_;                                                                                                                     
    options &___a___;                                                                                                                   
                                                                                                                                        
    %if &sqlrc > 0 %then %do;                                                                                                           
       quit;                                                                                                                            
       %if &__mmsg__=Y %then                                                                                                            
          %put Error: WHERE=%str(%bquote(&_where_)) is not correct. &__amsg__;                                                          
       %let __err__=ERROR;                                                                                                              
       %let _reason_=WHERE;                                                                                                             
       %let _wnobs_=0;                                                                                                                  
       %goto exit;                                                                                                                      
    %end;                                                                                                                               
    %else %do;                                                                                                                          
      select count (*) into : ___ag___                                                                                                  
      from &__dsn__                                                                                                                     
      where &_where_;                                                                                                                   
      quit;                                                                                                                             
                                                                                                                                        
      %let ___ag___=&___ag___;  ** added to 3.0 **;                                                                                     
                                                                                                                                        
      %if &___ag___ = 0 %then %do;                                                                                                      
         %if &__mmsg__=Y %then                                                                                                          
           %put Error: WHERE=%str(%bquote(&_where_)). No data selected. &__amsg__;                                                      
         %let __err__=ERROR;                                                                                                            
         %let _reason_=WHERE;                                                                                                           
         %let _wnobs_=0;                                                                                                                
         %goto exit;                                                                                                                    
      %end;                                                                                                                             
      %else %do;                                                                                                                        
        %let _wnobs_=&___ag___;                                                                                                         
        %if &__mmsg__=Y %then                                                                                                           
           %put Note: No of data after where clause: &_wnobs_;                                                                          
      %end;                                                                                                                             
    %end;                                                                                                                               
    %let ___a___=;                                                                                                                      
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Create global macrovariables LABEL, FORMAT, TYPE, or LEVEL                    :                                                      
%*===============================================================================;                                                      
                                                                                                                                        
%**v8** lagt till upcase p name nedan**;                                                                                               
%**v8** lagt till upcase p name nedan**;                                                                                               
%**v8** lagt till upcase p name nedan**;                                                                                               
                                                                                                                                        
                                                                                                                                        
%if (%bquote(&__lst__) NE and "&__mout__" ne "" and "&__use__"="") %then %do;                                                           
  %let ___l___=%scan(&__dsn__,1,'.');                                                                                                   
  %let ___d___=%scan(&__dsn__,2,'.');                                                                                                   
  %if %length(&___d___)=0 %then %do;                                                                                                    
    %let ___d___=%scan(&__dsn__,1,'.');                                                                                                 
    %let ___l___=WORK;                                                                                                                  
  %end;                                                                                                                                 
                                                                                                                                        
                                                                                                                                        
  %if ("&__mout__"="LABEL" or "&__mout__"="FORMAT" or "&__mout__"="TYPE") %then                                                         
    %do _iiiiii_=1 %to 99;                                                                                                              
       %let ___a___=%scan(&__lst__,&_iiiiii_,' ');                                                                                      
       %if "&___a___" ne "" %then %do;                                                                                                  
         %let ___b___=%scan(&__ulst__,&_iiiiii_,' ');                                                                                   
                                                                                                                                        
         %if "&sysver" ne "6.08" and "&___b___"="" %then %do;                                                                           
                                                                                                                                        
            %* is there already a macro variable with the same name as the column in lst?;                                              
            %* Used to be scope NOT in GLOBAL SCA2UTIL;                                                                                 
            %* Changed 2001-03-13 GSK;                                                                                                  
            proc sql noprint;                                                                                                           
               select count(scope) into : __ag__ from sashelp.vmacro                                                                    
               where (upcase(name) = upcase("&___a___") and                                                                             
                      scope NOT in ('GLOBAL','SCA2UTIL'));                                                                              
            quit;                                                                                                                       
            run;                                                                                                                        
                                                                                                                                        
            %let __ag__=&__ag__;  ** added to 3.0 **;                                                                                   
                                                                                                                                        
            %if &__ag__=0 %then %do;                                                                                                    
               %put Note: Global macro variable %upcase(&___a___) defined;                                                              
               %global &___a___;                                                                                                        
            %end;                                                                                                                       
                                                                                                                                        
            proc sql noprint;                                                                                                           
               select &__mout__ into : &___a___                                                                                         
               from dictionary.columns                                                                                                  
               where (libname = "&___l___" and                                                                                          
                      memname = "&___d___" and                                                                                          
                      memtype in ('DATA','VIEW') and                                                                                    
                      upcase(name) = upcase("&___a___"));                                                                               
            quit;                                                                                                                       
                                                                                                                                        
            %let ___a___=&___a___;  ** added to 3.0 **;                                                                                 
                                                                                                                                        
            %let ___r___=%length(&&&___a___);                                                                                           
            %if &___r___ GT 0 %then %let &___a___=%substr(%bquote(&&&___a___),1,&___r___);                                              
            %else %let &___a___=;                                                                                                       
         %end;                                                                                                                          
         %else %if "&sysver" ne "6.08" and "&___b___" NE "" %then %do;                                                                  
            %* Used to be scope NOT in GLOBAL SCA2UTIL;                                                                                 
            proc sql noprint;                                                                                                           
              select count(scope) into : __ag__ from sashelp.vmacro                                                                     
              where (upcase(name) = upcase("&___b___") and                                                                              
                    scope NOT in ('GLOBAL','SCA2UTIL'));                                                                                
            quit;                                                                                                                       
                                                                                                                                        
            %let __ag__=&__ag__;  ** added to 3.0 **;                                                                                   
                                                                                                                                        
            %if &__ag__=0 %then %do;                                                                                                    
               %put Note: Global macro variable %upcase(&___b___) defined;                                                              
               %global &___b___;                                                                                                        
            %end;                                                                                                                       
                                                                                                                                        
            proc sql noprint;                                                                                                           
               select &__mout__ into : &___b___                                                                                         
               from dictionary.columns                                                                                                  
               where (libname = "&___l___" and                                                                                          
                      memname = "&___d___" and                                                                                          
                      memtype in ('DATA','VIEW') and                                                                                    
                      upcase(name) = upcase("&___a___"));                                                                               
            quit;                                                                                                                       
                                                                                                                                        
            %let ___b___=&___b___;  ** added to 3.0 **;                                                                                 
                                                                                                                                        
            %let ___r___ = %length(&&&___b___);                                                                                         
            %if &___r___ GT 0 %then                                                                                                     
               %let &___b___=%substr(%bquote(&&&___b___),1,&___r___);                                                                   
            %else %let &___b___=;                                                                                                       
         %end;                                                                                                                          
      %end;                                                                                                                             
      %else %let _iiiiii_=99;                                                                                                           
                                                                                                                                        
  %end;                                                                                                                                 
  %else %if ("&__mout__"="MIN" or "&__mout__"="MAX" or "&__mout__"="NMISS"                                                              
     or "&__mout__"="MEAN" or "&__mout__"="STD" or "&__mout__"="N") %then                                                               
     %do _iiiiii_=1 %to 99;                                                                                                             
                                                                                                                                        
        %let ___a___=%scan(&__lst__,&_iiiiii_,' ');                                                                                     
        %if "&___a___" ne "" %then %do;                                                                                                 
            %let ___b___=%scan(&__ulst__,&_iiiiii_,' ');                                                                                
            %if "&sysver" ne "6.08" and "&___b___"="" %then %do;                                                                        
                                                                                                                                        
                proc sql noprint;                                                                                                       
                select count(scope) into : __ag__ from sashelp.vmacro                                                                   
                where (upcase(name) = upcase("&___a___") and                                                                            
                      scope not in ('GLOBAL','SCA2UTIL'));                                                                              
                quit;                                                                                                                   
                run;                                                                                                                    
                %let __ag__=&__ag__;  ** added to 3.0 **;                                                                               
                                                                                                                                        
                %if &__ag__=0 %then %do;                                                                                                
                    %put Note: Global macro variable %upcase(&___a___) defined;                                                         
                    %global &___a___;                                                                                                   
                %end;                                                                                                                   
                                                                                                                                        
                proc sql noprint;                                                                                                       
                    select &__mout__(&___a___) into : &___a___                                                                          
                    from &__dsn__;                                                                                                      
                quit;                                                                                                                   
                                                                                                                                        
                %let ___a___=&___a___;  ** added to 3.0 **;                                                                             
                                                                                                                                        
                %let ___r___ = %length(&&&___a___);                                                                                     
                %if &___r___ GT 0 %then                                                                                                 
                    %let &___a___=%substr(&&&___a___,1,&___r___);                                                                       
                %else %let &___a___=;                                                                                                   
            %end;                                                                                                                       
            %else %if "&sysver" ne "6.08" and "&___b___" NE "" %then %do;                                                               
                proc sql noprint;                                                                                                       
                  select count(scope) into : __ag__ from sashelp.vmacro                                                                 
                  where (upcase(name) = upcase("&___b___") and                                                                          
                         scope not in ('GLOBAL','SCA2UTIL'));                                                                           
                quit;                                                                                                                   
                                                                                                                                        
            %let __ag__=&__ag__;  ** added to 3.0 **;                                                                                   
                                                                                                                                        
            %if &__ag__=0 %then %do;                                                                                                    
                %put Note: Global macro variable %upcase(&___b___) defined;                                                             
                %global &___b___;                                                                                                       
            %end;                                                                                                                       
                                                                                                                                        
            proc sql noprint;                                                                                                           
               select &__mout__(&___a___) into : &___b___                                                                               
               from &__dsn__;                                                                                                           
            quit;                                                                                                                       
                                                                                                                                        
            %let ___b___=&___b___;  ** added to 3.0 **;                                                                                 
                                                                                                                                        
            %let ___r___ = %length(&&&___b___);                                                                                         
            %if &___r___ GT 0 %then                                                                                                     
                %let &___b___=%substr(&&&___b___,1,&___r___);                                                                           
            %else %let &___b___=;                                                                                                       
         %end;                                                                                                                          
     %end;                                                                                                                              
     %else %let _iiiiii_=99;                                                                                                            
                                                                                                                                        
  %end;                                                                                                                                 
  %else %if "&__mout__"="LEVEL" %then %do _iiiiii_=1 %to 99;                                                                            
    %let ___a___=%scan(&__lst__,&_iiiiii_,' ');                                                                                         
    %if "&___a___" NE "" %then %do;                                                                                                     
      %let ___b___ = %scan(&__ulst__,&_iiiiii_,' ');                                                                                    
      %if "&sysver" ne "6.08" and "&___b___"="" %then %do;                                                                              
        proc sql noprint;                                                                                                               
          select count(scope) into : __ag__ from sashelp.vmacro                                                                         
          where (upcase(name) = upcase("&___a___") and                                                                                  
                 scope not in ('GLOBAL','SCA2UTIL'));                                                                                   
        quit;                                                                                                                           
                                                                                                                                        
        %let __ag__=&__ag__;  ** added to 3.0 **;                                                                                       
                                                                                                                                        
        %if &__ag__=0 %then %do;                                                                                                        
          %put Note: Global macro variable %upcase(&___a___) defined;                                                                   
          %global &___a___;                                                                                                             
        %end;                                                                                                                           
                                                                                                                                        
        proc sql noprint;                                                                                                               
          select count(distinct &___a___) into : &___a___                                                                               
          from &__dsn__;                                                                                                                
        quit;                                                                                                                           
                                                                                                                                        
        %let ___a___=&___a___;  ** added to 3.0 **;                                                                                     
                                                                                                                                        
        %let ___r___ = %length(&&&___a___);                                                                                             
        %if &___r___ GT 0 %then                                                                                                         
           %let &___a___=%substr(&&&___a___,1,&___r___);                                                                                
        %else %let &___a___=;                                                                                                           
      %end;                                                                                                                             
      %else %if "&sysver" ne "6.08" and "&___b___" NE "" %then %do;                                                                     
        proc sql noprint;                                                                                                               
          select count(scope) into : __ag__ from sashelp.vmacro                                                                         
          where ( upcase(name) = upcase("&___b___") and                                                                                 
                  scope not in ('GLOBAL','SCA2UTIL'));                                                                                  
        quit;                                                                                                                           
                                                                                                                                        
        %let __ag__=&__ag__;  ** added to 3.0 **;                                                                                       
                                                                                                                                        
        %if &__ag__=0 %then %do;                                                                                                        
          %put Note: Global macro variable %upcase(&___b___) defined;                                                                   
          %global &___b___;                                                                                                             
        %end;                                                                                                                           
                                                                                                                                        
        proc sql noprint;                                                                                                               
          select count(distinct &___a___) into : &___b___                                                                               
          from &__dsn__;                                                                                                                
        quit;                                                                                                                           
                                                                                                                                        
        %let ___b___=&___b___;  ** added to 3.0 **;                                                                                     
                                                                                                                                        
        %let ___r___ = %length(&&&___b___);                                                                                             
        %if &___r___ GT 0 %then                                                                                                         
           %let &___b___=%substr(&&&___b___,1,&___r___);                                                                                
        %else %let &___b___=;                                                                                                           
      %end;                                                                                                                             
    %end;                                                                                                                               
    %else %let _iiiiii_=99;                                                                                                             
  %end;                                                                                                                                 
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Data management: lower or upper case                                          :                                                      
%*===============================================================================;                                                      
%if ("&___dm___"="UPCASE" or "&___dm___"="LOWCASE") and                                                                                 
    ( "&__dsn__" NE "" and "&__use__"="") %then %do;                                                                                    
                                                                                                                                        
  %if "&__out__"="" %then %let __out__=&__dsn__;                                                                                        
                                                                                                                                        
  %let ___l___=%scan(&__dsn__,1,'.');                                                                                                   
  %let ___d___=%scan(&__dsn__,2,'.');                                                                                                   
  %let _iiiiii_=1;                                                                                                                      
  %if %length(&___d___)=0 %then %do;                                                                                                    
    %let ___d___=%scan(&__dsn__,1,'.');                                                                                                 
    %let ___l___=WORK;                                                                                                                  
  %end;                                                                                                                                 
  proc sql noprint;                                                                                                                     
    create table ___X___ as                                                                                                             
    select libname,memname,memtype,type,name                                                                                            
    from sashelp.vcolumn                                                                                                                
    where (libname = "&___l___" and                                                                                                     
           memname = "&___d___" and                                                                                                     
           memtype in ('DATA','VIEW') and                                                                                               
           upcase(type) = 'CHAR');                                                                                                      
    select nobs into : _jjjjjj_                                                                                                         
    from dictionary.tables                                                                                                              
    where (libname = "WORK" and memname = "___X___");                                                                                   
    quit;                                                                                                                               
  %if &_jjjjjj_=1 %then %do;                                                                                                            
    proc sql noprint;                                                                                                                   
      select name into : ___a___                                                                                                        
      from ___X___                                                                                                                      
    quit;                                                                                                                               
                                                                                                                                        
    %let ___a___=&___a___;  ** added to 3.0 **;                                                                                         
                                                                                                                                        
    data &__out__;                                                                                                                      
      set &__dsn__;                                                                                                                     
      &___a___=&___dm___(&___a___);                                                                                                     
      run;                                                                                                                              
      %if &__mmsg__=Y %then                                                                                                             
         %put Note: Variable %upcase(&___a___) in &__dsn__ converted to &___dm___ in dataset &__out__;                                  
    proc datasets lib=work mt=data nolist;                                                                                              
       delete ___X___;                                                                                                                  
    quit;                                                                                                                               
  %end;                                                                                                                                 
  %else %if &_jjjjjj_>1 %then %do;                                                                                                      
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
%**v8** 200-limit for name string increased to 2000 ***;                                                                                
    %let __long__ = 0;                                                                                                                  
    data _null_;                                                                                                                        
      %if %scan(&sysver,1,'.') GE 8 %then %do;                                                                                          
         length ____a___ $40 ____b___ $2000;                                                                                            
         maxlen = 2000;                                                                                                                 
      %end;                                                                                                                             
      %else %do;                                                                                                                        
         length ____a___ $40 ____b___ $200;                                                                                             
         maxlen = 200;                                                                                                                  
      %end;                                                                                                                             
      retain ____b___ ;                                                                                                                 
      retain i 0;                                                                                                                       
      set ___X___(keep=name) end=eof;                                                                                                   
      ____a___=lag1(name);                                                                                                              
      i = i + 1;                                                                                                                        
      if length(___b___) + length(___a___) + 1 gt maxlen then do;                                                                       
         call symput( '__long__', compress(put(i,8.)));                                                                                 
      end;                                                                                                                              
      ____b___=trim(____b___)||' '||compress(____a___);                                                                                 
      if eof then call symput('___t___',trim(____b___)||' '||compress(name));                                                           
    run;                                                                                                                                
    %if &__long__ NE 0 %then %do;                                                                                                       
       %put Too many character variables ( &__long__ ). No conversion to &___dm___ in dataset &__out__;                                 
       %let __err__ = ERROR; %let _REASON_ = CHAR;                                                                                      
       proc datasets lib=work mt=data nolist;                                                                                           
          delete ___X___;                                                                                                               
       quit;                                                                                                                            
       %goto exit;                                                                                                                      
    %end;                                                                                                                               
                                                                                                                                        
    %let ___t___=&___t___;                                                                                                              
                                                                                                                                        
    data &__out__;                                                                                                                      
      set &__dsn__;                                                                                                                     
      %do _iiiiii_=1 %to &_jjjjjj_;                                                                                                     
        %let ___a___=%scan(&___t___,&_iiiiii_,' ');                                                                                     
        %str(&___a___=&___dm___(&___a___));  *--- Here the actual UPCASE/LOWCASE is performaed ---*;                                    
      %end;                                                                                                                             
      run;                                                                                                                              
      %if &__mmsg__=Y %then                                                                                                             
         %put Note: Variables %upcase(&___t___) in &__dsn__ converted to &___dm___ in dataset &__out__;                                 
    proc datasets lib=work mt=data nolist;                                                                                              
       delete ___X___;                                                                                                                  
    quit;                                                                                                                               
  %end;                                                                                                                                 
  %else %if &_jjjjjj_=0 and &__mmsg__=Y %then                                                                                           
      %put Note: No character variables found;                                                                                          
                                                                                                                                        
%end;                                                                                                                                   
                                                                                                                                        
%*===============================================================================;                                                      
%* Check for existence of external file                                          :                                                      
%*===============================================================================;                                                      
%if ("&__file__" ne "" and "&__use__"="") %then %do;                                                                                    
  %if &__mmsg__=Y %then %put Note: Checking existence of file &__file__;                                                                
  filename __zxqz__ "&__file__";                                                                                                        
  %if &sysfilrc ne 0 %then %do;                                                                                                         
    %if &__mmsg__=Y %then %put Error: File &__file__ does not exist. &__amsg__;                                                         
    %let _reason_=FEXIST;                                                                                                               
    %let __err__=ERROR;                                                                                                                 
    %goto exit;                                                                                                                         
  %end;                                                                                                                                 
  filename __zxqz__ clear;                                                                                                              
%end;                                                                                                                                   
                                                                                                                                        
%EXIT:                                                                                                                                  
                                                                                                                                        
%if "&__use__"="" %then %str(options &__opt1__;);                                                                                       
                                                                                                                                        
%EXIT2:                                                                                                                                 
                                                                                                                                        
%mend;
