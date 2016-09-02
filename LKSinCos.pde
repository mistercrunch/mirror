class LkpSinCos
{
  float sinLUT[];
  float cosLUT[];
 
  // set table precision to 0.5 degrees
  float SC_PRECISION, SC_INV_PREC;
  int SC_PERIOD;
 
LkpSinCos()
{
  //Default presicion is 1 degree
  this(1);
}
LkpSinCos(float fPrecision) {
  
  SC_PRECISION = fPrecision;
  SC_INV_PREC = 1/SC_PRECISION;
  SC_PERIOD = (int) (360f / SC_INV_PREC);
 
  sinLUT = new float[SC_PERIOD];
  cosLUT = new float[SC_PERIOD];
  
  for (int i = 0; i < SC_PERIOD; i++) {
    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SC_INV_PREC);
    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SC_INV_PREC);
  }
}
 
 float lkpSin(float fDegree)
 {
   fDegree %= SC_PERIOD;
   return sinLUT[(int) (fDegree * SC_INV_PREC)];
 }
 float lkpCos(float fDegree)
 {
   return cosLUT[(int) (fDegree * SC_INV_PREC)];
 }
};
