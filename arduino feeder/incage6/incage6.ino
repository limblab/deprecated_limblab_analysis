#include <SPI.h>
#include <Wire.h>
#include <SD.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"
#include "RTClib.h"


////////////////////////////// Hi Scott

// Global variables

RTC_DS1307           RTC;                    // the Real Time Clock

Adafruit_MotorShield AFMS = Adafruit_MotorShield();          // The motor shield object with the default I2C address
Adafruit_StepperMotor   *myMotor = AFMS.getStepper(200, 2);  // Connect a stepper motor with 120 steps per revolution (3 degree) to motor port #2 (M3 and M4)

const int            chipSelect       = 4;  //CS for the SD card (4 for ethernet shield)


unsigned long        ms_prev;               // TODO: ERASE
unsigned long        ms_incr;               // TODO: ERASE


int                  s_last_treat     = -1;
int                  elapsed_t        = 0;   // last second in which the monkey got a treat. = 100 at start up to identify first cycle
int                  mot_ctr          = 0;   // current motor step
int                  giving_got_treat = 0;   // 0 = No (or he can get a new treat), 1 = yes

int                  go_LEDs          = 1;   // status of the "you can do the task" LEDs (0 = off, 1 = on)

  
// To store the settings:

int                  dev_set         = 1;            // device configuration, i .e. the sensors connected, which determines how the software decides if the monkey succeeded
int                  rand_threshold  = 100;          // % of times the monkey will get a rewawrd
int                  th_sensor1_1    = 100;          // threshold that indicates that the monkey has successfully activated sensor 1 of device 1
int                  th_sensor1_2    = 100;          // threshold that indicates that the monkey has successfully activated sensor 2 of device 1
int                  th_sensor2_1    = 100;          // threshold that indicates that the monkey has successfully activated sensor 1 of device 2
int                  th_sensor2_2    = 100;          // threshold that indicates that the monkey has successfully activated sensor 2 of device 2
int                  time_btw_treats = 5;


// To generate the file name

int                   file_name_ctr    = 0;          // counter to generate the filename
int                   sample_in_file_ctr   = 1;      // counts the number of rows in teh current log file


// File variable

File                  myFile;





//////////////////////////////

// INTERRUPT 0 FUNCTION - DUMP SD CARD

void dumpSwitch (){ 

  // Turn the motor LED ON
  digitalWrite( 5, HIGH );   
}





//////////////////////////////

// SETUP function

void setup()
{
 // Open serial communications and wait for port to open:
 
  Serial.begin(9600);
  Wire.begin();
  RTC.begin();
  

  // to calculate the ms:

  ms_prev            = millis();


  // CHECK IF THE RT CLOCK IS WORKING

  if (! RTC.isrunning()) {
    Serial.println("RTC is NOT running!");
    // following line sets the RTC to the date & time this sketch was compiled
    // RTC.adjust(DateTime(__DATE__, __TIME__));
  }
  
  
  
  
    // INITIALIZE SD CARD:

  Serial.println();
  Serial.print("Initializing SD card...");
  // make sure that the default chip select pin is set to output, even if you don't use it:
  pinMode(10, OUTPUT);

  
  
  // see if the card is present and can be initialized:

  if ( !SD.begin( chipSelect ) ){

    Serial.println("ERROR: Card failed or not present");
    // don't do anything else
    return;  
  }
  Serial.println("card initialized.");


  delay(500);
  


  myFile  = SD.open( "config.csv", FILE_READ );

  if ( myFile == 0 ){

    // print error if config.csv is not present:
    Serial.println("ERROR: Could not find `config.csv`");
    // don't do anything else
    return;
  }


  Serial.println();
  Serial.println("Reading config from SD card...");


  // read the parameters from the SD card and store them in the String config_string

  String     config_string    = "";
  char       current_char;

  while ( myFile.available() ){

    current_char     = myFile.read();

    config_string    += current_char;
  }


  // TODO: erase
  Serial.print("the string is...");
  Serial.println( config_string );
  Serial.println("and the stored settings are...");

  // separate the comma separated string into the variables we want to use

  int          config_par_ctr = 0;              // to know which variable we're reading
  int          comma_pos;                       // position of the first comma in the string ()
  String       aux_string = "";


  do {

    comma_pos   = config_string.indexOf(',');    // Find the first ',' in the string


    if ( comma_pos != - 1 ){

      aux_string  = config_string.substring( 0, comma_pos );   // create a string to store the first chunk of text that corresponds to a variable


      if (config_par_ctr == 0 ){   // store the chunk, converted to int, in its corresponding variable

        int dev_set     = aux_string.toInt();
        Serial.println( dev_set );
      }
      else if (config_par_ctr == 1) {

        int th_sensor1_1 = aux_string.toInt();
        Serial.println( th_sensor1_1 );        
      }
      else if (config_par_ctr == 2) {

        int th_sensor1_2 = aux_string.toInt();
        Serial.println( th_sensor1_2 );        
      }
      else if (config_par_ctr == 3) {

        int th_sensor2_1 = aux_string.toInt();
        Serial.println( th_sensor2_1 );                
      }
      else if (config_par_ctr == 4) {

        int th_sensor2_2 = aux_string.toInt();
        Serial.println( th_sensor2_2 );                        
      }


      config_string = config_string.substring( comma_pos +1, config_string.length() );   // delete the part of the string that we've just read

      config_par_ctr ++;
    }
    else{   // this is the last piece of text

      int rand_threshold = config_string.toInt();

//      Serial.print("% times monkey gets treat: ");
      Serial.println( rand_threshold, DEC ); 

    }
  } 
  while (comma_pos >= 0);


  myFile.close();
  
  

  delay(1000); 
  
  
    // print the parameters in the terminal

  //  Serial.print("dev config: ");
  //  Serial.println(dev_set);
  //  Serial.print("threshold sensor 1 Dev 1: ");
  //  Serial.println(th_sensor1_1, DEC);
  //  Serial.print("threshold sensor 2 Dev 1: ");
  //  Serial.println(th_sensor1_2, DEC);
  //  Serial.print("threshold sensor 1 Dev 2: ");
  //  Serial.println(th_sensor2_1, DEC);
  //  Serial.print("threshold sensor 2 Dev 2: ");
  //  Serial.println(th_sensor2_2, DEC);
  //  Serial.print("% successes gets treat: ");
  //  Serial.println( rand_threshold );
  //
  Serial.println();
//  Serial.println("==");
//  Serial.println();


  delay(1000);
  



  // Store parameters into a file (paramXXX.csv)
  // TODO




  // Define interrupt 0: if we activate a switch it dumps the SD card through the ethernet 

  attachInterrupt( 0, dumpSwitch, FALLING );
//


  
  // Initialize the motor

  AFMS.begin();              // create with the default frequency 1.6KHz
  //AFMS.begin(1000);  // OR with a different frequency, say 1KHz

  myMotor->setSpeed(10);    // 10 rpm    



  Serial.println("Initialized motor");
//  Serial.println("==");
  Serial.println();

  delay(500);
 
}




