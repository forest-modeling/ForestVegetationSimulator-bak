      SUBROUTINE DBSIN (KEYWRD,ARRAY,ISDSP,SDLO,SDHI,LNOTBK,LKECHO)
      IMPLICIT NONE
C
C $Id$
C
C     OPTION PROCESSOR FOR DATA BASE CONNECTIVITY
C
COMMONS
C
      INCLUDE  'PRGPRM.F77'
C
C
      INCLUDE  'CONTRL.F77'
C
C
      INCLUDE  'PLOT.F77'
C
C
      INCLUDE  'DBSCOM.F77'
C
COMMONS

      INTEGER    KWCNT, STRLEN, IDT, ISDSP
      PARAMETER (KWCNT = 33)

      CHARACTER*8  TABLEME(KWCNT), PASKEY,CSPOUT
      CHARACTER*(*) KEYWRD
      CHARACTER*10 KARD(7)
      CHARACTER*20 TABLENAME,COLUMN
      CHARACTER*50 TYPEMSG(2)
      CHARACTER*3  YESNO(2)
      CHARACTER*5000 SQLSTR,STNDKODS,STNDSQL,COLNAMES,TMPSTR

      LOGICAL      LNOTBK(*),LACT,LKECHO
      INTEGER      KEY,I,J,IRTNCD
      INTEGER      I1,I2,I3,I4
      INTEGER      KODE,IPRMPT,NUMBER
      REAL         ARRAY(*),SDLO,SDHI

      DATA TABLEME /
     >     'END     ','DSNOUT  ','SQLOUT  ','SUMMARY ','COMPUTE ',
     >     'TREELIST','STANDIN ','CLIMREPT','DRIVERS ','DSNIN   ',
     >     'STANDSQL','TREESQL ','POTFIRE ','FUELSOUT','DSNESTAB',
     >     'SQLIN   ','CUTLIST ','MISRPTS ','FUELREPT','BURNREPT',
     >     'MORTREPT','SNAGSUM ','SNAGOUT ','STRCLASS','PPBMMAIN',
     >     'PPBMTREE','PPBMBKP ','PPBMVOL ','CARBRPTS','ECONRPTS',
     >     'ATRTLIST','DWDVLOUT','DWDCVOUT'/

      DATA TYPEMSG/'DATABASE TABLE AND STANDARD OUTPUT ARE GENERATED',
     >             'ONLY THE DATABASE TABLE IS GENERATED'/
      DATA YESNO/'YES','NO'/
C
C     **********          EXECUTION BEGINS          **********
C
   10 CONTINUE
      CALL KEYRDR (IREAD,JOSTND,.FALSE.,KEYWRD,LNOTBK,
     >             ARRAY,IRECNT,KODE,KARD,LFLAG,LKECHO)
C
C  RETURN KODES 0=NO ERROR,1=COLUMN 1 BLANK OR ANOTHER ERROR,2=EOF
C               LESS THAN ZERO...USE OF PARMS STATEMENT IS PRESENT.
C
      IF (KODE.LT.0) THEN
         IPRMPT=-KODE
      ELSE
         IPRMPT=0
      ENDIF
      IF (KODE .LE. 0) GO TO 30
      IF (KODE .EQ. 2) CALL ERRGRO(.FALSE.,2)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         
      
      CALL ERRGRO (.TRUE.,6)
      GOTO 10
   30 CONTINUE
C
      CALL FNDKEY (NUMBER,KEYWRD,TABLEME,KWCNT,KODE,.FALSE.,JOSTND)
C
C     RETURN KODES 0=NO ERROR,1=KEYWORD NOT FOUND,2=MISSPELLING.
C
      IF (KODE .EQ. 0) GOTO 90
      IF (KODE .EQ. 1) THEN
         CALL ERRGRO (.TRUE.,1)
         GOTO 10
      ENDIF
      GOTO 90
C
C     SPECIAL END-OF-FILE TARGET
C
   80 CONTINUE
      CALL ERRGRO(.FALSE.,2)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         
      
   90 CONTINUE
C
C     PROCESS OPTIONS
C
      GO TO( 100, 200, 300, 400, 500, 600, 700, 800, 900,1000,
     &      1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,
     &      2300,2400,2500,2600,2700,2800,2900,3000,3100,3200,
     &      3300), NUMBER

  100 CONTINUE
C                        OPTION NUMBER 1 -- END
      IF(LKECHO)WRITE(JOSTND,110) KEYWRD
  110 FORMAT (/1X,A8,'   END OF DATA BASE OPTIONS.')
      RETURN
  200 CONTINUE
