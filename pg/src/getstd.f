      SUBROUTINE GETSTD
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     READS A STAND FROM MASS STORAGE, AND THE ALL
C     DATA CHARACTER FILE, INTO MEMORY.
C
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PPDNCM.F77'
C
C
      INCLUDE 'ESPARM.F77'
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
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'CALDEN.F77'
C
C
      INCLUDE 'ECON.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
      INCLUDE 'ESHAP2.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
      INCLUDE 'ESCOM2.F77'
C
C
      INCLUDE 'ESTCOR.F77'
C
C
      INCLUDE 'ESTREE.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'RANCOM.F77'
C
C
      INCLUDE 'ESRNCM.F77'
C
C
      INCLUDE 'DBSTK.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'SUMTAB.F77'
C
C
      INCLUDE 'SSTGMC.F77'
C
C
      INCLUDE 'STDSTK.F77'
C
C
      INCLUDE 'SVDATA.F77'
C
C
      INCLUDE 'SVDEAD.F77'
C
C
      INCLUDE 'SVRCOM.F77'
C
C
      INCLUDE 'CWDCOM.F77'
C
C
      INCLUDE 'FVSSTDCM.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
      INCLUDE 'SCREEN.F77'
C
C
COMMONS
C
C
C     READ ALL INTEGER VARIABLES WITH IFREAD, ALL REAL VARIABLES WITH
C     BFREAD, AND ALL LOGICAL VARIABLES WITH LFREAD.  ONE EXCEPTION IS
C     IOSUM, WHICH MUST BE LONG INTEGER, AND IS READ USING
C     BFREAD VIA AN EQUIVALENCE TO ROSUM.  THE OTHER TWO EXCEPTIONS
C     ARE THE RANDOM NUMBER SEEDS, WHICH ARE EQUIVALENCED TO REAL
C     ARRAYS OF LENGTH 2.
C
      INTEGER MXL,MXR,MXI,IRECLN
      PARAMETER (MXR=130,MXL=40,MXI=119,IRECLN=1024)
      CHARACTER*40 CNAME
      INTEGER ILIMIT,IPNT,K,I,II,KODE
      INTEGER INTS(MXI)
      LOGICAL LOGICS(MXL),LCVGO,LMORED,LRR1,LRR2,LFM,LBWE,LCLM,LWRD,
     >        LCONN
      REAL REALS(MXR), ROSUM(20,MAXCY1),
     >          RSEED(2), ESSEED(2), RDTREE(MAXTRE),
     >          SVSED0(2),SVSED1(2)
      EQUIVALENCE (ROSUM,IOSUM),(RSEED,S0),(ESSEED,ESS0),(WK6,REALS),
     >            (WK6,LOGICS),(WK6,INTS),(IDTREE,RDTREE),
     >            (SVSED0,SVS0),(SVSED1,SVS1)
C
      ILIMIT=IRECLN
