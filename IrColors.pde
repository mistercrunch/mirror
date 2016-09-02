class colLookup
{
  int col[];
 
  colLookup()
  {
    colorMode(HSB,256);
    int nbGrayScale = 768;
    col = new int[nbGrayScale];
    float perc;
    for(int i=0; i<nbGrayScale; i++)
    {
      perc = 255- (255 *((float)i/(float)nbGrayScale));
      
      col[i] = color(perc,255,255-perc);
    }
  }
};
