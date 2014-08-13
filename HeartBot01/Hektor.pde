
/***********************************
 ╦ ╦┌─┐┬┌─┌┬┐┌─┐┬─┐  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠═╣├┤ ├┴┐ │ │ │├┬┘  ╚═╗ │ │ │├┤ ├┤ 
 ╩ ╩└─┘┴ ┴ ┴ └─┘┴└─  ╚═╝ ┴ └─┘└  └  
 ***********************************/


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

  "G90", // absolute positioning mode

  "G64", // continuous path mode
  "$kjd=1.0", // it's okay to decelerate even if it means that you will miss your path by .2 inches.
  "$yjd=1.0", // it's okay to decelerate even if it means that you will miss your path by .2 inches.

  //"G61.1", // exact path mode
  "G61", // exact stop mode

  "$mt=300", // wait 5 minutes idle before unpowering motors

  "$qv=1"    // verbose queue reports
};

int FEED_RATE = 360;

float jog = 4; // inches

//float HOME_BELT[] = {-58, 59}; // right, left belt lengths when homed (right belt has negative length)
float HOME_BELT[] = {
  77, -79 // RIGHT, LEFT!
}; // right, left belt lengths when homed (motors face canvas, left belt has negative length)
int REVERSE = -1;

float HOME_XY[] = {
  56.5, 56
};  // XY position (right, down from left motor) when homed

float CANVAS_OFFSET[] = {
  (HOME_XY[0]-36), (HOME_XY[1]-36) // calibration position is center of 6x6 foot drawing square
  };

  float HEKTOR_WIDTH = 115.0;  // separation between left and right motors
float CARRIAGE_WIDTH = 3.5; // separation between left and right supports on carriage

Serial tinyg;

int hektorQueueLength = 0;
int hektorQueueLimit = 5; // SELF IMPOSED LIMIT

boolean hektor_homed = false;
float XY[] = {
  0, 0
};

// call setup_robot at startup time to initialize motor drivers
// IT TAKES ABOUT 20 SECONDS
void hektorSetup() {
  if (!useHektor) {
    println("WARNING - hektor is disabled at the top of the code!");
    return;
  }

  tinyg = new Serial(this, TINYG_SERIAL_PORT, TINYG_SERIAL_SPEED);

  for (int i=0; i<TINYG_INITIALIZERS.length; i++) {
    tinyg.write(TINYG_INITIALIZERS[i]);
    tinyg.write("\n");
    println("Sending: " + TINYG_INITIALIZERS[i]);
    delay(150);
  }
}


// speed is fraction of maximum speed - 0.0 to 1.0
void hektorGotoXY(float X, float Y) {
  hektorGotoXY(X, Y, 1.0);
}

void hektorGotoXY(float X, float Y, float speed) {
  if (!useHektor) return;

  if (!hektor_homed) {
    println("NOT HOMED!");
    return;
  }

  float N = REVERSE * (float)Math.sqrt( (X-CARRIAGE_WIDTH/2)*(X-CARRIAGE_WIDTH/2) + Y*Y );
  float M = REVERSE * -1 * (float)Math.sqrt( (HEKTOR_WIDTH-X-CARRIAGE_WIDTH/2)*(HEKTOR_WIDTH-X-CARRIAGE_WIDTH/2) + Y*Y );
  String gcode = "G01 X" + nf(M, 0, 2) + " Y" + nf(N, 0, 2) + " F" + nf(FEED_RATE*speed, 0, 2);
  tinyg.write(gcode);
  tinyg.write("\n");
  hektorQueueLength = 100; // 100 means "queue out of date"
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

// approximate movement by using raw motor commands, for when it's not calibrated yet
void hektorJogRaw(float dx, float dy) {
  if (!useHektor) return;

  float hx=0, hy=0;
  if (dx != 0) {
    hx = REVERSE * dx;
    hy = REVERSE * dx;
  } else if (dy != 0) {
    hx = REVERSE * -dy;
    hy = REVERSE * dy;
  }

  tinyg.write("G91\n"); // relative coordinates
  tinyg.write("G0 X" + hx + " Y" + hy + "\n");
  tinyg.write("G90\n"); // back to absolute coords
}

void hektorSerialEvent(String data) {
  //println("Hektor serial event '" + data+"'");
  String[] m = match(data, "qr:(\\d+)");
  if (m != null) {
    int qr = Integer.parseInt(m[1]);
    hektorQueueLength = 28 - qr;
    //println("Hektor queue: " + hektorQueueLength);
  }
}

void hektorRequestQueueReport() {
  if (!useHektor) return;
  tinyg.write("$QR\n");
}

void hektorMotorsOff() {
  if (!useHektor) return;
  tinyg.write("$md\n");
}

// Request a RequestQueueReport every 2 seconds
int lastHektorRequestQueueReport = 0;
void hektorUpdate() {
  if (millis()-lastHektorRequestQueueReport > 2000) {
    hektorRequestQueueReport();
    //print("*");
    lastHektorRequestQueueReport = millis();
  }
}

