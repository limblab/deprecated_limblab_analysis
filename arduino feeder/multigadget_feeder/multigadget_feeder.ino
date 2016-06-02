#include <SPI.h>
#include <Wire.h>
#include <Adafruit_MotorShield.h> //refers to the "Adafruit Motor Shield v2" library
#include "RTClib.h" 

//Declare global variables

RTC_DS1307 RTC; //Initialize real time clock
Adafruit_MotorShield AFMS = Adafruit_MotorShield(); //Motor shield with default I2C address
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 2); //Stepper motor with 200 steps per revolution, to motor port 2 (M3 and M4)

//timing variables (we need these to be global so we can keep track of time over several loops)
unsigned long ms_prev = 0; //the time in ms from initialization of the program, saved from the previous loop
unsigned long ms_incr; //the amount of time that passed while the program executed a loop
int lastBlink1 = 0; //time since last blink of LED for sensor 1 
int lastBlink2 = 0; //time since last blink of LED for sensor 2
int lastTreat = 1000; //time in ms since last treat was given to the monkey (start at or above [betweenTreats] number to eliminate first-time delay)
int betweenTreats = 1000; //time in ms before monkey can start to earn another treat after receiving one
bool cycle = false; //determine whether the cycle indicator (to read time per cycle) is high (true) or low (false)
int active = 0; //amount of time the monkey has been doing the task correctly
int actTime = 5000; //amount of time the monkey has to do the task to get a treat

//motor control
int mot_ctr = 0; //current motor step
int giving_treat = 0; //whether we are currently giving a treat (0 = no, 1 = yes)

//LEDs and LED state
int goLED1 = 0; //status of "you can do the task" LED for the first sensor (0=LOW, 1=HIGH)
int goLED2 = 0; //status of "you can do the task" LED for the second sensor

//thresholds
int th11 = 100; //threshold for device 1, sensor 1 (how hard does the monkey have to squeeze)
int th12 = 100; //threshold for device 1, sensor 2 
int th21 = 100; //threshold for device 2, sensor 1 
int th22 = 100; //threshold for device 2, sensor 2 
int rand_threshold = 100; //% of times the monkey receives a treat TODO: include this!

void setup() {
  //Initialize serial, communications, and real time clock
  Serial.begin(9600);
  Wire.begin();
  RTC.begin();

  if (! RTC.isrunning() ){ //check if the clock is running
    Serial.println("RTC is not running.");
  }

  //initialize the motor
  AFMS.begin(); //default frequency 1.6 kHz
  myMotor->setSpeed(10); //10 rpm

  //set up pins for digital output
  pinMode(5, OUTPUT); //LED for motor-on signal
  pinMode(6, OUTPUT); //LED on device 1 (this turns on with a LOW signal)
  pinMode(7, OUTPUT); //LED on device 2 (this turns on with a LOW signal)
  pinMode(8, OUTPUT); //indicator for cycle time

  delay(500);
}

void loop() {
  //Serial.println(analogRead( 4 ));
  
  //keep track of time per loop
  ms_incr = millis() - ms_prev; //get time since the last delay (not including delay)
  if(ms_incr<50){ //delay the loop so that it consistently takes 50 ms (actually ends up 49-52 ms)
    delay(50-ms_incr);
  }
  ms_incr = millis() - ms_prev; //get time since the last delay (including new delay)
  ms_prev = millis(); //reset time for the next loop
  //Serial.print("cycle time: "); 
  //Serial.println(ms_incr); 
  lastTreat += ms_incr; //add cycle time to time since last treat

  //Indicate the cycle time via a digital output
  //switch digital out between high and low so we can read timing of cycle (it switches every time)
  if (cycle) {
    digitalWrite(8, HIGH);
    cycle = false;
  }
  else if (!cycle) {
    digitalWrite(8, LOW);
    cycle = true;
  }

  //turn the motor until it has finished dispensing a treat
  if (giving_treat) {
    turnMotor();
  }

  //check whether the treat dispenser is in a refractory period or currently dispensing treat
  //if not, read all sensors, blink the correct lights, and pay attention to amount of time the sensors have been activated correctly
  if (canAttempt()){

    //read the sensors 
    int sensor1_1 = analogRead( 0 );     // Read device 1 sensor 1 (in pin 0)
    int sensor1_2 = analogRead( 1 );     // Read device 1 sensor 2 (in pin 1)
    int sensor2_1 = analogRead( 2 );     // Read device 2 sensor 1 (in pin 2)
    int sensor2_2 = analogRead( 3 );     // Read device 2 sensor 2 (in pin 3)

    Serial.print("Sensor 1: "); 
    Serial.println(sensor2_1);
    Serial.print("Sensor 2: ");
    Serial.println(sensor2_2);
    
    //if both device 1 sensors are active, blink the LED for that device
    if ( sensor1_1>th11 && sensor1_2>th12 ){
      lastBlink1 += ms_incr; //add time to blinking variable
      blinkLED(6, goLED1, lastBlink1); 
    }
    else if (goLED1 == 1) {
      //turn on the device's LED so the monkey knows it can start
      digitalWrite(6, LOW); 
      goLED1 = 0; 
    }
    
    //if both device 2 sensors are active, blink the LED for that device
    if ( sensor2_1>th21 && sensor2_2>th22 ){
      lastBlink2 += ms_incr; 
      blinkLED(7, goLED2, lastBlink2); 
    }
    else if (goLED2 == 1) {
      //turn on the device's LED so the monkey knows it can start
      digitalWrite(7, LOW); 
      goLED2 = 0; 
    }
    
    //if all four sensors are active, start counting
    if ( sensor1_1>th11 && sensor1_2>th12 && sensor2_1>th21 && sensor2_2>th22 ){
      //count
      active += ms_incr; 
      if ( active >= actTime ) { //has held the gripper for as long as required
        if ( random(101) < rand_threshold ){ //the monkey receives a treat [rand_threshold] percent of the time
          //give treat
          //set a variable equal to 1 (true) so we know to keep turning the motor on subsequent iterations of the loop
          giving_treat = 1; 
          turnMotor(); 
        }
        lastTreat = 0; //reset time since last treat
        active = 0; //reset the amount of time the monkey has been attempting the task
      }
    }
    else {
      active = 0;
    }
  }
  else { //monkey can't attempt task and must wait
    //turn off LEDs for both devices
    digitalWrite(6, HIGH); //TODO: check this HIGH/LOW confusion with actual device
    digitalWrite(7, HIGH); 
    goLED1 = 1; //remember the states of the LEDs
    goLED2 = 1; 
  }

}



///////////////////////

// Function that turns the motor

void turnMotor () {
  // Turn the motor
  if ( mot_ctr < 30 ) { //The limiting number must be divisible by the number of steps or it stops after the first rotation
    myMotor->step(1, FORWARD, DOUBLE);
    mot_ctr  += 1;
    digitalWrite( 5, HIGH ); // Turn on the LED that indicates that the motor is turning on
  }
  
  else if ( mot_ctr == 30 ) {
    mot_ctr = 0;
    digitalWrite( 5, LOW ); // Turn off the LED that indicates that the motor is turning off
    giving_treat = 0; //done giving the treat
  }
}


// Function that blinks LEDs
void blinkLED(int ledPin, int &ledState, int &lastBlink){ //use references so we can edit each sensor's info
  //check the amount of time passed since the LED last blinked
  //if it has been 200 ms, check the current state of the pin (0=LOW, 1=HIGH)
  if (lastBlink>=200){
    if (ledState == 0){
      digitalWrite(ledPin, HIGH);
      ledState = 1; //keep track of state changes
      lastBlink = 0; //reset time for blinks to zero
    }
    else if (ledState == 1){
      digitalWrite(ledPin, LOW); 
      ledState = 0; //remember current state
      lastBlink = 0; //reset time for blinks to zero
    }
  }
}


// Function that tests if the monkey can proceed 
// (has it been more than [betweenTreats] milliseconds since the last treat)
bool canAttempt(){
   if (lastTreat >= betweenTreats){ //if time since last treat was dispensed is greater than the waiting period
    lastTreat = betweenTreats; //reset this value so it doesn't get obscenely high
    if (giving_treat == 0){
      return true; //monkey can attempt task again
    }
    else{
      return false; //monkey can't attempt task because it is getting a treat
    }
   }
   else{ 
    return false; //monkey can't attempt task yet
   }
}