//////////////////////////////

// LOOP function

void loop()
{


  // some variable definitions

  int success;


  // Read sensors:

  int sensor1_1        = analogRead( 0 );     // Read device 1 sensor 1 (in pin 0)
  int sensor1_2        = analogRead( 1 );     // Read device 1 sensor 2 (in pin 1)

  int sensor2_1        = analogRead( 2 );     // Read device 2 sensor 1 (in pin 2)
  int sensor2_2        = analogRead( 3 );     // Read device 2 sensor 2 (in pin 3)



  // Read the clock (year, month, day, hour, minute, seconds):

  DateTime now         = RTC.now();

  // Read miliseconds and calculate difference between loops:

  unsigned long ms_now     = millis();




   // Decide if the monkey gets a treat:

  success         = decideIfTreat( sensor1_1, sensor1_2, sensor2_1, sensor2_2 ); 



  //    Serial.print(now.year(), DEC);
  //    Serial.print('/');
  //    Serial.print(now.month(), DEC);
  //    Serial.print('/');
  //    Serial.print(now.day(), DEC);
  //    Serial.print(' ');
  //    Serial.print(now.hour(), DEC);
  //    Serial.print(':');
  //    Serial.print(now.minute(), DEC);
  //    Serial.print(':');
  //    Serial.print(now.second(), DEC);
  //    Serial.println();



  // Calculate elapsed time between loop iterations:

  ms_incr       = ms_now - ms_prev;
  ms_prev       = ms_now;



  // Create a string to log the data in the SD card:

  String         dataString = "";

  dataString     += now.year();
  dataString     += ",";
  dataString     += now.month();
  dataString     += ",";
  dataString     += now.day();
  dataString     += ",";
  dataString     += now.hour();
  dataString     += ",";
  dataString     += now.minute();
  dataString     += ",";
  dataString     += now.second();
  dataString     += ",";
  dataString     += ms_now % 1000;
  dataString     += ",";
  dataString     += sensor1_1;
  dataString     += ",";
  dataString     += sensor1_2;
  dataString     += ",";
  dataString     += sensor2_1;
  dataString     += ",";
  dataString     += sensor2_2;
  dataString     += ",";
  dataString     += success;


  // open the file we want to write to:

  char         dataFileName[]   = "data000.csv";   // this is the basic filename, we increase the last three digits


  // Generate file name

  if ( file_name_ctr < 10 ){

    dataFileName[6]  = file_name_ctr + '0';
  }
  else if ( file_name_ctr < 100 ){

    dataFileName[5]  = (char) file_name_ctr / 10 + '0';
    dataFileName[6]  = (char) file_name_ctr % 10 + '0';
  }
  else if ( file_name_ctr < 1000 ){

    dataFileName[4]  = (char) file_name_ctr / 100 + '0';
    dataFileName[5]  = (char) (file_name_ctr - 100 * file_name_ctr / 100 ) / 10 + '0';
    dataFileName[6]  = (char) file_name_ctr % 10 + '0';
  }

  
  
  // Create the variable used for storing the data:

  myFile      = SD.open( dataFileName, FILE_WRITE);




  // if the file is available then write! :
  if (myFile){

    myFile.println(dataString);
    myFile.close();               // It is necessary to close the file before opening it again // TODO: CHECK FLUSH()

    // Print to the serial port too:
    Serial.println(dataString);

  }
  else{

    Serial.println("ERROR: couldn't write SD card");     
  }




  // check if we have got to the datafile limit (1 day = 28800 samples):

  sample_in_file_ctr ++;

  //  if ( sample_in_file_ctr == 28800 ){
  if ( sample_in_file_ctr == 400 ){

    file_name_ctr ++; 
    sample_in_file_ctr   = 0;
  }




  // Print sensor readings:

  Serial.print("Dev 1 Sensor 1: ");
  Serial.println(sensor1_1, DEC);
  Serial.print("Dev 2 Sensor 1: ");
  Serial.println(sensor2_1, DEC);


  // Print if the monkey succeeded:

  Serial.print("Success?? ");
  Serial.println(success, DEC);





 // calculate the elapsed time since the last treat:

  if ( s_last_treat != -1 ){                               // if it's not the first time, calculate elapsed time from the last treat

    elapsed_t   = now.second() - s_last_treat;

    if ( elapsed_t < 0 ){       // to compensate for negative differences

      elapsed_t      += 60;
    }
  } 


//  Serial.print("time since last treat (s):");
//  Serial.println(elapsed_t, DEC);
  
  
  
  // Decide if the monkey gets a treat:

  // 1. Check if the elapsed time from the last treat is greater than it should, or if he has not performed the task in this session

  if ( ( elapsed_t > time_btw_treats ) || ( s_last_treat == -1 ) ){


    // Turn the "you can do the task" LEDS on:

    go_LEDs   = 1;     


    // 2. Are we giving the monkey a treat?

    if ( giving_got_treat == 1 ){           // Yes, we're giving the monkey a treat

      // continue turning the motor:

      turnMotor();


      // has the motor finished turning?

      if ( mot_ctr == 0 ){


        s_last_treat     = now.second();   // Store the second in which the monkey received the treat
        giving_got_treat = 0;              // the monkey can get a new treat


        go_LEDs   = 0;


//        Serial.print("GOT TREAT AT T=");   // TODO: DELETE
//        Serial.println(s_last_treat);

        //              delay(1000);                        // TODO: DELETE

      }
      else{

//        Serial.println("GIVING TREAT");     // TODO: DELETE              
      }

//      //            delay(1000);                        // TODO: DELETE
    }
    else if (giving_got_treat == 0) {       // No, we are not givint the monkey a treat


      // 3. Has the monkey just succeeded in doing the task?

      if ( success == 1 ){


        // 4. Will he get a treat this time? (compare with randomization thershold)

        if ( random(100) > (100 - rand_threshold) ){

          giving_got_treat     = 1;   // the monkey is getting a treat

          turnMotor();
        }
        else{

          s_last_treat     = now.second();   // Store the second in which the monkey received the treat
          giving_got_treat = 0;              // the monkey can get a new treat

//          Serial.print("GOT TREAT AT T=");   // TODO: DELETE
//          Serial.println(s_last_treat);
        } 
      }

    }          



    }
  else{


    go_LEDs   = 0;

    // Wait X ms to complete a ~50 ms cycle:

    delay(10);
  }


  
// See if we have to turn the "you can do the task" LEDs on or off

  if ( go_LEDs == 0 ){

    digitalWrite( 7, LOW );
    digitalWrite( 6, LOW ); 
  }
  else{

    digitalWrite( 7, HIGH );
    digitalWrite( 6, HIGH ); 
  }    



//  Serial.print("Cycle time (ms): ");
  Serial.println(ms_incr, DEC);
//  Serial.println();
  
}






