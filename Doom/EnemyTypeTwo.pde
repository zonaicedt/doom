import ddf.minim.*;

class EnemyTypeTwo{
  private boolean demonRotate = false;
  private float demonMovement = 0.0f;
  public int upperLimit, lowerLimit;
  public int life;
  private boolean changeTexture = false;
  private boolean isEnemyInjured = false;
  
  private float hurtEnemyTexture = 0.0f;
  
  private float animation = 0.0f; 
  
  private float positionX, positionZ;
  
  private boolean shot = false;
  
  private int demonDisplacement = 0;
  
  private int displacement = 0;
  
  private boolean isRotated = false;
  
  public EnemyTypeTwo(int upperLimit, int lowerLimit, int life, float positionX, float positionZ){
    this.upperLimit = upperLimit;
    this.lowerLimit = lowerLimit;
    this.life = life;
    this.positionX = positionX;
    this.positionZ = positionZ;
  }
  
  private void movement(){
        //Create  y  Muerte de Enemy
  if(life > 0){
   
    if(changeTexture){
      enemy(enemyDead[0]); 
      if(thisWeapon == 0)
        life--;
       if(thisWeapon == 1)
         life -= 2;
      enemyInjured.loop();
      enemyInjured.play();
      changeTexture = false;
      this.isEnemyInjured = true;
    }

    if(this.isEnemyInjured){
      this.isEnemyInjured = false;
      this.hurtEnemyTexture = 5;
    }
    
    /* Enemy Idle */
    if(changeTexture==false && this.hurtEnemyTexture <= 0){
      pushMatrix();
        beginShape();
        translate (this.positionX, height/2 - 120, this.positionZ);   //MOVE NPC
         if(demonRotate){
          rotateY(radians(180));
        }
        //rotateY(radians(sqrt(pow(z, 2) + pow(x, 2))));
        texture(demon[floor(demonMovement) % demon.length]); //asignar textura
        textureWrap(CLAMP);
        vertex(-100, -200, 0, 0, 0); 
        vertex(100, -200, 0, 102, 0);
        vertex(100, 200, 0, 102, 178);
        vertex(-100, 200, 0, 0, 178);
        endShape();
        
        beginShape();
        
        translate (0, 0, - 1);   //MOVE NPC
        //rotateY(radians(sqrt(pow(z, 2) + pow(x, 2))));
        texture(demonBack[floor(demonMovement) % demon.length]); //asignar textura
        textureWrap(CLAMP);
        vertex(-100, -200, 0, 0, 0); 
        vertex(100, -200, 0, 102, 0);
        vertex(100, 200, 0, 102, 178);
        vertex(-100, 200, 0, 0, 178);
        endShape();
        popMatrix();
        
        demonMovement += 0.05;
        this.positionZ += displacement;
        
        if(floor(demonMovement) % demon.length == 0){
          displacement = 0;
        }else if(!demonRotate)
                displacement = 4;
              else 
                displacement = -4;
          
         if(this.positionZ > upperLimit)
            demonRotate = true;
         
         if(this.positionZ < lowerLimit)
            demonRotate = false;
    }
      
    if(changeTexture==false && this.hurtEnemyTexture > 0){
      enemy(enemyDead[0]);
      this.hurtEnemyTexture -= 0.3;
    }
 }
    
  else {
    if(animation <= 0){
      fatality.loop();
      fatality.play();
      enemyDeath.loop();
      enemyDeath.play();
    }
      if(floor(animation) < enemyDead.length - 1)
          animation += 0.1;
      enemy(enemyDead[floor(animation)]);
    }
       
  }
  
    public boolean isCollidingBulletEnemy(
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
   
      if (positionAimX > (100/2 + aimRadius)) {return false; }
      //if (positionAimZ > (1000)) { println("ESTE MERO"); return false; }
   
      if (positionAimX <= (100/2)) { return true; }
      if (positionAimZ <= (100)) { return true; }
   
      float cornerDistance_sq = pow(positionAimX - rectangleWidth/2, 2) +
                           pow(positionAimZ - rectangleHeight/2, 2);
   
      return (cornerDistance_sq <= pow(centerBox,2));
  }
  
  public float getPositionZ(){
    return this.positionZ;
  }
  
  public float getPositionX(){
    return this.positionX;
  }
  
  public void setTexture(boolean changeTexture){
    this.changeTexture = changeTexture;
  }
  
private void enemy(PImage textura){
      beginShape();
      translate (this.positionX, height/2 - 120, this.positionZ);
      texture(textura); //asignar textura
      textureWrap(CLAMP);
      vertex(-100, -200, 0, 0, 0); 
      vertex(100, -200, 0, 102, 0);
      vertex(100, 200, 0, 102, 178);
      vertex(-100, 200, 0, 0, 178);
      endShape();
  }

}

