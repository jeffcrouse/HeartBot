

boolean recording = false;
boolean playing = false;

float playbackSpeed;
ArrayList<String> Recording = new ArrayList<String>();
String recFilename = "recording.txt";
String[] PlaybackStrings; // Loaded 
int pf=0; // playback frame



void toggleRecording() {
  if (playing) return;

  if (recording) {
    String []strings = new String[Recording.size()];
    Recording.toArray(strings);
    saveStrings(recFilename, strings);
    println("Saving data to "+recFilename);
    recording = false;
  } else {
    Recording.clear();
    recording = true;
  }
}

boolean inrange(int n, int min, int max) {
  return n >=0 && n <=max;
}

void togglePlayback() {
  if (recording) return;

  if (playing) {
    playing = false;
  } else {
    PlaybackStrings = loadStrings(recFilename);
    println("Loaded "+PlaybackStrings.length+" strings");
    playing = true;
  }
}

void doRecord(String inData) {
  if (!recording) return;
  
  Recording.add( inData );
}


void doPlayback() {

  while (true) {
    try {

      if (playing && PlaybackStrings.length>0) {
        sensorSerialEvent( PlaybackStrings[pf] );
        pf = (pf+1) % PlaybackStrings.length;
      }

      long sleep = (long)map(playbackSpeed, 0, 100, 100, 20);
      Thread.sleep(sleep);
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }
}

void recordPlaybackDraw() {
  pushStyle();
  noStroke();
  if (recording) {
    fill(#FF0000);
    ellipse(40, height-40, 20, 20);
  }
  if (playing) {
    fill(#00FF00);
    triangle(10, height-30, 10, height-10, 30, height-20);
  }
  popStyle();
}

