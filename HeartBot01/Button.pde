
/**********************************
 ╔╗ ┬ ┬┌┬┐┌┬┐┌─┐┌┐┌  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠╩╗│ │ │  │ │ ││││  ╚═╗ │ │ │├┤ ├┤ 
 ╚═╝└─┘ ┴  ┴ └─┘┘└┘  ╚═╝ ┴ └─┘└  └  
 **********************************/


//----------------------------------------------------
void onButtonUp() {
  println("Button Up");
//  if (heartbeatPresent() && !drawingInProgress) {
//    startNewDrawing();
//  }
}

//----------------------------------------------------
void onButtonDown() {
  println("Button Down");
}

//----------------------------------------------------
void buttonLightOn() {
  if (!useSensor) return;
  println("1");
  sPort.write("1");
  sPort.write("\n");
}

//----------------------------------------------------
void buttonLightOff() {
  if (!useSensor) return;
  println("0");
  sPort.write("0");
  sPort.write("\n");
}

