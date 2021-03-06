C MODPATH Version 3.00 (V3, Release 2, 5-99)
C Changes:
C   No change since previous release: (V3, Release 1, 9-94)
C***** SUBROUTINES *****
C     GETIJK
C     VOLDIV
C     FACDIV
C     SLFTYP
C     EPSLOC
C***********************
 
C***** SUBROUTINE *****
      SUBROUTINE GETIJK (I,J,K,X,Y,Z,ZLLC,ZLC,ICODE,JCODE,KCODE,HNOFLO,
     1 XMAX,YMAX,ZTOP,ZBOT,HEAD,LAYCON,NCON,NCOL,NROW,NLAY,NZDIM,IGRID,
     2 HDRY,TRLEAS)
      DIMENSION XMAX(NCOL),YMAX(NROW),HEAD(NCOL,NROW,NLAY),ZTOP(NZDIM),
     1          ZBOT(NZDIM),LAYCON(NLAY),NCON(NLAY)
C
      IXFACE=0
      IYFACE=0
      IZFACE=0
      ZLC=  1.0E+30
      ZLLC= 1.0E+30
C----------------------------------
C--- GET "J" INDEX FOR X-DIRECTION
C----------------------------------
      IF(JCODE.LT.2) THEN
        IF(J.LT.1 .OR. J.GT.NCOL) THEN
          J=0
          RETURN
        END IF
      END IF
C==> COORDINATE IS LOCAL. USE INPUT VALUE FOR GRID INDEX J
      IF(JCODE.EQ.0) THEN
      XMN=0.0
      IF(J.GT.1) XMN=XMAX(J-1)
      IF(X.LE.0.0) THEN
      X= 0.999*XMN + 0.001*XMAX(J)
      ELSE IF(X.GE.1.0) THEN
      X= 0.001*XMN + 0.999*XMAX(J)
      ELSE
      X= (1.0-X)*XMN + X*XMAX(J)
      END IF
      GO TO 15
 
C==> COORDINATE IS GLOBAL. USE INPUT VALUE FOR GRID INDEX J
      ELSE IF (JCODE.EQ.1) THEN
      XMN=0.0
      IF(J.GT.1) XMN=XMAX(J-1)
 
C--> ALLOW A LITTLE SLOP ON EITHER SIDE TO COMPENSATE FOR POSSIBLE
C    ROUNDOFF ERROR IN INPUT FILE. IF X IS OUTSIDE THE RANGE, RETURN J=0
      X1=0.99999*XMN
      X2=1.00001*XMAX(J)
      IF(X.LT.X1 .OR. X.GT.X2) THEN
      J=0
      GO TO 15
      END IF
 
      IF(X.LE.XMN) X= 0.999*XMN + 0.001*XMAX(J)
      IF(X.GE.XMAX(J)) X= 0.001*XMN + 0.999*XMAX(J)
      GO TO 15
 
C==> COORDINATE IS GLOBAL. FIND THE J GRID INDEX
      ELSE IF (JCODE.EQ.2) THEN
      J=0
      IF(X.LT.0.0 .OR. X.GT.XMAX(NCOL)) GO TO 15
      DO 10 N=1,NCOL
      IF(X.LE.XMAX(N)) THEN
      J=N
      IF(X.EQ.XMAX(N) .AND. N.LT.NCOL) IXFACE=1
      IF(N.GT.1) THEN
      IF(X.EQ.XMAX(N-1)) IXFACE= -1
      END IF
      GO TO 15
      END IF
10    CONTINUE
      END IF
 
15    CONTINUE
C==> IF J=0 THEN SOMETHING IS WRONG. RETURN A 0 VALUE TO INDICATE A PROB
      IF (J.EQ.0) RETURN
 
 
