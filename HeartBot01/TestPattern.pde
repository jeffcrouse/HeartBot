
PVector points[] = new PVector[5];

void doTestPattern() {
 
  float margin = 0.05;

  points[0] = new PVector( margin, margin);
  points[1] = new PVector( 1-margin, margin );
  points[2] = new PVector( 1-margin, 1-margin );
  points[3] = new PVector( margin, 1-margin );
  points[4] = new PVector( 0.5, 0.5 );

  doLine(0, 1);
  doLine(1, 2);
  doLine(2, 3);
  doLine(3, 0);
  doLine(0, 4);
}


void doLine(int from, int to) {
  
  for(int i=0; i<100; i++) {
    float amt = float(i) / 100.0;
    PVector p = new PVector();
    p.x = points[from].x + ((points[to].x - points[from].x) * amt); 
    p.y = points[from].y + ((points[to].y - points[from].y) * amt);
    //println( p );
    moves.add( p );
  }
}


