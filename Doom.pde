/*=============================================//
  Ryan Darge  3d Camera Movement
   
  Date      Log
  ----      ---
  09/20/10  Project Started
  09/21/10  Added:
              -LookMode 3
              -Spotlight View Options
              -XYZ Movement
              -Jumping             
  09/23/10  Added:
              -LookMode 4
              -MoveMode 2
              -LookMode 5
            Fixed:
              -Small bug in arrow key movement (right would register as left)
  09/25/10  Added:
              -LookMode 6
              -LookMode 7
              -LookMode 8
            Fixed:
              -MoveMode 2
  09/27/10  Added:
              -SpotLightMode 4
            Fixed:
              -LookMode 8
              
  BUGLIST:
    -All fixed?
   
  Notes:
  I have to go through and add comments before
  I actually upload this -.- 
   
  Bharath gave me this to look at:
  loc.x+cos(relative+radians(90))*(senoffset)
  loc.y+sin(relative+radians(90))*(senoffset)
//=============================================*/
 
 
//Global Variables
 
  //Environment Variables
    //How am make arrysss?!
 
  //Camera Variables
    float x,y,z;
    float rotateX,ty,rotateZ;
    float rotX,rotY;
    float mX, mY;
    float frameCounter;
    float xComp, zComp;
    float angle;
 
  //Movement Variables
    int moveX;
    int moveZ;
    float vY;
    boolean canJump;
    boolean moveUP,moveDOWN,moveLEFT,moveRIGHT;
     
 
//Constants
  int ground = 0;
  int totalBoxes = 20;
  int standHeight = 100;
  int dragMotionConstant = 10;
  int pushMotionConstant = 100;
  int movementSpeed = 50;    //Bigger number = slower
  float sensitivity = 15;      //Bigger number = slower
  int centerBox = 80;        /* This used mainly for mouse smoothness. Creates a virtual invisible box, when the mouse leaves it, the rotation begins */
  float camBuffer = 10;
  int cameraDistance = 1000;  //distance from camera to camera target in lookmode... 8?
  int floorSize = 1600;
  float floorTiling = 6.5f;
   
//Options
  int lookMode = 8;
  int spotLightMode = 4;
  int cameraMode = 1;
  int moveMode = 2;
  
  /************************* Textures  **********************/
  PImage concreteFloor;
  PImage brownWalls;
  PImage handGun;
  
  /* Weapon */
  PGraphics weapon;
  int wi = 200, hi = 200;
 
void setup(){
  size(800,600,P3D);
  noStroke();
   
  //Camera Initialization
  x = width/2;
  y = height/2;
    y-= standHeight;
  z = (height/2.0) / tan(PI*60.0 / 360.0);
  rotateX = width/2;
  ty = height/2;
  rotateZ = 0;
  rotX = 0;
  rotY = 0;
  xComp = rotateX - x;
  zComp = rotateZ - z;
  angle = 0;
   
  //Movement Initialization
  moveX = 0;
  moveX = 0;
  moveUP = false;
  moveDOWN = false;
  moveLEFT = false;
  moveRIGHT = false; 
  canJump = true;
  vY = 0;
  
  /* Texture Initilization */
  concreteFloor = loadImage("Concrete Floor.gif");
  brownWalls = loadImage("Walls.png");
  handGun = loadImage("9mm.png");
 
  weapon = createGraphics(wi, hi, P3D);

    //weapon.box(100);
}
 
 
void draw(){
   
  //update frame

  pushMatrix();
    weapon.beginDraw();
      weapon.background(255, 0);
    weapon.scale(200);
            weapon.noStroke();
    weapon.beginShape(TRIANGLE_STRIP);
    weapon.texture(handGun);
    weapon.textureMode(NORMAL);
    weapon.vertex(0, 0, 0,  0, 0);
    weapon.vertex(0, 1, 0, 0, 1);
    weapon.vertex(1, 0, 0, 1, 0);
    weapon.vertex(1, 1, 0, 1, 1);
    weapon.endShape();
    weapon.endDraw();
    popMatrix();
    
      background(0);

   hint(ENABLE_DEPTH_TEST);
  if(spotLightMode == 0)
    lights();
  else if(spotLightMode == 1)
    spotLight(255,255,255,x,y-standHeight,z,rotateX,ty,rotateZ,PI,1);
  else if(spotLightMode == 2)
    spotLight(255,255,255,x,y-standHeight-200,z,x+100,y+100,z,frameCounter/10,1);
  else if(spotLightMode == 3)
    spotLight(255,255,255,width/2,height/2-1000,0,width/2,height/2,0,PI,1);
  else if(spotLightMode == 4)
    //ambientLight(255,255,255,x,y,z);
   
  
    //Draw Boxes
     pushMatrix();
      translate(width/2, height/2,100);
//    translate(width/2,height/2);
//    fill((x1/totalBoxes)*255,255,(z1/totalBoxes)*255,random(250,255));
      fill(255,0,0);
      box(800); 
      popMatrix();
      
      //Draw Boxes
     pushMatrix();
      translate(width/2, height/2,100);
      rotateX(radians(90));
//    translate(width/2,height/2);
//    fill((x1/totalBoxes)*255,255,(z1/totalBoxes)*255,random(250,255));
        beginShape(QUADS);
          texture(concreteFloor);
          textureMode(NORMAL);
          textureWrap(REPEAT);
          vertex(floorSize, -floorSize, -1, 0, 0);
          vertex(-floorSize, -floorSize, -1, floorTiling, 0);
          vertex(-floorSize,  floorSize, -1, floorTiling, floorTiling);
          vertex( floorSize,  floorSize, -1, 0, floorTiling);
       endShape();
          //box(800); 
      popMatrix();
   
  cameraUpdate();
  locationUpdate();
  jumpManager(10);
   
  //Camera Mode 1 - Original
  if(cameraMode == 1)
    camera(x,y,z,rotateX,ty,rotateZ,0,1,0);
    
   pushMatrix();
   camera();
   hint(DISABLE_DEPTH_TEST);
   image(weapon, width/2, height - hi);
   popMatrix();
   
  frameCounter++;
   

   
}
 
public void cameraUpdate(){
  if (lookMode == 8){
    int diffX = mouseX - width/2;
    int diffY = mouseY - width/2; /* The width of the screen is more, this is used in order to have the same speed between axis */
     
     /* Camera rotation in X */
    if(abs(diffX) > centerBox){ /* If you are outside the box */
      xComp = rotateX - x; 
      zComp = rotateZ - z;
      angle = correctAngle(xComp,zComp);
        
      angle+= diffX/(sensitivity*10);
       
      if(angle < 0)
        angle += 360;
      else if (angle >= 360)
        angle -= 360;
       
      float newXComp = cameraDistance * sin(radians(angle));
      float newZComp = cameraDistance * cos(radians(angle));
       
      rotateX = newXComp + x;
      rotateZ = -newZComp + z;
     
      //---------DEBUG STUFF GOES HERE----------
      println("rotateX:    " + rotateX);
      println("rotateZ:    " + rotateZ);
     /* println("xC:    " + xComp);
      println("NewXC: " + newXComp);
      println("zC:    " + zComp);
      println("NewZC: " + newZComp);
      println("Angle: " +angle);*/
      println("X: " +x);
      println("Y: " +z);
      //--------------------------------------*/
        
    }
            
    if (abs(diffY) > centerBox)
      ty += diffY/(sensitivity/1.5);
  }
  
  /* Weapon */


   

   
}
 
public void locationUpdate(){
  
   /*******************************************/
   /****************** Movement ***************/
   /*******************************************/
  if(moveMode == 2){
    if(moveUP){
      z += zComp/movementSpeed;
      rotateZ+= zComp/movementSpeed;
      x += xComp/movementSpeed;
      rotateX+= xComp/movementSpeed;
    }
    if(moveDOWN){
      z -= zComp/movementSpeed;
      rotateZ-= zComp/movementSpeed;
      x -= xComp/movementSpeed;
      rotateX-= xComp/movementSpeed;
    }
    if (moveRIGHT){
      z += xComp/movementSpeed;
      rotateZ+= xComp/movementSpeed;
      x -= zComp/movementSpeed;
      rotateX-= zComp/movementSpeed;
    }
    if (moveLEFT){
      z -= xComp/movementSpeed;
      rotateZ-= xComp/movementSpeed;
      x += zComp/movementSpeed;
      rotateX+= zComp/movementSpeed;
    }
        
  }
  //New method also uses keyPressed() and keyReleased()
  // Scroll Down!
}
 
public void jumpManager(int magnitude){
   
  if(keyPressed && key == ' ' && canJump){
    vY -= magnitude;
    if(vY < -20)
      canJump = false;
  }
  else if (y < ground+standHeight)
    vY ++;
  else if (y >= ground+standHeight){
    vY = 0;
    y = ground + standHeight;
  }
   
  if((!canJump) && (!keyPressed)){
    println("Jump Reset!");
    canJump = true;
  }
     
  y += vY;
}
 
public void keyPressed(){
  if(keyCode == UP || key == 'w'){
    moveZ = -10;
    moveUP = true;
  }
   
  else if(keyCode == DOWN || key == 's'){
    moveZ = 10;
    moveDOWN = true;
  }
   
  else if(keyCode == LEFT || key == 'a'){
    moveX = -10;
    moveLEFT = true;
  }
   
  else if(keyCode == RIGHT || key == 'd'){
    moveX = 10;
    moveRIGHT = true;
  }
}
 
public void keyReleased(){
  if(keyCode == UP || key == 'w'){
    moveUP = false;
    moveZ = 0;
  }
  else if(keyCode == DOWN || key == 's'){
    moveDOWN = false;
    moveZ = 0;
  }
     
  else if(keyCode == LEFT || key == 'a'){
    moveLEFT = false;
    moveX = 0;
  }
   
  else if(keyCode == RIGHT || key == 'd'){
    moveRIGHT = false;
    moveX = 0;
  }
}
 
public float correctAngle(float xc, float zc){
  float newAngle = -degrees(atan(xc/zc));
  if (xComp > 0 && zComp > 0)
    newAngle = (90 + newAngle)+90;
  else if (xComp < 0 && zComp > 0)
    newAngle = newAngle + 180;
  else if (xComp < 0 && zComp < 0)
    newAngle = (90+ newAngle) + 270;
  return newAngle;
}
 
/*Conclusions:
  Increasing ty rotates field of view down
    vice versa for reverse
     
  Increasing tX rotates field of view right */
    