C----------------------------------
C--- GET "I" INDEX FOR Y-DIRECTION
C----------------------------------
C... COORDINATE IS LOCAL. USE INPUT VALUE FOR GRID INDEX I
      IF(ICODE.LT.2) THEN
        IF(I.LT.1 .OR. I.GT.NROW) THEN
          I=0
          RETURN
        END IF
      END IF
      IF(ICODE.EQ.0) THEN
      YMN=0.0
      IF (I.LT.NROW) YMN=YMAX(I+1)
      IF(Y.LE.0.0) THEN
      Y= 0.999*YMN + 0.001*YMAX(I)
      ELSE IF(Y.GE.1.0) THEN
      Y= 0.001*YMN + 0.999*YMAX(I)
      ELSE
      Y= (1.0-Y)*YMN + Y*YMAX(I)
      END IF
      GO TO 25
 
C==> COORDINATE IS GLOBAL. USE INPUT VALUE FOR GRID INDEX I
      ELSE IF (ICODE.EQ.1) THEN
      YMN=0.0
      IF (I.LT.NROW) YMN=YMAX(I+1)
 
C--> ALLOW A LITTLE SLOP ON EITHER SIDE TO COMPENSATE FOR POSSIBLE
C    ROUNDOFF ERROR IN INPUT FILE. IF Y IS OUTSIDE THE RANGE, RETURN I=0
      Y1= 0.99999*YMN
      Y2= 1.00001*YMAX(I)
      IF(Y.LT.Y1 .OR. Y.GT.Y2) THEN
      I=0
      GO TO 25
      END IF
 
      IF(Y.LE.YMN) Y= 0.999*YMN + 0.001*YMAX(I)
      IF(Y.GE.YMAX(I)) Y= 0.001*YMN + 0.999*YMAX(I)
      GO TO 25
 
C==> COORDINATE IS GLOBAL. FIND THE I GRID INDEX
      ELSE IF (ICODE.EQ.2) THEN
      I=0
      IF(Y.LT.0.0 .OR. Y.GT.YMAX(1)) GO TO 25
      DO 20 N=NROW,1, -1
      IF(Y.LE.YMAX(N)) THEN
      I=N
      IF(Y.EQ.YMAX(N) .AND. N.GT.1) IYFACE=1
      IF(N.LT.NROW) THEN
      IF(Y.EQ.YMAX(N+1)) IYFACE= -1
      END IF
      GO TO 25
      END IF
20    CONTINUE
      END IF
 
25    CONTINUE
C==> IF I=0 THEN SOMETHING IS WRONG. RETURN A 0 VALUE TO INDICATE A PROB
      IF (I.EQ.0) RETURN
 
 
C----------------------------------
C--- GET "K" INDEX FOR Z-DIRECTION
C----------------------------------
C
C==> COORDINATE IS LOCAL. USE SPECIFIED K INDEX
      IF(KCODE.LT.2) THEN
        IF(K.LT.1 .OR. K.GT.NLAY) THEN
          K=0
          RETURN
        END IF
      END IF
      IF(KCODE.EQ.0) THEN
C  IF K=0, FIND TOP-MOST ACTIVE CELL (DRAPE)
        IF(K.EQ.0) THEN
        DO 40 KT=1,NLAY
          IF(HEAD(J,I,KT).NE.HNOFLO .AND. HEAD(J,I,KT).NE.HDRY) THEN
            K=KT
            GO TO 42
          END IF
40      CONTINUE
42      CONTINUE
        END IF
      IF(K.EQ.0) GO TO 35
      ZLLC=Z
      IF(ZLLC.GE.1.0) ZLLC=0.999
      IF(ZLLC.EQ.0.0) ZLLC=0.001
      IF(ZLLC.LE.-1.0) ZLLC= -0.999
      GO TO 35
 
C==> COORDINATE IS GLOBAL. USE SPECIFIED K INDEX.
C    (ONLY ALLOWED FOR RECTANGULAR 3-D GRIDS, I.E. IGRID=1)
      ELSE IF (KCODE.EQ.1) THEN
      IF(IGRID.EQ.0) THEN
      K=0
      GO TO 35
      END IF
      ZMN1=ZBOT(K)
      ZMN2=ZMN1
      IF(K.LT.NLAY.AND.NCON(K).NE.0) ZMN2=ZTOP(K+1)
      IF (LAYCON(K).LE.0) THEN
      ZMX=ZTOP(K)
      ELSE IF (LAYCON(K).EQ.1) THEN
      ZMX=HEAD(J,I,K)
      ELSE IF (LAYCON(K).GT.1) THEN
      ZMX=ZTOP(K)
      IF(HEAD(J,I,K).LT.ZMX) ZMX=HEAD(J,I,K)
      END IF
 
C... IF Z COORDINATE IS NOT IN LAYER K, SET K=0 AND RETURN
      IF(Z.GT.ZMX .OR. Z.LT.ZMN2) THEN
      K=0
      RETURN
      END IF
C
C  SET GLOBAL COORDINATE IN ZLC ARRAY = Z
      ZLC=Z
 
C  IF THE LAYER IS CONFINED, IF PARTICLE IS IN CB, OR IF REVERSE MODE, COMPUTE
C  LOCAL Z COORDINATE NOW. IF THE PARTICLE IS IN A CELL THAT CAN HAVE A
C  WATER TABLE, WAIT AND COMPUTE THE LOCAL Z COORDINATE AT THE BEGINNING
C  OF THE TIME LOOP JUST BEFORE IT IS RELEASED.
C
      IF(ZMN1.NE.ZMN2 .AND. Z.LE.ZMN1) THEN
      ZLLC= (Z-ZMN1)/(ZMN1-ZMN2)
      IF(ZLLC.GE.0.0) ZLLC=0.001
      IF(ZLLC.LE.-1.0) ZLLC=-0.999
      ELSE IF(LAYCON(K).LE.0 .OR. TRLEAS.EQ.0.0) THEN
      ZLLC= (Z-ZMN1)/(ZMX-ZMN1)
      IF(ZLLC.GE.1.0) ZLLC=0.999
      IF(ZLLC.LE.0.0) ZLLC=0.001
      END IF
      GO TO 35
 
C==> COORDINATE IS GLOBAL. FIND THE K GRID INDEX.
      ELSE IF (KCODE.EQ.2) THEN
      K=0
C-->  DO NOT ALLOW GLOBAL COORDINATES IF THE GRID IS NOT RECTANGULAR.
      IF(IGRID.EQ.0) GO TO 35
 
      ZLC=Z
 
      DO 45 N=1,NLAY
      ZMN1=ZBOT(N)
      ZMN2=ZMN1
      IF(N.LT.NLAY.AND.NCON(N).NE.0) ZMN2=ZTOP(N+1)
      IF (LAYCON(N).LE.0) THEN
      ZMX=ZTOP(N)
      ELSE IF (LAYCON(N).EQ.1) THEN
      ZMX=HEAD(J,I,N)
      ELSE IF (LAYCON(N).GT.1) THEN
      ZMX=ZTOP(N)
      IF(HEAD(J,I,N).LT.ZMX) ZMX=HEAD(J,I,N)
      END IF
      IF(Z.GT.ZMX .OR. Z.LT.ZMN2) GO TO 45
      K=N
      IF(Z.EQ.ZMX .AND. N.GT.1) IZFACE=1
      IF(ZMN1.EQ.ZMN2 .AND. N.LT.NLAY) THEN
      IF(Z.EQ.ZMN1) IZFACE= -1
      END IF
      IF(ZMN1.NE.ZMN2 .AND. N.LT.NLAY) THEN
      IF(Z.EQ.ZMN2) IZFACE= -1
      END IF
 
      IF(ZMN1.NE.ZMN2 .AND. Z.LE.ZMN1) THEN
      ZLLC= (Z-ZMN1)/(ZMN1-ZMN2)
      IF(ZLLC.GT.0.0) ZLLC=0.0
      IF(ZLLC.LT.-1.0) ZLLC=-1.0
      ELSE IF(LAYCON(K).LE.0 .OR. TRLEAS.EQ.0.0) THEN
      ZLLC= (Z-ZMN1)/(ZMX-ZMN1)
      IF(ZLLC.GT.1.0) ZLLC=1.0
      IF(ZLLC.LT.0.0) ZLLC=0.0
      END IF
      GO TO 35
