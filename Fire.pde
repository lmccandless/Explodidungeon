class FireSystem {
  ArrayList<Fire> fires;
  PShape fireShape;

  FireSystem(int n) {
    fires = new ArrayList<Fire>();
    fireShape = createShape(PShape.GROUP);
    for (int i = 0; i < n; i++) {
      Fire p = new Fire();
      p.lifespan = 0;
      fires.add(p);
      fireShape.addChild(p.getShape());
    }
  }

  void update() {
    for (Fire p : fires) p.update();
  }

  void setEmitter(float x, float y) {
    int i = (int)random(2)+1;
    for (Fire p : fires) {
      if (p.isDead()) {
        i--;
        if (i<=0) break;
        p.rebirth(x, y);
      }
    }
  }

  void display() {
    shape(fireShape);
  }
}

class Fire {
  PVector velocity;
  float lifespan = 0;
  PShape part;
  final float partSize = random(2, 4);
  final PVector gravity = new PVector(0, 0.09);
  Fire() {
    float s = partSize;
    strokeWeight(s);
    strokeCap(SQUARE);
    part = createShape(POINT, 0, 0);
    part.setFill(color(168, 16, 0));
    part.setStroke(color(168, 16, 0));
    rebirth(width/2, height/2);
    lifespan = 0;
  }

  PShape getShape() {
    return part;
  }

  void rebirth(float x, float y) {
    float speed = random(0.6, 2);
    velocity = new PVector(random(0.5)-0.25, -(1+random(1)));
    speed = (sqrt(abs(y-451))*30)/96.2;
    velocity.mult(speed);
    lifespan = 255;   
    part.resetMatrix();
    part.translate(x, y);
  }

  boolean isDead() {  
    return (lifespan < 0) ? true : false;
  }

  public void update() {
    lifespan = lifespan - 2;
    velocity.add(gravity);
    part.translate(velocity.x, velocity.y);
    if (isDead())  part.translate(-1000, velocity.y);
  }
}