

// TO DO: shish kebab

float starburstAngle = 0;
int starburstNumLines = 50;
PVector starburstPoints[] = new PVector[30];

void starburst() {
  twitchStyle = "starburst";
  String lines[] = loadStrings("starburstAngle.txt");
  starburstAngle = (lines == null) ? 0 : float( lines[0] );


  float angle = radians(starburstAngle-90);
  float startRadius = random(0.1, 0.2);
  float endRadius = random(0.4, 0.5);

  for (int i=0; i<starburstPoints.length; i++) {
    float dist = map(i, 0, starburstPoints.length, startRadius, endRadius);
    float x = 0.5 + cos(angle) * dist;
    float y = 0.5 + sin(angle) * dist;
    starburstPoints[i] = new PVector(x, y);
  }

  start = starburstPoints[0];

  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "full speed" );
  commands.add( "goto start" );
  commands.add( "wait for queue" );

  commands.add( "start twitch" );
  commands.add( "starburst speed" );

  commands.add( "pen1 down" );
  commands.add( "starburst draw line" );
  commands.add( "wait for queue" );

  commands.add( "full speed" );
  commands.add( "stop twitch" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "goto center" );
  commands.add( "wait for queue" );

  commands.add( "starburst increment" );
  commands.add( "end drawing" );
}

void starburstTwitch() {
  twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAmount *= map(moves.size(), 0, starburstPoints.length, 1, 0.1);
  twitchAngle = radians(starburstAngle);
  dualPenTwitch(1, twitchAmount, twitchAngle);
}

void starburstIncrement() {
  starburstAngle += 360 / float(starburstNumLines);

  String[] list = {  
    str(starburstAngle)
    };
    saveStrings("starburstAngle.txt", list);
}

void starburstSpeed() {
  speed = 0.2;
}

void starburstDrawLine() {
  for (int i=0; i<starburstPoints.length; i++) {
    moves.add( starburstPoints[i] );
  }
}

