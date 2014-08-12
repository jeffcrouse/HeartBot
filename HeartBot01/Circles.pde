
int gridSize = 8;
PVector circlePts[] = new PVector[100];
JSONArray circlesGrid;
int circlesCell;


void circlesSetup() {
  try {
    circlesGrid = persist.getJSONArray("circlesGrid");
  } 
  catch(Exception e) {
    circlesGrid = new JSONArray();
    for (int i=0; i<gridSize*gridSize; i++) {
      circlesGrid.setBoolean(i, false);
    }
  }
}


void doCircles() {

  twitchStyle = "circles";

  // Pick a cell that is set to false (meaning it is unused)
  int row;
  int col;
  do {
    row = int(random(1, gridSize-1));
    col = int(random(1, gridSize-1));
    circlesCell = (row*gridSize) + col;
  } 
  while (circlesGrid.getBoolean (circlesCell)==true);

  println( "cell = "+circlesCell+" row = "+row+" col = "+col);

  PVector center = new PVector();
  center.x = (1/float(gridSize)) * row;
  center.y = (1/float(gridSize)) * col;

  float radius = 1/8.0;
  float x, y, angle;
  for (int i=0; i<circlePts.length; i++) {
    angle = map(i, 0, circlePts.length, radians(-90), radians(270));
    x = center.x + cos(angle) * radius;
    y = center.y + sin(angle) * radius;
    circlePts[i] = new PVector(x, y);
  }

  radius /= 5;
  east.x = center.x + cos(0) * radius;
  east.y = center.y + sin(0) * radius;

  south.x = center.x + cos(radians(90)) * radius;
  south.y = center.y + sin(radians(90)) * radius;

  west.x = center.x + cos(radians(180)) * radius;
  west.y = center.y + sin(radians(180)) * radius;

  north.x = center.x + cos(radians(270)) * radius;
  north.y = center.y + sin(radians(270)) * radius;


  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "goto north" );
  commands.add( "wait for queue" );
  commands.add( "pen2 down" );
  commands.add( "goto south" );
  commands.add( "wait for queue" );

  commands.add( "circles persist" );

  commands.add( "pen2 up" );
  commands.add( "goto west" );
  commands.add( "wait for queue" );
  commands.add( "pen2 down" );
  commands.add( "goto east" );
  commands.add( "wait for queue" );
  commands.add( "pen2 up" );
  commands.add( "pen2 home" );

  commands.add( "circles prep" );
  commands.add( "wait for queue" );

  commands.add( "pen1 down" );
  commands.add( "pen2 down" );
  commands.add( "start twitch" );
  commands.add( "circles draw" );
  commands.add( "wait for queue" );

  commands.add( "stop twitch" );
  commands.add( "pen1 up");
  commands.add( "pen2 up");

  commands.add( "full speed" );
  commands.add( "goto home" );
  commands.add( "wait for queue" );
  commands.add( "end drawing" );
}

void circlesTwitch() {
  twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAngle = map(moves.size(), vortexCircle.length, 0, 0, PI*2);
  dualPenTwitch(1, twitchAmount, twitchAngle);
}

void circlesPrep() {
  moves.add( circlePts[0] );
}

void circlesDraw() {
  platformSpeed = 0.4;
  for (int i=0; i<circlePts.length; i++) {
    moves.add( circlePts[i] );
  }
  moves.add( circlePts[0] );
}

void circlesPersist() {
  circlesGrid.setBoolean(circlesCell, true);
  persist.setJSONArray("circlesGrid", circlesGrid);
  savePersist();
}

