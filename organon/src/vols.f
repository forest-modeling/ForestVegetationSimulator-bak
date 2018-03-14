      SUBROUTINE VOLS
      IMPLICIT NONE
C----------
C ORGANON $Id: vols.f 2132 2018-03-06 22:32:41Z gedixon $
C----------
C
C  THIS SUBROUTINE CALCULATES TREE VOLUMES TO THREE MERCHANTABILITY
C  STANDARDS, AND COMPUTES DISTRIBUTION AND COMPOSITION VECTORS FOR
C  TOTAL CUBIC VOLUME AND ACCRETION.  TOTAL CUBIC FOOT VOLUME AND
C  MERCHANTABLE CUBIC FOOT VOLUME ARE COMPUTED IN **CFVOL**,
C  **NATCRS**, OR **OCFVOL**.  BOARD FOOT VOLUME IS COMPUTED IN
C  **BFVOL**, **NATCRS**, OR **OBFVOL**.  ADJUSTMENTS ARE MADE FOR
C  TOP DAMAGE AS APPROPRIATE.  ALL VOLUMES ARE THEN ADJUSTED FOR
C  DEFECT.
C
C  NATCRS, OCFVOL, AND OBFVOL ARE ENTRY POINTS IN SUBROUTINE
C  **VARVOL**, WHICH IS VARIANT SPECIFIC.
C----------
C
COMMONS
C
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
      INCLUDE 'GGCOM.F77'
C
C
      INCLUDE 'ORGANON.F77'
C
COMMONS
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C  SPCCC -- TOTAL CUBIC VOLUME BY SPECIES AND TREE CLASS.
C  SPCAC -- TOTAL CUBIC VOLUME ACCRETION BY SPECIES AND TREE CLASS.
C  SPCMC -- MERCH CUBIC VOLUME BY SPECIES AND TREE CLASS.
C  SPCBV -- MERCH BOARD VOLUME BY SPECIES AND TREE CLASS.
C
C  THESE VALUES DO NOT INCLUDE CYCLE 0 DEAD TREES.
C  IPASS=1 FOR LIVE TREES;  IPASS=2 FOR CYCLE 0 DEAD TREES.
C
C  BTKFLG - LOGICAL VARIABLES TO INDICATE WHETHER THE VOLUME ESTIMATE
C  CTKFLG   NEEDS TO BE ADJUSTED FOR TOPKILL OR NOT.
C           BTKFLG FOR BOARD FOOT VOLUME
C           CTKFLG FOR CUBIC FOOT VOLUME
C           .TRUE.  = ADJUST ESTIMATE FOR TOPKILL
C           .FALSE. = NO ADJUSTMENT NEEDED (ALREADY ACCOUNTED FOR).
C----------
      INTEGER DLIEQN,DLLMOD
      LOGICAL DEBUG
      REAL SPCCC(MAXSP,3),SPCAC(MAXSP,3),SPCBV(MAXSP,3),SPCMC(MAXSP,3)
      REAL DBHCLS(9),P,D,H,BARK,BRATIO
      REAL D2H,VM,VN,VMAX,BBFV,ALGSLP,VOLCOR,TCFTD
      INTEGER I,J,IPASS,ILOW,IHI,ISPC,IT,IM,ICDF,IBDF,ORGFIA
      LOGICAL TKILL,LCONE,BTKFLG,CTKFLG
C----------
C  ORGANON: DEFINE THE VARIABLES REQUIRED BY THE ORGANON ORGVOLS DLL
C           AND THE VOLCAL INTERFACE FUNCTION
C----------
      INTEGER*4   SPP                  ! SPECIES CODE FOR TREE RECORD
      REAL*4      FCR                  ! FLOATING POINT CROWN RATIO, UNITLESS.
      INTEGER*4   ORGVOL_VERROR(5)     ! VOLUME ERROR FLAGS
      INTEGER*4   ORGVOL_TERROR(4)     ! TREE ERROR FLAGS
      INTEGER*4   ORGVOL_VWARNING(5)   ! TREE WARNING FLAGS
      INTEGER*4   ORGVOL_TWARNING      ! TREE THREW A WARNING
      INTEGER*4   ORGVOL_IERROR        ! SOME GENERIC ERROR FLAG
      INTEGER*4   Z                    ! TEMP COUNTER FOR WARNING/ERRORS
