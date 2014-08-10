// intel-toolofna drawbot
// servo tester
// cc - by Ranjit Bhatnagar 2014


// math taken from Johannes Heberlein's Plotclock
// cc - by Johannes Heberlein 2014
// v 1.01
//thingiverse.com/joo   wiki.fablab-nuernberg.de



/* servos on teensy 3.1 digital pins:

 plotter 1 (right)
     servo A (left): 17  
     servo B (right): 16 
     servo C (lift): 15
     
 plotter 2 (left)
     servo A (left): 22
     servo B (right): 21
     servo C (lift): 20

*/
#include <Servo.h> 


Servo s1a, s1b, s1l, s2a, s2b, s2l;

int servofaktor = 630;

int s2aNull = 2450;
int s2bNull = 384;
int s2liftWrite = 1180;
int s2writeVariance = 80; // amount to vary pressure in response to p1p/p2p command
int s2liftUp = 1000;
  
float geom1L1 = 35;   // mm from servo to elbow joint
float geom1L2 = 57;  // elbow to pen point (projected vertically)
float geom1L3 = 15;// wrist joint to pen (projected vertically)


int s1aNull = 1900;
int s1bNull = 750;
int s1liftWrite = 1500;
int s1writeVariance = 90;
int s1liftUp = 1300;

float geom2L1 = 35;
float geom2L2 = 57;
float geom2L3 = 15;
/*
float geom1L1 = 35;   // mm from servo to elbow joint
float geom1L2 = 110;  // elbow to pen point (projected vertically)
float geom1L3 = 75;   // wrist joint to pen (projected vertically)

float geom2L1 = 35;
float geom2L2 = 110;
float geom2L3 = 75;
*/

// origin points of left and right servo (same on both sides)
#define O1X 22
#define O1Y -25
#define O2X 47
#define O2Y -25


// pen down states
boolean pen1down = false, pen2down = false;
float pen1pressure = 0.0, pen2pressure = 0.0;


String serialBuffer = "";


void setup() {
  Serial.begin(115200);
  Serial.println("dual pen crab here");
  
  serialBuffer.reserve(200);
  
  s1a.attach(17);
  s1b.attach(16);
  s1l.attach(15);
  s1l.writeMicroseconds(s1liftUp);
  
  s2a.attach(22);
  s2b.attach(21);
  s2l.attach(20);
  s2l.writeMicroseconds(s2liftUp);
  
  set_XY_1(30,30);
  set_XY_2(30,30);
  write_1(false);
  write_2(false);
}



void serialLine(String s) {
  // pen up / down
  if (s=="p2u") write_2(false);
  else if (s=="p2d") write_2(true);
  
  else if (s=="p1u") write_1(false);
  else if (s=="p1d") write_1(true); 
  
  // pen move raw (local coordinates)
  else if (s.indexOf("p1r")==0) {
    parseGoRaw(1, s);
  }
  else if (s.indexOf("p2r")==0) {
    parseGoRaw(2, s);
  }
  
  // pen move (artificial safe coordinates 0.0-1.0)
  else if (s.indexOf("p1g")==0) {
    parseGo(1, s);
  }
  else if (s.indexOf("p2g")==0) {
    parseGo(2, s);
  }
  
  // pen twitch 45 degrees left of vertical (from -1 bottom right to +1 top left)
  // optional second argument is angle (in radians) - default  3/4 * PI
  else if (s.indexOf("p1t")==0) {
    parseTwitch(1, s);
  }
  else if (s.indexOf("p2t")==0) {
    parseTwitch(2, s);
  }
  
  // pen down pressure -1.0 to 1.0
  else if (s.indexOf("p1p")==0) {
    parsePressure(1, s);
  }
  else if (s.indexOf("p2p")==0) {
    parsePressure(2, s);
  }
  
}

float parseFloat(String s) {
  char buffer[30];
  s.toCharArray(buffer, 30);
  float f = atof(buffer);
  return f;
}

