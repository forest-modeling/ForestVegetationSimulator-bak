      SUBROUTINE FVS(IRTNCD)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     THE PROGNOSIS MODEL FOR STAND DEVELOPMENT
C
C     DEVELOPED UNDER THE LEADERSHIP OF:
C
C     DR. ALBERT R. STAGE
C     FORESTRY SCIENCES LABORATORY
C     INTERMOUNTAIN FOREST AND RANGE EXPERIMENT STATION
C     USDA  --  FOREST SERVICE
C     1221 SOUTH MAIN
C     MOSCOW, IDAHO   83843    --    USA.
C
C     PHONE (208) 882-3557
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
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'ECON.F77'
C
C
      INCLUDE 'WORKCM.F77'
C
C
COMMONS
C

!DEC$ ATTRIBUTES DLLEXPORT, C, DECORATE, ALIAS : "FVS" :: FVS
!DEC$ ATTRIBUTES REFERENCE :: IRTNCD

      INTEGER I,IA,N,K,NTODO,ITODO,IACTK,IDAT,NP
      REAL STAGEA,STAGEB
      LOGICAL DEBUG,LCVGO
      INTEGER IBA
      CHARACTER*150 SYSCMD
      INTEGER MYACT(1)
      REAL PRM(1)
      DATA MYACT/100/
      INTEGER IRSTRTCD,ISTOPDONE,IRTNCD,lenCl
C
C     ******************     EXECUTION BEGINS     ******************
C
      DEBUG=.FALSE.
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C  NEEDED FOR STOP/RESTART DEBUG OPTION TO CONTINUE.
C-----------
      CALL DBCHK (DEBUG,'MAIN',4,0)

C     Check the current return code, if -1 the cmdLine has never been processed.

      call fvsGetRtnCode(IRTNCD)
      if (IRTNCD == -1) then
        lenCl = 0
        CALL fvsSetCmdLine(' ',lenCl,IRTNCD)
        IF (IRTNCD.NE.0) RETURN
      endif

C     FIND THE RESTART, AND BRANCH AS REQUIRED

      call fvsRestart (IRSTRTCD)
      call fvsGetRtnCode(IRTNCD)
      IF (DEBUG) WRITE(JOSTND,*) "In FVS, IRSTRTCD=",IRSTRTCD,
     >                           " IRTNCD=",IRTNCD
      if (IRTNCD.ne.0) return
      if (IRSTRTCD.lt.0) return
      if (IRSTRTCD.ge.1) goto 41
C
      ICL1=0
      LSTART = .TRUE.
      LFLAG = .TRUE.
      ICYC=0
C
C     INITIATE THE PROGNOSIS
C
      CALL INITRE
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'MAIN',4,0)
C
C     PROCESS ARRAY IY
C
      IF (NCYC.LE.0)  NCYC=1
      IF (NCYC.GT.MAXCYC) NCYC=MAXCYC
      DO I = 2, MAXCY1
         IF (IY(I).EQ.-1) IY(I)=10
         IY(I) = IY(I-1) + IY(I)
      ENDDO
C
C     ADD IN CYCLES FOR REQUESTED YEARS...BUT DON'T EXTEND THE END
C     OR CHANGE THE BEGINNING OF THE SIMULATION.
C
      IF (IWORK1(1).GT.0) THEN
        DO IA=2,IWORK1(1)+1
          IF (IWORK1(IA).LE.IY(1).OR.IWORK1(IA).GE.IY(NCYC+1)) THEN
            CYCLE
          ELSE
            N=NCYC
            DO I=1,N
              IF (IWORK1(IA).GT.IY(I).AND.IWORK1(IA).LT.IY(I+1)) THEN
                NCYC=NCYC+1
                IF (NCYC.GT.MAXCYC) NCYC=MAXCYC
                DO K=NCYC+1,I+2,-1
                  IY(K)=IY(K-1)
                ENDDO
                IY(I+1)=IWORK1(IA)
                EXIT
              ENDIF
            ENDDO
          ENDIF
        ENDDO
      ENDIF
C
C     WRITE BUG MODEL HEADERS AND WRITE AND PROCESS OPTION LISTS
C     THE CALL TO TMOPTS MUST BE PLACED BEFORE CALL OPEXPN AS TMOPTS
C     CALLS SCHED WHICH CHANGES THE CONTENTS OF THE ARRAY IY.
C
      CALL MPBOPS
      CALL TMOPS
      CALL DFBSCH
C
C     SET UP ECON COST & REVENUE INDEXES BY SPECIES
C     CALL ECSETP PRIOR TO PROCESSING ACTIVITY SCHEDULE TO ENSURE CORRECT ECON ACTIVITY SORTING
C
      CALL ECSETP(IY)
C
C     PROCESS AND LIST THE ACTIVITY SCHEDULE.
C
      CALL OPEXPN (JOSTND,NCYC,IY)
      CALL OPCYCL (NCYC,IY)
      IF(ITABLE(4).EQ.0)CALL OPLIST (.TRUE.,NPLT,MGMID,ITITLE)
