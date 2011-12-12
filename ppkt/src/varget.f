      SUBROUTINE VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      IMPLICIT NONE
C----------
C  **VARGET--KT   DATE OF LAST REVISION:  09/18/08
C----------
C
C     READ THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'KOTCOM.F77'
C
C
COMMONS
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).  SO... DON'T EVER LET MXI, MXL, MXR
C     BE SET HIGHER THAT MAXTRE.
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      LOGICAL LOGICS(MXL)
      PARAMETER (MXL=1,MXI=1,MXR=5)
      REAL WK3(MAXTRE)
      INTEGER INTS(MXI)
      REAL REALS(MXR)
C
C     GET THE INTEGER SCALARS.
C
      CALL IFREAD (WK3, IPNT, ILIMIT, INTS, MXI, 2)
      KKTYPE = INTS(1)
      KOTFOR = INTS(2)
C
C     GET THE LOGICAL SCALARS.
C
C**   CALL LFREAD (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     GET THE REAL SCALARS.
C
C**   CALL BFREAD (WK3, IPNT, ILIMIT, REALS, MXR, 2)
      RETURN
      END