C                        OPTION NUMBER 2 -- DSNOUT
      CALL PPEATV (LACT)
      IF (LACT.AND.ICASE.GT. -1) THEN
         CALL ERRGRO(.TRUE.,16)
         WRITE(JOSTND,205) TRIM(DSNOUT)
  205    FORMAT (/T13,'DSNOUT CONNECTION CAN NOT BE REDEFINED.',
     >           ' DSN FOR OUTPUT REMAINS: ',A)
         READ (IREAD,'(A)',END=100) TMPSTR(1:1)
         GOTO 10
      ENDIF
      READ (IREAD,'(A)',END=100) DSNOUT
      IF(LKECHO)WRITE(JOSTND,210) KEYWRD, TRIM(DSNOUT)
  210 FORMAT(/1X,A8,'   DSN FOR OUTPUT CONNECTION IS ',A)
C--------
C     SIMPLY CALL THE DBS OPEN FUNCTION
C--------
      CALL DBSOPEN(DSNOUT,EnvHndlOut,ConnHndlOut,DBMSOUT,JOSTND,
     -             LKECHO,KODE)
      !MUST RESET ICASE
      ICASE     = -1
      CMPUID    = -1
      SUMRYID   = -1
      TREEOUTID = -1
      IATRTLID  = -1
      CUTSID    = -1
      FMPFID    = -1
      FUELID    = -1
      DM1ID     = -1
      DM2ID     = -1
      DM3ID     = -1
      DM5ID     = -1
      DM6ID     = -1
      CONID     = -1
      BURNID    = -1
      CMRPTID   = -1
      CHRPTID   = -1
      MORTID    = -1
      SSUMID    = -1
      SDETID    = -1
      STRCLID   = -1
      BM_MNID   = -1
      BMTREID   = -1
      BMVOLID   = -1
      BMBKPID   = -1
      DWDVID    = -1
      DWDCID    = -1

C     CHECK TO SEE IF A CONNECTION WAS SUCCESSFULLY OPENED
      IF (KODE.EQ.0) THEN
        ICOMPUTE  = 0
        ISUMARY   = 0
        IATRTLIST = 0
        ITREELIST = 0
        ICUTLIST  = 0
        IDM1      = 0
        IDM2      = 0
        IDM3      = 0
        IDM5      = 0
        IDM6      = 0
        IPOTFIRE  = 0
        IFUELS    = 0
        IFUELC    = 0
        IDWDVOL   = 0
        IDWDCOV   = 0
        IBURN     = 0
        ICMRPT    = 0
        ICHRPT    = 0
        ICLIM     = 0
        IMORTF    = 0
        ISSUM     = 0
        ISDET     = 0
        ISTRCLAS  = 0
        IBMMAIN   = 0
        IBMBKP    = 0
        IBMTREE   = 0
        IBMVOL    = 0
        IDBSECON  = 0

        WRITE(JOSTND,215)TRIM(DSNOUT)
  215   FORMAT(T13,'DBS ERROR: OUTPUT CONNECTION FAILED FOR DSN:',A)
      ELSE
        IF(LKECHO)WRITE(JOSTND,220) TRIM(DBMSOUT)
  220   FORMAT(T13,'CONNECTION DATA BASE TYPE:',A)
      ENDIF
      GOTO 10
  300 CONTINUE

C                        OPTION NUMBER 3 -- SQLOUT
      IF(LKECHO)WRITE(JOSTND,310) KEYWRD,'OUTPUT'
  310 FORMAT(/1X,A8,'   SQL COMMAND FOR ',A,' CONNECTION')
      CALL DBSIN_GETCMD(IREAD,JOSTND,IRECNT,SQLSTR,KODE,LKECHO)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         

      IF (KODE.GT.0) GOTO 10
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
      IF (.NOT.LNOTBK(1)) THEN

C       QUERY IS FOR IMMEDIATE EXECUTION
        CALL DBSEXECSQL(SQLSTR,ConnHndlOut,.FALSE.,KODE)
      ELSE

C       QUERY IF FOR SCHEDULED EXECUTION
        CALL OPNEW (KODE,IDT,102,0,ARRAY)
        IF (KODE.EQ.0) CALL OPCACT (KODE,SQLSTR)
        IF(LKECHO)WRITE(JOSTND,320) IDT
  320   FORMAT (T13,'DATE/CYCLE=',I5,
     >           '; SQL COMMAND IS PENDING.')
      ENDIF
      GOTO 10
  400 CONTINUE