45    CONTINUE
      END IF
 
 
C==> CHECK FOR SPECIAL CONDITIONS.
35    CONTINUE
C--> IF K=0 THEN SOMETHING IS WRONG. RETURN A 0 VALUE TO INDICATE A PROB
      IF (K.EQ.0) RETURN
 
C--> IF NO GRID INDICES WERE OBTAINED BY SEARCHING, CHECK TO SEE IF CELL
C    IS ACTIVE OR INACTIVE, THEN RETURN.
      IF(JCODE.LT.2 .AND. ICODE.LT.2 .AND. KCODE.LT.2) THEN
        IF(HEAD(J,I,K).EQ.HNOFLO .OR. HEAD(J,I,K).EQ.HDRY) THEN
          K=0
        END IF
        RETURN
      END IF
 
C--> IF CELL INDICES WERE OBTAINED BY SEARCHING, DO SOME MORE CHECKING TO
C    ASSURE THAT A PARTICLE IS PLACED IN AN ACTIVE CELL.
C
C  IF THE CURRENT CELL IS INACTIVE AND PARTICLE IS EXACTLY ON A FACE,
C  THEN LOOK FOR AN ADJACENT ACTIVE CELL ON A SHARED FACE.
      IEDGE=0
      IF(IXFACE.NE.0 .OR. IYFACE.NE.0 .OR. IZFACE.NE.0) IEDGE=1
      INACT=0
      IF(HEAD(J,I,K).EQ.HNOFLO .OR. HEAD(J,I,K).EQ.HDRY) INACT=1
      IF (INACT.EQ.1 .AND. IEDGE.EQ.1) THEN
 
C  FIND AN ADJACENT ACTIVE CELL THAT HAS A SHARED FACE
      IHIT=0
      DO 50 JJJ=1,2
      JNEW=J+(JJJ-1)*IXFACE
      DO 50 III=1,2
      INEW=I-(III-1)*IYFACE
      DO 50 KKK=1,2
      KNEW=K-(KKK-1)*IZFACE
      IF(HEAD(JNEW,INEW,KNEW).NE.HNOFLO .AND.
     1   HEAD(JNEW,INEW,KNEW).NE.0) THEN
      IHIT=1
      GO TO 55
      END IF
50    CONTINUE
55    CONTINUE
 
C  IF THERE ARE NO ADJACENT ACTIVE CELLS WITH SHARED FACES, SET I,J,K
C  AND THEN RETURN
      IF(IHIT.EQ.0) THEN
      K=0
      RETURN
      END IF
 
 
C  IF AN ADJACENT CELL WAS FOUND, MAKE THAT THE CURRENT CELL. ADJUST THE
C  LOCAL Z COORDINATE TO ACCOUNT FOR THE CHANGE IN CELL
      J=JNEW
      I=INEW
      IF(KNEW.LT.K) THEN
 
      IF(NCON(KNEW).EQ.1) THEN
      ZLLC= -1.0
      ELSE
      IF(LAYCON(KNEW).LE.0 .OR. TRLEAS.EQ.0.0 .OR. KCODE.EQ.0) ZLLC=0.0
      END IF
 
      ELSE IF (KNEW.GT.K) THEN
      IF(LAYCON(KNEW).LE.0 .OR. TRLEAS.EQ.0.0 .OR. KCODE.EQ.0) ZLLC=1.0
      END IF
 
      K=KNEW
      END IF
 
 
C--> MAKE ONE FINAL CHECK TO SEE IF THE PARTICLE IS IN AN INACTIVE CELL
      IF(HEAD(J,I,K).EQ.HNOFLO .OR. HEAD(J,I,K).EQ.HDRY) THEN
        K=0
        RETURN
      END IF
 
