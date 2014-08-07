
/*********************************
 ╔═╗┌─┐┌┐┌┌─┐┌─┐┬─┐  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╚═╗├┤ │││└─┐│ │├┬┘  ╚═╗ │ │ │├┤ ├┤ 
 ╚═╝└─┘┘└┘└─┘└─┘┴└─  ╚═╝ ┴ └─┘└  └  
 *********************************/


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

