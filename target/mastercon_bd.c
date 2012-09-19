/* mastercon_bd.c
 
 * Master Control block for behavior: ball-drop
 */

#define S_FUNCTION_NAME mastercon_bd
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include "simstruc.h"

#define TASK_BD 1
#include "words.h"
#include "random_macros.h"

/* 
 * Current Databurst version: 0
 *
 * Note that all databursts are encoded half a byte at a time as a word who's 
 * high order bits are all 1 and who's low order bits represent the half byte to
 * be transmitted.  Low order bits are transmitted first.  Thus to transmit the
 * two bytes 0xCF 0x07, one would send 0xFF 0xFC 0xF7 0xF0.
 *
 * Databurst version descriptions
 * ==============================
 *
 * Version 0 (0x00)
 * ----------------

 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case one)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 */

typedef unsigned char byte;
#define DATABURST_VERSION (0x00) 


/*
 * Tunable parameters
 */
 
static real_T touch_pad_hold_l = .5;
#define param_touch_pad_hold_l mxGetScalar(ssGetSFcnParam(S,0))
static real_T touch_pad_hold_h = .5;
#define param_touch_pad_hold_h mxGetScalar(ssGetSFcnParam(S,1))

static real_T touch_pad_delay_l = .5;
#define param_touch_pad_delay_l mxGetScalar(ssGetSFcnParam(S,2))
static real_T touch_pad_delay_h = .5;
#define param_touch_pad_delay_h mxGetScalar(ssGetSFcnParam(S,3))

static real_T pickup_time = .5;          /* Time to pickup the ball*/
#define param_pickup_time mxGetScalar(ssGetSFcnParam(S,4))

static real_T drop_time = .5;          /* Time to drop the ball*/
#define param_drop_time mxGetScalar(ssGetSFcnParam(S,5))

#define param_intertrial mxGetScalar(ssGetSFcnParam(S,6))
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T failure_timeout = 1.0;    /* delay after failure */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */
                                         
static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,7))

static real_T catch_block_max = 0.0;
#define param_catch_block_max mxGetScalar(ssGetSFcnParam(S,8))

#define set_catch_trial(x) ssSetIWorkValue(S, 5, (x))
#define get_catch_trial() ssGetIWorkValue(S, 5)

static empty_rack_alarm_timeout = 5.0;

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_TOUCH_PAD_ON 1
#define STATE_TOUCH_PAD_HOLD 2
#define STATE_DELAY 3
#define STATE_PICKUP 4
#define STATE_DROP 5
#define STATE_EMPTY_RACK 6

#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3
#define TONE_EMPTY_RACK 4


static void updateVersion(SimStruct *S)
{
    /* set variable to file version for display on screen */
    /* DO NOT change this version string by hand.  CVS will update it upon commit */
    char version_str[256] = "$Revision: 1.26 $";
    char* version;
    
    version_str[strlen(version_str)-1] = 0; // set last "$" to zero
    version = version_str + 11 * sizeof(char); // Skip over "$Revision: "
    ssSetRWorkValue(S, 5, atof(version));
}

