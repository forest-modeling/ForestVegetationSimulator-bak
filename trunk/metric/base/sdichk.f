      SUBROUTINE SDICHK
      IMPLICIT NONE
C----------
C METRIC-BASE $Id$
C----------
C  THIS SUBROUTINE CHECKS TO SEE IF THE INITIAL STAND SDI
C  IS ABOVE THE SPECIFIED MAXIMUM SDI.  IF IT IS, THE MAXIMUM SDI
C  IS RESET AND A MESSAGE IS PRINTED.
C  THIS ROUTINE IS CALLED FROM **SITSET** IN VARIANTS THAT USE   
C  THE SDI-BASED MORTALITY MODEL.                                
C----------
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
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'METRIC.F77'
COMMONS
C----------
C  DEFINITIONS:
C----------
C  DQ0    = START OF CYCLE MEAN SQUARE DIAMETER
C  SDIMAX = SDI MAXIMUM WEIGHTED BY BASAL AREA
C  TEMTPA = TREES/ACRE AT START OF CYCLE
C  TMD0   = MAXIMUM NUMBER OF TREES FOR A GIVEN DQ0
C----------
      INTEGER I
      REAL DQ0,CONST,UPMAX,TEMD0,TEMTPA,TEMMAX,TEM,TEM2,UPLIM,TMD0
      LOGICAL DEBUG
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SDICHK',6,ICYC)
      IF(DEBUG)WRITE(JOSTND,9000)
 9000 FORMAT(' ENTERING SUBROUTINE SDICHK')
      IF(DEBUG)WRITE(JOSTND,9010)ICYC,RMSQD
 9010 FORMAT(1H0,'IN SDICHK 9010 ICYC,RMSQD= ',
     & I5,5X,F6.2)
C----------
C CONVERT PMSDIL & PMSDIU TO PROPORTION
C----------
      PMSDIL = PMSDIL/100.
      PMSDIU = PMSDIU/100.
C
      DQ0=RMSQD
      IF(LZEIDE)DQ0=DR016
C----------
C  IF QMD IS TOO LOW, NUMERICAL PROBLEMS OCCUR. RESET IF NECESSARY.
C----------
       IF(DQ0 .LT. 0.3) THEN
         DQ0  = 0.3
         IF(DEBUG) WRITE(JOSTND,*)' RESETTING DQ0= ',DQ0
       ENDIF
       IF(DEBUG) WRITE(JOSTND,*)' DQ0,RMSQD,DR016= ',
     & DQ0,RMSQD,DR016
C----------
C SDIMAX IS USED HERE TO CARRY WEIGHTED SDI MAXIMUM
C----------
      CALL SDICAL(0,SDIMAX)
      CONST = SDIMAX / 0.02483133
      TMD0 = CONST * (DQ0 ** (-1.605))
      IF(TMD0 .GT. 35000.0) TMD0 = 35000.0
C----------
C IF TOTAL NUMBER OF TREES IS GREATER THAN THE PMSDIU+5% LEVEL,
C RAISE MAXIMUM TO MATCH TOTAL NUMBER OF TREES, PRINT MESSAGE.
C----------
      UPMAX = PMSDIU + .05
      IF(UPMAX .GT. 1.) UPMAX=1.
      TEMD0 = RMSQD
      IF(LZEIDE)TEMD0=DR016
      TEMTPA = TPROB
      TEMMAX = CONST*(TEMD0**(-1.605))
      IF(TEMTPA .LE. UPMAX*TEMMAX) GO TO 200
      TEM = CONST * .02483133
      TEM = UPMAX * TEM
      IF(DEBUG)WRITE(JOSTND,9030)CONST,TEM,TEMTPA,TEMD0
 9030 FORMAT(1H ,'IN SDICHK 9030',4F10.2)
      CONST = EXP(ALOG(TEMTPA + 1.) + 1.605*ALOG(TEMD0)) / PMSDIU
      TEM2 = CONST * .02483133
      DO 194 I=1,MAXSP
        SDIDEF(I) = TEM2
  194 CONTINUE
      UPLIM = TMD0*PMSDIU
      WRITE(JOSTND,195)
     &  TEMTPA /ACRtoHA,
     &  UPLIM  /ACRtoHA,
     &  SDIMAX /ACRtoHA,
     &  PMSDIU*100.,
     &  TEM2   /ACRtoHA
  195 FORMAT(/,2(' ***************'/),' WARNING: INITIAL STAND ',
     &'STOCKING OF ',
     &F8.1,' TREES/HA IS MORE THAN 5% ABOVE THE UPPER LIMIT OF ',
     &F8.1,' TREES/HA.'/,9X,
     &'UPPER LIMIT IS BASED ON A SDI MAXIMUM OF ',F10.1,' AND AN UPPER',
     &' BOUND OF ',F5.1,' PERCENT OF MAXIMUM.',/,
     &9X,'MAXIMUM SDI BEING RESET TO',F10.1,' FOR FURTHER PROCESSING.',
     &/2(' ***************'/),/)
      LFIXSD=.TRUE.
  200 CONTINUE
      RETURN
      END