C
C     GET THE INTEGER SCALARS.
C     IT IS NECESSARY TO GET THE INTEGER SCALARS FIRST IN ORDER TO SET UP
C     LIMITS FOR THE REST OF THE VARIABLE LENGTH READS.
C
      CALL IFREAD (WK3,IPNT,ILIMIT,INTS,   MXI,    1)
      call fvsGetRtnCode(I)
      if (I.ne.0) return

      IAGE     =  INTS ( 1)
      IASPEC   =  INTS ( 2)
      IBLK     =  INTS ( 3)
      ICACT    =  INTS ( 4)
      ICFLAG   =  INTS ( 5)
      ICL1     =  INTS ( 6)
      ICL2     =  INTS ( 7)
      ICL3     =  INTS ( 8)
      ICL4     =  INTS ( 9)
      ICL5     =  INTS (10)
      ICL6     =  INTS (11)
      ICOD     =  INTS (12)
      ICRHAB   =  INTS (13)
      ICYC     =  INTS (14)
      IDG      =  INTS (15)
      IDSDAT   =  INTS (16)
      IEPT     =  INTS (17)
      IEVA     =  INTS (18)
      IEVT     =  INTS (19)
      IFINT    =  INTS (20)
      IFINTH   =  INTS (21)
      IFO      =  INTS (22)
      IFOR     =  INTS (23)
      IFST     =  INTS (24)
      IGL      =  INTS (25)
      IHAB     =  INTS (26)
      IHTG     =  INTS (27)
      IHTYPE   =  INTS (28)
      IMG1     =  INTS (29)
      IMG2     =  INTS (30)
      IMGL     =  INTS (31)
      IMPL     =  INTS (32)
      INADV    =  INTS (33)
      IPHASE   =  INTS (34)
      IPHY     =  INTS (35)
      IPINFO   =  INTS (36)
      IPREP    =  INTS (37)
      IPRINT   =  INTS (38)
      IPTINV   =  INTS (39)
      IREC1    =  INTS (40)
      IREC2    =  INTS (41)
      IRECNT   =  INTS (42)
      IRECRD   =  INTS (43)
      IRHHAB   =  INTS (44)
      ISISP    =  INTS (45)
      ISLOP    =  INTS (46)
      ISMALL   =  INTS (47)
      ISPCCF   =  INTS (48)
      ISPDSQ   =  INTS (49)
      ISPFOR   =  INTS (50)
      ISPHAB   =  INTS (51)
      ISTDAT   =  INTS (52)
      ITOP     =  INTS (53)       !DBSTK common
      ITOPRM   =  INTS (54)
      ITRN     =  INTS (55)
      ITRNRM   =  INTS (56)
      ITST5    =  INTS (57)
      ITYPE    =  INTS (58)
      IYRLRM   =  INTS (59)
      KDTOLD   =  INTS (60)
      KODFOR   =  INTS (61)
      KODTYP   =  INTS (62)
      LENSLS   =  INTS (63)
      LOAD     =  INTS (64)
      LSTKNT   =  INTS (65)
      METH     =  INTS (66)
      MINREP   =  INTS (67)
      MODE     =  INTS (68)
      MANAGD   =  INTS (69)
      NCYC     =  INTS (70)
      NNID     =  INTS (71)
      NONSTK   =  INTS (72)
      NPTIDS   =  INTS (73)
      NSTKNT   =  INTS (74)
      NTALLY   =  INTS (75)
      NUMSP    =  INTS (76)
      IMODTY   =  INTS (77)
      IPHREG   =  INTS (78)
      IFORTP   =  INTS (79)
      ISTCL    =  INTS (80)
      ISZCL    =  INTS (81)
      ISTRCL   =  INTS (82)
      IRREF    =  INTS (83)
      NDEAD    =  INTS (84)
      ICOLIDX  =  INTS (85)
      IDPLOTS  =  INTS (86)
      IGRID    =  INTS (87)
      ILYEAR   =  INTS (88)
      IRPOLES  =  INTS (89)
      JSVOUT   =  INTS (90)
      JSVPIC   =  INTS (91)
      NSVOBJ   =  INTS (92)
      IPLGEM   =  INTS (93)
      IMORTCNT =  INTS (94)
      ISVINV   =  INTS (95)
      ICNTY    =  INTS (96)
      ISTATE   =  INTS (97)
      ICAGE    =  INTS (98)
      MAIFLG   =  INTS (99)
      NEWSTD   =  INTS(100)
      ISEQDN   =  INTS(101)
      IMETRIC  =  INTS(102)
      NSPGRP   =  INTS(103)
      ITHNPI   =  INTS(104)
      ITHNPN   =  INTS(105)
      NCALHT   =  INTS(106)
      ITHNPA   =  INTS(107)
      ISILFT   =  INTS(108)
      NSITET   =  INTS(109)
      ILGNUM   =  INTS(110)
      NCWD     =  INTS(111)
      MFLMSB   =  INTS(112)
      JSPINDEF =  INTS(113)
      KOLIST   =  INTS(114)
      CALL SETNRPTS(INTS(115))
      IGFOR    =  INTS(116)
      NPTGRP   =  INTS(117)
      MAXTOP   =  INTS(118)      ! DBSTK common
      MAXLEN   =  INTS(119)      ! DBSTK common

