class SpriteSheet {
  PImage [] sprites ;
  int r, c;
  SpriteSheet(PImage src, int ncols, int nrows) {
    c = src.width/ncols;
    r = src.height/nrows;
    sprites = new PImage[ncols*nrows];
    println(ncols*nrows);
    for (int i = 0; i < ncols; i++) {
      for (int q = 0; q < nrows; q++) {
        sprites[i+q*ncols] = src.get(i*c, q*r, c, r);
      }
    }
  }
}