C                        OPTION NUMBER 4 -- SUMMARY
      ISUMARY=1
      IF(LKECHO)WRITE(JOSTND,410) KEYWRD,TRIM(DSNOUT)
  410 FORMAT(/1X,A8,'   SUMMARY STATISTICS SENT TO CONNECTION ',A)
      GOTO 10
  500 CONTINUE
C                        OPTION NUMBER 5 -- COMPUTE
      ICOMPUTE=1
      IADDCMPU = 0
      IF(ARRAY(1).GT.0) IADDCMPU = 1
      I=1
      IF (IADDCMPU.EQ.1) I=2
      I_CMPU = 0
      IF(ARRAY(2).GT.0) I_CMPU = 1
      J=2
      IF (IADDCMPU.EQ.1) J=1
      IF(LKECHO)WRITE(JOSTND,510) KEYWRD,TRIM(DSNOUT),YESNO(I),YESNO(J)
  510 FORMAT(/1X,A8,'   COMPUTE VARIABLES SENT TO CONNECTION ',A/
     >       T13,'ADD NEW VARIABLES TO EXISTING TABLE: ',A/
     >       T13,'INCLUDE VARIABLES STARTING WITH UNDERSCORE: ',A)

      GOTO 10
  600 CONTINUE
C                        OPTION NUMBER 6 -- TREELIST
      ITREELIST = 1
      I=1
      ISPOUT6=0
      IF(ARRAY(1).GT.0) ITREELIST = ARRAY(1)
      IF(ARRAY(2).GT.0) ISPOUT6 = ARRAY(2)
      IF(ISPOUT6.EQ.1)THEN
        CSPOUT='ALPHA'
      ELSEIF(ISPOUT6.EQ.2)THEN
        CSPOUT='FIA'
      ELSEIF(ISPOUT6.EQ.3)THEN
        CSPOUT='PLANTS'
      ELSE
        CSPOUT='NORMAL'
      ENDIF
      I=ITREELIST
      IF(LKECHO)WRITE(JOSTND,610) KEYWRD,TRIM(DSNOUT),YESNO(I),CSPOUT
  610 FORMAT(/1X,A8,'   TREE INFORMATION FROM OUTPUT SENT ',
     >       'TO CONNECTION ',A/
     >       T13,'CREATE TEXT FILE REPORT: ',A/
     >       T13,'SPECIES CODE OUTPUT FORMAT: ',A)
      GOTO 10
  700 CONTINUE
C                        OPTION NUMBER 7 -- STANDIN

      IF(LKECHO)WRITE(JOSTND,710) KEYWRD,TRIM(DSNIN)
  710 FORMAT(/1X,A8,' STANDIN COMMAND FOR INPUT CONNECTION: ',A)

      CALL DBSIN_GETCMD(IREAD,JOSTND,IRECNT,STNDKODS,KODE,LKECHO)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         
      
      IF (KODE.EQ.0.AND.LEN(TRIM(STNDKODS)).GT.0) THEN

C       CREATE QUERY STRING
        IF(TRIM(DBMSOUT).EQ.'EXCEL') THEN
          TABLENAME = '[FVS_StandInit$]'
        ELSE
          TABLENAME = 'FVS_StandInit'
        ENDIF
        !CREATE THE COLNAMES STRING FOR THE SQL QUERY
        COLNAMES = ''
        DO WHILE(LEN(TRIM(STNDKODS)).GT.0)
          CALL DBSPRS(COLUMN,STNDKODS,' ')
          TMPSTR = TRIM(COLNAMES)
          COLNAMES = TRIM(TMPSTR)//TRIM(COLUMN)//','
        ENDDO
        !STRIP OFF TRAILING COMMA
        STRLEN = LEN(TRIM(COLNAMES))
        TMPSTR = TRIM(COLNAMES)
        COLNAMES = TMPSTR(:STRLEN-1)
        !CREATE QUERY
        WRITE(STNDSQL,*)'SELECT ',TRIM(COLNAMES),' FROM ',
     -  TRIM(TABLENAME),' WHERE Stand_ID = ',CHAR(39),TRIM(NPLT),
     -  CHAR(39),' AND Inv_Year = ',IY(1)

        CALL DBSSTANDIN(STNDSQL,LKECHO)
      ENDIF

      GOTO 10
  800 CONTINUE
C                        OPTION NUMBER 8 -- CLIMATE
      ICLIM = 1
      IF(LKECHO) WRITE(JOSTND,810) KEYWRD
  810 FORMAT(/1X,A8,'   OUTPUT THE CLIMATE-FVS TABLE',A)
      GOTO 10
  900 CONTINUE
