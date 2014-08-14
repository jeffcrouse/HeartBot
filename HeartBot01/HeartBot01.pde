import processing.serial.*;
import controlP5.*;


ControlP5 cp5;
String props = "p5.properties";

PFont font;
boolean drawingInProgress = false;

boolean useSensor = true;      // ATTENTION!!!   Set this to false to disable the sensor altogether
boolean useHektor = true;      // MORE ATTENTION! false to disable hektorbot
boolean useDualPen = true;

// Global Hektor speed -- used whenever coords are put into the Hektor queue by the "moves" ArrayList
float platformSpeed = 1.0;

// Global twitch variales. 
boolean doTwitch;
String twitchStyle;

String cmd = "";
ArrayList<String> commands = new ArrayList<String>(); // meta-command strings
ArrayList<PVector> moves = new ArrayList<PVector>();  // platform move commands (because the tinyg can only hold 20, this holds the rest)
ArrayList<String> warnings = new ArrayList<String>(); // text warnings to draw on screen.

RadioButton moduleChooser;
Slider pen1pressure;
Slider pen2pressure;

float squishX = 0;
float squishY = 0;


// ---------------------------------------------------------------
boolean sketchFullScreen() {
  return false;
}


// ---------------------------------------------------------------
void setup() {
  println(Serial.list());
  thread("doPlayback");

  loadPersist();
  starburstSetup();
  vortexSetup();
  mayanSetup();
  circlesSetup();
  hektorSetup(); // takes 20-30 seconds!
  dualPenSetup();
  sensorSetup();

  size(1200, 800);  // Stage size
  frameRate(100);  
  smooth();

  registerPre(this);
  font = loadFont("HelveticaNeue-24.vlw");
  textFont(font, 14);

  cp5 = new ControlP5(this);
  //cp5.getProperties().setFormat( ControllerProperties.Format.SERIALIZED );

  int x = 20;
  int y = 20;
  moduleChooser = cp5.addRadioButton("moduleChooser")
    .setPosition(x, y)
      .setSize(40, 20)
        .setColorForeground(color(120))
          .setColorActive(color(255))
            .setColorLabel(color(255))
              .setItemsPerRow(6)
                .setSpacingColumn(50)
                  .addItem("circles", 1)
                    .addItem("fishbone", 2)
                      .addItem("starburst", 3)
                        .addItem("triangles", 4)
                          .addItem("vortex", 5)
                            .addItem("mayan", 6)
                              ;
  y += 40;
  pen1pressure = cp5.addSlider("pen1pressure")
    .setPosition(x, y)
      .setRange(-1, 1)
        .setSize(300, 20)
          ;
  y += 40;
  pen2pressure = cp5.addSlider("pen2pressure")
    .setPosition(x, y)
      .setRange(-1, 1)
        .setSize(300, 20)
          ;

  y += 40;
  cp5.addSlider("playbackSpeed")
    .setPosition(x, y)
      .setRange(0.25, 2.0)
        .setSize(300, 20);

  y += 40;
  cp5.addSlider("squishX")
    .setPosition(x, y)
      .setRange(0, 0.2)
        .setSize(300, 20);

  y += 40;
  cp5.addSlider("squishY")
    .setPosition(x, y)
      .setRange(0, 0.2)
        .setSize(300, 20);

  cp5.loadProperties(props);
}

JSONObject persist;

// ---------------------------------------------------------------
void loadPersist() {
  try {
    persist = loadJSONObject("persist.json");
  } 
  catch(Exception e) {
    persist = new JSONObject();
  }
}

// ---------------------------------------------------------------
void savePersist() {
  saveJSONObject(persist, "data/persist.json");
}


// ---------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {

  if (theEvent.isFrom(moduleChooser)) {
    println("Saving Properties to "+props);
  } else  if (theEvent.isFrom(pen1pressure)) {
    float pressure = pen1pressure.getValue();
    //println( "pen1pressure = "+pressure);
    dualPenPressure(1, pressure);
  } else if (theEvent.isFrom(pen2pressure)) {
    float pressure = pen2pressure.getValue();
    dualPenPressure(2, pressure);
    //println( "pen2pressure = "+pressure);
  }
}

// ---------------------------------------------------------------
void onBeatUp() {
  buttonLightOn();

  if (doTwitch) {
    if (twitchStyle == "starburst") {
      starburstOnBeatUp();
    } else if ( twitchStyle == "mayan") {
      mayanOnBeatUp();
    }
  }
}

