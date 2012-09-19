/* $Id: mastercon_rw.c 753 2012-01-16 22:03:55Z bwalker $
 *
 * Master Control block for behavior: random walk task 
 */

#define S_FUNCTION_NAME mastercon_rw
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include "simstruc.h"

#define TASK_RW 1
#include "words.h"
#include "random_macros.h"

/* 
 * Current Databurst version: 1
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
 * byte 0: uchar => number of bytes to be transmitted
 * byte 1: uchar => version number (in this case zero)
 * bytes 2 - 2+N*8: where N is the number of targets, contains 8 bytes per 
 *      target representing two single-precision floating point numbers in 
 *      little-endian format represnting the x and y position of the center of 
 *      the target.
 *
 * Version 1 (0x01)
 * ----------------
 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case one)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 * bytes  6 to  9: float => x offset
 * bytes 10 to 13: float => y offset
 * bytes 14 to 17: float => target_size - target_tolerance
 * bytes 18 to 18+N*8: where N is the number of targets, contains 8 bytes per 
 *      target representing two single-precision floating point numbers in 
 *      little-endian format represnting the x and y position of the center of 
 *      the target.
 *
 *  Version 2 (0x02) - Similar to version 1, fixed "target_size + target_tolerance" and
 *                      it should now send all the bytes, previous version only sent
 *                      half of them.
 * ----------------
 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case two)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 * bytes  6 to  9: float => x offset
 * bytes 10 to 13: float => y offset
 * bytes 14 to 17: float => target_size + target_tolerance
 * bytes 18 to 18+N*8: where N is the number of targets, contains 8 bytes per 
 *      target representing two single-precision floating point numbers in 
 *      little-endian format represnting the x and y position of the center of 
 *      the target.
 */

typedef unsigned char byte;
#define DATABURST_VERSION ((byte)0x02) 

/*
 * Tunable parameters
 */
static real_T num_targets = 8;      /* number of sequential targets */
#define param_num_targets mxGetScalar(ssGetSFcnParam(S,0))
static real_T target_size = 3.0;    /* width and height of actual targets in cm */
#define param_target_size mxGetScalar(ssGetSFcnParam(S,1))
static real_T target_tolerance = 0.0;   /* tolerance for hitting target in cm */
#define param_target_tolerance mxGetScalar(ssGetSFcnParam(S,2))

static real_T left_target_boundary = -15.0; /* left boundary for target drawing in cm */
#define param_left_target_boundary mxGetScalar(ssGetSFcnParam(S,3))
static real_T right_target_boundary = -15.0; /* right boundary for target drawing in cm */
#define param_right_target_boundary mxGetScalar(ssGetSFcnParam(S,4))
static real_T upper_target_boundary = 15.0; /* upper boundary for target drawing in cm */
#define param_upper_target_boundary mxGetScalar(ssGetSFcnParam(S,5))
static real_T lower_target_boundary = -15.0; /* lower boundary for target drawing in cm*/
#define param_lower_target_boundary mxGetScalar(ssGetSFcnParam(S,6))

/* dwell time in state 2 */
static real_T target_hold_l = 0;
#define param_target_hold_l mxGetScalar(ssGetSFcnParam(S,7))
static real_T target_hold_h = 0;
#define param_target_hold_h mxGetScalar(ssGetSFcnParam(S,8))

/* delay time between next target appearance and movement state */
static real_T target_delay_l = 0;
#define param_target_delay_l mxGetScalar(ssGetSFcnParam(S,9))
static real_T target_delay_h = 0;
#define param_target_delay_h mxGetScalar(ssGetSFcnParam(S,10))

static real_T movement_time = 10.0;  /* movement time */
#define param_movement_time mxGetScalar(ssGetSFcnParam(S,11))

static real_T initial_movement_time = 10.0;  /* movement time */
#define param_initial_movement_time mxGetScalar(ssGetSFcnParam(S,12))

