/***************************
 ╔═╗┌─┐┌┐┌  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠═╝├┤ │││  ╚═╗ │ │ │├┤ ├┤ 
 ╩  └─┘┘└┘  ╚═╝ ┴ └─┘└  └  
 **************************/

Serial dualPenPort;
//String DUALPEN_SERIAL_PORT = "/dev/tty.usbmodem26091";
String DUALPEN_SERIAL_PORT = "/dev/tty.usbmodem26021";
int DUALPEN_SERIAL_SPEED = 115200;
HashMap<Integer, Float> dualPenAngle = new HashMap<Integer, Float>();
HashMap<Integer, Float> dualPenTwitch = new HashMap<Integer, Float>();
HashMap<Integer, Boolean> dualPenDown = new HashMap<Integer, Boolean>();


void dualPenSetup() {
  if (!useDualPen) {
    println("WARNING - dualPen disabled");
    return;
  }
  dualPenPort = new Serial(this, DUALPEN_SERIAL_PORT, DUALPEN_SERIAL_SPEED);


  dualPenSetPen(1, false);
  dualPenSetPen(2, false);
  dualPenTwitch(1, 0, radians(90));
  dualPenTwitch(2, 0, radians(90));
}

void dualPenWrite(String s) {
  //println("Sending to dualPen: " + s);
  if (!useDualPen) return;

  dualPenPort.write(s);
  dualPenPort.write("\n");
}


// pen is 1 (left) or 2 (right); draw is boolean (true for pen to touch paper) 
void dualPenSetPen(int pen, boolean draw) {
  if (!useDualPen) return;

  dualPenDown.put(pen, draw);
  String s = "p" + pen + (draw ? "d" : "u");
  dualPenWrite(s);
}

// send pen 1 or 2 to its home to be out of the way of the other (top left, top right)
void dualPenHome(int pen) {
  if (pen==1) {
    dualPenWrite("p1g 0 1");
  } else if (pen==2) {
    dualPenWrite("p2g 1 0");
  }
}

// twitch pen 1 or 2 at a roughly -45 degree angle (\) - send values -1 to 1
void dualPenTwitch(int pen, float twitch) {
  dualPenTwitch(pen, twitch, 0.75*PI);
}

void dualPenTwitch(int pen, float twitch, float angle) {
  if (twitch < -1.0 || twitch > 1.0) return;

  dualPenTwitch.put(pen, twitch);
  dualPenAngle.put(pen, angle);

  String s = "p" + pen + "t " + twitch + " " + angle;
  dualPenWrite(s);
}

// set pen pressure -1.0 to 1.0 
void dualPenPressure(int pen, float pressure) {
  if (pressure < -1.0 || pressure > 1.0) return;
  String s = "p" + pen + "p " + pressure;
  dualPenWrite(s);
}