// ---------------------------------------------------------------
void onBeatDown() {
  buttonLightOff();
  if (doTwitch) {
    if (twitchStyle == "starburst") {
      starburstOnBeatDown();
    } else if ( twitchStyle == "mayan") {
      mayanOnBeatDown();
    }
  }
}

// ---------------------------------------------------------------
void pre() {

  sensorUpdate();
  hektorUpdate();

  if (doTwitch) {
    if ( twitchStyle == "vortex") {
      vortexTwitch();
    } else if (twitchStyle == "triangles") {
      trianglesTwitch();
    } else if (twitchStyle == "starburst") {
      starburstTwitch();
    } else if ( twitchStyle == "fishbone") {
      fishboneTwitch();
    } else if ( twitchStyle == "circles") {
      circlesTwitch();
    } else if ( twitchStyle == "starburst2") {
      starburstTwitch2();
    } else if ( twitchStyle == "mayan") {
      mayanTwitch();
    } else {
      println("twitch style unknown: "+twitchStyle);
    }
  }

  // If there is room in the Hektor queue, add some stuff from the moves ArrayList
  if (hektorQueueLength < hektorQueueLimit && moves.size() > 0) {
    movePlatform(moves.get(0).x, moves.get(0).y, platformSpeed);
    moves.remove(0);
  }

  // If there are any commands to process, process them.
  if (commands.size() > 0) {
    cmd = commands.get(0);
    boolean cmdFinished = true;


    if (cmd == "pen1 up") {
      dualPenSetPen(1, false);
    } else if (cmd == "pen2 up") {
      dualPenSetPen(2, false);
    } else if (cmd == "pen1 down") {
      dualPenSetPen(1, true);
    } else if (cmd == "pen2 down") {
      dualPenSetPen(2, true);
    } else if (cmd == "goto start") {
      moves.add( start );
    } else if (cmd == "goto end") {
      moves.add( end );
    } else if (cmd == "goto home") {
      moves.add( new PVector(0.5, 0) );
    } else if ( cmd == "fishbone prep circle" ) {
      fishbonePrepCircle();
    } else if (cmd == "circles prep") {
      circlesPrep();
    } else if (cmd == "circles draw") {
      circlesDraw();
    } else if ( cmd == "circles persist" ) {
      circlesPersist();
    } else if ( cmd == "wait for queue") {
      cmdFinished = (hektorQueueLength==0 && moves.size()==0);
    } else if ( cmd == "start drawing") {
      drawingInProgress = true;
    } else if ( cmd == "end drawing") {
      drawingInProgress = false;
    } else if ( cmd == "start twitch") {
      doTwitch = true;
    } else if ( cmd == "stop twitch") {
      doTwitch = false;
    } else if ( cmd == "pen1 home") {
      dualPenHome(1);
    } else if ( cmd == "pen2 home") {
      dualPenHome(2);
    } else if ( cmd == "full speed") {
      platformSpeed = 1.0;
    } else if ( cmd == "sun speed" ) {
      setSunSpeed();
    } else if ( cmd == "goto north" ) {
      moves.add(north);
    } else if ( cmd == "goto south" ) {
      moves.add(south);
    } else if ( cmd == "goto east" ) {
      moves.add(east);
    } else if ( cmd == "goto west" ) {
      moves.add(west);
    } else if ( cmd == "triangles speed" ) {
      triangleSetSpeed();
    } else if ( cmd == "triangles prep") {
      trianglePrep();
    } else if ( cmd == "triangles one" ) {
      trianglesOne();
    } else if ( cmd == "triangles two" ) {
      trianglesTwo();
    } else if ( cmd == "triangles three" ) {
      trianglesThree();
    } else if ( cmd == "circles prep") {
      circlesPrep();
    } else if ( cmd == "starburst speed") {
      starburstSpeed();
    } else if ( cmd == "starburst draw line") {
      starburstDrawLine();
    } else if ( cmd == "starburst line prep") {
      starburstPrepLine();
    } else if (cmd == "starburst twitch2 start") {
      starburstTwitch2Start();
    } else if (cmd == "starburst twitch2 end") {
      starburstTwitch2End();
    } else if ( cmd == "goto center") {
      moves.add( new PVector(0.5, 0.5) );
    } else if ( cmd ==  "starburst persist" ) {
      starburstPersist();
    } else if ( cmd == "vortex increment" ) {
      vortexIncrement();
    } else if ( cmd == "vortex prep" ) {
      vortexPrep();
    } else if ( cmd == "vortex draw" ) {
      vortexDraw();
    } else if ( cmd == "starburst circle" ) {
      starburstCircle();
    } else if (cmd == "starburst circle prep") {
      starburstCirclePrep();
    } else if ( cmd == "fishbone prep line") {
      fishbonePrepLine();
    } else if ( cmd == "fishbone draw line") {
      fishboneDrawLine();
    } else if ( cmd == "fishbone prep circle") {
      fishbonePrepCircle();
    } else if ( cmd == "fishbone draw circle") {
      fishboneDrawCircle();
    } else if ( cmd == "mayan line prep" ) {
      mayanPrepLine();
    } else if (cmd == "mayan line" ) {
      mayanDrawLine();
    } else if (cmd == "mayan circle prep" ) {
      mayanPrepCircle();
    } else if (cmd == "mayan circle") {
      mayanDrawCircle();
    } else if ( cmd == "mayan persist") {
      mayanPersist();
    } else {
      println("WARNING: unknown command"+cmd);
    }

    if (cmdFinished)  commands.remove(0);
  }


  warnings.clear();
  if (useHektor && !hektor_homed) warnings.add("HEKTOR NOT HOMED");
  if (!useSensor) warnings.add("SENSOR/BUTTON DISABLED");
  if (!useHektor) warnings.add("HEKTOR DISABLED");
  if (!useDualPen) warnings.add("DUAL PEN DISABLED");
  if (drawingInProgress) warnings.add("DRAWING IN PROGRESS");
}