C
C     SET UP INDEX POINTERS TO SPECIES SORT.
C
      CALL SETUP
C
C     CALCULATE TREES/ACRE ( = LOAD PROB )
C
      CALL NOTRE
C
C     WESTERN ROOT DISEASE MODEL VER. 3.0 INITIALIZATION
C
      CALL RDMN1 (1)
C
C     COMPUTE DEAD LPP/ACRE.
C
      CALL MPSDLP
C
C     COMPUTE DEAD DFB/ACRE.
C
      CALL DFBINV

      ICYC = 1
C
C     SET THE OPTION POINTERS FOR THE INITIALIZATION PHASE TO
C     THE CYCLE-1 OPTIONS.
C
      CALL OPCSET(ICYC)
C
C     CALIBRATE GROWTH FUNCTIONS AND FILL GAPS
C     SDICLS IS CALLED HERE SO CROWNS WILL DUB CORRECTLY IN VARIANTS
C     USING THE WEIBULL DISTRIBUTION
C
      CALL CRATET
      CALL SDICLS(0,0.,999.,1,SDIAC,SDIAC2,STAGEA,STAGEB,0)
C
C     SET CALIBRATION AND FLAG BEST TREE RECORDS FOR ESTAB. MODEL.
C
      CALL ESFLTR
C
      ICYC = 0
C
C     COMPUTE INITIAL CROWN WIDTH VALUES.
C
      CALL CWIDTH
C
C     COMPUTE INITIAL VOLUME STATISTICS
C
      CALL VOLS
C
C     COMPUTE INITIAL PERCENTILE POINTS IN THE DISTRIBUTION OF
C     DIAMETERS FOR ALL VOLUME STANDARDS.  FIRST CONVERT VOLUMES TO A
C     PER ACRE REPRESENTATION (SKIP IF THERE ARE NO TREE RECORDS).
C
      IF (ITRN.LE.0) GOTO 25
      DO 20 I=1,ITRN
      CFV(I)=CFV(I)*PROB(I)
      BFV(I)=BFV(I)*PROB(I)
      WK1(I)=WK1(I)*PROB(I)
   20 CONTINUE
   25 CONTINUE
      CALL PCTILE(ITRN,IND,CFV,WK3,OCVCUR(7))
      CALL DIST(ITRN,OCVCUR,WK3)
      CALL PCTILE(ITRN,IND,BFV,WK3,OBFCUR(7))
      CALL DIST(ITRN,OBFCUR,WK3)
      CALL PCTILE(ITRN,IND,WK1,WK3,OMCCUR(7))
      CALL DIST(ITRN,OMCCUR,WK3)
C
C     IF THERE ARE TREE RECORDS, THEN: CONVERT CFV TO A PER TREE
C     REPRESENTATION.
C
      IF (ITRN.LE.0) GOTO 35
      DO 30 I=1,ITRN
      CFV(I)=CFV(I)/PROB(I)
      BFV(I)=BFV(I)/PROB(I)
      WK1(I)=WK1(I)/PROB(I)
   30 CONTINUE
   35 CONTINUE
C
C     ASSIGN THE EXAMPLE TREES TO THE OUTPUT ARRAYS.
C
      CALL EXTREE
C
C     FIND OUT IF THE COVER MODEL WILL BE CALLED.
C
      CALL CVGO (LCVGO)
C
C     CALL **CVBROW** TO COMPUTE SHRUB DENSITY AND WILDLIFE
C     BROWSE STATISTICS (MAKE THIS CALL REGARDLESS OF LCVGO).
C
      IF(DEBUG) WRITE(JOSTND,9000) ICYC
 9000 FORMAT(' CALLING CVBROW, CYCLE=',I2)
      CALL CVBROW (.FALSE.)
C
C     CALL **CVCNOP** TO COMPUTE CANOPY COVER STATISTICS.
C
      IF (DEBUG) WRITE (JOSTND,8005) ICYC
 8005 FORMAT (' CALLING CVCNOP, CYCLE =',I2)
      CALL CVCNOP (.FALSE.)
C
C     CALL **STATS** TO COMPUTE STATISTICAL DESCRIPTION OF INPUT DATA.
C
      IF(DEBUG) WRITE(JOSTND,9005) ICYC
 9005 FORMAT(' CALLING STATS, CYCLE = ',I2)
      CALL STATS
C
C     WRITE OUTPUT HEADING FOR STAND COMP TABLE IF NOT TO BE SUPPRESSED
C     USING DELOTAB KEYWORD.
C
      IF (ITABLE(1) .EQ. 0) CALL GHEADS (NPLT,MGMID,JOSTND,0,ITITLE)
C
C     WRITE INITIAL STAND STATISTICS.  MAKE SURE THAT ICL6 IS POSITIVE
C
      ICL6=1
      CALL DISPLY
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     IF TREE LIST OUTPUT IS REQUESTED...CALL TREE LIST PRINTER.
C
      CALL MISPRT
      CALL PRTRLS (1)
C
C     CREATE THE INITIAL STAND VISULIZATION.
C
      CALL SVSTART
