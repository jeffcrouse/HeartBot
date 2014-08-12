

// TO DO: randomize array



PVector starburstLine[] = new PVector[30];
PVector starburstCircle[] = new PVector[40];
float starburstStartRadius;
float starburstEndRadius;


int starburstNumLines = 50;
int starburstIndex;
float starburstAngle;
JSONArray starburstUsedIndices;

void starburstSetup() {
  //starburstAngle = persist.getFloat("starburstAngle", 0);
  //println("starburstAngle = "+starburstAngle);

  try {
    starburstUsedIndices = persist.getJSONArray("starburstUsedIndices");
  } 
  catch(Exception e) {
    starburstUsedIndices = new JSONArray();
  }
}

boolean starburstIndexUsed(int idx) {
  for (int i=0; i<starburstUsedIndices.size (); i++) {
    if ( starburstUsedIndices.getInt(i)==idx) {
      return true;
    }
  }
  return false;
}

void doStarburst() {

  if(starburstUsedIndices.size()>=50) {
    println("WARNING: Canvas is full!");
    return;
  }
  
  twitchStyle = "starburst";
  float x;
  float y;

  do {
    starburstIndex = int(random(0, starburstNumLines));
  } 
  while (starburstIndexUsed (starburstIndex));

  starburstAngle = map(starburstIndex, 0, starburstNumLines, 0, PI*2);
  starburstStartRadius = random(0.05, 0.1);
  starburstEndRadius = random(0.35, 0.4);

  for (int i=0; i<starburstLine.length; i++) {
    float dist = map(i, 0, starburstLine.length, starburstStartRadius, starburstEndRadius);
    x = 0.5 + cos(starburstAngle) * dist;
    y = 0.5 + sin(starburstAngle) * dist;
    starburstLine[i] = new PVector(x, y);
  }

  start = starburstLine[0];



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

  commands.add( "starburst persist" );

  commands.add( "pen1 down" );
  commands.add( "starburst draw line" );
  commands.add( "wait for queue" );
  commands.add( "stop twitch" );

  commands.add( "full speed" );

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );

  commands.add( "starburst circle prep" );
  commands.add( "wait for queue" );


  commands.add( "pen2 down" );
  commands.add( "starburst twitch2 start" );
  commands.add( "starburst circle" );
  commands.add( "wait for queue" );
  
  commands.add( "starburst twitch2 end" );

  commands.add( "pen2 up" );

  //commands.add( "starburst line prep" );
  //commands.add( "wait for queue" );

  commands.add( "goto center" );
  commands.add( "wait for queue" );


  commands.add( "end drawing" );
}

void starburstTwitch() {
  twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAmount *= map(moves.size(), 0, starburstLine.length, 1, 0.1);
  twitchAngle = starburstAngle - radians(90);

  dualPenTwitch(1, twitchAmount, twitchAngle);
  dualPenTwitch(2, 0.5, 1.0);
}


void starburstTwitch2() {
  float t = millis();
  dualPenSetPen(2, cos(t) > 0);
}

void starburstOnBeatUp() {
  dualPenSetPen(2, false);
}

void starburstOnBeatDown() {
  dualPenSetPen(2, true);
}


void starburstPrepLine() {
  moves.add(   starburstLine[starburstLine.length-1] );
}

void starburstPersist() {
  //starburstAngle += 360 / float(starburstNumLines);
  //println("starburstAngle = "+starburstAngle);
  //persist.setFloat("starburstAngle", starburstAngle);

  starburstUsedIndices.append( starburstIndex );
  persist.setJSONArray("starburstUsedIndices", starburstUsedIndices);
  savePersist();
}

void starburstSpeed() {
  platformSpeed = 0.2;
}

void  starburstCirclePrep() {

  float radius = map(BPM, 60, 80, 0.02, 0.06); //0.05;
  PVector center = starburstLine[starburstLine.length-1];
  for (int i=0; i<starburstCircle.length; i++) {
    float angle = map(i, 0, starburstCircle.length, 0, PI*2);
    float x = center.x + cos(angle) * radius;
    float y = center.y + sin(angle) * radius;
    starburstCircle[i] = new PVector(x, y);
  }

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

void starburstTwitch2Start() {
  twitchStyle = "starburst2";
  doTwitch = true;
}

void starburstTwitch2End() {
  doTwitch = false;
}