// ---------------------------------------------------------------
void draw() {
  background(51);
  fill(#FFFFFF);
  noStroke();
  text(int(frameRate)+"fps", width-40, 12);
  /*
   String msg[] = {
   , 
   "BPM = "+BPM, 
   "IBI = "+IBI, 
   "Signal = "+Sensor, 
   //"Mean = "+Mean, 
   //"StdDev = "+StdDev, 
   //"StdDevThreshCounter = "+StdDevThreshCounter, 
   "hektorQueueLength = "+hektorQueueLength, 
   "commands.size() = "+commands.size(), 
   "moves.size() = " + moves.size(), 
   //"twitchAngle = " + degrees(twitchAngle), 
   //"twitchAmount = " + twitchAmount
   };
   int ystart = 320;
   for (int i=0; i<msg.length; i++) {
   text(msg[i], 20, ystart+(i*16));
   }
   */
  drawMoves();
  drawCommands();
  drawWarnings();
  drawSignal();
  drawHeart(width-30, height/2);
  recordPlaybackDraw();
}

// ---------------------------------------------------------------
void drawCommands() {
  pushStyle();
  noStroke();
  fill(#FFFFFF);
  textFont(font, 14);

  int x = 10;
  int y = height-30;
  int i = commands.size()-1;
  while (i > -1) {
    text(commands.get(i), x, y);
    y -= 16;
    i--;
  }
  text(cmd, x, height-10);
  popStyle();
}

// ---------------------------------------------------------------
void drawWarnings() {
  if (warnings.size()<1) return;
  pushStyle();
  noStroke();
  fill(#FF0000);
  textFont(font, 28);
  String s = "WARNING: \n";
  for (int i=0; i<warnings.size (); i++) {
    s += warnings.get(i)+"\n";
  }
  text(s, (width/2.0) - (textWidth(s)/2.0), height/2.0);
  popStyle();
}

// ---------------------------------------------------------------
void drawMoves() {
  if (moves.size()<1) return;
  pushStyle();
  beginShape();
  noFill();
  stroke(200, 200, 200);
  for (int i=0; i<moves.size (); i++) {
    PVector p = moves.get(i);
    vertex(p.x*width, p.y*height);
  }
  endShape();
  popStyle();
}


// ---------------------------------------------------------------
void mousePressed() {
  //  float x = map(mouseX, 0, width, 0, 1);
  //  float y = map(mouseY, 0, height, 0, 1);
  //  movePlatform(x, y);
}

// ---------------------------------------------------------------
void mouseReleased() {
}


// ---------------------------------------------------------------
boolean pen1 = false;
boolean pen2 = false;
void keyPressed() {

  switch(key) {
  case 'q':
    hektorRequestQueueReport();
    break;

  case 'r':
    toggleRecording();
    break;
    
  case 'p':
    togglePlayback();
    break;

  case 'I':
    hektorJogRaw(0, -1);
    break;
  case 'J':
    hektorJogRaw(-1, 0);
    break;
  case 'K':
    hektorJogRaw(0, 1);
    break;
  case 'L':
    hektorJogRaw(1, 0);
    break;

  case 'i':
    hektorJogRaw(0, -5);
    break;
  case 'j':
    hektorJogRaw(-5, 0);
    break;
  case 'k':
    hektorJogRaw(0, 5);
    break;
  case 'l':
    hektorJogRaw(5, 0);
    break;

  case '1':
    pen1 = !pen1;
    dualPenSetPen(1, pen1);
    break;

  case '2':
    pen2 = !pen2;
    dualPenSetPen(2, pen2);
    break;

  case 'H':
    hektorSetHome();
    break;

  case 'g':
    dualPenHome(1);
    dualPenHome(2);
    break;

  case 't':
    doTestPattern();
    break;

  case '+':
    dualPenSetPen(1, true);
    dualPenSetPen(2, true);
    break;

  case '-':
    dualPenSetPen(1, false);
    dualPenSetPen(2, false);
    break;

  case '`':
    hektorMotorsOff();
    break;

  case 'c':
    moves.clear();
    commands.clear();
    break;

  case 'S':
    cp5.saveProperties(props);
    break;

  case 'B':
    onButtonUp();
    break;

  case 'P':
    loadPersist();
    mayanUsedIndices = persist.getJSONArray("mayanUsedIndices");
    println(mayanUsedIndices);
    break;

  default:
    break;
  }


  // hektor bot moving 
  if (key==CODED) {
    switch(keyCode) {
    case UP:
      hektorJog(0, -1);
      break;
    case DOWN:
      hektorJog(0, 1);
      break;
    case LEFT:
      hektorJog(-1, 0);
      break;
    case RIGHT:
      hektorJog(1, 0);
      break;
    }
  }
}

//----------------------------------------------------
void serialEvent(Serial port) {
  try {
    String inData = port.readStringUntil('\n');
    if (inData==null) return;
    inData = trim(inData);
    if (inData.length()==0) return;

    if (port==tinyg) {
      hektorSerialEvent(inData);
    } else if (useSensor && port==sPort && !playing) {
      sensorSerialEvent(inData);
    }
  } 
  catch (Exception e) {
    println("Problem reading from serial");
    e.printStackTrace();
  }
}





/*************************************
 ╔╦╗┌─┐┌┬┐┌─┐╔═╗┌─┐┌┬┐┌┬┐┌─┐┌┐┌┌┬┐┌─┐
 ║║║├┤  │ ├─┤║  │ │││││││├─┤│││ ││└─┐
 ╩ ╩└─┘ ┴ ┴ ┴╚═╝└─┘┴ ┴┴ ┴┴ ┴┘└┘─┴┘└─┘
 *************************************/


// TO DO: get rid of these -- they are confusing
// Variables shared by several Modules
PVector start = new PVector();
PVector end = new PVector();


// TO DO: get rid of these -- they are confusing
// ---------------------------------------------------------------
// Function used by several modules
float circleRadius;
PVector circleCenter = new PVector();
void makeCircle() {
  float inc = radians(360) / 40.0;
  for (float angle = 0; angle < radians (360)+inc; angle+=inc) {
    PVector p = new PVector();
    p.x = circleCenter.x + cos(angle) * circleRadius;
    p.y = circleCenter.y + sin(angle) * circleRadius;
    moves.add( p );
  }
}

// ---------------------------------------------------------------
float clamp(float n, float min, float max) {
  if (n<=min) return min;
  if (n>=max) return max;
  return n;
}

// ---------------------------------------------------------------
float clamp(float n) {
  return clamp(n, 0, 1);
}

// ---------------------------------------------------------------
// x, y in range 0.0 to 1.0
void movePlatform(float x, float y, float speed) {

  x = map(clamp(x), 0, 1, squishX, 1-squishX);
  y = map(clamp(y), 0, 1, squishY, 1-squishY);

  float platformX = x * 72 + CANVAS_OFFSET[0];
  float platformY = y * 72 + CANVAS_OFFSET[1];
  //println("Hektor to "+x+", "+y + ", => " + platformX + ", " + platformY + " - enabled? " + useHektor);
  hektorGotoXY(platformX, platformY, speed);
}

// ---------------------------------------------------------------
void movePlatform(float x, float y) {
  movePlatform(x, y, 1.0);
}