C----------
C  INITIALIZE DBH CLASSES.
C----------
      DATA DBHCLS/0.0,5.0,10.0,15.0,20.0,25.0,30.0,35.0,40.0/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'VOLS',4,ICYC)
      DO J=1,2
      DO I=1,MAXTRE
      HT2TD(I,J)=0.
      ENDDO
      ENDDO
      IF (ITRN.LE.0) GOTO 2
      DO 1 I=1,MAXSP
      DO 1 J=1,3
      SPCCC(I,J)=0.0
      SPCAC(I,J)=0.0
      SPCMC(I,J)=0.0
      SPCBV(I,J)=0.0
    1 CONTINUE
    2 CONTINUE
      IPASS=1
      ILOW=1
      IHI=ITRN
C----------
C  CALL VOLKEY TO PROCESS KEYWORDS USED TO CHANGE VOLUME STANDARDS AND
C  EQUATIONS.
C----------
      CALL VOLKEY (DEBUG)
      DO J=1,MAXSP
      IF(BFMIND(J).LT.2.0) BFMIND(J)=2.0
      IF(BFTOPD(J).LT.2.0) BFTOPD(J)=2.0
      ENDDO
C
      IF (ITRN.LE.0) GOTO 205
C----------
C  ENTER TREE BY TREE LOOP TO CALCULATE VOLUMES AND COMPILE
C  SUMMARY ARRAYS.
C
C  I -- SUBSCRIPT TO TREE RECORD.
C  P -- NUMBER OF TREES PER ACRE REPRESENTED BY TREE I.
C  D -- DIAMETER OF TREE I.
C  H -- HEIGHT OF TREE I.
C  ISPC -- SPECIES OF TREE I.
C  WK5 -- ARRAY CONTAINING TOTAL ANNUAL CUBIC VOLUME ACCRETION
C    PER ACRE FOR EACH TREE.  THIS ARRAY IS NOT LOADED
C    IF LSTART IS TRUE.
C  VN -- USED TO TEMPORARILY STORE TOTAL CUBIC VOLUME FOR TREE I.
C----------
   10 CONTINUE
      DO 200 I=ILOW,IHI
      WK5(I)=0.0
      P=PROB(I)
      IF(P.LE.0.0) GO TO 200
      ISPC=ISP(I)
      D=DBH(I)
      H = HT(I)
C----------
C  INITIALIZE TOP KILL FLAG FOR NEXT TREE; IF TOPKILLED, ASSIGN H TO
C  NORMHT.
C----------
      TKILL = H.GE.4.5 .AND. ITRUNC(I).GT.0
      IF(TKILL) H=NORMHT(I)/100.0
C----------
C  IF NOT INITIAL SUMMARY, ADD DG TO DBH; ASSIGN D2H.
C----------
      BARK=BRATIO(ISPC,D,H)
      IF(.NOT.LSTART) D=D+DG(I)/BARK
      D2H=D*D*H
C----------
C  ORGANON: IF USING THE ORGVOLS DLL,  
C  COMPUTE THE VOLUMES USING THE VOLCAL SUBROUTINE
C  USE HT(I) INSTEAD OF NORMHT(I) FOR TRUNCATED TREES  GED 11/24/17
C----------
      IF( LORGVOLS ) THEN
        H = HT(I)
        VN=0.
        VM=0.
        VMAX=0.
        CFV(I)=0.
        WK1(I)=0.
        BFV(I)=0.
C----------
C SET FIA SPECIES CODE (ACTUAL FOR VALID ORGANON SPECIES, SURROGATE
C FOR NON-VALID SPECIES.
C----------
        CALL ORGSPC(ISP(I),ORGFIA)
        SPP = ORGFIA
C----------
C  GET THE SPECIES GROUP FOR THE TREE RECORD.
C  EXTRACT THE FIA SPECIES CODE FROM THE FVS DATA.
C----------
        IF(DEBUG) WRITE(JOSTND,*)' CALLING VOLCAL SPP= ',SPP
C----------
C  CONVERT THE CROWN RATIO FROM THE INTEGER (FVS) TO ORGANON'S REQUIRED FLOAT
C----------
        FCR   =   REAL(ICR(I)) / 100.0 ! MEASURED/PREDICTED CROWN RATIO
C----------
C  SET TEMPORARY VARIABLE FOR CUBIC FOOT TOP DIAMETER DEPENDING ON
C  WHETHER THE TREE IS A SOFTWOOD OR HARDWOOD.
C----------
      TCFTD = CFTD
      IF(SPP .GE. 300) TCFTD = CFTDHW
C----------
C  ORGANON: CALL THE ORGVOL.DLL VOLCALC SUBROUTINE
C----------
        IF(DEBUG)WRITE(JOSTND,*)' CALLING VOLCAL TCFTD,CFSH,LOGTD,LOGTA,
     &   LOGSH,LOGLL,LOGML= ',TCFTD,CFSH,LOGTD,LOGTA,LOGSH,LOGLL,LOGML
        IF(DEBUG)WRITE(JOSTND,*)' I,D,H,FCR= ',I,D,H,FCR
        CALL VOLCAL(      IMODTY,SPP,
     1                    TCFTD,CFSH,
     2                    LOGLL,LOGML,LOGTD,LOGSH,LOGTA,
     3                    D,H,FCR,
     4                    ORGVOL_VERROR,ORGVOL_TERROR,ORGVOL_VWARNING,
     5                    ORGVOL_TWARNING,ORGVOL_IERROR,
     6                    VM,BBFV)
C----------
C  ORGANON: PERFORM A BASIC ERROR CHECK.
C         INTEGER*4   VERROR(5)  ! VOLUME ERROR FLAG BUFFER
C         INTEGER*4   TERROR(4)  ! TREE ERROR FLAG BUFFER          
C         INTEGER*4   VWARNING(5) ! VOLUME WARNING FLAG BUFFER
C         INTEGER*4   TWARNING   ! TREE VARIABLE WARNING FLAG
C         INTEGER*4   IERROR     ! SOME GENERIC ERROR FLAG
C----------
C  ORGANON: PROCESS THE TWARNING FLAG
C----------
        IF( ORGVOL_TWARNING .EQ. 1 ) THEN
          IF (DEBUG) WRITE(JOSTND,12) ICYC, I, ORGVOL_TWARNING
   12     FORMAT(' CALLING ORGANON DLL::VOLCAL::BETA, CYCLE=',I2,
     &         ' IDX=',I2, 
     &         ' TWARNING=',I2 )
        END IF
        IF( ORGVOL_IERROR .EQ. 1 ) THEN
          IF (DEBUG) WRITE(JOSTND,13) ICYC, ORGVOL_IERROR
   13     FORMAT(' CALLING ORGANON.DLL::VOLCAL::BETA, CYCLE=',I2,
     &          ' ORGVOL_IERROR=',I2 )
C----------
C  ORGANON: PROCESS THE VOLUME WARNINGS AND ERRORS ARRAYS
C           VWARNING(5) AND VERROR(5) 
C----------
          DO Z = 1, 5
            IF( ORGVOL_VERROR(Z) .eq. 1 ) THEN
               IF (DEBUG) WRITE(JOSTND,14) ICYC, I, ORGVOL_VERROR(Z), 
     &                                       ORGVOL_VWARNING(Z)
   14          FORMAT(' CALLING ORGANON DLL::VOLCAL::BETA, CYCLE=',I2,
     &              ' IDX=',I2, 
     &              ' VERROR=',I2, 
     &              ' VWARNING=',I2 )
            END IF
          END DO
C----------
C  ORGANON: PROCESS THE TREE WARNING/ERRORS
C           TWARNING AND TERROR(4)
C----------
          DO Z = 1, 4
            IF( ORGVOL_TERROR(Z) .EQ. 1 ) THEN
               IF (DEBUG) WRITE(JOSTND,16) ICYC, I, ORGVOL_TERROR(Z)
   16          FORMAT(' CALLING ORGANON DLL::VOLCAL::BETA, CYCLE=',I2,
     &              ' IDX=',I2, 
     &              ' TERROR=',I2 )
            END IF
          END DO
        END IF
C-----------
C  ORGANON: ASSIGN THE FVS INTERNAL VARIABLES 
C           TO THE VALUES SET BY THE ORGANON DLL
C-----------
        VN = VM
        CFV(I)=VN
        WK1(I)=VM
        BFV(I)  = BBFV
        IF(DEBUG)WRITE(JOSTND,*)' IN VOLS AFTER VOLCAL I,VM,BBFV= ',
     &  I,VM,BBFV   
C----------
C  CALL ECON EXTENSION TO PROCESS VOLUME INFORMATION
C----------
        IF (WK1(I) .GT. 0.0) CALL ECVOL(IT,LOGDIA,LOGVOL,.TRUE.)
        IF (BFV(I) .GT. 0.0) CALL ECVOL(IT,LOGDIA,LOGVOL,.FALSE.)
        GO TO 200
      END IF
C-----------
C  ORGANON: END OF ORGANON
C-----------
C
C**************************************************
C          FVS CUBIC VOLUME SECTION               *
C**************************************************
C----------
C  INITIALIZE VOLUME ESTIMATES.
C----------
      VN=0.
      VM=0.
      VMAX=0.
      IF(DEBUG)WRITE(JOSTND,*)' CUBIC SECTION, I,ISPC,METHC= ',
     &I,ISPC,METHC(ISPC)
C----------
C  CALCULATE TOTAL CUBIC FOOT VOLUME. CORRECT FOR TOP KILL IF NEEDED.
C----------
      IT=I
      IF(METHC(ISPC).EQ.6) THEN
        CALL NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,
     1               CTKFLG,BTKFLG,IT)
      ELSEIF (METHC(ISPC).EQ.8) THEN
        CALL OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,LCONE,
     1               CTKFLG,IT)
      ELSE
        CALL CFVOL (ISPC,D,H,D2H,VN,VM,VMAX,TKILL,LCONE,BARK,ITRUNC(I),
     1              CTKFLG)
      ENDIF
      IF(CTKFLG .AND. TKILL .AND. VMAX .GT. 0.)
     1 CALL CFTOPK (ISPC,D,H,VN,VM,VMAX,LCONE,BARK,ITRUNC(I))
