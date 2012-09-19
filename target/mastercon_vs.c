/* $Id: mastercon_vs.c 851 2012-04-04 22:52:59Z brian $
 *
 * Master Control block for behavior: center-out task 
 */
#define S_FUNCTION_NAME mastercon_vs
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "simstruc.h"
#include "random_macros.h"

#define TASK_VS 1
#include "words.h"


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
 * Version 1 (0x01)
 * ----------------
 *
 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case one)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 * bytes  6 to  9: float => x offset
 * bytes 10 to 13: float => y offset
 * byte  14: int => number of targets
 * bytes 15 to 18: float => target radius
 * byte  19: int => target index
 * bytes 20 to 23: float => target size
 * bytes 24 to 27: float => target x position
 * bytes 28 to 31: float => target y position
 *
 */

typedef real_T target[4];
typedef unsigned char byte;
#define DATABURST_VERSION (0x01) 

#define PI (3.141592654)

/*
 * Until we implement tunable parameters, these will act as defaults
 */
static int num_targets = 6;      /* number of peripheral targets */
#define param_num_targets ((int)mxGetScalar(ssGetSFcnParam(S,0)))
static real_T target_radius = 15.0; /* radius of target circle in cm */
#define param_target_radius mxGetScalar(ssGetSFcnParam(S,1))
static real_T target_size = 5.0;    /* width and height of targets in cm */
#define param_target_size mxGetScalar(ssGetSFcnParam(S,2))

static int num_glyphs = 2;    /* total number of glyphs to select from */
#define param_num_glyphs ((int)mxGetScalar(ssGetSFcnParam(S,3)))

static real_T center_hold;     /* dwell time in state 2 */
static real_T center_hold_l = .5;     
#define param_center_hold_l mxGetScalar(ssGetSFcnParam(S,4))
static real_T center_hold_h = 2.0;     
#define param_center_hold_h mxGetScalar(ssGetSFcnParam(S,5))

static real_T search_delay = 5.0; /*max time monkey can spend searching while in CT*/
#define param_search_delay mxGetScalar(ssGetSFcnParam(S,6))

static real_T reach_time = 10.0;  /* movement time */
#define param_reach_time mxGetScalar(ssGetSFcnParam(S,7))

static real_T outer_hold;      /* outer target hold time */
static real_T outer_hold_l = 1.0;      
#define param_outer_hold_l mxGetScalar(ssGetSFcnParam(S,8))
static real_T outer_hold_h = 1.0; 
#define param_outer_hold_h mxGetScalar(ssGetSFcnParam(S,9))

static real_T abort_timeout   = 1.0;    /* delay after abort */
#define param_abort_timeout mxGetScalar(ssGetSFcnParam(S,10))
static real_T failure_timeout = 1.0;    /* delay after failure */
#define param_failure_timeout mxGetScalar(ssGetSFcnParam(S,11))
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
#define param_incomplete_timeout mxGetScalar(ssGetSFcnParam(S,12))
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */
#define param_reward_timeout mxGetScalar(ssGetSFcnParam(S,13))

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,14))

#define param_disable_abort mxGetScalar(ssGetSFcnParam(S,15))
static int disable_abort = 0;

#define param_green_hold mxGetScalar(ssGetSFcnParam(S,16))
static int green_hold = 0;

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_CT_ON 1
#define STATE_CENTER_HOLD 2
#define STATE_OT_ON 3
#define STATE_REACH 4
#define STATE_OUTER_HOLD 5
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3

