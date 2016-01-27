#include <SD.h>
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
int sol_time = 0; //amount of time we've been dispensing water
int betweenTreats = 1000; //time in ms before monkey can start to earn another treat after receiving one
bool cycle = false; //determine whether the cycle indicator (to read time per cycle) is high (true) or low (false)
int active = 0; //amount of time the monkey has been doing the task correctly
int actTime = 5000; //amount of time the monkey has to do the task to get a treat

//Reward (motor and solenoid) control
int mot_ctr = 0; //current motor step
int giving_reward = 0; //whether we are currently giving a treat (0 = no, 1 = yes)
int solenoid_pin = 11; //TODO update this to whatever I want it to be forever and ever.

//LEDs and LED state
int goLED1 = 0; //status of "you can do the task" LED for the first sensor (0=LOW, 1=HIGH)
int goLED2 = 0; //status of "you can do the task" LED for the second sensor

//thresholds
int th11 = 100; //threshold for device 1, sensor 1 (how hard does the monkey have to squeeze)
int th12 = 100; //threshold for device 1, sensor 2
int th21 = 100; //threshold for device 2, sensor 1
int th22 = 100; //threshold for device 2, sensor 2
int rand_threshold = 100; //% of times the monkey receives a treat 

//file management
int reward_type = 1; //0 for water (solenoid), 1 for dry food (motor)
int task_type1 = 0; //0 for force-sensitive resistor tasks, 1 for rotary potentiometer tasks - sensor 1
int task_type2 = 0; //sensor 2
int sensor_1_act = 0; //0 for false, 1 for true (sensor active)
int sensor_2_act = 0; 
int reward_amount = 0; 

/* variable setup on the SD card:
 *  TXT document named "setup.txt"
 *  Lists these variables in the following order (each value should be alone on a line):
 *  th11 (threshold for amount of pressure for device one, sensor one)
 *  th12
 *  th21
 *  th22
 *  rand_threshold (in %: how often should the monkey get a treat?)
 *  reward_type (0 = water (solenoid), 1 = food (motor))
 *  task_type1 (0 for FSR, 1 for rotary) - first device
 *  task_type2 - second device
 *  TODO reward amount? mostly just for water? -- in ms of open solenoid
 */

/*pins used:
 * 5 - motor is on LED
 * 6 - device 1 LED
 * 7 - device 2 LED
 * 8 - indicator for cycle time
 * 9 - solenoid (if using) TODO - make all motor stuff in "if" cases, add solenoid
 */

void setup() {
  //Initialize serial, communications, and real time clock
  Serial.begin(9600);
  Wire.begin();
  RTC.begin();

  if (! RTC.isrunning() ) { //check if the clock is running
    Serial.println("RTC is not running.");
  }

  //initialize the motor
  AFMS.begin(); //default frequency 1.6 kHz
  myMotor->setSpeed(10); //10 rpm


  delay(500);
}

void loop() {

  delay(1000); 
  myMotor->step(102, FORWARD, DOUBLE);

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
    giving_reward = 0; //done giving the treat
  }
}

//TODO make and test Function that turns on solenoid to reward monkey
void giveWater () {
  //turn on solenoid
  /* TODO remove this section if the below section works
  digitalWrite(solenoid_pin, HIGH); 
  delay(5000); //TODO update this temporary solution (this just turns on the solenoid for 5 seconds but I'll need to write a different function to keep
  //track of how long it's been open and how long it needs to be)
  digitalWrite(solenoid_pin, LOW); 
*/
  if (sol_time > reward_amount){ //if the solenoid has been active for more time than the amount dictated, turn it off
    digitalWrite(solenoid_pin, LOW); 
    digitalWrite(5, LOW); //turn off LED indicating whether we're giving a reward
    giving_reward = 0; //done giving the water
    sol_time == 0;
  }
  else if (sol_time == 0){ //if this is the first iteration of the loop for a specific instance giving a reward
    digitalWrite(solenoid_pin, HIGH); 
    digitalWrite(5, HIGH); //turn on LED indicating that we're giving a reward
  }
  //while waiting for sol_time to reach reward_amount, nothing happens (LED and solenoid stay on by themselves)
}

// Function that blinks LEDs
void blinkLED(int ledPin, int &ledState, int &lastBlink) { //use references so we can edit each sensor's info
  //check the amount of time passed since the LED last blinked
  //if it has been 200 ms, check the current state of the pin (0=LOW, 1=HIGH)
  if (lastBlink >= 200) {
    if (ledState == 0) {
      digitalWrite(ledPin, HIGH);
      ledState = 1; //keep track of state changes
      lastBlink = 0; //reset time for blinks to zero
    }
    else if (ledState == 1) {
      digitalWrite(ledPin, LOW);
      ledState = 0; //remember current state
      lastBlink = 0; //reset time for blinks to zero
    }
  }
}


// Function that tests if the monkey can proceed
// (has it been more than [betweenTreats] milliseconds since the last treat)
bool canAttempt() {
  if (lastTreat >= betweenTreats) { //if time since last treat was dispensed is greater than the waiting period
    lastTreat = betweenTreats; //reset this value so it doesn't get obscenely high
    if (giving_reward == 0) {
      return true; //monkey can attempt task again
    }
    else {
      return false; //monkey can't attempt task because it is getting a treat
    }
  }
  else {
    return false; //monkey can't attempt task yet
  }
}






