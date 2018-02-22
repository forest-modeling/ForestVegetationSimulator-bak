      SUBROUTINE DBSCASE(IFORSURE)
      IMPLICIT NONE
C
C $Id$
C
C
C     PURPOSE: TO POPULATE A DATABASE WITH THE PROGNOSIS MODEL
C              OUTPUT.
C
C     INPUT: IFORSURE - 1 NEED CONNECTION, 0 CHECK IF CONNECTION IS
C                       NEEDED.
C
C---
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'DBSCOM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'KEYCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C---

      INTEGER fsql3_tableexists,fsql3_exec,fsql3_errmsg
      INTEGER,parameter:: MaxStringLen=255

      CHARACTER*2000 SQLStmtStr
      CHARACTER*10  DATO, REV
      CHARACTER*8   TIM, SVN
      CHARACTER*(*) CFN
      CHARACTER(len=MaxStringLen) TIMESTAMP
      INTEGER IFORSURE, IFORSR, I, KODE, IRCODE
      CHARACTER(len=36) CID

      CHARACTER*7 VVER

      CHARACTER*2 VAR

      INCLUDE 'INCLUDESVN.F77'

      CALL VARVER(VVER)
      CALL REVISE(VVER,REV)
      VAR=VVER(:2)
      IF(VAR.EQ.'BP' .OR. VAR.EQ.'LP' .OR. VAR.EQ.'SF' .OR.
     &   VAR.EQ.'SM' .OR. VAR.EQ.'SP') VAR='CR'

C-----
C     CHECK TO SEE IF WE ARE NEEDING TO CONTINUE
C-----
      IFORSR=IFORSURE
      IF(IFORSR.EQ.0) THEN
        IF(ISUMARY.GE.1.OR.
     -     ICOMPUTE.GE.1.OR.
     -     ICALIB.GE.1.OR.
     -     IATRTLIST.GE.1.OR.
     -     ITREELIST.GE.1.OR.
     -     ICUTLIST.GE.1.OR.
     -     IDM1.GE.1.OR.IDM2.GE.1.OR.IDM3.GE.1.OR.
     -     IDM5.GE.1.OR.IDM6.GE.1.OR.
     -     IPOTFIRE.GE.1.OR.
     -     IFUELS.GE.1.OR.
     -     ICMRPT.GE.1.OR.
     -     ICHRPT.GE.1.OR.
     -     ISTRCLAS.GE.1.OR.
     -     IFUELC.GE.1.OR.
     -     IBURN.GE.1.OR.
     -     IMORTF.GE.1.OR.
     -     ISSUM.GE.1.OR.
     -     ISDET.GE.1.OR.
     -     ICANPR.GE.1.OR.
     -     IDWDVOL.GE.1.OR.
     -     IDWDCOV.GE.1.OR.
     -     IBMMAIN.GE.1.OR.
     -     IBMBKP.GE.1.OR.
     -     IBMTREE.GE.1.OR.
     -     IBMVOL.GE.1) IFORSR = 1
       ENDIF
       IF(IFORSR.EQ.0) RETURN
C---------
C     IF ALREADY HAVE A CURRENT CASE NUMBER, JUST BAIL
C---------
      IF (CASEID.NE."") RETURN
      KODE=0