static void mdlCheckParameters(SimStruct *S)
{
    num_targets = param_num_targets;
    target_radius = param_target_radius;
    target_size = param_target_size;

    num_glyphs = param_num_glyphs;
    center_hold_l = param_center_hold_l;
    center_hold_h = param_center_hold_h;

    search_delay = param_search_delay;

    reach_time = param_reach_time;

    outer_hold_l = param_outer_hold_l;
    outer_hold_h = param_outer_hold_h;

    abort_timeout   = param_abort_timeout;    
    failure_timeout = param_failure_timeout;
    reward_timeout  = param_reward_timeout;   
    incomplete_timeout = param_incomplete_timeout;
    
    master_reset = param_master_reset;

	disable_abort = (int)param_disable_abort;
	green_hold = (int)param_green_hold;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 17); 
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
	 *      input port 1: (position offsets) of width 2 (x, y)
     *      input port 2: (force) of width 2 (x, y)
     *      input port 3: (catch force) of width 2 (x, y)
     */
    if (!ssSetNumInputPorts(S, 4)) return;
    ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortWidth(S, 1, 2);
    ssSetInputPortWidth(S, 2, 2);
    ssSetInputPortWidth(S, 3, 2);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    
    /* 
     * Block has 8 output ports (force, status, word, targets, reward, tone, version, pos) of widths:
     *  force: 2
     *  status: 5 ( block counter, successes, aborts, failures, incompletes )
     *  word:  1 (8 bits)
     *  target: 85 ( center target, then peripheral targets clockwise from top: 
     *                  appearance (visible, color, etc), 
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
    ssSetOutputPortWidth(S, 3, 85);  /* target  */
    ssSetOutputPortWidth(S, 4, 1);   /* reward  */
    ssSetOutputPortWidth(S, 5, 2);   /* tone    */
    ssSetOutputPortWidth(S, 6, 4);   /* version */
    ssSetOutputPortWidth(S, 7, 2);   /* pos     */
    
    ssSetNumSampleTimes(S, 1);
    
    /* work buffers */
    ssSetNumRWork(S, 6);  /* 0: time of last timer reset 
                             1: tone counter (incremented each time a tone is played)
                             2: tone id
                             3: center hold
                             4: outer hold
                             5: mastercon version
                           */
    ssSetNumPWork(S, 0);
    ssSetNumIWork(S, 11);    /* 0: state_transition (true if state changed), 
                                1: successes
                                2: failures
                                3: aborts 
                                4: incompletes 
                                5: databurst_counter
                                6: target index
                                7: center target type
                                8: correct target type
                                9: distractor target type
								10: index of target cursor is in
                             */
    
    ssSetNumPWork(S, 3);  /* 0: Databurst array pointer  
                             1: target_type array pointer
                             2: target_location array pointer  
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
    real_T *x0;
	byte *databurst;
    int *target_type;
    target *target_location;
    
    
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
    
    /* set target types */
    ssSetIWorkValue(S, 7, 16);  /* center target appearance = same as correct target */
    ssSetIWorkValue(S, 8, 16);  /* correct gabor wavelet    */
    ssSetIWorkValue(S, 9, 17);  /* distractor gabor wavelet */

	/* set up databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 6, 0);
    
    /* set up pointers to target arrays */
    target_type = malloc(17*sizeof(int));   
    ssSetPWorkValue(S, 1, target_type); 
    target_location = malloc(17*sizeof(target));
    ssSetPWorkValue(S, 2, target_location);   

}

/* macro for setting state changed */
#define state_changed() (ssSetIWorkValue(S, 0, 1))
/* macro for resetting timer */
#define reset_timer() (ssSetRWorkValue(S, 0, (real_T)ssGetT(S)))

/* cursorInTarget
 * returns true (1) if the cursor is in the target and false (0) otherwise
 * cursor is specified as x,y = c[0], c[1]
 * target is specified by two corners: UL: x, y = t[0], t[1]
 *                                     LR: x, y = t[2], t[3]
 */
static int cursorInTarget(real_T *c, target t)
{
    return ( (c[0] > t[0]) && (c[1] < t[1]) && (c[0] < t[2]) && (c[1] > t[3]) );
}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
    /********************
     * Declarations     *
     ********************/
    
    /* stupidly declare all variables at the begining of the function */
    int target_idx;
    int starting_targ;
    int center_targ;
    int correct_targ;
    int distractor_targ;
    
    int *target_type;        /* values in array determine type of each target */    
    target *target_location; /* contains 4-value arrays of coordinates for each target */
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    real_T theta;
    real_T center_hold, outer_hold;
    int i;

    int databurst_counter;
    byte *databurst;
    float *databurst_offsets;
    int *databurst_num_targets;
    float *databurst_target_radius;
    int *databurst_target_idx;
    float *databurst_target_size;
    float *databurst_target_position;
    
       
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int new_state = state;
    
    /* default state changed to zero */
    ssSetIWorkValue(S, 0, 0);
   
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];

    /* random timers */
    center_hold = ssGetRWorkValue(S, 3);
    outer_hold = ssGetRWorkValue(S, 4);
    
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
 
    /* get target index */
    target_idx = ssGetIWorkValue(S, 6);
    
    /* get target type values */
    center_targ     = ssGetIWorkValue(S, 7);
    correct_targ    = ssGetIWorkValue(S, 8);
    distractor_targ = ssGetIWorkValue(S, 9);
    
    /* get pointers to target types and locations*/
    target_type=ssGetPWorkValue(S,1); 
    target_location=ssGetPWorkValue(S,2); 
    
    databurst = ssGetPWorkValue(S,0);
    databurst_offsets = (float *)(databurst + 6);
    databurst_num_targets = (int *)(databurst_offsets + 2);
    databurst_target_radius = (float *)(databurst_num_targets + 1);
    databurst_target_idx = (int *)(databurst_target_radius + 1);
    databurst_target_size = (float *)(databurst_target_idx + 1);
    databurst_target_position = (float *)(databurst_target_size + 1);
    databurst_counter = ssGetIWorkValue(S, 5);
     
    /*********************************
     * See if we have issued a reset *
     *********************************/
    if (param_master_reset != master_reset) {
        master_reset = param_master_reset;
        ssSetIWorkValue(S, 1, 0);
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
            
            /* update parameters */
            num_targets = param_num_targets;
            target_radius = param_target_radius;
            target_size = param_target_size;

            num_glyphs = param_num_glyphs;
            center_hold_l = param_center_hold_l;
            center_hold_h = param_center_hold_h;

            search_delay = param_search_delay;

            reach_time = param_reach_time;

            outer_hold_l = param_outer_hold_l;
            outer_hold_h = param_outer_hold_h;

            abort_timeout   = param_abort_timeout;    
            failure_timeout = param_failure_timeout;
            reward_timeout  = param_reward_timeout;   
            incomplete_timeout = param_incomplete_timeout;
            
			disable_abort = (int)param_disable_abort;
			green_hold = (int)param_green_hold;

			/* Set target locations */
            target_location[0][0]= -target_size/2;
            target_location[0][1]=  target_size/2;
            target_location[0][2]=  target_size/2;
            target_location[0][3]= -target_size/2;
   
            for (i=0; i < num_targets; i++) {                                       //change to num_positions
                theta = PI/2 - i*2*PI/num_targets;                                  //change to num_positions
                target_location[i+1][0]=  cos(theta)*target_radius-target_size/2;
                target_location[i+1][1]=  sin(theta)*target_radius+target_size/2;
                target_location[i+1][2]=  cos(theta)*target_radius+target_size/2;
                target_location[i+1][3]=  sin(theta)*target_radius-target_size/2;
            }

            /* Set target types */
            starting_targ = (int)(UNI * num_targets);                               //change to num_positions
            ssSetIWorkValue(S, 6,  ((int)(UNI * (num_targets ) + starting_targ) % num_targets));//change last one to num_positions
                                  
            for (i=0; i<17; i++){ 
                target_type[i]=0; 
            } 
            target_type[0] = center_targ;         
            for (i=0; i<num_targets; i++){          
                target_type[(starting_targ+i) % num_targets + 1] = distractor_targ; //change to num_positions
            }
            target_type[ssGetIWorkValue(S,6)+1] = correct_targ; 
            
            
            /* Decide on the random timer durations */
            if (center_hold_h == center_hold_l) {
                center_hold = center_hold_h;
            } else {
                center_hold = center_hold_l + (center_hold_h - center_hold_l)*((double)rand())/((double)RAND_MAX);
            }
            ssSetRWorkValue(S, 3, center_hold);
            
            if (outer_hold_h == outer_hold_l) {
                outer_hold = outer_hold_h;
            } else {
                outer_hold = outer_hold_l + (outer_hold_h - outer_hold_l)*((double)rand())/((double)RAND_MAX);
            }
            ssSetRWorkValue(S, 4, outer_hold);
            
			
            /* Setup the databurst */
            databurst[0] = 6+2*sizeof(float)+1+sizeof(float)+1+3*sizeof(float); /* add sizes of each databurst component */
            databurst[1] = DATABURST_VERSION;
            databurst[2] = BEHAVIOR_VERSION_MAJOR;
            databurst[3] = BEHAVIOR_VERSION_MINOR;
            databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
            databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            /* The offsets used in the calculation of the cursor location */
            uPtrs = ssGetInputPortRealSignalPtrs(S, 1); 
            databurst_offsets[0] = *uPtrs[0];
            databurst_offsets[1] = *uPtrs[1];
            /* The number of targets */
            databurst_num_targets[0] = num_targets;
            /* The target radius */
            databurst_target_radius[0] = target_radius;
            /* The target index */
            databurst_target_idx[0] = ssGetIWorkValue(S, 6);
            /* The target size */
            databurst_target_size[0] = target_size;
            /* The target position */
            databurst_target_position[0] = target_location[ssGetIWorkValue(S,6)+1][0]+target_size/2;
            databurst_target_position[1] = target_location[ssGetIWorkValue(S,6)+1][3]+target_size/2;
                    
            /* reset counter */
            ssSetIWorkValue(S, 5, 0); /* reset the databurst_counter */

            /* and advance */
            new_state = STATE_DATA_BLOCK;
            state_changed();

            break;
        case STATE_DATA_BLOCK:
            if (databurst_counter > 2*(databurst[0]-1)) { 
                new_state = STATE_CT_ON;
                state_changed();
            }
            ssSetIWorkValue(S, 5, databurst_counter+1);
            
            break;
        case STATE_CT_ON:
            /* center target on */
            if (cursorInTarget(cursor, target_location[0])) {
                new_state = STATE_CENTER_HOLD;
				reset_timer(); /* start center hold timer */
                state_changed();
            }
            break;
        case STATE_CENTER_HOLD:
            /* center hold */
			if (elapsed_timer_time > center_hold) {
                new_state = STATE_OT_ON;
                reset_timer(); /* start search timer */
                state_changed();
            } else if (!cursorInTarget(cursor, target_location[0])) {
				if (disable_abort) {
	                new_state = STATE_CT_ON;
		            state_changed();
				}
				else {
			        new_state = STATE_ABORT;
				    reset_timer(); /* abort timeout */
					state_changed();
				}
            }
            break;
        case STATE_OT_ON:
            /* outer targets appear */
             if (elapsed_timer_time > search_delay) {
                new_state = STATE_INCOMPLETE;
                reset_timer(); /* incomplete timeout */
                state_changed();
             } else if (!cursorInTarget(cursor, target_location[0])) {
                new_state = STATE_REACH;
                reset_timer(); /* start reach timer */
                state_changed();
             }
             break;
       case STATE_REACH:
            /* cursor has left center target */
            if (elapsed_timer_time > reach_time) {
                new_state = STATE_INCOMPLETE;
                reset_timer(); /* incomplete timeout */
                state_changed();   
            } else {
                for (i=1; i<17; i++) {                           
                    if (cursorInTarget(cursor, target_location[i])) {
						ssSetIWorkValue(S, 10, i); /* set index of target cursor is in */
                        if ((target_type[i] == correct_targ) || disable_abort) {
                            new_state = STATE_OUTER_HOLD;
                            reset_timer(); /* start hold timer */
                            state_changed();
                        } else if (target_type[i] == distractor_targ) {
                            new_state = STATE_FAIL;
                            reset_timer();
                            state_changed();
                        }
                    }
                }
            }
            break;
        case STATE_OUTER_HOLD:
            /* hold cursor in outer target */
            if (elapsed_timer_time > outer_hold) {
				if (target_type[ssGetIWorkValue(S,10)] == correct_targ)
					new_state = STATE_REWARD;
				else
					new_state = STATE_FAIL;
                reset_timer();
                state_changed();
            } else if (!cursorInTarget(cursor, target_location[ssGetIWorkValue(S,10)])) {
                if (disable_abort) {
                    new_state = STATE_REACH;
                    reset_timer();
                    state_changed();
                } else {
                    new_state = STATE_INCOMPLETE;
                    reset_timer();
                    state_changed();
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
    }

    /***********
     * Cleanup *
     ***********/
    
    /* write back new state */
    state_r[0] = new_state;
    
    UNUSED_ARG(tid);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /********************
     *  Initialization
     ********************/
    int *IWorkVector; 
    int target_idx;
    int *target_type;
    target *target_location;
    real_T elapsed_timer_time;
    real_T theta;
    real_T center_hold, outer_hold;
    int i,j;
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T force_in[2];
    real_T catch_force_in[2];
    
    /* allocate holders for outputs */
    real_T force_x, force_y, word, reward, tone_cnt, tone_id, pos_x, pos_y;
    real_T target_pos[85];
    real_T status[5];
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
    
	int databurst_counter;
	byte *databurst;

    
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int new_state = ssGetIWorkValue(S, 0);
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];

    /* random timers */
    center_hold = ssGetRWorkValue(S, 3);
    outer_hold = ssGetRWorkValue(S, 4);

    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    
    /* get target index */
    target_idx=ssGetIWorkValue(S, 6);
    
    /* get target types and locations*/
    target_type=ssGetPWorkValue(S,1);
    target_location=ssGetPWorkValue(S,2);
   
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    force_in[0] = *uPtrs[0];
    force_in[1] = *uPtrs[1];
    
    /* input catch force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 3);
    catch_force_in[0] = *uPtrs[0];
    catch_force_in[1] = *uPtrs[1];
    
    /* current tone values */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);

    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 5);
    databurst = (byte *)ssGetPWorkValue(S, 0);
    
    /********************
     * Calculate outputs
     ********************/
    
    /* force (0) */
    force_x = force_in[0]; 
    force_y = force_in[1];

    /* status (1) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S, 1, ssGetIWorkValue(S, 1)+1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, 2, ssGetIWorkValue(S, 2)+1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, 3, ssGetIWorkValue(S, 3)+1);
    if (state == STATE_INCOMPLETE && new_state)
        ssSetIWorkValue(S, 4, ssGetIWorkValue(S, 4)+1);
       
    
    status[0] = state;
    status[1] = ssGetIWorkValue(S, 1); /* num rewards     */
    status[2] = ssGetIWorkValue(S, 2); /* num aborts      */
    status[3] = ssGetIWorkValue(S, 3); /* num fails       */
    status[4] = ssGetIWorkValue(S, 4); /* num incompletes */
    
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
            case STATE_CT_ON:
                word = WORD_CT_ON;
                break;
            case STATE_CENTER_HOLD:
                word = WORD_CENTER_TARGET_HOLD;
                break;
            case STATE_OT_ON:
                word = WORD_OT_ON(target_idx);
                break;
            case STATE_REACH:
                word = WORD_MOVEMENT_ONSET;
                break;
            case STATE_OUTER_HOLD:
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
            case STATE_INCOMPLETE:
                word = WORD_INCOMPLETE;
                break;
            default:
                word = 0;
        }    
    } else {
        /*not a new state*/
        word = 0; 
    }
    
    
    /* target_pos (3) */
    for(i=0; i<85; i++){
        target_pos[i] = 0;
    }
    /* center  target on */
	if ( (state == STATE_CENTER_HOLD ||
          state == STATE_OT_ON) &&
		  green_hold ) 
    {
            target_pos[0]=3;
            target_pos[1]=target_location[0][0];
            target_pos[2]=target_location[0][1];
            target_pos[3]=target_location[0][2];
            target_pos[4]=target_location[0][3]; 
			
    }
	else if ( state == STATE_CT_ON ||
              state == STATE_CENTER_HOLD ||
              state == STATE_OT_ON ) 
    {
            target_pos[0]=target_type[0];
            target_pos[1]=target_location[0][0];
            target_pos[2]=target_location[0][1];
            target_pos[3]=target_location[0][2];
            target_pos[4]=target_location[0][3]; 
			
    }
    /* outer targets on */
    if ( state == STATE_OT_ON ||
         state == STATE_REACH ||
         state == STATE_OUTER_HOLD ) 
    {
        j=5;
        for (i=1; i<17; i++){
            if (target_type[i] != 0){
				if ( state == STATE_OUTER_HOLD &&
                     ssGetIWorkValue(S, 10) == (target_idx + 1) &&
                     i == (target_idx + 1) &&
					 green_hold )
					target_pos[j]=3;
				else
	                target_pos[j]=target_type[i];
                target_pos[j+1]=target_location[i][0];
                target_pos[j+2]=target_location[i][1];
                target_pos[j+3]=target_location[i][2];
                target_pos[j+4]=target_location[i][3]; 
                j=j+5;
            }
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
        } else if (state == STATE_FAIL) {
            tone_cnt++;
            tone_id = TONE_ABORT;
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
    for (i=0; i<5; i++) 
        status_p[i] = status[i];
    
    word_p = ssGetOutputPortRealSignal(S,2);
    word_p[0] = word;
    
    target_p = ssGetOutputPortRealSignal(S,3);
    for (i=0; i<85; i++) {
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

static void mdlTerminate (SimStruct *S) { 
    free(ssGetPWorkValue(S,0));
    free(ssGetPWorkValue(S,1));
    free(ssGetPWorkValue(S,2));
}

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif
