import processing.serial.*;
import vsync.*;

ValueReceiver receiver;

public int trigval;

Serial aport, ledport;

int val;
int count = 0;
int sweep_count = 0;
int prev_trigval = 0;

String arduino_port = "/dev/ttyACM0"; // COM[port_number] in windows machines 
String coolled_port = "/dev/ttyACM2"; // COM[port_number] in windows machines

int[] intensities = {25, 50, 75, 100}; // intensity levels to be set
int[] nsweeps = {10, 10, 10, 10};  // number of triggers to count before changing intensity
int[] sumsweeps; 
int int_idx = 0;

String channel = "C";      // Channel id, A,B,C starting from the left to right of the control panel
String power_state = "N";  // "N" turns on the LED, "F" leaves it off
String coolled_command;

int framerate = 120;

void setup() 
{
  size(300, 200);
  background(255);
  frameRate(framerate);
  
  sumsweeps = arrCumSum(nsweeps);
  
  aport = new Serial(this, arduino_port, 57600);
  receiver = new ValueReceiver(this, aport);
  receiver.observe("trigval");
  
  ledport = new Serial(this, coolled_port, 57600);
  
  coolled_command = coolled_intensity_command(intensities[int_idx], channel, power_state);
  display(intensities[int_idx]);

  ledport.write(coolled_command);
  
}


void draw() {
  
  if (trigval != prev_trigval && trigval == 1) {
    
    int_idx = get_idx(sumsweeps, count);
    
    coolled_command = coolled_intensity_command(intensities[int_idx], channel, power_state);
    ledport.write(coolled_command);        
    display(intensities[int_idx]);

    //println(count, int_idx, coolled_command);
    
    count++;
    
  }
  
  prev_trigval = trigval;
  
}
 
 
String coolled_intensity_command(int intensity, String channel, String state) {
   
  String command = "";
   
  if (intensity != 100 && intensity >= 10) {
    command = "CSS" + channel + "S" + state + "0" + str(intensity) + "\r"; 
  }
  if (intensity < 10) {
    command = "CSS" + channel + "S" + state + "00" + str(intensity) + "\r";
  }
  if (intensity >= 100) {
    command = "CSS" + channel + "S" + state + "100\r";
  }
   
  return command;
 }
 
 
int[] arrCumSum(int[] arr){
  int[] sum = arr;
  int s = 0;
  for (int i = 0; i < arr.length; i++) {
    s += arr[i];
    sum[i] = s;
  }
  return sum;
}


int get_idx(int[] cumSumArray, int value) {
  
  int idx = 0;
  
  for(int i=0; i<cumSumArray.length - 1; i++) {
    
    if(value < cumSumArray[i+1] && value >= cumSumArray[i]) {
      idx = i+1;
    }
    
  }
  
  return idx;
}


void display(int intensity) {
  
  background(255);
  
  fill(0, 102, 153);
  textSize(32);
  text("Intensity : " + str(intensity) + " %", 35, 100);
  
}
 