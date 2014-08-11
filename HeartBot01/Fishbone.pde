
/*********************
 ╔═╗┬┌─┐┬ ┬┌┐ ┌─┐┌┐┌┌─┐
 ╠╣ │└─┐├─┤├┴┐│ ││││├┤ 
 ╚  ┴└─┘┴ ┴└─┘└─┘┘└┘└─┘
 *********************/

float fishboneDist;

void doFishbone() {
  twitchStyle = "fishbone";
  
  do {
    start.x = random(0.1, 0.4);
    start.y = random(0.5, 0.9);
    fishboneDist = random(0.4, 1);

    end.x = start.x + cos(radians(-45)) * fishboneDist;
    end.y = start.y + sin(radians(-45)) * fishboneDist;
  } 
  while (end.x > 0.8 || end.y < 0.2);

  commands.add( "start drawing" );

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );
  commands.add( "goto start" );
  commands.add( "wait for queue" );
  commands.add( "pen1 down" );
  commands.add( "pen2 down" );

  for (int i=0; i<100; i++) {
    commands.add("null");
  }
  commands.add( "start twitch" );
  commands.add( "goto end" );
  commands.add( "wait for queue" );

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );
  commands.add( "stop twitch" );

  commands.add( "fishbone set radius" );
  commands.add( "fishbone prep circle" );
  commands.add( "full speed" );
  commands.add( "wait for queue" );
  commands.add( "pen2 down" );

  commands.add( "circle" );
  commands.add( "wait for queue" );

  commands.add( "pen2 up");
  commands.add( "goto home" );
  commands.add( "wait for queue" );
  commands.add( "end drawing" );
}

// ---------------------------------------------------------------
void fishboneTwitch() {
  
}

// ---------------------------------------------------------------
void fishboneSetRadius() {
  circleRadius = random(0.01, 0.1);
}

// ---------------------------------------------------------------
void fishbonePrepCircle() {
  circleCenter.x = end.x + cos(radians(-45)) * circleRadius;
  circleCenter.y = end.y + sin(radians(-45)) * circleRadius;

  PVector p = new PVector();
  p.x = circleCenter.x + cos(0) * circleRadius;
  p.y = circleCenter.y + sin(0) * circleRadius;
  moves.add( p );
}

