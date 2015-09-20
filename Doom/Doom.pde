import ddf.minim.*;
Minim minim;

 AudioPlayer mainSong, handgunSound, shotgunSound;
 
//Global Variables
 
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
    float rotateX,rotateZ;
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
  
  //EnemyLife
  float enemyLife = 6;
  
  /************************* Textures  **********************/
  PImage[] enemyMove = new PImage[8];
  PImage[] enemyDead = new PImage[7];
  
  PImage[] handGunAnimations = new PImage[8];
  PImage[] shotGunAnimations = new PImage[11];
  
  PImage Floor;
  PImage brownWalls;
  PImage bigWalls;
  
  PImage HUD, face; 
  boolean crouch = false;
  
  /* Weapon */
  PGraphics weapon, doomHUD; 
  int wi = 400, hi = 390;
  float moveWeapon = 0.0f;
  boolean isGoingDown = false;
  boolean isGoingUp = false;
  PImage[][] actualWeapon;
  PImage shotGun;
  int thisWeapon = 0;
  float thisShoot = 0.0f;
  boolean isShooting = false;
  int shootingAnimation = 0;
  boolean shot, changeTexture;
  
void setup(){
  size(800,600,P3D);
  noStroke();
  
  //************************************************ START load texture 
  enemyMove[0] = loadImage("enemy/enemy-01.png");
  enemyMove[1] = loadImage("enemy/enemy-02.png");
  enemyMove[2] = loadImage("enemy/enemy-03.png");
  enemyMove[3] = loadImage("enemy/enemy-04.png");
  enemyMove[4] = loadImage("enemy/enemy-05.png");
  enemyMove[5] = loadImage("enemy/enemy-06.png");
  enemyMove[6] = loadImage("enemy/enemy-07.png");
  enemyMove[7] = loadImage("enemy/enemy-08.png");
  
  enemyDead[0] = loadImage("enemy/muerte-1.png");
  enemyDead[1] = loadImage("enemy/muerte-2.png");
  enemyDead[2] = loadImage("enemy/muerte-3.png");
  enemyDead[3] = loadImage("enemy/muerte-4.png");
  enemyDead[4] = loadImage("enemy/muerte-5.png");
  enemyDead[5] = loadImage("enemy/muerte-6.png");
  enemyDead[6] = loadImage("enemy/muerte-7.png");
  
  Floor = loadImage("rockFloor.jpg");
  brownWalls = loadImage("Walls.png");
  bigWalls = loadImage("Big wall.jpg");
   
  weapon = createGraphics(wi, hi, P3D); 
  
  HUD = loadImage("HUD.png");
  face = loadImage("face/face.png");
  doomHUD = createGraphics(width, hi, P2D); 
  
  //******************************************************* END load textures
   
  //Camera Initialization
  x = width/2;
  y = height/2;
    y-= standHeight;
  z = (height/2.0) / tan(PI*60.0 / 360.0);
  rotateX = width/2;
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
  
      /* Load handgun animations */
  for(int i = 0; i < handGunAnimations.length; i++)
    handGunAnimations[i] = loadImage("Weapons/Handgun/Handgun0" + i + ".png");
    
   /* Load shotgun animations */
  for(int i = 0; i < shotGunAnimations.length - 1; i++)
    shotGunAnimations[i] = loadImage("Weapons/Shotgun/Shotgun0" + i + ".png");
 
  weapon = createGraphics(wi, hi, P3D);
  actualWeapon = new PImage[][]{{handGunAnimations[0], handGunAnimations[1], handGunAnimations[2], handGunAnimations[3], handGunAnimations[4], handGunAnimations[4], handGunAnimations[4], handGunAnimations[7]}, {shotGunAnimations[0], shotGunAnimations[1], shotGunAnimations[2], shotGunAnimations[3], shotGunAnimations[4], shotGunAnimations[5], shotGunAnimations[6], shotGunAnimations[7], shotGunAnimations[8], shotGunAnimations[9], shotGunAnimations[0]}};
  
  /* OST */
  
  minim = new Minim(this);
  mainSong = minim.loadFile("Audio/Music/main.mp3");
  mainSong.loop();
  handgunSound = minim.loadFile("Audio/Sound Effects/handgun.wav");
  handgunSound.setGain(14);
  
  shotgunSound = minim.loadFile("Audio/Sound Effects/shotgun.wav");
  shotgunSound.setGain(14);
  

}
 
   void weapon()
{
        pushMatrix();
      weapon.beginDraw();
        weapon.background(255, 0);
        weapon.scale(400);
        weapon.noStroke();
        weapon.translate(0, moveWeapon, 0);
        weapon.beginShape(TRIANGLE_STRIP);
          weapon.texture(actualWeapon[thisWeapon][floor(thisShoot)]);
          weapon.textureMode(NORMAL);
          weapon.vertex(0, 0, 0,  0, 0);
          weapon.vertex(0, 1, 0, 0, 1);
          weapon.vertex(1, 0, 0, 1, 0);
          weapon.vertex(1, 1, 0, 1, 1);
        weapon.endShape();
      weapon.endDraw();
      popMatrix();
      background(0); 
      
      if(isGoingDown && moveWeapon < 1.0)
        moveWeapon += 0.08;
        
      if(isGoingDown && moveWeapon >= 1.0){
        thisWeapon = (thisWeapon + 1) % actualWeapon.length;
        isGoingDown = false;
        isGoingUp = true;
      }
      
      if(isGoingUp){
        moveWeapon -= 0.08;
        println(moveWeapon);
       // isChanging = false;
      }
      
      if(isGoingUp && moveWeapon <= 0.0){
        moveWeapon = 0.0;
        isGoingUp = false;
        isGoingDown = false;
      }
      
      if(isShooting && thisWeapon == 0 && thisShoot < 6){
        thisShoot += 0.2;
        shot=true;
      }
      
      if(thisWeapon == 0 && thisShoot >= 6){
        thisShoot = 0;
        isShooting = false;        
      }
      
        if(isShooting && thisWeapon == 1 && thisShoot < 6){
        thisShoot += 0.15;       
      }
      
      
       if(thisWeapon == 1 && (thisShoot >= 6)){
        thisShoot += 0.12;
        isShooting = false;
      }
      
      if(thisWeapon == 1 && thisShoot >= 10){
        thisShoot = 0;
        isShooting = false;
        shot=false;
      }
   
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
      translate(0,0,0); // *******RE LOCATE Matrix in Center, primary Y
      rotateY(-angle);  //Gira a donde se mueva la camara
      texture(textura); //asignar textura
      textureWrap(CLAMP);
      vertex(-100, -200, 0, 0, 0); 
      vertex(100, -200, 0, 102, 0);
      vertex(100, 200, 0, 102, 178);
      vertex(-100, 200, 0, 0, 178);
      endShape();
  }
  
  void enemy(){
    //**********************************************************  NPC  1
  pushMatrix();  
  translate (positionX, height/2 - 100, -positionZ);   //MOVE NPC
  
  //Create  y  Muerte de Enemy
  if(enemyLife!=0){
    //  UPDATE Position in X, Z
    positionX = positionX + (speedX * xDirection); 
    positionZ = positionZ + (speedZ * zDirection);    
   
    if(changeTexture==true){
      enemy(enemyDead[0]); 
      enemyLife=enemyLife-0.5;
    }
    if(changeTexture==false){
      enemy(enemyMove[0]);
    }    
  }
  else {
    enemy(enemyDead[6]);
    positionX = positionX + 0; //Stop enemy
    positionZ = positionZ + 0;
  }

  //  CHANGE Speed in X, z based on PLANE
  if (positionX > FloorSize || positionZ>-FloorSize)
  {
    speedX = random(2, 8);
    speedZ = random(2, 8);    
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
  }

void draw(){
   
   background(0);

   hint(ENABLE_DEPTH_TEST);
    if(spotLightMode == 0)
      lights();
    else if(spotLightMode == 1)
      spotLight(255,255,255,x,y-standHeight,z,rotateX,0,rotateZ,PI,1);
    else if(spotLightMode == 2)
      spotLight(255,255,255,x,y-standHeight-200,z,x+100,y+100,z,frameCounter/10,1);
    else if(spotLightMode == 3)
      spotLight(255,255,255,width/2,height/2-1000,0,width/2,height/2,0,PI,1);
    else if(spotLightMode == 4)
      
    cameraUpdate();
    locationUpdate();
    jumpManager(10);
    
    HUD();
    weapon();  //Load Weapon
    environment();  //Load Enviromnment

     
  //Camera Mode 1 - Original
    if(cameraMode == 1)
      camera(x,y,z,rotateX,0,rotateZ,0,1,0);
      
       enemy();
     //weapon and HUD 
     pushMatrix();
       camera();
       hint(DISABLE_DEPTH_TEST);
       image(weapon, width/2 - (wi/2), height - (hi + 100));
       image(doomHUD, 0, height-100); 
     popMatrix();

      

//****************************************************************** END  NPC 1

  //  DISPARO COLISION  
     
     boolean collisionDetected = isCollidingCircleRectangle(rotateX, rotateZ, centerBox, positionX, -positionZ, 100, 300); //////////////////////////////////////////////////
     if (collisionDetected == true) { println("IMPACTA!!"); 
         if(shot==true){ changeTexture=true;}
     }
     else { println("No impacta"); shot=false; changeTexture=false;}
     
  

}//   fin de DRAW
 
public void cameraUpdate(){
  if (lookMode == 8){
    int diffX = mouseX - width/2;
    //int diffY = mouseY - width/2; /* The width of the screen is more, this is used in order to have the same speed between axis */
     
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
      //println("X: " +xComp);
      //println("Y: " +angle);
      //--------------------------------------*/
        
    }

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
   
   if(keyCode == DOWN || key == 's'  || key == 'S'){
    moveZ = 10;
    moveDOWN = true;
  }
   
   if(keyCode == LEFT || key == 'a'  || key == 'A'){
    moveX = -10;
    moveLEFT = true;
  }
   
   if(keyCode == RIGHT || key == 'd'  || key == 'D'){
    moveX = 10;
    moveRIGHT = true;
  }
  
   if(key =='z' || key == 'Z'){
    crouch=true;
  }
  
    /* Change Weapons */
  if(!isGoingUp && !isGoingDown)
    if(key == 'r' || key == 'R'){
      isGoingDown = true;
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

void mousePressed(){
  if (mouseButton == LEFT){
    if(!isShooting){
      if(thisWeapon == 0){
        handgunSound.loop();
        handgunSound.play();
        isShooting = true;
        shot=true;
      }
       if(thisWeapon == 1){
         shotgunSound.loop();
         shotgunSound.play();
        isShooting = true;
        shot=true;
      }
    }
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

 
boolean isCollidingCircleRectangle(
      float lookX, //aim
      float lookY,  //aim
      float aimRadius,  //aimRadius
      float rectangleX,  //positionX
      float rectangleY,  //positionZ
      float rectangleWidth,  //sizeW
      float rectangleHeight  //sizeY    
        )
{
    float positionAimX = abs(lookX - rectangleX);
    float positionAimZ = abs(lookY - rectangleY);
 
    if (positionAimX > (100/2 + aimRadius)) { return false; }
    if (positionAimZ > (1000)) { return false; }
 
    if (positionAimX <= (100/2)) { return true; }
    if (positionAimZ <= (100)) { return true; }
 
    float cornerDistance_sq = pow(positionAimX - rectangleWidth/2, 2) +
                         pow(positionAimZ - rectangleHeight/2, 2);
 
    return (cornerDistance_sq <= pow(centerBox,2));
}