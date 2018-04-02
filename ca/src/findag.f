      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX1,HTMAX2,
     &                  DEBUG)
      IMPLICIT NONE
C----------
C CA $Id: findag.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM ***COMCUP
C  CALLED FROM ***CRATET
C  CALLED FROM ***HTGF
C  CALLS ***HTCALC
C----------
C  COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C  DECLARATIONS
C----------
      INTEGER I,ISPC
      LOGICAL DEBUG
      REAL AGEMAX(MAXSP),AGMAX,AG,DIFF,H,HGUESS,SINDX,TOLER
      REAL SITAGE,SITHT,D1,D2,HTMAX1,HTMAX2
      REAL RDANUW
C----------
C  DATA STATEMENTS
C----------
      DATA AGEMAX/ MAXSP*200. /
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = D1
      RDANUW = D2
      RDANUW = HTMAX1
      RDANUW = HTMAX2
C----------
C  INITIALIZATIONS
C----------
      TOLER=2.0
      SINDX = SITEAR(ISPC)
      AGMAX=AGEMAX(ISPC)
      IF(IFOR .LE. 5) AGMAX=400.
      AG = 2.0
C----------
C R5 USE DUNNING/LEVITAN SITE CURVE.
C R6 USE **HTCALC** SITE CURVES.
C SPECIES DIFFERENCES ARE ARE ACCOUNTED FOR BY THE SPECIES
C SPECIFIC SITE INDEX VALUES WHICH ARE SET AFTER KEYWORD PROCESSING.
C----------
   75 CONTINUE
C
      HGUESS = 0.
      CALL HTCALC(IFOR,SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)I,IFOR,AG,HGUESS,H
91200 FORMAT(' IN GUESS AN AGE--I,IFOR,AGE,HGUESS,H ',2I5,3F10.2)
C
      DIFF=ABS(HGUESS-H)
      IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
        SITAGE = AG
        SITHT = HGUESS
        GO TO 30
      END IF
      AG = AG + 2.
C
      IF(AG .GT. AGMAX) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C
   30 CONTINUE
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  I,SITAGE,SITHT =',
     &I5,2F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT