      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C TT $Id: crown.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND COMPUTE
C  CROWN RATIO CHANGES FOR TREES THAT ARE GREATER THAN 3 INCHES DBH.
C  CROWN RATIO IS PREDICTED FROM HABITAT TYPE, BASAL AREA, CCF, DBH,
C  HEIGHT, AND BASAL AREA PERCENTILE.  WHEN PREDICTING CROWN RATIO
C  CHANGE, START-OF-CYCLE VALUES OF THE PREDICTOR VARIABLES ARE USED
C  TO PREDICT OLD CROWN RATIO AND END-OF-CYCLE VALUES ARE USED TO
C  PREDICT NEW CROWN RATIO; CHANGE IS COMPUTED BY SUBTRACTION.  THE
C  CHANGE IS ADDED TO THE ACTUAL CROWN RATIO.  THIS ROUTINE IS CALLED
C  FROM **CRATET** TO DUB MISSING VALUES, AND BY **TREGRO** TO COMPUTE
C  CHANGE DURING REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY
C  **RCON** TO LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED
C  ONLY BE RESOLVED ONCE.  A CALL TO **DUBSCR** IS ISSUED TO DUB
C  CROWN RATIO WHEN DBH IS LESS THAN 3 INCHES.  PROCESSING OF
C  CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY **REGENT**.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'ARRAYS.F77'
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
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER JJ,NTODO,I,NP,IACTK,IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP
      INTEGER J1,ISPC,I1,I2,I3,IITRE,ICRI
      INTEGER MYACTS(1),ICFLG(MAXSP),ISORT(MAXTRE)
      REAL CR,TPCCF,TPCT,CL,HD,HN,CRMAX,CRLN,PDIFPY,CHG
      REAL RNUMB,X,SCALE,H,D,C,A,B,ACRNEW,RELSDI,HF
      REAL CRNEW(MAXTRE),WEIBA(MAXSP),WEIBB0(MAXSP),PRM(5),
     & WEIBB1(MAXSP),WEIBC0(MAXSP),WEIBC1(MAXSP),C0(MAXSP),C1(MAXSP),
     & CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP)
C
      DATA MYACTS/81/
C----------
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
C
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)
C----------
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C----------
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ)=0.0
        ISORT(JJ)=0
   10   CONTINUE
      ENDIF
C----------
C  DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
C----------
      IF((ITRN.LE.0).AND.(IREC2.LT.MAXTP1))GO TO 74
C----------
C IF THERE ARE NO TREE RECORDS, THEN RETURN
C----------
      IF(ITRN.EQ.0)THEN
        RETURN
      ELSEIF(TPROB.LE.0.0)THEN
        DO I=1,ITRN
        ICR(I)=ABS(ICR(I))
        ENDDO
        RETURN
      ENDIF
C-----------
C  PROCESS CRNMULT KEYWORD.
C-----------
      CALL OPFIND(1,MYACTS,NTODO)
      IF(NTODO .EQ. 0)GO TO 25
      DO 24 I=1,NTODO
      CALL OPGET(I,5,IDATE,IACTK,NP,PRM)
      IDT=IDATE
      CALL OPDONE(I,IDT)
      ISPCC=INT(PRM(1))
C----------
C  ISPCC<0 CHANGE FOR ALL SPECIES IN THE SPECIES GROUP
C  ISPCC=0 CHANGE FOR ALL SPEICES
C  ISPCC>0 CHANGE THE INDICATED SPECIES
C----------
      IF(ISPCC .LT. 0)THEN
        IGRP = -ISPCC
        IULIM = ISPGRP(IGRP,1)+1
        DO 21 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        IF(PRM(2) .GE. 0.0)CRNMLT(IGSP)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(IGSP)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(IGSP)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(IGSP)=1
   21   CONTINUE
      ELSEIF(ISPCC .EQ. 0)THEN
        DO 22 ISPCC=1,MAXSP
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
   22   CONTINUE
      ELSE
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
      ENDIF
   24 CONTINUE
   25 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9024)ICYC,CRNMLT
 9024 FORMAT(/' IN CROWN 9024 ICYC,CRNMLT= ',
     & I5/((1X,11F6.2)/))
