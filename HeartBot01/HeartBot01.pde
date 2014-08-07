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
boolean useSensor = false;
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



// ---------------------------------------------------------------
void setup() {
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

  resetPlatform();
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
  if (beatCounter == 0 || !heartbeatPresent()) {
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
  movePlatform(mouseX, mouseY);
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

  default:
    break;
  }
}

//----------------------------------------------------
void serialEvent(Serial port) {

  try {
    String inData = port.readStringUntil('\n');
    if (inData==null) return;
    inData = trim(inData);
    if (inData.length()==0) return;

    if (useSensor && port==sPort) {
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


void movePlatform(int x, int y) {
  float _x = map(x, 0, width, 0, 1);
  float _y = map(y, 0, height, 0, 1);
  println("Moving to "+_x+", "+_y);
}

void startNewDrawing() {
  drawingInProgress = true;
}

void resetPlatform() {
}

