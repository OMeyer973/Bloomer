// small app to add bloom layers to an image

import controlP5.*;

int bloomRadius = 5;
float bloomIntensity = 0.5;
float bloomThreshold = 0.8;

int UIX = 600, UIY = 110;
int sizeX = UIX, sizeY = UIY; //must be the size of the input image


//computing variables  
String diffusePath, diffuseName;
PImage diffuse;
PImage bloomLayer;
boolean init = false;
boolean running = false;

//GUI variables
ControlP5 cp5;

//export variables

void settings() {
  
  size(sizeX, sizeY);
}

  
void setup () {
  //initialisation of variables
  background(0);
  noStroke();
  cp5 = new ControlP5(this);
  
   cp5.addButton("selectFile")
   .setLabel("select picture")
   .setPosition(10,10)
   .setSize(90,20)
   ;
   
   cp5.addButton("computeBloom")
   .setLabel("add bloom")
   .setPosition(120,10)
   .setSize(90,20)
   ;
      
   cp5.addButton("resetImage")
   .setLabel("reset image")
   .setPosition(230,10)
   .setSize(90,20)
   ;
  
   cp5.addButton("export")
   .setLabel("export image")
   .setPosition(340,10)
   .setSize(90,20)
   ;
    
   cp5.addSlider("bloomRadius")
     .setLabel("bloom radius")
     .setPosition(10,40)
     .setSize(500,10)
     .setRange(0,300)
     ;
     
   cp5.addSlider("bloomIntensity")
     .setLabel("bloom intensity")
     .setPosition(10,60)
     .setSize(500,10)
     .setRange(0,1)
     ;
     
  cp5.addSlider("bloomThreshold")
     .setLabel("bloom threshold")
     .setPosition(10,80)
     .setSize(500,10)
     .setRange(0,1)
     ;
}

void draw () {
  if (running) {
    image(diffuse,0,UIY);
  }
}

void exchange2Pixels(PImage diffuse) {
  int x = (int)random(0, sizeX-1);
  int y = (int)random(0, sizeY-1);
  color pixelColor = diffuse.get(x,y);
    
  diffuse.set(x,  y,  pixelColor);
}

void selectFile() {
  running = false;
  println("select a file");
  selectInput("Select an image to ditter", "diffuseSelected");
}

void diffuseSelected(File selection) {
  if (selection == null) {
    println("image import got cancelled");
  } else {
    diffusePath = selection.getAbsolutePath();
    diffuseName = selection.getName();
    resetImage();
  }
}

void resetImage() {
  diffuse = loadImage(diffusePath);
  sizeX = diffuse.width;
  sizeY = diffuse.height;
  surface.setSize(max(sizeX, UIX),sizeY+UIY);
  running = true;
 }
 
 void computeBloom() {
   bloomLayer = diffuse.copy();
   bloomLayer.filter(THRESHOLD, bloomThreshold);
   bloomLayer.filter(BLUR, bloomRadius);
   diffuse = sumImages(diffuse, bloomLayer);
   //diffuse = bloomLayer;
 }

PImage sumImages(PImage img1, PImage img2) {
  PImage out = img1.copy();
  if (img1.height == img2.height && img1.width == img2.width) {
    for (int y=0; y<img1.height; y++) {
      for (int x=0; x<img1.width; x++) {
        color c = color(
          constrain(red(img1.get(x,y)) + red(img2.get(x,y)) * bloomIntensity, 0, 255),
          constrain(green(img1.get(x,y)) + green(img2.get(x,y)) * bloomIntensity, 0, 255), 
          constrain(blue(img1.get(x,y)) + blue(img2.get(x,y)) * bloomIntensity, 0, 255)
        );
        out.set(x, y, c); 
      }
    }
  } else {
    print("error : the 2 PImages to sum must have the same dimensions");
  }
  return out;
}
 
 void export() {
   diffuse.save(diffuseName + "_out-" + year() + month() + day() + hour() + minute() + second() + ".png");
   javax.swing.JOptionPane.showMessageDialog(null,"Saved file : " + diffuseName + "_out-" + year() + month() + day() + hour() + minute() + second() + ".png");
 }