C--> ADJUST PARTICLE THAT ARE EXACTLY AT A FACE. IF CODE IS 0 OR 1,
C    ADJUSTMENTS HAVE ALREADY BEEN MADE.
      IF (JCODE.EQ.2) THEN
      XMN=0.0
      IF(J.GT.1) XMN=XMAX(J-1)
      IF(X.LE.XMN) X= 0.999*XMN + 0.001*XMAX(J)
      IF(X.GE.XMAX(J)) X= 0.001*XMN + 0.999*XMAX(J)
      END IF
 
      IF (ICODE.EQ.2) THEN
      YMN=0.0
      IF (I.LT.NROW) YMN=YMAX(I+1)
      IF(Y.LE.YMN) Y= 0.999*YMN + 0.001*YMAX(I)
      IF(Y.GE.YMAX(I)) Y= 0.001*YMN + 0.999*YMAX(I)
      END IF
 
      IF (KCODE.EQ.2 .AND. ZLLC.LE.1.0 .AND. ZLLC.GE.-1.0) THEN
      IF(ZLLC.GE.1.0) ZLLC=0.999
      IF(ZLLC.EQ.0.0) ZLLC=0.001
      IF(ZLLC.LE.-1.0) ZLLC= -0.999
      END IF
 
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE VOLDIV (J,I,K,JLC,ILC,KLC,XLC,YLC,ZLLC,NDIV,MDIV,LDIV,
     1NPART,NP,IBATCH)
      DIMENSION JLC(NPART),ILC(NPART),KLC(NPART),XLC(NPART),YLC(NPART),
     1ZLLC(NPART)
C
      DELN= 1.0E+0/FLOAT(NDIV)
      S1F= DELN/2.0E+0
      DELM= 1.0E+0/FLOAT(MDIV)
      S2F= DELM/2.0E+0
      DELL= 1.0E+0/FLOAT(LDIV)
      S3F= DELL/2.0E+0
      S3=S3F
      DO 30 L=1,LDIV
      S1=S1F
      DO 20 N=1,NDIV
      S2=S2F
      DO 10 M=1,MDIV
      NP=NP+1
      IF(NP.GT.NPART) THEN
      IF (IBATCH.EQ.0)
     1WRITE (*,*) 'MAXIMUM NUMBER OF PARTICLES EXCEEDED. RUN STOPPED.'
      STOP
      END IF
      JLC(NP)=J
      ILC(NP)=I
      KLC(NP)=K
      XLC(NP)=S2
      YLC(NP)=S1
      ZLLC(NP)=S3
      S2=S2+DELM
10    CONTINUE
      S1=S1+DELN
20    CONTINUE
      S3=S3+DELL
30    CONTINUE
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE FACDIV (J,I,K,JLC,ILC,KLC,XLC,YLC,ZLLC,IS,NDIV,
     1MDIV,NPART,NP,IBATCH)
      DIMENSION JLC(NPART),ILC(NPART),KLC(NPART),XLC(NPART),YLC(NPART),
     1ZLLC(NPART)
C
      DELN= 1.0E+0/FLOAT(NDIV)
      S1F= DELN/2.0E+0
      DELM= 1.0E+0/FLOAT(MDIV)
      S2F= DELM/2.0E+0
      S1=S1F
      DO 20 N=1,NDIV
      S2=S2F
      DO 10 M=1,MDIV
      NP=NP+1
      IF(NP.GT.NPART) THEN
      IF (IBATCH.EQ.0)
     1WRITE (*,*) 'MAXIMUM NUMBER OF PARTICLES EXCEEDED. RUN STOPPED.'
      STOP
      END IF
      JLC(NP)=J
      ILC(NP)=I
      KLC(NP)=K
      IF(IS.EQ.1) THEN
      XLC(NP)=0.0001
      YLC(NP)=S1
      ZLLC(NP)=S2
      ELSE IF(IS.EQ.2) THEN
      XLC(NP)=0.9999
      YLC(NP)=S1
      ZLLC(NP)=S2
      ELSE IF(IS.EQ.3) THEN
      XLC(NP)=S1
      YLC(NP)=0.0001
      ZLLC(NP)=S2
      ELSE IF(IS.EQ.4) THEN
      XLC(NP)=S1
      YLC(NP)=0.9999
      ZLLC(NP)=S2
      ELSE IF(IS.EQ.5) THEN
      XLC(NP)=S1
      YLC(NP)=S2
      ZLLC(NP)=0.0001
      ELSE IF(IS.EQ.6) THEN
      XLC(NP)=S1
      YLC(NP)=S2
      ZLLC(NP)=0.9999
      END IF
      S2=S2+DELM
