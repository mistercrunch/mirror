
import processing.opengl.*;
//import javax.media.opengl.*;
//import com.sun.opengl.util.texture.*;

//Vas for autopilot
boolean autoPilot=true;
long lastChange=0;
long modeDuration=10000;//milliseconds

int nbMode=7;

photoArray bacon;
photoArray pig;
photoArray kevin;

long imgMillis;
int previousMode;
import processing.video.*;

colLookup irC;
lkpMirror mirror;

//specific to mode 5
int minSquareSize =5;
int maxSquareSize =20;
int squareSize =10;
boolean bGoingUp;

int iRange=30;

int numPixels;
int[] previousFrame;

boolean bEvent=false;
color cRef=color(255);
color cBlack=color(0);
color cBack = color(0);
color cWhite = color(255);
float newHue;
boolean bFlag = true;
int cHue;
  
Capture video;

void setup() {
  colorMode(HSB,256);
  background(0);
  frameRate(30);
  size(640, 480, P2D); // Change size to 320 x 240 if too slow at 640 x 480
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height, 90);
  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  irC = new colLookup();
  mirror = new lkpMirror(width, height);
  bacon = new photoArray("C:/Documents and Settings/Administrator/My Documents/Processing/Contour/baconpic");
  pig = new photoArray("C:/Documents and Settings/Administrator/My Documents/Processing/Contour/pigpic");
  kevin = new photoArray("C:/Documents and Settings/Administrator/My Documents/Processing/Contour/kevinpic");
}

int mode=1;

void draw() {
  //println(frameRate);
  
  loadPixels();
  
  if (video.available()) 
  {
      
      video.read(); // Read the new frame from the camera
      video.loadPixels(); // Make its pixels[] array available
      if(mode==0)
      {
        for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
            pixels[mirror.pos[i]] = video.pixels[i];
            //pixels[i] = video.pixels[i];
        }
      }
      else if (mode==1)
      {
        if(bEvent)
        {
            if(cRef==cBlack) 
            {
              cRef=cWhite;
              cBack=cBlack;
            }
            else
            {
              cRef=cBlack;
              cBack=cWhite;
            }
            bEvent=false;
        }
          
        fill(cBack);
        rect(0,0,width,height);
        
        for (int i = width+1; i < numPixels-(width+1); i++) { // For each pixel in the video frame...


          int grayScale = GetGrayScale(video.pixels[i]);

          int totalDiff = abs(grayScale - GetGrayScale(video.pixels[i-1]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i+1]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i-width]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i+width]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i-(width+1)]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i-(width-1)]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i+(width+1)]));
          totalDiff += abs(grayScale - GetGrayScale(video.pixels[i+(width-1)]));
        
          if (totalDiff> 50)
            pixels[mirror.pos[i]] = cRef;
          //pixels = tmpFrame;
        }
      } else if (mode==2) 
      {
        if(bEvent)
        {
          if (cBack==cBlack)
            cBack = cWhite;
          else
            cBack = cBlack;
          bEvent=false;
        }
        fill(cBack, 150);
        rect(0,0, width, height);
        cRef = CycleHue(cRef, 15);
        //cBack = CycleHue(cBack, 7);
        
        for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
          if ((GetGrayScale(video.pixels[i]) > 355))
            pixels[mirror.pos[i]] = cRef;
          
        }
      }else if (mode==3) 
      {
        if(bEvent)
        {
          for (int i = 0; i < numPixels; i++) previousFrame[i]=765;
          bEvent=false;
        }
                
        //Infrared colors with trail
        for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
          int g = GetGrayScale(video.pixels[i]);
          if(g>previousFrame[i])
            g = (int) (previousFrame[i]+ ((g-previousFrame[i]) *0.60));
          else
            g = (int) (previousFrame[i]+ ((g-previousFrame[i]) *0.03));
          
          pixels[mirror.pos[i]] = irC.col[g];
          previousFrame[i] = (int)g;
        }    
      }
      else if (mode==4) 
      {
        //Frame differencing with traces while cycling colors
        if(bEvent)
        {
          fill(color(0,255,255));
          rect(0,0, width, height);
          bEvent=false;
        }
        else
        {
          fill(0, 20);
          rect(0,0, width, height);
        }
        cRef = CycleHue(cRef, 10);
        
        for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
          float g = GetGrayScale(video.pixels[i]);
          if(abs(g-previousFrame[i]) > 70)
            pixels[mirror.pos[i]] = cRef;
            
          previousFrame[i] = (int)g;
        }    
      }
      else if (mode==5) 
      {
        stroke(1);
        if(bEvent)
        {
          minSquareSize=(int)random(5)+5;
          maxSquareSize=(int)random(50)+5;
          squareSize=6;
          if(minSquareSize > maxSquareSize)
          {
            int t = minSquareSize;
            minSquareSize= maxSquareSize;
            maxSquareSize = t;
          }  
          bEvent = false;
        }
        
        if(bGoingUp) squareSize+=1;
        else squareSize-=1;
        
        if(squareSize>maxSquareSize || squareSize < minSquareSize)
          bGoingUp=!bGoingUp;
        
        for(int x=0; x<(width/squareSize)+1; x++)
        {
          for(int y=0; y<(height/squareSize)+1; y++)
          {
            float b = brightness(video.get(x * squareSize,y* squareSize));
            fill((int)random(255), 255, b);
            rect(width-(x * squareSize),y* squareSize,squareSize,squareSize);
          }
        }  
      }
      else if (mode==6) 
      {
        noStroke();
        if(bEvent)
        {
          squareSize = (int)random(5)+4;
          iRange = (int)random(200);
          cHue = (int)random(255);
          
          bEvent=false;
        }
        fill(0,20);
        rect(0,0,width,height);
        
        updatePixels();
        loadPixels();
        for (int i = numPixels-1; i >= width*2; i--) { 
          pixels[i] = pixels[i-width*2];
        }
        for (int i = 0; i < width*2; i++) { 
          pixels[i] = cBlack;
        }
        
        
        for(int x=0; x<(width/squareSize)+1; x++)
        {
          for(int y=0; y<(height/squareSize)+1; y++)
          {
            float b = brightness(video.get(x * squareSize,y* squareSize));
            
            if(b>80)
            {
              float daHue = cHue + random(iRange) - (iRange/2);
              if(daHue>255)daHue-=255;
              else if(daHue<0)daHue=255+daHue;
              fill(daHue, 255, b);
              rect(width-(x * squareSize),y* squareSize,squareSize,squareSize);
            }
          }
        }  
      }
      else if (mode==7) 
      {
        //Frame differencing with traces while cycling colors
        if(bEvent)
        {
           cBack = color((int)random(255),255,255);
           bEvent =false;
           if(cRef == cWhite)
             cRef = cBlack;
           else
             cRef = cWhite;
        }
        
        fill(cBack,30);
        rect(0,0,width,height);
        
     
        for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
          float g = GetGrayScale(video.pixels[i]);
          if(abs(g-previousFrame[i]) > 70)
          {  
              pixels[mirror.pos[i]] = cRef;
          }  
          previousFrame[i] = (int)g;
        }    
      }
      else if (mode==666)
      {
        
      }
  }
  updatePixels();
  HandleAutoPilot();
}
void keyPressed()
{
  if(key=='1')
  {
     mode=1;
     cRef=cWhite;
     cBack=cBlack;
  }
  else if(key=='2')
  {
    mode=2;
    cBack=cBlack;
  }
  else if(key=='3')
  {  
    mode=3;
    bEvent = true;
  }
  else if(key=='4')mode=4;
  else if(key=='5')mode=5;
  else if(key=='6')
    {
      mode=6;
      bEvent = true;
    }
  else if(key=='0')mode=0;
  else if(key=='7'){
      mode=7;
      bEvent = true;
    }
  else if(key=='e')
  {
    bEvent = true;
  }
  else if(key=='b')
  {
    image(bacon.images[(int)random(bacon.nbImage)],0,0,width,height);
    mode=666;
  }
  else if(key=='p')
  {
    image(pig.images[(int)random(pig.nbImage)],0,0,width,height);
    mode=666;
  }
  else if(key=='k')
  {
    image(kevin.images[(int)random(kevin.nbImage)],0,0,width,height);
    mode=666;
  }
  else if(key=='a')
  {
    autoPilot=!autoPilot;
  }
}

