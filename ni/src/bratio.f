      FUNCTION BRATIO(IS,D,H)
      IMPLICIT NONE
C----------
C NI $Id: bratio.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C
C FUNCTION TO COMPUTE BARK RATIOS. THIS ROUTINE IS VARIANT SPECIFIC
C AND EACH VARIANT USES ONE OR MORE OF THE ARGUMENTS PASSED TO IT.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
COMMONS
      INTEGER IS
      REAL H,D,BRATIO
      REAL DANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = H
      DANUW = D
C
      BRATIO=BKRAT(IS)
      RETURN
      END