C
C     GET THE INTEGER ARRAYS.
C
      CALL IFREAD (WK3,IPNT,ILIMIT,DEFECT, ITRN,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IABFLG,MAXSP,   2)
      K=IMGL-1
      DO I=1,5
        CALL IFREAD (WK3,IPNT,ILIMIT,IACT(1,I),K,    2)
      ENDDO
      CALL IFREAD (WK3,IPNT,ILIMIT,IDATE, K,       2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IOPCYC,K,       2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IOPSRT,K,       2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISEQ,  K,       2)
      K=MAXACT-IEPT+1
      DO I=1,5
        CALL IFREAD (WK3,IPNT,ILIMIT,IACT(IEPT,I),K, 2)
      ENDDO
      CALL IFREAD (WK3,IPNT,ILIMIT,IDATE(IEPT), K, 2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISEQ(IEPT),  K, 2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IALN,   3,      2)
      K=IEVA-1
      IF (K.GT.0) THEN
         DO 10 I=1,6
         CALL IFREAD (WK3,IPNT,ILIMIT,IEVACT(1,I),K,  2)
   10    CONTINUE
         CALL IFREAD (WK3,IPNT,ILIMIT,LENAGL,K,       2)
      ENDIF
      CALL IFREAD (WK3,IPNT,ILIMIT,IEVCOD,ICOD-1,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IEVNTS(1,1),IEVT-1,2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IEVNTS(1,2),IEVT-1,2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IEVNTS(1,3),IEVT-1,2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IMC,   ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IMGPTS(1,1),NCYC,2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IMGPTS(1,2),NCYC,2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IBEGIN,MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IBTAVH,ICYC+1,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IBTCCF,ICYC+1,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IBTRAN,MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ICTRAN,MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ICR,   ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IDTREE,ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IESTAT,ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IND,   ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IND1,  ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IND2,  ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,INS,   6,       2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IOICR, 6,       2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IOLDBA,ICYC+1,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IORDER,MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IPHAB, IPTINV,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IPHYS, IPTINV,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IPPREP,MAXPLT,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IPTIDS,IPTINV,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IPVEC, IPTINV,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IREF,  MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISCT,  MAXSP*2, 2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISDI,  ICYC+1,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISDIAT,ICYC+1,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISP,   ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISPECL,ITRN,    2)
      DO 12 I=1,30
      DO 11 II=1,52
      CALL IFREAD (WK3,IPNT,ILIMIT,ISPGRP(I,II),1, 2)
   11 CONTINUE
   12 CONTINUE
      CALL IFREAD (WK3,IPNT,ILIMIT,ISTAGF,MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ITRE,  ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ITRUNC,ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IY, MAXCY1,     2)
      CALL IFREAD (WK3,IPNT,ILIMIT,KOUNT, MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,KPTR,  MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,KUTKOD, ITRN,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,MAXSDI, MAXSP,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,METHC, MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,METHB, MAXSP,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,NBFDEF,ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,NCFDEF,ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,NORMHT,ITRN,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,NSTORE,MAXPLT,  2)
C
      CALL IFREAD (WK3,IPNT,ILIMIT,ISNSP, NDEAD,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IYRCOD,NDEAD,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ISTATUS,NDEAD,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IOBJTP,NSVOBJ,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,IS2F,  NSVOBJ,  2)
      CALL IFREAD (WK3,IPNT,ILIMIT,OIDTRE,NDEAD,   2)
      CALL IFREAD (WK3,IPNT,ILIMIT,JSPIN,MAXSP,    2)
      CALL IFREAD (WK3,IPNT,ILIMIT,ITABLE,7,       2)
      DO 14 I=1,30
      DO 13 II=1,52
      CALL IFREAD (WK3,IPNT,ILIMIT,IPTGRP(I,II),1, 2)
   13 CONTINUE
   14 CONTINUE
