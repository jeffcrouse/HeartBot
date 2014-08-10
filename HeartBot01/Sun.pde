
PVector north = new PVector();
PVector south = new PVector();
PVector east = new PVector();
PVector west = new PVector();

void mySun() {

  circleRadius = random(0.1, 0.2);
  circleCenter.x = random(0.2, 0.8);
  circleCenter.y = random(0.2, 0.8);

  east.x = circleCenter.x + cos(0) * circleRadius;
  east.y = circleCenter.y + sin(0) * circleRadius;

  south.x = circleCenter.x + cos(radians(90)) * circleRadius;
  south.y = circleCenter.y + sin(radians(90)) * circleRadius;

  west.x = circleCenter.x + cos(radians(180)) * circleRadius;
  west.y = circleCenter.y + sin(radians(180)) * circleRadius;

  north.x = circleCenter.x + cos(radians(270)) * circleRadius;
  north.y = circleCenter.y + sin(radians(270)) * circleRadius;

  commands.add( "full speed" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "goto north" );
  commands.add( "pen1 down" );
  commands.add( "goto south" );
  commands.add( "wait for queue" );
  commands.add( "pen1 up" );
  commands.add( "goto west" );
  commands.add( "pen1 down" );
  commands.add( "goto east" );

  commands.add( "wait for queue" );

  commands.add( "pen2 down" );
  commands.add( "sun speed" );
  commands.add( "start twitch" );

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

