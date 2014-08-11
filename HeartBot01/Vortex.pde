
float vortexRadius;
int vortexNumRings = 50;


void vortex() {
  twitchStyle = "vortex";
  String lines[] = loadStrings("vortexRadius.txt");
  vortexRadius = (lines == null) ? 0.2 : float( lines[0] ); 



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

  commands.add( "goto center" );
  commands.add( "wait for queue" );

  commands.add( "vortex increment" );
  commands.add( "end drawing" );
}

void vortexTwitch() {
  twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAngle = map(moves.size(), 40, 0, radians(-90), radians(270));
  dualPenTwitch(1, twitchAmount, twitchAngle);

  float amt = cos(millis()/1000.0) * 0.5;
  dualPenTwitch(2, amt, twitchAngle);
}

void vortexPrep() {
  PVector p = new PVector();
  p.x = 0.5 + cos( radians(-90) ) * vortexRadius;
  p.y = 0.5 + sin( radians(-90) ) * vortexRadius;
  moves.add( p );
}


void vortexDraw() {
  speed = 0.5; // TO DO: shoudl be proportional to the radius.
  for (int i=0; i<41; i++) {
    float angle = map(i, 0, 40, radians(-90), radians(270));
    PVector p = new PVector();
    p.x = 0.5 + cos(angle) * vortexRadius;
    p.y = 0.5 + sin(angle) * vortexRadius;
    moves.add( p );
  }
}

void vortexIncrement() {
  vortexRadius += 0.8 / float(vortexNumRings);
  String[] list = {   
    str(vortexRadius)
    };
    saveStrings("vortexRadius.txt", list);
}

