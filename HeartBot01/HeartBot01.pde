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
Serial sPort;

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

ArrayList<Integer> BPMHistory = new ArrayList<Integer>();

int Button = 1;      // Current Button Signal (updated in serialEvent)
int ButtonLast = 1;  // Button signal as of last pre() - used to determine change events




/*************************************
 ╦═╗┌─┐┌┐ ┌─┐┌┬┐  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠╦╝│ │├┴┐│ │ │   ╚═╗ │ │ │├┤ ├┤ 
 ╩╚═└─┘└─┘└─┘ ┴   ╚═╝ ┴ └─┘└  └  
 *************************************/


// For you, Ranjit



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
    .setPosition(10, 20)
      .setRange(100, 300);

  cp5.loadProperties(props);

  println(Serial.list());

  sPort = new Serial(this, "/dev/tty.usbmodem1411", 115200); 
  sPort.clear();            // flush buffer
  sPort.bufferUntil('\n');  // set buffer full flag on receipt of carriage return

  buttonLightOff();
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
    if (port==sPort) {
      sensorSerialEvent(inData);
    }
  } 
  catch (Exception e) {
    println("Problem reading from serial");
    e.printStackTrace();
  }
}



//----------------------------------------------------
void sensorSerialEvent(String inData) {
  if (inData.charAt(0) == 'S') {          // leading 'S' for sensor data
    inData = inData.substring(1);        // cut off the leading 'S'
    Sensor = int(inData);                // convert the string to usable int
  }
  if (inData.charAt(0) == 'B') {          // leading 'B' for BPM data
    inData = inData.substring(1);        // cut off the leading 'B'
    BPM = int(inData);                   // convert the string to usable int
    beat = true;                         // set beat flag to advance heart rate graph
  }
  if (inData.charAt(0) == 'Q') {            // leading 'Q' means IBI data 
    inData = inData.substring(1);        // cut off the leading 'Q'
    IBI = int(inData);                   // convert the string to usable int
  }
  if (inData.charAt(0) == 'P') {        // is the button up or down?
    inData = inData.substring(1);
    Button = int(inData);
  }
}


//----------------------------------------------------
boolean heartbeatPresent() {
  return StdDevThreshCounter > 150;
}

//----------------------------------------------------
void crunchSensorData() {

  // Deal with the data from the heart rate sensor
  Signal.add( Sensor );
  if (Signal.size() > BufferSize) {
    Signal.remove(0);
  }

  if (Signal.size() < BufferSize) return;

  int Total = 0;
  for (int i=0; i<Signal.size (); i++) {
    Total += Signal.get(i);
  }
  Mean = Total / (float)Signal.size();

  float E=0;
  for (int i=0; i<Signal.size (); i++) {
    E += (Signal.get(i) - Mean) * (Signal.get(i) - Mean);
  }

  StdDev = sqrt(1 / (float)Signal.size () * E);

  // Update StdDevThreshCounter
  if (StdDev > StdDevThresh) {
    StdDevThreshCounter++;
  } else {
    StdDevThreshCounter=0;
  }
}

// ---------------------------------------------------------------
void drawSignal() {
  pushStyle(); 
  color c;
  if (StdDevThreshCounter>200) {
    stroke(#00FF00);
  } else {
    stroke(#FF0000);
  }

  noFill();
  beginShape();                             
  for (int i = 0; i < Signal.size (); i++) {
    float x = map(i, 0, BufferSize, 0, width-50);
    float y = map(Signal.get(i), 0, 1024, height-100, 100);
    vertex(x, y);
  }
  endShape();
  popStyle();
}

// ---------------------------------------------------------------
void drawHeart(int x, int y) {
  pushMatrix();
  translate(x, y);
  scale(0.25, 0.25);
  pushStyle();
  fill(250, 0, 0);
  stroke(250, 0, 0);
  strokeWeight(max(beatCounter, 0));
  smooth();   // draw the heart with two bezier curves
  bezier(0, 0, -80, -70, -100, 90, 0, 100);
  bezier(0, 0, 90, -70, 100, 90, 0, 100);
  strokeWeight(1);          // reset the strokeWeight for next time
  popStyle();
  popMatrix();
}



/**********************************
╔╗ ┬ ┬┌┬┐┌┬┐┌─┐┌┐┌  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
╠╩╗│ │ │  │ │ ││││  ╚═╗ │ │ │├┤ ├┤ 
╚═╝└─┘ ┴  ┴ └─┘┘└┘  ╚═╝ ┴ └─┘└  └  
**********************************/


//----------------------------------------------------
void onButtonUp() {
  println("Button Up");
  if (heartbeatPresent()) {
    
  }
}


//----------------------------------------------------
void onButtonDown() {
  println("Button Down");
}

//----------------------------------------------------
void buttonLightOn() {
  //println("Light On");
  //port.write("L");
  sPort.write("1");
  sPort.write("\n");
}


//----------------------------------------------------
void buttonLightOff() {
  //println("Light Off");
  //port.write("L");
  sPort.write("0");
  sPort.write("\n");
}
