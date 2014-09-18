

int lighted=0;
int myPins[] = { 
  2, 3, 4, 5, 6, 7, 8 };

int NUM_PINS = 7;
boolean boardLED = false;

int pace = 20;

void setup() {
  for(int i=0; i<NUM_PINS; i++) {
    pinMode(myPins[i], OUTPUT);
  }
  pinMode(13, OUTPUT);
}


void loop() {
  // loop_sevenBackInverted();
  loop_backAndForthInverted();
}


void loop_oneTwoOneTwo() {
  digitalWrite(13, boardLED ? 1 : 0);
  boardLED = !boardLED;

  int pin = myPins[lighted];

  digitalWrite(pin, true);
  delay(8 * pace);
  digitalWrite(pin, false);
  delay(5 * pace);
  digitalWrite(pin, true);
  delay(20 * pace);
  digitalWrite(pin, false);
  delay(50 * pace);


  lighted = (lighted+1) % NUM_PINS;
}

void loop_allOn() {
  light(10,10,true);
}


void loop_sevenBack() {
  int a=30, b=60, c=110;
  
  light(0,a);
  light(1,a);
  light(2,a);
  delay(b);
  light(3,a);
  light(4,a);
  light(5,a);
  light(6,a);
  delay(c);
}

void loop_sevenBackInverted() {
  int a=30, b=60, c=110;
  
  light(0,a, true);
  light(1,a, true);
  light(2,a, true);
  delay(b);
  light(3,a, true);
  light(4,a, true);
  light(5,a, true);
  light(6,a, true);
  delay(c);
}

void loop_backAndForthInverted() {
  int a=24, b=40, c=60;
  
  light(0,a, true);
  light(1,a, true);
  light(2,a, true);
  light(3,a, true);
  light(4,a, true);
  light(5,a, true);
  light(6,a, true);  
  light(-1,a, true);  
  delay(b);
  light(6,b, true);
  light(5,b, true);
  light(4,b, true);
  light(3,b, true);
  light(2,b, true);
  light(1,b, true);
  light(0,b, true);
  light(-1,b,true);
  delay(c);
}

void light(int which, int howlong) {
  light(which, howlong, false);
}

void light(int which, int howlong, boolean reverse) {
  int m = 2;
  for (int i=0; i<NUM_PINS; i++) {
    digitalWrite(myPins[i], which==i ? !reverse : reverse);
  }
  delay(howlong*m);
}