C
C     GET THE LOGICAL SCALARS.
C
      CALL LFREAD (WK3,IPNT,ILIMIT,LOGICS, MXL,    2)
      LAUTAL = LOGICS( 1)
      LAUTON = LOGICS( 2)
      LBKDEN = LOGICS( 3)
      LBSETS = LOGICS( 4)
      LBVOLS = LOGICS( 5)
      LCVGO  = LOGICS( 6)
      LCVOLS = LOGICS( 7)
      LDCOR2 = LOGICS( 8)
      LDUBDG = LOGICS( 9)
      LECBUG = LOGICS(10)
      LECON  = LOGICS(11)
      LEVUSE = LOGICS(12)
      LFIXSD = LOGICS(13)
      LFLAG  = LOGICS(14)
      LHCOR2 = LOGICS(15)
      LINGRW = LOGICS(16)
      LMORT  = LOGICS(17)
      LNEDNS = LOGICS(18)
      LOPEVN = LOGICS(19)
      LRCOR2 = LOGICS(20)
      LSITE  = LOGICS(21)
      LSTART = LOGICS(22)
      LSTATS = LOGICS(23)
      LSPRUT = LOGICS(24)
      LSUMRY = LOGICS(25)
      LTRIP  = LOGICS(26)
      MORDAT = LOGICS(27)
      NOTRIP = LOGICS(28)
      LCALC  = LOGICS(29)
      LFLAGV = LOGICS(30)
      LBAMAX = LOGICS(31)
      LPRNT  = LOGICS(32)
      LFIA   = LOGICS(33)
      LZEIDE = LOGICS(34)
      LFIRE  = LOGICS(35)
      LFM    = LOGICS(36)
      CALL FMSATV(LFM)
      FSTOPEN= LOGICS(37)
      LCLM   = LOGICS(38)
      CALL CLSETACTV(LCLM)
      LWRD   = LOGICS(39)
      LSCRN  = LOGICS(40)
C
C
C     GET THE LOGICAL ARRAYS.
C
      CALL LFREAD (WK3,IPNT,ILIMIT,LDGCAL,MAXSP,   2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LHTDRG,MAXSP,   2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LHTCAL,MAXSP,   2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LTSTV4,MXTST4,  2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LTSTV5, ITST5,  2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LSPCWE,MAXSP,   2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LREG  ,MXLREG,  2)
      CALL LFREAD (WK3,IPNT,ILIMIT,LEAVESP,MAXSP,  2)
C
C
C     GET THE REAL SCALARS.
C
      CALL BFREAD (WK3,IPNT,ILIMIT,REALS,  MXR,    2)
      AHAT   = REALS ( 1)
      ALPHA  = REALS ( 2)
      ASPECT = REALS ( 3)
      ATAVD  = REALS ( 4)
      ATAVH  = REALS ( 5)
      ATBA   = REALS ( 6)
      ATCCF  = REALS ( 7)
      ATSDIX = REALS ( 8)
      ATTPA  = REALS ( 9)
      AUTMAX = REALS (10)
      AUTMIN = REALS (11)
      AUTEFF = REALS (12)
      AVH    = REALS (13)
      BA     = REALS (14)
      BAA    = REALS (15)
      BAALN  = REALS (16)
      BAASQ  = REALS (17)
      BAF    = REALS (18)
      BAMAX  = REALS (19)
      BAMIN  = REALS (20)
      BFMIN  = REALS (21)
      BHAT   = REALS (22)
      BJPHI  = REALS (23)
      BJTHET = REALS (24)
      BRK    = REALS (25)
      BTSDIX = REALS (26)
      BWAF   = REALS (27)
      BWB4   = REALS (28)
      CCMIN  = REALS (29)
      CEPMRT = REALS (30)
      CFMIN  = REALS (31)
      CONFID = REALS (32)
      COVMLT = REALS (33)
      COVYR  = REALS (34)
      D0     = REALS (35)
      D0MULT = REALS (36)
      DBHDOM = REALS (37)
      DGSD   = REALS (38)
      EFF    = REALS (39)
      ELEV   = REALS (40)
      ELEVSQ = REALS (41)
      ESA    = REALS (42)
      ESB    = REALS (43)
      ESDRAW = REALS (44)
      FINT   = REALS (45)
      FINTH  = REALS (46)
      FINTM  = REALS (47)
      FPA    = REALS (48)
      GAPPCT = REALS (49)
      GROSPC = REALS (50)
      H2COF  = REALS (51)
      HDGCOF = REALS (52)
      HGHCH  = REALS (53)
      OLDAVH = REALS (54)
      OLDBA  = REALS (55)
      OLDFNT = REALS (56)
      OLDTIM = REALS (57)
      OLDTPA = REALS (58)
      ORMSQD = REALS (59)
      PBURN  = REALS (60)
      PCTSMX = REALS (61)
      PDCCFN = REALS (62)
      PDBAN  = REALS (63)
      PI     = REALS (64)
      PMECH  = REALS (65)
      PMSDIL = REALS (66)
      PMSDIU = REALS (67)
      POTEN  = REALS (68)
      REGCH  = REALS (69)
      REGNBK = REALS (70)
      REGT   = REALS (71)
      RELDEN = REALS (72)
      RELDM1 = REALS (73)
      RMAI   = REALS (74)
      RMSQD  = REALS (75)
      SAMWT  = REALS (76)
      SAWDBH = REALS (77)
      SDIAC  = REALS (78)
      SDIBC  = REALS (79)
      SDIMAX = REALS (80)
      SLO    = REALS (81)
      SLOPE  = REALS (82)
      SLPMRT = REALS (83)
      SPCLWT = REALS (84)
      SQBWAF = REALS (85)
      SQREGT = REALS (86)
      SSDBH  = REALS (87)
      STOADJ = REALS (88)
      SUMPRB = REALS (89)
      TCFMIN = REALS (90)
      TCWT   = REALS (91)
      TFPA   = REALS (92)
      THRES1 = REALS (93)
      THRES2 = REALS (94)
      TIME   = REALS (95)
      TLAT   = REALS (96)
      TPACRE = REALS (97)
      TPAMIN = REALS (98)
      TPAMRT = REALS (99)
      TPROB  = REALS (100)
      TRM    = REALS (101)
      VMLT   = REALS (102)
      VMLTYR = REALS (103)
      XCOS   = REALS (104)
      XCOSAS = REALS (105)
      XSIN   = REALS (106)
      XSINAS = REALS (107)
      XTES   = REALS (108)
      YR     = REALS (109)
      ZBURN  = REALS (110)
      ZMECH  = REALS (111)
      SVSS   = REALS (112)
      TLONG  = REALS (113)
      TOTREM = REALS (114)
      AGELST = REALS (115)
      PBAWT  = REALS (116)
      PCCFWT = REALS (117)
      FNMIN  = REALS (118)
      QMDMSB = REALS (119)
      SLPMSB = REALS (120)
      CEPMSB = REALS (121)
      PTPAWT = REALS (122)
      EFFMSB = REALS (123)
      DLOMSB = REALS (124)
      DHIMSB = REALS (125)
      SDIAC2 = REALS (126)
      SDIBC2 = REALS (127)
      DBHZEIDE =REALS(128)
      DBHSTAGE= REALS (129)
      DR016  = REALS (130)  