C                        OPTION NUMBER 9 -- DRIVERS
      WRITE(JOSTND,910) KEYWRD
  910 FORMAT(/1X,A8,'   ODBC DRIVERS AND ATTRIBUTES:')
      CALL DBSDRIV(JOSTND)
      GOTO 10
 1000 CONTINUE
C                        OPTION NUMBER 10 -- DSNIN

      READ (IREAD,'(A)',END=100) DSNIN
      IF(LKECHO)WRITE(JOSTND,1010) KEYWRD, TRIM(DSNIN)
 1010 FORMAT(/1X,A8,'   DSN FOR INPUT CONNECTION IS ',A)
C--------
C     SIMPLY CALL THE DBS OPEN FUNCTION
C--------
      CALL DBSOPEN(DSNIN,EnvHndlIn,ConnHndlIn,DBMSIN,JOSTND,
     -             LKECHO,KODE)
C     CHECK TO SEE IF CONNECTION WAS SUCCESSFUL
      IF (KODE.EQ.0) THEN
        WRITE(JOSTND,1015)TRIM(DSNIN)
 1015   FORMAT(T13,'DBS ERROR: INPUT CONNECTION FAILED FOR DSN:',A)
      ELSE
        IF(LKECHO)WRITE(JOSTND,1020) TRIM(DBMSIN)
 1020   FORMAT(T13,'CONNECTION DATA BASE TYPE:',A)
      ENDIF

      GOTO 10
 1100 CONTINUE
C                        OPTION NUMBER 11 -- STANDSQL
      IF(LKECHO)WRITE(JOSTND,1110) KEYWRD,TRIM(DSNIN)
 1110 FORMAT(/1X,A8,T13'STANDSQL COMMAND FOR INPUT CONNECTION: ',A)

      CALL DBSIN_GETCMD(IREAD,JOSTND,IRECNT,STNDSQL,KODE,LKECHO)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         
      
      IF (KODE.EQ.0) THEN
C       PARSE OUT AND REPLACE WITH USER DEFINED AND EVENT MONITOR VAR VALS
        CALL DBSPRSSQL(STNDSQL,.FALSE.,KODE)
        IF(KODE.EQ.0) THEN
C         THERE WAS A PROBLEM IN PARSING THE SQL STATEMENT
          WRITE(JOSTND,1120) 'STANDSQL',TRIM(STNDSQL)
 1120     FORMAT (1X,'********  WARNING: ',A,' CAN NOT PREFORM'
     &      ' SUBSTITUTIONS IN SQL COMMAND: ',A)
          CALL RCDSET(2,.TRUE.)
          RETURN
        ENDIF
        CALL DBSSTANDIN(STNDSQL,LKECHO)
      ENDIF
      GOTO 10
 1200 CONTINUE
C                        OPTION NUMBER 12 -- TREESQL
      IF(LKECHO)WRITE(JOSTND,1210) KEYWRD,TRIM(DSNIN)
 1210 FORMAT(/1X,A8,T13'TREESQL COMMAND FOR INPUT CONNECTION: ',A)

      CALL DBSIN_GETCMD(IREAD,JOSTND,IRECNT,SQLSTR,KODE,LKECHO)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         
      
      IF (KODE.EQ.0) THEN
C        MAKE SURE WE HAVE AN OPEN CONNECTION
         IF(ConnHndlIn.EQ.-1) CALL DBSOPEN(DSNIN,EnvHndlIn,
     -                             ConnHndlIn,DBMSIN,JOSTND,LKECHO,KODE)
C        ALLOCATE A STATEMENT HANDLE

         iRet = fvsSQLAllocHandle(SQL_HANDLE_STMT,ConnHndlIn,
     -                          StmtHndlTree)
         IF (iRet.NE.SQL_SUCCESS .AND.
     -       iRet.NE. SQL_SUCCESS_WITH_INFO) THEN
            CALL  DBSDIAGS(SQL_HANDLE_DBC,ConnHndlIn,
     -             'DBSIN:DSN Connection')
         ELSE
C           PARSE OUT AND REPLACE WITH USER DEFINED AND EVENT MONITOR VAR VALS
            CALL DBSPRSSQL(SQLSTR,.FALSE.,KODE)
            IF(KODE.EQ.0) THEN
C             THERE WAS A PROBLEM IN PARSING THE SQL STATEMENT
              IF(LKECHO)WRITE(JOSTND,1120) 'TREESQL',TRIM(SQLSTR)
              CALL RCDSET(2,.TRUE.)
              RETURN
            ENDIF
C          EXECUTE QUERY
           iRet = fvsSQLExecDirect(StmtHndlTree,trim(SQLSTR),
     -          int(len_trim(SQLSTR),SQLINTEGER_KIND))
           IF (iRet.EQ.SQL_SUCCESS .OR.
     -         iRet.EQ. SQL_SUCCESS_WITH_INFO) THEN
             ITREEIN = 1
             CALL INTREE(TMPSTR,2,ISDSP,SDLO,SDHI,LKECHO)
             CALL getfvsRtnCode(IRTNCD)
             IF (IRTNCD.NE.0) RETURN         
             MORDAT = .TRUE.
           ELSE
             CALL DBSDIAGS(SQL_HANDLE_STMT,StmtHndlTree,
     -            'DBSIN:Executing TreeSQL KeyWrd: '//trim(SQLSTR))
           ENDIF
         ENDIF
         ITREEIN = 0
      ENDIF
      GOTO 10
 1300 CONTINUE
C                        OPTION NUMBER 13 -- POTFIRE
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IPOTFIRE=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IPOTFIRE = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,1310) KEYWRD,TRIM(DSNOUT),YESNO(I)
 1310    FORMAT(/1X,A8,'   POTFIRE STATISTICS SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IPOTFIRE))
      ELSE
         IF(LKECHO)WRITE(JOSTND,1310) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 1400 CONTINUE
C                        OPTION NUMBER 14 -- FUELSOUT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IFUELS=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IFUELS = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,1410) KEYWRD,TRIM(DSNOUT),YESNO(I)
 1410    FORMAT(/1X,A8,'   FUELS STATISTICS SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IFUELS))
      ELSE
         WRITE(JOSTND,1410) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 1500 CONTINUE
C                        OPTION NUMBER 15 -- DSNESTAB
      READ (IREAD,'(A)') DSNRGIN
      IF(LKECHO)WRITE(JOSTND,1510) KEYWRD, TRIM(DSNRGIN)
 1510 FORMAT(/1X,A8,'   DSN FOR REGEN INPUT CONNECTION IS ',A)
C--------
C     SIMPLY CALL THE DBS OPEN FUNCTION
C--------
      CALL DBSOPEN(DSNRGIN,EnvHndlRgnIn,ConnHndlRgnIn,DBMSRGIN,
     -             JOSTND,LKECHO,KODE)
      IF (KODE .EQ. 0) THEN
        IRGIN = 1
        IF(LKECHO)WRITE(JOSTND,1515) TRIM(DBMSRGIN)
 1515   FORMAT(T13,'SUCCESSFUL CONNECTION TO DATABASE TYPE:',A)
      ELSE
        WRITE(JOSTND,1516)
 1516   FORMAT(T13,'CONNECTION TO DATABASE FAILED.')
        CALL  DBSDIAGS(SQL_HANDLE_DBC,ConnHndlRgnIn,
     &        'DSNRGIN:DSN Connection')
      ENDIF
      GOTO 10
 1600 CONTINUE
C                        OPTION NUMBER 16 -- SQLIN
      IF(LKECHO)WRITE(JOSTND,310) KEYWRD,'INPUT'
      CALL DBSIN_GETCMD(IREAD,JOSTND,IRECNT,SQLSTR,KODE,LKECHO)
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         
      
      IF (KODE.GT.0) GOTO 10
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
      IF (.NOT.LNOTBK(1)) THEN

C       QUERY IS FOR IMMEDIATE EXECUTION
        CALL DBSEXECSQL(SQLSTR,ConnHndlIn,.FALSE.,KODE)
      ELSE

C       QUERY IF FOR SCHEDULED EXECUTION
        CALL OPNEW (KODE,IDT,101,0,ARRAY)
        IF (KODE.EQ.0) CALL OPCACT (KODE,SQLSTR)
        IF(LKECHO)WRITE(JOSTND,320) IDT
      ENDIF
      GOTO 10
 1700 CONTINUE
C                        OPTION NUMBER 17 -- CUTLIST
      ICUTLIST = 1
      I=1
      ISPOUT17=0
      IF(ARRAY(1).GT.0) ICUTLIST = ARRAY(1)
      IF(ARRAY(2).GT.0) ISPOUT17 = ARRAY(2)
      IF(ISPOUT17.EQ.1)THEN
        CSPOUT='ALPHA'
      ELSEIF(ISPOUT17.EQ.2)THEN
        CSPOUT='FIA'
      ELSEIF(ISPOUT17.EQ.3)THEN
        CSPOUT='PLANTS'
      ELSE
        CSPOUT='NORMAL'
      ENDIF
      I=ICUTLIST
      IF(LKECHO)WRITE(JOSTND,1710) KEYWRD,TRIM(DSNOUT),CSPOUT,YESNO(I)
 1710 FORMAT(/1X,A8,T13,'CUTS INFORMATION FROM OUTPUT SENT ',
     >       'TO CONNECTION ',A/
     >       T13,'SPECIES CODE OUTPUT FORMAT: ',A/
     >       T13,'CREATE TEXT FILE REPORT: ',A)
      GOTO 10
 1800 CONTINUE
C                        OPTION NUMBER 18 -- MISRPTS
      IDM1 = 1
      IDM2 = 1
      IDM3 = 1
      IDM5 = 1
      IDM6 = 1
      I=1
      IF(ARRAY(1).GT.0) THEN
        IDM1 = ARRAY(1)
        IDM2 = ARRAY(1)
        IDM3 = ARRAY(1)
        IDM5 = ARRAY(1)
        IDM6 = ARRAY(1)
      ENDIF
      I=IDM1
      IF(LKECHO)WRITE(JOSTND,1810) KEYWRD,TRIM(DSNOUT),YESNO(I)
 1810 FORMAT(/1X,A8,'   MISTLETOE INFORMATION FROM OUTPUT SENT ',
     >       'TO CONNECTION ',A/
     >       T13,'CREATE TEXT FILE REPORTS: ',A)
      GOTO 10
 1900 CONTINUE
C                        OPTION NUMBER 19 -- FUELREPT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IFUELC=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IFUELC = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,1910) KEYWRD,TRIM(DSNOUT),YESNO(I)
 1910    FORMAT(/1X,A8,'   CONSUMPTION STATS SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IFUELC))
      ELSE
         WRITE(JOSTND,1910) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 2000 CONTINUE
C                        OPTION NUMBER 20 -- BURNREPT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IBURN=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IBURN = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2010) KEYWRD,TRIM(DSNOUT),YESNO(I)
 2010    FORMAT(/1X,A8,'   BURN CONDITION STATS SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IBURN))
      ELSE
         WRITE(JOSTND,2010) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 2100 CONTINUE
C                        OPTION NUMBER 21 -- MORTREPT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IMORTF=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IMORTF = 2
           I=2
         ENDIF
         ISPOUT21=0
         IF(ARRAY(2).GT.0) ISPOUT21 = ARRAY(2)
         IF(ISPOUT21.EQ.1)THEN
           CSPOUT='ALPHA'
         ELSEIF(ISPOUT21.EQ.2)THEN
           CSPOUT='FIA'
         ELSEIF(ISPOUT21.EQ.3)THEN
           CSPOUT='PLANTS'
         ELSE
           CSPOUT='NORMAL'
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2110) KEYWRD,TRIM(DSNOUT),CSPOUT,
     &   YESNO(I)
 2110    FORMAT(/1X,A8,'   FFE MORTALITY INFO SENT TO CONNECTION ',A/
     >       T13,'SPECIES CODE OUTPUT FORMAT: ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IMORTF))
      ELSE
         WRITE(JOSTND,2110) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 2200 CONTINUE
C                        OPTION NUMBER 22 -- SNAGSUM
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         ISSUM=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           ISSUM = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2210) KEYWRD,TRIM(DSNOUT),YESNO(I)
 2210    FORMAT(/1X,A8,'   SUMMARY SNAG INFO SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(ISSUM))
      ELSE
         WRITE(JOSTND,2210) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 2300 CONTINUE
C                        OPTION NUMBER 23 -- SNAGOUT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         ISDET=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           ISDET = 2
           I=2
         ENDIF
         ISPOUT23=0
         IF(ARRAY(2).GT.0) ISPOUT23 = ARRAY(2)
         IF(ISPOUT23.EQ.1)THEN
           CSPOUT='ALPHA'
         ELSEIF(ISPOUT23.EQ.2)THEN
           CSPOUT='FIA'
         ELSEIF(ISPOUT23.EQ.3)THEN
           CSPOUT='PLANTS'
         ELSE
           CSPOUT='NORMAL'
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2310) KEYWRD,TRIM(DSNOUT),CSPOUT,
     &   YESNO(I)
 2310    FORMAT(/1X,A8,'   DETAILED SNAG INFO SENT TO CONNECTION ',A/
     >       T13,'SPECIES CODE OUTPUT FORMAT: ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(ISDET))
      ELSE
         WRITE(JOSTND,2310) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 2400 CONTINUE
C                        OPTION NUMBER 24 -- STRCLASS
      ISTRCLAS=1
      I=1
      IF(ARRAY(1).GT.1) THEN
C       WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
        ISTRCLAS = 2
        I=2
      ENDIF
      IF(LKECHO)WRITE(JOSTND,2410) KEYWRD,TRIM(DSNOUT),YESNO(I)
 2410 FORMAT(/1X,A8,'   STRUCTURE CLASS INFO SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
      IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(ISTRCLAS))
      GOTO 10
 2500 CONTINUE
C                        OPTION NUMBER 25 --PPBMMAIN
      CALL BMLNKD(LACT)
      IF (LACT) THEN
         IBMMAIN=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IBMMAIN = 2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2510) KEYWRD,TRIM(DSNOUT)
 2510    FORMAT(/1X,A8,'   WWPBM MAIN OUTPUT SENT TO CONNECTION ',A/)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IBMMAIN))
      ELSE
         WRITE(JOSTND,2510) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF

      GOTO 10
 2600 CONTINUE
