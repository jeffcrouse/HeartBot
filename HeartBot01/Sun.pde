/*******************************
 ╔═╗┬ ┬┌┐┌  ╔╦╗┬─┐┌─┐┬ ┬┬┌┐┌┌─┐
 ╚═╗│ ││││   ║║├┬┘├─┤││││││││ ┬
 ╚═╝└─┘┘└┘  ═╩╝┴└─┴ ┴└┴┘┴┘└┘└─┘
 *******************************/
 

PVector north = new PVector();
PVector south = new PVector();
PVector east = new PVector();
PVector west = new PVector();

void sun() {
  twitchStyle = "sun";
  circleRadius = random(0.1, 0.2);
  circleCenter.x = random(0.2, 0.8);
  circleCenter.y = random(0.2, 0.8);

  east.x = circleCenter.x + cos(0) * (circleRadius/2);
  east.y = circleCenter.y + sin(0) * (circleRadius/2);

  south.x = circleCenter.x + cos(radians(90)) * (circleRadius/2);
  south.y = circleCenter.y + sin(radians(90)) * (circleRadius/2);

  west.x = circleCenter.x + cos(radians(180)) * (circleRadius/2);
  west.y = circleCenter.y + sin(radians(180)) * (circleRadius/2);

  north.x = circleCenter.x + cos(radians(270)) * (circleRadius/2);
  north.y = circleCenter.y + sin(radians(270)) * (circleRadius/2);

  start.x = circleCenter.x + cos(0) * circleRadius;
  start.y = circleCenter.y + sin(0) * circleRadius;

  commands.add( "start drawing" );
  commands.add( "full speed" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "goto north" );
  commands.add( "wait for queue" );
  commands.add( "pen1 down" );
  commands.add( "goto south" );
  commands.add( "wait for queue" );
  commands.add( "pen1 up" );
  commands.add( "goto west" );
  commands.add( "wait for queue" );
  commands.add( "pen1 down" );
  commands.add( "goto east" );
  commands.add( "wait for queue" );

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "goto start" );
  commands.add( "wait for queue" );

  commands.add( "pen1 down" );
  commands.add( "pen2 down" );
  commands.add( "sun speed" );
  commands.add( "sun start twitch" );

  commands.add( "circle" );
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

void setSunSpeed() {
  speed = map(circleRadius, 0.1, 0.2, 0.2, 0.4);
}