C
C     GET THE REAL ARRAYS.
C
      CALL BFREAD (WK3,IPNT,ILIMIT,AA,     MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ABIRTH, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ACCFSP, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ATTEN,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BAAA,   IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BAAINV, IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BARANK, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB,     MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB0 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB1 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB2 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB3 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB4 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB5 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB6 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB7 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB8 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB9 ,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB10,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB11,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB12,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BB13,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,B0ACCF, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,B1ACCF, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,B0BCCF, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,B1BCCF, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,B0ASTD, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,B1BSTD, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BCCFSP, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BCYMAI, MAXCY1,    2)
      DO 15 I=1,MAXSP
      CALL BFREAD (WK3,IPNT,ILIMIT,BFDEFT(1,I),9,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFVEQL(1,I),7,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFVEQS(1,I),7,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CFDEFT(1,I),9,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CFVEQL(1,I),7,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CFVEQS(1,I),7,     2)
   15 CONTINUE
      CALL BFREAD (WK3,IPNT,ILIMIT,BFLA0,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFLA1,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFMIND, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFSTMP, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFTOPD, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BFV,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BJRHO,  40,        2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BKRAT,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,BTRAN,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CFLA0,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CFLA1,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CFV,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,COR,    MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,COR2,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CRCON,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CRWDTH, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CTRAN,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DBH,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DBHIO,  6,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DBHMIN, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DG,     ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DGCCF,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DGCON,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DGDSQ,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DGIO,   6,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,DIFH,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ESB1,   MAXPLT,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ESSEED, 2,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,FL,     MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,FM,     MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,FRMCLS, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,FU,     MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,GMULT,  2,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HCOR,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HCOR2,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HSIG,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HT,     ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HT1,    MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HT2,    MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HTT1, MAXSP*9,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HTT2, MAXSP*9,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HTADJ,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HTCON,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HTG,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HTIO,   6,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,LOGDIA(1,1),21,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,LOGDIA(1,2),21,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,LOGDIA(1,3),21,    2)
      DO 17 I=1,20
      CALL BFREAD (WK3,IPNT,ILIMIT,LOGVOL(1,I),7,     2)
   17 CONTINUE
      CALL BFREAD (WK3,IPNT,ILIMIT,OACC,   7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OBFCUR, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OBFREM, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OCVCUR, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OCVREM, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OLDPCT, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OLDRN,  ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OMCCUR, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OMCREM, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OMORT,  7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ONTCUR, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ONTREM, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ONTRES, 7,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPAC,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPBR,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPBV,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPCT,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPCV,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPMC,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPMO,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPMR,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPRT,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPTT,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSPTV,  4,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OVER, IPTINV*MAXSP,2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PARMS,  IMPL-1,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PARMS(ITOPRM), MAXPRM-ITOPRM+1, 2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PASP,   IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PCCF,   IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PCT,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PCTIO,  6,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PNN,    MAXPLT,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PRBIO,  6,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PADV,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PSUB,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PTBAA,  IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PTBALT, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PTPA,   IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PXCS,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SUMPX,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SUMPI,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PLPROB, IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PLTSIZ, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PROB,   ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PROB1,  MAXPLT,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PSLO,   IPTINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PTOCFV, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PMRCFV, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PMRBFV, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,PDBH,   ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,QDBHAT, ICYC+1,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,QSDBT,  ICYC+1,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,RCOR2,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,RDTREE, ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,REIN,   2,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,RELDSP, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,RHCON,  MAXSP,     2)
      K=ICYC+1
      DO 20 I=1,K
      CALL BFREAD (WK3,IPNT,ILIMIT,ROSUM(1,I),20,     2)
   20 CONTINUE
      CALL BFREAD (WK3,IPNT,ILIMIT,RSEED,   2,        2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SDIDEF, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SIGMA,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SIGMAR, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SITEAR, MAXSP,     2)
      DO 22 I=1,MAXSP
      DO 21 II=1,4
      CALL BFREAD (WK3,IPNT,ILIMIT,SIZCAP(I,II),1,    2)
   21 CONTINUE
   22 CONTINUE
      CALL BFREAD (WK3,IPNT,ILIMIT,SMCON,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,STMP,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SUMPRE, 5,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,TOPD,   MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,TSTV1,  50,        2)
      CALL BFREAD (WK3,IPNT,ILIMIT,TSTV2,  30,        2)
      CALL BFREAD (WK3,IPNT,ILIMIT,TSTV3,  20,        2)
      CALL BFREAD (WK3,IPNT,ILIMIT,TSTV4,  MXTST4,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,TSTV5,  ITST5,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,VARDG,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,WCI,    MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,WK1,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,WK2,    ITRN,      2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XDMULT, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XESMLT, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XHMULT, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XMDIA1, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XMDIA2, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XMMULT, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XRDMLT, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XRHMLT, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ZRAND,  ITRN,      2)