//////////////////////////////

// Function to decide if the monkey gets a treat

int decideIfTreat(int input1_1, int input1_2, int input2_1, int input2_2 ){



  switch(dev_set){

  case 1:              // For the first combination of sensors

    if ( ( (input1_1 > th_sensor1_1) && (input1_2 > th_sensor1_2) ) && ( (input2_1 > th_sensor2_1) && (input2_2 > th_sensor2_2) ) ){
      return 1;
    }
    else{
      return 0;
    }

    break;

  case 2:              // For the second combination of sensors

    if ((input1_1 < th_sensor1_1) && (input2_1 < th_sensor1_2)){
      return 1;
    }
    else{
      return 0;
    }

    break;
  }

}





//////////////////////////////

// Function that turns the motor

void turnMotor (){


  // Turn on the receiving treat LED - TODO: delete
  digitalWrite( 2, HIGH ); 


  // Turn the motor  
  if ( mot_ctr < 100 ){

    myMotor->step(20, FORWARD, DOUBLE);
    mot_ctr  = mot_ctr + 20;

    Serial.print("current motor step: ");     // TODO: DELETE
    Serial.println(mot_ctr, DEC);

    // Turn the LED that indicates that the motor is turning on:
    digitalWrite( 5, HIGH ); 

  }
  else if ( mot_ctr == 100 ) {

    mot_ctr           = 0;            

    // Turn the LED that indicates that the motor is turning off:
    digitalWrite( 5, LOW ); 

  }

}



