

// TO DO: shish kebab

float starburstAngle = 0;
int starburstNumLines = 50;
PVector starburstLine[] = new PVector[30];
PVector starburstCircle[] = new PVector[40];
float starburstStartRadius;
float starburstEndRadius;


void starburstSetup() {
  starburstAngle = persist.getFloat("starburstAngle", 0);
  println("starburstAngle = "+starburstAngle);
}

void doStarburst() {

  twitchStyle = "starburst";
  float angle;
  float x;
  float y;


  angle = radians(starburstAngle-90);
  starburstStartRadius = random(0.1, 0.2);
  starburstEndRadius = random(0.4, 0.5);

  for (int i=0; i<starburstLine.length; i++) {
    float dist = map(i, 0, starburstLine.length, starburstStartRadius, starburstEndRadius);
    x = 0.5 + cos(angle) * dist;
    y = 0.5 + sin(angle) * dist;
    starburstLine[i] = new PVector(x, y);
  }

  start = starburstLine[0];

  float radius = 0.05;
  PVector center = starburstLine[starburstLine.length-1];
  for (int i=0; i<starburstCircle.length; i++) {
    angle = map(i, 0, starburstCircle.length, 0, PI*2);
    x = center.x + cos(angle) * radius;
    y = center.y + sin(angle) * radius;
    starburstCircle[i] = new PVector(x, y);
  }


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
  commands.add( "starburst circle prep" );
  commands.add( "wait for queue" );

  commands.add( "pen2 down" );
  commands.add( "starburst circle" );
  commands.add( "wait for queue" );

  commands.add( "pen2 up" );

  commands.add( "goto center" );
  commands.add( "wait for queue" );

  commands.add( "starburst increment" );
  commands.add( "end drawing" );
}

void starburstTwitch() {
  twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAmount *= map(moves.size(), 0, starburstLine.length, 1, 0.1);
  twitchAngle = radians(starburstAngle);

  dualPenTwitch(1, twitchAmount, twitchAngle);
}

void starburstIncrement() {
  starburstAngle += 360 / float(starburstNumLines);
  println("starburstAngle = "+starburstAngle);
  persist.setFloat("starburstAngle", starburstAngle);
  savePersist();
}

void starburstSpeed() {
  platformSpeed = 0.2;
}

void  starburstCirclePrep() {
  moves.add( starburstCircle[0] );
}

void starburstCircle() {
  for (int i=0; i<starburstCircle.length; i++) {
    moves.add( starburstCircle[i] );
  }
  moves.add( starburstCircle[0] );
}
void starburstDrawLine() {
  for (int i=0; i<starburstLine.length; i++) {
    moves.add( starburstLine[i] );
  }
}

