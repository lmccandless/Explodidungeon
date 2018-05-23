int sW = 20, sH = 20;
float gravity = 0.3;
int pHeight = 0;
int pHeightHalf = 0;
float accel = 0.5;
float airMove = 0.1;

SpriteSheet playerSheet;

PVector playerLoc;
PVector playerVel;
float playerDrag = 0.99, 
  accl = 0.3, 
  speedLimit = 6.0;

float idle = 0;
float running = 0;
float jumping = 8;
float attacking = 0;
boolean swing = false, airSwing = false;
int combo = 5;
boolean onFloor = false;
float playerHealth = 100;
boolean airSwung;

void playerLoad() {
  PImage sheet = loadImage("sheet.png");
  int cols = 7, rows = 11;
  playerSheet = new SpriteSheet(sheet,cols,rows);
  sW = sheet.width/cols;
  sH = sheet.height/rows;
  imageMode(CENTER);
  pHeight = sH-5;
  pHeightHalf = pHeight/2;
}

void drawPlayerSprite(int i) {
  if (shake>0)tint(0,0,0,255);
  if (playerVel.x<0) playerSpriteFlipped(i);
  else playerSprite(i);
  noTint();
}

void playerSprite(int i) {
  image(playerSheet.sprites[i], playerLoc.x, playerLoc.y-pHeight, sW*2, sH*2);
}
void playerSpriteFlipped(int i) {
  pushMatrix();
  scale(-1, 1);
  translate(-playerLoc.x, playerLoc.y);
  image(playerSheet.sprites[i], 0, -pHeight, sW*2, sH*2);
  popMatrix();
}

void drawPlayer() {
  if (swing) {
    float oldA = attacking;
    attacking += 0.234;
    if ((oldA<6)&&(attacking>=6)) {
      asSwing.trigger();
      for (Enemy e : enemies) {
        fill(255);
        enemyHit(e);
      }
    }
    if (attackButton()) combo = 9;
    if (attacking >combo) {
      drawPlayerSprite((int)floor(attacking-1) + 44);
      attacking = 0;
      swing = false;
      combo = 5;
    } else drawPlayerSprite((int)attacking + 44);
  } else if (airSwing) { 
    attacking += 0.24;
    if (attacking >4.75) {
      drawPlayerSprite((int)floor(attacking-1) + 55);
      attacking = 0;
      airSwing = false;
      combo = 5;
      jumping = 8;
    } else drawPlayerSprite((int)attacking + 55);
  } else if (onFloor) {

    if (abs(playerVel.x)<0.45) {
      drawPlayerSprite((int)idle);
      idle+=0.1;
      if (idle>4)idle=0;
    } else {
      float dir = abs(playerVel.x);
      if (dir>0) {
        running += 0.05*dir;//dir/6.0;

        if (running > 5) running = 0;
        drawPlayerSprite(9+(int)running);
      } else {
        running += 0.05*dir;
        if (running > 5) running = 0;
        drawPlayerSprite(9+(int)running);
      }
    }
    if (jumpButton()) {
      onFloor = false;
      asJump.trigger();
      playerVel.y-=8;
      jumping = 0;
    }
  } else {
    drawPlayerSprite(15+(int)jumping);
    if (jumping < 8) jumping +=0.21;
    else jumping = 8;
  }
}

void movePlayer() {
  if (attackButton() && !swing && !airSwung) {
    asSwing.trigger();
    for (Enemy e : enemies) {
      enemyHit(e);
    }
    if (onFloor) {
      swing = true;
      playerVel.x *=0.03;
    } else {
      airSwing = true;
      if (playerVel.x>0) playerVel.x += 1;
      else playerVel.x -=1;
      airSwung = true;
    }
    mouseHit = false;
  }

  playerVel.y+=gravity;
  PVector hit = getLCollision(playerLoc);
  if (hit.y<playerLoc.y+playerVel.y) {
    playerVel.y=0;
    playerLoc.y = hit.y;
    onFloor = true;
    airSwung = false;
  } else if (abs(playerLoc.y-hit.y)>7) { // to prevent "falling" down hills
    onFloor = false;
  }

  if (onFloor) {
    if (keys['a']) playerVel.x-=accel;
    if (keys['d']) playerVel.x+=accel;
    float slope = getLSlope(playerLoc).rotate(HALF_PI).heading();
    slope+=HALF_PI;
    if (((playerVel.x >0)&&(slope<0)) || ((playerVel.x <0)&&(slope>0))) 
      playerVel.x*= 1-pow(abs((slope)/2.0), 2);
    playerVel.x*=0.9;
  } else {
    if (keys['a']) playerVel.x-=accel*airMove;
    if (keys['d']) playerVel.x+=accel*airMove;
  }
  playerVel.x = constrain(playerVel.x, -speedLimit, speedLimit);
  if (playerLoc.x < 250)playerVel.x*=-1;
  playerLoc.add(playerVel);
}

boolean enemyHit(Enemy e) {
  final PVector eOffset = new PVector(0, -3), 
    pOffset = new PVector(-17, -66), 
    eSize = new PVector(75, 72);
  if (playerVel.x<0) pOffset.x -= 43;
  /*fill(255);
   ellipse(e.loc.x+eOffset.x, e.loc.y+eOffset.y, 5, 5);
   rect(playerLoc.x +pOffset.x, playerLoc.y+pOffset.y, eSize.x, eSize.y);*/
  if ((e.dying ==0) &&(pointInBox(e.loc.copy().add(eOffset), playerLoc.copy().add(pOffset), eSize))) {
    e.dmg();
    return true;
  }
  return false;
}