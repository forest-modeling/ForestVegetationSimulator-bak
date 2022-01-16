      SUBROUTINE REGENT(LESTB,ITRNIN)
      IMPLICIT NONE
C----------
C OC $Id$
C----------
C  THIS SUBROUTINE COMPUTES 5-YR HEIGHT AND DIAMETER INCREMENTS FOR
C  SMALL TREES.  
C
C  FOR SPECIES/TREES USING FVS GROWTH EQUATIONS:
C    THE HEIGHT INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS THAN 4 
C    INCHES DBH, AND THE DBH INCREMENT MODEL IS APPLIED TO TREES THAT ARE
C    LESS THAN 3 INCHES DBH.  FOR TREES THAT ARE GREATER THAN 2 INCHES
C    AND LESS THAN 4 INCHES DBH, HEIGHT INCREMENT PREDICTIONS
C    ARE AVERAGED WITH THE PREDICTIONS FROM THE LARGE TREE MODEL.
C    DIAMETER IS ASSIGNED FROM A HEIGHT-DIAMETER FUNCTION FROM HEIGHT AT
C    THE BEGINNING AND END OF THE PROJECTION CYCLE. DIAMETER INCREMENT IS
C    COMPUTED BY SUBTRACTION AND ADJUSTED FOR BARK RATIO. DIAMETER 
C    INCREMENT PREDICTIONS ARE AVERAGED WITH THE PREDICTIONS FROM THE
C    LARGE TREE MODEL OVER THE DIAMETER RANGE 1.5-3.0 INCHES.
C
C  FOR SPECIES/TREES USING ORGANON GROWTH EQUATIONS:
C    USE THE LARGE TREE DIAMETER AND HEIGHT GROWTH ESTIMATES
C
C  THIS ROUTINE IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **GRINCR** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'ESTCOR.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'ORGANON.F77'
C
C
COMMONS
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C    RHCON -- CONSTANT FOR THE HEIGHT INCREMENT MODEL.  ZERO FOR ALL
C             SPECIES IN THIS VARIANT
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C     DIAM -- BUD WIDTH (I.E. MINIMUM DIAMETER)
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      REAL DIAM(MAXSP),CORTEM(MAXSP),XMAX(MAXSP),XMIN(MAXSP)
      INTEGER NUMCAL(MAXSP)
      INTEGER N,IREFI,KOUT,ISPEC,KK,I3,I
      INTEGER ITRNIN,ISPC,I1,I2,IPCCF,K,L
      REAL REGYR,FNT,BACHLO,BRATIO,DGSM,DDS,HTNEW,SCALE3,CORNEW
      REAL SNP,SNX,SNY,EDH,P,TERM
      REAL SCALE,SCALE2,XRHGRO,XRDGRO,CON,XMX,XMN,SI,D,CR,RAN,BAL,H
      REAL RELHT,BARK,HTGRR,HTGR,ZZRAN,XWT,HK,BX,AX,DK,DKK,XDWT,LTHG
      REAL DGMIN(MAXSP),DGLT
      CHARACTER SPEC*2
C----------
C  DATA STATEMENTS.
C----------
      DATA XMAX/ 22*4.0, 10.0, 26*4.0, 10.0 /,XMIN/ MAXSP*2.0 /
      DATA DGMIN/22*3.0, 7.0, 26*3.0, 7.0/
      DATA REGYR/5.0/
      DATA DIAM/
     & 9*0.2, 2*0.5,   0.4, 4*0.5,   0.3, 3*0.5, 5*0.3,
     & 9*0.2,   0.3, 2*0.1,   0.2,   0.1,   0.3,   0.4,
     & 2*0.2, 3*0.1, 3*0.2, 0.3 /
C-----------
C  CHECK FOR DEBUG.
C-----------
      LSKIPH=.FALSE.
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,9980)ICYC
 9980 FORMAT('ENTERING SUBROUTINE REGENT  CYCLE =',I5)
