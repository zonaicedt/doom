import ddf.minim.*;
Minim minim;
AudioPlayer song;
 
//Global Variables
 
  //Environment Variables
  //NPC variables
  //NPC start position
    float positionX=0;
    float positionZ=1;
    float positionX2=0;
    float positionZ2=-1;
  //NPC Speed
    float speedX= 10;
    float speedZ= 15;
    float speedX2= 18;
    float speedZ2= 6;
  //character direction
    int xDirection=1;
    int zDirection=1;
    int xDirection2=1;
    int zDirection2=1;
  //Change Sprites
    int mov = 1;
    int mov2= 1;
  //Texture NPC variables
    int numFrames = 8;  // The number of frames in the animation
    int actualFrame = 0;
      
  //Camera Variables
    float x,y,z;
    float rotateX,ty,rotateZ;
    float rotX,rotY;
    float mX, mY;
    float frameCounter;
    float xComp, zComp;
    float angle;
  //Movement Variables
    boolean move =false;
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
  
  int FloorSize = 1600;
  float FloorTiling = 6.5f;
   
  //Options
  int lookMode = 8;
  int spotLightMode = 4;
  int cameraMode = 1;
  int moveMode = 2;
  
  /************************* Textures  **********************/
  int actualFrameWeapon = 0;
  int numFramesWeapon = 2;
  PImage[] enemyMove = new PImage[numFrames];
  PImage[] handGun = new PImage[numFramesWeapon];
  PImage handGunSolo;
  PImage Floor;
  PImage brownWalls;
  PImage bigWalls;
  
  PImage HUD, face; 
  boolean crouch = false;
  
  /* Weapon */
  PGraphics weapon, doomHUD; 
  int wi = 200, hi = 200;
 
