/* mastercon_wf.c
 
 * Master Control block for behavior: wrist-flexion
 */

#define S_FUNCTION_NAME mastercon_wf
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include "simstruc.h"

#define TASK_WF 1
#include "words.h"
#include "random_macros.h"

#define PI (3.141592654)

/* 
 * Current Databurst version: 4
 *
 * Note that all databursts are encoded half a byte at a time as a word whose 
 * high order bits are all 1 and whose low order bits represent the half byte to
 * be transmitted.  Low order bits are transmitted first.  Thus to transmit the
 * two bytes 0xCF 0x07, one would send 0xFF 0xFC 0xF7 0xF0.
 *
 * Databurst version descriptions
 * ==============================
 *
 * Version 1 (0x01)
 * ----------------
 * byte 0: uchar => number of bytes to be transmitted
 * byte 1: uchar => version number (in this case one)
 * bytes 2 to 2+ N*16: where N is the number of targets whose position are output.
 *      contains 16 bytes per target representing four single precision floating point
 *      numbers in little-endian format representing UL x, UL y, LR x and LR y coordinates
 *      of the UL and LR corners of the target.
 *
 *      The position of only the current target is output at the begining of each trial
 *      in normal behavior, but in multiple target mode, all the targets
 *      are included in the databurst
 *
 *      In MVC mode, the current value of the MVC target is provided in the databurst
 *
 * Version 2 (0x02) 
 * ----------------
 * byte 0: uchar => number of bytes to be transmitted
 * byte 1: uchar => version number (in this case two)
 * bytes 2 to 6: float => Cursor rotation value
 * bytes 6 to 6+ N*16: where N is the number of targets whose position are output.
 *      contains 16 bytes per target representing four single precision floating point
 *      numbers in little-endian format representing UL x, UL y, LR x and LR y coordinates
 *      of the UL and LR corners of the target.
 *
 *      The position of only the current target is output at the begining of each trial
 *      in normal behavior, but in multiple target mode, all the targets
 *      are included in the databurst
 *
 *      In MVC mode, the current value of the MVC target is provided in the databurst
 *
 *      NOTICE: Version 2 was bugged, and output the target of the _previous_
 *      trial.
 *
 * Version 3 (0x03)
 * ----------------
 * Almost exactly the same specification as version 2.  Fixes the bug that 
 * caused the output target position to be delayed by one trial, and removes
 * the possibility of multiple targets (although they were in the spec, 
 * multiple targets were never output in the databurst).
 * 
 * Version 4 (0x04)
 * ----------------
 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case four)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 * bytes  6 to  9: float => x offset
 * bytes 10 to 13: float => y offset
 * bytes 14 to 17: float => Cursor rotation value
 * bytes 18 to 33: 16 bytes per target representing four single precision floating point
 *      numbers in little-endian format representing UL x, UL y, LR x and LR y coordinates
 *      of the UL and LR corners of the target.
 *
 *      The position of only the current target is output at the begining of each trial
 *      in normal behavior.
 *
 *      In MVC mode, the current value of the MVC target is provided in the databurst
 */

typedef unsigned char byte;
#define DATABURST_VERSION (0x04) 

/*
 * Tunable parameters
 */
static real_T num_targets = 8;      /* total number of targets from which to select */
#define param_num_targets mxGetScalar(ssGetSFcnParam(S,0))

static real_T reach_time = 5.0;          /* Time to reach AND hold target*/
#define param_reach_time mxGetScalar(ssGetSFcnParam(S,1))
static real_T target_hold_time = .5;
#define param_target_hold_time mxGetScalar(ssGetSFcnParam(S,2))

static real_T center_hold_time_l = .5;          /* delay before movement */
#define param_center_hold_time_l mxGetScalar(ssGetSFcnParam(S,3))

static real_T center_hold_time_h = .5;
#define param_center_hold_time_h mxGetScalar(ssGetSFcnParam(S,19))

#define param_intertrial mxGetScalar(ssGetSFcnParam(S,4))
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T failure_timeout = 1.0;    /* delay after failure */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */

static real_T center_x = 0.0;
#define param_center_x mxGetScalar(ssGetSFcnParam(S,5))
static real_T center_y = 0.0;
#define param_center_y mxGetScalar(ssGetSFcnParam(S,6))  
static real_T center_h = 2.0; 
#define param_center_h mxGetScalar(ssGetSFcnParam(S,7))
static real_T center_w = 4.0;
#define param_center_w mxGetScalar(ssGetSFcnParam(S,8))

static real_T center_delay_time_l = 0.0;
#define param_center_delay_time_l mxGetScalar(ssGetSFcnParam(S,9))

static real_T center_delay_time_h = 0.0;
#define param_center_delay_time_h mxGetScalar(ssGetSFcnParam(S,10))

static real_T idiot_mode = 0.0;
#define param_idiot_mode mxGetScalar(ssGetSFcnParam(S,11))

static real_T clear_MVC_tgts = 0.0;
#define param_clear_MVC_tgts mxGetScalar(ssGetSFcnParam(S,12))

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,13))