static void mdlCheckParameters(SimStruct *S)
{
  touch_pad_hold_l = param_touch_pad_hold_l;
  touch_pad_hold_h = param_touch_pad_hold_h;

  touch_pad_delay_l = param_touch_pad_delay_l;
  touch_pad_delay_h = param_touch_pad_delay_h;

  pickup_time = param_pickup_time;
  drop_time = param_drop_time;

  abort_timeout      = param_intertrial;
  failure_timeout    = param_intertrial;
  incomplete_timeout = param_intertrial;
  reward_timeout     = param_intertrial;    

  catch_block_max = param_catch_block_max;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 9); 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
    for (i=0; i<ssGetNumSFcnParams(S); i++)
        ssSetSFcnParamTunable(S,i, 1);
    mdlCheckParameters(S);
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);
    
    /*
     * Block has 2 input ports
     *      input port 0: (touch pad) of width 1 (true if touchpad pressed)
     *      input port 1: (ball sensor) of width 2 (1: pickup_sensor, true if ball is picked up;  2: drop sensor, true if ball is dropped)
     */
    if (!ssSetNumInputPorts(S, 2)) return;
    ssSetInputPortWidth(S, 0, 1); /* touch pad */
    ssSetInputPortWidth(S, 1, 2); /* ball sensors [0]: pickup sensor  [1]:drop sensor*/
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    
    /* 
     * Block has 9 output ports (reward, word, touch pad LED, gadget LED, gadget select, status, tone, version) of widths:
     * 0: reward:         1
     * 1: word:           1
     * 2: touch pad LED:  1
     * 3: gadget LED:     1
     * 4: gadget select:  1 ( will always be set to gadget #3 (the last of [0-3]) )
     * 5: status:         5 ( 1: state, 2: rewards, 3: aborts 4: failures, 5: incomplete )
     * 6: tone:           2 ( 1: counter incemented for each new tone, 2: tone ID )
     * 7: target: 10 ( target 1, 2: 
     *                  type, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)     
     * 8: version : 4
     */
    if (!ssSetNumOutputPorts(S, 9)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 1);
    ssSetOutputPortWidth(S, 3, 1);
    ssSetOutputPortWidth(S, 4, 1);
    ssSetOutputPortWidth(S, 5, 5);
    ssSetOutputPortWidth(S, 6, 2);
    ssSetOutputPortWidth(S, 7, 10);
    ssSetOutputPortWidth(S, 8, 4);
        
    ssSetNumSampleTimes(S, 1);
    
    /* work buffers */
    ssSetNumRWork(S, 6);   /* 
                            0: time of last timer reset
                            1: tone counter (incremented each time a tone is played)
                            2: tone id
                            3: current touch pad hold time
                            4: current delay hold time
                            5: mastercon version
                            */

    ssSetNumPWork(S, 0);    /*
                            */
    
    ssSetNumIWork(S, 9);    /*
                            0: state_transition (true if state changed), 
                            1: rewards
                            2: aborts
                            3: failures
                            4: incomplete
                            5: catch_trial_flag
                            6: catch_block_counter
                            7: catch_index
                            8: databurst counter
                            */
    
    ssSetNumPWork(S, 1); /*    0: Databurst array pointer  */
    
    /* we have no zero crossing detection or modes */
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0;
    byte *databurst;

    /* initialize state to zero */
    x0 = ssGetRealDiscStates(S);
    *x0 = 0.0;
    
    /* notify that we just entered this state */
    ssSetIWorkValue(S, 0, 1);

    /* set the tone counter to zero */
    ssSetRWorkValue(S, 1, 0.0);
    ssSetRWorkValue(S, 2, 0.0);
        
    /* set trial counters to zero */
    ssSetIWorkValue(S, 1, 0);
    ssSetIWorkValue(S, 2, 0);
    ssSetIWorkValue(S, 3, 0);
    ssSetIWorkValue(S, 4, 0);
    
    /* set catch trial flag & block counter to zero */
    ssSetIWorkValue(S,5,0); //catch_trial_flag
    ssSetIWorkValue(S,6,100); //catch_block_counter
    ssSetIWorkValue(S,7,0); //catch_index
    
    /* set reset counter to zero */
    master_reset = 0.0;

    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 8, 0);
    
    updateVersion(S);
}

/* macro for setting state changed */
#define state_changed() (ssSetIWorkValue(S, 0, 1))

/* macros for resetting timer */
#define reset_timer() (ssSetRWorkValue(S, 0, (real_T)ssGetT(S)))


