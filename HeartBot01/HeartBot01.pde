import processing.serial.*;
import controlP5.*;

PFont font;
ControlP5 cp5;
String props = "bot.properties";




/*********************************
 ╔═╗┌─┐┌┐┌┌─┐┌─┐┬─┐  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╚═╗├┤ │││└─┐│ │├┬┘  ╚═╗ │ │ │├┤ ├┤ 
 ╚═╝└─┘┘└┘└─┘└─┘┴└─  ╚═╝ ┴ └─┘└  └  
 *********************************/
boolean useSensor = false;      // ATTENTION!!!   Set this to false to disable the sensor altogether
boolean useHektor = true;      // MORE ATTENTION! false to disable hektorbot
boolean useDualPen = false;

Serial sPort;
//String sPortName = "/dev/tty.AdafruitEZ-Link3290-SPP";
String sPortName = "/dev/tty.usbmodem1411";

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced
int beatCounter = 0;    // Bump this up to some number when the sensor reports a heartbeat, then decrement 

int BufferSize = 200;  // How much "raw" sensor rata will we keep around for calculation?
ArrayList<Integer> Signal = new ArrayList<Integer>();
float Mean;              // The average of all of the samples in the Signal ArrayList
float StdDev;            // The standard deviation of the "raw" sensor data
int StdDevThresh = 200;  // A standard deviation above 200 means that there is some kind of activity.
int StdDevThreshCounter = 0;  // If the standard deviation stays high for a while, we probably have a heartbeat

int Button = 1;      // Current Button Signal (updated in serialEvent)
int ButtonLast = 1;  // Button signal as of last pre() - used to determine change events

int lastHektorRequestQueueReport = 0;

ArrayList<String> commands = new ArrayList<String>();
ArrayList<PVector> moves = new ArrayList<PVector>();



// ---------------------------------------------------------------
void setup() {
  hektorSetup(); // takes 20-30 seconds!
  dualPenSetup();

  size(700, 600);  // Stage size
  frameRate(100);  
  smooth();
  registerPre(this);
  font = loadFont("HelveticaNeue-24.vlw");
  textFont(font, 18);
  cp5 = new ControlP5(this);
  println("Loading Properties to "+props);

  cp5.addSlider("StdDevThresh")
    .setBroadcast(false)
      .setPosition(10, 20)
        .setSize(300, 20)
          .setRange(100, 300)
            .setNumberOfTickMarks(7)
              .setValue(200);


  cp5.loadProperties(props);

  println(Serial.list());

  if (useSensor) {
    sPort = new Serial(this, sPortName, 115200); 
    sPort.clear();            // flush buffer
    sPort.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
    buttonLightOff();
  }
}


// ---------------------------------------------------------------
void pre() {

  // Calculate mean, standard deviation, etc
  crunchSensorData();

  // If we have gotten a heartbeat from the sensor, do some stuff.
  if (beat) {
    beatCounter = 20;
    if (heartbeatPresent()) buttonLightOn();
    beat = false;
  }

  beatCounter--;
  if (beatCounter == 0) {
    buttonLightOff();
  }

  // Has the Button signal changed?
  if (Button!=ButtonLast) {
    if (Button==0) onButtonDown();
    else onButtonUp();
    ButtonLast = Button;
  }

  // Request a RequestQueueReport every 2 seconds
  if(millis()-lastHektorRequestQueueReport > 2000) {
    hektorRequestQueueReport();
    print("*");
    lastHektorRequestQueueReport = millis();
  }
  
  // If there is room in the Hektor queue, add some stuff from the moves ArrayList
  if (hektorQueueLength < 20 && moves.size() > 0) {
    float x = moves.get(0).x;
    float y = moves.get(0).y;
    //println("moving to "+x+" "+y);
    movePlatform(x, y, 0.5);
    moves.remove(0);
  }

  // If there are any commands to process, process them.
  if (commands.size() > 0) {
    String cmd = commands.get(0);
    boolean cmdFinished = true;

    if (cmd=="wait for queue" || cmd=="null") print('.');
    else println(cmd);

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
    } else if ( cmd == "prep circle" ) {
      prepCircle();
    } else if (cmd == "circle") {
      makeCircle();
    } else if ( cmd == "wait for queue") {
      cmdFinished = (hektorQueueLength==0 && moves.size()==0);
    }

    if (cmdFinished)  commands.remove(0);
  }
}