C----------
C LOAD ISORT ARRAY WITH DIAMETER DISTRIBUTION RANKS.  IF
C ISORT(K) = 10 THEN TREE NUMBER K IS THE 10TH TREE FROM
C THE BOTTOM IN THE DIAMETER RANKING  (1=SMALL, ITRN=LARGE)
C----------
      DO 11 JJ=1,ITRN
      J1 = ITRN - JJ + 1
      ISORT(IND(JJ)) = J1
   11 CONTINUE
      IF(DEBUG)THEN
        WRITE(JOSTND,7900)ITRN,(IND(JJ),JJ=1,ITRN)
 7900   FORMAT(' IN CROWN 7900 ITRN,IND =',I6,/,86(1H ,32I4,/))
        WRITE(JOSTND,7901)ITRN,(ISORT(JJ),JJ=1,ITRN)
 7901   FORMAT(' IN CROWN 7900 ITRN,ISORT =',I6,/,86(1H ,32I4,/))
      ENDIF
C----------
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
C----------
C ESTIMATE MEAN CROWN RATIO FROM SDI, AND ESTIMATE WEIBULL PARAMETERS
C----------
      SELECT CASE (ISPC)
C
      CASE(10) 
        IF(BAMAX .GT. 0.)THEN
          RELSDI = BA / BAMAX
        ELSEIF(SDIDEF(10) .GT. 0.)THEN
          RELSDI = SDIAC / SDIDEF(10)
        ELSE
          RELSDI = 1.0
        ENDIF
C
      CASE DEFAULT
        IF(SDIDEF(ISPC) .GT. 0.)THEN
          RELSDI = SDIAC / SDIDEF(ISPC)
        ELSE
          RELSDI = 1.0
        ENDIF
      END SELECT
