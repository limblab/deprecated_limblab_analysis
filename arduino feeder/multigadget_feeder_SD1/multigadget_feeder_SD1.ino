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
int actTime = 500; //amount of time the monkey has to do the task to get a treat

//Reward (motor and solenoid) control
int mot_ctr = 0; //current motor step
int giving_reward = 0; //whether we are currently giving a treat (0 = no, 1 = yes)
int solenoid_pin = 9; //TODO update this to whatever I want it to be forever and ever.

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
int reward_amount = 30; //only matters for water
int bimanual = 0; //0 for false (unimanual operation - only one device), 1 for true

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
 *  reward amount - only used for water rewards -- in ms of time the solenoid should be open
 *  unimanual vs bimanual control - 0 for false (unimanual operation - only one device), 1 for true
 *  amount of time between rewards, in ms
 *  
 *  MUST END IN A NEWLINE
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

  //set up pins for digital output
  pinMode(5, OUTPUT); //LED for motor-on signal
  pinMode(6, OUTPUT); //LED on device 1 (this turns on with a LOW signal)
  pinMode(7, OUTPUT); //LED on device 2 (this turns on with a LOW signal)
  pinMode(8, OUTPUT); //indicator for cycle time
  pinMode(solenoid_pin, OUTPUT); //controls solenoid (if using)
  
  //read initial conditions from SD card: allows us to switch out conditions without reuploading code
  if(SD.begin(4)){ //if the SD card is in there, do all of this - otherwise it will stay as default values
    //open file named s_file
    File s_file = SD.open("setup.txt");
  
    //if the file isn't over: read until \n
    char temp[4]; //create a string 4 characters long
    int i = 0; //var to iterate through string characters
    int setup_variables[12]; //create an array to store setup variables
    int j = 0; //var to iterate through setup var array
  
    while (s_file.available()) { //until the end of the file
      char next_char = s_file.read();
      if (next_char != '\n') { //read the next character and put each combination of characters into a string
        temp[i] = next_char;
        i++;
      }
      else { //because of this structure, the setup text file MUST END IN A NEWLINE CHARACTER (or it won't write the last variable)
        setup_variables[j] = atoi(temp); //convert each string to an integer and add it to the variable array
        j++;
        memset(&temp[0], 0, sizeof(temp)); //clear the string array TODO check that this actually makes it null, not int 0
        i = 0;
      }
    }
  
    s_file.close();
  
    //hard-coded: which variables are assigned to which location in the array
    th11 = setup_variables[0];
    th12 = setup_variables[1];
    th21 = setup_variables[2];
    th22 = setup_variables[3];
    rand_threshold = setup_variables[4];
    reward_type = setup_variables[5];
    task_type1 = setup_variables[6]; 
    task_type2 = setup_variables[7];
    reward_amount = setup_variables[8]; 
    bimanual = setup_variables[9]; 
    betweenTreats = setup_variables[10]; 
  }
  
  delay(500);
}