void parseGo(int pen, String s) {
  String xs = getNthToken(s, ' ', 1);
  String ys = getNthToken(s, ' ', 2);
  
  //Serial.println("xs is " + xs + " and ys is " + ys);
  
  if (xs != "" && ys != "") {
     float x = parseFloat(xs);
     float y = parseFloat(ys);
     
     if (x < 0.0 || y > 1.0) return;
     if (y < 0.0 || y > 1.0) return;
     
     if (pen < 1 || pen > 2) return;
     
     goNormalized(pen, x, y);
     /*
     Serial.print("Pen ");
     Serial.print(pen);
     Serial.print(" to ");
     Serial.print(localX);
     Serial.print(",");
     Serial.println(localY);
     */
  }
}

void parseGoRaw(int pen, String s) {
  String xs = getNthToken(s, ' ', 1);
  String ys = getNthToken(s, ' ', 2);
  
  //Serial.println("xs is " + xs + " and ys is " + ys);
  
  if (xs != "" && ys != "") {
    float x = parseFloat(xs);
    float y = parseFloat(ys);
   /*
    Serial.print("Pen ");
    Serial.print(pen);
    Serial.print(" to ");
    Serial.print(x);
    Serial.print(",");
    Serial.println(y);
    */
    set_XY(pen, x, y);
  }
}

void parseTwitch(int pen, String s) {
  String ts = getNthToken(s, ' ', 1);
  String as = getNthToken(s, ' ', 2); // optional angle argument 0 to PI
  if (ts != "") {
    float t = parseFloat(ts);
    if (t < -1.0 || t > 1.0) return;
    
    float a = 3*PI/4.0;
    if (as != "") {
      a = parseFloat(as);
    }
    
    Serial.print("twitch ");
    Serial.print(t);
    Serial.print(" angle ");
    Serial.print(a * 360.0 / TWO_PI);
    Serial.println();
    
    float x = 0.5 + 0.4*t*cos(a);
    float y = 0.5 + 0.4*t*sin(a);
    
    goNormalized(pen, x, y);
  }
}


void parsePressure(int pen, String s) {
  String ps = getNthToken(s, ' ', 1);
  if (ps != "") {
    float p = parseFloat(ps);
    if (p < -1.0 || p > 1.0) return;
    
    if (pen==1) {
      pen1pressure = p;
      if (pen1down) write_1(true);
    }
    else if (pen==2) {
      pen2pressure = p;
      if (pen2down) write_2(true);
    }
    
  }
}

void set_XY(int pen, float x, float y) { 
    if (pen==1) {
      set_XY_1(x, y);
    }
    else if (pen==2) {
      set_XY_2(x, y);
    }
}


void checkSerial() {
  while (Serial.available()) {
    byte b = Serial.read();
    char c = (char)b;

    if (b==10 || b==13) {
      serialLine(serialBuffer);
      serialBuffer = "";
    }
    else serialBuffer.concat(c);
  }
}



void loop() {
  loop2();
  checkSerial();
}


boolean writing = false;

void loop2() {
  /*
  int xx = 10;
  
  writing = !writing;
  write_1(false);
  
  set_XY_1(20+xx,30);
  delay(500);
  set_XY_1(20+xx,40);
  delay(500);
  set_XY_1(10+xx,40);
  delay(500);
  set_XY_1(10+xx,30);
  delay(500);


  write_2(true);
  
  set_XY_2(30,30);
  */
  //set_XY_2(30,30);
}





void goNormalized(int pen, float x, float y) {
    float localX = 30, localY = 30; 
     if (pen==1) {
       localX = 15.0 + y*36.0;
       localY = 10.0 + y*40.0;
       set_XY_1(localX, localY);
     }
     else if (pen==2) {
       localX = 50.0 - y*35.0;
       localY = 70.0 - x*50.0;
       set_XY_2(localX, localY);
     } 
}




