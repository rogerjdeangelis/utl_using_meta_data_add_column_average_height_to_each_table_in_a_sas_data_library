Using meta data add column average height to each table in a sas data library

see
https://goo.gl/QzA1gq
https://communities.sas.com/t5/SAS-Procedures/How-to-assign-a-value-from-a-table-to-another-table-according-to/m-p/435463
D
DOSUBL has another advantage over a 'SIMPLE' call execute, it creates a logging dataset.

INPUT Meta data and four tables
===============================

  ALGORITHM

    Each record in the meta data contains
       1. The full path to a sas dataset
       2  The variable avgHgt with average height in last years math class
       2. Add avgHgt to each of the datasets in meta


  WORK.META total obs=4

     SAS7BDAT                                      avgHgt

     d:/suprhero/Bumblebee.sas7bdat                64.80
     d:/suprhero/Starscream.sas7bdat               52.50
     d:/suprhero/Batman.sas7bdat                   41.86
     d:/suprhero/Wonderwoman.sas7bdat              61.72


  FOUR INPUT TABLES

  1. D:/SUPRHERO/BUMBLEBEE.SAS7BDAT total obs=5

    NAME      HEIGHT

   Alfred      69.0
   Henry       63.5
   Jeffrey     62.5
   Louise      56.3
   Ronald      67.0

   ....
   ....

  4. D:/SUPRHERO/WONDERWOMAN total obs=4

     NAME     HEIGHT

    Carol      62.8
    Janet      62.5
    Judy       64.3
    Robert     64.8


  EXAMPLE  BUMBLEBEE output for one of the four

   D:/SUPRHERO/BUMBLEBEE.SAS7BDAT

     NAME      HEIGHT    AVGHGT
    Alfred      69.0     64.80
    Henry       63.5     64.80
    Jeffrey     62.5     64.80
    Louise      56.3     64.80
    Ronald      67.0     64.80


PROCESS
=======

  data log; 

    set meta;

    call symputx("sas7bdat",sas7bdat);
    call symputx("avgHgt",avgHgt);

    rc=dosubl('
       %symdel rc_code rctxt / nowarn; * just in case;
       data "&sas7bdat";
          set "&sas7bdat";
          avgHgt=symgetn("avgHgt");
       run;quit;

       %let rc_code=&syserr;
       %let rctxt=&syserrortext;
      ');

      * if there is an error a window pops up and asks where you want to continue;
      * detail information about the error appears in the log;

      if symget('rc_code') ne '0' then do;

           syserr=symget('rc_code');     * probably do not need to do this;
           syserrortext=symget('rctxt'); * probably do not need to do this;

           putlog // "Failed to Create Dataset " sas7bdat //;

           putlog "Error Code =" syserr //;
           putlog "Error Text =" syserrortext //;

           window chose irow=5 rows=25
             #5 @12 "Error encountered - Continue or stop and create " response $8. attr=underline;
           display chose;
           if response='stop' then do;
               put "Stopping datastep because of user request";
               stop;
           end;
           putlog "Continuing datastep processing even though an error was encountered";
      end;

  run;quit;

  If you have batmaxn instead of batman and you respond to
  the prompt with continue (or anthing other than stop you
  will see the following in your log

  * error you will
  Failed to Create Dataset d:/suprhero/Batmaxn.sas7bdat
  Error Code =1012
  Error Text =File d:/suprhero/Batmaxn.sas7bdat does not exist.


  Continuing datastep processing even though an error was encountered
  NOTE: There were 4 observations read from the data set d:/suprhero/Wonderwoman.sas7bdat.
  NOTE: The data set d:/suprhero/Wonderwoman.sas7bdat has 4 observations and 3 variables.
  NOTE: DATA statement used (Total process time):
        real time           0.01 seconds
        cpu time            0.01 seconds


  NOTE: There were 4 observations read from the data set WORK.META.
  NOTE: DATA statement used (Total process time):
        real time           6.14 seconds



OUTPUT  Update the four input datasets adding avgHgt
====================================================

   1.  D:/SUPRHERO/BUMBLEBEE.SAS7BDAT

       NAME      HEIGHT    AVGHGT
      Alfred      69.0     64.80
      Henry       63.5     64.80
      Jeffrey     62.5     64.80
      Louise      56.3     64.80
      Ronald      67.0     64.80

    ...

   4. D:/SUPRHERO/WONDERWOMAN.SAS7BDAT

       NAME     HEIGHT    AVGHGT

      Carol      62.8      61.72
      Janet      62.5      61.72
      Judy       64.3      61.72
      Robert     64.8      61.72

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

* If you want to rerun

libname suprhero "d:/suprhero";

proc datasets lib=suprhero kill;
run;quit;

data  suprhero.Bumblebee
      suprhero.Starscream
      suprhero.Batman
      suprhero.Wonderwoman;

  set sashelp.class(keep=name height);

  select (mod(_n_,4));
      when (1) output suprhero.Bumblebee  ;
      when (2) output suprhero.Starscream ;
      when (3) output suprhero.Batman     ;
      when (0) output suprhero.Wonderwoman;
  end; * no need for otherwise;

run;quit;


data meta;
 informat sas7bdat $32.;
 input sas7bdat avgHgt;
cards4;
d:/suprhero/Bumblebee.sas7bdat 64.80
d:/suprhero/Starscream.sas7bdat 52.50
d:/suprhero/Batmaxn.sas7bdat 41.86
d:/suprhero/Wonderwoman.sas7bdat 61.72
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

 * same as above

data _null_;

  set meta;

  call symputx("sas7bdat",sas7bdat);
  call symputx("avgHgt",avgHgt);

  rc=dosubl('
     %symdel rc_code rctxt / nowarn; * just in case;
     data "&sas7bdat";
        set "&sas7bdat";
        avgHgt=symgetn("avgHgt");
     run;quit;

     %let rc_code=&syserr;
     %let rctxt=&syserrortext;
    ');

    * if there is an error a window pops up and asks where you want to continue;
    * detail information about the error appears in the log;

    if symget('rc_code') ne '0' then do;

         syserr=symget('rc_code');     * probably do not need to do this;
         syserrortext=symget('rctxt'); * probably do not need to do this;

         putlog // "Failed to Create Dataset " sas7bdat //;

         putlog "Error Code =" syserr //;
         putlog "Error Text =" syserrortext //;

         window chose irow=5 rows=25
           #5 @12 "Error encountered - Continue or stop and create " response $8. attr=underline;
         display chose;
         if response='stop' then do;
             put "Stopping datastep because of user request";
             stop;
         end;
         putlog "Continuing datastep processing even though an error was encountered";
    end;

run;quit;