void setup(){
  size(800,600,P3D);
  noStroke();
  
  //************************************************ START load texture 
  enemyMove[0] = loadImage("enemy/enemy-02.png");
  enemyMove[1] = loadImage("enemy/enemy-03.png");
  enemyMove[2] = loadImage("enemy/enemy-04.png");
  enemyMove[3] = loadImage("enemy/enemy-05.png");
  enemyMove[4] = loadImage("enemy/enemy-06.png");
  enemyMove[5] = loadImage("enemy/enemy-07.png");
  enemyMove[6] = loadImage("enemy/enemy-08.png");
  enemyMove[7] = loadImage("enemy/enemy-09.png");

  Floor = loadImage("rockFloor.jpg");
  brownWalls = loadImage("Walls.png");
  bigWalls = loadImage("Big wall.jpg");
  handGunSolo =loadImage("9mm.png");
  
  handGun[0] = loadImage("9mm_left.png");
  handGun[1] = loadImage("9mm_right.png");
   
  weapon = createGraphics(wi, hi, P3D); 
  
  HUD = loadImage("HUD.png");
  face = loadImage("face/face.png");
  doomHUD = createGraphics(width, hi, P2D); 
  
  //******************************************************* END load textures

/*
   minim = new Minim(this);
   song = minim.loadFile("E1.WAV");
   
   song.play();
*/
   
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

}
 
   void weapon()
{
     pushMatrix();
        weapon.beginDraw();
        weapon.background(255, 0);
        weapon.scale(200);
        weapon.noStroke();
        weapon.beginShape(TRIANGLE_STRIP);
       if(move == true){
          if(moveUP == true){weapon.texture(handGun[(actualFrameWeapon)]);}
          if(moveDOWN == true){weapon.texture(handGun[(actualFrameWeapon)]);}
          if(moveLEFT == true){weapon.texture(handGun[0]);}
          if(moveRIGHT == true){weapon.texture(handGun[1]);}     
        }
        if(move == false){weapon.texture(handGunSolo); }  
        weapon.textureMode(NORMAL);
        weapon.vertex(0, 0, 0,  0, 0);
        weapon.vertex(0, 1, 0, 0, 1);
        weapon.vertex(1, 0, 0, 1, 0);
        weapon.vertex(1, 1, 0, 1, 1);
        weapon.endShape();
        weapon.endDraw();
    popMatrix();  
   
 }
 void HUD()
 {
      doomHUD.beginDraw(); 
        doomHUD.beginShape();
            doomHUD.texture(HUD);
            doomHUD.vertex(0,0,0,0); 
            doomHUD.vertex(width, 0,HUD.width,0);
            doomHUD.vertex(width, 100, HUD.width,HUD.height);
            doomHUD.vertex(0, 100,0,HUD.height);
        doomHUD.endShape(); 
      doomHUD.endDraw(); 

       doomHUD.beginDraw();       
         noStroke();
         doomHUD.beginShape();
          doomHUD.texture(face);
          doomHUD.vertex(width/2-35,0,0,0); 
          doomHUD.vertex(width/2+35, 0, face.width,0);
          doomHUD.vertex(width/2+35, face.height-25, face.width, face.height);
          doomHUD.vertex(width/2-35, face.height-25, 0, face.height);
        doomHUD.endShape();
       doomHUD.endDraw();
       
 }
   
  void environment()
  {
    // START BIG WALLS
      pushMatrix();
      translate(FloorSize/2,height/2,FloorSize/2);
      beginShape();
      texture(bigWalls);
      vertex(FloorSize, 0, -FloorSize,0,0); 
      vertex(FloorSize, 0,  FloorSize, bigWalls.width,0);
      vertex(FloorSize, -512, FloorSize, bigWalls.width, bigWalls.height);
      vertex(FloorSize, -512, -FloorSize, 0,bigWalls.height);
      endShape();
      beginShape();
      texture(bigWalls);
      vertex(-FloorSize, 0, -FloorSize,0,0); 
      vertex(-FloorSize, 0,  FloorSize, bigWalls.width,0);
      vertex(-FloorSize, -512, FloorSize, bigWalls.width, bigWalls.height);
      vertex(-FloorSize, -512, -FloorSize, 0,bigWalls.height);
      endShape();
      beginShape();
      texture(bigWalls);
      vertex(-FloorSize, 0, -FloorSize,0,0); 
      vertex(FloorSize, 0,  -FloorSize, bigWalls.width,0);
      vertex(FloorSize, -512, -FloorSize, bigWalls.width, bigWalls.height);
      vertex(-FloorSize, -512, -FloorSize, 0,bigWalls.height);
      endShape();
      beginShape();
      texture(bigWalls);
      vertex(-FloorSize, 0, FloorSize,0,0); 
      vertex(FloorSize, 0,  FloorSize, bigWalls.width,0);
      vertex(FloorSize, -512, FloorSize, bigWalls.width, bigWalls.height);
      vertex(-FloorSize, -512, FloorSize, 0,bigWalls.height);
      endShape();
     popMatrix(); 
     //END MATRIX Big Walls     
     
     // START CELLING
      pushMatrix();
      translate(FloorSize/2, height/2,FloorSize/2);      
      beginShape();
      texture(bigWalls);
      vertex(-FloorSize, -512, -FloorSize,0,0); 
      vertex(FloorSize, -512,  -FloorSize, bigWalls.width,0);
      vertex(FloorSize, -512, FloorSize, bigWalls.width, bigWalls.height);
      vertex(-FloorSize, -512, FloorSize, 0,bigWalls.height);
      endShape();
      popMatrix();
    // END CELLING
    
   // START PLANE
       pushMatrix();
       translate(FloorSize/2, height/2, FloorSize/2); //MODIFIQUE DE 100 A 0 ************************           
         beginShape();
            texture(Floor);
            vertex(-FloorSize, 0, -FloorSize, 0, 0);
            vertex(FloorSize, 0, -FloorSize, Floor.width, 0);
            vertex(FloorSize,  0, FloorSize, Floor.width, Floor.height);
            vertex(-FloorSize,  0, FloorSize, 0, Floor.height);
         endShape();        
        popMatrix();
    //END PLANE
     
     
  //  START BOX 1
      //wall 1 
      pushMatrix();
      translate(FloorSize/2, height/2,FloorSize/2);
     
      beginShape();
      texture(brownWalls);
      vertex(-FloorSize+600, 0, FloorSize-1000,0,0); 
      vertex(-FloorSize+600, 0, FloorSize-600 ,brownWalls.width,0);
      vertex(-FloorSize+600, -512, FloorSize-600, brownWalls.width, brownWalls.height);
      vertex(-FloorSize+600, -512, FloorSize-1000,0,brownWalls.height);
      endShape(); 
      //wall 2
      beginShape();
      texture(brownWalls);
      vertex(-FloorSize+1000, 0, FloorSize-1000,0,0); 
      vertex(-FloorSize+1000, 0, FloorSize-600 ,brownWalls.width,0);
      vertex(-FloorSize+1000, -512, FloorSize-600, brownWalls.width, brownWalls.height);
      vertex(-FloorSize+1000, -512, FloorSize-1000,0,brownWalls.height);
      endShape();
      //wall 3
      beginShape();
      texture(brownWalls);
      vertex(-FloorSize+600, 0, FloorSize-1000,0,0); 
      vertex(-FloorSize+1000, 0, FloorSize-1000 ,brownWalls.width,0);
      vertex(-FloorSize+1000, -512, FloorSize-1000, brownWalls.width, brownWalls.height);
      vertex(-FloorSize+600, -512, FloorSize-1000,0,brownWalls.height);
      endShape();
      //wall 4
      beginShape();
      texture(brownWalls);
      vertex(-FloorSize+600, 0, FloorSize-600,0,0); 
      vertex(-FloorSize+1000, 0, FloorSize-600 ,brownWalls.width,0);
      vertex(-FloorSize+1000, -512, FloorSize-600, brownWalls.width, brownWalls.height);
      vertex(-FloorSize+600, -512, FloorSize-600,0,brownWalls.height);
      endShape();      
     
     //  START BOX 2
      //wall 1
      beginShape();
      texture(brownWalls);
      vertex(FloorSize-600, 0, -FloorSize+600,0,0); 
      vertex(FloorSize-600, 0, -FloorSize+1000 ,brownWalls.width,0);
      vertex(FloorSize-600, -512, -FloorSize+1000, brownWalls.width, brownWalls.height);
      vertex(FloorSize-600, -512, -FloorSize+600,0,brownWalls.height);
      endShape(); 
      //wall 2
      beginShape();
      texture(brownWalls);
      vertex(FloorSize-1000, 0, -FloorSize+600,0,0); 
      vertex(FloorSize-1000, 0, -FloorSize+1000 ,brownWalls.width,0);
      vertex(FloorSize-1000, -512, -FloorSize+1000, brownWalls.width, brownWalls.height);
      vertex(FloorSize-1000, -512, -FloorSize+600,0,brownWalls.height);
      endShape();
      //wall 3
      beginShape();
      texture(brownWalls);
      vertex(FloorSize-1000, 0, -FloorSize+600,0,0); 
      vertex(FloorSize-600, 0, -FloorSize+600 ,brownWalls.width,0);
      vertex(FloorSize-600, -512, -FloorSize+600, brownWalls.width, brownWalls.height);
      vertex(FloorSize-1000, -512, -FloorSize+600,0,brownWalls.height);
      endShape();
      //wall 4
      beginShape();
      texture(brownWalls);
      vertex(FloorSize-1000, 0, -FloorSize+1000,0,0); 
      vertex(FloorSize-600, 0, -FloorSize+1000 ,brownWalls.width,0);
      vertex(FloorSize-600, -512, -FloorSize+1000, brownWalls.width, brownWalls.height);
      vertex(FloorSize-1000, -512, -FloorSize+1000,0,brownWalls.height);
      endShape();
     
  /*-------------------Fin del BOX 2 ----------------------------------*/
  popMatrix();  
  
  // END MATRIX BOXES
    
  }
  
   //NPC CREATION
   
  void enemy(PImage textura)
  {
      beginShape();
      translate(0,height/2,0); // *******RE LOCATE Matrix in Center, primary Y
      texture(textura); //asignar textura
      textureWrap(CLAMP);
      vertex(-100, -200, 0, 0, 0); 
      vertex(100, -200, 0, 102, 0);
      vertex(100, 200, 0, 102, 178);
      vertex(-100, 200, 0, 0, 178);
      endShape();
  }