double return_angle(double a, double b, double c) {
  // cosine rule for angle between c and a
  return acos((a * a + c * c - b * b) / (2 * a * c));
}

void write_1(boolean wr) {
  if (wr) {
    s1l.writeMicroseconds(s1liftWrite + s1writeVariance*pen1pressure);
    pen1down = true;
  }
  else {
    s1l.writeMicroseconds(s1liftUp);
    pen1down = false;
  }
}

void set_XY_1(double Tx, double Ty) 
{
  delay(1);
  double dx, dy, c, a1, a2, Hx, Hy;

  // calculate triangle between pen, servoLeft and arm joint
  // cartesian dx/dy
  dx = Tx - O1X;
  dy = Ty - O1Y;

  // polar lemgth (c) and angle (a1)
  c = sqrt(dx * dx + dy * dy); // 
  a1 = atan2(dy, dx); //
  a2 = return_angle(geom1L1, geom1L2, c);

  s1a.writeMicroseconds(floor(((a2 + a1 - M_PI) * servofaktor) + s1aNull));

  // calculate joinr arm point for triangle of the right servo arm
  a2 = return_angle(geom1L2, geom1L1, c);
  Hx = Tx + geom1L3 * cos((a1 - a2 + 0.621) + M_PI); //36,5°
  Hy = Ty + geom1L3 * sin((a1 - a2 + 0.621) + M_PI);

  // calculate triangle between pen joint, servoRight and arm joint
  dx = Hx - O2X;
  dy = Hy - O2Y;

  c = sqrt(dx * dx + dy * dy);
  a1 = atan2(dy, dx);
  a2 = return_angle(geom1L1, (geom1L2 - geom1L3), c);

  s1b.writeMicroseconds(floor(((a1 - a2) * servofaktor) + s1bNull));

}


void write_2(boolean wr) {
  if (wr) {
    s2l.writeMicroseconds(s2liftWrite + s2writeVariance*pen2pressure);
    pen2down = true;
  }
  else {
    s2l.writeMicroseconds(s2liftUp);
    pen2down = false;
  }
}

void set_XY_2(double Tx, double Ty) 
{
  delay(1);
  double dx, dy, c, a1, a2, Hx, Hy;

  // calculate triangle between pen, servoLeft and arm joint
  // cartesian dx/dy
  dx = Tx - O1X;
  dy = Ty - O1Y;

  // polar lemgth (c) and angle (a1)
  c = sqrt(dx * dx + dy * dy); // 
  a1 = atan2(dy, dx); //
  a2 = return_angle(geom2L1, geom2L2, c);

  s2a.writeMicroseconds(floor(((a2 + a1 - M_PI) * servofaktor) + s2aNull));

  // calculate joinr arm point for triangle of the right servo arm
  a2 = return_angle(geom2L2, geom2L1, c);
  Hx = Tx + geom2L3 * cos((a1 - a2 + 0.621) + M_PI); //36,5°
  Hy = Ty + geom2L3 * sin((a1 - a2 + 0.621) + M_PI);

  // calculate triangle between pen joint, servoRight and arm joint
  dx = Hx - O2X;
  dy = Hy - O2Y;

  c = sqrt(dx * dx + dy * dy);
  a1 = atan2(dy, dx);
  a2 = return_angle(geom2L1, (geom2L2 - geom2L3), c);

  s2b.writeMicroseconds(floor(((a1 - a2) * servofaktor) + s2bNull));

}


// from http://arduino.stackexchange.com/a/1237
String getNthToken(String data, char separator, int index)
{
 int found = 0;
  int strIndex[] = {
0, -1  };
  int maxIndex = data.length()-1;
  for(int i=0; i<=maxIndex && found<=index; i++){
  if(data.charAt(i)==separator || i==maxIndex){
  found++;
  strIndex[0] = strIndex[1]+1;
  strIndex[1] = (i == maxIndex) ? i+1 : i;
  }
 }
  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}

