

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



void not_loop() {
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


void loop() {
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

void light(int which, int howlong) {
  int m = 2;
  for (int i=0; i<NUM_PINS; i++) {
    digitalWrite(myPins[i], which==i);
  }
  delay(howlong*m);
}