C
      IF(RELSDI .GT. 1.5) RELSDI = 1.5
      IF(ISPC.EQ.17 .AND. RELSDI.GT.1.0)RELSDI=1.0
      ACRNEW = C0(ISPC) + C1(ISPC) * RELSDI*100.0
      A = WEIBA(ISPC)
      B = WEIBB0(ISPC) + WEIBB1(ISPC) * ACRNEW
      C = WEIBC0(ISPC) + WEIBC1(ISPC)*ACRNEW
      IF(ISPC .EQ. 10)THEN
        IF(B .LT. 3.0) B=3.0
      ELSE
        IF(B .LT. 1.0) B=1.0
      ENDIF
      IF(C .LT. 2.0) C=2.0
      IF(DEBUG) WRITE(JOSTND,9001) ISPC,SDIAC,ORMSQD,RELSDI,
     & ACRNEW,A,B,C,SDIDEF(ISPC)
 9001 FORMAT(/' IN CROWN 9001 WRITE ISPC,SDIAC,ORMSQD,RELSDI,ACRNEW,A,B
     &C,SDIDEF = ',/,1X,I5,F8.2,F8.4,F8.2,F8.2,4F10.4)
C----------
C  ENTER THE TREE LOOP
C----------
      DO 60 I3=I1,I2
      I = IND1(I3)
      IITRE=ITRE(I)
C----------
C  IF THIS IS THE INITIAL ENTRY TO 'CROWN' AND THE TREE IN QUESTION
C  HAS A CROWN RATIO ASCRIBED TO IT, THE WHOLE PROCESS IS BYPASSED.
C----------
      IF(LSTART .AND. ICR(I).GT.0)GOTO 60
C----------
C  IF ICR(I) IS NEGATIVE, CROWN RATIO CHANGE WAS COMPUTED IN A
C  PEST DYNAMICS EXTENSION.  SWITCH THE SIGN ON ICR(I) AND BYPASS
C  CHANGE CALCULATIONS.
C----------
      IF (LSTART) GOTO 40
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (/' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)
C----------
C  BRANCH TO STATEMENT 58 TO HANDLE TREES WITH DBH LESS THAN 1 IN.
C----------
      IF(D.LT.1.0 .AND. LSTART) GO TO 58
C----------
C  PINYON, JUNIPER, AND COTTONWOOD FROM CR VARIANT
C----------
      SELECT CASE(ISPC)
C
      CASE(4,11,12,15,18)
        HF = H + HTG(I)
        IF(ISPC.EQ.15 .OR. ISPC.EQ.18)THEN
          CL = 5.17281 + 0.32552 * HF - 0.01675 * BA
        ELSE
          CL = -0.59373 + 0.67703 * HF
        ENDIF
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        CRNEW(I) = (CL/HF)*100.
        IF(DEBUG)WRITE(JOSTND,*)' I,HF,BA,CL,CRNEW= ',
     &  I,HF,BA,CL,CRNEW(I)
C
      CASE DEFAULT
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
        SCALE = (1.0 - .00167 * (RELDEN-100.0))
        IF(SCALE .GT. 1.0) SCALE = 1.0
        IF(SCALE .LT. 0.30) SCALE = 0.30
        IF(DBH(I) .GT. 0.0) THEN
          X = (REAL(ISORT(I)) / REAL(ITRN)) * SCALE
        ELSE
          CALL RANN(RNUMB)
          X = RNUMB * SCALE
        ENDIF
        IF(X .LT. .05) X=.05
        IF(X .GT. .95) X=.95
        CRNEW(I) = A + B*((-1.0*ALOG(1-X))**(1.0/C))
C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
        IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I)
 9002   FORMAT(/' IN CROWN 9002 WRITE I,X,CRNEW,ICR = ',
     &  I5,2F10.5,I5)
        CRNEW(I) = CRNEW(I)*10.0
      END SELECT
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR
C----------
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - REAL(ICR(I))
      PDIFPY=CHG/REAL(ICR(I))/FINT
      IF(PDIFPY.GT.0.01)CHG=REAL(ICR(I))*(0.01)*FINT
      IF(PDIFPY.LT.-0.01)CHG=REAL(ICR(I))*(-0.01)*FINT
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &I5,F10.3,I5,3F10.3)
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
        CRNEW(I) = REAL(ICR(I)) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = REAL(ICR(I)) + CHG
      ENDIF
 9052 ICRI = INT(CRNEW(I)+0.5)
      IF(LSTART .OR. ICR(I).EQ.0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
          ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
        ENDIF
      ENDIF
C----------
C CALC CROWN LENGTH NOW
C----------
      IF(LSTART .OR. ICR(I).EQ.0)GO TO 55
      CRLN=HT(I)*REAL(ICR(I))/100.
C----------
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C----------
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),
     & CHG
 9004 FORMAT(/' CRMAX=',F10.2,' CRLN=',F10.2,
     &' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(ICRI.LT.10.AND.CRNMLT(ISPC).EQ.1.0)ICRI=INT(CRMAX+0.5)
      IF(REAL(ICRI).GT.CRMAX) ICRI=INT(CRMAX+0.5)
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,
     & ICRI,CL
 9030 FORMAT(/'  IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 1.0 IN ARE DUBBED HERE.  NO CHANGE
C  IS CALCULATED UNTIL THE TREE ATTAINS A DBH OF 3 INCHES.
C----------
   58 CONTINUE
      IF(ICR(I) .NE. 0) GO TO 60
C
      SELECT CASE(ISPC)
C
       CASE(15,18)
        HF = H + HTG(I)
        CL = 5.17281 + 0.32552 * HF - 0.01675 * BA
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        ICRI = INT((CL/HF)*100. + 0.5)
        IF(DEBUG)WRITE(JOSTND,*)' I,HF,BA,CL,CRNEW= ',
     &  I,HF,BA,CL,CRNEW(I)
C
      CASE DEFAULT
        TPCT = PCT(I)
        TPCCF = PCCF(IITRE)
        CALL DUBSCR(ISPC,D,H,CR,TPCT,TPCCF)
        IF(DEBUG) WRITE(JOSTND,*) 'RETURN FROM DUBSCR IN CROWN'
        ICRI=INT(CR*100.0+0.5)
      END SELECT
C
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &   ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10.AND.CRNMLT(ISPC).EQ.1.0) ICRI=10
      IF(ICRI .LT. 1)ICRI = 1
      ICR(I)= ICRI
   60 CONTINUE
      IF(LSTART .AND. ICFLG(ISPC).EQ.1)THEN
        CRNMLT(ISPC)=1.0
        ICFLG(ISPC)=0
      ENDIF
   70 CONTINUE
   74 CONTINUE
C----------
C  DUB MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 80
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      H=HT(I)
C
      SELECT CASE(ISPC)
C
       CASE(15,18)
        CL = 5.17281 + 0.32552 * H - 0.01675 * BA
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. H) CL = H
        ICRI = INT((CL/H)*100. + 0.5)
        IF(DEBUG)WRITE(JOSTND,*)' I,H,BA,CL,ICRI= ',
     &  I,HF,BA,CL,ICRI
