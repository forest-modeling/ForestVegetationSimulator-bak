      SUBROUTINE ERRGRO (LRETRN,IERRN)
      IMPLICIT NONE
C----------
C  **ERRGRO--BASE   DATE OF LAST REVISION:  11/07/2012
C----------
C
C     ERROR PROCESSOR FOR THE FOREST VEGETATION SIMULATOR.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C
      LOGICAL LRETRN
      INTEGER IERRN,IPTKNT,I
      CHARACTER*12 PREF
C
      DATA PREF/' ********   '/
      GO TO( 1000,1200,1300,1400,1500,1600,1700,1800,1900,2000
     >      ,2100,2200,2300,2400,2500,2600,2700,2800,2900,3000
     >      ,3100,3200,3300,3400,3500,3600,3700,3800,3900,4000
     >      ,4100,4200,4300,4400,4500,4600),  IERRN 
 1000 CONTINUE
C                        ERROR NUMBER 1
      WRITE (JOSTND,1110) PREF,IRECNT
 1110 FORMAT (/,A12,'FVS01 ERROR:  INVALID KEYWORD WAS SPECIFIED.',
     >        '  RECORDS READ=',I4)
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 1200 CONTINUE
C                        ERROR NUMBER 2
      WRITE (JOSTND,1210) PREF,IRECNT
 1210 FORMAT (/,A12,'FVS02 ERROR:  NO "STOP" RECORD IN KEYWORD FILE',
     >        ';  RECORDS READ=',I4,'; END-OF-FILE.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 1300 CONTINUE
C                        ERROR NUMBER 3
      WRITE (JOSTND,1310) PREF
 1310 FORMAT (/,A12,'FVS03 WARNING:  FOREST CODE INDICATES THE',
     >        ' GEOGRAPHIC LOCATION IS OUTSIDE THE RANGE OF THE ',
     >        'MODEL.  DEFAULT CODE IS USED.')
      GO TO 9000
 1400 CONTINUE
C                        ERROR NUMBER 4
      WRITE (JOSTND,1410) PREF
 1410 FORMAT (/,A12,'FVS04 ERROR:  A REQUIRED PARAMETER IS MISSING',
     >        ' OR A PARAMETER IS INCORRECT; KEYWORD IGNORED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 1500 CONTINUE
C                        ERROR NUMBER 5
      WRITE (JOSTND,1510) PREF
 1510 FORMAT (/,A12,'FVS05 ERROR: EXPRESSION IS TOO LONG.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 1600 CONTINUE
C                        ERROR NUMBER 6
      WRITE (JOSTND,1610) PREF,IRECNT
 1610 FORMAT (/,A12,'FVS06 ERROR:  KEYWORD RECORD WAS INCORRECTLY',
     >        ' READ. RECORDS READ=',I4)
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 1700 CONTINUE
C                        ERROR NUMBER 7
      WRITE (JOSTND,1710) PREF
 1710 FORMAT (/,A12,'FVS07 WARNING:  A TREEFMT OR SPCODES RECORD',
     >        ' FOLLOWS A TREEDATA RECORD.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 1800 CONTINUE
C                        ERROR NUMBER 8
      WRITE (JOSTND,1810) PREF,IREC1,IRECRD,NPLT
 1810 FORMAT (/,A12,'FVS08 WARNING:  TOO FEW PROJECTABLE TREE RECORDS.',
     >        '  PROJECTABLE RECORDS:',I2,';',/,28X,'TREE RECORDS:',I4,
     >        ';  STAND ID: ',A26)
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 1900 CONTINUE
C                        ERROR NUMBER 9
      IPTKNT=LSTKNT-1
      WRITE (JOSTND,1910) PREF,IPTKNT,NSTKNT
 1910 FORMAT (/,A12,'FVS09 WARNING:  PLOT COUNTS DO NOT MATCH ',
     >        'DATA ON THE DESIGN RECORD; DESIGN RECORD DATA USED.',/
     >        T29,'PLOT COUNT=',I4,'; NONSTOCKABLE COUNT=',I4)
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 2000 CONTINUE
C                        ERROR NUMBER 10
      WRITE (JOSTND,2010) PREF
 2010 FORMAT (/,A12,'FVS10 ERROR:  OPTION/ACTIVITY STORAGE AREA IS',
     >        ' FULL;  REQUEST(S) IGNORED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 2100 CONTINUE
C                        ERROR NUMBER 11
      WRITE (JOSTND,2110) PREF
 2110 FORMAT (/A12,'FVS11 ERROR:  REQUESTED EXTENSION IS NOT PART',
     >        ' OF THIS PROGRAM.')
      IF (ICCODE .LT. 3) ICCODE=3
      GO TO 9000
 2200 CONTINUE
C                        ERROR NUMBER 12
      WRITE (JOSTND,2210) PREF
 2210 FORMAT (/A12,'FVS12 ERROR:  ERROR COMPILING EXPRESSION RENDERS',
     >             ' IT USELESS.  IT WILL BE IGNORED.')
      IF (ICCODE.LT.2) ICCODE=2
      GO TO 9000
 2300 CONTINUE
C                        ERROR NUMBER 13
      WRITE (JOSTND,2310) PREF,IRECRD,LSTKNT
 2310 FORMAT (/,A12,'FVS13 ERROR:  THE MAXIMUM NUMBER OF USEABLE ',
     >        'TREE RECORDS HAVE BEEN PROCESSED.  NUMBER READ =',I6,
     >        '; PLOT COUNT =',I3)
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 2400 CONTINUE
C                        ERROR NUMBER 14
      WRITE(JOSTND,2410) PREF
 2410 FORMAT(/A12,'FVS14 WARNING:  HABITAT/PLANT ASSOCIATION/ECOREGION',
     &            ' CODE WAS NOT RECOGNIZED; HABITAT/PLANT ',
     &            'ASSOCIATION/ECOREGION SET TO DEFAULT CODE.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 2500 CONTINUE
C                        ERROR NUMBER 15
      WRITE (JOSTND,2510) PREF
 2510 FORMAT (/,A12,'FVS15 ERROR:  ATTEMPT TO REDEFINE A RESERVED ',
     >       'VARIABLE.  EXPRESSION IGNORED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 2600 CONTINUE
C                        ERROR NUMBER 16
      WRITE (JOSTND,2610) PREF,IRECNT
 2610 FORMAT (/A12,'FVS16 ERROR:  KEYWORD ENTERED IS USED IN ',
     >        'WRONG CONTEXT AND WAS IGNORED.  RECORDS READ=',I4)
      IF (ICCODE.LT.2) ICCODE=2
      GO TO 9000
 2700 CONTINUE
C                        ERROR NUMBER 17
      WRITE (JOSTND,2710) PREF
 2710 FORMAT (/A12,'FVS17 ERROR:  EVENT MONITOR STORAGE AREA IS FULL.')
      IF (ICCODE.LT.2) ICCODE=2
      GO TO 9000
 2800 CONTINUE
C                        ERROR NUMBER 18
      WRITE (JOSTND,2810) PREF
 2810 FORMAT (/A12,'FVS18 ERROR:  ATTEMPT TO SCHEDULE A GROUP OF ',
     >        'ACTIVITIES FAILED.')
      IF (ICCODE.LT.3) ICCODE=3
      GO TO 9000
 2900 CONTINUE
C                        ERROR NUMBER 19
      WRITE (JOSTND,2910) PREF
 2910 FORMAT(/,A12,'FVS19 ERROR:  INCORRECT RECORD TYPE OR END OF ',
     >        'DATA FOUND WHILE READING SAMPLE TREE SCRATCH FILE.')
      IF (ICCODE .LT. 4) ICCODE=4
      GO TO 9000
 3000 CONTINUE
C                        ERROR NUMBER 20
      WRITE (JOSTND,3010) PREF
 3010 FORMAT(/,A12,'FVS20 WARNING:  SAMPLE TREE AND STAND ATTRIBUTE',
     >        ' TABLE SCRATCH FILE IS EMPTY; TABLE NOT PRINTED.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 3100 CONTINUE
C                        ERROR NUMBER 21
      WRITE (JOSTND,3110) PREF
 3110 FORMAT (/,A12,'FVS21 ERROR:  AN EXPRESSION ',
     >  'WAS INCORRECTLY COMPUTED; ANSWER IS IGNORED.')
      IF (ICCODE .LT. 1) ICCODE=2
      GO TO 9000
 3200 CONTINUE
C                        ERROR NUMBER 22
      WRITE (JOSTND,3210) PREF
 3210 FORMAT(/A12,'FVS22 ERROR:  OVER 9 ALTERNATIVE ACTIVITY GROUPS ',
     >        'SPECIFIED, CURRENT GROUP MAY NOT BE SCHEDULED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 3300 CONTINUE
C                        ERROR NUMBER 23
      WRITE(JOSTND,3310) PREF
 3310 FORMAT(/A12,'FVS23 WARNING:  PLANT ASSOCIATION (FIELD 2) NOT ',
     &            'RECOGNIZED.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 3400 CONTINUE
C                        ERROR NUMBER 24
      WRITE(JOSTND,3410) PREF
 3410 FORMAT(/A12,'FVS24 WARNING:  MODEL TYPE (FIELD 2) NOT ',
     &            'RECOGNIZED.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
C                        ERROR NUMBER 25
 3500 CONTINUE
      WRITE(JOSTND,3510) PREF
 3510 FORMAT(/A12,'FVS25 ERROR:  INCORRECT USE/PLACEMENT OF PARMS;',
     >        ' KEYWORD IGNORED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 3600 CONTINUE
C                        ERROR NUMBER 26
      WRITE(JOSTND,3610) PREF
 3610 FORMAT(/A12,'FVS26 ERROR:  GENERAL REPORTS SCRATCH FILE CAN',
     >        ' NOT BE OPENED.')
      IF (ICCODE .LT. 3) ICCODE=3
      GO TO 9000
 3700 CONTINUE
C                        ERROR NUMBER 27
      WRITE (JOSTND,3710) PREF
 3710 FORMAT (/,A12,'FVS27 WARNING:  CALCULATED CALIBRATION VALUE ',
     >        'OUTSIDE REASONABLE RANGE. CALIBRATION OF THIS SPECIES ',
     >        'BEING TURNED OFF.')
      GO TO 9000
 3800 CONTINUE
C                        ERROR NUMBER 28
      WRITE (JOSTND,3810) PREF
 3810 FORMAT (/,A12,'FVS28 ERROR:  MAXIMUM NUMBER OF 10 SPECIES GROUPS',
     >        ' HAS ALREADY BEEN DEFINED; KEYWORD IGNORED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 3900 CONTINUE
C                        ERROR NUMBER 29
      WRITE (JOSTND,3910) PREF
 3910 FORMAT (/,A12,'FVS29 ERROR:  A SPECIES CODE WAS NOT RECOGNIZED.',
     >        ' THIS SPECIES WILL BE IGNORED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
 4000 CONTINUE
C                        ERROR NUMBER 30
      GOTO 9000
C                        ERROR NUMBER 31
 4100 CONTINUE
      WRITE(JOSTND,4110) PREF
 4110 FORMAT(/A12,'FVS31 ERROR:  .KCP OR .ADD FILE CAN NOT BE OPENED.')
      IF (ICCODE .LT. 2) ICCODE=2
      GO TO 9000
C                        ERROR NUMBER 32
 4200 CONTINUE
      WRITE(JOSTND,4210) PREF
 4210 FORMAT(/A12,'FVS32 WARNING:  PV REFERENCE CODE WAS NOT ',
     &            'RECOGNIZED; HABITAT/PLANT ASSOCIATION/ECOREGION ',
     &            'SET TO DEFAULT CODE.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
C                        ERROR NUMBER 33
 4300 CONTINUE
      WRITE(JOSTND,4310) PREF
 4310 FORMAT(/A12,'FVS33 WARNING:  PV CODE WAS NOT ',
     &            'RECOGNIZED; HABITAT/PLANT ASSOCIATION/ECOREGION ',
     &            'SET TO DEFAULT CODE.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
C                        ERROR NUMBER 34
 4400 CONTINUE
      WRITE(JOSTND,4410) PREF
 4410 FORMAT(/A12,'FVS34 WARNING:  PV CODE/PV REFERENCE CODE ',
     &            'COMBINATION WAS NOT RECOGNIZED; HABITAT/PLANT ',
     &            'ASSOCIATION/ECOREGION SET TO DEFAULT CODE.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
C                        ERROR NUMBER 35
 4500 CONTINUE
      WRITE(JOSTND,4510)  PREF
 4510 FORMAT(/A12,'FVS35 WARNING:  THE NUMBER OF NONSTOCKABLE ',
     &            'PLOTS EQUALS THE TOTAL NUMBER OF PLOTS. ',
     &            /T29,'NUMBER OF NONSTOCKABLE PLOTS SET TO ZERO.')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
C                        ERROR NUMBER 36
 4600 CONTINUE
      WRITE(JOSTND,4610)  PREF
 4610 FORMAT(/A12,'FVS36 WARNING:  EXCESSIVE TREE HEIGHT: UNABLE TO ',
     &         'CALCULATE VOLUME FOR TREE RECORD, VOLUME SET TO ZERO')
      IF (ICCODE .LT. 1) ICCODE=1
      GO TO 9000
 9000 CONTINUE
      IF (.NOT. LRETRN) CALL fvsSetRtnCode(1)
      RETURN
C
      ENTRY getICCODE(I)

      I = ICCODE 
      RETURN
      END