#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
    /****************
     * Declarations *
     ****************/
    
    /* stupidly declare all variables at the begining of the function */
    InputRealPtrsType uPtrs;
    real_T touch_pad; // should be 0.0 if touch pad is not pressed, 1.0 if it is.
    real_T elapsed_timer_time;
    real_T touch_pad_hold_timeout;
    real_T delay_timeout;
    real_T pickup_sensor;
    real_T drop_sensor;

    int catch_block_counter;
    int catch_index;

    int databurst_counter;
    byte *databurst;
        
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int new_state = state;
    ssSetIWorkValue(S, 0, 0); /* By default, clear the state-changed flag */
    
    /* touch pad state */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    touch_pad = *uPtrs[0];
    
    /* ball sensors state */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 1);
    pickup_sensor = *uPtrs[0];
    drop_sensor = *uPtrs[1];    
    
    /* read current timeouts */
    touch_pad_hold_timeout = ssGetRWorkValue(S, 3);
    delay_timeout = ssGetRWorkValue(S, 4);
    
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    
    /* catch trial block counter and index*/
    catch_block_counter = ssGetIWorkValue(S,6);
    catch_index = ssGetIWorkValue(S,7);
    
    databurst = ssGetPWorkValue(S,0);
    databurst_counter = ssGetIWorkValue(S, 8);

    /*********************************
     * See if we have issued a reset *
     *********************************/
    if (param_master_reset > master_reset) {
        master_reset = param_master_reset;
        ssSetIWorkValue(S, 1, 0); //rewards
        ssSetIWorkValue(S, 2, 0); //abort
        ssSetIWorkValue(S, 3, 0); //failures
        ssSetIWorkValue(S, 4, 0); //incompletes
        state_r[0] = STATE_PRETRIAL;
        return;
    }
    
    /************************
     * Calculate next state *
     ************************/
    
    /* execute one step of state machine */
    switch (state) {
        case STATE_PRETRIAL:
            /* pretrial initilization */
            /* 
             * We should only be in this state for one cycle.
             * Initialize the trial and then advance to STATE_TOUCH_PAD_ON 
             */
            
            /* Update parameters */

            touch_pad_hold_l = param_touch_pad_hold_l;
            touch_pad_hold_h = param_touch_pad_hold_h;
            
            touch_pad_delay_l = param_touch_pad_delay_l;
            touch_pad_delay_h = param_touch_pad_delay_h;
            
            pickup_time = param_pickup_time;
            drop_time = param_drop_time;
            
            abort_timeout      = param_intertrial;
            failure_timeout    = param_intertrial;
            incomplete_timeout = param_intertrial;
            reward_timeout     = param_intertrial;    

            
            /* intialize timers*/
            if (touch_pad_hold_l == touch_pad_hold_h) { 
                ssSetRWorkValue(S, 3, touch_pad_hold_l);
            } else {
                ssSetRWorkValue(S, 3, touch_pad_hold_l + UNI*(touch_pad_hold_h-touch_pad_hold_l));
            }
            
            if (touch_pad_delay_l == touch_pad_delay_h) { 
                ssSetRWorkValue(S, 4, touch_pad_delay_l);
            } else {
                ssSetRWorkValue(S, 4, touch_pad_delay_l + UNI*(touch_pad_delay_h-touch_pad_delay_l));
            }
            
            /* Catch trials: one catch per block of catch_block_max trials.
                catch_block_max is set in graphics, using the drop-down menu
                to choose between 0% and 33%, with steps of 1/N
                So catch_block_max is el of: [0(No catch),3,4,5,7,10,20]*/

            // 1 - increment trial counter
            catch_block_counter +=1;
            ssSetIWorkValue(S,6,catch_block_counter);

            // 2- Reset the catch block if needed
            if (catch_block_max != param_catch_block_max || catch_block_counter >= catch_block_max) {
                catch_block_max =  param_catch_block_max;
                catch_block_counter = 0;
                catch_index = (int)(UNI*(catch_block_max));
                ssSetIWorkValue(S,7,catch_index);
                ssSetIWorkValue(S,6,catch_block_counter);
            }

            // 3 - is this the catch trial?
            if (catch_block_counter == catch_index && catch_block_max!=0) {
                set_catch_trial(1);
            } else {
                set_catch_trial(0);
            }
            
            /* Setup the databurst */
            databurst[0] = 6+1+4*sizeof(float);
            databurst[1] = DATABURST_VERSION;
            databurst[2] = BEHAVIOR_VERSION_MAJOR;
            databurst[3] = BEHAVIOR_VERSION_MINOR;
            databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
            databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            
            ssSetIWorkValue(S, 8, 0); /* reset the databurst_counter */

            new_state = STATE_DATA_BLOCK;
            state_changed();
            /* End of Pretrial State */
            break;
        case STATE_DATA_BLOCK:
            if (databurst_counter > 2*(databurst[0]-1)) { 
                new_state = STATE_TOUCH_PAD_ON;
                state_changed();
            }
            ssSetIWorkValue(S, 8, databurst_counter+1);
            break;
        case STATE_TOUCH_PAD_ON:
            if (touch_pad) {
                new_state = STATE_TOUCH_PAD_HOLD;
                state_changed();
                reset_timer();
            }
            break;
        case STATE_TOUCH_PAD_HOLD:
            if (pickup_sensor) {
                new_state = STATE_EMPTY_RACK;
                reset_timer();
                state_changed();
            } else if (elapsed_timer_time > touch_pad_hold_timeout) {
                new_state = STATE_DELAY;
                state_changed();
                reset_timer();
            } else if (!touch_pad) {
                new_state = STATE_TOUCH_PAD_ON;
                state_changed();
                reset_timer();
            }
            break;
        case STATE_DELAY:
            if (elapsed_timer_time > delay_timeout) {
                new_state = STATE_PICKUP;
                state_changed();
                reset_timer();
            } else if (!touch_pad) {
                new_state = STATE_ABORT;
                state_changed();
                reset_timer();                
            }
            break;
        case STATE_PICKUP:
            if (elapsed_timer_time > pickup_time) {
                new_state = STATE_FAIL;
                state_changed();
                reset_timer();
            } else if (pickup_sensor) {
                new_state = STATE_DROP;
                reset_timer();
                state_changed();
            }
            break;
        case STATE_DROP:
            if (elapsed_timer_time > drop_time) {
                new_state = STATE_INCOMPLETE;
                state_changed();
                reset_timer();
            } else if (drop_sensor) {
                new_state = STATE_REWARD;
                state_changed();
                reset_timer();
            }
            break;
        case STATE_ABORT:
            /* abort */
            if (elapsed_timer_time > abort_timeout) {
                new_state = STATE_PRETRIAL;
                //don't count for a trial in catch_block
                ssSetIWorkValue(S,6,catch_block_counter-1);
                state_changed();
            }
            break;
        case STATE_FAIL:
            /* failure - The Monkey did not even picked up the ball*/
            if (elapsed_timer_time > failure_timeout) {
                new_state = STATE_PRETRIAL;
                //don't count for a trial in catch_block
                ssSetIWorkValue(S,6,catch_block_counter-1);                
                state_changed();
            }
            break;
        case STATE_INCOMPLETE:
            /* incomplete - the monkey picked up the ball but did not drop it in the tube*/
            if (elapsed_timer_time > incomplete_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
            }
            break;
        case STATE_EMPTY_RACK:
            /* empty_rack - the monkey has his hand on touch pad but no ball detected in device */
            if (elapsed_timer_time > empty_rack_alarm_timeout) {
                new_state = STATE_PRETRIAL;
                //don't count for a trial in catch_block
                ssSetIWorkValue(S,6,catch_block_counter-1);             
                state_changed();
                reset_timer();
            }
            break;  
        case STATE_REWARD:
            /* reward */
            if (elapsed_timer_time > reward_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
            }
            break;
        default:
            new_state = STATE_PRETRIAL;
            state_changed();
    }
    
    /***********
     * Cleanup *
     ***********/
    
    /* write back new state */
    state_r[0] = new_state;
    
    KISS; /* burn a place in the prng */
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /********************
     *  Initialization
     ********************/
    int i;
    InputRealPtrsType uPtrs;
    real_T touch_pad;
    real_T pickup_sensor, drop_sensor;
    real_T tone_cnt, tone_id;
    int new_state;
    int gadget_id;
    
    /* holders for outputs */
    real_T reward, word, touch_pad_led, gadget_led, gadget_select;
    real_T tgt[4];
    real_T target[10];
    real_T status[5];
    real_T tone[2];
    real_T version[4];
    
    /* pointers to output buffers */
    real_T *reward_p;
    real_T *word_p;
    real_T *touch_pad_led_p;
    real_T *gadget_led_p;
    real_T *gadget_select_p;
    real_T *target_p;
    real_T *status_p;
    real_T *tone_p;
    real_T *version_p;
    
    int databurst_counter;
    byte *databurst;

    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    new_state = ssGetIWorkValue(S, 0);
    
    /* Current gadget index (always set to 3 for BD device) */
    gadget_id = 3;

    /* touch pad state */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    touch_pad = *uPtrs[0];

    /* ball sensors state */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 1);
    pickup_sensor = *uPtrs[0];
    drop_sensor = *uPtrs[1];   
            
    /* tone counters */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id  = ssGetRWorkValue(S, 2);
    
    /* target */
    tgt[0]= -5.0;
    tgt[1]= 5.0;
    tgt[2]= 5.0;
    tgt[3]= -5.0;
    
    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 8);
    databurst = (byte *)ssGetPWorkValue(S, 0);

    /********************
     * Calculate outputs
     ********************/
    
    /* reward (0) */
    if (new_state && state == STATE_REWARD) {
        reward = 1.0;
    } else {
        reward = 0.0;
    }
    
    /* word (1) */
    if (state == STATE_DATA_BLOCK) {
        if (databurst_counter % 2 == 0) {
            word = databurst[databurst_counter / 2] | 0xF0; // low order bits
        } else {
            word = databurst[databurst_counter / 2] >> 4 | 0xF0; // high order bits
        }
    } else if (new_state) {
        switch (state) {
            case STATE_PRETRIAL:
                word = WORD_START_TRIAL;
                break;
            case STATE_TOUCH_PAD_HOLD:
                word = WORD_HAND_ON_TOUCH_PAD;
                break;
//             case STATE_DELAY:
//                 word = WORD_GADGET_ON(gadget_id);
//                 break;
            case STATE_PICKUP:
                if (get_catch_trial()) {
                    word = WORD_CATCH;
                } else {
                    word = WORD_GO_CUE;
                }                
                break;
            case STATE_DROP:
                word = WORD_PICKUP; // The monkey just picked up the ball, so we are in state STATE_DROP
                break;
            case STATE_REWARD:
                word = WORD_REWARD;
                break;
            case STATE_ABORT:
                word = WORD_ABORT;
                break;
            case STATE_FAIL:
                word = WORD_FAIL;
                break;
            case STATE_INCOMPLETE:
                word = WORD_INCOMPLETE;
                break;
            case STATE_EMPTY_RACK:
                word = WORD_EMPTY_RACK_END_CODE;
                break;
            default:
                word = 0.0;
        }
    } else {
        word = 0.0;
    }
    
    /* touch_pad_led (2) */
    if (state == STATE_TOUCH_PAD_ON || state == STATE_TOUCH_PAD_HOLD || state == STATE_DELAY) {
        touch_pad_led = 1.0;
    } else {
        touch_pad_led = 0.0;
    }

    /* gadget_led (3) */
    if (state == STATE_DELAY || state == STATE_PICKUP || state == STATE_DROP) 
    {
        gadget_led = 1.0;
    } else {
        gadget_led = 0.0;
    }
    
    /* gadget_select (4) */
    gadget_select = gadget_id;
    
    /* status (5) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S, 1, ssGetIWorkValue(S, 1)+1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, 2, ssGetIWorkValue(S, 2)+1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, 3, ssGetIWorkValue(S, 3)+1);
    if (state == STATE_INCOMPLETE && new_state)
        ssSetIWorkValue(S, 4, ssGetIWorkValue(S, 4)+1);
      
    status[0] = state;
    status[1] = ssGetIWorkValue(S,1); // num rewards
    status[2] = ssGetIWorkValue(S,2); // num aborts
    status[3] = ssGetIWorkValue(S,3); // num failures
    status[4] = ssGetIWorkValue(S,4); // num incomplete
    
    /* tone (6) */
    if (new_state) {
        if (state == STATE_ABORT) {
            tone_cnt++;
            tone_id = TONE_ABORT;
        } else if (state == STATE_PICKUP || state == STATE_DROP) {
            tone_cnt++;
            tone_id = TONE_GO;
        } else if (state == STATE_REWARD) {
            tone_cnt++;
            tone_id = TONE_REWARD;
        } else if (state == STATE_EMPTY_RACK) {
            tone_cnt++;
            tone_id = TONE_EMPTY_RACK;
        }
    }
    
    /* targets (7) */
    for (i=0; i<4; i++) {
        target[i+1] = tgt[i];
    }
    if ( state == STATE_DELAY || 
         state == STATE_PICKUP || 
         state == STATE_DROP )
    {
        /* target red */
        target[0] = 1;
    } else if (state == STATE_REWARD) {
        /* target green */
        target[0] = 3;
    }  else {
        /* target off*/
        target [0] = 0;
    }
    /* we don't need a second target */
    for (i=5; i<10; i++) {
        target[i] = 0;
    }

     /* Version */
    version[0] = BEHAVIOR_VERSION_MAJOR;
    version[1] = BEHAVIOR_VERSION_MINOR;
    version[2] = BEHAVIOR_VERSION_MICRO;
    version[3] = BEHAVIOR_VERSION_BUILD;
    
    /**********************************
     * Write outputs back to SimStruct
     **********************************/
 
     reward_p = ssGetOutputPortRealSignal(S,0);
     reward_p[0] = reward;
     
     word_p = ssGetOutputPortRealSignal(S,1);
     word_p[0] = word;
     
     touch_pad_led_p = ssGetOutputPortRealSignal(S,2);
     touch_pad_led_p[0] = touch_pad_led;
     
     gadget_led_p = ssGetOutputPortRealSignal(S,3);
     gadget_led_p[0] = gadget_led;
     
     gadget_select_p = ssGetOutputPortRealSignal(S,4);
     gadget_select_p[0] = gadget_select;
     
     status_p = ssGetOutputPortRealSignal(S,5);
     for (i=0; i<5; i++) 
         status_p[i] = (real_T)status[i];
    
     tone_p = ssGetOutputPortRealSignal(S,6);
     tone_p[0] = tone_cnt;
     tone_p[1] = tone_id;
     ssSetRWorkValue(S, 1, tone_cnt);
     ssSetRWorkValue(S, 2, tone_id);
     
     target_p = ssGetOutputPortRealSignal(S,7);
     for (i=0; i<10; i++) 
         target_p[i] = target[i];
     
     version_p = ssGetOutputPortRealSignal(S,8);
     for (i=0; i<4; i++) {
         version_p[i] = version[i];
     }   
     
     UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif
