CODE SEGMENT ESTREE
C----------
C  **ESTREE DATE OF LAST REVISION:  06/14/00
C----------
      INTEGER IESTAT(MAXTRE)
      COMMON /ESTREE/ IESTAT
C
C     HOLDS THE YEAR WHEN MORTALITY CAN BEGIN ON TREES REGENERATED
C     IN **ESTAB**; REGEN-SIZE TREES ARE ALSO FLAGGED IN **ESFLTR**
C
C-----END SEGMENT