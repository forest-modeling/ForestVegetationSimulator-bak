      SUBROUTINE TREGRO
      IMPLICIT NONE
C----------
C  **TREGRO--BS  DATE OF LAST REVISION:  11/30/2011
C----------
C    CALLED FROM **MAIN** AND PPMAIN EACH CYCLE.
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
COMMONS
C
C----------
C  DECLARATIONS:
C----------
      LOGICAL LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,LBGCGO,DEBUG
      INTEGER :: ICKTAKEN,IRTNCD
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'TREGRO',6,ICYC)
      CALL getrestartcode (ICKTAKEN)
      IF (ICKTAKEN.EQ.2) GOTO 10
C-----------
C  CALL GRINCR TO COMPUTE INCREMENTS AND SEE IF BUG MODELS ARE ACTIVE.
C-----------
      CALL GRINCR (DEBUG,1,LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,LBGCGO)
      call fvsCheckPoint (2,ICKTAKEN)
      IF (ICKTAKEN.NE.0) RETURN
      CALL getfvsRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
   10 CONTINUE
C-----------
C  CALL GRADD TO COMPUTE BUGS AND ADD THE INCREMENTS.
C-----------
      CALL GRADD (DEBUG,1,LTMGO,LMPBGO,LDFBGO,LBWEGO,LCVATV,LBGCGO)
C----------
C  END OF CYCLE.
C----------
      IF(DEBUG) WRITE(JOSTND,9022) ICYC
 9022 FORMAT(' END OF TREGRO, CYCLE=',I2,'.  RETURN TO MAIN')
      RETURN
      END