void draw(){
   
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
      
    HUD();
    weapon();  //Load Weapon
    environment();  //Load Enviromnment
   
    cameraUpdate();
    locationUpdate();
    jumpManager(10);
   
  //Camera Mode 1 - Original
    if(cameraMode == 1)
      camera(x,y,z,rotateX,ty,rotateZ,0,1,0);
      
      
     //weapon and HUD 
     pushMatrix();
       camera();
       hint(DISABLE_DEPTH_TEST);
       image(weapon, width/2-100, height - 280);
       image(doomHUD, 0, height-100); 
     popMatrix();
   
      
//**********************************************************  NPC  1
  pushMatrix();  
  translate (positionX, 0, -positionZ);   //MOVE NPC
  
  //Create NPC
  //enemy(enemyMove[(actualFrame)]);

    enemy(enemyMove[(actualFrame)]);
 
  
  //  CHANGE FRAME
  actualFrame = (actualFrame+1) % numFrames; //% numFrames cicla los frmaes 
  
  //  UPDATE Position in X, Z
  positionX = positionX + (speedX * xDirection); 
  positionZ = positionZ + (speedZ * zDirection);
  
  //  CHANGE Speed in X, z based on PLANE
  if (positionX > FloorSize || positionZ>-FloorSize)
  {
    speedX = random(5, 20);
    speedZ = random(5, 20);    
  }
  
  //  CHANGE DIRECTION
 //  Z
 if (positionZ>FloorSize-800) {
    zDirection*=-1;
 
  }
  if (positionZ<-FloorSize-800) {
    zDirection*=-1;

  }
  // X
   if (positionX>FloorSize+700) {
    xDirection*=-1;

  }
  if (positionX<-FloorSize+800) {
    xDirection*=-1;

  }
   
   // **********************  OBJECT 1 COLLISION wall 1  |
  if (positionX<-FloorSize+1010)
  {
    if (positionX>-FloorSize+990)
    {
      if (positionZ<FloorSize-600)
      {
        if (positionZ>FloorSize-1000)
        {
          println("BOX 1 wall 1"  );
          xDirection*=-1;
          zDirection*=-1;              
        }
      }
    }
  }
  
   // **********************  OBJECT 1 COLLISION wall 2
    if (positionX<-FloorSize+610)
  {
    if (positionX>-FloorSize+590)
    {
      if (positionZ<FloorSize-600)
      {
        if (positionZ>FloorSize-1000)
        {
          println("BOX 1 wall 2"  );
          xDirection*=-1;
          zDirection*=-1;             
        }
      }
    }
  }
  
  // **********************  OBJECT 1 COLLISION wall 3
 if (positionX<-FloorSize+600)
  {
    if (positionX>-FloorSize+1000)
    {println("BOX 1 wall 3"  );
      if (positionZ<FloorSize-990)
      {
        if (positionZ>FloorSize-1010)
        {
          println("BOX 1 wall 3"  );
          xDirection*=-1;
          zDirection*=-1;              
        }
      }
    }
  }
  
  // **********************  OBJECT 1 COLLISION wall 4
  if (positionX<-FloorSize+600)
  {
    if (positionX>-FloorSize+1000)
    {
      if (positionZ<FloorSize-590)
      {
        if (positionZ>FloorSize-610)
        {
          println("BOX 1 wall 4"  );
          xDirection*=-1;
          zDirection*=-1;    
          
        }
      }
    }
  }
    
  // **********************  OBJECT 2 COLLISION wall 1
   if (positionX<FloorSize-610)
  {
    if (positionX>FloorSize-590)
    {
      if (positionZ<-FloorSize+600)
      {
        if (positionZ>-FloorSize+1000)
        {
          println("BOX 2 wall 1"  );
          xDirection*=-1;
          zDirection*=-1; 
        }
      }
    }
  }
  
   // **********************  OBJECT 2 COLLISION wall 2
  if (positionX<FloorSize-990)
  {
    if (positionX>FloorSize-1010)
    {
      if (positionZ<-FloorSize+600)
      {
        if (positionZ>-FloorSize+1000)
        {
          println("BOX 2 wall 2"  );
          xDirection*=-1;
          zDirection*=-1;    
          
        }
      }
    }
  }
  
  // **********************  OBJECT 2 COLLISION wall 3 
  if (positionX<FloorSize-600)
  {
    if (positionX>FloorSize-1000)
    {
      if (positionZ<-FloorSize+590)
      {
        if (positionZ>-FloorSize+610)
        {
          println("BOX 2 wall 3"  );
          xDirection*=-1;
          zDirection*=-1;    
          
        }
      }
    }
  }
  
  // **********************  OBJECT 2 COLLISION wall 4
  if (positionX<FloorSize-600)
  {
    if (positionX>FloorSize-1000)
    {
      if (positionZ<-FloorSize+990)
      {
        if (positionZ>-FloorSize+1010)
        {
          println("BOX 2 wall 3"  );
          xDirection*=-1;
          zDirection*=-1;  
        }
      }
    }
  }
  popMatrix();
//****************************************************************** END  NPC 1

  /* 
   // ______COLISION ENTRE NPC________
   if(positionX<positionX2+100)
  {
    if(positionX>positionX2-100)
    {
      if(positionZ<positionZ2+10)
      {
        if(positionZ>positionZ2-10)
        {
          println("CHOCARON!!");
          xDirection*=-1; xDirection2*=-1;
          zDirection*=-1; zDirection2*=-1;
        }
      }      
    }
  }
*/  
}//   fin de DRAW
 
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
      //println("xC:    " + xComp);
      //println("NewXC: " + newXComp);
      //println("zC:    " + zComp);
      //println("NewZC: " + newZComp);
      //println("Angle: " +angle);*/
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
  move=false;
  if(keyPressed && key == ' ' && canJump){
    vY -= magnitude;
    if(vY < -10)
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
 
public void keyPressed(){ //**ADD "w" and "W"
  move = true;
  if(keyCode == UP || key == 'w'  || key == 'W'){
    moveZ = -10;
    moveUP = true;
  }
   
  else if(keyCode == DOWN || key == 's'  || key == 'S'){
    moveZ = 10;
    moveDOWN = true;
  }
   
  else if(keyCode == LEFT || key == 'a'  || key == 'A'){
    moveX = -10;
    moveLEFT = true;
  }
   
  else if(keyCode == RIGHT || key == 'd'  || key == 'D'){
    moveX = 10;
    moveRIGHT = true;
  }
  
  else if(key =='z' || key == 'Z'){
    crouch=true;
  }
}
 
public void keyReleased(){
  move =false;
  if(keyCode == UP || key == 'w'  || key == 'W'){
    moveUP = false;
    moveZ = 0;
  }
  else if(keyCode == DOWN || key == 's'  || key == 'S'){
    moveDOWN = false;
    moveZ = 0;
  }
     
  else if(keyCode == LEFT || key == 'a'  || key == 'A'){
    moveLEFT = false;
    moveX = 0;
  }
   
  else if(keyCode == RIGHT || key == 'd'  || key == 'D'){
    moveRIGHT = false;
    moveX = 0;
  }
  
  else if(key =='z' || key == 'Z'){
    crouch=false;
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
    