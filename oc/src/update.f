      SUBROUTINE UPDATE
      IMPLICIT NONE
C----------
C  **UPDATE DATE OF LAST REVISION:  07/23/08
C $Id: update.f 271 2012-11-14 22:17:42Z jdh $
C $Revision: 271 $
C $Date: 2012-11-14 14:17:42 -0800 (Wed, 14 Nov 2012) $
C $HeadURL: https://www.forestinformatics.com/svn/fvs/trunk/cacor/src/update.f $
C----------
C  UPDATE:
C     ADDS GROWTH INCREMENT
C     DEDUCTS MORTALITY
C     COMPUTES VOLUME STATISTICS
C     EXECUTES SOME OF THE SUMMARY LOGIC.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C
      LOGICAL DEBUG
      REAL SPCMO(MAXSP,3),WKI,BRATIO
      INTEGER I,IS,I1,I2,J,IM
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'UPDATE',6,ICYC)
C---------
C  ZERO OUT MORTALITY ACCUMULATOR ARRAYS
C---------
      DO 5 I=1,7
      OMORT(I)=0.0
    5 CONTINUE
      DO 10 I=1,MAXSP
      SPCMO(I,1)=0.0
      SPCMO(I,2)=0.0
      SPCMO(I,3)=0.0
   10 CONTINUE
C----------
C  DO FOR ALL TREES BY SPECIES.
C----------
      DO 100 IS=1,MAXSP
      I1=ISCT(IS,1)
      IF (I1 .EQ. 0) GO TO 100
      I2=ISCT(IS,2)

      DO 90 J=I1,I2
      I=IND1(J)
C----------
C  ADD THE HEIGHT INCREMENT TO THE HEIGHTS
C----------
      HT(I) = HT(I)+HTG(I)

C----------
C  DEDUCT THE MORTALITY FROM PROB AND PREPARE THE SUMMARY.
C----------

      IM=IMC(I)
      WKI = WK2(I)
      IF (WKI .GT. PROB(I) ) then
        WKI=PROB(I)
      end if
      
C     ASSIGN THE REMOVED VOLUME VARIABLES (WK6) AND 
C     ACCUMULATE THE VALUES IN THE SUMMARY TABLE.
      WK6(I) = WKI*CFV(I)/FINT
      SPCMO(IS,IM)=SPCMO(IS,IM)+WK6(I)

C     REDUCE THE EXPANSION FACTOR OF THE TREE RECORD
      PROB(I) = MAX( 0.0, PROB(I) - WKI )

C      ALSO, UPDATE THE CROWNS TOO.
      ICR(I)=ABS(ICR(I))

C----------
C  END OF TREE WITHIN SPECIES LOOP.
C----------
   90 CONTINUE
      IF(.NOT.DEBUG) GO TO 100

      WRITE(JOSTND,9001)  IS,(SPCMO(IS,J),J=1,3)
 9001 FORMAT(' IN UPDATE,  SPECIES=',I3,
     &       ',  CUM. MORT. VOL. BY TREE CLASS=',3(F8.3,','))
C----------
C  END OF SPECIES LOOP.
C----------
  100 CONTINUE
C----------
C  CALL **PCTILE** TO LOAD WK3 WITH PERCENTILES IN THE DISTRIBUTION
C  OF VOLUME MORTALITY IN DESCENDING ORDER OF DIAMETER.
C----------
      CALL PCTILE(ITRN,IND,WK6,WK3,OMORT(7))
C----------
C  FIND THE PERCENTILE POINTS IN THE DISTRIBUTION OF MORTALITY
C  VOLUME.
C----------
      CALL DIST(ITRN,OMORT,WK3)
C----------
C  COMPUTE SPECIES TREE CLASS COMPOSITION CORRESPONDING TO OMORT.
C----------
      CALL COMP(OSPMO,IOSPMO,SPCMO)
C----------
C  COMPUTE TREE AND STAND VOLUME STATISTICS.
C----------
      IF(DEBUG) WRITE(JOSTND,9017) ICYC
 9017 FORMAT(' CALLING VOLS, CYCLE=',I2)
      CALL VOLS
C----------
C  UPDATE DIAMETERS TO END OF CYCLE VALUES.
C----------
      IF (ITRN.EQ.0) RETURN
      DO 110 I=1,ITRN
      IS=ISP(I)

C     THIS IS THE ORIGINAL CODE
C      DBH(I)=DBH(I)+DG(I)/BRATIO(IS,DBH(I),HT(I))
C     AND THIS IS THE ORGANON DIAMETER INCREMENT CODE.
      DBH(I)=DBH(I)+DG(I)

  110 CONTINUE
      RETURN
      END
