class lkpMirror
{
  int pos[];
  
  lkpMirror(int dawidth, int daheight)
  {
    pos = new int[dawidth*daheight];
    int i=0;
    for(int y=0; y<daheight; y++)
    {
      for(int x=0; x<dawidth; x++)
      {
        pos[i] = (y * dawidth + (width-x-1));
        i++;
      }
    }   
  }
};
