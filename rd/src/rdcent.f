      SUBROUTINE RDCENT(PROBIN,PCENTS,NCENTS,PROBD,SAREA,
     &                  IRFLAG,NNCENT,PISIZE,PAREA,IRRSP)
      IMPLICIT NONE
C----------
C RD $Id: rdcent.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C  THIS SUBROUTINE CREATES NEW INFECTION CENTERS BASED ON THE TOTAL
C  NUMBER OF INFECTED STUMPS, THE PROBABILITY OF INITIATION, AND
C  THE DISTRIBUTION OF THOSE STUMPS (IN THE OLD DISEASE CENTERS).
C
C  CALLED BY :
C     RDCNTL  [ROOT DISEASE]
C
C  CALLS     :
C     DBCHK   (SUBROUTINE)   [PROGNOSIS]
C     RDRANN  (FUNCTION)     [ROOT DISEASE]
C
C  PARAMETERS :
C     PROBIN -
C     PCENTS -
C     NCENTS -
C     PROBD  -
C     SAREA  -
C     IRFLAG -
C     NNCENT -
C     PISIZE -
C     PAREA  -
C
C  Revision History :
C   12/15/87 - Last revision date.
C   08/27/14 Lance R. David (FMSC)
C     Added implicit none and declared variables.
C
C----------------------------------------------------------------------
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'CONTRL.F77'

      INCLUDE 'RDPARM.F77'
      INCLUDE 'RDADD.F77'
C
COMMONS
C
      INTEGER  I, INP, IRFLAG, IRRSP, IT, J, NCENTS(ITOTRR), NCELLS,
     &         NHASH, NNCENT, NPCELL, NSTUMP

      REAL     ARRAY(75,75), DIMEN, DIST, PAREA(ITOTRR), PCELL,
     &         PPCELL, PCENTS(ITOTRR,100,3), PISIZE(ITOTRR),
     &         PROBD(ITOTRR,2,5),PROBIN(ITOTRR,2,5), R, RDRANN,
     &         SAREA, TSTUMP,XP, YP, WSTUMP

      LOGICAL DEBUG

      DATA NHASH/75/

C
C     SEE IF WE NEED TO DO SOME DEBUG.
C
      CALL DBCHK (DEBUG,'RDCENT',6,ICYC)

      IF (DEBUG) WRITE (JOSTND,69) PROBIN
   69 FORMAT (' IN RDCENT : PROBIN = ',(4E15.7))
      IF (DEBUG) WRITE (JOSTND,79) PROBD
   79 FORMAT (' IN RDCENT : PROBD = ',(4E15.7))

      DIMEN = SQRT(SAREA) * 208.7
C
C     SET UP THE LOCATION OF THE INFECTED AREAS IN THE LOCATION ARRAY
C
      NSTUMP = 0
      TSTUMP = 0.
      DO 200 I=1, 2
         DO 100 J=1, 5
            TSTUMP = TSTUMP + PROBD(IRRSP,I,J)
            NSTUMP=INT(REAL(NSTUMP)+PROBD(IRRSP,I,J)*PROBIN(IRRSP,I,J))
  100    CONTINUE
  200 CONTINUE

      WSTUMP = FLOAT(NSTUMP) / (TSTUMP+1E-6)
      NCELLS = 0
      DO 500 I=1, NHASH
         DO 400 J=1, NHASH
            ARRAY(I,J) = 0
            XP = (DIMEN/NHASH) * (I-0.5)
            YP = (DIMEN/NHASH) * (J-0.5)
            IF (NCENTS(IRRSP) .EQ. 0) GOTO 400

            DO 300 IT=1, NCENTS(IRRSP)
               DIST = SQRT((XP - PCENTS(IRRSP,IT,1))**2 +
     &                (YP-PCENTS(IRRSP,IT,2))**2)
               IF (DIST .GT. PCENTS(IRRSP,IT,3)) GOTO 300
               NCELLS = NCELLS + 1
               ARRAY(I,J) = 1
               GOTO 400
  300       CONTINUE
  400    CONTINUE
  500 CONTINUE

      IF (DEBUG) WRITE(JOSTND,777) NCELLS
  777 FORMAT(' IN RDCENT : NCELLS=',I5)
C
C     ESTIMATE MEAN NUMBER OF NEW CENTERS PER INFECTED CELL
C
      IF (IRFLAG .EQ. 1) GOTO 650
      IF (NSTUMP .GT. 100) NSTUMP = 100
      PCELL = FLOAT(NSTUMP) / (FLOAT(NCELLS) + 1E-6)
      GOTO 700

  650 CONTINUE
      PCELL = FLOAT(NNCENT) / (FLOAT(NCELLS) + 1E-6)

  700 CONTINUE
C
C     CALCULATE THE SIZE OF EACH NEW PATCH
C
      PISIZE(IRRSP) = SQRT(PAREA(IRRSP) * WSTUMP /
     &                (3.14159 * NSTUMP + 1E-6))
      PISIZE(IRRSP) = PISIZE(IRRSP) * 208.7

      IF (DEBUG) WRITE(JOSTND,778) IRRSP,PCELL,PISIZE(IRRSP)
  778 FORMAT(' RDCENT : IRRSP PCELL PISIZE=',I2,2E15.8)
      IF (DEBUG) WRITE(JOSTND,785) NSTUMP,NNCENT,WSTUMP,PAREA(IRRSP)
  785 FORMAT(' RDCENT : NSTUMP NNCENT WSTUMP PAREA',2I5,2F15.8)

C
C     RANDOMLY ASSIGN DISEASE CENTERS TO CELLS TO OBTAIN COORDINATES
C
      NCENTS(IRRSP) = 0
      SPPROP(IRRSP) = 0.0

      DO 900 I=1, NHASH
         DO 800 J=1, NHASH
            IF (ARRAY(I,J) .EQ. 0) GOTO 800
            NPCELL = IFIX(PCELL)
            R = RDRANN(0)
            PPCELL = PCELL - IFIX(PCELL)
            IF (R .GT. PPCELL) GOTO 725
            NPCELL = NPCELL + 1
            IF (DEBUG) WRITE(JOSTND,779) NPCELL
  779       FORMAT(' RDCENT : NPCELL=',I5)

  725       CONTINUE
            IF (NPCELL .LT. 1) GOTO 800
            DO 750 INP=1, NPCELL
               IF (NCENTS(IRRSP) .GE. 100) GOTO 1000
               NCENTS(IRRSP) = NCENTS(IRRSP) + 1
               R = RDRANN(0)
               PCENTS(IRRSP,NCENTS(IRRSP),1) = (DIMEN/NHASH) * (I-R)
               R = RDRANN(0)
               PCENTS(IRRSP,NCENTS(IRRSP),2) = (DIMEN/NHASH) * (J-R)
               PCENTS(IRRSP,NCENTS(IRRSP),3) = PISIZE(IRRSP)
               ICENSP(IRRSP,NCENTS(IRRSP)) = 0
  750       CONTINUE
  800    CONTINUE
  900 CONTINUE

      IF (DEBUG) WRITE(JOSTND,780) NCENTS(IRRSP)
 780  FORMAT(' RDCENT : NCENTS=',I5)

 1000 CONTINUE
      RETURN
      END
