

int lighted=0;
int myPins[] = {
  1, 2, 3, 4, 5, 6, 7};
int NUM_PINS = 7;
int delayLength = 1000;


void setup() {
  for(int i=0; i<NUM_PINS; i++) {
    pinMode(myPins[i], OUTPUT);
  }
}

void loop() {
  for(int i=0; i<NUM_PINS; i++) {
    digitalWrite(myPins[lighted], lighted==i);
  }

  delay(delayLength);
  lighted = (lighted+1) % NUM_PINS;
}


