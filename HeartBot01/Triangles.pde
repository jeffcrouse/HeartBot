

PVector corners[] = new PVector[3];


void triangles() {

  circleRadius = random(0.1, 0.2);
  circleCenter.x = random(0.2, 0.8);
  circleCenter.y = random(0.2, 0.8);

  float angle = random(0, PI*2);

  corners[0] = new PVector();
  corners[0].x = circleCenter.x + cos(angle) * circleRadius;
  corners[0].y = circleCenter.y + sin(angle) * circleRadius;

  angle += (PI*2) / 3.0;

  corners[1] = new PVector();
  corners[1].x = circleCenter.x + cos(angle) * circleRadius;
  corners[1].y = circleCenter.y + sin(angle) * circleRadius;

  angle += (PI*2) / 3.0;

  corners[2] = new PVector();
  corners[2].x = circleCenter.x + cos(angle) * circleRadius;
  corners[2].y = circleCenter.y + sin(angle) * circleRadius;

  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "triangles prep" );
  commands.add( "wait for queue" );

  commands.add( "pen1 down" );
  commands.add( "pen2 down" );
  commands.add( "start twitch" );

  commands.add( "triangles speed");
  commands.add( "make triangle" );
  commands.add( "wait for queue" );

  commands.add( "stop twitch" );

  commands.add( "pen1 up");
  commands.add( "pen2 up");
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "full speed" );
  commands.add( "goto home" );
  commands.add( "wait for queue" );
  commands.add( "end drawing" );
}

void trianglePrep() {
  moves.add( corners[0] );
}

void makeTriangle() {
  moves.add( corners[1] );
  moves.add( corners[2] );
  moves.add( corners[0] );
}

void triangleSetSpeed() {
  speed = 0.3;
}

