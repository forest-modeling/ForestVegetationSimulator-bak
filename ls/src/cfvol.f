      SUBROUTINE CFVOL(ISPC,D,HZ,D2H,VN,VM,VMAX,TKILL,LCONE,BARK,ITHT,
     1                 CTKFLG)
      IMPLICIT NONE
C----------
C LS $Id: cfvol.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C THIS ROUTINE CALCULATES CUBIC FOOT VOLUME USING A 
C USER DEFINED EQUATION.
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
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
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
C  DIMENSION STATEMENT FOR INTERNAL ARRAYS.
C----------
      LOGICAL TKILL,LCONE,CTKFLG,BTKFLG,DEBUG,DONE
      INTEGER ITHT,ISPC,IHT1,IHT2
      REAL BARK,VMAX,VM,VN,D2H,HZ,D,H,TSIZE,TOPDOB,BFTDOB,SINDX,HM1
      REAL HM2,TOTCU,SAWCU
      REAL DANUW
      LOGICAL LDANUW
C----------
C  DEFINE VARIABLES
C    DONE = LOGICAL OPERATOR TO SIGNIFY ALL VOLUMES HAVE BEEN COMPUTED
C     HM1 = MERCH HEIGHT TO SAWLOG TOP
C     HM2 = MERCH HEIGHT TO PULPWOOD TOP
C    IHT1 = # OF SAWLOG 8' BOLTS
C    IHT2 = # OF PULPWOOD 8' BOLTS
C   TOTCU = CUBIC FOOT VOLUME TO THE PULPWOOD TOP
C   SAWCU = CUBIC FOOT VOLUME TO THE SAWLOG TOP                
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = REAL(ITHT)
      LDANUW = LCONE
      LDANUW = TKILL
C
C----------
C  CHECK FOR DEBUG
C----------
      CALL DBCHK(DEBUG,'CFVOL',5,ICYC)
      IF(DEBUG)WRITE(JOSTND,*)'IN CFVOL, ICYC= ',ICYC
C----------
C FIRST COMPUTE VMAX BASED ON TOTAL HEIGHT
C----------
      H=HZ
      TSIZE=D
      IF(ICTRAN(ISPC).GT.0) TSIZE=D2H
      IF(TSIZE.LT.CTRAN(ISPC)) THEN
        VMAX = CFVEQS(1,ISPC)
     &    +CFVEQS(2,ISPC)*D
     &    +CFVEQS(3,ISPC)*D*H
     &    +CFVEQS(4,ISPC)*D*D*H
     &    +CFVEQS(5,ISPC)*D**CFVEQS(6,ISPC)*H**CFVEQS(7,ISPC)
        ELSE
          VMAX = CFVEQL(1,ISPC)
     &    +CFVEQL(2,ISPC)*D
     &    +CFVEQL(3,ISPC)*D*H
     &    +CFVEQL(4,ISPC)*D*D*H
     &    +CFVEQL(5,ISPC)*D**CFVEQL(6,ISPC)*H**CFVEQL(7,ISPC)
        ENDIF
        IF(VMAX .LT. 0.) VMAX = 0.
C----------
C  METHC = 1: VOLUME COMPUTED USING REGRESSION MODEL WITH EITHER DEFAULT
C  (SEE **CUBRDS**) OR USER SUPPLIED PARAMETERS (SEE CFVOLEQ KEYWORD).
C  
C  **NBOLT** IS CALLED TO COMPUTE NUMBER OF 8' BOLTS TO SPECIFIED PULPWOOD
C  AND SAWLOG TOPS.  THE NUMBER OF BOLTS IS THEN MULTIPLIED BY 8.333 TO
C  GET THE MERCHANTABLE BOLE HEIGHT FOR THIS EQUATION.
C----------
      DONE=.FALSE.
      TOPDOB=TOPD(ISPC)/BARK
      BFTDOB=BFTOPD(ISPC)/BARK 
      SINDX=SITEAR(ISPC)
C
      IF(DEBUG)WRITE(JOSTND,*)
     &' TOPDOB= ',TOPDOB,' BFTDOB=',BFTDOB,' BRATIO=',BARK
C----------
C  CALL NBOLT TO COMPUTE THE TOTAL NUMBER OF 8' BOLTS TO A SPECIFIED
C  PULPWOOD AND SAWTIMBER TOP DIAMETER.
C----------
      CALL NBOLT(ISPC,H,D,DBHMIN,BFMIND,SINDX,TOPDOB,BFTDOB,
     &           JOSTND,DEBUG,IHT1,IHT2)
      HM1=FLOAT(IHT1)*8.333333
      HM2=FLOAT(IHT2)*8.333333
C----------
C  COMPUTE TOTAL MERCH CUBIC AND SAWLOG CUBIC VOLUMES
C
C  CASES 1-3 ASSUME THE MINIMUM SAWTIMBER DBH IS GREATER THAN THE
C  MINIMUM PULPWOOD DBH
C----------
      IF(DEBUG)WRITE(JOSTND,*)' D,DBHMIN,BFMIND,IHT1,IHT2,HM1,HM2= ',
     &D,DBHMIN(ISPC),BFMIND(ISPC),IHT1,IHT2,HM1,HM2
C
      IF(D.LT.DBHMIN(ISPC) .OR. IHT2.LE.0)THEN
C
C  CASE 1: TREE DOES NOT MEET PULPWOOD SPECS
C
        TOTCU=0.
C----------
C  TREE DBH IS GREATER THAN PULPWOOD MIN DBH
C  FIRST CASE ASSUMES DEFAULT SAWTIMBER DBH IS GREATER THAN DEFAULT PULPWOOD
C----------
      ELSEIF(D.LT.BFMIND(ISPC).OR. IHT1.LE.0)THEN