10    CONTINUE
      S1=S1+DELN
20    CONTINUE
      RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE SLFTYP(ITYPE,IU,IO,IOPT)
      CHARACTER*132 LINE
C
      ITYPE=1
      IOPT=0
      REWIND(IU)
      READ(IU,'(A)',END=100) LINE
      IF(LINE(1:11).EQ.'@ [ MODPATH') THEN
       WRITE(IO,*) ' '
       WRITE(IO,*)' STARTING LOCATIONS WILL BE READ FROM ENDPOINT FILE.'
       WRITE(IO,*) ' '
       ITYPE=2
       CALL UPCASE2(LINE)
       N= INDEX(LINE,'ACTIVE')
       IF(N.GT.0) IOPT=IOPT+1
       N= INDEX(LINE,'AUTOMATIC')
       IF(N.GT.0) IOPT=IOPT+10
       N= INDEX(LINE,'TERMINATED')
       IF(N.GT.0) IOPT=IOPT+100
       IF(IOPT.EQ.0) IOPT=1
       N= INDEX(LINE,'(COMPACT)')
       IF(N.GT.0) IOPT= -IOPT
      ELSE
       REWIND(IU)
      END IF
100   RETURN
      END
 
C***** SUBROUTINE *****
      SUBROUTINE EPSLOC(IU,IO,IOPT,J,I,K,X,Y,Z,JC,IC,KC,TRLS,IQUIT,
     1                  NCOL,NROW)
      CHARACTER*200 LINE
      CHARACTER*1 INLINE
      INLINE= '@'
C
      JC=1
      IC=1
      KC=0
      TRLS=0.0
      IACTIV=1
      IAUTO=0
      ITERM=0
      ISTAND=1
      NN=IOPT
      IF(NN.LT.0)ISTAND=0
      IF(NN.LT.0) NN= -NN
      IF(NN.EQ.10 .OR. NN.EQ.100 .OR. NN.EQ.110) IACTIV=0
      IF(NN.EQ.10 .OR. NN.EQ.11 .OR. NN.EQ.110 .OR. NN.EQ.111) IAUTO=1
      IF(NN.GE.100) ITERM=1
      IQUIT=0
10    READ(IU,'(A)',END=100) LINE
      IF(LINE(1:1).EQ.INLINE) GO TO 10
      IF(ISTAND.EQ.1) THEN
        ICOL=1
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,0,IDUMMY,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,2,J,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,2,I,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,2,K,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,X,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,Y,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,ZGLOB,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,Z,IO,IU)
        DO 11 N=1,9
11      CALL URWORD(LINE,ICOL,IFIRST,ILAST,0,IDUMMY,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,2,IPCODE,RDUMMY,IO,IU)
      ELSE
        ICOL=1
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,0,IDUMMY,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,2,NODE,RDUMMY,IO,IU)
        CALL ND2IJK(NODE,I,J,K,NROW,NCOL)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,X,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,Y,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,3,IDUMMY,Z,IO,IU)
        DO 12 N=1,7
12      CALL URWORD(LINE,ICOL,IFIRST,ILAST,0,IDUMMY,RDUMMY,IO,IU)
        CALL URWORD(LINE,ICOL,IFIRST,ILAST,2,IPCODE,RDUMMY,IO,IU)
      END IF
 
      KEEP=0
      IF(IPCODE.GE.0) THEN
        IDCODE=MOD(IPCODE,10)
        IF(IACTIV.EQ.1 .AND. IDCODE.EQ.0) KEEP=1
        IF(ITERM.EQ.1  .AND. IDCODE.EQ.1) KEEP=1
        IF(IAUTO.EQ.1  .AND. IDCODE.EQ.2) KEEP=1
      END IF
      IF(KEEP.EQ.1) RETURN
      GO TO 10
100   IQUIT=1
      RETURN
      END
