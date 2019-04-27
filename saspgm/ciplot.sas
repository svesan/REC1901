*-----------------------------------------------------------------------------;
* Study.......: REC1901                                                       ;
* Name........: s_ciplt2.sas                                                  ;
* Date........: 2019-03-04                                                    ;
* Author......: svesan                                                        ;
* Purpose.....: Create plots for the confidence intervals                     ;
* Note........:                                                               ;
*-----------------------------------------------------------------------------;
* Data used...:                                                               ;
* Data created:                                                               ;
*-----------------------------------------------------------------------------;
* OP..........: Linux/ SAS ver 9.04.01M4P110916                               ;
*-----------------------------------------------------------------------------;

*-- External programs --------------------------------------------------------;

*-- SAS macros ---------------------------------------------------------------;

*-- SAS formats --------------------------------------------------------------;

*-- Main program -------------------------------------------------------------;

filename saspgm 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saspgm';
filename result 'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\sasout';
filename log    'P:\0RECAP\0RECAP_Research\sasproj\REC\REC1901\saslog';


options nosource;
%macro ssciplt(__func__, data=pest1, label=label, sublabel=, est=estimate, upper=upper, lower=lower, gout=gseg, truncate=,
                type=1, boxwidth=0.1, xorder=, citext=, labelposition=, digits=4.1, sublabelposition=LEFT,
                upper_offset=3, lower_offset=3, left_offset=3, right_offset=3, href=1, vref=,
                flabel=, fsublabel=, hsublabel=, hlabel=, alabel=0, boxcolor=, hcitext=, order=, annotate=, origin=,
                boxcolor_dsn=, hsymbol=1, weight=, xformat=);