// ---------------------------------------------------------------
void draw() {
  background(51);
  fill(#FFFFFF);
  noStroke();

  String msg[] = {
    "FrameRate = "+int(frameRate), 
    "BPM = "+BPM, 
    "IBI = "+IBI, 
    "Signal = "+Sensor, 
    "Mean = "+Mean, 
    "StdDev = "+StdDev, 
    "StdDevThreshCounter = "+StdDevThreshCounter, 
    "hektorQueueLength = "+hektorQueueLength, 
    "commands.size() = "+commands.size(), 
    "moves.size() = " + moves.size(), 
    "current command = " + (commands.size()>0 ? commands.get(0) : "")
    };

    for (int i=0; i<msg.length; i++) {
      text(msg[i], 10, 200+(i*20));
    }

  drawSignal();
  drawHeart(width-30, 10);
}


// ---------------------------------------------------------------
void mousePressed() {
  float x = map(mouseX, 0, width, 0, 1);
  float y = map(mouseY, 0, height, 0, 1);
  movePlatform(x, y);
}


// ---------------------------------------------------------------
void mouseReleased() {
}


// ---------------------------------------------------------------
void keyPressed() {

  switch(key) {
  case 'q':
    hektorRequestQueueReport();
    break;

  case 's':
    println("Saving Properties to "+props);
    cp5.saveProperties(props);
    break;

  case 'n':
    drawLine();
    break;

  case '0':
    buttonLightOff();
    break;

  case '1':
    buttonLightOn();
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

  case 'p':
    dualPenSetPen(2, true);
    break;

  case 'o':
    dualPenSetPen(2, false);
    break;

  case 'H':
    hektorSetHome();
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
    } else if (useSensor && port==sPort) {
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


PVector start = new PVector();
PVector end = new PVector();
float dist;
float circleRadius;
PVector circleCenter = new PVector();

void drawLine() {

  do {
    start.x = random(0.1, 0.4);
    start.y = random(0.5, 0.9);
    dist = random(0.4, 1);

    end.x = start.x + cos(radians(-45)) * dist;
    end.y = start.y + sin(radians(-45)) * dist;
  } 
  while (end.x > 0.8 || end.y < 0.2);

  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "goto start" );
  commands.add( "wait for queue" );
  commands.add( "pen2 down" );
  for (int i=0; i<200; i++) {
    commands.add("null");
  }
  commands.add( "goto end" );
  commands.add( "wait for queue" );
  commands.add( "pen2 up" );

  commands.add( "prep circle" );
  commands.add( "wait for queue" );

  commands.add( "pen2 down" );
  commands.add( "circle" );
  commands.add( "wait for queue" );
  commands.add( "pen2 up");
  commands.add( "goto home" );
  commands.add( "wait for queue" );
}


// ---------------------------------------------------------------
void prepCircle() {
  circleRadius = random(0.01, 0.1);
  circleCenter.x = end.x + cos(radians(-45)) * circleRadius;
  circleCenter.y = end.y + sin(radians(-45)) * circleRadius;

  PVector p = new PVector();
  p.x = circleCenter.x + cos(0) * circleRadius;
  p.y = circleCenter.y + sin(0) * circleRadius;
  moves.add( p );
}

// ---------------------------------------------------------------
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
// x, y in range 0.0 to 1.0
void movePlatform(float x, float y, float speed) {
  float platformX = x * 72 + 24;
  float platformY = y * 72 + 24;

  //println("Hektor to "+x+", "+y + ", => " + platformX + ", " + platformY + " - enabled? " + useHektor);
  hektorGotoXY(platformX, platformY);
}

// ---------------------------------------------------------------
void movePlatform(float x, float y) {
  movePlatform(x, y, 0.5);
}

