/* $Id: mastercon_bs.c 842 2012-03-29 21:11:35Z brian $
 * 
 * Master Control block for behavior: bump-stim task
 */

static int last_word = 0; /*** HACK ***/

#define S_FUNCTION_NAME mastercon_bs
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "simstruc.h"

#define TASK_BS 1
#include "words.h"
#include "random_macros.h"

#define PI (3.141592654)

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
 * bytes 2-5: float => origin target x position (cm)
 * bytes 6-9: float => origin target y position (cm)
 * bytes 10-13: float => destination target x position (cm)
 * bytes 14-17: float => destination target y position (cm)
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
 * bytes 14 to 17: float => origin target x position (cm)
 * bytes 18 to 21: float => origin target y position (cm)
 * bytes 22 to 25: float => destination target x position (cm)
 * bytes 26 to 29: float => destination target y position (cm)
 */

typedef unsigned char byte;
#define DATABURST_VERSION ((byte)0x01) 


/*
 * Until we implement tunable parameters, these will act as defaults
 */
static real_T req_target_angle = 0; /* requested angle at which targets appear */
#define param_req_target_angle mxGetScalar(ssGetSFcnParam(S,0))
static real_T target_radius = 15.0; /* radius of target circle in cm */
#define param_target_radius mxGetScalar(ssGetSFcnParam(S,1))
static real_T target_size = 5.0;    /* width and height of targets in cm */
#define param_target_size mxGetScalar(ssGetSFcnParam(S,2))
static real_T window_size = 10.0;   /* diameter of blocking circle */
#define param_window_size mxGetScalar(ssGetSFcnParam(S,3))

/*
 * Trial type nomenclature:
 *
 * All trials consist of two targets, "target 1" (T1) and "target 2" (T2)
 * T1 is always positioned on the target_radius circle at an angle of target_angle from the x axis (monkey right)
 * T2 is always positioned on the target_radius circle at an angle of target_angle + 180 degrees
 *
 * Trials are divided into "forward" (Movement is from T1 to T2) and "reverse" (T2 to T1) trials
 * 
 * Within a trial targets may be referred to as "origin" or "destination".  Thus, in a forward trial T1 is the origin
 * and T2 is the destination.  In a reverse trial T2 is the origin and T1 is the destination.
 */

static real_T origin_hold;     /* dwell time in state 2 */
static real_T origin_hold_l = .5;     
#define param_origin_hold_l mxGetScalar(ssGetSFcnParam(S,4))
static real_T origin_hold_h = 2.0;     
#define param_origin_hold_h mxGetScalar(ssGetSFcnParam(S,5))

static real_T origin_delay;     /* delay between destination target and go tone */
static real_T origin_delay_l = 0.0;
#define param_origin_delay_l mxGetScalar(ssGetSFcnParam(S,6))
static real_T origin_delay_h = 0.0;
#define param_origin_delay_h mxGetScalar(ssGetSFcnParam(S,7))

static real_T movement_time = 1.0;  /* movement time */
#define param_movement_time mxGetScalar(ssGetSFcnParam(S,8))

static real_T destination_hold;      /* destination target hold time */
static real_T destination_hold_l = 1.0;      
#define param_destination_hold_l mxGetScalar(ssGetSFcnParam(S,9))
static real_T destination_hold_h = 1.0; 
#define param_destination_hold_h mxGetScalar(ssGetSFcnParam(S,10))

#define param_intertrial mxGetScalar(ssGetSFcnParam(S,11))
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T failure_timeout = 1.0;    /* delay after failure */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */

#define param_stim_trial_pct mxGetScalar(ssGetSFcnParam(S,12))
static real_T stim_trial_pct = 0.0; /* percent of trials in which we stimulate */

#define param_bump_trial_pct mxGetScalar(ssGetSFcnParam(S,13))
static real_T bump_trial_pct = 0.0; /* percent of trials in which we bump */

#define param_bump_magnitude mxGetScalar(ssGetSFcnParam(S,14))
static real_T bump_magnitude;

#define param_bump_duration mxGetScalar(ssGetSFcnParam(S,15))
static real_T bump_duration;

#define param_bump_steps ((int)(mxGetScalar(ssGetSFcnParam(S,16))) <= 7 ? (int)(mxGetScalar(ssGetSFcnParam(S,16))) : 7)
static int bump_steps;

#define param_stim_steps ((int)(mxGetScalar(ssGetSFcnParam(S,17))) <= 7 ? (int)(mxGetScalar(ssGetSFcnParam(S,17))) : 7)
static int stim_steps;

#define param_num_targets_per_angle ((int)(mxGetScalar(ssGetSFcnParam(S,18))))
static int num_targets_per_angle;

#define param_bump_displacement_gain mxGetScalar(ssGetSFcnParam(S,21))
static real_T bump_displacement_gain;

#define param_stim_displacement_gain mxGetScalar(ssGetSFcnParam(S,22))
static real_T stim_displacement_gain;

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,19))

#define param_num_target_locations ( ( \
    (int)(mxGetScalar(ssGetSFcnParam(S,20))) <= 0 ? 0 : ( \
        ((int)(mxGetScalar(ssGetSFcnParam(S,20))) % 2 == 0) ? \
            (int)(mxGetScalar(ssGetSFcnParam(S,20))) : \
            (int)(mxGetScalar(ssGetSFcnParam(S,20)))*2 )))
static int num_target_locations;

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_ORIGIN_ON 1
#define STATE_ORIGIN_HOLD 2
#define STATE_ORIGIN_DELAY 3
#define STATE_MOVEMENT 4
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3
#define TONE_MASK 5

#define DIRECTION_FORWARD 0
#define DIRECTION_REVERSE 1