C
      CASE DEFAULT
        TPCT=PCT(I)
        TPCCF=PCCF(IITRE)
        IITRE=ITRE(I)
        CALL DUBSCR (ISPC,D,H,CR,TPCT,TPCCF)
        ICRI=INT(CR*100.0 + 0.5)
      END SELECT
C
      IF(ITRUNC(I).EQ.0) GO TO 78
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
   78 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10) ICRI=10
      ICR(I)= ICRI
   79 CONTINUE
C
   80 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(/' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
C
C
      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS
C
C
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
C
C----------
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C----------
      DATA WEIBA/
     &      1.0,      1.0,      1.0,      0.0,      1.0,
     &      0.0,      0.0,      1.0,      1.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0, 
     &      0.0,      1.0,      0.0/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBB0/
     & -0.82631, -0.82631, -0.24217,      0.0, -0.90648,
     & -0.08414,  0.17162, -0.90648, -0.89553,  0.24916,
     &      0.0,      0.0, -0.23830, -0.08414,      0.0, 
     & -0.23830, -0.26595,      0.0/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBB1/
     &  1.06217,  1.06217,  0.96529,      0.0,  1.08122,
     &  1.14765,  1.07338,  1.08122,  1.07728,  1.04831,
     &      0.0,      0.0,  1.18016,  1.14765,      0.0, 
     &  1.18016,  0.98326,      0.0/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBC0/
     &  3.31429,  3.31429, -7.94832,      0.0,  3.48889,
     &  2.77500,  3.15000,  3.48889,  1.74621,     4.36,
     &      0.0,      0.0,     3.04,  2.77500,      0.0,  
     &     3.04, -7.00555,      0.0/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBC1/
     &      0.0,      0.0,  1.93832,      0.0,      0.0,
     &      0.0,      0.0,      0.0,  0.29052,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,  
     &      0.0,  1.60411,      0.0/
C----------
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C----------
      DATA C0/
     &  6.19911,  6.19911,  7.46296,      0.0,  6.81087,
     &  4.01678,  6.00567,  6.81087,  7.65751,  6.41166,
     &      0.0,      0.0,  4.62512,  4.01678,      0.0,  
     &  4.62512,  7.92810,      0.0/
C----------
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C----------
      DATA C1/
     &  -.02216, -0.02216, -0.02944,      0.0, -0.01037,
     & -0.01516, -0.03520, -0.01037, -0.03513, -0.02041,
     &      0.0,      0.0, -0.01604, -0.01516,      0.0, 
     & -0.01604, -0.06298,      0.0/
C
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
      RETURN
      END