C----------
C  IF THIS IS THE FIRST CALL TO REGENT, BRANCH TO STATEMENT 40 FOR
C  MODEL CALIBRATION.
C----------
      IF(LSTART) GOTO 40
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      IF (ITRN.LE.0) GO TO 91
C----------
C  FOR SPECIES/TREES USING FVS GROWTH ESTIMATES:
C    HEIGHT INCREMENT IS DERIVED FROM A HEIGHT-AGE CURVE AND IS
C    BASED ON A 5-YEAR GROWTH PERIOD.
C    SCALE IS USED TO CONVERT THE 5-YR HTG ESTIMATE TO A FINT-YR BASIS.
C
C    DIAMETER INCREMENT IS PREDICTED FROM CHANGE IN HEIGHT. SO THE
C    DIAMETER INCREMENT IS INITIALLY ON A FINT-YR BASIS.
C    SCALE2 IS USED TO COVERT THE FINT-YR DG ESTIMATE TO A 5-YR BASIS.
C    DIAMETER INCREMENT IS CONVERTED BACK TO A FINT-YEAR BASIS IN 
C    **UPDATE**.
C
C  FOR SPECIES/TREES USING ORGANON GROWTH ESTIMATES:
C    HEIGHT INCREMENT IS BASED ON A 5-YEAR GROWTH PERIOD AND HAS ALREADY
C    BEEN SCALED TO A FINT-YR BASIS IN **HTGF**.
C
C    DIAMETER INCREMENT IS BASED ON A 5-YEAR GROWTH PERIOD, SO IT DOES
C    NOT NEED TO BE SCALED. DIAMETER INCREMENT WILL BE CONVERTED TO A
C    FINT-YR BASIS IN **UPDATE**.
C----------
      FNT=FINT
      IF(LESTB) THEN
        IF(FINT.LE.5.0) THEN
          LSKIPH=.TRUE.
        ELSE
          FNT=FNT-5.0
        ENDIF
      ENDIF
      SCALE=FNT/REGYR
      SCALE2=YR/FNT
      IF(DEBUG)WRITE(JOSTND,*)'FNT,REGYR,YR,SCALE,SCALE2= ',
     &FNT,REGYR,YR,SCALE,SCALE2
C----------
C  ENTER GROWTH PREDICTION LOOP.  PROCESS EACH SPECIES AS A GROUP;
C  LOAD CONSTANTS FOR NEXT SPECIES.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
      XRHGRO=XRHMLT(ISPC)
      XRDGRO=XRDMLT(ISPC)
      CON=RHCON(ISPC) * EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      SI=SITEAR(ISPC)
C----------
C  PROCESS NEXT TREE RECORD.
C----------
      DO 25 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      IF(D .GE. XMX) GO TO 25
C----------
C  BYPASS INCREMENT CALCULATIONS IF CALLED FROM ESTAB AND THIS IS NOT A
C  NEWLY CREATED TREE.
C----------
      IF(LESTB) THEN
        IF(I.LT.ITRNIN) GO TO 25
C----------
C  SET ORGANON TREE FLAG TO NON-VALID TREE BECAUSE THIS IS A NEW SEEDLING
C----------
        IORG(I) = 0
C----------
C  CALCULATE CROWN RATIO FOR NEWLY REGENERATED TREES.
C----------
        IPCCF=ITRE(I)
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
    1   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 1
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=INT((CR*100.0)+0.5)
      ENDIF
      K=I
      L=0
      CR=REAL(ICR(I))/10.
      BAL=((100.0-PCT(I))/100.0)*BA
      H=HT(I)
C
      IF(AVH .LE. 0.0) THEN
        RELHT= 1.0
      ELSE
        RELHT=H/AVH
      ENDIF
      IF (RELHT .GT. 1.05) RELHT= 1.05
C
      BARK=BRATIO(ISPC,D,H)
      IF(LSKIPH) THEN
        HTG(K)=0.0
        GO TO 4
      ENDIF
C
      CALL SMHTGF(ISPC,D,H,CR,BA,BAL,SI,HTGRR,RELHT,DEBUG,JOSTND)
C
      IF(DEBUG)WRITE(JOSTND,*)'AFTER CALL SMHTGF D,CR,BA,BAL,SI,',
     &'HTGRR =',D,CR,BA,BAL,SI,HTGRR
C----------
C     RETURN HERE TO PROCESS NEXT TRIPLE.
C----------
    2 CONTINUE
C
      HTGR= HTGRR
      HTGR=HTGRR * CON
      IF(DEBUG) WRITE(JOSTND,9983) HTGR,HTGRR,CON
 9983 FORMAT('IN REGENT HTGR,HTGRR,CON = ',3F10.4)
    3 CONTINUE
      ZZRAN = 0.0
      IF(DGSD.GE.1.0) ZZRAN=BACHLO(0.0,1.0,RANN)
      IF((ZZRAN .GT. 0.5) .OR. (ZZRAN .LT. -2.0)) GO TO 3
      IF(DEBUG)WRITE(JOSTND,9984) HTGR,ZZRAN,XRHGRO,SCALE
 9984 FORMAT('IN REGENT 9984 FORMAT',4(F10.4,2X))
      HTGR = (HTGR +ZZRAN*0.1)*XRHGRO * SCALE
C-------------
C     COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C     ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN, THE LARGE TREE
C     PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=(D-XMN)/(XMX-XMN)
      IF(D.LE.XMN .OR. LESTB) XWT = 0.0
C----------
C  IF THIS IS A VALID ORGANON TREE, HTG WAS SET IN HTGF
C----------
      IF(LORGANON .AND. (IORG(K) .EQ. 1)) XWT = 1.0