C----------
C  LOAD WK1 WITH MERCH CUBIC VOLUME PER TREE.
C----------
      WK1(I)=VM
C----------
C  SUMMARIZE VOLUME BY SPECIES AND TREE CLASS.  IF LSTART IS
C  FALSE, LOAD WK5 AND SUMMARIZE ACCRETION BY SPECIES AND TREE
C  CLASS. DO NOT DO THIS FOR CYCLE 0 DEAD TREES.
C----------
      IF(IPASS .EQ. 2) GO TO 15
      IM=IMC(I)
      IF(.NOT.LSTART) THEN
        IF(CFV(I).GT.VN)THEN
          WK5(I)=0.
        ELSE
          WK5(I)=(VN-CFV(I))*P/FINT
        ENDIF
        SPCAC(ISPC,IM)=SPCAC(ISPC,IM)+WK5(I)
      ENDIF
      SPCCC(ISPC,IM)=SPCCC(ISPC,IM)+VN*P
C----------
C  LOAD CFV WITH TOTAL CUBIC VOLUME PER TREE.
C----------
   15 CONTINUE
      CFV(I)=VN
      ICDF= DEFECT(I)/1000000
      IF(WK1(I).GT.0.0 .AND. LCVOLS) THEN
C----------
C       COMPUTE DEFECT CORRECTION FACTOR FOR CUBIC FOOT VOLUME.
C       TAKE LARGEST OF 1) INPUT CF DEFECT PERCENT, 2) COMPUTED LINEAR
C       INTERPOLATION VALUE, OR 3) COMPUTED LOG-LINEAR MODEL VALUE.
C----------
        DLIEQN=NINT(ALGSLP(D,DBHCLS,CFDEFT(1,ISPC),9) * 100.)
        IF(DLIEQN.GT.ICDF) ICDF=DLIEQN
        IF(CFLA0(ISPC).EQ.0.0 .AND. CFLA1(ISPC).EQ.1.0) THEN
          VOLCOR=WK1(I)
        ELSE
          VOLCOR=EXP(CFLA0(ISPC)+CFLA1(ISPC)*ALOG(WK1(I)))
        ENDIF
        DLLMOD=NINT(((WK1(I)-VOLCOR)/WK1(I)) * 100.)
        IF(DLLMOD.GT.ICDF) ICDF=DLLMOD
        IF(ICDF.GT.99) ICDF=99
        IF(ICDF.LT. 0) ICDF= 0
      ENDIF
C----------
C        CORRECT MERCHANTABLE CUBIC VOLUME FOR FORM AND DEFECT.
C        CONSIDER 99% DEFECT AS 100% DEFECT.
C----------
      IF(ICDF.LT.99) THEN
        WK1(I)=WK1(I)*(1.-FLOAT(ICDF)/100.)
      ELSE
        WK1(I)=0.
      ENDIF
      IF(IPASS .EQ. 1) SPCMC(ISPC,IM)=SPCMC(ISPC,IM)+WK1(I)*P
C----------
C  CALL ECON EXTENSION TO PROCESS VOLUME INFORMATION
C----------
      IF (WK1(I) .GT. 0.0) CALL ECVOL(IT,LOGDIA,LOGVOL,.TRUE.)
C**************************************************
C       FVS BOARD VOLUME SECTION                  *
C**************************************************
C----------
C  COMPUTE SCRIBNER BOARD FOOT VOLUME TO A VARIABLE TOP FOR TREES
C  OF MINIMUM MERCHANTABLE DBH AND LARGER.
C----------
      BFV(I)=0.0
      IBDF= DEFECT(I)/10000 - (DEFECT(I)/1000000)*100
      IF(D.LT.BFMIND(ISPC).OR.D.LE.BFTOPD(ISPC)) GO TO 150
C----------
C   CALCULATE SCRIBNER BOARD FOOT VOLUME.
C----------
      IF(DEBUG)WRITE(JOSTND,*)' BOARD SECTION, I,ISPC,D,H,METHB= ',
     &I,ISPC,D,H,METHB(ISPC)
      IF(METHB(ISPC).EQ.6 .OR. METHB(ISPC).EQ.9) THEN
        IF(METHC(ISPC).EQ.6) THEN
          GO TO 100
        ELSE
        CALL NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,
     1               CTKFLG,BTKFLG,IT)
        ENDIF
      ELSEIF (METHB(ISPC).EQ.8) THEN
        IT=I
        CALL OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRUNC(I),VMAX,LCONE,
     1               BTKFLG,IT)
      ELSE
        CALL BFVOL (ISPC,D,H,D2H,BBFV,TKILL,LCONE,BARK,VMAX,ITRUNC(I),
     1              BTKFLG)
      ENDIF
C-----------
C  CORRECT FOR TOPKILL IF NEEDED.
C  LOAD BFV WITH SCRIBNER BOARD FOOT VOLUME CORRECTED FOR TOPKILL.
C----------
  100 CONTINUE
      IF(BTKFLG .AND. TKILL .AND. VMAX .GT. 0.)
     1 CALL BFTOPK (ISPC,D,H,BBFV,LCONE,BARK,VMAX,ITRUNC(I))
      BFV(I)=BBFV
      IF(BFV(I).GT.0.0 .AND. LBVOLS) THEN
C----------
C     COMPUTE DEFECT CORRECTION FACTOR FOR BOARD FOOT VOLUME.
C     TAKE LARGEST OF 1) INPUT BF DEFECT PERCENT, 2) COMPUTED LINEAR
C     INTERPOLATION BF VALUE, OR 3) COMPUTED LOG-LINEAR MODEL BF VALUE.
C----------
        DLIEQN=NINT(ALGSLP(D,DBHCLS,BFDEFT(1,ISPC),9) * 100.)
        IF(DLIEQN.GT.IBDF)IBDF=DLIEQN
        IF(BFLA0(ISPC).EQ.0.0 .AND. BFLA1(ISPC).EQ.1.0) THEN
          VOLCOR=BFV(I)
        ELSE
          VOLCOR=EXP(BFLA0(ISPC)+BFLA1(ISPC)*ALOG(BFV(I)))
        ENDIF
        DLLMOD=NINT(((BFV(I)-VOLCOR)/BFV(I)) * 100.)
        IF(DLLMOD.GT.IBDF)IBDF=DLLMOD
        IF(IBDF.GT.99)IBDF=99
        IF(IBDF.LT. 0)IBDF= 0
      ENDIF
C----------
C        CORRECT MERCHANTABLE BOARD FOOT VOLUME FOR FORM AND DEFECT.
C        CONSIDER 99% DEFECT AS 100% DEFECT.
C----------
      IF(IBDF.LT.99) THEN
        BFV(I)=BFV(I)*(1.-FLOAT(IBDF)/100.)
      ELSE
        BFV(I)=0.
      ENDIF
C----------
C  CALL ECON EXTENSION TO PROCESS VOLUME INFORMATION
C----------
      IF (BFV(I) .GT. 0.0) CALL ECVOL(IT,LOGDIA,LOGVOL,.FALSE.)
C----------
C  RESET NEGATIVE VOLUMES TO ZERO AND COMPILE TOTAL.
C----------
      IF(BFV(I).LT.0.0) BFV(I)=0.0
  150 CONTINUE
      IF(IPASS .EQ. 1) SPCBV(ISPC,IM)=SPCBV(ISPC,IM)+BFV(I)*P
C----------
C  SET VALUES IN CODED DEFECT NUMBER TO INDICATE THE ACTUAL DEFECT
C  PERCENTAGES APPLIED THIS CYCLE.
C  DEFECT CODED AS 11223344, WHERE 11=INPUT MC DEFECT %, 22=INPUT BF
C  DEFECT PERCENT, 33=MC DEFECT % USED THIS CYCLE, 44=BF DEFECT % USED
C  THIS CYCLE.
C----------
      DEFECT(I)=((DEFECT(I)/10000)*10000) + ICDF*100 + IBDF
      IF(DEBUG)WRITE(JOSTND,*)' IN VOLS, I= ',I,' DEFECT= ',DEFECT(I)
C----------
C  PRINT DEBUG OUTPUT IF DESIRED
C----------
      IF(.NOT.DEBUG) GO TO 200
      WRITE(JOSTND,9000)I,VN,WK1(I),WK5(I),CFV(I),
     &     SPCAC(ISPC,1),SPCAC(ISPC,2),SPCAC(ISPC,3),SPCCC(ISPC,1),
     &     SPCCC(ISPC,2),SPCCC(ISPC,3),ISPC,D,H
 9000 FORMAT(' IN VOLS, I=',I4,' VN=',E15.6,' WK1=',E15.6,/,
     &  '  WK5=',E15.6,' CFV=',E15.6,
     &  ' SPCAC=',3(E15.6,',')/'  SPCCC=',3(E15.6,','),' ISPC=',I2,
     &  ' DBH=',E11.2,' NORMAL HT=',E11.2)
C----------
C  END OF TREE LOOP.
C----------
  200 CONTINUE
  205 CONTINUE
      IF(IPASS .EQ. 2) GO TO 250
C----------
C  DETERMINE SPECIES-TREE CLASS COMPOSITION FOR ALL VOLUME STANDARDS.
C----------
      CALL COMP(OSPCV,IOSPCV,SPCCC)
      CALL COMP(OSPBV,IOSPBV,SPCBV)
      CALL COMP(OSPMC,IOSPMC,SPCMC)
C----------
C  DETERMINE SPECIES-TREE CLASS COMPOSITION AND PERCENTILE POINTS IN
C  THE DISTRIBUTION OF DIAMETERS FOR ANNUAL TOTAL CUBIC FOOT ACCRETION.
C  BYPASS IF LSTART IS TRUE.
C----------
      IF(LSTART) GO TO 210
      CALL COMP(OSPAC,IOSPAC,SPCAC)
      CALL PCTILE(ITRN,IND,WK5,WK3,OACC(7))
      CALL DIST(ITRN,OACC,WK3)
  210 CONTINUE
C----------
C  CALCULATE VOLUMES FOR CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 250
      IPASS=2
      ILOW=IREC2
      IHI=MAXTRE
      GO TO 10
C----------
C  END OF VOLS.
C----------
  250 CONTINUE
      DO I=1,10
      IF(DEBUG)WRITE(JOSTND,*)' LEAVING VOLS, I,CFV,BFV= ',
     * I,CFV(I),BFV(I)
      ENDDO
      RETURN
      END
