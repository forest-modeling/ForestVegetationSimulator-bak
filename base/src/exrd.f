      SUBROUTINE EXRD
      IMPLICIT NONE
C----------
C BASE $Id$
C----------
C
C     EXTRA EXTERNAL REFERENCES FOR THE WESTERN ROOT DISEASE MODEL
C     VERSION 3.0
C
C
      INCLUDE 'PRGPRM.F77'
C
C----------
      INTEGER ICODES(6),I3(*),I2(*),ITN1,ITN2,II,I,I1,II1
      INTEGER ILIMIT,IPNT,II2,III2,KEY
      REAL ARRAY(7),R1(*),RR2,RR1,OLD,WK3
      LOGICAL L,LNOTBK(7),LTR,LTEE,LDUM,LKECHO
      CHARACTER*8 KEYWRD,NORR
      REAL RDANUW
      INTEGER IDANUW
      CHARACTER*8 CDANUW
      LOGICAL LDANUW
C
      DATA NORR/'*NO RROT'/
C----------
C RDIN CALLED FROM INITRE
C----------
      ENTRY RDIN (KEYWRD,ARRAY,LNOTBK,LKECHO)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = ARRAY(1)
      CDANUW(1:8) = KEYWRD(1:8)
      LDANUW = LNOTBK(1)
      LDANUW = LKECHO
C
      CALL ERRGRO (.TRUE.,11)
      RETURN
C----------
C RDATV CALLED FROM INTREE
C----------
      ENTRY RDATV(L,LTEE)
      L=.FALSE.
      LTEE=.FALSE.
      RETURN
C----------
C RDTRES CALLED FROM INTREE
C----------
      ENTRY RDTRES (ITN1,ITN2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = ITN1
      IDANUW = ITN2
C
      RETURN
C----------
C RDINIT CALLED FROM INITRE
C----------
      ENTRY RDINIT
      RETURN
C----------
C RDDAM CALLED FROM DAMCDS
C----------
      ENTRY RDDAM  (II,ICODES)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = II
      IDANUW = ICODES(1)
C
      RETURN
C----------
C RDTRP CALLED FROM MAIN, GRINCR
C----------
      ENTRY RDTRP(LTR)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      LDANUW = LTR
C
      RETURN
C----------
C RDROUT CALLED FROM MAIN
C----------
      ENTRY RDROUT
      RETURN
C----------
C RDPRIN CALLED FROM NOTRE
C----------
      ENTRY RDPRIN (I)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = I
C
      RETURN
C----------
C RDESIN CALLED FROM INITRE
C----------
      ENTRY RDESIN
      RETURN
C----------
C RDTREG CALLED FROM GRADD
C----------
      ENTRY RDTREG
      RETURN
C----------
C RDCMPR CALLED FROM COMPRS
C----------
      ENTRY RDCMPR (I1,R1,I2,I3)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = I1
      IDANUW = I2(1)
      IDANUW = I3(1)
      RDANUW = R1(1)
C
      RETURN
C----------
C RDSTR CALLED FROM CUTS
C----------
      ENTRY RDSTR (II1,RR1,RR2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = II1
      RDANUW = RR1
      RDANUW = RR2
C
      RETURN
C----------
C RDESCP CALLED FROM ESTAB, ESUCKR
C----------
      ENTRY RDESCP (II1,II2)
      II2=II1
      RETURN
C----------
C RDESTB CALLED FROM ESTAB
C----------
      ENTRY RDESTB (I1,R1)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = I1
      RDANUW = R1(1)
C
      RETURN
C----------
C RDMN1 CALLED FROM MAIN
C----------
      ENTRY RDMN1 (II)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = II
C
      RETURN
C----------
C RDMN2 CALLED FROM GRINCR
C----------
      ENTRY RDMN2 (OLD)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = OLD
C
      RETURN
C----------
C RDPR CALLED FROM MAIN
C----------
      ENTRY RDPR
      RETURN
C----------
C RDTRIP CALLED FROM TRIPLE
C----------
      ENTRY RDTRIP (II1,III2,RR1)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = II1
      IDANUW = III2
      RDANUW = RR1
C
      RETURN
C----------
C RDTDEL CALLED FROM TREDEL
C----------
      ENTRY RDTDEL (II1,II2)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = II1
      IDANUW = II2
C
      RETURN
C----------
C RDKEY CALLED FROM OPLIST
C----------
      ENTRY RDKEY (KEY,KEYWRD)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = KEY
C
      KEYWRD=NORR
      RETURN
C----------
C  RDPPATV - PPE -
C----------
      ENTRY RDPPATV (LDUM)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      LDANUW = LDUM
C
      RETURN

C----------
C  RDPPPT - PPE -
C----------
      ENTRY RDPPPT (WK3,IPNT,ILIMIT)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = WK3
      IDANUW = IPNT
      IDANUW = ILIMIT
C
      RETURN
C----------
C  RDPPGT - PPE -
C----------
      ENTRY RDPPGT (WK3,IPNT,ILIMIT)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = WK3
      IDANUW = IPNT
      IDANUW = ILIMIT
C
      RETURN
C
      END
