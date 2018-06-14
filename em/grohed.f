      SUBROUTINE GROHED (IUNIT)
      IMPLICIT NONE
C----------
C EM $Id: grohed.f 0000 2018-02-14 00:00:00Z gedixon $
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
      CHARACTER DAT*10,TIM*8,REV*10,SVN*4
      INTEGER IUNIT
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
C     CALL REVISE TO GET THE LATEST REVISION DATE FOR THIS VARIANT.
C----------
      CALL REVISE (VARACD,REV)
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
     >  5X,'VERSION ',A,' -- EASTERN MONTANA PROGNOSIS',
     >  T97,'RV:',A,T112,A,2X,A)
      RETURN
      END