C----------
C     COMPUTE WEIGHTED HEIGHT INCREMENT FOR NEXT TRIPLE.
C----------
      IF(DEBUG)WRITE(JOSTND,9985)XWT,HTGR,HTG(K),I,K
 9985 FORMAT('IN REGENT 9985 FORMAT',3(F10.4,2X),2I7)
      IF(ISPC .EQ. 50 .OR. ISPC .EQ. 23) THEN
        LTHG = HTG(K)
        IF(LESTB) THEN
          HTGR = HTGR
        ELSE
          HTGR = (HTGR + LTHG)/2.0
        ENDIF
        HTG(K)=HTGR*(1.0-XWT) + XWT*LTHG
        IF(DEBUG)WRITE(JOSTND,*)'IN REGENT - RW/GS DEBUG: ',' LESTB=',
     &    LESTB,' D=',D,' XWT=',XWT,' HTGR=',HTGR,' LTHG=',LTHG,
     &    ' HTG FINAL=', HTG(K)
      ELSE
        HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
      ENDIF
      IF(HTG(K) .LT. .1) HTG(K) = .1
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
    4 CONTINUE
C----------
C     ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C     THAN 3 INCHES (COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C     PROJECTION PERIOD LENGTH).
C----------
      IF(D.GE.DGMIN(ISPC)) GO TO 23
      HK=H + HTG(K)
      IF(HK .LE. 4.5) THEN
        DG(K)=0.0
        DBH(K)=D+0.001*HK
      ELSE
        BX=HT2(ISPC)
        IF(IABFLG(ISPC).EQ.1) THEN
          AX=HT1(ISPC)
        ELSE
          AX=AA(ISPC)
        ENDIF
        DK=(BX/(ALOG(HK-4.5)-AX))-1.0
        IF(H .LE. 4.5) THEN
          DKK=D
        ELSE
          DKK=(BX/(ALOG(H-4.5)-AX))-1.0
        ENDIF
        IF(DEBUG)WRITE(JOSTND,9986) AX,BX,ISPC,HK,BARK,
     &                                XRDGRO,DK,DKK
 9986     FORMAT('IN REGENT 9986 FORMAT AX,BX,ISPC,HK',
     &    ' BARK,XRDGRO,DK,DKK= '/T12, F10.3,2X,F10.3,2X,I5,2X,5F10.3)
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
        IF(.NOT.LHTDRG(ISPC) .OR. 
     &     (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
          CALL HTDBH (IFOR,ISPC,DK,HK,1)
          IF(H .LE. 4.5) THEN
            DKK=D
          ELSE
            CALL HTDBH (IFOR,ISPC,DKK,H,1)
          ENDIF
          IF(DEBUG)WRITE(JOSTND,*)'INV EQN DUBBING IFOR,ISPC,H,HK,DK,'
     &    ,'DKK= ',IFOR,ISPC,H,HK,DK,DKK
          IF(DEBUG)WRITE(JOSTND,*)'ISPC,LHTDRG,IABFLG= ',
     &    ISPC,LHTDRG(ISPC),IABFLG(ISPC)
        ENDIF
C----------
C         IF CALLED FROM **ESTAB** ASSIGN DIAMETER
C----------
        IF(LESTB) THEN
          DBH(K)=DK
          IF(DBH(K).LT.DIAM(ISPC)) DBH(K)=DIAM(ISPC)
          DBH(K)=DBH(K)+0.001*HK
          DG(K)=DBH(K)
        ELSE
C----------
C         COMPUTE DIAMETER INCREMENT BY SUBTRACTION, APPLY USER
C         SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF COMPUTED VALUE
C         IS WITHIN BOUNDS.  IN ICASCA, THE INCREMENT FOR TREES BETWEEN
C         1.5 AND 3 INCHES DBH IS A WEIGHTED AVERAGE OF PREDICTIONS FROM
C         THE LARGE AND SMALL TREE MODELS.
C         SCALE ADJUSTMENT IS ON GROWTH IN DDS TERMS RATHER THAN INCHES
C         OF DG TO MAINTAIN CONSISTENCY WITH GRADD.
C         
C         NOTE: LARGE TREE DG IS ON A 10-YR BASIS; SMALL TREE DG IS ON A 
C         FINT-YR BASIS. CONVERT SMALL TREE DG TO A 10-YR BASIS BEFORE
C         WEIGHTING. DG GETS CONVERTED BACK TO A FINT-YR BASIS IN **GRADD**.
C----------
          IF(ISPC.EQ.23 .OR. ISPC.EQ.50) THEN
            XDWT=(D-XMN)/(DGMIN(ISPC)-XMN)
            IF(D.LE.XMN) XDWT=0.0
          ELSE
            XDWT=(D-1.5)/1.5
            IF(D.LE.1.5) XDWT=0.0
            IF(D.GE.3.0) XDWT=1.0
          ENDIF
C----------
C  IF THIS IS A VALID ORGANON TREE, DG WAS SET IN DGDRIV AND IS ALREADY
C  ON A 5-YR BASIS
C----------
          IF(LORGANON .AND. (IORG(K) .EQ. 1)) XDWT = 1.0
C
          DGSM=(DK-DKK)*BARK*XRDGRO
          IF(DGSM .LT. 0.0) DGSM=0.0
          DDS=DGSM*(2.0*BARK*D+DGSM)*SCALE2
          DGSM=SQRT((D*BARK)**2.0+DDS)-BARK*D
          DGLT=DG(K)
          IF(DGSM.LT.0.0) DGSM=0.0
          DG(K)=DGSM*(1.0-XDWT)+DG(K)*XDWT
          IF(DEBUG)WRITE(JOSTND,*)'IN REGENT',' ISPC=',ISPC,' D=',D,
     &    ' XDWT=',XDWT,' DKK=', DKK,' DK=',DK,' BARK=', BARK,
     &    ' DGSM=',DGSM,' DGLT=', DGLT,' DGSM FINAL=',DG(K)
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
   23 CONTINUE
C----------
C  RETURN TO PROCESS NEXT TRIPLE IF TRIPLING.  OTHERWISE,
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TREE.
C----------
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 22
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 2
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   22 CONTINUE
      IF(DEBUG)THEN
      HTNEW=HT(I)+HTG(I)
      WRITE(JOSTND,9987) I,ISPC,HT(I),HTG(I),HTNEW,DBH(I),DG(I)
 9987 FORMAT('IN REGENT, I=',I4,',  ISPC=',I3,'  CUR HT=',F7.2,
     &       ',  HT INC=',F7.4,',  NEW HT=',F7.2,',  CUR DBH=',F10.5,
     &       ',  DBH INC=',F7.4)
      ENDIF
   25 CONTINUE
   30 CONTINUE
      GO TO 91
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) GO TO 91
      IF(IFINTH .EQ. 0)  GOTO 95
      SCALE3 = REGYR / FINTH
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      DO 100 ISPC=1,MAXSP
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 100
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      SI=SITEAR(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS LESS THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      H=HT(I)
      BAL=((100.0-PCT(I))/100.0)*BA
      CR=REAL(ICR(I))/10.0
      RELHT=H/AVH
C----------
C  DIA GT 3 INCHES INCLUDED IN OVERALL MEAN
C----------
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
      CALL SMHTGF(ISPC,D,H,CR,BA,BAL,SI,EDH,RELHT,DEBUG,JOSTND)
      IF(DEBUG)WRITE(JOSTND,*)'AFTER CALL SMHTGF D,CR,BA,BAL,SI,',
     &'EDH =',D,CR,BA,BAL,SI,EDH
      EDH=EDH*RHCON(ISPC)
      IF(DEBUG)WRITE(JOSTND,9990) I,ISPC,EDH,RHCON(ISPC)
 9990 FORMAT('IN REGENT I,ISPC,EDH,RHCON = ',2I5,2F10.4)
      P=PROB(I)
      IF(HTG(I).LT.0.001) GO TO 60
      TERM=HTG(I) * SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)WRITE(JOSTND,9991) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),RELDM1,RHCON(ISPC),EDH,TERM
 9991 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9992) ISPC,SNP,SNX,SNY
 9992 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';  SNX=',F10.2,';  SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE POPULATION AND FOR THE SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  CALCULATE RATIO ESTIMATOR.
