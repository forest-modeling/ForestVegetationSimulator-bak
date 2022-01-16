      SUBROUTINE PTGRP (IPLTNO,IVAR,ICODE,BELOW,ABOVE)
      IMPLICIT NONE
C----------
C LPMPB $Id$
C----------
C
C     ROUTINE TO SPECIFY GROUP OF VALUES TO BE PLOTTED ON
C     SAME SCALE, AND WHICH BOUNDS NEED TO BE CALCULATED.
C
C     ICODE-- 00  NO BOUNDS SPECIFIED, SET BOTH
C             11  BOTH BOUNDS SPECIFIED, SET NEITHER
C             10  LOWER BOUND SPECIFIED, SET UPPER
C             01  UPPER BOUND SPECIFIED, SET LOWER
C
C Revision History
C   02/08/88 Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C     Added IMPLICIT NONE.
C----------
COMMONS
C
C
      INCLUDE 'PT.F77'
C
C
COMMONS

      REAL ABOVE, BELOW 
      INTEGER ICODE, IPLTNO, IV, IVAR 

      IPTVAR(IPLTNO)=IPTVAR(IPLTNO)+IVAR
      IF (IPTVAR(IPLTNO) .GT. 10) IPTVAR(IPLTNO) = 10
      IV=IPTVAR(IPLTNO)
      IPTCOD(IPLTNO,IV)=ICODE
      PTL(IPLTNO,IV)=BELOW
      PTU(IPLTNO,IV)=ABOVE
C
      RETURN
      END
