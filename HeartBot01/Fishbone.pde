
/*********************
 ╔═╗┬┌─┐┬ ┬┌┐ ┌─┐┌┐┌┌─┐
 ╠╣ │└─┐├─┤├┴┐│ ││││├┤ 
 ╚  ┴└─┘┴ ┴└─┘└─┘┘└┘└─┘
 *********************/

float fishboneDist;
PVector[] fishboneLine = new PVector[30];
PVector[] fishboneCircle = new PVector[40];

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


  for (int i=0; i<fishboneLine.length; i++) {
    float amt = i / float(fishboneLine.length);
    float x = start.x + (end.x-start.x * amt);
    float y = start.y + (end.y-start.y * amt);

    fishboneLine[i] = new PVector(x, y);
  }


  commands.add( "start drawing" );

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "fishbone prep line" );
  commands.add( "wait for queue" );
  commands.add( "pen1 down" );
  commands.add( "pen2 down" );

  commands.add( "start twitch" );
  commands.add( "fishbone draw line" );
  commands.add( "wait for queue" );

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );
  commands.add( "stop twitch" );

  commands.add( "full speed" );

  commands.add( "fishbone prep circle" );
  commands.add( "wait for queue" );

  commands.add( "pen2 down" );
  commands.add( "fishbone draw circle" );
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
void fishbonePrepLine() {
  moves.add( fishboneLine[0] );
  
}

// ---------------------------------------------------------------
void fishboneDrawLine() {
  for(int i=0; i<fishboneLine.length; i++) {
    moves.add( fishboneLine[i] );
  }
  moves.add( fishboneLine[0] );
}

// ---------------------------------------------------------------
void fishbonePrepCircle() {
  circleRadius = random(0.01, 0.1);
  circleCenter.x = end.x + cos(radians(-45)) * circleRadius;
  circleCenter.y = end.y + sin(radians(-45)) * circleRadius;

  for(int i=0; i<fishboneCircle.length; i++) {
    float angle = map(i, 0, fishboneCircle.length, 0, PI*2);
    float x = circleCenter.x + cos(angle) * circleRadius;
    float y = circleCenter.y + sin(angle) * circleRadius;
    
    fishboneCircle[i] = new PVector(x, y);
  }

  moves.add( fishboneCircle[0] );
}

// ---------------------------------------------------------------
void fishboneDrawCircle() {
  for(int i=0; i<fishboneCircle.length; i++) {
    moves.add( fishboneCircle[i] );
  }
  moves.add( fishboneCircle[0] );
}


