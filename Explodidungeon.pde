/*
 * Explodidungeon | Copyright (C) 2018  Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */
 
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
FireSystem fireSystem;
ArrayList<Enemy> enemies;

final int w = 356, h = 240, w2 = w*2, h2 = h*2;
final int lineLength=50, mapLength = 2000;
PVector cameraLoc = new PVector(0, 0);

int bestScore = 0, score = 0;
int progress=0;
boolean gameRunning = false;

void settings() {
  size( w2, h2, P2D);
  noSmooth();
}

color background = color(0, 64, 88), 
  farground =  color(80, 48, 0), 
  midground = color(172, 124, 0), 
  foreground =  color(0, 136, 136); 

void gameStart() {
  apLevel.unmute();
  apTitle.mute();
  apLevel.loop();
  score = 0;
  playerLoc = new PVector(600, 300);
  playerVel = new PVector(0, 0);
  playerHealth = 100;
  progress=0;
  shake = 0;
  gameRunning = true;
  cameraLoc = playerLoc.copy();
  enemies = new ArrayList<Enemy>();
  enemies.add(new Enemy());
  generateMap();
}

void setup() {
  ((PGraphicsOpenGL)g).textureSampling(2);
  loadAssets();
  frameRate(60);
  textFont(font);
  generateMap();
  menuStart();
  noCursor();
}

void menuStart() {
  apLevel.mute();
  apTitle.unmute();
  apTitle.loop();
  enemies = new ArrayList<Enemy>();
  enemies.add(new Enemy());
}

PVector getLCollision(PVector loc) {
  int x = floor(loc.x/lineLength);
  PVector p1 = new PVector(x*lineLength, mapLines[1][x]);
  PVector p2 = new PVector((x+1)*lineLength, mapLines[1][x+1]);
  PVector intersect = p1.copy();
  float xx = (loc.x/lineLength-x);
  intersect.lerp(p2, xx);
  return intersect;
}

PVector getLSlope(PVector loc) {
  int x = floor(loc.x/lineLength);
  PVector p1 = new PVector(x*lineLength, mapLines[1][x]);
  PVector p2 = new PVector((x+1)*lineLength, mapLines[1][x+1]);
  return p1.sub(p2).normalize();
}

float shake = 0.0;
void screenShake(){
  if (shake>0){
  PVector n = new PVector(noise(frameCount,0)-0.5,noise(0,frameCount)-0.5);
  n.mult(4.5*shake);
  cameraLoc.add(n);
  shake -=3.5;
  }
}

void drawStage() {
  background(background);
  cameraLoc.x -= (cameraLoc.x-playerLoc.x)*0.05;
  cameraLoc.y -= (cameraLoc.y-playerLoc.y-100)*0.05;
  pushMatrix();
  translate((-cameraLoc.x+w-w/2)*0.9, (-(cameraLoc.y-w)*0.3)*0.9);
  shape(shGroundDetail2);
  popMatrix();
  pushMatrix();
  translate(-cameraLoc.x+w-w/2, -(cameraLoc.y-w)*0.35);
  shape(shGroundDetail);
  shape(shRoofDetail);
  popMatrix();
}

void drawLavaParticles() {
  int s = (int)playerLoc.x/lineLength;
  s = max(0, s-3);
  for (int i = 0; i < 3+w2/lineLength; i++) {
    if (mapLines[1][s+i] > h2-26) {
      fireSystem.setEmitter((s+i)*lineLength, mapLines[1][s+i]);
    }
  }
  fireSystem.update();
  fireSystem.display();
}

void lavaFloor() {
  if (playerLoc.y - 6 > h2-30) {
    playerVel.y = -8;
    asHit.trigger();
    shake = 16;
    playerHealth -= 5.0;
    for (int i= 0; i < 60; i++)  fireSystem.setEmitter(playerLoc.x+random(30)-15, 440-i);
  }
  noStroke();
  fill(168, 16, 0);
  rect(0, h2-30, mapLength*lineLength, 150);
}

void drawEnemies() {
  ArrayList<Enemy> eToRemove = new ArrayList<Enemy>();
  for (Enemy e : enemies) {
    e.ai();
    e.animate();
    e.draw();
    if (e.explode>4.8) {
      eToRemove.add(e);
    }
  }
  enemies.removeAll(eToRemove);
}

void drawTopBar() {
  fill(0);
  noStroke();
  rect(0, 0, width, 50);
  fill(255);
  textSize(24);
  text("SCORE  " + score, 10, 30);
  text("HEALTH  " + ceil(playerHealth), 558, 30);
}

void gameDraw() {
  screenShake();
  drawStage();
  pushMatrix();
  translate(-cameraLoc.x+w-w/2, -(cameraLoc.y-w)*0.3);
  lavaFloor();
  drawLavaParticles();
  shape(shGround);
  shape(shRoof);
  filter(derez);
  drawPlayer();
  movePlayer();
  drawEnemies();
  popMatrix();
  
  drawTopBar();
  enemySpawn();
  checkGameOver();
  //menuBanner();
  //saveFrame("frames/####.png");
}

void enemySpawn() {
  if (floor(playerLoc.x)>progress) {
    int old = floor(progress/500.0);
    if ((old > 4) &&(floor(playerLoc.x/500.0)>old)) {
      if (old % 4 == 0)  enemies.add(new Enemy2(new PVector(progress+500, 200)));
      else enemies.add(new Enemy(new PVector(progress+500, 200)));
    }
    progress = floor(playerLoc.x);
  }
}

void checkGameOver() {
  if ((playerHealth <=0) || (floor(playerLoc.x/lineLength) > 1950)) {
    gameRunning = false;
        enemies = new ArrayList<Enemy>();
    apLevel.mute();
    apTitle.unmute();
    apTitle.loop();
    if (score>bestScore)bestScore = score;
  }
}

void menuBanner() {
  textSize(84);
  fill(80, 48, 0);
  text("Explodidungeon", 72-4, 148-4);
  text("Explodidungeon", 72, 148-4);
  text("Explodidungeon", 72-4, 148);
  fill(168, 16, 0);
  text("Explodidungeon", 72, 148);
}

void menuDraw() {
  int k = frameCount;
  cameraLoc = new PVector(1300+k, 250+noise(k/200.0)*200);
  playerLoc = cameraLoc ;//new PVector(0,0);
  background(0);
  drawStage();

  pushMatrix();
  translate(-cameraLoc.x+w-w/2, -(cameraLoc.y-w)*0.3);
  lavaFloor();
  drawLavaParticles();
  shape(shGround);
  shape(shRoof);
  filter(derez);
  popMatrix();

  menuBanner();
  textSize(48);
  fill(168, 16, 0);
  fill(farground);
  text("START", 278-4, 278-4);
   fill(midground);
  text("START", 278-2, 278-2);

  textSize(24);
  fill(255);
  rect(mouseX, mouseY, 2, 2);
  fireSystem.update();
  fireSystem.display();
   fill(0);
  
  text("WASD = move,   space = jump,   / or click = attack", 120, 468+2);
  fill(255);
  text("WASD = move,   space = jump,   / or click = attack", 120, 468);
 
  if (score>0) {
    fill(0);
     text("best score: " + bestScore, 280, 418+2);
     fill(255);
    text("best score: " + bestScore, 280, 418);
  }
  playerLoc = new PVector(mouseX, mouseY+40);
  if (enemies.size()==0) enemies.add(new Enemy());
  Enemy e = enemies.get(0);
  e.attacking = 0;
  e.attack = 0;
  drawEnemies();
  if ((attackButton())&&(pointInBox(new PVector(mouseX, mouseY), new PVector(282, 245), new PVector(136, 40)))) {
    gameStart();
  }
}

void draw() {
  if (gameRunning) gameDraw();
  else menuDraw();
  lastKeys = keys.clone();
  mouseHit = false;
  //text((int)frameRate, 10, 10);
}