C
C  CASE 2: TREE ONLY HAS PULPWOOD
C
        H=HM2
        TSIZE=D
        IF(ICTRAN(ISPC).GT.0) TSIZE=D2H
        IF(TSIZE.LT.CTRAN(ISPC)) THEN
          TOTCU=CFVEQS(1,ISPC)
     &    +CFVEQS(2,ISPC)*D
     &    +CFVEQS(3,ISPC)*D*H
     &    +CFVEQS(4,ISPC)*D*D*H
     &    +CFVEQS(5,ISPC)*D**CFVEQS(6,ISPC)*H**CFVEQS(7,ISPC)
        ELSE
          TOTCU=CFVEQL(1,ISPC)
     &    +CFVEQL(2,ISPC)*D
     &    +CFVEQL(3,ISPC)*D*H
     &    +CFVEQL(4,ISPC)*D*D*H
     &    +CFVEQL(5,ISPC)*D**CFVEQL(6,ISPC)*H**CFVEQL(7,ISPC)
        ENDIF
        IF(TOTCU .LT. 0.) TOTCU = 0.
C
        SAWCU=0.0
        DONE=.TRUE.
      ELSE
C
C  CASE 3: TREE HAS PULPWOOD AND SAWTIMBER
C
        H=HM2
        TSIZE=D
        IF(ICTRAN(ISPC).GT.0) TSIZE=D2H
        IF(TSIZE.LT.CTRAN(ISPC)) THEN
          TOTCU=CFVEQS(1,ISPC)
     &    +CFVEQS(2,ISPC)*D
     &    +CFVEQS(3,ISPC)*D*H
     &    +CFVEQS(4,ISPC)*D*D*H
     &    +CFVEQS(5,ISPC)*D**CFVEQS(6,ISPC)*H**CFVEQS(7,ISPC)
        ELSE
          TOTCU=CFVEQL(1,ISPC)
     &    +CFVEQL(2,ISPC)*D
     &    +CFVEQL(3,ISPC)*D*H
     &    +CFVEQL(4,ISPC)*D*D*H
     &    +CFVEQL(5,ISPC)*D**CFVEQL(6,ISPC)*H**CFVEQL(7,ISPC)
        ENDIF
        IF(TOTCU .LT. 0.) TOTCU = 0.
C
        H=HM1
        TSIZE=D
        IF(ICTRAN(ISPC).GT.0) TSIZE=D2H
        IF(TSIZE.LT.CTRAN(ISPC)) THEN
          SAWCU=CFVEQS(1,ISPC)
     &    +CFVEQS(2,ISPC)*D
     &    +CFVEQS(3,ISPC)*D*H
     &    +CFVEQS(4,ISPC)*D*D*H
     &    +CFVEQS(5,ISPC)*D**CFVEQS(6,ISPC)*H**CFVEQS(7,ISPC)
        ELSE
          SAWCU=CFVEQL(1,ISPC)
     &    +CFVEQL(2,ISPC)*D
     &    +CFVEQL(3,ISPC)*D*H
     &    +CFVEQL(4,ISPC)*D*D*H
     &    +CFVEQL(5,ISPC)*D**CFVEQL(6,ISPC)*H**CFVEQL(7,ISPC)
        ENDIF
        IF(SAWCU .LT. 0.) SAWCU = 0.
        DONE=.TRUE.
      ENDIF
      IF (DONE)GOTO 50
C
C--STRANGE CASE IF SAWTIMBER MIN DBH IS LESS THAN PULPWOOD MIN DBH
C
      IF(D .LT. BFMIND(ISPC))THEN
C
C  CASE 4: STRANGE CASE SPECS MET AND TREE DOES NOT MEET SAWTIMBER SPECS
C
        SAWCU=0.0
      ELSE
C
C  CASE 5: STRANGE CASE SPECS MET AND TREE ONLY HAS SAWTIMBER
C
        H=HM1
        TSIZE=D
        IF(ICTRAN(ISPC).GT.0) TSIZE=D2H
        IF(TSIZE.LT.CTRAN(ISPC)) THEN
          SAWCU=CFVEQS(1,ISPC)
     &    +CFVEQS(2,ISPC)*D
     &    +CFVEQS(3,ISPC)*D*H
     &    +CFVEQS(4,ISPC)*D*D*H
     &    +CFVEQS(5,ISPC)*D**CFVEQS(6,ISPC)*H**CFVEQS(7,ISPC)
        ELSE
          SAWCU=CFVEQL(1,ISPC)
     &    +CFVEQL(2,ISPC)*D
     &    +CFVEQL(3,ISPC)*D*H
     &    +CFVEQL(4,ISPC)*D*D*H
     &    +CFVEQL(5,ISPC)*D**CFVEQL(6,ISPC)*H**CFVEQL(7,ISPC)
        ENDIF
        IF(SAWCU .LT. 0.) SAWCU = 0.
       ENDIF
C----------
C  SET RETURN VALUES.
C----------
   50 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' TOTCU=',TOTCU,' SAWCU=',SAWCU 
      VN=TOTCU
      VM=SAWCU
      CTKFLG = .TRUE.
      BTKFLG = .TRUE.
      IF(VN.LE.0.)THEN
        VN=0.
        CTKFLG = .FALSE.
      ENDIF
      IF(VM.LE.0.)THEN
        VM=0.
        BTKFLG = .FALSE.
      ENDIF
C
      IF(DEBUG)WRITE(JOSTND,*)' RETURNING VN,VMAX,VM,CTKFLG,BTKFLG= ',
     * VN,VMAX,VM,CTKFLG,BTKFLG
C
      RETURN
C           
      END