%if %upcase(&__func__)=HELP %then %do;
  %put ;
  %put %str(----------------------------------------------------------------------------------------------);
  %put %str(Help on the macro SSCIPLT ver 2.0 at 27-Apr-2011);
  %put %str(----------------------------------------------------------------------------------------------);
  %put %str(The macro will plot horizontal boxes for point estimates and associated confidence limits. The macro will in);
  %put %str(particular create x-axis on a relative scale, that is equal distance between 0.5 and 1 and between 1 and 2.);
  %put %str(The actual point estimate and confidence limits values can be printed on the plot as well. Also, the labelling);
  %put %str(can be controlled in different ways.);
  %put %str( );
  %put %str(If by default the graph is not produced try setting the offset parameters to higher values and do not adjust);
  %put %str(the parameters effecting the labels.);
  %put %str( );
  %put %str(The macro is defined with the following set of parameters:);
  %put %str( );
  %put %str(DATA=............: Mandatory. SAS dataset to containing the estimates and confidence limits);
  %put %str(ORDER............: Mandatory. A variable in the DATA= dataset that indicate y-axis order of the boxes.);
  %put %str(LABEL=...........: Mandatory. Name of the variable containing the labels describing the different estimates);
  %put %str(SUBLABEL=........: Optional. Name of a variable containing label describing the estimates. These should be);
  %put %str(.................: labels within LABEL. E.g. LABEL could be treatment group A, B and C and);
  %put %str(.................: SUBLABEL male and females within each treatment group);
  %put %str(EST=.. ..........: Mandatory. The name of the SAS variable containing the point estimate to be plotted);
  %put %str(LOWER= ..........: Mandatory. The name of the SAS variable containing the lower confidence limit to be plotted);
  %put %str(UPPER= ..........: Mandatory. The name of the SAS variable containing the upper confidence limit to be plotted);
  %put %str(GOUT=............: Optional. A SAS catalog name where the graph will be stored);
  %put %str(TRUNCATE=........: Optional. A value on the X-axis where the graph will be truncated. Useful when single);
  %put %str(.................: very long confidence intervals);
  %put %str(TYPE=2...........: Optional. Integer 1 or 2 for x-axis linear or relative scale);
  %put %str(BOXWIDTH=0.1.....: Optional. A value for the box width);
  %put %str(HSYMBOL=1........: Optional. A value for the size of the point estimate symbol);
  %put %str(XORDER=..........: Optional. A x-axis order statement set directly, e.g xorder=0 to 3 by 1);
  %put %str(CITEXT=..........: Optional. Strings ABOVE, BELOW, LEFT, RIGHT or RIGHMOST for the position of the values of the point);
  %put %str(.................: estimates and confidence limits. When blank the values are not printed);
  %put %str(DIGITS=4.1.......: Optional. SAS format for the presentation of the CITEXT data, e.g. 5.3);
  %put %str(LABELPOSITION=...: Optional. Strings LEFT or RIGHT for the position of the LABEL text strings. If set the labels);
  %put %str(.................: are printed inside the plot region. If left blank the labels will be printed on the y-axis);
  %put %str(FLABEL=..........: Optional. Font for the LABEL, e.g FLABEL='Times-Roman' or FLABEL='<ttf> Arial');
  %put %str(HLABEL=..........: Optional. Height for the LABEL text);
  %put %str(ALABEL=..........: Optional. Angle for the LABEL text. ALABEL=90 will have text vertical.);
  %put %str(HSUBLABEL=.......: Optional. Height for the SUBLABEL font);
  %put %str(SUBLABELPOSITION=: Optional. Strings "LEFT", ABOVE or BELOW for the position of the SUBLABEL. Will only be);
  %put %str(.................: used when the SUBLABEL parameter has been set.);
  %put %str(UPPER_OFFSET=3...: Optional. A numeric value setting the distance from the upper y-axis tickmark to the upper end of the axis line);
  %put %str(LOWER_OFFSET=3...: Optional. A numeric value setting the distance from the lower y-axis tickmark to the lower end of the axis line);
  %put %str(LEFT_OFFSET=3....: Optional. A numeric value setting the distance from the left y-axis tickmark to the left end of the axis line);
  %put %str(RIGHT_OFFSET=3...: Optional. A numeric value setting the distance from the right y-axis tickmark to the right end of the axis line);
  %put %str(HREF=............: Optional. Horizontal reference lines. Besides lines href=1 or href=1 to 5 by 0.5 the parameter can);
  %put %str(.................: also include color, e.g chref=red, and line type, e.g. lhref=2  );
  %put %str(VREF=............: Optional. Vertical reference lines. Besides lines vref=1 or vref=1 to 5 by 0.5 the parameter can);
  %put %str(.................: also include color, e.g cvref=red, and line type, e.g. lvref=2  );
  %put %str(WEIGHT=..........: Optional. To control the width of the boxes. A variable in the DATA dataset.);
  %put %str(BOXCOLOR=........: Optional. To control the color of the boxes. A color such as LIGHTGRAY is expected);
  %put %str(BOXCOLOR_DSN=....: Optional. To control the color of the boxes using a dataset. The dataset should contain the variable ORDER=);
  %put %str(.................: and a variable COLOR for the color to use. Leave empty for a white box contained in a black square.);
  %put %str(XFORMAT=.........: Optional. To speficy other format for x-axis. Should be entered as SAS format with ending dot.);
  %put %str(----------------------------------------------------------------------------------------------);
  %put ;
  %goto exit2;
%end;
%else %if %bquote(&__func__)^= %then %do;
  %put Warning: Unknown command SCAUPLOAD(&__func__). Macro aborts.;
  %goto exit2;
%end;

%* 2012-11-13 added the hlabel parameter ;

%let yvalue=(j=L);
%let _ymajor_= ;

* type 1=linear scale only, 2=ratio scale only, 3=both ;

    data pest2;
      length order 3;
      set &data(keep=&label &sublabel &est &lower &upper can_txt &order &weight);

      %if %bquote(&order)^= %then %str(order=&order;);
      %else %str(order=_n_;);

    run;

    data fmt1;
      keep fmtname type start end label;
      length start end 3;
      retain fmtname 'HEPP' type 'N' firstgroup 1;
      set &data(keep=&order &label can_txt) end=eof;by can_txt;

      %if %bquote(&order)^= %then %str(start=&order;);
      %else %str(start=_n_;);
      end=start;

      label=&label;

      if firstgroup then output fmt1;
      if last.can_txt then firstgroup=0;
    run;
    proc format cntlin=fmt1 lib=work;run;

    *-- Upper limit of the y-axis;
    proc sql noprint;
      select max(start) into : slask4 from fmt1;
    quit;

