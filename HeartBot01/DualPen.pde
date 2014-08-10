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