static void mdlCheckParameters(SimStruct *S)
{
    bump_steps = (int)param_bump_steps;
    stim_steps = (int)param_stim_steps;
    bump_magnitude = param_bump_magnitude;
    bump_duration = param_bump_duration;
    stim_trial_pct = param_stim_trial_pct;
    bump_trial_pct = param_bump_trial_pct;
    bump_displacement_gain = param_bump_displacement_gain;
    stim_displacement_gain = param_stim_displacement_gain;

    req_target_angle = param_req_target_angle;
    num_targets_per_angle = param_num_targets_per_angle;
    target_radius = param_target_radius;
    target_size = param_target_size;
    window_size = param_window_size;
    
    num_target_locations = param_num_target_locations;
    
    origin_hold_l = param_origin_hold_l;
    origin_hold_h = param_origin_hold_h;

    origin_delay_l = param_origin_delay_l;
    origin_delay_h = param_origin_delay_h;

    movement_time = param_movement_time;

    destination_hold_l = param_destination_hold_l;
    destination_hold_h = param_destination_hold_h;

    abort_timeout   = param_intertrial;    
    failure_timeout = param_intertrial;
    reward_timeout  = param_intertrial;   
    incomplete_timeout = param_intertrial;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 23); 
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
    for (i=0; i<ssGetNumSFcnParams(S); i++)
        ssSetSFcnParamTunable(S,i, 1);
    mdlCheckParameters(S);
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 2); /* First state is the state machine state (as in all other behavior controls.
							   * Second state is 0: forward trial. 1: reverse trial. */
    
    /*
     * Block has 4 input ports
     *      input port 0: (position) of width 2 (x, y)
	 *      input port 1: (pos offsets) of width 2 (x, y)
     *      input port 2: (force) of width 2 (x, y)
     *      input port 3: (catch force) of width 2 (x, y) NOT USED
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
    ssSetNumRWork(S, 6);  /* 0: time of last timer reset 
                             1: tone counter (incremented each time a tone is played)
                             2: tone id
                             3: target angle
                             4: fixed x position
                             5: fixed y position
                           */
    ssSetNumPWork(S, 1);  /* 0: pointer to databurst array
                           */
    ssSetNumIWork(S, 75);  /*    0: state_transition (true if state changed), 
                                 1: current bump index,
                                 2: current stim index,
		                         3: bump trial (1 for yes, 0 for no)
                                 4: stimulation flag 0=not stimulating -1=stim started 1=stimulate
                            [5-21]: bump presentation sequence
                           [22-38]: stim presentation sequence
                                67: bump duration counter
                                68: successes
                                69: failures
                                70: aborts 
                                71: incompletes 
                                72: counter for targets at a given angle 
                                73: masking noise flag 0=not played -1=started playing 1=start playing
                                74: databurst counter
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
    real_T *x0;
    int *databurst;
    
    /* initialize state to zero */
    x0 = ssGetRealDiscStates(S);
    x0[0] = 0.0; /* state-machine state */
    x0[1] = 0.0; /* begin with forward trial */
    
    /* notify that we just entered this state */
    ssSetIWorkValue(S, 0, 1);
    
    /* set stim and bump indicese to force a reset of the condition blocks */
    ssSetIWorkValue(S, 1, -1);
    ssSetIWorkValue(S, 2, -1);
    
    /* initilize the value of target angle to the parameter */
    ssSetRWorkValue(S, 3, param_req_target_angle);
    
    /* set the tone counter to zero */
    ssSetRWorkValue(S, 1, 0.0);
    
    /* give arbitrary value to fixed position */
    ssSetRWorkValue(S, 4, 0.0);
    ssSetRWorkValue(S, 5, 0.0);
        
    /* set trial counters to zero */
    for (i = 68; i<=72; i++)
      ssSetIWorkValue(S, i, 0);
        
    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 74, 0);
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
static int cursorInTarget(real_T *c, real_T *t)
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
    real_T target_angle;
    real_T target1[4];
    real_T target2[4];
    real_T *target_origin;
    real_T *target_destination;
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    int bump, bump_mag, bump_direction;
    int stim, stim_mag, stim_direction;
    real_T cursor_displacement_x, cursor_displacement_y;
    int reset_stim_block = 0;
    int reset_bump_block = 0;
    double tmp_rand_value;
        
    /* databurst variables */
    byte *databurst;
	float *databurst_offsets;
    float *databurst_target_list;
    int databurst_counter;
    float databurst_target_offset;
    
    /* block initialization working variables */
    int tmp_trial[15];
    int tmp_sort[15];
    int i, j, tmp;
    
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int direction = (int)state_r[1];
    int new_state = state;
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    
    /* get target bounds */
    if (num_targets_per_angle == 0) {
      target_angle = req_target_angle;
    } else {
      target_angle = ssGetRWorkValue(S, 3);
    }
    
    target1[0] = cos(target_angle)*target_radius-target_size/2;
    target1[1] = sin(target_angle)*target_radius+target_size/2;
    target1[2] = cos(target_angle)*target_radius+target_size/2;
    target1[3] = sin(target_angle)*target_radius-target_size/2;
    
    target2[0] = cos(target_angle+PI)*target_radius-target_size/2;
    target2[1] = sin(target_angle+PI)*target_radius+target_size/2;
    target2[2] = cos(target_angle+PI)*target_radius+target_size/2;
    target2[3] = sin(target_angle+PI)*target_radius-target_size/2;

    if (direction == 0) {
      /* forward trial */
      target_origin = target1;
      target_destination = target2;
    } else {
      /* reverse trial */
      target_origin = target2;
      target_destination = target1;
    }
    
    /* databurst pointers */
    databurst_counter = ssGetIWorkValue(S, 74);
    databurst = ssGetPWorkValue(S, 0);
	databurst_offsets = (float *)(databurst + 6);
    databurst_target_list = databurst_offsets + 2;
    
    /*********************************
     * See if we have issued a reset *
     *********************************/
    if (param_master_reset != master_reset) {
      master_reset = param_master_reset;
      for (i = 68; i<=72; i++)
        ssSetIWorkValue(S, i, 0);
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
            if (bump_steps != param_bump_steps || stim_steps != param_stim_steps) {
                bump_steps = param_bump_steps;
                stim_steps = param_stim_steps;
                reset_stim_block = 1;
                reset_bump_block = 1;
            }
            
            stim_trial_pct = param_stim_trial_pct;
            bump_trial_pct = param_bump_trial_pct;
            
            bump_magnitude = param_bump_magnitude;
            bump_duration = (int)param_bump_duration;

            req_target_angle = param_req_target_angle;
            num_targets_per_angle = param_num_targets_per_angle;
            num_target_locations = param_num_target_locations;
            target_radius = param_target_radius;
            target_size = param_target_size;
            window_size = param_window_size;
            bump_displacement_gain = param_bump_displacement_gain;
            stim_displacement_gain = param_stim_displacement_gain;

            origin_hold_l = param_origin_hold_l;
            origin_hold_h = param_origin_hold_h;

            origin_delay_l = param_origin_delay_l;
            origin_delay_h = param_origin_delay_h;

            movement_time = param_movement_time;

            destination_hold_l = param_destination_hold_l;
            destination_hold_h = param_destination_hold_h;

            abort_timeout   = param_intertrial;    
            failure_timeout = param_intertrial;
            reward_timeout  = param_intertrial;   
            incomplete_timeout = param_intertrial;
            
            /* Determine if this is a bump, stim, or simple trial */
            tmp_rand_value = UNI;
            if (tmp_rand_value <= stim_trial_pct) {
                /* this is a stim trial */
                ssSetIWorkValue(S, 3, 0);
                ssSetIWorkValue(S, 4, 1);
                                
                ssSetIWorkValue(S, 2, ssGetIWorkValue(S, 2) - 1);
                if (ssGetIWorkValue(S, 2) < 0) {
                    reset_stim_block = 1;
                }
            } else if (tmp_rand_value <= stim_trial_pct + bump_trial_pct) {
                /* this is a bump trial */
                ssSetIWorkValue(S, 3, 1);
                ssSetIWorkValue(S, 4, 0);
                                
                ssSetIWorkValue(S, 1, ssGetIWorkValue(S, 1) - 1);
                if (ssGetIWorkValue(S, 1) < 0) {
                    reset_bump_block = 1;
                }
            } else {
                /* this is a simple (no bump or stim) trial */
                ssSetIWorkValue(S, 3, 0);
                ssSetIWorkValue(S, 4, 0);
            }
            
            /* reset stim block */
            if (reset_stim_block) {
                ssSetIWorkValue(S, 2, stim_steps-1);
                for (i=0; i<stim_steps; i++) {
                    tmp_trial[i] = i;
                    tmp_sort[i] = KISS;
                }
                
                for (i=0; i<stim_steps; i++) {
                    for (j=0; j<stim_steps-1; j++) {
                        if (tmp_sort[i] < tmp_sort[j]) {
                            tmp = tmp_sort[j];
                            tmp_sort[j] = tmp_sort[j+1];
                            tmp_sort[j+1] = tmp;
                            
                            tmp = tmp_trial[j];
                            tmp_trial[j] = tmp_trial[j+1];
                            tmp_trial[j+1] = tmp;
                        }
                    }
                }
                
                for (i=0; i<stim_steps; i++) {
                    ssSetIWorkValue(S, 22+i, tmp_trial[i]);
                }
            }
            
            /* reset bump block */
            if (reset_bump_block) {
				/* All bumps are given a magnitude and a sign in the last 4 bits of the word:
				 * 0001 is magnitude 1
				 * 0010 is magnitude 2
				 * 1001 is magnitude -1
				 * 1011 is magnitude -3, etc.
				 */
                ssSetIWorkValue(S, 1, 2*bump_steps-1);
                for (i=0; i<bump_steps; i++) {
                    tmp_trial[i] = i+1;
                    tmp_sort[i] = KISS;
                }

				for (i=bump_steps; i<bump_steps*2; i++) {
                    tmp_trial[i] = (i-bump_steps+1) | 0x08; 
                    tmp_sort[i] = KISS;
                }
                
                for (i=0; i<bump_steps*2; i++) {
                    for (j=0; j<(2*bump_steps)-1; j++) {
                        if (tmp_sort[i] < tmp_sort[j]) {
                            tmp = tmp_sort[j];
                            tmp_sort[j] = tmp_sort[j+1];
                            tmp_sort[j+1] = tmp;
                            
                            tmp = tmp_trial[j];
                            tmp_trial[j] = tmp_trial[j+1];
                            tmp_trial[j+1] = tmp;
                        }
                    }
                }
                
                for (i=0; i<bump_steps*2; i++) {
                    ssSetIWorkValue(S, 5+i, tmp_trial[i]);
                }
            }
            
            /* reset masking noise */
            ssSetIWorkValue(S, 73, 0);
                        
            /* choose the target angle based on the requested angle and counter */
            if (num_targets_per_angle == 0) {
              /* use requested angle */
              ssSetRWorkValue(S, 3, req_target_angle);
              ssSetIWorkValue(S, 72, 0);
            } else {
              /* increment counter */
              ssSetIWorkValue(S, 72, ssGetIWorkValue(S, 72) + 1);
              
              /* see if we have run enough trials at this angle */
              if (ssGetIWorkValue(S, 72) >= num_targets_per_angle) {
                ssSetIWorkValue(S, 72, 0); /* reset counter */

                /* see if we have continuous or discrete target locations */
                if (num_target_locations == 0) {
                    ssSetRWorkValue(S, 3, UNI * 2.0 * PI); /* pick a new random value */
                } else {
                    tmp_rand_value = (int)(UNI*num_target_locations);
                    ssSetRWorkValue(S, 3, 2.0 * PI * tmp_rand_value / num_target_locations + req_target_angle);
                }
              }
            }
            
            /* In all cases, we need to decide on the random timer durations */
            if (origin_hold_h == origin_hold_l) {
                origin_hold = origin_hold_h;
            } else {
                origin_hold = origin_hold_l + (origin_hold_h - origin_hold_l)*((double)rand())/((double)RAND_MAX);
            }
            if (origin_delay_h == origin_delay_l) {
                origin_delay = origin_delay_h;
            } else {
                origin_delay = origin_delay_l + (origin_delay_h - origin_delay_l)*((double)rand())/((double)RAND_MAX);
            }
            if (destination_hold_h == destination_hold_l) {
                destination_hold = destination_hold_h;
            } else {
                destination_hold = destination_hold_l + (destination_hold_h - destination_hold_l)*((double)rand())/((double)RAND_MAX);
            }
			

			/* Setup the databurst data */
            /* adjust targets for forward or reverse trial */
            databurst_target_offset = ( direction==0 ? 0 : PI );
            
            databurst[0] = 6+6*sizeof(float);
            databurst[1] = DATABURST_VERSION;
			databurst[2] = BEHAVIOR_VERSION_MAJOR;
			databurst[3] = BEHAVIOR_VERSION_MINOR;
			databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
			databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
			/* The offsets used in the calculation of the cursor location */
			uPtrs = ssGetInputPortRealSignalPtrs(S, 1); 
			databurst_offsets[0] = *uPtrs[0];
			databurst_offsets[1] = *uPtrs[1];
            databurst_target_list[0] = cos(target_angle+databurst_target_offset)*target_radius;
            databurst_target_list[1] = sin(target_angle+databurst_target_offset)*target_radius;
            databurst_target_list[2] = cos(target_angle+databurst_target_offset+PI)*target_radius;
            databurst_target_list[3] = sin(target_angle+databurst_target_offset+PI)*target_radius;
            

            /* clear the counters */
            ssSetIWorkValue(S, 67, -1);  /* bump counter */
            ssSetIWorkValue(S, 74, 0); /* Databurst counter */
                            
            /* and advance */
            new_state = STATE_DATA_BLOCK;
            state_changed();
            break;
        case STATE_DATA_BLOCK:            
            if (databurst_counter > 2*(databurst[0]-1)) { 
                new_state = STATE_ORIGIN_ON;
                reset_timer(); /* start timer for movement */
                state_changed();
            }
            
            ssSetIWorkValue(S, 74, databurst_counter+1);
            break;
        case STATE_ORIGIN_ON:
            /* center target on */
            if (cursorInTarget(cursor, target_origin)) {
                new_state = STATE_ORIGIN_HOLD;
                reset_timer(); /* start center hold timer */
                state_changed();
            }
            break;
        case STATE_ORIGIN_HOLD:
            /* center hold */
            if (!cursorInTarget(cursor, target_origin)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > origin_hold) {
                new_state = STATE_ORIGIN_DELAY;
                reset_timer(); /* delay timer */
                state_changed();
            }
            break;
        case STATE_ORIGIN_DELAY:
            /* center delay (destination target on) */
            if (!cursorInTarget(cursor, target_origin)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > origin_delay) {
                new_state = STATE_MOVEMENT;
                reset_timer(); /* movement timer */
                state_changed();
            }
            break;
        case STATE_MOVEMENT:
            /* get bump magnitude, direction */
            
            cursor_displacement_x = 0.0;
            cursor_displacement_y = 0.0;
            if (ssGetIWorkValue(S,3) == 1) {
                bump = 1;
                bump_mag = ssGetIWorkValue(S, 5+ssGetIWorkValue(S,1));
                bump_direction = ( 0x08 & bump_mag ? -1 : 1 );
                bump_mag = bump_mag & 0x07;
                cursor_displacement_x = (cos( PI/2 + target_angle )* bump_displacement_gain * bump_mag * bump_direction);
                cursor_displacement_y = (sin( PI/2 + target_angle )* bump_displacement_gain * bump_mag * bump_direction);
            } else {
                bump = 0;
                bump_mag = 0;
            }
            
            /* get stim magnitude, direction */
            if (ssGetIWorkValue(S,4) == -1) {
                stim = 1;
                /* stim_mag = ssGetIWorkValue(S, 22+ssGetIWorkValue(S,2)); */
                cursor_displacement_x = cos( PI/2 + target_angle )* stim_displacement_gain;
                cursor_displacement_y = sin( PI/2 + target_angle )* stim_displacement_gain;
            } else {
                stim = 0;
                stim_mag = 0;
            }
                          
            /* movement phase (go tone on entry) */
            if ( ( direction == 0 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] <= -target_radius) ||
                  ( direction == 1 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] >= target_radius) ) {                       
                   if ((((cursor[0] + cursor_displacement_x)*cos(target_angle + PI/2) + (cursor[1]+cursor_displacement_y)*sin(target_angle + PI/2 )) <= target_size/2) &&
                       (((cursor[0] + cursor_displacement_x)*cos(target_angle + PI/2) + (cursor[1]+cursor_displacement_y)*sin(target_angle + PI/2 )) >= -target_size/2) ) {
                       new_state = STATE_REWARD;
                       reset_timer();
                       state_changed();
                   } else {
                       new_state = STATE_FAIL;
                       reset_timer();
                       state_changed();
                   }
            } else if (elapsed_timer_time > movement_time) {
                new_state = STATE_INCOMPLETE;
                reset_timer(); /* failure timeout */
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
                state_r[1] = !state_r[1];
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
    
	KISS; /* burn a number off the LCG */

    /* write back new state */
    state_r[0] = new_state;
    
    UNUSED_ARG(tid);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /********************
     *  Initialization
     ********************/
    int i;
    int_T *IWorkVector; 
    real_T target_angle;
    real_T target_origin[4];
    real_T target_destination[4];
    real_T theta;
    
    int databurst_counter;
    byte* databurst;
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T force_in[2];
    
    /* allocate holders for outputs */
    real_T force_x, force_y, word, reward, tone_cnt, tone_id, pos_x, pos_y;
    real_T target_pos[10];
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
    
    /* stim and bump */
	int bump_started = 0;
    int mask = 0;
    int bump_duration_counter;
    int bump, bump_mag, bump_direction;
    int stim, stim_id, stim_mag, stim_direction;
    real_T pos_x_fixed, pos_y_fixed;
    real_T cursor_displacement_x, cursor_displacement_y;
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)(state_r[0]);
    int direction = (int)(state_r[1]);
    int new_state = ssGetIWorkValue(S, 0);
    ssSetIWorkValue(S, 0, 0); /* reset changed state each iteration */

    /* work vector pointer */
    IWorkVector = ssGetIWork(S);
    
    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 74);
    databurst = (byte *)ssGetPWorkValue(S, 0);
    
    /* get stim */
    if (ssGetIWorkValue(S,4) == 1) {
        stim = 1;
        stim_id = ssGetIWorkValue(S, 22+ssGetIWorkValue(S,2));        
    } else if (ssGetIWorkValue(S,4) == -1) {
        stim = -1;
        stim_id = 0;
    } else {
        stim = 0;
        stim_id = 0;
    }

    /* get bump */
    if (ssGetIWorkValue(S,3) == 1) {
        bump = 1;
        bump_mag = ssGetIWorkValue(S, 5+ssGetIWorkValue(S,1));
		bump_direction = ( 0x08 & bump_mag ? -1 : 1 );
		bump_mag = bump_mag & 0x07;
    } else {
        bump = 0;
        bump_mag = 0;
    }
    
    /* get masking noise */
    if (ssGetIWorkValue(S,73) == 1) {
        mask = -1;
    } else {
        mask = 0;
    }
    
    bump_duration_counter = ssGetIWorkValue(S, 67);
    
    /* get current tone counter */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);
    
    /* get target bounds */
    if (num_targets_per_angle == 0) {
      target_angle = req_target_angle;
    } else {
      target_angle = ssGetRWorkValue(S, 3);
    }
      
    if (direction == 0) {
        /* forward trial */
        target_origin[0] = cos(target_angle)*target_radius-target_size/2;
        target_origin[1] = sin(target_angle)*target_radius+target_size/2;
        target_origin[2] = cos(target_angle)*target_radius+target_size/2;
        target_origin[3] = sin(target_angle)*target_radius-target_size/2;
        
        target_destination[0] = cos(target_angle+PI)*target_radius-target_size*sin(target_angle+PI)/2;
        target_destination[1] = sin(target_angle+PI)*target_radius+target_size*cos(target_angle+PI)/2;
        target_destination[2] = cos(target_angle+PI)*target_radius+target_size*sin(target_angle+PI)/2;
        target_destination[3] = sin(target_angle+PI)*target_radius-target_size*cos(target_angle+PI)/2;

    } else {
        /* reverse trial */
        target_origin[0] = cos(target_angle+PI)*target_radius-target_size/2;
        target_origin[1] = sin(target_angle+PI)*target_radius+target_size/2;
        target_origin[2] = cos(target_angle+PI)*target_radius+target_size/2;
        target_origin[3] = sin(target_angle+PI)*target_radius-target_size/2;

        target_destination[0] = cos(target_angle)*target_radius-target_size*sin(target_angle)/2;
        target_destination[1] = sin(target_angle)*target_radius+target_size*cos(target_angle)/2;
        target_destination[2] = cos(target_angle)*target_radius+target_size*sin(target_angle)/2;
        target_destination[3] = sin(target_angle)*target_radius-target_size*cos(target_angle)/2;

    }
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    pos_x_fixed = ssGetRWorkValue(S,4);
    pos_y_fixed = ssGetRWorkValue(S,5);
    
    /* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    force_in[0] = *uPtrs[0];
    force_in[1] = *uPtrs[1];
    
    /********************
     * Calculate outputs
     ********************/
    
    /* force (0) */
    /* see if we are in a bump */

    if (bump_duration_counter > 0) {
        /* yes, so decrement the counter and maintain the bump */
        bump_duration_counter--;
        theta = PI/2 + target_angle;
        force_x = force_in[0] + cos(theta)*bump_mag*bump_magnitude*bump_direction;
        force_y = force_in[1] + sin(theta)*bump_mag*bump_magnitude*bump_direction;
    } else if ( bump_duration_counter == -1 && bump &&
                state==STATE_MOVEMENT && 
                ( ( direction == 0 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] <= 0) ||
                  ( direction == 1 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] >= 0) )
              ) 
    {
        /* initiating a new bump */
        bump_started = 1;
        bump_duration_counter = (int)bump_duration;
        theta = PI/2 + target_angle;
        force_x = force_in[0] + cos(theta)*bump_mag*bump_magnitude*bump_direction;
        force_y = force_in[1] + sin(theta)*bump_mag*bump_magnitude*bump_direction;
    } else {
        force_x = force_in[0]; 
        force_y = force_in[1];
    }

    /* status (1) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S, 68, ssGetIWorkValue(S, 68) + 1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, 69, ssGetIWorkValue(S, 69) + 1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, 70, ssGetIWorkValue(S, 70) + 1);
    if (state == STATE_INCOMPLETE && new_state)
        ssSetIWorkValue(S, 71, ssGetIWorkValue(S, 71) + 1);
    
#if 0
    status[0] = ssGetIWorkValue(S,4);
    status[1] = 0; //ssGetIWorkValue(S, 68); /* num rewards     */
    status[2] = 0;
    status[3] = 0; //ssGetIWorkValue(S, 70); /* num fails       */
    status[4] = 0; //ssGetIWorkValue(S, 71); /* num incompletes */
