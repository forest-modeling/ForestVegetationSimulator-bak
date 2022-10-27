      SUBROUTINE STATS
      IMPLICIT NONE
C----------
C METRIC-BASE $Id: stats.f 4010 2022-06-28 22:23:31Z donrobinson $
C----------
C  THIS ROUTINE COMPUTES STATISTICS THAT DESCRIBE THE INPUT
C  DISTRIBUTION OF STAND ATTRIBUTES AMONG SAMPLE PLOTS.  CALLED FROM
C  **MAIN**.  **TVALUE** IS CALLED TO CALCULATE STUDENT'S T FOR
C  CONSTRUCTION OF CONFIDENCE INTERVALS.
C---------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'PLOT.F77' 
C
C
      INCLUDE 'METRIC.F77'
C
C
COMMONS
      CHARACTER*16 LABELS(4)
      CHARACTER*4 SP(MAXSP),SPECCD(MAXSP)      
      REAL TOTCF(MAXSP),SIGLEVEL,
     &   TOTTR(MAXSP),TOTBA(MAXSP),TOTBF(MAXSP),
     &   SUMT(MAXPLT),SUMBA(MAXPLT),SUMCF(MAXPLT),SUMBF(MAXPLT),
     &   ITPA(MAXSP),IBA(MAXSP),IBF(MAXSP),ICF(MAXSP),TPA(MAXSP),
     &   BAREA(MAXSP),BFVOL(MAXSP),CFVOL(MAXSP)
      INTEGER IFLG(MAXSP),I,ISPC,J,IALP,IERR,NDF,ROWS,CNT,IYEAR,K
      REAL P,TBA,TBF,TCF,T,SUM,SUMSQ,ST,XBAR,S,SS,SE,UL,UU,CV
      REAL SEU,SEP,SCF,SBF,SBA,IDIST(8,4)
      EQUIVALENCE (WK3,SUMT),(WK3(MAXPLT+1),SUMBA),
     &            (WK4,SUMCF),(WK4(MAXPLT+1),SUMBF),
     &            (WK5,TOTTR),(WK5(MAXSP+1),TOTBA),
     &            (WK6,TOTCF),(WK6(MAXSP+1),TOTBF)
      DATA LABELS/
     &  'BOARD FEET/HA   ',
     &  'CUBIC METERS/HA ',
     &  'TREES/HA        ',
     &  'BASAL AREA/HA   '/
C----------
C  IF THERE ARE NO TREE RECORDS, OR STATS OPTION WAS NOT REQUESTED,
C  RETURN.
C----------
      IF(.NOT.LSTATS.OR.ITRN.EQ.0) RETURN
C----------
C  INITIALIZE.
C----------
      DO 1 I=1,MAXSP
      TOTTR(I)=0.0
      TOTBA(I)=0.0
      TOTBF(I)=0.0
      TOTCF(I)=0.0
      IFLG(I)=0
      ITPA(I) = 0.0
      IBA(I)  = 0.0
      IBF(I)  = 0.0
      ICF(I)  = 0.0
      TPA(I)  = 0.0
      BAREA(I)= 0.0
      BFVOL(I)= 0.0
      CFVOL(I)= 0.0
    1 CONTINUE
      DO 2 I=1,MAXPLT
      SUMT(I)=0.0
      SUMBA(I)=0.0
      SUMBF(I)=0.0
      SUMCF(I)=0.0
    2 CONTINUE
      DO I=1,8
        DO J=1,4
          IDIST(I,J) = 0.0
        ENDDO
      ENDDO
      SIGLEVEL=0.0
      ROWS  = 0
      CNT   = 0
      IYEAR = 0
C----------
C  ACCUMULATE SUMS FOR OVERALL STATISTICS.
C----------
      DO 30 I=1,ITRN
      ISPC=ISP(I)
      J=ITRE(I)
      P=PROB(I)
      TBA=DBH(I)*DBH(I)*P*0.005454154
      TBF=BFV(I)*P
      TCF=CFV(I)*P
      TOTTR(ISPC)=TOTTR(ISPC)+P
      TOTBA(ISPC)=TOTBA(ISPC)+TBA
      TOTCF(ISPC)=TOTCF(ISPC)+TCF
      TOTBF(ISPC)=TOTBF(ISPC)+TBF
      IFLG(ISPC)=1
      IF(IPTINV.LE.1) GO TO 30
      SUMT(J)=SUMT(J)+IPTINV*P
      SUMBA(J)=SUMBA(J)+IPTINV*TBA
      SUMBF(J)=SUMBF(J)+IPTINV*TBF
      SUMCF(J)=SUMCF(J)+IPTINV*TCF
   30 CONTINUE
      DO 35 ISPC=1,MAXSP
      TOTTR(ISPC)=TOTTR(ISPC)/GROSPC
      TOTBA(ISPC)=TOTBA(ISPC)/GROSPC
      TOTCF(ISPC)=TOTCF(ISPC)/GROSPC
      TOTBF(ISPC)=TOTBF(ISPC)/GROSPC
   35 CONTINUE
