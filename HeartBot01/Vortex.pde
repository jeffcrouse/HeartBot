
float vortexRadius;
int vortexNumRings = 50;
PVector[] vortexCircle = new PVector[40];

void vortexSetup() {
  vortexRadius = persist.getFloat("vortexRadius", 0.2);
  println("vortexRadius = "+vortexRadius);
}

void doVortex() {

  twitchStyle = "vortex";

  for (int i=0; i<vortexCircle.length; i++) {
    float angle = map(i, 0, 40, radians(-90), radians(270));
    float x = 0.5 + cos(angle) * vortexRadius;
    float y = 0.5 + sin(angle) * vortexRadius;
    vortexCircle[i] = new PVector(x, y);
  }

  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );


  commands.add( "vortex prep" );
  commands.add( "wait for queue" );

  commands.add( "start twitch" );
  commands.add( "pen1 down" );
  commands.add( "pen2 down" );


  commands.add( "vortex draw" );
  commands.add( "wait for queue" );


  commands.add( "full speed" );
  commands.add( "stop twitch" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );
  commands.add( "vortex increment" );

  commands.add( "goto center" );
  commands.add( "wait for queue" );


  commands.add( "end drawing" );
}

void vortexTwitch() {
  twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAngle = map(moves.size(), vortexCircle.length, 0, radians(-90), radians(270));
  dualPenTwitch(1, twitchAmount, twitchAngle);

  float amt = cos(millis()/1000.0) * 0.5;
  dualPenTwitch(2, amt, twitchAngle);
}

void vortexPrep() {
  moves.add( vortexCircle[0] );
}

void vortexDraw() {
  platformSpeed = 0.5; // TO DO: should be proportional to the radius.
  for (int i=0; i<vortexCircle.length; i++) {
    moves.add( vortexCircle[i] );
  }
}

void vortexIncrement() {
  vortexRadius += 0.8 / float(vortexNumRings);
  println("vortexRadius = "+vortexRadius);
  persist.setFloat("vortexRadius", vortexRadius);
  savePersist();
}

