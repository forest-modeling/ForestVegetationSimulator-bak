      SUBROUTINE GROHED (IUNIT)
      IMPLICIT NONE
C----------
C OP $Id$ 
C----------
C     WRITES HEADER FOR BASE MODEL PORTION OF PROGNOSIS SYSTEM
C----------
COMMONS
C
C
      INCLUDE 'INCLUDESVN.F77'
C
C
COMMONS
C----------
      CHARACTER DAT*10,TIM*8,VVER*7,DVVER*7,REV*10,SVN*4
      INTEGER IUNIT
      DATA DVVER/'OP     '/
C----------
C     CALL REVISE TO GET THE LATEST REVISION DATE FOR THIS VARIANT.
C----------
      CALL REVISE (DVVER,REV)
C
C     CALL THE DATE AND TIME ROUTINE FOR THE HEADING.
C
      CALL GRDTIM (DAT,TIM)
C
C     CALL PPE TO CLOSE OPTION TABLE IF IT IS OPEN.
C
      CALL PPCLOP (IUNIT)
C
      WRITE (IUNIT,40) SVN,REV,DAT,TIM
   40 FORMAT (//T10,'FOREST VEGETATION SIMULATOR',
     >  5X,'VERSION ',A,' ORGANON NWO&SMC',
     >  T97,'RV:',A,T112,A,2X,A)
C
      RETURN
C
C
      ENTRY VARVER (VVER)
C
C     SUPPLY THE VARIANT AND VERSION NUMBER.
C
      VVER=DVVER
      RETURN
      END
