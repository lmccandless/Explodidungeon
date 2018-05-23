class Enemy {
  SpriteSheet sheet = enemySprites;
  PVector loc, vel;
  int frame = 0;

  float idle = 0;
  float running = 0;
  float jumping = 8;
  float attacking = 0;
  int size = 80;
  int health = 1;
  int attack = 0;

  float hurt = 0;
  float dying = 0;
  float explode = 0;
  float behaveWait = 2.0;
  float behaveTick = 0.015;
  float speed = 2.3;
  PVector biteOffset = new PVector(32, 16), 
    playerOffset = new PVector(22, 62), 
    hitBox = new PVector(46, 69);

  Enemy(PVector l) {
    loc = l.copy();
    vel = new PVector(0, 0);
  }
  
  Enemy() {
    loc = new PVector(000, 200);
    vel = new PVector(0, 0);
  }
  
  float behavior = random(1);
  void ai() {
    behavior += behaveTick;
    if (behavior>1) {behavior =0; attack =0; attacking = 0;}
    PVector playerTop = playerLoc.copy();
    playerTop.y-=40;
    PVector d = loc.copy().sub(playerTop).add(biteOffset);
    float dMag = d.mag();
    if (dMag < 500){
      if (dMag > 15)if ((behavior < behaveWait) && (dying==0)) vel.sub(d.mult(0.7));
      if (dMag < 60) {
        if ((hurt==0)&&(dying ==0)&&(explode == 0))attack++;
        if (attack == 20) {
          attack++;
          if (hitCheck()) {
            playerHealth-=5;
            asHit.trigger();
            shake = 32;
             asBite.trigger();
          }
        }
        if (attacking == 0) {
          if (attack==10) {
            attacking+=0.01;
          }
        }
      } else {
        attack = 0;
      }
    }
   
    if (dying==0){
      vel.mult(0.9);
       vel.limit(speed);
    }
    
    if (hurt==0){
      vel.mult(0.6);
    }
    loc.add(vel);
     if ((dying>0) && (explode == 0)) {
      int x = floor(loc.x/lineLength);
      PVector p1 = new PVector(x*lineLength, mapLines[1][x]);
      PVector p2 = new PVector((x+1)*lineLength, mapLines[1][x+1]);
      PVector intersect =  p1.copy();
      float xx = (loc.x/lineLength-x);
      intersect.lerp(p2, xx);
      
      if (loc.y < intersect.y-20) {
        loc.y += 2;
        loc.x += 1.5*vel.x;
      }
      else vel = new PVector(0,0);
    }
    if (loc.x-playerLoc.x < - 400) loc.x = playerLoc.x-400; 
  }

  void dmg() {
    asDead.trigger();
    hurt+=0.001;
    health--;
     for (int i = 0; i < 10; i++)fireSystem.setEmitter(loc.x,loc.y);
    if (health==0){ 
      dying += 0.001;
     
      asDead.trigger();
    }
  }
  int explodeType = 0;

  void animate() {
    if (explode >0) { //Exploding
      frame = 29;
      if (explode < 0+5)explode+=0.15;
      PVector playerC = playerLoc.copy().add(new PVector(0, -30));
      if ((playerC.sub(loc)).mag() <70) {
        playerHealth -= 1.0;
        //asHit.trigger();
      }
      drawExplosion();
      //rect(loc.x, loc.y, 10, 10);
    } 
    
    else if (dying >0) { // Dying
    hurt = 0;
      dying += 0.08;
      if (dying>=6) {
        dying  = 5;
        vel.x = 0; vel.y = 0;
        asExplosion.trigger();
       
        vel.x = playerVel.x;
        vel.y = 1;
        int xL = floor(loc.x/lineLength);
        PVector pl = shGround.getVertex(xL);
        pl.y += 110;
        score++;
        shGround.setVertex(xL, pl);
        mapLines[1][xL] = (int)pl.y;
        explode++;
        explodeType = floor(random(3));
      }
      frame = 23+ (int)dying;
    } 
    
    else if (hurt > 0) { // Hurt
      hurt += 0.15;
      if (hurt>=7) {
        hurt  = 0;
      }
      frame = 17+ (int)hurt;
    } 
    
    else if (attacking > 0) { // Attacking
      attacking += 0.150;
      if (attacking>=9) {
        attacking  = 0; 
        attack = 0;
      }
      frame = 8+ (int)attacking;
    } 
    
    else if (vel.mag()<0.4) { // Idle
      idle+=0.1;
      if (idle>4)idle=0;
      frame = (int)idle;
    } 
    
    else {  // Moving
      running += 0.1;
      if (running > 4) running = 0;
      frame =4+ (int)running;
    }
  }

  boolean hitCheck() {
    if (playerLoc.x<loc.x) biteOffset.x= abs(biteOffset.x)*-1;//flipSprite(i);
    else biteOffset.x = abs(biteOffset.x);
    if (attack==20) fill(255, 0, 0, 255);
    // ellipse(loc.x+biteOffset.x, loc.y+biteOffset.y, 5, 5);
    // fill(100, 100);
    // rect(playerLoc.x-playerOffset.x, playerLoc.y-playerOffset.y, hitBox.x, hitBox.y);
     boolean hit = pointInBox(loc.copy().add(biteOffset), 
      playerLoc.copy().sub(playerOffset), 
      hitBox);
    return hit;
  }

  void draw() {
    drawEnemy(frame);
    //ellipse(playerC.x,playerC.y,10,10);
    // ellipse(loc.x,loc.y,10,10);
    hitCheck();
  }

  void drawExplosion() {
    int i =  explodeType*7+floor(explode);
    image(explosionSprites.sprites[i], loc.x, loc.y, 180, 180);
  }

  void drawEnemy(int i) {
     if (((hurt >0)&&(hurt<0.5)) || ((dying>0)&&(dying<0.5)))tint(0,0,0,255);
    if (playerLoc.x>loc.x) drawSpriteFlipped(i);
    else drawSprite(i);
    stroke(255);
    fill(255);
    noTint();
  }

  void drawSprite(int i) {
    image(sheet.sprites[i], loc.x, loc.y, size, size);
  }
  void drawSpriteFlipped(int i) {
    pushMatrix();
    scale(-1, 1);
    translate(-loc.x, loc.y);
    image(sheet.sprites[i], 0, 0, size, size);
    popMatrix();
  }
}

class Enemy2 extends Enemy {
  Enemy2(PVector l){
    super(l);
    sheet = enemySprites2;
    health = 3;
     behaveWait = 0.25;
     behaveTick = 0.005;
     speed = 4.3;
  }
  Enemy2(){
    super();
    sheet = enemySprites2;
    health = 3;
  }
}