*-----------------------------------------------;
* Y-axis                                        ;
*-----------------------------------------------;
%if &type=1 %then %let _vord_=order=0 to &slask4 by 1;
%else %if &type=2 %then %do;
  proc sql;
    create table xx0 as select ceil(max(max(1/&lower,&upper))) as max from &data;
    create table xx1 as select ceil(max) as max from xx0;
*    %if &truncate^= %then str(create table xx1 as select min(&truncate, max) as max from xx1;);
  quit;

  *-- First calculate the x-axis order to use;
  data fmt2;
    length txt $1000. label $10;
    retain txt '' fmtname 'SLASK' type 'N';
    set xx1 end=eof;
    if _n_=1 and max>1000 then do;
      put 'WARNING: x-axis order > 1000 or < 1/1000. Will truncate at 1000';
      max=1000;
    end;

    %if %bquote(&truncate)^= %then %str(max=min(max,&truncate););
    do i=max to 1 by -1;
      v=put(1/i,best.8);
      label='1/'||compress(put(i,8.)); start=v; end=v;
      output fmt2;
      txt=compress(txt)||compress(v)||',';
    end;
    do i=2 to max by 1;
      v=put(i,8.);
      txt=compress(txt)||compress(v)||',';
    end;
    if eof then do;
      length=length(compress(txt));
      txt='order='||substr(compress(txt),1,length-1);
      call symput('_vord_',compress(txt));
    end;
  run;

  *-- The create the format  ;
  data fmt2(keep=fmtname type start end label);
    length txt $1000. label $10;
    retain txt '' fmtname 'SLASK' type 'N';
    set xx1 end=eof;
    %if %bquote(&truncate)^= %then %str(max=min(max,&truncate););
    do i=max(max, 128) to 1 by -1;
      v=put(1/i,best.8);
      label='1/'||compress(put(i,8.)); start=v; end=v;
      output fmt2;
      txt=compress(txt)||compress(v)||',';
    end;
    do i=2 to max(max,30) by 1;
      v=put(i,8.);
      txt=compress(txt)||compress(v)||',';
    end;
    if eof then do;
      length=length(compress(txt));
*      txt='order='||substr(compress(txt),1,length-1);
*      call symput('_vord_',compress(txt));
    end;
  run;

  *-- Change label "1/1" to 1;
  data fmt3;
    set fmt2;
    if label="1/1" then label="1";
  run;

  proc format cntlin=fmt3;run;
  %put Note: The x-axis order &_vord_ will be used;

%end;

%if "&xorder" NE "" %then %do;
  %put Note: Calculated X-axis order &_vord_ overrun by user order=&xorder;
  %let _vord_=order=&xorder;
%end;

proc sql;
  create table pest3 as
  select a.*, b.start
  from pest2(keep=&label &sublabel &est &lower &upper can_txt order &weight) as a
  join fmt1 as b
  on a.&label = b.label and a.order=b.start
  order by a.order;
quit;
/*full outer*/


data anno1;
  length function $8 color $16 style $20;
  retain start 0 fmtname 'HEPP' type 'N' xsys ysys '2' hsys '3' line 1 size 0.05 when 'a' sortor 0;

  set pest3(keep=can_txt start &label &est &lower &upper &weight rename=(&label=lbl));

  lim = &boxwidth;
  %if %bquote(&weight) ne %then %str(lim = &boxwidth * &weight;);

  color='black';
  size=0.05;
  &lower=round(&lower,0.0000001)+0.0000001;
  &upper=round(&upper,0.0000001)-0.0000001;

  %if %bquote(&truncate)^= %then %do;
    tr_l=1/&truncate; tr_u=&truncate;

    y=start-lim; x=max(&lower,tr_l); function='move'; sortor=sortor+1; output;
    ylast=start-lim; xlast=max(&lower,tr_l); y=start + lim; x=min(&upper,tr_u);
    function='bar'; line=0;

    if "&boxcolor" ne "" then do;
      style='S'; color="&boxcolor";
    end;
    else if "&boxcolor_dsn" ne "" then style='S';
    else style='E';
    sortor=sortor+1; output;

    color=''; style='';
    if &lower<tr_l then do;
      x=tr_l; y=start; function='move'; sortor=sortor+1; output;
      x=tr_l; y=start; function='symbol'; text='='; size=4; sortor=sortor+1; output;
    end;

    if &upper>tr_u then do;
      x=tr_u; y=start; function='move'; sortor=sortor+1; output;
      x=tr_u; y=start; function='symbol'; text='='; size=4; sortor=sortor+1; output;
    end;

  %end;
  %else %do;
    y=start-lim; x=&lower; function='move'; sortor=sortor+1; output;
    ylast=start-lim; xlast=&lower; y=start+lim; x=&upper; function='bar'; line=0;
    if "&boxcolor" ne "" then do;
      style='S'; color="&boxcolor";
    end;
    else if "&boxcolor_dsn" ne "" then style='S';
    else style='E';
    sortor=sortor+1; output;
  %end;
