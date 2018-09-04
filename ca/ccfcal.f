      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      IMPLICIT NONE
C----------
C CA $Id$
C----------
C  THIS ROUTINE COMPUTES CROWN WIDTH AND CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE, PRTRLS, SSTAGE, AND CVCW.
C
C  ARGUMENT DEFINITIONS:
C    ISPC = NUMERIC SPECIES CODE
C       D = DIAMETER AT BREAST HEIGHT
C       H = TOTAL TREE HEIGHT
C     JCR = CROWN RATIO IN PERCENT (0-100)
C       P = TREES PER ACRE
C   LTHIN = .TRUE. IF THINNING HAS JUST OCCURRED
C         = .FALSE. OTHERWISE
C    CCFT = CCF REPRESENTED BY THIS TREE
C  CRWDTH = CROWN WIDTH OF THIS TREE
C    MODE = 1 IF ONLY NEED CCF RETURNED
C           2 IF ONLY NEED CRWDTH RETURNED
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C----------
C  DIMENSION AND DATA STATEMENTS FOR INTERNAL VARIABLES.
C
C  CROWN WIDTH EQUATIONS FOR REGION 5:
C  FROM WARBINGTON/LEVITAN & DIXON --- SEE DOCUMENTATION IN
C                                      SUBROUTINE **R5CRWD**
C
C  CROWN WIDTH EQUATIONS FOR REGION 6:
C  FROM DONNELLY --- SEE DOCUMENTATION IN SUBROUTINE **R6CRWD**
C
C  CCF DERIVED FROM CROWN WIDTHS CALCULATED WITH R5 EQUATIONS
C
C SPECIES ORDER IN CA VARIANT:
C  1=PC  2=IC  3=RC  4=WF  5=RF  6=SH  7=DF  8=WH  9=MH 10=WB
C 11=KP 12=LP 13=CP 14=LM 15=JP 16=SP 17=WP 18=PP 19=MP 20=GP
C 21=JU 22=BR 23=GS 24=PY 25=OS 26=LO 27=CY 28=BL 29=EO 30=WO
C 31=BO 32=VO 33=IO 34=BM 35=BU 36=RA 37=MA 38=GC 39=DG 40=FL
C 41=WN 42=TO 43=SY 44=AS 45=CW 46=WI 47=CN 48=CL 49=OH
C----------
      INTEGER JCR,ISPC,MODE
      REAL CRWDTH,CCFT,P,H,D,CRWD5
      LOGICAL LTHIN
      INTEGER IDANUW
      LOGICAL LDANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = JCR
      LDANUW = LTHIN
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.
      CRWDTH = 0.
C----------
C  CALL R5CRWD TO GET CROWN WIDTH FOR CCF CALCULATIONS.
C----------
      CALL R5CRWD (ISPC,D,H,CRWD5)
C----------
C  COMPUTE CROWN WIDTH
C----------
      IF(IFOR .GT. 5) GO TO 100
      CRWDTH = CRWD5
      GO TO 200
C----------
C  REGION 6 CROWN WIDTH
C----------
  100 CONTINUE
      CALL R6CRWD (ISPC,D,H,CRWDTH)
  200 CONTINUE
C----------
C  LIMIT CROWN WIDTH FOR PRINTING ON TREELIST.
C----------
      IF(CRWDTH .GT. 99.9) CRWDTH=99.9
C----------
C  COMPUTE CCF
C----------
      IF(MODE.EQ.1) THEN
        CCFT= CRWD5  * CRWD5  * 0.001803
        CCFT = CCFT * P
      ENDIF
C
      RETURN
      END
