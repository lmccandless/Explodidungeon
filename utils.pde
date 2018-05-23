boolean [] keys = new boolean[256];
boolean [] lastKeys = new boolean[256];

boolean keyHit(int c) {
  return (keys[c] && !lastKeys[c]);
}

boolean shift;
boolean escape;
boolean mouseHit = false;

char keyHit= ' ';
void setKey(boolean state) {
  int rawKey = key;
  // println(rawKey);
  if (key == 27) {
    escape = state;
    key = (char)0;
  }
  if (rawKey==65535) shift = state;
  if (rawKey < 256) {
    if ((rawKey>64)&&(rawKey<91)) rawKey+=32;
    if ((state) && (!lastKeys[rawKey])) {
      keyHit = (char) (rawKey);
    }
    keys[rawKey] = state;
  }
}

void keyPressed() { 
  setKey(true);
}

void keyReleased() { 
  setKey(false);
}

void mousePressed() {
  mouseHit = true;
}

void mouseReleased() {
}

boolean jumpButton() {
  if (keyHit(' ') || (keyHit('w'))) return true;
  return false;
}

boolean attackButton() {
  if (mouseHit || keyHit('/') || (keyHit('s'))) return true;
  return false;
}

boolean pointInBox(PVector loc, PVector boxLoc, PVector boxSize) {
  if ((loc.x > boxLoc.x) &&
    (loc.y > boxLoc.y) &&
    (loc.x < boxLoc.x+boxSize.x) &&
    (loc.y < boxLoc.y+boxSize.y)) return true;
  return false;
}