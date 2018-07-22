      SUBROUTINE SICHG(ISISP,SSITE,SIAGE)
      IMPLICIT NONE
C----------
C WS $Id$
C----------
C THIS ROUTINE TAKES THE SITE INFORMATION AND CALCULATES AN AGE FOR
C THAT CURVE, GIVEN THE SITE, WHERE A NEW HT (OR PROXY AGE) MAY ME
C LOOKED UP.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
COMMONS
C----------
      CHARACTER*1 ISILOC,REFLOC(MAXSP)
      INTEGER DIFF,REFAGE(MAXSP)
      INTEGER I,ISISP
      REAL A(MAXSP),B(MAXSP),SIAGE(MAXSP)
      REAL SSITE,AGE2BH
C----------
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C
C     1 = SUGAR PINE (SP)                   PINUS LAMBERTIANA
C     2 = DOUGLAS-FIR (DF)                  PSEUDOTSUGA MENZIESII
C     3 = WHITE FIR (WF)                    ABIES CONCOLOR
C     4 = GIANT SEQUOIA (GS)                SEQUOIADENDRON GIGANTEAUM
C     5 = INCENSE CEDAR (IC)                LIBOCEDRUS DECURRENS
C     6 = JEFFREY PINE (JP)                 PINUS JEFFREYI
C     7 = CALIFORNIA RED FIR (RF)           ABIES MAGNIFICA
C     8 = PONDEROSA PINE (PP)               PINUS PONDEROSA
C     9 = LODGEPOLE PINE (LP)               PINUS CONTORTA
C    10 = WHITEBARK PINE (WB)               PINUS ALBICAULIS
C    11 = WESTERN WHITE PINE (WP)           PINUS MONTICOLA
C    12 = SINGLELEAF PINYON (PM)            PINUS MONOPHYLLA
C    13 = PACIFIC SILVER FIR (SF)           ABIES AMABILIS
C    14 = KNOBCONE PINE (KP)                PINUS ATTENUATA
C    15 = FOXTAIL PINE (FP)                 PINUS BALFOURIANA
C    16 = COULTER PINE (CP)                 PINUS COULTERI
C    17 = LIMBER PINE (LM)                  PINUS FLEXILIS
C    18 = MONTEREY PINE (MP)                PINUS RADIATA
C    19 = GRAY PINE (GP)                    PINUS SABINIANA
C         (OR CALIFORNIA FOOTHILL PINE)
C    20 = WASHOE PINE (WE)                  PINUS WASHOENSIS
C    21 = GREAT BASIN BRISTLECONE PINE (GB) PINUS LONGAEVA
C    22 = BIGCONE DOUGLAS-FIR (BD)          PSEUDOTSUGA MACROCARPA
C    23 = REDWOOD (RW)                      SEQUOIA SEMPERVIRENS
C    24 = MOUNTAIN HEMLOCK (MH)             TSUGA MERTENSIANA
C    25 = WESTERN JUNIPER (WJ)              JUNIPERUS OCIDENTALIS
C    26 = UTAH JUNIPER (UJ)                 JUNIPERUS OSTEOSPERMA
C    27 = CALIFORNIA JUNIPER (CJ)           JUNIPERUS CALIFORNICA
C    28 = CALIFORNIA LIVE OAK (LO)          QUERCUS AGRIFOLIA
C    29 = CANYON LIVE OAK (CY)              QUERCUS CHRYSOLEPSIS
C    30 = BLUE OAK (BL)                     QUERCUS DOUGLASII
C    31 = CALIFORNIA BLACK OAK (BO)         QUERQUS KELLOGGII
C    32 = VALLEY OAK (VO)                   QUERCUS LOBATA
C         (OR CALIFORNIA WHITE OAK)
C    33 = INTERIOR LIVE OAK (IO)            QUERCUS WISLIZENI
C    34 = TANOAK (TO)                       LITHOCARPUS DENSIFLORUS
C    35 = GIANT CHINQUAPIN (GC)             CHRYSOLEPIS CHRYSOPHYLLA
C    36 = QUAKING ASPEN (AS)                POPULUS TREMULOIDES
C    37 = CALIFORNIA-LAUREL (CL)            UMBELLULARIA CALIFORNICA
C    38 = PACIFIC MADRONE (MA)              ARBUTUS MENZIESII
C    39 = PACIFIC DOGWOOD (DG)              CORNUS NUTTALLII
C    40 = BIGLEAF MAPLE (BM)                ACER MACROPHYLLUM
C    41 = CURLLEAF MOUNTAIN-MAHOGANY (MC)   CERCOCARPUS LEDIFOLIUS
C    42 = OTHER SOFTWOODS (OS)
C    43 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH) 
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE), 
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C      ALEXANDER 1967 RM32 USED AS A SITE REFERENCE; COEFFICIENTS WERE
C      COPIED FROM THE SO VARIANT SPECIES 8=ES FOR THIS ROUTINE AND
C      **HTCALC**.
C----------
C  DATA STATEMENTS
C----------
      DATA A/
     &    10.83,    13.27,    22.67,   29.286,    22.67, 
     &   18.667,     25.0,   13.789,     10.0,     10.0, 
     &    10.83,     10.0,    22.67,     10.0,     10.0, 
     &     10.0,     10.0,   13.789,     10.0,     10.0, 
     & 33.72545,    13.27,   29.286,    10.83,     10.0, 
     &     10.0,     10.0,   10.976,   10.976,   10.976, 
     &   10.976,   10.976,   10.976,   19.763,   19.763, 
     &   19.763,   19.763,   19.763,   19.763,   10.976, 
     & 11.56252,    13.92,   10.976/ 