static real_T catch_trials_pct = 0.0;
#define param_catch_trials_pct mxGetScalar(ssGetSFcnParam(S,14))

static real_T rotation = 0.0;
#define param_rotation mxGetScalar(ssGetSFcnParam(S,15))

static real_T rotation_increment = 0.0;
#define param_rotation_increment mxGetScalar(ssGetSFcnParam(S,16))

static real_T rotation_max = 0.785398163; /* ( PI / 4 ) == 90 deg */
#define param_rotation_max mxGetScalar(ssGetSFcnParam(S,17))

static real_T master_update = 0.0;
#define param_master_update mxGetScalar(ssGetSFcnParam(S,18))

/* Param(S,19) is center_hold_time_h -- see above */

static real_T neural_control_during_catch_trials = 1;
#define param_neural_control_during_catch_trials mxGetScalar(ssGetSFcnParam(S,20));

#define set_catch_trial(x) ssSetIWorkValue(S, 22, (x))
#define get_catch_trial() ssGetIWorkValue(S, 22)

/*
 * State IDs
 */
#define STATE_PRETRIAL          0
#define STATE_CENTERING         1
#define STATE_RECENTERING       2
#define STATE_CENTER_HOLD       3
#define STATE_DELAY             4
#define STATE_MOVEMENT          5
#define STATE_TARGET_HOLD       6
#define STATE_CONTINUE_MOVEMENT 7
#define STATE_REWARD            82
#define STATE_ABORT             65
#define STATE_FAIL              70
#define STATE_DATA_BLOCK        255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3

static void mdlCheckParameters(SimStruct *S)
{
  num_targets = param_num_targets;
  
  reach_time = param_reach_time;
  target_hold_time = param_target_hold_time;
  center_hold_time_l  = param_center_hold_time_l;
  center_hold_time_h  = param_center_hold_time_h;
  center_delay_time_l = param_center_delay_time_l;
  center_delay_time_h = param_center_delay_time_h;

  center_y = param_center_y;
  center_h = param_center_h;
  center_x = param_center_x;
  center_w = param_center_w;
  
  abort_timeout      = param_intertrial;
  failure_timeout    = param_intertrial;
  incomplete_timeout = param_intertrial;
  reward_timeout     = param_intertrial;
  
  idiot_mode = param_idiot_mode;
  catch_trials_pct = param_catch_trials_pct/100;
  
  rotation           = param_rotation * PI / 180.0;
  rotation_increment = param_rotation_increment * PI / 180.0;
  rotation_max       = param_rotation_max * PI / 180.0;

  neural_control_during_catch_trials = param_neural_control_during_catch_trials;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 21); 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
    for (i=0; i<ssGetNumSFcnParams(S); i++)
        ssSetSFcnParamTunable(S,i, 1);
    mdlCheckParameters(S);
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);
    
    /*
     * Block has 3 input ports
     *      input port 0: (position) of width 2 (horizontal and vertical cursor displacement)
     *      input port 1: (position offsets) of width 2 (x, y)
     *      input port 2: (target) of width 6*16 (vertical displacement, height, horiz disp, width, xVarEnable, yVarEnable)*16
     */
    if (!ssSetNumInputPorts(S, 3)) return;
    ssSetInputPortWidth(S, 0, 2); /* cursor position*/
    ssSetInputPortWidth(S, 1, 2); /* cursor position*/
    ssSetInputPortWidth(S, 2, 6*16); /* target position _table_ (stacked) */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    
    /* 
     * Block has 9 output ports (reward, word, status, tone, target, target select, MVC Target, version, rotation) of widths:
     * 0: reward:         1
     * 1: word:           1
     * 2: status:         4 ( 1: state, 2: rewards, 3: aborts, 4: failures )
     * 3: tone:           2 ( 1: counter incemented for each new tone, 2: tone ID )     
     * 4: target: 10 ( target 1, 2: 
     *                  type, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)
`    * 5: MVC Target:     8  ( [Xmax quad 1, Ymax quad 1, Xmax quad 2,...,Ymax quad 4] )
     * 6: version: 4
     * 7: rotation: 1
     *
     */
    if (!ssSetNumOutputPorts(S, 9)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 4);
    ssSetOutputPortWidth(S, 3, 2);
    ssSetOutputPortWidth(S, 4, 10);
    ssSetOutputPortWidth(S, 5, 8);
    ssSetOutputPortWidth(S, 6, 4); /*version*/
    ssSetOutputPortWidth(S, 7, 1);
	ssSetOutputPortWidth(S, 8, 1);
    
    ssSetNumSampleTimes(S, 1);
    
    /* work buffers */
    ssSetNumRWork(S, 39);   /* 0: time of last timer reset
                               1: time of last target hold timer reset 
                               2: tone counter (incremented each time a tone is played)
                               3: tone id
                               4: UNUSED

                                 // For Following MVC Target related buffers:                                  
                                 // Quadrant 1 is +x and + y, including the +x and y = 0 axis
                                 // Quadrant 2 is -x and +y, including the x = 0 and +y axis                                
                                 // Quadrant 3 is -x and - y, including the -x and y = 0 axis
                                 // Quadrant 4 is +x and -y, including the x = 0 and -y axis
                               5-12: User specified MVC targets [x1 x2 x3 x4 y1 y2 y3 y4]
                               13-20: Current MVC targets [x1 x2 x3 x4 y1 y2 y3 y4]
                               21-28: higher MVC targets reached [x1 x2 x3 x4 y1 y2 y3 y4]
                               29: mastercon version
                               30: Time of last update
                               31: The randomized center hold time
                               32: The randomized delay time
                               33-38: The current target: [target_y, target_h, target_x, target_w, tgt_xVar_enabled, tgt_yVar_enabled]
                            */
    ssSetNumPWork(S, 1);    /* 0: Databurst array pointer 
                            */
    ssSetNumIWork(S, 25); /*   0: state_transition (true if state changed), 
                               1: current target index (in sequence),
                               2: successes
                               3: aborts
                               4: failures 
                          [5-20]: target_id list
                              21: success_flag
                              22: catch_trial_flag
                              23: datablock counter
                              24: increment_rotation_flag
                          */
    
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
    int i;
    int* databurst;
    real_T *x0;
    
    /* initialize state to zero */
    x0 = ssGetRealDiscStates(S);
    *x0 = 0.0;
    
    /* notify that we just entered this state */
    ssSetIWorkValue(S, 0, 1);
    
    /* set target index to indicate that we need to begin a new block */
    ssSetIWorkValue(S, 1, (int)num_targets-1);
    
    /* set the tone counter to zero */
    ssSetRWorkValue(S, 2, 0.0);
    ssSetRWorkValue(S, 3, 0.0);
    
    /* set the mvc Targets at 0 */
    for (i=5; i<29; i++) {
        ssSetRWorkValue(S, i, 0.0);
    }
    /* set the initial last update time to 0 */
    ssSetRWorkValue(S,30,0.0);
    
    /* initialize targets id lists at zero */
    for (i = 5 ; i<21 ; i++){
        ssSetIWorkValue(S, i, 0);
    }
    
    /* set trial counters to zero */
    ssSetIWorkValue(S, 2, 0);
    ssSetIWorkValue(S, 3, 0);
    ssSetIWorkValue(S, 4, 0);
    
    /* set catch trial flag to zero */
    ssSetIWorkValue(S,22,0);
    
    /* initialize success flag at zero */
    ssSetIWorkValue(S, 21, 0);
    
    /* set reset counter to zero */
    clear_MVC_tgts = 0.0;
    master_reset = 0.0;
    
    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 23, 0);
    
    /* set the increment_rotation_flag to 0 */
    ssSetIWorkValue(S, 24, 0);
}