run;

*-- Datastep added 2008-01-08: Join in box colors from dataset set by parameter boxcolor_dsn=;
%if "&boxcolor_dsn" ne "" %then %do;
  proc sort data=&boxcolor_dsn;by &order;run;
  data anno1;
    merge anno1(drop=color) &boxcolor_dsn(keep=&order color rename=(&order=start));by start;
    if style='S' and color eq '' then do;
      style='E'; color='black';
    end;
  run;
/****
  proc sql;
    create table anno1 as
    select a.*, case when a.style='S' then b.color else '' end as color length=12
    from anno1(rename=(color=slask)) as a
    left join &boxcolor_dsn as b
    on a.start = b.order
    order by sortor
    ;
  quit;
****/
%end;


*-----------------------------------------------;
* Point estimates and confidence intervals      ;
*-----------------------------------------------;
%if "&citext" ne "" %then %do;
  %put Note: Calculating coordinates for the estimates;

  data anno2;
    length text $40;
    set pest3;
    text=put(&est, &digits)||' ('||compress(put(&lower, &digits)||' - '||put(&upper, &digits))||')';

    *-- If lower=upper=RR then do not print a text. Print blank;
    if round(&lower, 0.0004) = round(&upper, 0.0004) or &upper le .z or &lower le .z then text='';
  run;

  proc sort data=anno1(keep=can_txt start function y ylast &est &lower &upper xsys ysys hsys
                       where=(function='bar'))
            out=zz2(rename=(start=order y=y0 ylast=ylast0));
    by start;
  run;

  data anno3;
    keep can_txt xsys ysys hsys x y function text position size;
    length text $200;
    merge anno2(keep=order text)
          zz2
    ;
    by order;

    if "&citext"="BELOW" then do;
      function='move '; x=&est; y=ylast0; output;
      function='label'; position='8'; output;
    end;
    else if "&citext"="ABOVE" then do;
      function='move '; x=&est; y=y0; output;
      function='label'; position='2'; output;
    end;
    else if "&citext"="LEFT" then do;
      function='move '; x=&lower*0.95; y=mean(y0,ylast0); output;
      function='label'; position='<'; output;
    end;
    else if "&citext"="RIGHT" then do;
      function='move '; x=&upper*1.01; y=mean(y0,ylast0); output;
      function='label'; position='>'; output;
    end;
    else if "&citext"="RIGHTMOST" then do;
      xsys='1';x=100;

      %if "&hcitext" ne "" %then %str(size=&hcitext;);%else %str(size=.;);

      function='move '; *x=&upper*1.01; y=mean(y0,ylast0); output;
      function='label'; position='<'; output;
      xsys='2';
    end;
    else if "&citext"="LEFTMOST" then do; ** added leftmost 16may2007 **;
      xsys='1';x=0;

      %if "&hcitext" ne "" %then %str(size=&hcitext;);%else %str(size=.;);

      function='move '; *x=&upper*1.01; y=mean(y0,ylast0); output;
      function='label'; position='>'; output;
      xsys='2';
    end;
  run;
%end;


*--------------------------------------------------------------------;
* Position y-axis labels inside the graph                            ;
* 2012-09-25 removed color as last variable in the class statements  ;
*--------------------------------------------------------------------;
%if "&labelposition" ne "" %then %do;
  proc summary data=anno1 nway;
    where function='bar';
    var y ylast &lower &upper;
    %if "&sublabel" ne "" %then %str(class can_txt lbl xsys ysys hsys;);
    %else %str(class can_txt lbl start xsys ysys hsys;);
    output out=zz1(drop=_type_ _freq_) mean(y ylast)=y0 ylast0 min(&lower)=&lower max(&upper)=&upper;
  run;

  data anno5;
    keep can_txt xsys ysys hsys color x y function text position style size angle;
    length text $200 style $20;
    set zz1;
    color='black';

    if "&labelposition"="LEFT" then do;
      function='move '; y=mean(y0,ylast0); x=&lower*0.90; style=""; output;
      function='label'; text=lbl; position='<'; angle=&alabel; if angle=90 then position='E';

      %if "&hlabel" ne "" %then %str(size=&hlabel;);%else %str(size=.;);
      style="&flabel";output;
    end;
    else if "&labelposition"="RIGHT" then do;
      function='move '; y=mean(y0,ylast0); x=&upper*1.1; style="";output;
      function='label'; text=lbl; position='>'; angle=&alabel; if angle=90 then position='E';

      %if "&hlabel" ne "" %then %str(size=&hlabel;);%else %str(size=.;);
      style="&flabel";output;
    end;
    if "&labelposition"="INNERLEFT" then do;
      x=input(scan("&_vord_",2,"=,"),8.)*1.001;
      function='move '; y=mean(y0,ylast0); style=""; output;
      function='label'; text=lbl; position='>'; angle=&alabel; if angle=90 then position='E';

      %if "&hlabel" ne "" %then %str(size=&hlabel;);%else %str(size=.;);
      style="&flabel";output;
    end;

    else if "&labelposition"="LEFTMOST" then do;
      xsys='1'; x=0; y=mean(y0, ylast0);

      function='move '; output;
      function='label'; text=lbl; position='>'; angle=&alabel; if angle=90 then position='E';

      %if "&hlabel" ne "" %then %str(size=&hlabel;);%else %str(size=.;);
      %if %bquote(&flabel)^= %then %str(style="&flabel";);%else %str(style="";);
      output;

      xsys='2';
    end;
  run;

  %let yvalue=NONE;
  %let _ymajor_=%str(major=NONE);

%end;

*-----------------------------------------------;
* Sub labels                                    ;
*-----------------------------------------------;
%if "&sublabel" ne "" %then %do;
  proc sort data=pest3 out=zz3(keep=can_txt order &sublabel &est &lower &upper &weight rename=(order=y));
    by can_txt order;
  run;

*options mprint;
  data anno6a;
    length style $20 text $40;
    retain xsys ysys '2' hsys '3' color 'black' ;
    set zz3;

    _boxwidth = &boxwidth;
    %if %bquote(&weight) ne %then %str(_boxwidth = &boxwidth * &weight;);

    if "&sublabelposition"="LEFT" then do;
      x=&lower*0.98; function='move '; style=""; output;
      function='label'; text=&sublabel; position='<';
      %if "&hsublabel" ne "" %then %str(size=&hsublabel;);%else %str(size=.;);
      %if %bquote(&fsublabel)^= %then %str(style="&fsublabel";); %else %str(style="";);
      output;
    end;
    else if "&sublabelposition"="ABOVE" then do;
      x=&est; y=y + _boxwidth; function='move '; style=""; output;
      function='label'; text=&sublabel; position='2';
      %if "&hsublabel" ne "" %then %str(size=&hsublabel;);%else %str(size=.;);
      %if %bquote(&fsublabel)^= %then %str(style="&fsublabel";); %else %str(style="";);
      output;
    end;
    else if "&sublabelposition"="BELOW" then do;
      x=&est; y=y - _boxwidth; function='move '; style=""; output;
      function='label'; text=&sublabel; position='8';
      %if "&hsublabel" ne "" %then %str(size=&hsublabel;);%else %str(size=.;);
      %if %bquote(&fsublabel)^= %then %str(style="&fsublabel";); %else %str(style="";);
      output;
    end;
    else if "&sublabelposition"="RIGHT" then do;
      x=&upper*1.02; function='move '; style=""; output;
      function='label'; text=&sublabel; position='>';
      %if "&hsublabel" ne "" %then %str(size=&hsublabel;);%else %str(size=.;);
      %if %bquote(&fsublabel)^= %then %str(style="&fsublabel";); %else %str(style="";);
      output;
    end;
    else if "&sublabelposition"="LEFTMOST" then do;
      xsys='1';x=0;

      function='move '; output;
      function='label'; text=&sublabel; position='>';
      %if "&hsublabel" ne "" %then %str(size=&hsublabel;);%else %str(size=.;);
      %if %bquote(&fsublabel)^= %then %str(style="&fsublabel";); %else %str(style="";);
      output;
      xsys='2';
    end;
  run;

%end;

*-- 2012-11-13 If lower=upper=RR then do not print a text. Print blank;
data anno6;
  set anno6a;
  if round(&lower, 0.0004) = round(&upper, 0.0004) or &upper le .z or &lower le .z then text='';
run;


*-----------------------------------------------;
* Combine the different annotated datasets      ;
*-----------------------------------------------;
data anno7;
  length text $100 style $20;
  set anno1
  %if "&citext" ne "" %then %str( anno3);
  %if "&labelposition" ne "" %then %str( anno5);
  %if "&sublabel" ne "" %then %str( anno6);
  ;
  when='B';
run;

%if %bquote(&vref)^= %then %let vref=vref=&vref;

proc sql noprint;
  select label
  from dictionary.columns
  where libname='WORK' and memname='PEST3' and name="&est" and label ne '';
quit;

%if &sqlobs=0 %then %let _ax2_lbl_=%str(label=none);

%if %bquote(&annotate)^= %then %do;

data anno7;
  length text $200;
  set anno7 &annotate;
  can_txt='A';
*  style="'Times-Bold'";
run;

%end;

*-- 2012-11-13 If lower=upper=RR then do not print a text. Print blank;
data pest4;
  set pest3;
  if round(&lower, 0.0004) = round(&upper, 0.0004) or &upper le .z or &lower le .z then &est=.u;
run;

options mprint;
goptions hby=0;
proc gplot data=pest4 nocache gout=&gout;

  symbol1 c=black i=none v=dot h=&hsymbol;
  symbol2 c=black i=none v=none;

  axis1 minor=none &_ymajor_ offset=(&lower_offset.pct, &upper_offset.pct)
        label=none value=&yvalue order=1 to &slask4 by 1 origin=(&origin);

  axis2 minor=none offset=(&left_offset.pct, &right_offset.pct) &_vord_ &_ax2_lbl_  origin=(&origin);

  plot start*&est=1 start*(&lower &upper)=2
  / overlay vaxis=axis1 haxis=axis2 annotate=anno7 href=&href &vref;

  by can_txt;

  %if &type=2 AND %bquote(&xformat)=  %then %str(format start hepp. &est slask. ;);
  %else %if %bquote(&xformat)^=  %then %str(format start hepp. &est &xformat ;);
  %else %str(format start hepp.;);
run;quit;
options nomprint;

%exit:


%exit2:

proc datasets lib=work mt=data nolist;
*  delete pest2-pest4 anno1-anno7 anno6a xx0 xx1 fmt1-fmt3 zz1-zz3;
quit;

%mend;
options source;


*-- SAS macros ---------------------------------------------------------------;
*%inc saspgm(ssciplt);

*-- SAS formats --------------------------------------------------------------;
proc format;
  value myx 0.03125='0.031' 0.0625='0.062' 0.125='0.125' 0.25='0.25' 0.5='0.5' 1='1'
  ;
run;

%let slask1=%qsysfunc(pathname(result));


*-- SAS annotate dataset to add in RR (95% CI) on top of left most column;
data annot1;
  length function $12 text  $50;
  retain xsys ysys '3' hsys '3' color 'black' size 2.00;
  x=95; y=98.5; function='move  '; output;
  function='label'; text='RR  (95% CI)'; style='Thorndale/Bold AMT'; output;
run;

