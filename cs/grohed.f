      SUBROUTINE GROHED (IUNIT)
      IMPLICIT NONE
C----------
C CS $Id$
C----------
C     WRITES HEADER FOR BASE MODEL PORTION OF PROGNOSIS SYSTEM
C
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
      INCLUDE 'INCLUDESVN.F77'
C
COMMONS
C----------
      INTEGER IUNIT
      CHARACTER DAT*10,TIM*8,REV*10,SVN*8
C----------
C     CALL REVISE TO GET THE LATEST REVISION DATE FOR THIS VARIANT.
C----------
      CALL REVISE (VARACD,REV)
C
C     CALL THE DATE AND TIME ROUTINE FOR THE HEADING.
C
      CALL GRDTIM (DAT,TIM)
C
      WRITE (IUNIT,40) SVN,REV,DAT,TIM
   40 FORMAT (//T6,'FOREST VEGETATION SIMULATOR',
     >  5X,'VERSION ',A,' -- CENTRAL STATES',
     >  T97,'RV:',A,T112,A,2X,A)
      RETURN
      END
