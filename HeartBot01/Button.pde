
/**********************************
 ╔╗ ┬ ┬┌┬┐┌┬┐┌─┐┌┐┌  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠╩╗│ │ │  │ │ ││││  ╚═╗ │ │ │├┤ ├┤ 
 ╚═╝└─┘ ┴  ┴ └─┘┘└┘  ╚═╝ ┴ └─┘└  └  
 **********************************/


//----------------------------------------------------
void onButtonUp() {
  println("Button Up");
  if (heartbeatPresent() && !drawingInProgress) {
    startNewDrawing();
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


