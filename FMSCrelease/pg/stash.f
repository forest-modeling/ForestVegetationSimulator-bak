      SUBROUTINE STASH (BUFFER,ILIMIT)
      IMPLICIT NONE
C----------
C PG $Id$
C----------
C
C     STASH A BUFFER FULL OF DATA
C
C     BUFFER= BUFFER FULL OF DATA TO BE STASHED.
C     ILIMIT= LENGTH OF THE BUFFER.
C
COMMONS
C
C
      INCLUDE 'GLBLCNTL.F77'
C
C
COMMONS
C
C
      INTEGER ILIMIT
      REAL BUFFER (ILIMIT)
      WRITE (JSTASH) BUFFER
      RETURN
      END

      SUBROUTINE CHSTSH (CBUFF,LNCBUF)
      IMPLICIT NONE
C
C     STASH A BUFFER FULL OF DATA
C
C     CBUFF= A CHAR BUFFER FULL OF DATA TO BE STASHED
C     ILIMIT= LENGTH OF THE BUFFER.
C
COMMONS
C
C
      INCLUDE 'GLBLCNTL.F77'
C
C
COMMONS
C
C
      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      WRITE (JSTASH) CBUFF
      RETURN
      END


      SUBROUTINE DSTASH (BUFFER,IPNT)
      IMPLICIT NONE
C
C     GET DATA STASHED WITH STASH.
C
COMMONS
C
C
      INCLUDE 'GLBLCNTL.F77'
C
C
COMMONS
C
C
      INTEGER IPNT,ISIZE
      REAL BUFFER (IPNT)
      IF (seekReadPos.gt.0) then
        INQUIRE (UNIT=JDSTASH,SIZE=ISIZE)
        IF (seekReadPos .gt. isize) GOTO 10
        READ (JDSTASH,ERR=10,POS=seekReadPos) BUFFER
        seekReadPos = -1
      ELSE
        READ (JDSTASH,END=10,ERR=10) BUFFER
      ENDIF
      RETURN
   10 CONTINUE
      call fvsSetRtnCode(2) ! signal end of file
      RETURN
      END


      SUBROUTINE CHDSTH (CBUFF,IPNT)
      IMPLICIT NONE
C
C     GET A BUFFER FULL OF DATA
C
C     CBUFF= A CHAR BUFFER FULL OF DATA FETCHED
C     IPNT= LENGTH OF THE BUFFER.
C
COMMONS
C
C
      INCLUDE 'GLBLCNTL.F77'
C
C
COMMONS
C
C
      INTEGER IPNT
      CHARACTER CBUFF(IPNT)
      READ (JDSTASH,END=10,ERR=10) CBUFF
      RETURN
   10 CONTINUE
      call fvsSetRtnCode(2) ! signal end of file
      RETURN
      END