C
      DATA B/
     &    -0.10,    -0.04,    -0.17,   -0.071,    -0.17, 
     &   -0.100,   -0.125,   -0.050,      0.0,      0.0, 
     &    -0.10,      0.0,    -0.17,      0.0,      0.0, 
     &      0.0,      0.0,   -0.050,      0.0,      0.0, 
     &-0.274509,    -0.04,   -0.071,    -0.10,      0.0, 
     &      0.0,      0.0,   -0.071,   -0.071,   -0.071, 
     &   -0.071,   -0.071,   -0.071,   -0.080,   -0.080, 
     &   -0.080,   -0.080,   -0.080,   -0.080,   -0.071, 
     & -0.05586,    -0.13,   -0.071/ 
C
      DATA REFLOC/
     &      'T',      'T',      'T',      'T',      'T', 
     &      'T',      'B',      'T',      'T',      'T', 
     &      'T',      'T',      'T',      'T',      'T', 
     &      'T',      'T',      'T',      'T',      'T', 
     &      'B',      'T',      'T',      'T',      'T', 
     &      'T',      'T',      'B',      'B',      'B', 
     &      'B',      'B',      'B',      'B',      'B', 
     &      'B',      'B',      'B',      'B',      'B', 
     &      'B',      'T',      'B'/ 
C
      DATA REFAGE/
     &       50,       50,       50,       50,       50, 
     &       50,       50,       50,       50,       50, 
     &       50,       50,       50,       50,       50, 
     &       50,       50,       50,       50,       50, 
     &      100,       50,       50,       50,       50, 
     &       50,       50,       50,       50,       50, 
     &       50,       50,       50,       50,       50, 
     &       50,       50,       50,       50,       50, 
     &      100,       50,       50/ 
C----------
C ISILOC IS THE PLACE WHERE THE AGE FOR THE SITE IS TAKEN
C----------
      ISILOC = REFLOC(ISISP)
      DO 100 I = 1,MAXSP
C----------
C  SET UP THE ARRAY TO TELL WHETHER YOU NEED TO SLIDE UP OR DOWN THE SIT
C LINE TO ADJUST FOR TOTAL AGE OR BREAST HIGH AGE
C----------
      IF(ISILOC .EQ. 'T' .AND. REFLOC(I) .EQ. 'B')DIFF=-1
      IF(ISILOC .EQ. REFLOC(I))DIFF=0
      IF(ISILOC .EQ. 'B' .AND. REFLOC(I) .EQ. 'T')DIFF=1
      AGE2BH=0.0
      IF(DIFF .LT. 0 .OR. DIFF .GT. 0) AGE2BH= A(I) + B(I)*SSITE
      SIAGE(I) = REFAGE(I) + AGE2BH*DIFF
  100 CONTINUE
C
      RETURN
      END