int GetGrayScale(color c)
{
        int currR = (c >> 16) & 0xFF; // Like red(), but faster
        int currG = (c >> 8) & 0xFF;
        int currB = c & 0xFF;
 
        // Add these differences to the running tally
        return currR + currG + currB;
}

color CycleHue(color c, float RaiseBy)
{
  float fHue = hue(c) + RaiseBy;
  if (fHue>255) fHue-=255;
  return color(fHue, 255, 255);
}

int Mirror(int ipos)
{
  //returns the corresponding pixel position to mirror it
  int i = ((ipos / width) * width) + width-(ipos % width) ;
  return i-1;
}

void HandleAutoPilot()
{
  if(autoPilot)
  {
    fill(0);
    stroke(255);
    rect(2,2,20,2);
    fill(128);
    rect(2,2, 20*(((float)millis()-(float)lastChange)/(float)modeDuration),2);
    if((lastChange + modeDuration) < millis())
    {
      //changing mode
      mode = (int) random(nbMode) + 1;
      lastChange= millis();
      modeDuration = 2000+(int)random(20000);
    }
    
    if((int)random(100)==1)bEvent=true;
    
    if (mode==666)
      mode=previousMode;
    
    if((int)random(5000)==1)
    {
      image(kevin.images[(int)random(kevin.nbImage)],0,0,width,height);
      previousMode=mode;
      mode=666;
    }
    if((int)random(400)==1)
    {
      image(bacon.images[(int)random(bacon.nbImage)],0,0,width,height);
      previousMode=mode;
      mode=666;
    }
    if((int)random(1000)==1)
    {
      image(pig.images[(int)random(pig.nbImage)],0,0,width,height);
      previousMode=mode;
      mode=666;
    }
  }
}