/* macro for setting state changed */
#define state_changed() (ssSetIWorkValue(S, 0, 1))
/* macros for resetting timers */
#define reset_timer() (ssSetRWorkValue(S, 0, (real_T)ssGetT(S)))
#define reset_target_hold_timer() (ssSetRWorkValue(S, 1, (real_T)ssGetT(S)))

#define success_flag() (ssSetIWorkValue(S, 21, 1))
/* Macro for assigning random center hold time */
#define set_random_hold_time() if (center_hold_time_l == center_hold_time_h) { ssSetRWorkValue(S, 31, center_hold_time_l);} \
                               else {ssSetRWorkValue(S, 31, center_hold_time_l + UNI*(center_hold_time_h-center_hold_time_l));}
/* Macro for assigning random delay time */
#define set_random_delay_time() if (center_delay_time_l == center_delay_time_h) { ssSetRWorkValue(S, 32, center_delay_time_l);} \
                               else {ssSetRWorkValue(S, 32, center_delay_time_l + UNI*(center_delay_time_h-center_delay_time_l));}

/* cursorInTarget
 * returns true (1) if the cursor is in the target and false (0) otherwise
 * cursor is specified as x, y = c[0], c[1]
 * target is specified by two corners: UL: x, y = t[0], t[1]
 *                                     LR: x, y = t[2], t[3]
 */
#define cursorInTarget(c, t) ( ((c)[0] > (t)[0]) && ((c)[1] < (t)[1]) && ((c)[0] < (t)[2]) && ((c)[1] > (t)[3]) )

/* getQuad: simply returns the quadrant that a point is in. */
static int getQuad(real_T x, real_T y) {
    if      (x> 0 && y>=0)    { return 1; }
    else if (x<=0 && y> 0)    { return 2; }
    else if (x< 0 && y<=0)    { return 3; }
    else if (x>=0 && y< 0)    { return 4; }
    else /* (x==0 && y==0) */ { return 0; }
}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
    /****************
     * Declarations *
     ****************/
    
    /* stupidly declare all variables at the begining of the function */
    int i, j;    
    int *IWorkVector; 
    int target_index;
    int target_id;
    int *target_list;
    int tgt_xVar_enabled;
    int tgt_yVar_enabled;
    int quadrant;
    real_T target_x, target_y, target_h, target_w;
    real_T tgt[4];
    real_T center[4];
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    real_T elapsed_target_hold_time;
    real_T success_flag;

    //holders for MVC targets variables
    real_T user_spec_MVC_targets[8];
    real_T current_MVC_targets[8];
    real_T higher_MVC_targets[8];
    
    int tmp_tgts[64];
    int tmp_i;
    double tmp_sort[64];
    double tmp_d;
        
    byte *databurst;
    float *databurst_rotation;
    float *databurst_offsets;
    float *databurst_target_list;
    int databurst_counter;
    
    int reshuffle = 0;
    
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int new_state = state;
    ssSetIWorkValue(S, 0, 0); /* By default, clear the state-changed flag */
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* Current target index*/
    target_index = ssGetIWorkValue(S, 1);
    target_id = ssGetIWorkValue(S, 5 + target_index);

    IWorkVector = ssGetIWork(S);
    target_list = IWorkVector+5;
    
    /* Success Flag */
    success_flag = ssGetIWorkValue(S, 21);
    
    /* Get the Current Target Location */
    target_y = ssGetRWorkValue(S,33);
    target_h = ssGetRWorkValue(S,34);
    target_x = ssGetRWorkValue(S,35);
    target_w = ssGetRWorkValue(S,36);
    tgt_xVar_enabled = (int)ssGetRWorkValue(S,37);
    tgt_yVar_enabled = (int)ssGetRWorkValue(S,38);
    /* Define the target corners */
    tgt[0] = target_x - target_w / 2.0;
    tgt[1] = target_y + target_h / 2.0;
    tgt[2] = target_x + target_w / 2.0;
    tgt[3] = target_y - target_h / 2.0;
    /* And define the quadrant */
    quadrant = getQuad(target_x, target_y);
    if (quadrant == 0) {
        /* (x,y) = (0,0); Turn off the MVC routines */
        tgt_xVar_enabled = 0;
        tgt_yVar_enabled = 0;   
    } 
    
    /*MVC Targets variables*/
    for (i=0; i<8; i++) {
        user_spec_MVC_targets[i]= ssGetRWorkValue(S,i+5);
        current_MVC_targets[i]  = ssGetRWorkValue(S,i+13);
        higher_MVC_targets[i]   = ssGetRWorkValue(S,i+21);
    }  
        
    /* get center bounds */
    center[0] = center_x - center_w / 2.0;
    center[1] = center_y + center_h / 2.0;
    center[2] = center_x + center_w / 2.0;
    center[3] = center_y - center_h / 2.0;
       
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    elapsed_target_hold_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 1);

    /* Setup the databurst pointers */
    databurst_counter = ssGetIWorkValue(S, 23);
    databurst = ssGetPWorkValue(S, 0);
    databurst_offsets     = (float *)(databurst + 6);
    databurst_rotation    = databurst_offsets + 2;
    databurst_target_list = databurst_rotation + 1;
    
    /*********************************
     * See if we have issued a reset *
     *********************************/
    if (param_master_reset > master_reset) {
        master_reset = param_master_reset;
        ssSetIWorkValue(S, 2, 0);
        ssSetIWorkValue(S, 3, 0);
        ssSetIWorkValue(S, 4, 0);
        state_r[0] = STATE_PRETRIAL;
        return;
    }
    
    /* See if we want to clear the value of the higher target reached */    
    if (param_clear_MVC_tgts > clear_MVC_tgts) {
        clear_MVC_tgts = param_clear_MVC_tgts;
        for (i=5; i<29; i++) {
            ssSetRWorkValue(S, i, 0.0); //clear all MVC target buffers
        }
    }
    
    /* See if we should increment the rotation; only do it on the very first
     * cycle of each minute. Since we run at 1kHz, that's every 60000 cycles. */
    if ( ((((unsigned long int)((ssGetT(S)-ssGetRWorkValue(S,30)) * 1000)) % (60*1000)) == 0) &&
         ( ssGetT(S)-ssGetRWorkValue(S,30) != 0.0 ) ) {
        /* We're in a once-a-minute cycle; set the flag to increment the rotation on the next trial */
        ssSetIWorkValue(S, 24, 1);
    }
            
    /************************
     * Calculate next state *
     ************************/
    
    /* execute one step of state machine */
    switch (state) {
        case STATE_PRETRIAL:
            /* Initialize the trial and then advance to STATE_DATA_BLOCK */

            /* Update parameters */        
            center_hold_time_l = param_center_hold_time_l;
            center_hold_time_h = param_center_hold_time_h;
            center_delay_time_l = param_center_delay_time_l;
            center_delay_time_h = param_center_delay_time_h;
            center_y = param_center_y;
            center_h = param_center_h;
            center_x = param_center_x;
            center_w = param_center_w;
            reach_time = param_reach_time;
            target_hold_time = param_target_hold_time;
            
            abort_timeout   = param_intertrial;    
            failure_timeout = param_intertrial;   
            reward_timeout  = param_intertrial;
            
            catch_trials_pct = param_catch_trials_pct/100;

            num_targets = param_num_targets;
            idiot_mode = param_idiot_mode;
            
            /* Only update these values if we've explicitly issued an update */
            if ( param_master_update > master_update ) {
                master_update = param_master_update;
                rotation = param_rotation * PI / 180.0;
                ssSetRWorkValue(S, 30, ssGetT(S));
                reshuffle = 1;
            }
            rotation_increment = param_rotation_increment * PI / 180.0;
            rotation_max       = param_rotation_max * PI / 180.0;
			neural_control_during_catch_trials = param_neural_control_during_catch_trials;
            
            /* Check for the rotation flag and rotate the cursor by that amount */
            if ( ssGetIWorkValue(S, 24) ) {
                rotation += rotation_increment;
                if ( (rotation_increment < 0 && rotation < rotation_max) ||
                     (rotation_increment > 0 && rotation > rotation_max) )
                    rotation = rotation_max;
                ssSetIWorkValue(S, 24, 0); /* and unflag */
            }            

            /* decide if this is going to be a catch trial */
			set_catch_trial(catch_trials_pct > UNI ? 1 : 0);
            /*set_catch_trial( (catch_trials_pct > ((double)rand()/(double)RAND_MAX)) ? 1 : 0 );*/

            /***************************************/
            /* see if we have to update MVC_Target */
            /***************************************/
            if (success_flag) {
                if (tgt_xVar_enabled) {
                    /* MVC Target reached! Increase it by 15% */
                    ssSetRWorkValue(S, 12+quadrant,target_x*1.15);
                }
                if (tgt_yVar_enabled) {
                    /* MVC Target reached! Increase it by 15% */
                    ssSetRWorkValue(S, 16+quadrant,target_y*1.15);
                }
                if ( target_x*target_x > higher_MVC_targets[quadrant-1]*higher_MVC_targets[quadrant-1]) {
                    /* We have a new Max MVC!*/
                    ssSetRWorkValue(S, 20+quadrant,target_x);
                }
                if (target_y*target_y > higher_MVC_targets[quadrant+3]*higher_MVC_targets[quadrant+3]) {
                    /* We have a new Max MVC!*/
                    ssSetRWorkValue(S, 24+quadrant,target_y);
                }
            } else { // last trial was not a success
                if (tgt_xVar_enabled) {
                    /* Failed to reach and hold MVC Target, decrease x by 8% */
                    ssSetRWorkValue(S, 12+quadrant,target_x*0.92);
                }
                if (tgt_yVar_enabled) {
                    /* Failed to reach and hold MVC Target, decrease y by 8% */
                    ssSetRWorkValue(S, 16+quadrant,target_y*0.92);
                }
            }
                    
        
            // reshuffle by default if we reached the last target in the list, unless failure and idiot mode
            if (target_index == num_targets-1 && !(idiot_mode && success_flag == 0)) {
                reshuffle = 1;  
            }

            /* Reshuffle the targets! */
            if (reshuffle) {
                // reshuffle
                j = 0;
                /* set up lists loop */
                for (i=0; i<num_targets; i++) {
                    tmp_tgts[j] = i;
                    tmp_sort[j++] = rand();
                }
                
                /* shuffle lists loop */
                for (i=0; i<num_targets-1; i++) {
                    for (j=0; j<num_targets-1; j++) {
                        if (tmp_sort[j] < tmp_sort[j+1]) {
                            tmp_d = tmp_sort[j];
                            tmp_sort[j] = tmp_sort[j+1];
                            tmp_sort[j+1] = tmp_d;
                            
                            tmp_i = tmp_tgts[j];
                            tmp_tgts[j] = tmp_tgts[j+1];
                            tmp_tgts[j+1] = tmp_i;
                        }
                    }
                }
                
                /* write lists back to work buffer loop */
                for (i=0; i<=num_targets-1; i++) {
                    target_list[i] = tmp_tgts[i];
                    ssSetIWorkValue(S, i+5, target_list[i]);
                }
                
                /* and reset the counter */
                target_index = 0;
                ssSetIWorkValue(S, 1, target_index);
                
            } else if (idiot_mode) {
                //    advance to next target only if previous success
                if (success_flag) ssSetIWorkValue(S, 1, ++target_index);
            } else {
                // default : advance to next target
                ssSetIWorkValue(S, 1, ++target_index);
            }
            
            /* Update the current target_id based on our new target_index */
            target_id = ssGetIWorkValue(S, 5 + target_index);

            /* Grab the (newly) selected target from the target table */
            uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
            target_y = *uPtrs[0+(target_id*6)];
            target_h = *uPtrs[1+(target_id*6)];
            target_x = *uPtrs[2+(target_id*6)];
            target_w = *uPtrs[3+(target_id*6)];
            tgt_xVar_enabled = (int)*uPtrs[4+(target_id*6)];
            tgt_yVar_enabled = (int)*uPtrs[5+(target_id*6)];
            /* update the quadrant */
            quadrant = getQuad(target_x, target_y);
            if (quadrant == 0) {
                /* (x,y) = (0,0); Turn off the MVC routines */
                tgt_xVar_enabled = 0;
                tgt_yVar_enabled = 0;   
            } 
            
            /****************************************************************************/ 
            /* if we are in MVC routine mode, we may want to override the target values */
            /****************************************************************************/ 
            if (tgt_xVar_enabled) {
                if (current_MVC_targets[quadrant-1]!=0) { // we have xVar enabled and a current value for this quad x target
                    if (target_x != user_spec_MVC_targets[quadrant-1]) { //this quad x MVC target changed by user, we clear this current MVC target
                            current_MVC_targets[quadrant-1] = 0;
                    } else {
                        target_x = current_MVC_targets[quadrant-1]; //override the x value for the MVC target in this quad
                    }
                }
                if (current_MVC_targets[quadrant-1] == 0) { //first occurence of this target, don't modify it
                    user_spec_MVC_targets[quadrant-1] = target_x;
                    ssSetRWorkValue(S,4+quadrant,user_spec_MVC_targets[quadrant-1]);
                    current_MVC_targets[quadrant-1] = target_x; //set the current target to value provided by user
                    ssSetRWorkValue(S,12+quadrant,current_MVC_targets[quadrant-1]);
                }
            }
            if (tgt_yVar_enabled) {
                if (current_MVC_targets[quadrant+3]!=0) { // we have yVar enabled and a current value for this quad y target
                    if (target_y != user_spec_MVC_targets[quadrant+3]) { //this quad y MVC target changed by user, we clear this current MVC target
                        current_MVC_targets[quadrant+3] = 0;
                    } else {
                        target_y = current_MVC_targets[quadrant+3]; //override the y value for the MVC target in this quad
                    }
                }
                if (current_MVC_targets[quadrant+3] == 0) { //first occurence of this target, don't modify it
                    user_spec_MVC_targets[quadrant+3] = target_y;
                    ssSetRWorkValue(S,8+quadrant,user_spec_MVC_targets[quadrant+3]);
                    current_MVC_targets[quadrant+3] = target_y; //set the current target to value provided by user
                    ssSetRWorkValue(S,16+quadrant,current_MVC_targets[quadrant+3]);
                }
            }
            /********************************/ 
            /* End of MVC target overriding */
            /********************************/ 
            
            /* Write the target back to the RWork vector */
            ssSetRWorkValue(S,33,target_y);
            ssSetRWorkValue(S,34,target_h);
            ssSetRWorkValue(S,35,target_x);
            ssSetRWorkValue(S,36,target_w);
            ssSetRWorkValue(S,37,tgt_xVar_enabled);
            ssSetRWorkValue(S,38,tgt_yVar_enabled);
            /* Update the target bounds */
            tgt[0] = target_x - target_w / 2.0;
            tgt[1] = target_y + target_h / 2.0;
            tgt[2] = target_x + target_w / 2.0;
            tgt[3] = target_y - target_h / 2.0;
            
            /* Copy target info into databursts */
            databurst[0] = 6 + 3*sizeof(float) + 4*sizeof(float);
            databurst[1] = DATABURST_VERSION;
            databurst[2] = BEHAVIOR_VERSION_MAJOR;
            databurst[3] = BEHAVIOR_VERSION_MINOR;
            databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
            databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            /* The offsets used in the calculation of the cursor location */
            uPtrs = ssGetInputPortRealSignalPtrs(S, 1); 
            databurst_offsets[0] = *uPtrs[0];
            databurst_offsets[1] = *uPtrs[1];
            databurst_rotation[0] = (float)(rotation * 180.0 / PI);
            for (i = 0; i < 4; i++) {
                databurst_target_list[i] = (float)tgt[i];
            }
            /* and reset the databurst counter */
            ssSetIWorkValue(S, 23, 0);
                        
            new_state = STATE_DATA_BLOCK;
            ssSetIWorkValue(S, 21, 0);  // clear success_flag
            state_changed();

            break;
        case STATE_DATA_BLOCK:
            if (databurst_counter > 2*(databurst[0]-1)) { 
               new_state = STATE_CENTERING;
               state_changed();
            }
            ssSetIWorkValue(S, 23, databurst_counter+1);
            break;           
        case STATE_CENTERING:
            if (cursorInTarget(cursor, center)) {
                new_state = STATE_CENTER_HOLD;
                state_changed();
                set_random_hold_time();
                reset_timer();                
            }
            break;
        case STATE_CENTER_HOLD:
            if (!cursorInTarget(cursor, center)) {
                new_state = STATE_RECENTERING;
                state_changed();
            } else if ( elapsed_timer_time > ssGetRWorkValue(S,31) ) {
                new_state = STATE_DELAY;
                set_random_delay_time();
                state_changed();
                reset_timer();
            }
            break;
        case STATE_RECENTERING:
            if (cursorInTarget(cursor, center)) {
                new_state = STATE_CENTER_HOLD;
                state_changed();
                reset_timer();                
            }
            break;            
        case STATE_DELAY:
            if (!cursorInTarget(cursor, center)) {
                new_state = STATE_RECENTERING;
                state_changed();
                reset_timer();
            } else if ( elapsed_timer_time > ssGetRWorkValue(S,32) ) {
                new_state = STATE_MOVEMENT;
                state_changed();
                reset_timer();
            }
            break;
        case STATE_MOVEMENT:
            if (elapsed_timer_time > reach_time) {
                new_state = STATE_FAIL;
                state_changed();
                reset_timer();
            } else if (cursorInTarget(cursor, tgt)) {
                new_state = STATE_TARGET_HOLD;
                state_changed();
                reset_target_hold_timer();
            }
            break;
        case STATE_TARGET_HOLD:
            if (!cursorInTarget(cursor, tgt)) {
                new_state = STATE_CONTINUE_MOVEMENT;
                state_changed();
            } else if (elapsed_target_hold_time > target_hold_time) {
                success_flag();
                new_state = STATE_REWARD;
                state_changed();
                reset_timer();
            }
            break;
        case STATE_CONTINUE_MOVEMENT:
            if (elapsed_timer_time > reach_time) {
                new_state = STATE_FAIL;
                state_changed();
                reset_timer();
            } else if (cursorInTarget(cursor, tgt)) {
                new_state = STATE_TARGET_HOLD;
                state_changed();
                reset_target_hold_timer();
            }
            break;
        case STATE_ABORT:
            /* abort */
            if (elapsed_timer_time > abort_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
            }
            break;
        case STATE_FAIL:
            /* failure */
            if (elapsed_timer_time > failure_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
            }
            break;
        case STATE_REWARD:
            /* reward */
            if (elapsed_timer_time > reward_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
                success_flag();
            }
            break;
        default:
            new_state = STATE_PRETRIAL;
            state_changed();
    }
    
    
    /* Stuff that happens on state boundaries */
    if (ssGetIWorkValue(S, 0)) {
        /* increment the status counters */
        if (new_state == STATE_REWARD)
            ssSetIWorkValue(S, 2, ssGetIWorkValue(S, 2)+1);
        else if (new_state == STATE_ABORT)
            ssSetIWorkValue(S, 3, ssGetIWorkValue(S, 3)+1);
        else if (new_state == STATE_FAIL)
            ssSetIWorkValue(S, 4, ssGetIWorkValue(S, 4)+1);
        
        /* update the tone */
        if (new_state == STATE_ABORT) {
            ssSetRWorkValue(S, 2, ssGetRWorkValue(S, 2)+1); /* tone_cnt */
            ssSetRWorkValue(S, 3, TONE_ABORT); /* tone_id  */
        } else if (new_state == STATE_MOVEMENT) {
            ssSetRWorkValue(S, 2, ssGetRWorkValue(S, 2)+1); /* tone_cnt */
            ssSetRWorkValue(S, 3, TONE_GO); /* tone_id  */
        } else if (new_state == STATE_REWARD) {
            ssSetRWorkValue(S, 2, ssGetRWorkValue(S, 2)+1); /* tone_cnt */
            ssSetRWorkValue(S, 3, TONE_REWARD); /* tone_id  */
        }
    }
    
    /***********
     * Cleanup *
     ***********/
    
    /* write back new state */
    state_r[0] = new_state;
    
    KISS; /* burn a place in the prng */
    
    UNUSED_ARG(tid);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /********************
     *  Initialization
     ********************/
    int i;
    real_T target_x, target_y, target_h, target_w;
    int target_index;
    int target_id;
    real_T tgt[4];
    real_T center[4];
    real_T tone_cnt, tone_id;
    int new_state;
    byte* databurst;
    int databurst_counter;
    real_T higher_MVC_targets[8];
    
    /* holders for outputs */
    real_T reward, word;
    real_T status[4];
    real_T target[10];
    real_T version[4];
       
    /* pointers to output buffers */
    real_T *reward_p;
    real_T *word_p;
    real_T *status_p;
    real_T *tone_p;
    real_T *target_p;
    real_T *target_select_p;
    real_T *mvcTarget_p;
    real_T *version_p;
    real_T *rotation_p;
	real_T *neural_control_flag_p;
    
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    new_state = ssGetIWorkValue(S, 0);
    
    /* Get the Current Target ID and Location */
    target_index = ssGetIWorkValue(S, 1);
    target_id = ssGetIWorkValue(S, 5 + target_index);
    target_y = ssGetRWorkValue(S,33);
    target_h = ssGetRWorkValue(S,34);
    target_x = ssGetRWorkValue(S,35);
    target_w = ssGetRWorkValue(S,36);
    /* And define the target bounds */
    tgt[0] = target_x - target_w / 2.0;
    tgt[1] = target_y + target_h / 2.0;
    tgt[2] = target_x + target_w / 2.0;
    tgt[3] = target_y - target_h / 2.0;
    
    /* get center bounds */
    center[0] = center_x - center_w / 2.0;
    center[1] = center_y + center_h / 2.0;
    center[2] = center_x + center_w / 2.0;
    center[3] = center_y - center_h / 2.0;    
    
    /*MVC Targets variables*/
    for (i=0; i<8; i++) {
        higher_MVC_targets[i]=ssGetRWorkValue(S,i+21);
    }  

    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 23);
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
            word = databurst[databurst_counter / 2] | 0xF0; /* low order bits */
        } else {
             word = (databurst[(databurst_counter-1) / 2] >> 4) | 0xF0; /* high order bits */
        }
    } else if (new_state) {
        switch (state) {
            case STATE_PRETRIAL:
                word = WORD_START_TRIAL;
                break;
            case STATE_CENTERING:
                word = WORD_CT_ON;
                break;
            case STATE_CENTER_HOLD:
                word = WORD_CENTER_TARGET_HOLD;
                break;
			case STATE_DELAY:
				word = WORD_OT_ON(target_id);
				break;
            case STATE_MOVEMENT:
                if (get_catch_trial()) {
                    word = WORD_CATCH;
                } else {
                    word = WORD_GO_CUE;
                }
                break;
            case STATE_TARGET_HOLD:
                word = WORD_OUTER_TARGET_HOLD;
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
            default:
                word = 0.0;
        }
    } else {
        word = 0.0;
    }
    
    /* status (2) */
    status[0] = state;
    status[1] = ssGetIWorkValue(S,2); // num rewards
    status[2] = ssGetIWorkValue(S,3); // num aborts
    status[3] = ssGetIWorkValue(S,4); // num failures
    
    /* tones (3) */
    tone_cnt = ssGetRWorkValue(S, 2);
    tone_id  = ssGetRWorkValue(S, 3);
    
    /* targets (4)*/     
	for (i=0; i<4; i++) {
        target[i+1] = tgt[i];
        target[i+6] = center[i];
    }
    
    switch (state) {
        case STATE_CENTERING:
            /* target off */
            target[0] = 0;
            /* center red*/
            target[5] = 1;
        break;
		case STATE_RECENTERING:
            /* target off */
            target[0] = 0;
            /* center red*/
            target[5] = 1;
        break;
        case STATE_CENTER_HOLD:
            /* target off */
            target[0] = 0;
            /* center green*/
            target[5] = 3;
        break;
        case STATE_DELAY:
            /* target white */
            target[0] = 2;
            /* center green*/
            target[5] = 3;
        break;
        case STATE_MOVEMENT:
            /* target red */
            target[0] = 1;
            /* center off */
            target[5] = 0;
        break;
        case STATE_CONTINUE_MOVEMENT:
            /* target red */
            target[0] = 1;
            /* center off */
            target[5] = 0;
        break;
        case STATE_TARGET_HOLD:
            /* target green */
            target[0] = 3;
            /* center off */
            target[5] = 0;
        break;
        default:
            /* target and center off */
            target[0] = 0;
            target[5] = 0;
    }

     /* Version */
     version[0] = BEHAVIOR_VERSION_MAJOR;
     version[1] = BEHAVIOR_VERSION_MINOR;
     version[2] = BEHAVIOR_VERSION_MICRO;
     version[3] = BEHAVIOR_VERSION_BUILD;
    
    /* neural control flag (8)*/
	neural_control_flag_p = ssGetOutputPortRealSignal(S,8);
	if (!neural_control_during_catch_trials){
		neural_control_flag_p[0] = 1;
	} else {
		if (get_catch_trial() && (state==STATE_MOVEMENT || state==STATE_CONTINUE_MOVEMENT || state==STATE_TARGET_HOLD))
			neural_control_flag_p[0] = 1;
		else
			neural_control_flag_p[0] = 0;
	}


    /**********************************
     * Write outputs back to SimStruct
     **********************************/
 
     reward_p = ssGetOutputPortRealSignal(S,0);
     reward_p[0] = reward;
     
     word_p = ssGetOutputPortRealSignal(S,1);
     word_p[0] = word;
          
     status_p = ssGetOutputPortRealSignal(S,2);
     for (i=0; i<4; i++) 
         status_p[i] = (real_T)status[i];
    
     tone_p = ssGetOutputPortRealSignal(S,3);
     tone_p[0] = tone_cnt;
     tone_p[1] = tone_id;
     
     target_p = ssGetOutputPortRealSignal(S,4);
     for (i=0; i<10; i++) 
         target_p[i] = target[i];
     
     mvcTarget_p = ssGetOutputPortRealSignal(S,5);
     for (i=0; i<4; i++) {
         mvcTarget_p[2*i]  = higher_MVC_targets[i];
         mvcTarget_p[2*i+1]= higher_MVC_targets[i+4];
     }
     
     version_p = ssGetOutputPortRealSignal(S, 6);
     for (i=0; i<4; i++) {
         version_p[i] = version[i];
     }
     
     rotation_p = ssGetOutputPortRealSignal(S,7);
     rotation_p[0] = rotation;
          
    UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif
