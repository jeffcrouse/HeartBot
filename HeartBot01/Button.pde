
/**********************************
 ╔╗ ┬ ┬┌┬┐┌┬┐┌─┐┌┐┌  ╔═╗┌┬┐┬ ┬┌─┐┌─┐
 ╠╩╗│ │ │  │ │ ││││  ╚═╗ │ │ │├┤ ├┤ 
 ╚═╝└─┘ ┴  ┴ └─┘┘└┘  ╚═╝ ┴ └─┘└  └  
 **********************************/


//----------------------------------------------------
void onButtonUp() {
  println("Button Up");
  
  if(!hektor_homed) return;
  int module = int(moduleChooser.getValue());
  switch(module) {
  case 1: 
    doCircles(); 
    break;
  case 2: 
    doFishbone(); 
    break;
  case 3: 
    doStarburst(); 
    break;
  case 4: 
    doTriangles(); 
    break;
  case 5: 
    doVortex(); 
    break;
  }
}

//----------------------------------------------------
void onButtonDown() {
  println("Button Down");
  if (!drawingInProgress) {
  }
}

//----------------------------------------------------
void buttonLightOn() {
  if (!useSensor) return;
  //println("1");
  sPort.write("1");
  sPort.write("\n");
}

//----------------------------------------------------
void buttonLightOff() {
  if (!useSensor) return;
  //println("0");
  sPort.write("0");
  sPort.write("\n");
}

