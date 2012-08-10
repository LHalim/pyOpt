* SUBROUTINE PLADR1               ALL SYSTEMS                97/12/01
C PORTABILITY : ALL SYSTEMS
C 97/12/01 LU : ORIGINAL VERSION
*
* PURPOSE :
* TRIANGULAR DECOMPOSITION OF KERNEL OF THE GENERAL PROJECTION
* IS UPDATED AFTER CONSTRAINT ADDITION.
*
* PARAMETERS :
*  II  NF  DECLARED NUMBER OF VARIABLES.
*  IU  N  ACTUAL NUMBER OF VARIABLES.
*  IU  ICA(NF)  VECTOR CONTAINING INDICES OF ACTIVE CONSTRAINTS.
*  RI  CG(NF*NC)  MATRIX WHOSE COLUMNS ARE NORMALS OF THE LINEAR
*         CONSTRAINTS.
*  RI  CR(NF*(NF+1)/2)  TRIANGULAR DECOMPOSITION OF KERNEL OF THE
*         ORTHOGONAL PROJECTION.
*  RU  H(NF*(NF+1)/2)  TRIANGULAR DECOMPOSITION OR INVERSION OF THE
*         HESSIAN MATRIX APPROXIMATION.
*  RA  S(NF)  AUXILIARY VECTOR.
*  RO  G(NF)  VECTOR USED IN THE DUAL RANGE SPACE QUADRATIC PROGRAMMING
*         METHOD.
*  RI  EPS7  TOLERANCE FOR LINEAR INDEPENDENCE OF CONSTRAINTS.
*  RO  GMAX  MAXIMUM ABSOLUTE VALUE OF A PARTIAL DERIVATIVE.
*  RO  UMAX  MAXIMUM ABSOLUTE VALUE OF A NEGATIVE LAGRANGE MULTIPLIER.
*  RO  E  AUXILIARY VARIABLE.
*  RI  T  AUXILIARY VARIABLE.
*  IU  IDECF  DECOMPOSITION INDICATOR. IDECF=0-NO DECOMPOSITION.
*         IDECF=1-GILL-MURRAY DECOMPOSITION. IDECF=9-INVERSION.
*         IDECF=10-DIAGONAL MATRIX.
*  II  INEW  INDEX OF THE NEW ACTIVE CONSTRAINT.
*  IU  NADD  NUMBER OF CONSTRAINT ADDITIONS.
*  IO  IER  ERROR INDICATOR.
*  II  JOB  SPECIFICATION OF COMPUTATION. OUTPUT VECTOR G IS NOT OR IS
*         COMPUTED IN CASE WHEN N.LE.0 IF JOB=0 OR JOB=1 RESPECTIVELY.
*
* SUBPROGRAMS USED :
*  S   MXDPGB  BACK SUBSTITUTION.
*  S   MXDPRB  BACK SUBSTITUTION.
*  S   MXDSMM  MATRIX-VECTOR PRODUCT.
*  S   MXDSMV  COPYING OF A ROW OF DENSE SYMMETRIC MATRIX.
*  S   MXVCOP  COPYING OF A VECTOR.
*  RF  MXVDOT  DOT PRODUCT OF TWO VECTORS.
*
      SUBROUTINE PLADR1(NF,N,ICA,CG,CR,H,S,G,EPS7,GMAX,UMAX,IDECF,
     & INEW,NADD,IER,JOB)
      INTEGER NF,N,ICA(*),IDECF,INEW,NADD,IER,JOB
      DOUBLE PRECISION CG(*),CR(*),H(*),S(*),G(*),EPS7,GMAX,UMAX
      DOUBLE PRECISION MXVDOT
      INTEGER NCA,NCR,JCG,J,K,L
      IER=0
      IF (JOB.EQ.0.AND.N.LE.0) IER=2
      IF (INEW.EQ.0) IER=3
      IF (IDECF.NE.1.AND.IDECF.NE.9) IER=-2
      IF (IER.NE.0) RETURN
      NCA=NF-N
      NCR=NCA*(NCA+1)/2
      IF (INEW.GT.0) THEN
      JCG=(INEW-1)*NF+1
      IF (IDECF.EQ.1) THEN
      CALL MXVCOP(NF,CG(JCG),S)
      CALL MXDPGB(NF,H,S,0)
      ELSE
      CALL MXDSMM(NF,H,CG(JCG),S)
      ENDIF
      GMAX=MXVDOT(NF,CG(JCG),S)
      ELSE
      K=-INEW
      IF (IDECF.EQ.1) THEN
      CALL MXVSET(NF,0.0D0,S)
      S(K)=1.0D 0
      CALL MXDPGB(NF,H,S,0)
      ELSE
      CALL MXDSMV(NF,H,S,K)
      ENDIF
      GMAX=S(K)
      ENDIF
      DO 1 J=1,NCA
      L=ICA(J)
      IF (L.GT.0) THEN
      G(J)=MXVDOT(NF,CG((L-1)*NF+1),S)
      ELSE
      L=-L
      G(J)=S(L)
      ENDIF
    1 CONTINUE
      IF (N.EQ.0) THEN
      CALL MXDPRB(NCA,CR,G,1)
      UMAX=0.0D0
      IER=2
      RETURN
      ELSE IF (NCA.EQ.0) THEN
      UMAX=GMAX
      ELSE
      CALL MXDPRB(NCA,CR,G,1)
      UMAX=GMAX-MXVDOT(NCA,G,G)
      CALL MXVCOP(NCA,G,CR(NCR+1))
      ENDIF
      IF (UMAX.LE.EPS7*GMAX) THEN
      IER=1
      RETURN
      ELSE
      NCA=NCA+1
      NCR=NCR+NCA
      ICA(NCA)=INEW
      CR(NCR)=SQRT(UMAX)
      IF (JOB.EQ.0) THEN
      N=N-1
      NADD=NADD+1
      ENDIF
      ENDIF
      RETURN
      END