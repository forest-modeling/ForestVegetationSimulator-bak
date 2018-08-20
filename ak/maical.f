      SUBROUTINE MAICAL
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C  THIS SUBROUTINE CALCULATES THE MAI FOR THE STAND.
C  CALLED FROM CRATET.
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
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      INTEGER IERR,ISICD
C
      INTEGER ISPNUM(MAXSP)
C
      REAL ADJMAI,SSSI
C
C----------
C  DATA STATEMENTS:
C
C  SPECIES ORDER
C  1    2    3    4    5    6    7    8    9   10   11  12  13
C WS  WRC  PSF   MH   WH  AYC   LP   SS   SAF  RA   CW  OH  OS
C----------
      DATA ISPNUM/098,242,011,264,263,042,108,098,019,351,747,300,098/
C----------
C     THE SPECIES ORDER IS AS FOLLOWS:
C     1 = WHITE SPRUCE (WS)
C     2 = WESTERN RED CEDAR (RC)
C     3 = PACIFIC SILVER FIR (SF)
C     4 = MOUNTAIN HEMLOCK (MH)
C     5 = WESTERN HEMLOCK (WH)
C     6 = ALASKA CEDAR (YC)
C     7 = LODGEPOLE PINE (LP)
C     8 = SITKA SPRUCE (SS)
C     9 = SUBALPINE FIR (AF)
C    10 = RED ALDER (RA)
C    11 = COTTONWOOD (CW)
C    12 = OTHER HARDWOODS (OH)
C    13 = OTHER SOFTWOODS (OS)
C
C   RMAI IS FUNCTION TO CALCULATE ADJUSTED MAI.
C-------
      IF (ISISP .EQ. 0) ISISP=5
      SSSI=SITEAR(ISISP)
      IF (SSSI .EQ. 0.) SSSI=80.0
      ISICD=ISPNUM(ISISP)
      RMAI=ADJMAI(ISICD,SSSI,10.0,IERR)
      IF(RMAI .GT. 128.0)RMAI=128.0
      RETURN
      END