C----------
C  WRITE TABLE HEADING FOR GENERAL SPECIES SUMMARY.
C----------
      WRITE(JOSTND,9000)
 9000 FORMAT(/)
      WRITE(JOSTND,9001)
 9001 FORMAT(T9,'GENERAL SPECIES SUMMARY FOR THE CRUISE',
     &' (PER HECTARE)')
      WRITE(JOSTND,9002)
 9002 FORMAT(/2X,'SPECIES',T18,'NMV (CU M)',T31,'GTV (CU M)',
     &        T52,'TREES',T61,'BASAL AREA',/,73('-'))
      ROWS=0
      DO 40 I=1,MAXSP
        IF(IFLG(I).EQ.0) GO TO 40
        ROWS=ROWS+1
        SP(ROWS)=JSP(I)
        ITPA(ROWS)=TOTTR(I)
        IBA(ROWS)=TOTBA(I)
        IBF(ROWS)=TOTBF(I)
        ICF(ROWS)=TOTCF(I)
        WRITE(JOSTND,9003) JSP(I),
     &                NSP(I,1)(1:2),
     &                TOTBF(I)*FT3pACRtoM3pHA,
     &                TOTCF(I)*FT3pACRtoM3pHA,
     &                TOTTR(I)/ACRtoHA,
     &                TOTBA(I)*FT2pACRtoM2pHA
 9003   FORMAT(1X,A4,'=',A4,T18,F10.1,T31,F10.1,T47,F10.1,T61,F10.1)
   40 CONTINUE
      IF(IPTINV.GT.1) GO TO 50
C----------
C  1 POINT.  PRINT ERROR MESSAGE AND GO WRITE SPECIES STATS TO DATABASE.
C----------
      WRITE(JOSTND,9004)
 9004 FORMAT(' DISTRIBUTION OF ATTRIBUTES AMONG SAMPLE POINTS',
     &   ' CANNOT BE COMPUTED WITH ONE SAMPLE POINT.'/)
      GOTO 150
   50 CONTINUE
      WRITE(JOSTND,9005)
 9005 FORMAT(//T19,'DISTRIBUTION OF STAND ATTRIBUTES AMONG SAMPLE'
     &              ,' POINTS'/)
      IALP=INT(100.0-100.0*ALPHA+0.5)
      WRITE(JOSTND,9008)IALP
 9008 FORMAT(T31,'STANDARD  COEFF OF SAMPLE',T67,I4,'%',
     &T83,'SAMPLING ERROR IN')
      WRITE(JOSTND,9006)
 9006 FORMAT(' CHARACTERISTIC',T25,'MEAN DEVIATION VARIATION   SIZE',
     &'     CONFIDENCE  LIMITS    PERCENT     UNITS',/,16('-'),
     &3X,9('-'),1X,9('-'),1X,9('-'),1X,6('-'),1X,22('-'),4X,17('-'))
C----------
C  CALL **TVALUE TO APPROXIMATE 'T' FOR (IPTINV-1) DF AT THE 'ALPHA'
C  PROBABILITY LEVEL.
C----------
      NDF=IPTINV-1
      CALL TVALUE(NDF,ALPHA,T,IERR)