C                        OPTION NUMBER 26 --PPBMTREE
      CALL BMLNKD(LACT)
      IF (LACT) THEN
         IBMTREE=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IBMTREE = 2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2610) KEYWRD,TRIM(DSNOUT)
 2610    FORMAT(/1X,A8,'   WWPBM TREE-LEVEL OUTPUT SENT TO CONNECTION ',
     >       A /)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IBMTREE))
      ELSE
         WRITE(JOSTND,2610) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF

      GOTO 10
 2700 CONTINUE
C                        OPTION NUMBER 27 --PPBMBKP
      CALL BMLNKD(LACT)
      IF (LACT) THEN
         IBMBKP=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IBMBKP = 2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2710) KEYWRD,TRIM(DSNOUT)
 2710    FORMAT(/1X,A8,'   WWPBM DETAILED BKP OUTPUT SENT TO'
     >    'CONNECTION:',A/)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IBMBKP))
      ELSE
         WRITE(JOSTND,2710) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF

      GOTO 10
 2800 CONTINUE
C                        OPTION NUMBER 28 --PPBMVOL
      CALL BMLNKD(LACT)
      IF (LACT) THEN
         IBMVOL=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IBMVOL = 2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2810) KEYWRD,TRIM(DSNOUT)
 2810    FORMAT(/1X,A8,'   WWPBM DETAILED VOLUME OUTPUT SENT TO '
     >       ' CONNECTION ',A/)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IBMMAIN))
      ELSE
         WRITE(JOSTND,2810) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF

      GOTO 10
C
 2900 CONTINUE
C                        OPTION NUMBER 29 -- CARBRPTS
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         ICMRPT=1
         ICHRPT=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           ICMRPT=2
           ICHRPT=2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,2910) KEYWRD,TRIM(DSNOUT),YESNO(I)
 2910    FORMAT(/1X,A8,'   CARBON REPORTS SENT TO CONNECTION ',A/
     >       T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(I))
      ELSE
         WRITE(JOSTND,2910) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
C
 3000 CONTINUE
C                        OPTION NUMBER 30 -- ECONRPTS
      IDBSECON=2
      ISPOUT30=0
      IF(NINT(ARRAY(1)) == 1) IDBSECON=1
      IF(ARRAY(2).GT.0) ISPOUT30 = ARRAY(2)
      IF(ISPOUT30.EQ.1)THEN
        CSPOUT='ALPHA'
      ELSEIF(ISPOUT30.EQ.2)THEN
        CSPOUT='FIA'
      ELSEIF(ISPOUT30.EQ.3)THEN
        CSPOUT='PLANTS'
      ELSE
        CSPOUT='NORMAL'
      ENDIF
      IF(LKECHO) WRITE(JOSTND,3010) KEYWRD,TRIM(DSNOUT),CSPOUT
 3010 FORMAT(/1X,A8,'   ECON REPORTS SENT TO CONNECTION ', A/
     >       T13,'SPECIES CODE OUTPUT FORMAT: ',A)
      GOTO 10
 3100 CONTINUE
