
      SUBROUTINE GVRVOL (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
      IMPLICIT NONE
C----------
C LS $Id: gvrvol.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C  GEVORKIANTZ VOLUME CALCULATION METHOD (METHC AND/OR METHB=5)
C  THIS METHOD WAS SUPERCEEDED BY THE CLARK METHOD FALL 2009
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'ARRAYS.F77'
COMMONS
C
C----------
      REAL VOL(15)
      LOGICAL TKILL,CTKFLG,BTKFLG,DEBUG,DONE
      CHARACTER CTYPE*1,HTTYP*1
      CHARACTER*2 FORST,PROD
      INTEGER FOREST,IHT1,IHT2
      INTEGER I1,I0,I02,I01,I,ISPC,IERR,IT,ITRNC
      REAL SAWBF,SAWCU,X01,TOTCU,BOLT1,BOLT2,BFTDOB
      REAL TOPDOB,SINDX,VM,VN,BBFV,H,D,BARK,VMAX
C----------
C  CHECK FOR DEBUG
C----------
      CALL DBCHK(DEBUG,'VARVOL',6,ICYC)
      IF(DEBUG)WRITE(JOSTND,*)'IN GVRVOL -, ICYC= ',ICYC
C----------
C  INITIALIZE VOLUME ARRAY TO ZERO
C----------
      DO  11 I=1,15
      VOL(I)= 0.
   11 CONTINUE
      FOREST = KODFOR-900
      WRITE(FORST,'(I2)')FOREST
      IF(FOREST.LT.10)FORST(1:1)='0'
      SINDX=SITEAR(ISPC)
      DONE=.FALSE.
      TOPDOB=TOPD(ISPC)/BARK
      BFTDOB=BFTOPD(ISPC)/BARK
C
      IF(DEBUG)WRITE(JOSTND,*)
     &' TOPDOB= ',TOPDOB,' BFTDOB=',BFTDOB,' BRATIO=',BARK
C----------
C  CALL NBOLT TO COMPUTE THE TOTAL NUMBER OF 8' BOLTS TO A SPECIFIED
C  PULPWOOD AND SAWTIMBER TOP DIAMETER.
C    IHT1 = # OF SAWLOG 8' BOLTS
C    IHT2 = # OF PULPWOOD 8' BOLTS
C----------
      CALL NBOLT(ISPC,H,D,DBHMIN,BFMIND,SINDX,TOPDOB,BFTDOB,
     &           JOSTND,DEBUG,IHT1,IHT2)
      BOLT1=FLOAT(IHT1)
      BOLT2=FLOAT(IHT2)
      IF(DEBUG)WRITE(JOSTND,*)' AFTER NBOLT BOLT1,BOLT2= ',BOLT1,BOLT2
C----------
C  COMPUTE TOTAL MERCH CUBIC, SAWLOG CUBIC, AND SAWLOG BOARDFOOT VOLUME
C
C  CASES 1-3 ASSUME THE MINIMUM SAWTIMBER DBH IS GREATER THAN THE
C  MINIMUM PULPWOOD DBH
C----------
      IF(DEBUG)WRITE(JOSTND,*)' ISPC,D,DBHMIN,BFMIND,IHT1,IHT2= ',
     &ISPC,D,DBHMIN(ISPC),BFMIND(ISPC),IHT1,IHT2
C
C----------
C  SET CONSTANT ARGUMENTS IN CALL TO R9VOL
C
C  REAL CONSTANT ARGUMENTS
C----------
        X01=0.
C----------
C  INTEGER CONSTANT ARGUMENTS
C----------
        IERR=0
        I01=0
        I02=0
        I0=0
        I1=1
C----------
C  CHARACTER CONSTANT ARGUMENTS
C----------
        CTYPE='F'
        HTTYP='L'
C
C----------
C  TREE DBH IS LESS THAN PULPWOOD MIN DBH, OR NO PULPWOOD HT
C----------
      IF(D.LT.DBHMIN(ISPC) .OR. IHT2.LE.0)THEN
C
C  CASE 1: TREE DOES NOT MEET PULPWOOD SPECS
C
        TOTCU=0.
C----------
C  TREE DBH IS >PULPWOOD MIN DBH BUT <SAWTIMBER MIN DBH, OR NO SAW HT
C----------
      ELSEIF(D.LT.BFMIND(ISPC).OR. IHT1.LE.0)THEN
C
C  CASE 2: TREE ONLY HAS PULPWOOD (PROD='02')
C
        IF(DEBUG)WRITE(JOSTND,*)' CASE 2 PWVOL VEQNNC,BOLT2,D,H,FORST= '
     &  ,VEQNNC(ISPC),BOLT2,D,H,FOREST
C
        PROD='02'
        CALL R9VOL(VEQNNC(ISPC),H,BOLT2,BOLT2,D,VOL,FORST,I01,
     &             I02,PROD,CTYPE,I1,I1,I0,I1,HTTYP,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 2 PWVOL VOL= ',VOL
C
        TOTCU=VOL(4)
        SAWCU=0.0
        SAWBF=0.0
        DONE=.TRUE.
C----------
C  TREE DBH IS >SAWTIMBER MIN DBH, POSITIVE SAW HT AND PULP HT
C----------
      ELSE

C  CASE 3: TREE HAS SAWTIMBER AND PULPWOOD (PROD='01' AND TOPWOOD)

        IF(DEBUG)WRITE(JOSTND,*)' CASE 3 SBVOL VEQNNC,H,BOLT1,BOLT2,D,',
     &  'FORST= ',VEQNNC(ISPC),H,BOLT1,BOLT2,D,FORST
C
        PROD='01'
        CALL R9VOL(VEQNNC(ISPC),H,BOLT1,BOLT2,D,VOL,FORST,I01,
     &             I02,PROD,CTYPE,I1,I1,I0,I1,HTTYP,IERR)
        SAWBF=VOL(2)
        SAWCU=VOL(4)
        TOTCU=SAWCU+VOL(7)
        IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 3 TCVOL VOL= ',VOL
        IF(VEQNNB(ISPC).EQ.VEQNNC(ISPC))THEN
          DONE=.TRUE.
        ELSE
         CALL R9VOL(VEQNNB(ISPC),H,BOLT1,BOLT2,D,VOL,FORST,I01,
     &             I02,PROD,CTYPE,I1,I1,I0,I1,HTTYP,IERR)
         SAWBF=VOL(2)
         DONE=.TRUE.
         IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 3 (CALL 2)TCVOL VOL= ',VOL
        ENDIF       
        IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 3 TCVOL VOL= ',VOL
      ENDIF
      IF (DONE)GOTO 51
C----------
C--TREE DID NOT MEET PULPWOOD SPECS
C----------
      IF(D .LT. BFMIND(ISPC))THEN
C
C  CASE 4: TREE DOES NOT MEET SAWTIMBER OR PULPWOOD SPECS
C
        SAWCU=0.0
        SAWBF=0.0
      ELSE
C
C  CASE 5: STRANGE CASE SPECS MET AND TREE ONLY HAS SAWTIMBER(PROD='01')
C
        IF(DEBUG)WRITE(JOSTND,*)' CASE 5 R9VOL VEQNNC,BOLT1,D,FORST= ',
     &  VEQNNC(ISPC),BOLT2,D,FOREST
C
        PROD='01'
        CALL R9VOL(VEQNNC(ISPC),H,BOLT1,X01,D,VOL,FORST,I01,
     &             I02,PROD,CTYPE,I1,I1,I0,I0,HTTYP,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 5 R9VOL VOL= ',VOL
C
        SAWCU=VOL(4)
        SAWBF=VOL(2)
        IF(VEQNNB(ISPC).NE.VEQNNC(ISPC))THEN
          CALL R9VOL(VEQNNB(ISPC),H,BOLT1,X01,D,VOL,FORST,I01,
     &             I02,PROD,CTYPE,I1,I1,I0,I0,HTTYP,IERR)
          SAWBF=VOL(2)
        IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 5 (CALL 2) R9VOL VOL= ',VOL
        ENDIF
      ENDIF
C----------
C  SET RETURN VALUES.
C----------
   51 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' TOTCU=',TOTCU,' SAWCU=',SAWCU,
     &   ' SAWBF=',SAWBF
      VN=TOTCU
      VMAX=VN
      VM=SAWCU
      BBFV=SAWBF
      IF(DEBUG)WRITE(JOSTND,*)' RETURNING VN,VMAX,VM,BBFV= ',
     &VN,VMAX,VM,BBFV
C
      RETURN
      END
C