C
C     LOAD OLD VOLUME VARIABLES WITH CYCLE 0 VOLUMES
C
      CALL FVSSTD (1)
C
C     IF NAT CRUISE OUTPUT IS REQUESTED ... CALL NATCRZ PRINTER.
C
      CALL NATCRZ (1)
C
C     DONE WITH DEAD TREES THAT WERE PRESENT IN THE INVENTORY. PURGE
C     THEM FROM THE LIST (VIA RESET POINTER)
C
      IREC2=MAXTP1
C
C     WESTERN ROOT DISEASE MODEL VER. 3.0 MODEL INITIALIZATION
C
      CALL RDMN1 (2)
      CALL RDPR
C
C     BLISTER RUST MODEL INITIALIZATION
C
      CALL BRSETP
      CALL BRPR
C
      LFLAG=.FALSE.
      LSTART = .FALSE.
C
C     INITIALIZE TYPE 1 EVENT MONTITOR VARIABLES
C
      CALL EVTSTV(-1)
C
C     PROJECT THE TREE GROWTH AND PRINT STATISTICS
C
   40 CONTINUE
C
C     ADVANCE TIME INCREMENT
C
      ICYC = ICYC + 1

   41 CONTINUE
C
C     SIMULATE HARVEST (THINNINGS), GROWTH, MORTALITY, AND
C     ESTABLISHMENT.
C
      IF (DEBUG) WRITE (JOSTND,50) ICYC
   50 FORMAT (/,' CALLING TREGRO, CYCLE = ',I4)
      CALL TREGRO
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
      CALL getAmStopping (ISTOPDONE)
      IF (ISTOPDONE.NE.0) RETURN
C
C     ASSIGN THE EXAMPLE TREES TO THE OUTPUT ARRAYS.
C
      CALL EXTREE
C
C     WRITE STAND STATISTICS
C
      IF (DEBUG) WRITE (JOSTND,70) ICYC
   70 FORMAT (/,' CALLING DISPLY, CYCLE = ',I4)
      CALL DISPLY
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
C
C     CALL RESAGE TO RESET STAND AGE.
C
      CALL RESAGE
C
C     DWARF MISTLETOE MODEL OUTPUT
C
      CALL MISPRT
C
C     WESTERN ROOT DISEASE MODEL VER. 3.0 OUTPUT
C
      CALL RDPR
C
C     BLISTER RUST MODEL OUTPUT
C
      CALL BRPR
C
C     IF TREE LIST OUTPUT IS REQUESTED...CALL TREE LIST PRINTER.
C
      CALL PRTRLS (1)
C
C     IF RUNNING FVSSTAND POST-PROCESSOR, CALL FILE PRINTER.
C
      CALL FVSSTD (1)
C
C     IF NAT CRUISE OUTPUT IS REQUESTED ... CALL NATCRZ PRINTER.
C
      CALL NATCRZ (1)
C
C     FIND AND RUN ANY SCHEDULED SYSTEM CALLS.
C
      CALL OPFIND (1,MYACT,NTODO)
      IF (NTODO.GT.0) THEN
         DO ITODO=1,NTODO
            CALL OPGET(ITODO,1,IDAT,IACTK,NP,PRM)
            IF (IACTK.EQ.MYACT(1)) THEN
               CALL OPGETC (ITODO,SYSCMD)
               CALL OPDONE (ITODO,IY(ICYC+1)-1)
               IF (SYSCMD.NE.' ') CALL SYSTEM(SYSCMD)
            ENDIF
         ENDDO
      ENDIF
C
      IF ( ICYC .LT. NCYC ) THEN
        CALL ClearRestartCode
        GOTO 40
      ENDIF

C     signal that stopping for this stand can not continue.

      call fvsStopPoint (-1,ISTOPDONE)
C
C     PROJECTION COMPLETED.  SET ICL6 NEGATIVE, SAVE DENSITIES
C     FOR PRINTING, AND CALL DISPLY.
C
      ICYC=ICYC+1
      ICL6=-99
      ONTREM(7)=0.0
      OLDTPA=TPROB
      OLDBA=BA
      OLDAVH=AVH
      ORMSQD=RMSQD
      RELDM1=RELDEN
      CALL SDICLS(0,0.,999.,1,SDIBC,SDIBC2,STAGEA,STAGEB,0)
      SDIAC=SDIBC
      SDIAC2=SDIBC2
C
      CALL DISPLY
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      IBA = 1
      CALL SSTAGE(IBA,ICYC,.FALSE.)
C
C     PRINT THE VISULIZATION FOR FINAL OUTPUT.
C
      CALL SVOUT(IY(ICYC),3,'End of projection')
      LFLAG=.TRUE.
      CALL ESOUT (LFLAG)
      CALL CVOUT
      CALL MPBOUT
      CALL DFBOUT
      CALL TMOUT
      CALL BWEOUT
C      CALL RDROUT ! RD output now handled by GENPRT 12/5/14 LD
      CALL BRROUT
C
      CALL GENPRT
C
      RETURN
C
      END