C----------
C  COMPUTE AND PRINT STATISTICS FOR TREES PER HECTARE.
C----------
      SUM=0.0
      SUMSQ=0.0
      DO 60 I=1,IPTINV
      ST=SUMT(I)/GROSPC
      SUM=SUM+ST
      SUMSQ=SUMSQ+ST*ST
   60 CONTINUE
      IF(SUM.GT.0.0) GO TO 65
         WRITE(JOSTND,9007)  LABELS(3),SUM,SUM
 9007 FORMAT(A16,T19,3(1X,F9.2),1X,I6,1X,F9.2,4X,F9.2,
     &4X,F6.1,1X,F10.1)
      GO TO 70
   65 CONTINUE
      XBAR=SUM/PI
      S=0.0
      SS=SUMSQ-SUM*SUM/PI
      IF(SS.LE.0.0) GO TO 67
      S=SQRT(SS/(PI-1.0))
   67 CONTINUE
      SE=S/SQRT(PI)
      UL=XBAR-T*SE
      IF(UL.LT.0.0) UL=0.0
      UU=XBAR+T*SE
      CV=S/XBAR  
      SEU=T*SE
      SEP=SEU*100./XBAR
      WRITE(JOSTND,9007) LABELS(3),
     &                   XBAR /ACRtoHA,
     &                   S    /ACRtoHA,
     &                   CV,
     &                   IPTINV,
     &                   UL   /ACRtoHA,
     &                   UU   /ACRtoHA,
     &                   SEP  /ACRtoHA,
     &                   SEU
       IDIST(1,1)=XBAR /ACRtoHA
       IDIST(2,1)=S    /ACRtoHA
       IDIST(3,1)=CV
       IDIST(4,1)=IPTINV
       IDIST(5,1)=UL   /ACRtoHA
       IDIST(6,1)=UU   /ACRtoHA
       IDIST(7,1)=SEP  /ACRtoHA
       IDIST(8,1)=SEU
   70 CONTINUE
C----------
C  COMPUTE AND PRINT STATISTICS FOR CUBIC METER VOL.
C----------
      SUM=0.0
      SUMSQ=0.0
      DO 80 I=1,IPTINV
      SCF=SUMCF(I)/GROSPC
      SUM=SUM+SCF
      SUMSQ=SUMSQ+SCF*SCF
   80 CONTINUE
      IF(SUM.GT.0.0) GO TO 85 
      WRITE(JOSTND,9007)  LABELS(2),SUM,SUM
      GO TO 90
   85 CONTINUE
      XBAR=SUM/PI
      S=0.0
      SS=SUMSQ-SUM*SUM/PI
      IF(SS.LE.0.0) GO TO 87
      S=SQRT(SS/(PI-1.0))
   87 CONTINUE
      SE=S/SQRT(PI)
      UL=XBAR-T*SE
      IF(UL.LT.0.0) UL=0.0
      UU=XBAR+T*SE
      CV=S/XBAR
      SEU=T*SE
      SEP=SEU*100./XBAR
      WRITE(JOSTND,9007) LABELS(2),
     &                   XBAR *FT3pACRtoM3pHA,
     &                   S    *FT3pACRtoM3pHA,
     &                   CV,
     &                   IPTINV,
     &                   UL   *FT3pACRtoM3pHA,
     &                   UU   *FT3pACRtoM3pHA,
     &                   SEP  *FT3pACRtoM3pHA,
     &                   SEU
       IDIST(1,2)=XBAR *FT3pACRtoM3pHA
       IDIST(2,2)=S    *FT3pACRtoM3pHA
       IDIST(3,2)=CV
       IDIST(4,2)=IPTINV
       IDIST(5,2)=UL   *FT3pACRtoM3pHA
       IDIST(6,2)=UU   *FT3pACRtoM3pHA
       IDIST(7,2)=SEP  *FT3pACRtoM3pHA
       IDIST(8,2)=SEU
   90 CONTINUE
C----------
C  COMPUTE AND PRINT STATISTICS FOR BOARD FOOT VOLUME (IF NOT METRIC).
C----------
      SUM=0.0
      SUMSQ=0.0
      DO 100 I=1,IPTINV
      SBF=SUMBF(I)/GROSPC
      SUM=SUM+SBF
      SUMSQ=SUMSQ+SBF*SBF
  100 CONTINUE
      IF(SUM.GT.0.0) GO TO 105
      WRITE(JOSTND,9007)  LABELS(1),SUM,SUM
      GO TO 110
  105 CONTINUE
      XBAR=SUM/PI
      S=0.0
      SS=SUMSQ-SUM*SUM/PI
      IF(SS.LE.0.0) GO TO 107
      S=SQRT(SS/(PI-1.0))
  107 CONTINUE
      SE=S/SQRT(PI)
      UL=XBAR-T*SE
      IF(UL.LT.0.0) UL=0.0
      UU=XBAR+T*SE
      CV=S/XBAR
      SEU=T*SE
      SEP=SEU*100./XBAR
      WRITE(JOSTND,9007) LABELS(1),
     &                   XBAR *0.,
     &                   S    *0.,
     &                   CV   *0.,
     &                   IPTINV,
     &                   UL   *0.,
     &                   UU   *0.,
     &                   SEP  *0.,
     &                   SEU  *0.
       IDIST(1,3)=XBAR *0.
       IDIST(2,3)=S    *0.
       IDIST(3,3)=CV   *0.
       IDIST(4,3)=IPTINV
       IDIST(5,3)=UL   *0.
       IDIST(6,3)=UU   *0.
       IDIST(7,3)=SEP  *0.
       IDIST(8,3)=SEU  *0.
  110 CONTINUE
