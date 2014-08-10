

float starburstAngle = 0;
int starburstNumLines = 50;



void starburst() {

  String lines[] = loadStrings("starburstAngle.txt");
  if (lines == null) {
    starburstAngle = 0;
  } else {
    starburstAngle = float( lines[0] );
  }

  float angle = radians(starburstAngle-90);
  start.x = 0.5 + cos(angle) * 0.1;
  start.y = 0.5 + sin(angle) * 0.1;


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

  commands.add( "goto start" );
  commands.add( "wait for queue" );

  commands.add( "starburst increment" );
  commands.add( "end drawing" );
}

void starburstIncrement() {
  starburstAngle += 360 / float(starburstNumLines);

  String[] list = new String[1];
  list[0] = str(starburstAngle);
  saveStrings("starburstAngle.txt", list);
}

void starburstSpeed() {
  speed = 0.2;
}

void starburstDrawLine() {

  float angle = radians(starburstAngle-90);
  float distance = 0;
  float inc = 0.5 / 100.0;

  for (float d=0.1; d < 0.4; d += inc) {
    PVector p = new PVector();
    p.x = 0.5 + cos(angle) * d;
    p.y = 0.5 + sin(angle) * d;
    moves.add( p );
  }
}