#define param_intertrial mxGetScalar(ssGetSFcnParam(S,13))
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T failure_timeout = 1.0;    /* delay after failure */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */
#define param_minimum_distance mxGetScalar(ssGetSFcnParam(S,14))
static real_T minimum_distance = 0.0;   /* minumum x distance and y distance from current target to the next one in cm */
#define param_maximum_distance mxGetScalar(ssGetSFcnParam(S,15))
static real_T maximum_distance = 0.0;   /* maximum x distance and y distance from current target to the next one in cm  *
                                         * set maximum_distance to zero for unconstrained target distance */
#define param_percent_catch_trials mxGetScalar(ssGetSFcnParam(S,16))
static real_T percent_catch_trials = 0.0;

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,17))

#define param_disable_abort mxGetScalar(ssGetSFcnParam(S,18))
static int disable_abort = 0;

#define param_green_hold mxGetScalar(ssGetSFcnParam(S,19))
static int green_hold = 0;

#define param_cumulative_hold mxGetScalar(ssGetSFcnParam(S,20))
static int cumulative_hold = 0;

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_INITIAL_MOVEMENT 1
#define STATE_TARGET_HOLD 2
#define STATE_TARGET_DELAY 3
#define STATE_MOVEMENT 4
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3

#define PI (3.141592654)

static void mdlCheckParameters(SimStruct *S)
{
    num_targets = param_num_targets;
    target_size = param_target_size;
    target_tolerance = param_target_tolerance;

    left_target_boundary = param_left_target_boundary;
    right_target_boundary = param_right_target_boundary;
    upper_target_boundary = param_upper_target_boundary;
    lower_target_boundary = param_lower_target_boundary;
            
    target_hold_l = param_target_hold_l;
    target_hold_h = param_target_hold_h;
    
    target_delay_l = param_target_delay_l;
    target_delay_h = param_target_delay_h;
    
    movement_time = param_movement_time;
    initial_movement_time = param_initial_movement_time;

    abort_timeout   = param_intertrial;    
    failure_timeout = param_intertrial;
    reward_timeout  = param_intertrial;   
    incomplete_timeout = param_intertrial;
    
    minimum_distance = param_minimum_distance;
    maximum_distance = param_maximum_distance;
    
    percent_catch_trials = param_percent_catch_trials;
	
	disable_abort = (int)param_disable_abort;
	green_hold = (int)param_green_hold;
	cumulative_hold = (int)param_cumulative_hold;
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
     * Block has 4 input ports
     *      input port 0: (position) of width 2 (x, y)
     *      input port 1: (position offset) of width 2 (x, y)
     *      input port 2: (force) of width 2 (x, y)
     *      input port 3: (catch force) of width 2 (x, y)
     */
    if (!ssSetNumInputPorts(S, 4)) return;
    ssSetInputPortWidth(S, 0, 2); /* x & y position */
    ssSetInputPortWidth(S, 1, 2); /* x & y position offsets */
    ssSetInputPortWidth(S, 2, 2); /* main force */
    ssSetInputPortWidth(S, 3, 2); /* catch trial force */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    
    /* 
     * Block has 8 output ports (force, status, word, targets, reward, tone, version, pos) of widths:
     *  force: 2
     *  status: 5 ( block counter, successes, aborts, failures, incompletes )
     *  word:  1 (8 bits)
     *  target: 10 ( target 1, 2: 
     *                  on/off, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)
     *  reward: 1
     *  tone: 2     ( 1: counter incemented for each new tone, 2: tone ID )
     *  version: 1 ( the cvs revision of the current .c file )
     *  pos: 2 (x and y position of the cursor)
     */
    if (!ssSetNumOutputPorts(S, 8)) return;
    ssSetOutputPortWidth(S, 0, 2);   /* force   */
    ssSetOutputPortWidth(S, 1, 5);   /* status  */
    ssSetOutputPortWidth(S, 2, 1);   /* word    */
    ssSetOutputPortWidth(S, 3, 10);  /* target  */
    ssSetOutputPortWidth(S, 4, 1);   /* reward  */
    ssSetOutputPortWidth(S, 5, 2);   /* tone    */
    ssSetOutputPortWidth(S, 6, 4);   /* version */
    ssSetOutputPortWidth(S, 7, 2);   /* pos     */
    
    ssSetNumSampleTimes(S, 1);

    /* work buffers */
    ssSetNumRWork(S, 512);  /* 0: time of last timer reset 
                               1: tone counter (incremented each time a tone is played)
                               2: tone id
                               3: current target hold time
                               4: current target delay time
                               5: time last entered hold state (used for cumulative hold)
                               6: cumulative hold time
                               7: UNUSED
                         [8-511]: positions of targets stored as (x, y) */

    ssSetNumIWork(S, 7); /*    0: state_transition (true if state changed), 
                               1: current target index (in sequence),
                               2: successes
                               3: failures
                               4: aborts 
                               5: catch trial flag (true if catch trial)
                               6: databock counter */
                  
    ssSetNumPWork(S, 1); /*    0: Databurst array pointer  */
    
    /* we have no zero crossing detection or modes */
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

#undef MDL_SET_WORK_WIDTHS
#ifdef MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    const char_T *param_names[] = {
        "NumTargets",
        "TargetSize",
        "TargetTolerance",
        "LeftTargetBoundary",
        "RightTargetBoundary",
        "UpperTargetBoundary",
        "LowerTargetBoundary",
        "TargetHoldLow",
        "TargetHoldHigh",
        "TargetDelayLow",
        "TargetDelayHigh",
        "MovementTime",
        "InitialMovementTime",
        "IntertrialInterval",
        "MinInterTargetDistance",
        "MaxInterTargetDistance",
        "PctCatchTrials",
        "MasterReset",
		"DisableAbort",
		"GreenHold",
		"CumulativeHold"
    };
    ssRegAllTunableParamsAsRunTimeParams(S, param_names);
}
#endif

#undef MDL_RTW
#ifdef MDL_RTW
static void mdlRTW (SimStruct *S)
{
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"NumTargets","",mxGetPr(ssGetSFcnParam(S,0)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"TargetSize","",mxGetPr(ssGetSFcnParam(S,1)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"TargetTolerance",mxGetPr(ssGetSFcnParam(S,2)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"LeftTargetBoundary",mxGetPr(ssGetSFcnParam(S,3)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"RightTargetBoundary",mxGetPr(ssGetSFcnParam(S,4)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"UpperTargetBoundary",mxGetPr(ssGetSFcnParam(S,5)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"LowerTargetBoundary",mxGetPr(ssGetSFcnParam(S,6)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"TargetHoldLow",mxGetPr(ssGetSFcnParam(S,7)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"TargetHoldHigh",mxGetPr(ssGetSFcnParam(S,8)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"TargetDelayLow",mxGetPr(ssGetSFcnParam(S,9)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"TargetDelayHigh",mxGetPr(ssGetSFcnParam(S,10)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"MovementTime",mxGetPr(ssGetSFcnParam(S,11)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"InitialMovementTime",mxGetPr(ssGetSFcnParam(S,12)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"IntertrialInterval",mxGetPr(ssGetSFcnParam(S,13)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"MinInterTargetDistance",mxGetPr(ssGetSFcnParam(S,14)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"MaxInterTargetDistance",mxGetPr(ssGetSFcnParam(S,15)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"PctCatchTrials",mxGetPr(ssGetSFcnParam(S,16)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"MasterReset",mxGetPr(ssGetSFcnParam(S,17)),1);
	ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"DisableAbort",mxGetPr(ssGetSFcnParam(S,18)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"GreenHold",mxGetPr(ssGetSFcnParam(S,19)),1);
    ssWriteRTWParameters(S,1,SSWRITE_VALUE_VECT,"CumulativeHold",mxGetPr(ssGetSFcnParam(S,20)),1);
}
#endif

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
    ssSetRWorkValue(S, 1, 0.0);
    ssSetRWorkValue(S, 2, 0.0);
    
    /* initialize targets at zero */
    for (i = 8 ; i<512 ; i++){
        ssSetRWorkValue(S, i, 0.0);
    }
    
    /* set trial counters to zero */
    ssSetIWorkValue(S, 2, 0);
    ssSetIWorkValue(S, 3, 0);
    ssSetIWorkValue(S, 4, 0);

    /* set reset counter to zero */
    master_reset = 0.0;
    
    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 6, 0);
}

/* macro for setting state changed */
#define state_changed() (ssSetIWorkValue(S, 0, 1))
/* macro for resetting timer */
#define reset_timer() (ssSetRWorkValue(S, 0, (real_T)ssGetT(S)))

/* macro for assigning a random (if needed) time to the target hold time */
#define set_random_hold_time() if (target_hold_l == target_hold_h) { ssSetRWorkValue(S, 3, target_hold_l);} \
                               else {ssSetRWorkValue(S, 3, target_hold_l + UNI*(target_hold_h-target_hold_l));}

/* similarly, macro for assigning random delay time */
#define set_random_delay_time() if (target_delay_l == target_delay_h) { ssSetRWorkValue(S, 4, target_delay_l);} \
                               else {ssSetRWorkValue(S, 4, target_delay_l + UNI*(target_delay_h-target_delay_l));}

/* setCatchFlag
 * If pct (percent of catch trials) is zero, catch trial flag is set to zero
 * If UNI <= pct, catch trial flag is set to one
 * If UNI > pct, catch trial flag is set to zero */
static void setCatchFlag(SimStruct *S, real_T pct)
{
    if (pct == 0)
        ssSetIWorkValue(S, 5, 0);
    else {
      if (UNI <= pct)
          ssSetIWorkValue(S, 5, 1);
      else 
          ssSetIWorkValue(S, 5, 0);
    }
}

/* cursorInTarget
 * returns true (1) if the cursor is in the target and false (0) otherwise
 * cursor is specified as x,y = c[0], c[1]
 * target is specified by two corners: UL: x, y = t[0], t[1]
 *                                     LR: x, y = t[2], t[3]
 */
static int cursorInTarget(real_T *c, real_T *t)
{
    return ( (c[0] > t[0]) && (c[1] < t[1]) && (c[0] < t[2]) && (c[1] > t[3]) );
}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
    /****************
     * Declarations *
     ****************/
    
    /* stupidly declare all variables at the begining of the function */
    int i;
    int j;
    int *IWorkVector; 
    int target_index;
    real_T *RWorkVector;
    real_T *target_list;
    real_T target_x, target_y;
    real_T tgt[4];
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    real_T temp_distance;
    real_T temp_angle;
    byte *databurst;
    float *databurst_offsets;
    float *databurst_target_size;
    float *databurst_target_list;
    int databurst_counter;
    
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int new_state = state;
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];

    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    
    /* current target position */
    IWorkVector = ssGetIWork(S);
    target_index = IWorkVector[1];
    RWorkVector = ssGetRWork(S);
    target_list = RWorkVector+8;
    target_x = target_list[2*target_index];
    target_y = target_list[2*target_index+1];
    
    /* get target bounds */
    tgt[0] = target_x-target_size/2 - target_tolerance/2;
    tgt[1] = target_y+target_size/2 + target_tolerance/2;
    tgt[2] = target_x+target_size/2 + target_tolerance/2;
    tgt[3] = target_y-target_size/2 - target_tolerance/2;
    
    /* databurst pointers */
    databurst_counter = ssGetIWorkValue(S, 6);
    databurst = ssGetPWorkValue(S, 0);
    databurst_offsets = (float *)(databurst + 6);
    databurst_target_size = databurst_offsets + 2;
    databurst_target_list = databurst_target_size + 1;
    
    /*********************************
     * See if we have issued a reset *
     *********************************/
    if (param_master_reset != master_reset) {
        master_reset = param_master_reset;
        ssSetIWorkValue(S, 2, 0);
        ssSetIWorkValue(S, 3, 0);
        ssSetIWorkValue(S, 4, 0);
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
             * Initilize the trial and then advance to CT_ON 
             */
            
            /* Update parameters */
            num_targets = ( param_num_targets > 31 ? 31 : param_num_targets );
            target_size = param_target_size;
            target_tolerance = param_target_tolerance;

            left_target_boundary = param_left_target_boundary;
            right_target_boundary = param_right_target_boundary;
            upper_target_boundary = param_upper_target_boundary;
            lower_target_boundary = param_lower_target_boundary;

            target_hold_l = param_target_hold_l;
            target_hold_h = param_target_hold_h;
            
            target_delay_l = param_target_delay_l;
            target_delay_h = param_target_delay_h;
            
            movement_time = param_movement_time;

            initial_movement_time = param_initial_movement_time;
           
            abort_timeout   = param_intertrial;
            failure_timeout = param_intertrial;
            incomplete_timeout = param_intertrial;
            reward_timeout  = param_intertrial;
                           
            minimum_distance = param_minimum_distance;
            maximum_distance = param_maximum_distance;
            
            percent_catch_trials = param_percent_catch_trials;
			
			disable_abort = (int)param_disable_abort;
			green_hold = (int)param_green_hold;
			cumulative_hold = (int)param_cumulative_hold;
            
            /* initialize target positions */
            if (maximum_distance==0){     /* random positions */
                for (i=0; i<num_targets; i++) {
                    target_list[i*2]   = UNI * (right_target_boundary - left_target_boundary) + left_target_boundary;  /* x position */
                    target_list[i*2+1] = UNI * (upper_target_boundary - lower_target_boundary) + lower_target_boundary; /* y position */
                }
            } else {                      /* semi-random positions with min and max distances */
                for (i=0; i<num_targets; i++){                
                    temp_distance = minimum_distance + UNI * (maximum_distance - minimum_distance);
                    temp_angle = 2 * PI * UNI;
                    for(j=1; j<5; j++){
                        if (i==0){
                            target_list[i*2] = target_list[2*target_index] + temp_distance * cos(temp_angle);  /* x position of first target*/
                            target_list[i*2+1] = target_list[2*target_index+1] + temp_distance * sin(temp_angle); /* y position of first target*/
                        } else {
                            target_list[i*2] = target_list[i*2-2] + temp_distance * cos(temp_angle);
                            target_list[i*2+1] = target_list[i*2-1] + temp_distance * sin(temp_angle);
                        }
                        if(target_list[i*2] > left_target_boundary && target_list[i*2] < right_target_boundary &&
                          target_list[i*2+1] > lower_target_boundary && target_list[i*2+1] < upper_target_boundary){
                            break;
                        }
                        if(j==4){
                            target_list[i*2] = ( right_target_boundary + left_target_boundary )/2; /* place target in center watchdog */
                            target_list[i*2+1] = ( upper_target_boundary + lower_target_boundary )/2;
                            break;
                        }
                        temp_angle = temp_angle + PI/2;
                        temp_distance = minimum_distance;
                    }
                }
            }
            
            /* Copy data into databursts */
            databurst[0] = 6 + 3*sizeof(float) + 2*num_targets*sizeof(float);
            databurst[1] = DATABURST_VERSION;
            databurst[2] = BEHAVIOR_VERSION_MAJOR;
            databurst[3] = BEHAVIOR_VERSION_MINOR;
            databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
            databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            /* The offsets used in the calculation of the cursor location */
            uPtrs = ssGetInputPortRealSignalPtrs(S, 1); 
            databurst_offsets[0] = *uPtrs[0];
            databurst_offsets[1] = *uPtrs[1];
            databurst_target_size[0] = target_size + target_tolerance;
            for (i = 0; i < num_targets * 2; i++) {
                databurst_target_list[i] = (float)ssGetRWorkValue(S, 8 + i);
            }
            
            /* and reset the counters */
            ssSetIWorkValue(S, 1, 0); // Target counter
            ssSetIWorkValue(S, 6, 0); // Databurst counter
            
            /* set flag randomly for first target */ 
            setCatchFlag(S, percent_catch_trials);
            
            new_state = STATE_DATA_BLOCK;

            break;
        case STATE_DATA_BLOCK:
            if (databurst_counter > 2*(databurst[0]-1)) {
                new_state = STATE_INITIAL_MOVEMENT;
                reset_timer(); /* start timer for movement */
                state_changed();
            }
            ssSetIWorkValue(S, 6, databurst_counter+1);
            break;
        case STATE_INITIAL_MOVEMENT:
            /* first target on */
            if (cursorInTarget(cursor, tgt)) {
				ssSetRWorkValue(S, 5, (real_T)(ssGetT(S))); /* stamp time for cumulative hold */
				ssSetRWorkValue(S, 6, 0.0); /* reset cumulative hold time */
                set_random_hold_time();
                new_state = STATE_TARGET_HOLD;
				if (!cumulative_hold) {
					reset_timer(); /* start target hold timer */
				}
                state_changed();
            } else if (elapsed_timer_time > initial_movement_time) {
                new_state = STATE_INCOMPLETE;
                reset_timer(); /* start incomplete timeout */
                state_changed();
            }
            break;
        case STATE_MOVEMENT:
            /* new target on */
            if (cursorInTarget(cursor, tgt) &&
				cumulative_hold) {
				ssSetRWorkValue(S, 5, (real_T)(ssGetT(S))); /* stamp time for cumulative hold */
                new_state = STATE_TARGET_HOLD;
                state_changed();
			} else if (cursorInTarget(cursor, tgt)) {
                new_state = STATE_TARGET_HOLD;
                reset_timer(); /* start target hold timer */
                state_changed();
            } else if (elapsed_timer_time > movement_time) {
                new_state = STATE_FAIL;
                reset_timer(); /* start incomplete timeout */
                state_changed();
            }
            break;
        case STATE_TARGET_HOLD:
            /* dwell time in target */
            /* abort disabled, go back to movement */
            if (cumulative_hold) {
                if (!cursorInTarget(cursor, tgt)) {
					ssSetRWorkValue(S, 6, ssGetRWorkValue(S,6) + (real_T)(ssGetT(S)) - ssGetRWorkValue(S,5)); /* update cumulative hold time */
					new_state = STATE_MOVEMENT;
					state_changed();
				} else if ((ssGetRWorkValue(S,6) + (real_T)(ssGetT(S)) - ssGetRWorkValue(S,5)) > ssGetRWorkValue(S,3)) {
					/* do this if total hold time is greater than required hold time */
					if (target_index == (int)num_targets-1) {
						/* no more targets */
						new_state = STATE_REWARD;
						reset_timer(); /* reward timer */
						state_changed();
					} else {
						/* more targets */
						set_random_delay_time();
						new_state = STATE_TARGET_DELAY;
						reset_timer(); /* delay timer */
						state_changed();
					}
				}
			} else if (!cursorInTarget(cursor, tgt) &&
				disable_abort) {
                new_state = STATE_MOVEMENT;
                reset_timer(); /* abort timeout */
                state_changed();
			} else if (!cursorInTarget(cursor, tgt)) {
				/* abort enabled */
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > ssGetRWorkValue(S,3)) {
                /* next state depends on whether there are more targets */
                if (target_index == (int)num_targets-1) {
					/* no more targets */
					new_state = STATE_REWARD;
					reset_timer(); /* reward timer */
					state_changed();
                } else {
					/* more targets */
					set_random_delay_time();
					new_state = STATE_TARGET_DELAY;
					reset_timer(); /* delay timer */
					state_changed();                
                }
            }
            break;
        case STATE_TARGET_DELAY:
            if (!cursorInTarget(cursor, tgt)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else {
                if (elapsed_timer_time > ssGetRWorkValue(S,4)) {
                    /* start movement to next target */
                    target_index++;
                    ssSetIWorkValue(S, 1, target_index);
                    setCatchFlag(S, percent_catch_trials);  /* set flag randomly for next target */ 
					ssSetRWorkValue(S, 6, 0.0); /* reset cumulative hold time for next target */
					set_random_hold_time(); /* for next hold period */
                    new_state = STATE_MOVEMENT;
                    reset_timer(); /* movement timer */
                    state_changed();
                }
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
        case STATE_INCOMPLETE:
            /* incomplete */
            if (elapsed_timer_time > incomplete_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
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
    int_T *IWorkVector;
    real_T *RWorkVector;
    int_T target_index;
    int_T catch_trial_flag;
    real_T *target_list;
    real_T target_x, target_y;
    real_T next_target_x, next_target_y;
    real_T tgt[4];
    real_T disp_tgt[4];
    real_T next_tgt[4];
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T force_in[2];
    real_T force_in_catch[2];
    
    /* databurst */
    byte* databurst;
    int databurst_counter;
    
    /* allocate holders for outputs */
    real_T force_x, force_y, word, reward, tone_cnt, tone_id, pos_x, pos_y;
    real_T target_pos[10];
    real_T status[4];
    real_T version[4];
    
    /* pointers to output buffers */
    real_T *force_p;
    real_T *word_p;
    real_T *target_p;
    real_T *status_p;
    real_T *reward_p;
    real_T *tone_p;
    real_T *version_p;
    real_T *pos_p;
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)(state_r[0]);
    int new_state = ssGetIWorkValue(S, 0);
    ssSetIWorkValue(S, 0, 0); /* reset changed state each iteration */

    /* target position */
    IWorkVector = ssGetIWork(S);
    target_index = IWorkVector[1];
    RWorkVector = ssGetRWork(S);
    target_list = RWorkVector+8;
    target_x = target_list[2*target_index];
    target_y = target_list[2*target_index+1];
    
    /* catch trial flag */
    catch_trial_flag = IWorkVector[5];
    
    /* get current tone counter */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);
    
    /* get target bounds */
    tgt[0] = target_x-target_size/2 - target_tolerance/2;
    tgt[1] = target_y+target_size/2 + target_tolerance/2;
    tgt[2] = target_x+target_size/2 + target_tolerance/2;
    tgt[3] = target_y-target_size/2 - target_tolerance/2;    
    
    disp_tgt[0] = target_x-target_size/2;
    disp_tgt[1] = target_y+target_size/2;
    disp_tgt[2] = target_x+target_size/2;
    disp_tgt[3] = target_y-target_size/2; 
    
    if (target_index < (int)num_targets) {
        next_target_x = target_list[2*(target_index+1)];
        next_target_y = target_list[2*(target_index+1)+1];
        
        /* Only care about the displayed target -- ignore tolerances */
        next_tgt[0] = next_target_x-target_size/2;
        next_tgt[1] = next_target_y+target_size/2;
        next_tgt[2] = next_target_x+target_size/2;
        next_tgt[3] = next_target_y-target_size/2;
    }
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    force_in[0] = *uPtrs[0];
    force_in[1] = *uPtrs[1];
    
    /* catch input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 3);
    force_in_catch[0] = *uPtrs[0];
    force_in_catch[1] = *uPtrs[1];
    
    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 6);
    databurst = (byte *)ssGetPWorkValue(S, 0);
    
    /********************
     * Calculate outputs
     ********************/
    
    /* force (0) */
    if (catch_trial_flag){
        force_x = force_in_catch[0]; 
        force_y = force_in_catch[1]; 
    } else {
        force_x = force_in[0]; 
        force_y = force_in[1]; 
    }
  
    /* status (1) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S, 2, ssGetIWorkValue(S, 2)+1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, 3, ssGetIWorkValue(S, 3)+1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, 4, ssGetIWorkValue(S, 4)+1);
    
    status[0] = state;
    status[1] = ssGetIWorkValue(S, 2); // num rewards
    status[2] = ssGetIWorkValue(S, 3); // num aborts
    status[3] = ssGetIWorkValue(S, 4); // num fails
    
    /* word (2) */
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
            case STATE_INITIAL_MOVEMENT:
                if (catch_trial_flag) {
                    word = WORD_CATCH;
                } else {
                    word = WORD_GO_CUE;
                }
				break;
			case STATE_TARGET_HOLD:
				word = WORD_TARGET_HOLD;
				break;
            case STATE_MOVEMENT:
                if (catch_trial_flag) {
                    word = WORD_CATCH;
                } else {
                    word = WORD_GO_CUE;
                }
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
            default:
                word = 0;
        }
    } else {
        /* not a new state */
        word = 0;
    }
    
    /* target_pos (3) */
    if (state == STATE_TARGET_HOLD &&
		green_hold) {
        /* target green */
        target_pos[0] = 3;
        for (i=0; i<4; i++) {
            target_pos[i+1] = disp_tgt[i];
        }
	} else if (state == STATE_INITIAL_MOVEMENT || 
			   state == STATE_MOVEMENT || 
			   state == STATE_TARGET_HOLD ||
			   state == STATE_TARGET_DELAY) {
        /* target red */
        target_pos[0] = 1;
        for (i=0; i<4; i++) {
            target_pos[i+1] = disp_tgt[i];
        }
	} else {
        /* target off */
        target_pos[0] = 0;
        for (i=0; i<4; i++) {
            target_pos[i+1] = 0;
        }
    }
    
    /* the upcoming target */
    if ( state == STATE_TARGET_DELAY ) {
        target_pos[5] = 1;
        for (i=0; i<4; i++) {
            target_pos[i+6] = next_tgt[i];
        }
    } else {
        /* upcoming target is off */
        target_pos[5] = 0;
        for (i=0; i<4; i++) {
            target_pos[i+6] = 0;
        }
    }
    
        
    /* reward (4) */
    if (new_state && state==STATE_REWARD) {
        reward = 1;
    } else {
        reward = 0;
    }

    /* tone (5) */
    if (new_state) {
        if (state == STATE_ABORT) {
            tone_cnt++;
            tone_id = TONE_ABORT;
        } else if (state == STATE_MOVEMENT &&
			ssGetRWorkValue(S, 6) == 0.0) {
            tone_cnt++;
            tone_id = TONE_GO;
        } else if (state == STATE_REWARD) {
            tone_cnt++;
            tone_id = TONE_REWARD;
        }
    }
        
    /* version (6) */
    version[0] = BEHAVIOR_VERSION_MAJOR;
    version[1] = BEHAVIOR_VERSION_MINOR;
    version[2] = BEHAVIOR_VERSION_MICRO;
    version[3] = BEHAVIOR_VERSION_BUILD;

    /* pos (7) */
    pos_x = cursor[0];
    pos_y = cursor[1];
    
    /**********************************
     * Write outputs back to SimStruct
     **********************************/
    force_p = ssGetOutputPortRealSignal(S,0);
    force_p[0] = force_x;
    force_p[1] = force_y;
    
    status_p = ssGetOutputPortRealSignal(S,1);
    for (i=0; i<4; i++) 
        status_p[i] = status[i];
    
    word_p = ssGetOutputPortRealSignal(S,2);
    word_p[0] = word;
    
    target_p = ssGetOutputPortRealSignal(S,3);
    for (i=0; i<10; i++) {
        target_p[i] = target_pos[i];
    }
    
    reward_p = ssGetOutputPortRealSignal(S,4);
    reward_p[0] = reward;
    
    tone_p = ssGetOutputPortRealSignal(S,5);
    tone_p[0] = tone_cnt;
    tone_p[1] = tone_id;
    ssSetRWorkValue(S, 1, tone_cnt);
    ssSetRWorkValue(S, 2, tone_id);

    version_p = ssGetOutputPortRealSignal(S,6);
    for (i=0; i<4; i++) {
        version_p[i] = version[i];
    }
        
    pos_p = ssGetOutputPortRealSignal(S,7);
    pos_p[0] = pos_x;
    pos_p[1] = pos_y;
    
    UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif

