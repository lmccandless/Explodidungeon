AudioSample asBite, asDead, asExplosion, asHit, asJump, asSwing;
AudioPlayer apTitle, apLevel;

PFont font;
PShader derez;

int mapLines[][];
PShape l, u, ld, ud, ld2;

PImage enemySheet, enemySheet2;
SpriteSheet enemySprites, enemySprites2;

PImage explosionSheet;
SpriteSheet explosionSprites

  ;
void loadAssets() {
  derez = loadShader("derez.glsl");
  font = loadFont("Ebrima-9.vlw");
  enemySheet = loadImage("enemy.png");
  explosionSheet  = loadImage("explosion.png");
  enemySheet2 = loadImage("enemy2.png");
  enemySprites = new SpriteSheet(enemySheet, 6, 5);
  enemySprites2 = new SpriteSheet(enemySheet2, 6, 5);
  explosionSprites = new SpriteSheet(explosionSheet, 7, 3);
  loadAudio();
  ps = new FireSystem(200);
  playerLoad();
}

void loadAudio() {
  minim = new Minim(this);
  int audioBuffer= 1024;
  apTitle = minim.loadFile("data/wyverArcadeTitle.mp3", audioBuffer);
  apLevel = minim.loadFile("data/wyverBeatemUp.mp3", audioBuffer);
  asBite = minim.loadSample( "data/bite.wav", audioBuffer);
  asDead = minim.loadSample( "data/dead.wav", audioBuffer);
  asExplosion = minim.loadSample( "data/explosion.wav", audioBuffer);
  asHit = minim.loadSample( "data/hit.wav", audioBuffer);
  asJump = minim.loadSample( "data/jump.wav", audioBuffer);
  asSwing = minim.loadSample( "data/swing.wav", audioBuffer);
  apLevel.setGain(-7);
}

void generateMap() {
  mapLines = new int[2][mapLength];
  for (int i = 0; i < mapLength; i++) {
    mapLines[0][i] =  round(noise(i/10.0, 0)*200+10);
    mapLines[1][i] =  h2-round((noise(i/10.0, 1)*200+10- pow(random(2), 7)));
  }
  mapLines[0][0] = -h;
  mapLines[0][mapLength-2] = -h;
  mapLines[1][0] = h2+h;
  for (int i = 0; i<10; i++) mapLines[1][i] = h2+h;
  for (int i = 10; i<15; i++) mapLines[1][i] = h+100;
  mapLines[1][mapLength-2] = h2+h;

  stroke(255);
  noStroke();
  fill(foreground);
  u = createShape();
  u.beginShape();
  for (int i = 0; i < mapLength-1; i++) {
    u.vertex(i*lineLength, mapLines[0][i]);
  }
  u.endShape();

  l = createShape();
  l.beginShape();
  for (int i = 0; i < mapLength-1; i++) {
    l.vertex(i*lineLength, mapLines[1][i] );
  }
  l.endShape();

  fill(midground);
  ld = createShape();
  ld.beginShape();
  for (int i = 0; i < mapLength-1; i++) {
    ld.vertex(i*lineLength, mapLines[1][i]-random(60));
  }
  ld.endShape();

  ud = createShape();
  ud.beginShape();
  for (int i = 0; i < mapLength-1; i++) {
    ud.vertex(i*lineLength, mapLines[0][i]+noise(i/100.0)*20+pow(random(3), 5));
  }
  ud.endShape();

  fill(farground);
  ld2 = createShape();
  ld2.beginShape();
  for (int i = 0; i < mapLength-1; i++) {
    ld2.vertex(i*lineLength, mapLines[1][i]-random(160));
  }
  ld2.endShape();
}