void loop() {
  
  //keep track of time per loop
  ms_incr = millis() - ms_prev; //get time since the last delay (not including delay)
  if (ms_incr < 50) { //delay the loop so that it consistently takes 50 ms (actually ends up 49-52 ms)
    delay(50 - ms_incr);
  }
  ms_incr = millis() - ms_prev; //get time since the last delay (including new delay)
  ms_prev = millis(); //reset time for the next loop
  //Serial.print("cycle time: ");
  //Serial.println(ms_incr);

  if(reward_type == 1){ 
    lastTreat += ms_incr; //add cycle time to time since last treat
  }
  else if(reward_type == 0){
    if(giving_reward){
      sol_time += ms_incr; //add cycle time to time that the solenoid has been active
      lastTreat += ms_incr; //add cycle time to time since last reward
    }
  }

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

  //Continue to give reward until we have reached the amount of water or food desired
  if (giving_reward) {
    if (reward_type == 1){ turnMotor(); }
    else if (reward_type == 0){ giveWater(); }
  }

  //check whether the treat dispenser is in a refractory period or currently dispensing treat
  //if not, read all sensors, blink the correct lights, and pay attention to amount of time the sensors have been activated correctly
  if (canAttempt()) {
    bool active_devices[2] = { false }; //initialize an array to track which tasks the monkey is doing correctly
    //defaults to false (0) for all values

    if (task_type1 == 0) {
      //task is FSR: read both sensors and decide if it's active
      //read the sensors
      int sensor1_1 = analogRead( 0 );     // Read device 1 sensor 1 (in pin 0)
      int sensor1_2 = analogRead( 1 );     // Read device 1 sensor 2 (in pin 1)
      
      //if both device 1 sensors are active, blink the LED for that device (monkey is doing the task correctly)
      if ( sensor1_1 > th11 && sensor1_2 > th12 ) {
        lastBlink1 += ms_incr; //add time to blinking variable
        blinkLED(6, goLED1, lastBlink1);
        active_devices[0] = true; //indicates that the first device is correctly activated
      }
      else if (goLED1 == 1) {
      //turn on the device's LED so the monkey knows it can start trying
      digitalWrite(6, LOW);
      goLED1 = 0;
      }
    
    }
  //TODO: implement else case for task type as rotary motion
    else if (task_type1 == 1) {
      //task is rotary: read only the first sensor
      //how is this going to work? compare to the last value? check if it has peaked? uhm. 
    }
  /* okay, here's what needs to be dealt with: 
   *  1. is the device active? (has it been turned past a certain point?)
   *  --will need to have some kind of mechanical spring back? or just let it keep turning continuously? 
   *  what values am I getting? how to hook this up to the existing pcb, if at all? 
   *  software reset - do that 
   */
   
    if (bimanual) { //if the task is two-handed, read the second sensor (otherwise, ignore it)
      if (task_type2 == 0) {
        //task for second device is FSR: read both sensors
        //read the sensors
        int sensor2_1 = analogRead( 2 );     // Read device 2 sensor 1 (in pin 2)
        int sensor2_2 = analogRead( 3 );     // Read device 2 sensor 2 (in pin 3)
        
        //if both device 2 sensors are active, blink the LED for that device
        if ( sensor2_1 > th21 && sensor2_2 > th22 ) {
          lastBlink2 += ms_incr;
          blinkLED(7, goLED2, lastBlink2);
          active_devices[1] = true; //indicates that the second device is being used correctly
        }
        else if (goLED2 == 1) {
          //turn on the device's LED so the monkey knows it can start
          digitalWrite(7, LOW);
          goLED2 = 0;
        }
      }
      //TODO implement else case for rotary motion device 2
   }
   
   else{
    active_devices[1] = true; //set the device you're not using to always true so that the monkey only
    //has to activate one device for a reward
   }
   
    //TODO test this (the if case has been changed to depend on the variable keeping track of activated devices)
    //TODO add the unimanual control option
    //if all devices are activated correctly, start counting
    if ( active_devices[0] == true && active_devices[1] == true ) {
      //count
      active += ms_incr;
      if ( active >= actTime ) { //has held the gripper for as long as required
        if ( random(101) < rand_threshold ) { //the monkey receives a treat [rand_threshold] percent of the time
          //give treat
          //set a variable equal to 1 (true) so we know to keep turning the motor on subsequent iterations of the loop
          giving_reward = 1;
          if (reward_type == 1){ turnMotor(); }     
          else if (reward_type == 0){ giveWater(); }
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
    digitalWrite(6, HIGH); //High and low are switched
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
    myMotor->step(5, FORWARD, DOUBLE);
    mot_ctr  += 5;
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
    digitalWrite(solenoid_pin, LOW); //turn off the solenoid
    digitalWrite(5, LOW); //turn off LED indicating whether we're giving a reward
    giving_reward = 0; //done giving the water
    sol_time = 0; //reset the solenoid time for the next round
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