C----------
      CORNEW = SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE 
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES 
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
  100 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9993) (NUMCAL(I),I=1,NUMSP)
 9993 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T49,11(I4,2X)/)))
   95 CONTINUE
      WRITE(JOSTND,9994) (CORTEM(I),I=1,NUMSP)
 9994 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TO DATABASE.
C----------
      CALL DBSCALIB(2,CORTEM,NUMCAL,CORTEM) ! LAST ARG IGNORED
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
   91 IF(DEBUG)WRITE(JOSTND,9995)ICYC
 9995 FORMAT('LEAVING SUBROUTINE REGENT  CYCLE =',I5)
C----------
C IF DEBUGGING, WRITE RESULTS TO THE OUTPUT FILE
C----------
      IF(DEBUG) THEN
        DO I=1,ITRN
        WRITE(JOSTND,*)' LEAVING REGENT I,ISP,DBH,DG,HT,HTG,IORG= ',
     &  I,ISP(I),DBH(I),DG(I),HT(I),HTG(I),IORG(I) 
        ENDDO
      ENDIF
C
      RETURN
C
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C---------
      DO 90 ISPC=1,MAXSP
      RHCON(ISPC) = 1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)
     &RHCON(ISPC)=RCOR2(ISPC)
   90 CONTINUE
      RETURN
      END