C
      CALL BFREAD (WK3,IPNT,ILIMIT,SVSED0, 2,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SVSED1, 2,         2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CRNDIA, NDEAD,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CRNRTO, NDEAD,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OLEN,   NDEAD,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,ODIA,   NDEAD,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,FALLDIR,NDEAD,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,YHFHTS, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,YHFHTH, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,HRATE,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,XSLOC,  NSVOBJ,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,YSLOC,  NSVOBJ,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,X1R1S,  ISVINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,X2R2S,  ISVINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,Y1A1S,  ISVINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,Y2A2S,  ISVINV,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDS0,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDS1,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDS2,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDS3,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDL0,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDL1,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDL2,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWDL3,  MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,CWTDBH, MAXSP,     2)
      CALL BFREAD (WK3,IPNT,ILIMIT,OSTRST, 33*2,      2)
C
      IF (NDEAD .GT. 0) THEN

        CALL BFREAD (WK3,IPNT,ILIMIT,PBFALL, NDEAD,     2)
        CALL BFREAD (WK3,IPNT,ILIMIT,SNGDIA, NDEAD,     2)
        CALL BFREAD (WK3,IPNT,ILIMIT,SNGLEN, NDEAD,     2)
        DO I=1,3
          CALL BFREAD (WK3,IPNT,ILIMIT,SPROBS(1,I),NDEAD, 2)
        ENDDO
        DO I=0,3
          CALL BFREAD (WK3,IPNT,ILIMIT,SNGCNWT(1,I),NDEAD, 2)
        ENDDO
      ENDIF

      IF (NCWD .GT. 0) THEN      

        CALL BFREAD (WK3,IPNT,ILIMIT,CWDDIA, NCWD,      2)
        CALL BFREAD (WK3,IPNT,ILIMIT,CWDLEN, NCWD,      2)
        CALL BFREAD (WK3,IPNT,ILIMIT,CWDPIL, NCWD,      2)
        CALL BFREAD (WK3,IPNT,ILIMIT,CWDDIR, NCWD,      2)
        CALL BFREAD (WK3,IPNT,ILIMIT,CWDWT,  NCWD,      2)
      ENDIF
      CALL BFREAD (WK3,IPNT,ILIMIT,PHT,    MAXTRE,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,REMP,   MAXTRE,    2)
      CALL BFREAD (WK3,IPNT,ILIMIT,SITETR, MAXSTR*6,  2)