*==============================================================================================================;
* START WITH ASD                                                                                               ;
* First column (8,7,etc) is the ordering from top (8) to bottom.                                               ;
* 2nd column then outcome ASD or AD                                                                            ;
* 3rd column the vertical text on the left most part along the yaxis                                           ;
* 4th column the text attached to each bar                                                                     ;
* 5th to 8th column are the rates and number of individuals but not used in this first version                 ;
* 9th to 10th columns are the point estimate and lower and upper concfidence intervals. These will be printed  ;
* on the leftmost side of the figure                                                                           ;
*                                                                                                              ;
*==============================================================================================================;
data asd1;
drop n ref_n cases refcases;
input sorder outcome $ 5-8 lbl $ 10-34 sub $ 36-49 cases refcases n ref_n estimate lower upper ;
can_txt='A'; ** can_txt is a dummy. Doesnt do ANYTHING but need to be there;

jamatxt='(Rate='||compress(put(cases, 8.))||' vs '||compress(put(refcases,8.))||
             ', P-Year='||compress(put(n, 12.))||' vs '||compress(put(ref_n,8.))||')';
jamatxt=' ';

cards;
14  ASD  Uncles                   Crude               6273.5  26.8      130720       96       3.22 2.54 3.91
13  ASD  Uncles                   Adjusted 1          805.1   54.5      385521      869       2.75 2.15 3.36
12  ASD  Uncles                   Adjusted 2          805.1   54.5      385521      869       1.92 1.49 2.37
11  ASD  Uncles                   Adjusted 3          805.1   54.5      385521      869       2.07 1.58 2.61
9   ASD  Aunts                    Crude               154.6   48.6   148053914   313739       2.73 1.88 3.73
8   ASD  Aunts                    Adjusted 1          463.1   26.3     8750181    14467       2.36 1.62 3.21
7   ASD  Aunts                    Adjusted 2          463.1   26.3     8750181    14467       1.73 1.19 2.35
6   ASD  Aunts                    Adjusted 3          463.1   26.3     8750181    14467       1.58 1.04 2.21
4   ASD  Aunts or Uncles          Crude               6273.5  26.8      130720       96       3.05 2.54 3.67
3   ASD  Aunts or Uncles          Adjusted 1          805.1   54.5      385521      869       2.62 2.18 3.15
2   ASD  Aunts or Uncles          Adjusted 2          463.1   26.3     8750181    14467       1.88 1.55 2.27
1   ASD  Aunts or Uncles          Adjusted 3          463.1   26.3     8750181    14467       1.89 1.55 2.30
;
run;














*-- Adjust ASD1 dataset to a proper SAS annotate dataset;
data annot3;
  length function $12;
  retain xsys ysys '2' hsys '2' size 0.8;
  set asd1(keep=sorder lower jamatxt rename=(sorder=y lower=x jamatxt=text));
/*
  function='move';  x=x*0.90; y=y-0.1; output;
  function='label'; position='8'; output;
*/
run;

data annot4;
  set annot1 annot3(in=annot3);
  if annot3 then do;
    size=0.37;
  end;
run;

filename  epsgraf "&slask1/Fig1_v2.png";
*options reset=all device=eps14x16 /*device=psepsf*/   display gsfname=epsgraf gsfmode=replace rotate=p
         ftext="Times-Roman"
         lfactor=4 htext=2.1 fontres=presentation noborder;
goptions reset=all device=png300 display gsfname=epsgraf gsfmode=replace rotate=p
         htext=1.6 ftext="Thorndale AMT";


%ssciplt(data=asd1, order=sorder, gout=gseg, annotate=annot4,
type=2, boxwidth=0.20, hsymbol=1.20, boxcolor=LIGR,
label=lbl, labelposition=LEFTMOST, hlabel=2.6, alabel=90, flabel=Thorndale/Bold AMT,
sublabel=sub, hsublabel=2.2, digits=5.2, fsublabel=Helvetica,
citext=RIGHTMOST, hcitext=2.2, xformat=myx.,
lower_offset=6, upper_offset=8, left_offset=6, right_offset=12,
xorder= %str( 0.5 ,1,2,4,8),
href=1 whref=2, vref=5 10  lvref=(2 2) wvref=(2 2));

filename epsgraf clear;
goptions reset=all;

*-- Cleanup ------------------------------------------------------------------;
title1;footnote;
proc datasets lib=work mt=data nolist;
  delete asd1 annot1 annot3 annot4;
quit;

*-- End of File --------------------------------------------------------------;