C---------
C     MAKE SURE WE HAVE AN OPEN CONNECTION
C---------
      IF (IoutDBref.EQ.-1) CALL DBSOPEN(.TRUE.,.FALSE.,KODE)
      IF (KODE.EQ.1) THEN
        ICOMPUTE  = 0
        ICALIB    = 0
        ISUMARY   = 0
        IATRTLIST = 0
        ITREELIST = 0
        ICUTLIST  = 0
        IDM1      = 0
        IDM2      = 0
        IDM3      = 0
        IDM5      = 0
        IDM6      = 0
        IPOTFIRE  = 0
        IFUELS    = 0
        ICMRPT    = 0
        ICHRPT    = 0
        ISTRCLAS  = 0
        IFUELC    = 0
        IBURN     = 0
        IMORTF    = 0
        ISSUM     = 0
        ISDET     = 0
        ICANPR    = 0
        IDWDVOL   = 0
        IDWDCOV   = 0
        IBMMAIN   = 0
        IBMBKP    = 0
        IBMTREE   = 0
        IBMVOL    = 0
        RETURN
      ENDIF
      
      IRCODE = fsql3_tableexists(IoutDBref,"FVS_Cases"//CHAR(0))
      IF(IRCODE.EQ.0) THEN
        SQLStmtStr="CREATE TABLE FVS_Cases"//
     -              " (CaseID char(36) primary key,"//
     -              "Stand_CN char(40),"//
     -              "StandID char(26),"//
     -              "MgmtID char(4),"//
     -              "RunTitle char(72),"//
     -              "KeywordFile char(50),"//
     -              "SamplingWt real,"//
     -              "Variant char(2),"//
     -              "Version char(10),"//
     -              "RV char(8),"//
     -              "Groups char(250),"//
     -              "RunDateTime char(19))"//CHAR(0)
        IRCODE = fsql3_exec(IoutDBref,SQLStmtStr)
        IF (IRCODE .NE. 0) RETURN
      ENDIF
C---------
C     CREATE ENTRY FROM DATA FOR FVSRUN TABLE
C---------
      CALL UUIDGEN(CASEID)
C     CREATE DATETIME

      CALL GRDTIM(DATO,TIM)
      TIMESTAMP = DATO(7:10)//'-'//DATO(1:5)//'-'//TIM

C     STRIP 3-CHARACTER EXTENSION (IF PRESENT) FROM KEYFNAME
      KEYFNAME = TRIM(KEYFNAME)
      I = INDEX(".KEY",KEYFNAME)
      IF (I.GT.0 .AND. I.EQ.LEN_TRIM(KEYFNAME)-3) THEN
        KEYFNAME = KEYFNAME(1:I-4)
      ENDIF 
C----------
C           MAKE SURE WE DO NOT EXCEED THE MAX TABLE SIZE IN EXCEL
C----------
      IF (LENSLS.EQ.-1) THEN
        SLSET =""
      ELSE
        CALL REMOVEQUOTES(SLSET)
      ENDIF
      CALL REMOVEQUOTES(DBCN)
      CALL REMOVEQUOTES(NPLT)
      CALL REMOVEQUOTES(MGMID)
      CALL REMOVEQUOTES(ITITLE)
      CALL REMOVEQUOTES(KEYFNAME)      
      IF (KEYFNAME.EQ.' ') THEN
        KEYFNAME='Unknown'
      ELSE
        CALL REMOVEQUOTES(KEYFNAME)      
      ENDIF   
      
      WRITE(SQLStmtStr,*)"INSERT INTO FVS_Cases",
     - " (CaseID,Stand_CN,StandID,MgmtID,RunTitle,KeywordFile,",
     - "SamplingWt,Variant,Version,RV,Groups,RunDateTime) ",
     - "VALUES('",CASEID,"','",
     - TRIM(ADJUSTL(DBCN)),"','",
     - TRIM(ADJUSTL(NPLT)),"','",
     - TRIM(ADJUSTL(MGMID)),"','",
     - TRIM(ADJUSTL(ITITLE)),"','",
     - TRIM(ADJUSTL(KEYFNAME)),"',",
     - SAMWT,",'",VAR,"',","'",SVN,"','",REV,"','",
     - TRIM(ADJUSTL(SLSET)),"','",
     - TRIM(ADJUSTL(TIMESTAMP)),"');"

      IRCODE = fsql3_exec(IoutDBref,trim(SQLStmtStr)//CHAR(0))
      IF (IRCODE.ne.0) then
          IRCODE = fsql3_errmsg(IoutDBref,SQLStmtStr,LEN(SQLStmtStr)-1)
          PRINT *," IoutDBref=",IinDBref,
     >             " ErrMsg =",SQLStmtStr(:IRCODE)
      ENDIF
      RETURN
C
C     CALLED BY FILOPN: ENTRY TO SAVE THE KEYWORD FILE NAME AND TO SET
C                       THE DEFAULT DBS CONNECTIONS
C
      ENTRY DBSVKFN (CFN)
      I=LEN_TRIM(CFN)
      IF (I.GT.LEN(KEYFNAME)) THEN
         KEYFNAME=CFN(1:4)//'...'//CFN(I+8-LEN(KEYFNAME):)
      ELSE
         KEYFNAME = CFN
      ENDIF
      RETURN
C
C======================================================================
C     ENTRY FOR WWPBM, FETCHING CASEID
C    (NOTE: THE WWPBM NEEDS TO KNOW AND SAVE (INTERNALLY) CASEID, BECAUSE
C     IT IS DOING ITS DB-WRITING FROM WITHIN ITS OWN INTERNAL STAND LOOP
C
      ENTRY DBSWW2(CID)
      CID=CASEID
      RETURN
C======================================================================
      END

      SUBROUTINE REMOVEQUOTES (CS)
      IMPLICIT NONE
      CHARACTER(LEN=*) CS
      INTEGER I
      IF (LEN_TRIM(CS).LE.0) RETURN
      DO I=1,LEN_TRIM(CS)
        IF (CS(I:I) .EQ. "'") CS(I:I)=' '
      ENDDO
      RETURN
      END
      
