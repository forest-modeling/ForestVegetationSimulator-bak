      BLOCK DATA CUBRDS
      IMPLICIT NONE
C----------
C  **CUBRDS--CR   DATE OF LAST REVISION:  06/16/09
C----------
C  DEFAULT PARAMETERS FOR THE CUBIC AND BOARD FOOT VOLUME EQUATIONS.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
C  SPECIES ORDER:
C   1=AF,  2=CB,  3=DF,  4=GF,  5=WF,  6=MH,  7=RC,  8=WL,  9=BC, 10=LM,
C  11=LP, 12=PI, 13=PP, 14=WB, 15=SW, 16=UJ, 17=BS, 18=ES, 19=WS, 20=AS,
C  21=NC, 22=PW, 23=GO, 24=AW, 25=EM, 26=BK, 27=SO, 28=PB, 29=AJ, 30=RM,
C  31=OJ, 32=ER, 33=PM, 34=PD, 35=AZ, 36=CI, 37=OS, 38=OH
C
C  SPECIES EXPANSION:
C  UJ,AJ,RM,OJ,ER USE CR JU                              
C  NC,PW USE CR CO
C  GO,AW,EM,BK,SO USE CR OA                             
C  PB USES CR AS                              
C  PM,PD,AZ USE CR PI
C  CI USES CR PP                              
C----------
C  COEFFICIENTS FOR CUBIC FOOT VOLUME FOR TREES THAT ARE SMALLER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, EACH ROW HAS 7 COEFFS.
C----------
      DATA CFVEQS/ 266*0.0 /
C----------
C  COEFFICIENTS FOR CUBIC FOOT VOLUME FOR TREES THAT ARE LARGER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, EACH ROW HAS 7 COEFFS.
C----------
      DATA CFVEQL/ 266*0.0 /
C----------
C  FLAG IDENTIFYING THE SIZE TRANSITION VARIABLE; 0=D, 1=D2H
C  1 PER SPECIES.
C----------
      DATA ICTRAN/ 38*0 /
C----------
C  TRANSITION SIZE.  TREES OF LARGER SIZE (D OR D2H) WILL COEFFICIENTS
C  FOR LARGER SIZE TREES.  1 PER SPECIES.
C----------
      DATA CTRAN/ 38*0.0 /
C----------
C  COEFFICIENTS FOR BOARD FOOT VOLUME FOR TREES THAT ARE SMALLER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, 7 COEFFS PER ROW.
C----------
      DATA BFVEQS/ 266*0.0 /
C----------
C  COEFFICIENTS FOR BOARD FOOT VOLUME FOR TREES THAT ARE LARGER THAN
C  THE TRANSITION SIZE. 1 ROW PER SPECIES, 7 COEFFS PER ROW.
C----------
      DATA BFVEQL/ 266*0.0 /
C----------
C  FLAG IDENTIFYING THE SIZE TRANSITION VARIABLE; 0=D, 1=D2H
C  1 PER SPECIES.
C----------
      DATA IBTRAN/ 38*0 /
C----------
C  TRANSITION SIZE.  TREES OF LARGER SIZE (D OR D2H) WILL USE
C  COEFFICIENTS FOR LARGER SIZE TREES.  1 PER SPECIES.
C----------
      DATA BTRAN/ 38*0.0 /
      END