C----------
C  COMPUTE AND PRINT STATISTICS FOR BASAL AREA PER HECTARE.
C----------
      SUM=0.0
      SUMSQ=0.0
      DO 120 I=1,IPTINV
      SBA=SUMBA(I)/GROSPC
      SUM=SUM+SBA
      SUMSQ=SUMSQ+SBA*SBA
  120 CONTINUE
      IF(SUM.GT.0.0) GO TO 130
      WRITE(JOSTND,9007) LABELS(4),SUM,SUM
      RETURN
  130 CONTINUE
      XBAR=SUM/PI
      S=0.0
      SS=SUMSQ-SUM*SUM/PI
      IF(SS.LE.0.0) GO TO 137
      S=SQRT(SS/(PI-1.0))
  137 CONTINUE
      SE=S/SQRT(PI)
      UL=XBAR-T*SE
      IF(UL.LT.0.0) UL=0.0
      UU=XBAR+T*SE
      CV=S/XBAR
      SEU=T*SE
      SEP=SEU*100./XBAR
      WRITE(JOSTND,9007) LABELS(4),
     &                   XBAR *FT2pACRtoM2pHA,
     &                   S    *FT2pACRtoM2pHA,
     &                   CV,
     &                   IPTINV,
     &                   UL   *FT2pACRtoM2pHA,
     &                   UU   *FT2pACRtoM2pHA,
     &                   SEP  *FT2pACRtoM2pHA,
     &                   SEU
       IDIST(1,4)=XBAR *FT2pACRtoM2pHA
       IDIST(2,4)=S    *FT2pACRtoM2pHA
       IDIST(3,4)=CV
       IDIST(4,4)=IPTINV
       IDIST(5,4)=UL   *FT2pACRtoM2pHA
       IDIST(6,4)=UU   *FT2pACRtoM2pHA
       IDIST(7,4)=SEP  *FT2pACRtoM2pHA
       IDIST(8,4)=SEU
       
       SIGLEVEL=(1-ALPHA)*100        
C----------
C  POPULATE ARRAYS WITH NON-ZERO VALUES
C----------
  150 CNT=0
      DO I=1,MAXSP
         CNT=CNT+1
         SPECCD(CNT)=SP(I)
         TPA(CNT)=ITPA(I)/ACRtoHA
         BAREA(CNT)=IBA(I)*FT2pACRtoM2pHA 
         BFVOL(CNT)=IBF(I)*0. 
         CFVOL(CNT)=ICF(I)*FT3pACRtoM3pHA
      ENDDO   
      IYEAR=IY(1)
C
C     CALL DBSSTATS FOR POPULATING THE DATABASE WITH CRUISE STATISTICS
C
C     DATABASE OUTPUT FOR STAND (REQUIRES MULTIPLE SAMPLE POINTS)
C
      IF(IPTINV.EQ.1) GO TO 160
      K=3
      DO I=1,3
      CALL DBSSTATS(SP(I),TPA(I),BAREA(I),CFVOL(I),
     &   BFVOL(I),IDIST(1,I),IDIST(2,I),IDIST(3,I),
     &   IDIST(4,I),SIGLEVEL,IDIST(5,I),IDIST(6,I),IDIST(7,I),
     &   IDIST(8,I),LABELS(K),2,IYEAR)
      K=K-1
      ENDDO
      CALL DBSSTATS(SP(I),TPA(I),BAREA(I),CFVOL(I),
     &   BFVOL(I),IDIST(1,I),IDIST(2,I),IDIST(3,I),
     &   IDIST(4,I),SIGLEVEL,IDIST(5,I),IDIST(6,I),IDIST(7,I),
     &   IDIST(8,I),LABELS(4),2,IYEAR)

C     DATABASE OUPUT FOR GENERAL SPECIES SUMMARY
C
  160   DO I=1,ROWS
        CALL DBSSTATS(SP(I),TPA(I),BAREA(I),CFVOL(I),
     &   BFVOL(I),IDIST(1,I),IDIST(2,I),IDIST(3,I),
     &   IDIST(4,I),SIGLEVEL,IDIST(5,I),IDIST(6,I),IDIST(7,I),
     &   IDIST(8,I),LABELS(I),1,IYEAR)
        ENDDO
C
      RETURN
      END
