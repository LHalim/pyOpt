* SUBROUTINE MXVDIR                ALL SYSTEMS                91/12/01
* PORTABILITY : ALL SYSTEMS
* 91/12/01 LU : ORIGINAL VERSION
*
* PURPOSE :
* VECTOR AUGMENTED BY THE SCALED VECTOR.
*
* PARAMETERS :
*  II  N  VECTOR DIMENSION.
*  RI  A  SCALING FACTOR.
*  RI  X(N)  INPUT VECTOR.
*  RI  Y(N)  INPUT VECTOR.
*  RO  Z(N)  OUTPUT VECTOR WHERE Z:= Y + A*X.
*
      SUBROUTINE MXVDIR(N,A,X,Y,Z)
      DOUBLE PRECISION A
      INTEGER N
      DOUBLE PRECISION X(*),Y(*),Z(*)
      INTEGER I
      DO 10 I = 1,N
          Z(I) = Y(I) + A*X(I)
   10 CONTINUE
      RETURN
      END