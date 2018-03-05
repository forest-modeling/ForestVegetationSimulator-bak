      SUBROUTINE RDZERO
      IMPLICIT NONE
C----------
C RD $Id: rdzero.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C
C  THIS SUBROUTINE TAKES THE CENTERS, CHECKS IF THE RADIUS OF ANY IS ZERO 
C  (OR SMALL, LESS THAN 0,01)
C  AND REMOVES IT FROM CONSIDERATION. WHEN A CENTER IS REMOVED, ALL VARIABLES
C  REFERENCING A CENTER BY CENTER NUMBER MUST BE UPDATED.
C
C  CALLED BY :
C     RDCNTL  [ROOT DISEASE]
C
C  CALLS     :
C     DBCHK   (SUBROUTINE)   [PROGNOSIS]
C
C  DEFINITIONS:
C
C  Revision History:
C   10/04/93 - Last revision date.
C   09/04/14 Lance R. David (FMSC)
C     Added implicit none and declared variables.
C
C----------------------------------------------------------------------
C
C
C.... PARAMETER INCLUDE FILES
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'RDPARM.F77'
C
C.... COMMON INCLUDE FILES
C
      INCLUDE 'CONTRL.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'RDCOM.F77'
      INCLUDE 'RDARRY.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'RDADD.F77'
C
      LOGICAL DEBUG
      INTEGER I, ICEN, ICENT, JCEN

C
C     SEE IF WE NEED TO DO SOME DEBUG.
C
      CALL DBCHK (DEBUG,'RDZERO',6,ICYC)

      IF (DEBUG) WRITE (JOSTND,1)
    1 FORMAT (' STARTING RDZERO')

C     BEGIN PROGRAM
      ICENT = NCENTS(IRRSP)
      
      DO 300 ICEN= ICENT,1,-1
        IF (PCENTS(IRRSP,ICEN,3) .LE. 0.01) THEN

C         REDUCE THE NUMBER OF CENTERS
          NCENTS(IRRSP) = NCENTS(IRRSP) - 1
          IF (SHCENT(IRRSP,ICEN,2) .GT. 0.0) 
     &                    NSCEN(IRRSP) = NSCEN(IRRSP) - 1

C         MOVE EVERYTHING UP ONE PLACE
          DO 200 JCEN= ICEN,ICENT-1
            DO 150 I= 1,3
              PCENTS(IRRSP,JCEN,I) = PCENTS(IRRSP,JCEN+1,I)
              SHCENT(IRRSP,JCEN,I) = SHCENT(IRRSP,JCEN+1,I)
  150       CONTINUE 
            ICENSP(IRRSP,JCEN) = ICENSP(IRRSP,JCEN+1)
            RRATES(IRRSP,JCEN) = RRATES(IRRSP,JCEN+1)
  200     CONTINUE 
             
C         IF THIS IS THE FIRST CENTER TO BE REMOVED, PUT A ZERO IN THE LAST PLACE
          IF (NCENTS(IRRSP) .EQ. (ICENT-1)) THEN
            ICENSP(IRRSP,ICENT) = 0 
            RRATES(IRRSP,ICENT) = 0.0
            DO 100 I= 1,3
              PCENTS(IRRSP,ICENT,I) = 0.0
              SHCENT(IRRSP,ICENT,I) = 0.0
  100       CONTINUE
          ENDIF
        ENDIF
  300 CONTINUE
      
      
      RETURN
      END
