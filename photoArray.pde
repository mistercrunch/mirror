//import java.io

class photoArray{

  PImage [] images;
  int nbImage;
  
  photoArray(String path)
  {
    File myDir = new File(path);
    if( myDir.exists() && myDir.isDirectory())
    {
      
      File[] files = myDir.listFiles();
      images = new PImage[files.length];
      nbImage=files.length;
      for(int i=0; i < files.length; i++)
      {
        //println(files[i]);
        
        images[i] = loadImage((String)files[i].getPath());
      }
    }
  }
  
};

