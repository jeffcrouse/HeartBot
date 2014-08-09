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
boolean useHektor = false;      // MORE ATTENTION! false to disable hektorbot

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



/*************************************
 ╦═╗┌─┐┌┐ ┌─┐┌┬┐  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠╦╝│ │├┴┐│ │ │   ╚═╗ │ │ │├┤ ├┤ 
 ╩╚═└─┘└─┘└─┘ ┴   ╚═╝ ┴ └─┘└  └  
 *************************************/


// For you, Ranjit

boolean drawingInProgress = false;

String TINYG_SERIAL_PORT = "/dev/tty.usbserial-DA00FRX3";
int TINYG_SERIAL_SPEED = 115200;
String TINYG_INITIALIZERS[] = {
  //"$defa=1", // TOTAL RESET - DON'T DO THIS
  "G20", // standard units (inches)
  "$1sa=1.8", // 1.8 degrees per step = 200 steps per revolution
  "$1tr=2.4", // 2.4 inches per revolution using the 30 tooth pulley
  "$2sa=1.8", // same for motor 2
  "$2tr=2.4", 
  // Jerk max of 20 isn’t bad, maybe a bit too high
  "$xjm=20", 
  "$yjm=20", 
  //Max feed rate 360 revs per minute?
  "$xvm=360", 
  "$xfr=360", 
  "$yvm=360", 
  "$yfr=360", 

  // microstepping (1, 2, 4, or 8)
  "$1mi=8", 
  "$2mi=8", 

  "G90",    // absolute positioning mode
  
  "$qv=1"    // verbose queue reports
};

int FEED_RATE = 360;

float jog = 4; // inches

//float HOME_BELT[] = {-58, 59}; // right, left belt lengths when homed (right belt has negative length)
float HOME_BELT[] = {
  58, -59
}; // right, left belt lengths when homed (motors face canvas, left belt has negative length)
int REVERSE = -1;

float HOME_XY[] = {
  58, 24
};  // XY position (right, down from left motor) when homed

float HEKTOR_WIDTH = 115.0;  // separation between left and right motors
float CARRIAGE_WIDTH = 3.5; // separation between left and right supports on carriage

Serial tinyg;

int hektorQueueLength = 0;

boolean hektor_homed = false;
float XY[] = {
  0, 0
};

// call setup_robot at startup time to initialize motor drivers
// IT TAKES ABOUT 20 SECONDS
void hektorSetup() {
  if (!useHektor) return;
  
  tinyg = new Serial(this, TINYG_SERIAL_PORT, TINYG_SERIAL_SPEED);

  for (int i=0; i<TINYG_INITIALIZERS.length; i++) {
    tinyg.write(TINYG_INITIALIZERS[i]);
    tinyg.write("\n");
    println("Sending: " + TINYG_INITIALIZERS[i]);
    delay(500);
  }

}

void hektorGotoXY(float X, float Y) {
  if (!useHektor) return;
  
  if (!hektor_homed) {
    println("NOT HOMED!");
    return;
  }
  float N = REVERSE * (float)Math.sqrt( (X-CARRIAGE_WIDTH/2)*(X-CARRIAGE_WIDTH/2) + Y*Y );
  float M = REVERSE * -1 * (float)Math.sqrt( (HEKTOR_WIDTH-X-CARRIAGE_WIDTH/2)*(HEKTOR_WIDTH-X-CARRIAGE_WIDTH/2) + Y*Y );
  String gcode = "G01 X" + nf(M, 0, 2) + " Y" + nf(N, 0, 2) + " F" + FEED_RATE;
  tinyg.write(gcode);
  tinyg.write("\n");

  //println("GO " + nf(X, 0, 2) + ", " + nf(Y, 0, 2) + " => " + gcode);
}

void hektorSetHome() {
  if (!useHektor) return;
  
  XY[0] = HOME_XY[0];
  XY[1] = HOME_XY[1];

  tinyg.write("G92 X");
  tinyg.write(nf(HOME_BELT[0], 0, 2));
  tinyg.write(" Y");
  tinyg.write(nf(HOME_BELT[1], 0, 2));
  tinyg.write("\n");
  hektor_homed = true;
}

void hektorJog(float dx, float dy) {
  if (!useHektor) return;
    
  XY[0] += dx * jog;
  XY[1] += dy * jog;
  hektorGotoXY(XY[0], XY[1]);
}

void hektorSerialEvent(String data) {
  //println("Hektor serial event " + data);
  String[] m = match(data, "qr:(\\d+)");
  if (m != null) {
    int qr = Integer.parseInt(m[1]);
    hektorQueueLength = 28 - qr;
    println("Hektor queue: " + hektorQueueLength);
  }
}


// ---------------------------------------------------------------
void setup() {
  hektorSetup(); // takes 20-30 seconds!
  
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

  //resetPlatform();
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
}



// ---------------------------------------------------------------
void draw() {
  background(51);
  fill(#FFFFFF);
  noStroke();

  String msg[] = {
    "BPM = "+BPM, 
    "IBI = "+IBI, 
    "Signal = "+Sensor, 
    "Mean = "+Mean, 
    "StdDev = "+StdDev, 
    "StdDevThreshCounter = "+StdDevThreshCounter
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
  case 's':
    println("Saving Properties to "+props);
    cp5.saveProperties(props);
    break;

  case '0':
    buttonLightOff();
    break;

  case '1':
    buttonLightOn();
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
      hektorJog(0,-1);
      break;
    case DOWN:
      hektorJog(0,1);
      break;
    case LEFT:
      hektorJog(-1,0);
      break;
    case RIGHT:
      hektorJog(1,0);
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





/**********************************
 ╔═╗┌─┐┌┐┌  ╔═╗┌─┐┌┬┐┌┬┐┌─┐┌┐┌┌┬┐┌─┐
 ╠═╝├┤ │││  ║  │ │││││││├─┤│││ ││└─┐
 ╩  └─┘┘└┘  ╚═╝└─┘┴ ┴┴ ┴┴ ┴┘└┘─┴┘└─┘
 **********************************/

// ??  just guessing here
void penOneUp() {
}

void penOneDown() {
}




/**************************************************
 ╔═╗┬  ┌─┐┌┬┐┌─┐┌─┐┬─┐┌┬┐  ╔═╗┌─┐┌┬┐┌┬┐┌─┐┌┐┌┌┬┐┌─┐
 ╠═╝│  ├─┤ │ ├┤ │ │├┬┘│││  ║  │ │││││││├─┤│││ ││└─┐
 ╩  ┴─┘┴ ┴ ┴ └  └─┘┴└─┴ ┴  ╚═╝└─┘┴ ┴┴ ┴┴ ┴┘└┘─┴┘└─┘
 **************************************************/

void platformUp() {
}


// x, y in range 0.0 to 1.0
void movePlatform(float x, float y) {
  float platformX = x * 72 + 24;
  float platformY = y * 72 + 24;
  
  println("Hektor to "+x+", "+y + ", => " + platformX + ", " + platformY + " - enabled? " + useHektor);
  hektorGotoXY(platformX, platformY);
}

void startNewDrawing() {
  drawingInProgress = true;
}

/*
void resetPlatform() {
  movePlatform(0.5, 1);
}
*/