C                        OPTION NUMBER 31 -- ATRTLIST
      IATRTLIST = 1
      I=1
      ISPOUT31=0
      IF(ARRAY(1).GT.0) IATRTLIST = ARRAY(1)
      IF(ARRAY(2).GT.0) ISPOUT31 = ARRAY(2)
      IF(ISPOUT31.EQ.1)THEN
        CSPOUT='ALPHA'
      ELSEIF(ISPOUT31.EQ.2)THEN
        CSPOUT='FIA'
      ELSEIF(ISPOUT31.EQ.3)THEN
        CSPOUT='PLANTS'
      ELSE
        CSPOUT='NORMAL'
      ENDIF
      I=IATRTLIST
      IF(LKECHO)WRITE(JOSTND,3110) KEYWRD,TRIM(DSNOUT),CSPOUT,YESNO(I)
 3110 FORMAT(/1X,A8,'   TREE INFORMATION FROM OUTPUT SENT ',
     >       'TO CONNECTION ',A/
     >       T13,'SPECIES CODE OUTPUT FORMAT: ',A/
     >       T13,'CREATE TEXT FILE REPORT: ',A)
      GOTO 10
 3200 CONTINUE
C                        OPTION NUMBER 32 -- DWDVLOUT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IDWDVOL=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IDWDVOL = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,3210) KEYWRD,TRIM(DSNOUT),YESNO(I)
 3210    FORMAT(/1X,A8,'   DOWN WOOD VOLUME REPORT SENT TO CONNECTION ',
     >       A/ T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IDWDVOL))
      ELSE
         WRITE(JOSTND,3210) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
 3300 CONTINUE
C                        OPTION NUMBER 33 -- DWDCVOUT
      CALL FMLNKD(LACT)
      IF (LACT) THEN
         IDWDCOV=1
         I=1
         IF(ARRAY(1).GT.1) THEN
C          WE ARE REDIRECTING OUTPUT AND DON'T WANT TO PRINT TO FILE
           IDWDCOV = 2
           I=2
         ENDIF
         IF(LKECHO)WRITE(JOSTND,3310) KEYWRD,TRIM(DSNOUT),YESNO(I)
 3310    FORMAT(/1X,A8,'   DOWN WOOD COVER REPORT SENT TO CONNECTION ',
     >        A/ T13,'INCLUDE REPORT IN OUT FILE: ',A)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') TRIM(TYPEMSG(IDWDCOV))
      ELSE
         WRITE(JOSTND,3310) KEYWRD,TRIM(DSNOUT)
         CALL ERRGRO (.TRUE.,11)
      ENDIF
      GOTO 10
C
C.... Special entry to retrieve keywords.
C
      ENTRY DBSKEY (KEY,PASKEY)
      PASKEY= TABLEME(KEY)
      RETURN
C
C     ENTRY TO FETCH WWPBM OUTPUT TABLE FLAGS
C     CALLED FROM BMSDIT

      ENTRY DBSWW(I1,I2,I3,I4)
         I1=IBMMAIN
         I2=IBMTREE
         I3=IBMBKP
         I4=IBMVOL
      RETURN

      END

      SUBROUTINE DBSIN_GETCMD(INFILE,JOSTND,IRECNT,CMDBUF,KODE,LKECHO)
      IMPLICIT NONE

C     PRIVATE ROUTINE TO DBSIN, USED TO LOAD THE CMDBUF.
      LOGICAL LKECHO
      INTEGER INFILE,JOSTND,IRECNT,KODE
      INTEGER I1,I2,MXLEN,IRTNCD
      CHARACTER*(*) CMDBUF
      CHARACTER*140 LINE

      MXLEN=LEN(CMDBUF)

      I1=1
   10 CONTINUE
      READ (INFILE,'(A)',END=100) LINE
      IRECNT = IRECNT+1
      IF (INDEX(LINE,'EndSQL').EQ.0) THEN
         I2=LEN_TRIM(LINE)
         IF(LKECHO)WRITE(JOSTND,'(T13,A)') LINE(:I2)
         LINE=ADJUSTL(TRIM(LINE))
         I2=LEN_TRIM(LINE)
         IF (I1+I2.GE.MXLEN) THEN
            WRITE(JOSTND,20)
   20       FORMAT (/' ******** ERROR: SQL COMMAND TOO LONG.')
            KODE=1
            CALL RCDSET (2,.TRUE.)
         ELSE
            CMDBUF(I1:)=LINE(:I2)
            I1=I1+I2+1
            GOTO 10
         ENDIF
      ELSE
         KODE=0
      ENDIF
      RETURN
  100 CONTINUE
      CALL ERRGRO(.FALSE.,2) ! will not return
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN         

      END
