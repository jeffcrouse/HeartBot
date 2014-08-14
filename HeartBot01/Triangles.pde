

PVector corners[] = new PVector[3];
float triangleStartAngle;
float angles[] = new float[3];
float triangleTwitch;

void doTriangles() {

  twitchStyle = "triangles";

  circleRadius = random(0.05, 0.15);
  circleCenter.x = random(0.2, 0.8);
  circleCenter.y = random(0.2, 0.8);


  angles[0] = random(0, TWO_PI);
  angles[1] = angles[0] + (TWO_PI / 3.0);
  angles[2] = angles[1] + (TWO_PI / 3.0);

  corners[0] = new PVector();
  corners[0].x = circleCenter.x + cos(angles[0]) * circleRadius;
  corners[0].y = circleCenter.y + sin(angles[0]) * circleRadius;

  corners[1] = new PVector();
  corners[1].x = circleCenter.x + cos(angles[1]) * circleRadius;
  corners[1].y = circleCenter.y + sin(angles[1]) * circleRadius;

  corners[2] = new PVector();
  corners[2].x = circleCenter.x + cos(angles[2]) * circleRadius;
  corners[2].y = circleCenter.y + sin(angles[2]) * circleRadius;


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

  commands.add( "triangles one" );
  commands.add( "wait for queue" );
  commands.add( "triangles two" );
  commands.add( "wait for queue" );
  commands.add( "triangles three" );
  commands.add( "wait for queue" );


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

// ------------------------------------
void trianglesTwitch() {
  float twitchAmount = map(Sensor, 212, 1024, -1, 1);
  dualPenTwitch(1, twitchAmount, triangleTwitch);
  
   float t = millis();
  dualPenSetPen(2, cos(t) > 0);
}


// ------------------------------------
void trianglePrep() {
  moves.add( corners[0] );
}

// ------------------------------------
void trianglesOne() {
  triangleTwitch = angles[2];
  moves.add( corners[1] );
}

// ------------------------------------
void trianglesTwo() {
  triangleTwitch = angles[0];
  moves.add( corners[2] );
}

// ------------------------------------
void trianglesThree() {
  triangleTwitch = angles[1];
  moves.add( corners[0] );
}


// ------------------------------------
void triangleSetSpeed() {
  platformSpeed = 0.3;
}

