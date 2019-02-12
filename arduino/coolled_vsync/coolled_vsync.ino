#include <VSync.h>
ValueSender<1> sender;


const int trigpin = 12;

int trigval = 0;

void setup() {

  pinMode(trigpin, INPUT);
  
  Serial.begin(57600);
  sender.observe(trigval);
 
}

void loop() {

  trigval = digitalRead(trigpin);
  
  sender.sync();
  
}
