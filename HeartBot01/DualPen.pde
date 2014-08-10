/***************************
 ╔═╗┌─┐┌┐┌  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠═╝├┤ │││  ╚═╗ │ │ │├┤ ├┤ 
 ╩  └─┘┘└┘  ╚═╝ ┴ └─┘└  └  
 **************************/

Serial dualPenPort;
String DUALPEN_SERIAL_PORT = "/dev/tty.usbmodem26091";
int DUALPEN_SERIAL_SPEED = 115200;

void dualPenSetup() {
  if (!useDualPen) {
    println("WARNING - dualPen disabled");
    return;
  }
  dualPenPort = new Serial(this, DUALPEN_SERIAL_PORT, DUALPEN_SERIAL_SPEED);
}

void dualPenWrite(String s) {
  println("Sending to dualPen: " + s);
  dualPenPort.write(s);
  dualPenPort.write("\n");
}

// pen is 1 (left) or 2 (right); draw is boolean (true for pen to touch paper) 
void dualPenSetPen(int pen, boolean draw) {
  if (!useDualPen) return;

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
  if (twitch < -1.0 || twitch > 1.0) return;
  String s = "p" + pen + "t " + twitch;
  dualPenWrite(s);  
}