C
C     READ THE VARIANT SPECIFIC VARIABLES.
C
      CALL VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)

C
C     GET THE COVER VARIABLES...IF THE COVER MODEL IS BEING USED
C     IN THIS STAND.
C
      IF (LCVGO) CALL CVGET (WK3,IPNT,ILIMIT)

C
C     GET THE MISTLETOE DATA...IF THE MISTLETOE MODEL LINKED TO
C     TO THE SYSTEM (WHICH IS GENERALLY TRUE FOR MOST VARIANTS).
C
      CALL MISACT (LMORED)
      IF (LMORED) CALL MSPPGT (WK3,IPNT,ILIMIT)

C
C     GET THE ROOT DISEASE & STEM RUST DATA...IF THE QUICK RR MODEL
C     IS LINKED TO THE SYSTEM (WHICH IT IS FOR THE WESTWIDE PINE
C     BEETLE MODEL).
C
 !     CALL RRATV (LRR1,LRR2)
 !     IF(LRR1) CALL RRPPGT (WK3,IPNT,ILIMIT)
C
C     GET THE WESTERN ROOT DISEASE MODEL INFORMATION
C
      IF(LWRD) CALL RDPPGT (WK3,IPNT,ILIMIT)

C
C     GET THE WESTWIDE PINE BEETLE MODEL STAND-LEVEL DATA THAT
C     IS NEEDED.
C
 !     CALL BMPPGT (IPNT,ILIMIT)
C
C     GET THE GENDEFOL/BUDWORM MODEL NUMERIC VARIABLES, IF ACTIVE.
C
 !     CALL BWEPPATV (LBWE)
 !     IF (LBWE) CALL BWEPPGT (WK3,IPNT,ILIMIT,1)
C
C     GET THE FIRE MODEL VARIABLES
C
      IF (LFM) CALL FMPPGET (WK3,IPNT,ILIMIT)

C
C     GET THE ECONOMIC MODEL VARIABLES
C
      CALL ECNGET (WK3,IPNT,ILIMIT)

C
C     GET THE DATABASE VARIABLES
C
      CALL DBSPPGET (WK3,IPNT,ILIMIT)

C
C     GET THE CLIMATE-FVS VARIABLES
C
      CALL CLGET (WK3,IPNT,ILIMIT)

C
C     GET THE LAST REAL VARIABLE.
C
      CALL BFREAD (WK3,IPNT,ILIMIT,XSTORE, MAXPLT,    3)

C
C     END OF NUMERIC AND LOGICAL READ.  READ IN CHARACTERS.
C
      CALL CHGET
C
C     REOPEN ESTABLISHMENT MODEL REPORT FILE IF PRESENT.
C
      CNAME=TRIM(KWDFIL)//'_RegenRpt.txt'
      INQUIRE(FILE=TRIM(CNAME),exist=LCONN)
      IF (LCONN) THEN
        CALL MYOPEN (JOREGT,CNAME,3,133, 0,1,1,0,KODE)
        IF(KODE.GT.0) THEN
          WRITE(*,'(''OPEN FAILED FOR '',I4)') JOREGT
        ELSE
          DO
            READ (JOREGT,*,END=100)
          ENDDO
  100     BACKSPACE (JOREGT)
        ENDIF
      ENDIF

      RETURN
      END
