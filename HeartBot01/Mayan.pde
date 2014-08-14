

PVector mayanLine[] = new PVector[30];
PVector mayanCircle[] = new PVector[360];

JSONArray mayanUsedIndices;
int mayanTotal = 50; // total number of things to draw

int mayanIndex;
float mayanAngle;
float mayanRadius;

void mayanSetup() {
  try {
    mayanUsedIndices = persist.getJSONArray("mayanUsedIndices");
  } 
  catch(Exception e) {
    mayanUsedIndices = new JSONArray();
  }
}

boolean mayanIndexUsed(int idx) {
  for (int i=0; i<mayanUsedIndices.size (); i++) {
    if ( mayanUsedIndices.getInt(i)==idx) return true;
  }
  return false;
}

void doMayan() {
  twitchStyle = "mayan";

  if (mayanUsedIndices.size()>=mayanTotal) {
    println("WARNING: Canvas is full!");
    return;
  }

  do {
    mayanIndex = int(random(0, mayanTotal));
  } 
  while (mayanIndexUsed (mayanIndex));

  mayanAngle = map(mayanIndex, 0, mayanTotal, 0, PI*2);
  float endRadius = random(0.4, 0.45);

  for (int i=0; i<starburstLine.length; i++) {
    float dist = map(i, 0, mayanLine.length, 0.075, endRadius);
    float x = 0.5 + cos(mayanAngle) * dist;
    float y = 0.5 + sin(mayanAngle) * dist;
    mayanLine[i] = new PVector(x, y);
  }

  mayanRadius = map(mayanIndex, 0, mayanTotal, 0.1, 0.4);
  for (int i=0; i<mayanCircle.length; i++) {
    float angle = map(i, 0, mayanCircle.length, mayanAngle, mayanAngle+TWO_PI);
    float x = 0.5 + cos(angle) * mayanRadius;
    float y = 0.5 + sin(angle) * mayanRadius;
    mayanCircle[i] = new PVector(x, y);
  }


  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );
  commands.add( "full speed" );


  commands.add( "mayan line prep" );
  commands.add( "wait for queue" );

  commands.add( "pen1 down" );
  commands.add( "start twitch" );
  commands.add( "mayan line" );
  commands.add( "wait for queue" );
  commands.add( "stop twitch" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );


  commands.add( "mayan persist" );

  commands.add( "full speed" );
  commands.add( "mayan circle prep" );
  commands.add( "wait for queue" );

  commands.add( "pen2 down" );
  commands.add( "mayan circle" );
  commands.add( "wait for queue" );


  commands.add( "pen2 up" );
  commands.add( "pen1 up" );
  commands.add( "goto center" );
  commands.add( "wait for queue" );
  commands.add( "end drawing" );
}


void  mayanPersist() {
  mayanUsedIndices.append( mayanIndex );
  persist.setJSONArray("mayanUsedIndices", mayanUsedIndices);
  savePersist();
}

void mayanOnBeatUp() {
  dualPenSetPen(2, false);
}

void mayanOnBeatDown() {
  dualPenSetPen(2, true);
}

void mayanTwitch() {
  float twitchAmount = map(Sensor, 212, 1024, -1, 1);
  twitchAmount *= map(moves.size(), 0, mayanLine.length, 1, 0.25);
  
  float twitchAngle = mayanAngle - radians(90);

  dualPenTwitch(1, twitchAmount, twitchAngle);
  dualPenTwitch(2, 0.5, 1.0);
}



void mayanPrepCircle() {
  moves.add( mayanCircle[0] );
}

void mayanDrawCircle() {
  platformSpeed = 0.8;
  for (int i=0; i<mayanCircle.length; i++) {
    moves.add( mayanCircle[i] );
  }
  moves.add( mayanCircle[0] );
}

void mayanPrepLine() {
  moves.add(   mayanLine[0] );
}

void mayanDrawLine() {
  platformSpeed = 0.2;
  for (int i=0; i<mayanLine.length; i++) {
    moves.add( mayanLine[i] );
  }
}