#else
    
    status[0] = state;
    status[1] = ssGetIWorkValue(S, 68); /* num rewards     */
    status[2] = ssGetIWorkValue(S, 69); /* num aborts      */
    status[3] = ssGetIWorkValue(S, 70); /* num fails       */
    status[4] = ssGetIWorkValue(S, 71); /* num incompletes */
#endif

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
				if (direction == 0) {
					word = WORD_START_FORWARD_TRIAL;
				} else {
					word = WORD_START_REVERSE_TRIAL;
				}
                break;
            case STATE_ORIGIN_ON:
                word = WORD_ORIGIN_TARGET_ON;
                break;
            case STATE_ORIGIN_DELAY:
                word = WORD_DESTINATION_TARGET_ON;
                break;
            case STATE_MOVEMENT:
                word = WORD_GO_CUE;
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
                word = 0;
        }
    } else if ( stim == 1 &&
                state==STATE_MOVEMENT && 
                ( ( direction == 0 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] <= 0) ||
                  ( direction == 1 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] >= 0) )
              ) {
		/* stim */
		word = WORD_STIM(stim_id);
		ssSetIWorkValue(S, 4, -1);
	} else if (bump_started) {
        /* just started a bump */
        word = WORD_BUMP(ssGetIWorkValue(S, 5+ssGetIWorkValue(S,1)));
    } else {
        word = 0;
    }
    
    if ( mask == 0 && state==STATE_MOVEMENT &&
         ( ( direction == 0 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] <= 0) ||
          ( direction == 1 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] >= 0))
           ) {
          ssSetIWorkValue(S, 73, 1);
          tone_cnt++;
          tone_id = TONE_MASK;
    }
                        
    if (word != 0) last_word = word; /*** HACK ***/
    
    /* target_pos (3) */
    /* origin */
    if ( state == STATE_ORIGIN_ON || 
         state == STATE_ORIGIN_HOLD || 
         state == STATE_ORIGIN_DELAY )
    {
        /* origin target on */
        target_pos[0] = 1;
        for (i=0; i<4; i++) {
            target_pos[i+1] = target_origin[i];
        }
    } else {
        /* center target off */
        target_pos[0] = 0;
        for (i=0; i<4; i++) {
            target_pos[i+1] = 0;
        }
    }
    
	/* destination */
    if ( state == STATE_ORIGIN_DELAY ||
         state == STATE_MOVEMENT ||
         state == STATE_REWARD ||
         state == STATE_FAIL)
    {
        /* destination target on */
        target_pos[5] = 4;
        for (i=0; i<4; i++) {
            target_pos[i+6] = target_destination[i];
        }
    } else {
        /* destination target off */
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
        if (state == STATE_ABORT || state == STATE_FAIL) {
            tone_cnt++;
            tone_id = TONE_ABORT;
        } else if (state == STATE_MOVEMENT) {
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
    
    if (bump) {
        cursor_displacement_x = cos( PI/2 + target_angle )* bump_displacement_gain * bump_mag * bump_direction;
        cursor_displacement_y = sin( PI/2 + target_angle )* bump_displacement_gain * bump_mag * bump_direction;
    } else if (stim != 0) { 
        cursor_displacement_x = cos( PI/2 + target_angle )* stim_displacement_gain;
        cursor_displacement_y = sin( PI/2 + target_angle )* stim_displacement_gain;
    } else {
        cursor_displacement_x = 0.0;
        cursor_displacement_y = 0.0;
    }
              
    /* pos (7) */
    if ( state == STATE_MOVEMENT && abs(cursor[0]*cos(target_angle) + cursor[1]*sin(target_angle)) < window_size) {
        /* we are inside blocking window => draw cursor off screen */
        pos_x = 1E6;
        pos_y = 1E6;
    } else if ( state == STATE_REWARD || state == STATE_FAIL) {
        /* we finished the trial and hold the cursor at the goal target */
        if (new_state) {
            pos_x_fixed = cursor[0] + cursor_displacement_x;
            pos_y_fixed = cursor[1] + cursor_displacement_y;
        }
        pos_x = pos_x_fixed;
        pos_y = pos_y_fixed;
    } else if ( state == STATE_MOVEMENT &&
        ( ( direction == 0 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] <= 0) ||
          ( direction == 1 && cos( -target_angle )*cursor[0] - sin( -target_angle )*cursor[1] >= 0))) {
            pos_x = cursor[0] + cursor_displacement_x;
            pos_y = cursor[1] + cursor_displacement_y;
    } else {
        /* we are outside the blocking window */
        pos_x = cursor[0];
        pos_y = cursor[1];
    }
    
    /**********************************
     * Write outputs back to SimStruct
     **********************************/
    force_p = ssGetOutputPortRealSignal(S,0);
    force_p[0] = force_x;
    force_p[1] = force_y;
    ssSetIWorkValue(S, 67, bump_duration_counter);
    
    status_p = ssGetOutputPortRealSignal(S,1);
    for (i=0; i<5; i++) 
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
    
    ssSetRWorkValue(S,4,pos_x_fixed);
    ssSetRWorkValue(S,5,pos_y_fixed);
    
    UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif
