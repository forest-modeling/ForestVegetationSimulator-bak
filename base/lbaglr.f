      SUBROUTINE LBAGLR (KEYWRD,JOSTND,IREAD,IRECNT,RECORD,KODE)
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C
C     READ AN ACTIVITY GROUP LABEL FOR THE CURRENT ACTIVITY GROUP.
C
C     PART OF THE LABEL PROCESSING COMPONENT OF THE PROGNOSIS SYSTEM
C     N.L. CROOKSTON -- INTERMOUNTAIN RESEARCH STATION -- JAN 1987
C
C     KEYWRD= KEYWORD CHARACTER STRING.
C     JOSTND= PRINT MESSAGE FILE.
C     IREAD = READER FILE
C     IRECNT= NUMBER OF RECORDS READ ON IRECNT.
C     KODE  = 0: OK, 1: END-OF-DATA FOUND ON IREAD.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
      CHARACTER*8 KEYWRD
      CHARACTER*(*) RECORD
      INTEGER KODE,IRECNT,IREAD,JOSTND,LWRK,I1,I2
C
C     READ THE ACTIVITY GROUP LABEL, STORE IT IN A WORK STRING.
C
      CALL LBSTRD (IREAD,LWRK,WKSTR1,IRECNT,RECORD,KODE,WKSTR2,WKSTR3)
C
C     IF THE RETURN CODE IS GT ONE, END-OF-DATA WAS FOUND
C
      IF (KODE.GT.1) THEN
         KODE=1
         GOTO 50
      ENDIF
C
C     WRITE THE ACTIVITY GROUP LABEL.
C
      WRITE (JOSTND,10) KEYWRD
   10 FORMAT (/1X,A8,'   ACTIVITY GROUP LABEL SET: ')
      I1=1
      I2=100
   20 CONTINUE
      IF (I2.GT.LWRK) I2=LWRK
      WRITE (JOSTND,'(T13,A)') WKSTR1(I1:I2)
      IF (I2.LT.LWRK) THEN
         I1=I2+1
         I2=I2+100
         GOTO 20
      ENDIF
      IF (KODE.EQ.1) THEN
         KODE=0
         WRITE (JOSTND,30)
   30    FORMAT (/' ********   WARNING: THIS LABEL SET IS SHORTER ',
     >           'THAN THE ONE YOU SPECIFIED.')
         CALL RCDSET (1,.TRUE.)
      ENDIF
C
C     IF LOPENV IS TRUE, THEN STORE THE LABEL SET IN THE CORRECT STRING
C     AND SET LBSETS TRUE INDICATING THAT AT LEAST SOME ACTIVITY GROUPS
C     HAVE LABELS.
C
      IF (LOPEVN) THEN
         LBSETS=.TRUE.
         AGLSET(IEVA)=WKSTR1
         LENAGL(IEVA)=LWRK
      ELSE
C
C        AN ACTIVITY GROUP LABEL CAN NOT BE ENTERED BECAUSE THE
C        AGPLABEL KEYWORD MUST BE ENTERED IN THE CONTEXT OF AN
C        ACTIVITY GROUP.
C
         WRITE (JOSTND,40)
   40    FORMAT (/' ********   ERROR: THIS ACTIVITY GROUP LABEL IS NOT',
     >           ' PART OF AN ACTIVITY GROUP AND WILL BE IGNORED.')
         CALL RCDSET (1,.TRUE.)
      ENDIF
   50 CONTINUE
      RETURN
      END
