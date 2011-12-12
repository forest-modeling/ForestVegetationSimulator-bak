      SUBROUTINE RDTIM
C----------
C  **RDTIM       LAST REVISION:  MARCH 1, 1995
C----------
C
C  SUBROUTINE FOR SUMMING UP OPROB FOR TIM
C
C  CALLED BY :
C     RDTREG  [ROOT DISEASE]
C
C  CALLS     :
C     NONE
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'RDPARM.F77'
C
C
      INCLUDE 'RDCOM.F77'
      INCLUDE 'RDARRY.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'CONTRL.F77' 
      INCLUDE 'RDADD.F77'
C
C
COMMONS
C
      RRGEN(1,1) = 0.0
      RRGEN(2,1) = 0.0
      IF (ITRN .LT. 1) RETURN

      IDI = MAXRR
      DO 1000 I = 1,ITRN
         IF (MAXRR .LT. 3) IDI = IDITYP(IRTSPC(ISP(I)))
C
C     If non-host species skip operation (RNH May98)
C
      IF (IDI .LE. 0) GO TO 1000
C
      RRGEN(IDI,1) = RRGEN(IDI,1) + PROB(I)
 1000 CONTINUE

      RETURN
      END
