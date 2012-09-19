/* $Id: mastercon_2afc.c 851 2012-04-04 22:52:59Z brian $
 *
 * Master Control block for behavior: two-alternative forced choice task
 */

#define S_FUNCTION_NAME mastercon_2afc
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "simstruc.h"

#define TASK_2AFC 1
#include "words.h"
#include "random_macros.h"

#define PI (3.141592654)

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
 * byte   6: uchar => training trial (1 if training, 0 if not)
 * bytes  7 to 10: float => x offset
 * bytes 11 to 14: float => y offset
 * byte 15: uchar => first target: 1 or 2
 * bytes 16 to 19: float => target size
 * bytes 20 to 23: float => stim delay
 * bytes 24 to 27: float => bump duration interval 1 (ms)
 * bytes 28 to 31: float => bump duration interval 2 (ms)
 * bytes 32 to 35: float => stim code interval 1
 * bytes 36 to 39: float => stim code interval 2
 * bytes 40 to 43: float => bump magnitude interval 1 (bump units)
 * bytes 44 to 47: float => bump magnitude interval 2 (bump units)
 * bytes 48 to 51: float => bump direction interval 1 (rad)
 * bytes 52 to 55: float => bump direction interval 2 (rad)
 *
 */

typedef unsigned char byte;
#define DATABURST_VERSION (0x00) 

/*
 * Until we implement tunable parameters, these will act as defaults
 */

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,0))

/* Update counter */
static real_T master_update = 0.0;
#define param_master_update mxGetScalar(ssGetSFcnParam(S,1))

/* Target parameters */
static real_T target_radius = 10.0; /* radius of target circle in cm */
#define param_target_radius mxGetScalar(ssGetSFcnParam(S,2))
static real_T target_size = 3.0;    /* width and height of targets in cm */
#define param_target_size mxGetScalar(ssGetSFcnParam(S,3))
static real_T window_size = 5.0;   /* radius of blocking circle */
#define param_window_size mxGetScalar(ssGetSFcnParam(S,4))

/* Timing parameters */
static real_T center_hold;
static real_T center_hold_l = 0.5; /* shortest delay between entry of ct and bump/stim */ 
#define param_center_hold_l mxGetScalar(ssGetSFcnParam(S,5))
static real_T center_hold_h = 1.0; /* longest delay between entry of ct and bump/stim */ 
#define param_center_hold_h mxGetScalar(ssGetSFcnParam(S,6))
static real_T movement_time = 10.0;  /* movement time */
#define param_movement_time mxGetScalar(ssGetSFcnParam(S,7))
static real_T interval_length = 1.0; /* length of each interval */
#define param_interval_length mxGetScalar(ssGetSFcnParam(S,8))
static real_T interval_wait = 1.0; /* wait between two intervals */
#define param_interval_wait mxGetScalar(ssGetSFcnParam(S,9))

static real_T incomplete_timeout = 1.0; /* delay after incomplete trial */
#define param_incomplete_intertrial mxGetScalar(ssGetSFcnParam(S,10)) 
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial */     
#define param_reward_intertrial mxGetScalar(ssGetSFcnParam(S,11)) 
static real_T failure_timeout = 1.0;    /* delay after failure */
#define param_fail_intertrial mxGetScalar(ssGetSFcnParam(S,12)) 
static real_T abort_timeout = 1.0;     /* delay after abort */
#define param_abort_intertrial mxGetScalar(ssGetSFcnParam(S,13)) 

/* stimulus delay parameters */
static real_T stim_delay;
static real_T stim_delay_l = 0.0; /*shortest delay between interval signal and bump/stim/tone */
# define param_stim_delay_l mxGetScalar(ssGetSFcnParam(S,14))
static real_T stim_delay_h = 0.0; /*longest delay between interval signal and bump/stim/tone */
# define param_stim_delay_h mxGetScalar(ssGetSFcnParam(S,15))

/* General parameters */
static real_T pct_training_trials = 0.0; /* true=show one outer target, false=show 2 */
#define param_pct_training_trials mxGetScalar(ssGetSFcnParam(S,16))

/* Stimulation parameters */
static int ct_color_change = 0; /* change color of CT during intervals */
#define param_ct_color_change (int)mxGetScalar(ssGetSFcnParam(S,17))

/* Left target */
static int t1_tone = 1;
#define param_t1_tone (int)mxGetScalar(ssGetSFcnParam(S,18))
static int t1_icms = 0;
#define param_t1_icms (int)mxGetScalar(ssGetSFcnParam(S,19))
static int t1_bump = 0;
#define param_t1_bump (int)mxGetScalar(ssGetSFcnParam(S,20))
static int t1_icms_steps = 1;
#define param_t1_icms_steps (int)mxGetScalar(ssGetSFcnParam(S,21))
static int t1_bump_steps = 1;
#define param_t1_bump_steps (int)mxGetScalar(ssGetSFcnParam(S,22))
static real_T t1_bump_mag_min = 1.0;
#define param_t1_bump_mag_min mxGetScalar(ssGetSFcnParam(S,23))
static real_T t1_bump_mag_max = 1.0;
#define param_t1_bump_mag_max mxGetScalar(ssGetSFcnParam(S,24))
static real_T t1_bump_direction = -1.0;
#define param_t1_bump_direction mxGetScalar(ssGetSFcnParam(S,25))
static real_T t1_bump_duration = 1.0;
#define param_t1_bump_duration mxGetScalar(ssGetSFcnParam(S,26))

/* Right target */
static int t2_tone = 1;
#define param_t2_tone (int)mxGetScalar(ssGetSFcnParam(S,27))
static int t2_icms = 0;
#define param_t2_icms (int)mxGetScalar(ssGetSFcnParam(S,28))
static int t2_bump = 0;
#define param_t2_bump (int)mxGetScalar(ssGetSFcnParam(S,29))
static int t2_icms_steps = 1;
#define param_t2_icms_steps (int)mxGetScalar(ssGetSFcnParam(S,30))
static int t2_bump_steps = 1;
#define param_t2_bump_steps (int)mxGetScalar(ssGetSFcnParam(S,31))
static real_T t2_bump_mag_min = 1.0;
#define param_t2_bump_mag_min mxGetScalar(ssGetSFcnParam(S,32))
static real_T t2_bump_mag_max = 1.0;
#define param_t2_bump_mag_max mxGetScalar(ssGetSFcnParam(S,33))
static real_T t2_bump_direction = -1.0;
#define param_t2_bump_direction mxGetScalar(ssGetSFcnParam(S,34))
static real_T t2_bump_duration = 1.0;
#define param_t2_bump_duration mxGetScalar(ssGetSFcnParam(S,35))

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_ORIGIN_ON 1
#define STATE_CENTER_HOLD 2
#define STATE_INTERVAL_1 3
#define STATE_INTER_INTERVAL 4
#define STATE_INTERVAL_2 5
#define STATE_MOVEMENT 6
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3
#define TONE_MASK 5

static void mdlCheckParameters(SimStruct *S)
{
    target_radius = param_target_radius;
    target_size = param_target_size;
    window_size = param_window_size;
      
    center_hold_l = param_center_hold_l;
    center_hold_h = param_center_hold_h;
    movement_time = param_movement_time;
    interval_length = param_interval_length;
    interval_wait = param_interval_wait;

    abort_timeout   = param_abort_intertrial;    
    failure_timeout = param_fail_intertrial;
    reward_timeout  = param_reward_intertrial;   
    incomplete_timeout = param_incomplete_intertrial;
    
    stim_delay_l = param_stim_delay_l;
    stim_delay_h = param_stim_delay_h;    
    
    pct_training_trials = param_pct_training_trials;    
    
    ct_color_change = param_ct_color_change;
    
    t1_tone = param_t1_tone;
    t1_icms = param_t1_icms;
    t1_bump = param_t1_bump;
    t1_icms_steps = param_t1_icms_steps;
    t1_bump_steps = param_t1_bump_steps;
    t1_bump_mag_min = param_t1_bump_mag_min;
    t1_bump_mag_max = param_t1_bump_mag_max;
    t1_bump_direction = param_t1_bump_direction;
    t1_bump_duration = param_t1_bump_duration;
    
    t2_tone = param_t2_tone;
    t2_icms = param_t2_icms;
    t2_bump = param_t2_bump;
    t2_icms_steps = param_t2_icms_steps;
    t2_bump_steps = param_t2_bump_steps;
    t2_bump_mag_min = param_t2_bump_mag_min;
    t2_bump_mag_max = param_t2_bump_mag_max;
    t2_bump_direction = param_t2_bump_direction;
    t2_bump_duration = param_t2_bump_duration;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 36);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* parameter number mismatch */
    }
    for (i=0; i<ssGetNumSFcnParams(S); i++)
        ssSetSFcnParamTunable(S, i, 1);
    mdlCheckParameters(S);
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 1);
    
    /*
     * Block has 5 input ports
     *      input port 0: (position) of width 2 (x, y)
	 *      input port 1: (position offsets) of width 2 (x, y)
     *      input port 2: (force) of width 2 (x, y)
     *      input port 3: (catch force) of width 2 (x,y) NOT USED
	 *      input port 4: (stim table) of width 32
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
     *  target: 15 ( target 1, 2, 3: 
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
    ssSetOutputPortWidth(S, 3, 15);  /* target  */
    ssSetOutputPortWidth(S, 4, 1);   /* reward  */
    ssSetOutputPortWidth(S, 5, 2);   /* tone    */
    ssSetOutputPortWidth(S, 6, 4);   /* version */
    ssSetOutputPortWidth(S, 7, 2);   /* pos     */
    
    ssSetNumSampleTimes(S, 1);
    
    /* work buffers */
    ssSetNumRWork(S, 10);  /* 0: time of last timer reset 
                             1: tone counter (incremented each time a tone is played)
                             2: tone id
							 3: mastercon version
                             4: bump direction interval 1
                             5: bump direction interval 2
                             7: bump magnitude interval 1
                             8: bump magnitude interval 2   
                             9: master update counter                        
                           */
    ssSetNumPWork(S, 1);   /* 0: pointer to databurst array
                            */
    
    ssSetNumIWork(S, 15);     /* 0: state_transition (true if state changed), 
                                1: successes
                                2: failures
                                3: aborts
                                4: incompletes   
                                5: debugging info 
                                6: training mode
                                7: databurst counter
                                8: bump duration counter
                                9: first target: 1 or 2
                                10: stim code interval 1
                                11: stim code interval 2
                                12: bump step interval 1
                                13: bump step interval 2
                                14: interval counter
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
    int *databurst;
    
    /* initialize state to zero */
    x0 = ssGetRealDiscStates(S);
    *x0 = 0.0;
    
    /* notify that we just entered this state */
    ssSetIWorkValue(S, 0, 1);
       
    /* set the tone counter to zero */
    ssSetRWorkValue(S, 1, 0.0);
        
    /* set trial counters to zero */
    ssSetIWorkValue(S, 1, 0);
    ssSetIWorkValue(S, 2, 0);
    ssSetIWorkValue(S, 3, 0);
    ssSetIWorkValue(S, 4, 0);
    
    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 7, 0);        
    
    /* set the initial last update time to 0 */
    ssSetRWorkValue(S,0,0.0);    
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
   
    real_T ct[4];
    real_T rt[4];     /* reward target UL and LR coordinates */
    real_T ft[4];     /* fail target UL and LR coordinates */
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    int reset_block = 0;
    
    /* get trial parameters */
    int first_target;  /* 1 if left target is first, 2 for right target */
    int bump_step_1;
    int bump_step_2;
    int training_mode;
    real_T bump_magnitude_1;
    real_T bump_magnitude_2;
    real_T bump_direction_1;
    real_T bump_direction_2;
    int bump_duration_1;
    int bump_duration_2;
    
    /* stimulation parameters */
    int stim_code_1;
    int stim_code_2;
    
    /* databurst variables */
    byte *databurst;
	float *databurst_offsets;
    byte *databurst_target;
    float *databurst_target_size;
    float *databurst_stim_delay;
    float *databurst_bump_duration_1;
    float *databurst_bump_duration_2;
    float *databurst_stim_code_1;
    float *databurst_stim_code_2;
    float *databurst_bump_mag_1;
    float *databurst_bump_mag_2;
    float *databurst_bump_dir_1;
    float *databurst_bump_dir_2;
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

    /* get IWorkVector */
    bump_direction_1 = ssGetRWorkValue(S,4);
    bump_direction_2 = ssGetRWorkValue(S,5);
    bump_magnitude_1 = ssGetRWorkValue(S,7); 
    bump_magnitude_2 = ssGetRWorkValue(S,8); 
    bump_step_1 = ssGetIWorkValue(S,12);
    bump_step_2 = ssGetIWorkValue(S,13);
    training_mode = ssGetIWorkValue(S,6);   
    first_target = ssGetIWorkValue(S,9);
    stim_code_1 = ssGetIWorkValue(S,10);
    stim_code_2 = ssGetIWorkValue(S,11);
    
    if ( param_master_update > master_update ) {
        master_update = param_master_update;
        ssSetRWorkValue(S, 9, (real_T)ssGetT(S));
    }
                   
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
        
    /* get target bounds */
    ct[0] = -target_size/2;
    ct[1] = target_size/2;
    ct[2] = target_size/2;
    ct[3] = -target_size/2;
       
    rt[0] = pow(-1,(float)first_target)*target_radius - target_size/2; /* reward target */
    rt[1] = target_size/2;
    rt[2] = pow(-1,(float)first_target)*target_radius + target_size/2;
    rt[3] = -target_size/2;

    ft[0] = pow(-1,(float)first_target+1)*target_radius - target_size/2; /* fail target */
    ft[1] = target_size/2;
    ft[2] = pow(-1,(float)first_target+1)*target_radius + target_size/2; 
    ft[3] = -target_size/2;   
    
    /* databurst pointers */
    databurst_counter = ssGetIWorkValue(S, 7);
    databurst = ssGetPWorkValue(S, 0);
	databurst_offsets  = (float *)(databurst + 7);
    databurst_target = (byte *)(databurst_offsets+2);
    databurst_target_size = (float *)(databurst_target + 1);
    databurst_stim_delay = databurst_target_size + 1;
    databurst_bump_duration_1 = databurst_stim_delay +1;
    databurst_bump_duration_2 = databurst_bump_duration_1 +1;
    databurst_stim_code_1 = databurst_bump_duration_2 + 1;
    databurst_stim_code_2 = databurst_stim_code_1 + 1;
    databurst_bump_mag_1 = databurst_stim_code_2 + 1;
    databurst_bump_mag_2 = databurst_bump_mag_1 + 1;
    databurst_bump_dir_1 = databurst_bump_mag_2 + 1;
    databurst_bump_dir_2 = databurst_bump_dir_1 + 1;   
    
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

            target_radius = param_target_radius;
            target_size = param_target_size;
            window_size = param_window_size;

            center_hold_l = param_center_hold_l;
            center_hold_h = param_center_hold_h;
            movement_time = param_movement_time;
            interval_length = param_interval_length;
            interval_wait = param_interval_wait;

            abort_timeout   = param_abort_intertrial;    
            failure_timeout = param_fail_intertrial;
            reward_timeout  = param_reward_intertrial;   
            incomplete_timeout = param_incomplete_intertrial;

            stim_delay_l = param_stim_delay_l;
            stim_delay_h = param_stim_delay_h;    

            pct_training_trials = param_pct_training_trials;    

            ct_color_change = param_ct_color_change;

            t1_tone = param_t1_tone;
            t1_icms = param_t1_icms;
            t1_bump = param_t1_bump;
            t1_icms_steps = param_t1_icms_steps;
            t1_bump_steps = param_t1_bump_steps;
            t1_bump_mag_min = param_t1_bump_mag_min;
            t1_bump_mag_max = param_t1_bump_mag_max;
            t1_bump_direction = param_t1_bump_direction;
            t1_bump_duration = param_t1_bump_duration;

            t2_tone = param_t2_tone;
            t2_icms = param_t2_icms;
            t2_bump = param_t2_bump;
            t2_icms_steps = param_t2_icms_steps;
            t2_bump_steps = param_t2_bump_steps;
            t2_bump_mag_min = param_t2_bump_mag_min;
            t2_bump_mag_max = param_t2_bump_mag_max;
            t2_bump_direction = param_t2_bump_direction;
            t2_bump_duration = param_t2_bump_duration;
            
            /* decide if it is a training trial */
            training_mode = (UNI<pct_training_trials) ? 1 : 0;
            ssSetIWorkValue(S,6,training_mode);
            
            /* decide which is the correct target */
            first_target = (UNI<0.5 ? 1 : 2);
            ssSetIWorkValue(S,9,first_target);
            
            bump_step_1 = 0;
            bump_step_2 = 0;
            bump_magnitude_1 = 0;
            bump_magnitude_2 = 0;
            bump_direction_1 = 0;
            bump_direction_2 = 0;
            stim_code_1 = -1;
            stim_code_2 = -1;
            bump_duration_1 = 0;
            bump_duration_2 = 0;
            
            if (first_target == 1){
                if (t1_icms){
                    stim_code_1 = (int)floor(UNI*t1_icms_steps);
                }
                if (t2_icms){
                    stim_code_2 = (int)floor(UNI*t2_icms_steps);
                }
                if (t1_bump){
                    bump_step_1 = (int)(UNI*t1_bump_steps);                                
                    bump_magnitude_1 = t1_bump_mag_min + ((float)bump_step_1)*(t1_bump_mag_max-t1_bump_mag_min)/((float)t1_bump_steps-1);
                    bump_duration_1 = t1_bump_duration;
                    if (t1_bump_direction == -1) {
                        bump_direction_1 = 2*PI*UNI;
                    } else {
                        bump_direction_1 = t1_bump_direction;
                    }
                } 
                if (t2_bump){
                    bump_step_2 = (int)(UNI*t2_bump_steps);                                
                    bump_magnitude_2 = t2_bump_mag_min + ((float)bump_step_2)*(t2_bump_mag_max-t2_bump_mag_min)/((float)t2_bump_steps-1);
                    bump_duration_2 = t2_bump_duration;
                    if (t2_bump_direction == -1) {
                        bump_direction_2 = 2*PI*UNI;
                    } else {
                        bump_direction_2 = t2_bump_direction;
                    }
                }
            } else {
                if (t1_icms){
                    stim_code_2 = (int)floor(UNI*t1_icms_steps);
                }
                if (t2_icms){
                    stim_code_1 = (int)floor(UNI*t2_icms_steps);
                }
                if (t1_bump){
                    bump_step_2 = (int)(UNI*t1_bump_steps);                                
                    bump_magnitude_2 = t1_bump_mag_min + ((float)bump_step_2)*(t1_bump_mag_max-t1_bump_mag_min)/((float)t1_bump_steps-1);
                    bump_duration_2 = t1_bump_duration;
                    if (t1_bump_direction == -1) {
                        bump_direction_2 = 2*PI*UNI;
                    } else {
                        bump_direction_2 = t1_bump_direction;
                    }
                } 
                if (t2_bump){
                    bump_step_1 = (int)(UNI*t2_bump_steps);                                
                    bump_magnitude_1 = t2_bump_mag_min + ((float)bump_step_1)*(t2_bump_mag_max-t2_bump_mag_min)/((float)t2_bump_steps-1);
                    bump_duration_1 = t2_bump_duration;
                    if (t2_bump_direction == -1) {
                        bump_direction_1 = 2*PI*UNI;
                    } else {
                        bump_direction_1 = t2_bump_direction;
                    }
                }
            }
            ssSetIWorkValue(S,10,stim_code_1);
            ssSetIWorkValue(S,11,stim_code_2);
            ssSetIWorkValue(S,12,bump_step_1);
            ssSetIWorkValue(S,13,bump_step_2);
            ssSetRWorkValue(S,7,bump_magnitude_1);
            ssSetRWorkValue(S,8,bump_magnitude_2); 
            ssSetRWorkValue(S,4,bump_direction_1);
            ssSetRWorkValue(S,5,bump_direction_2);
                      
            /* In all cases, we need to decide on the random timer durations */
	        if (center_hold_h == center_hold_l) {
	            center_hold = center_hold_h;
	        } else {
	            center_hold = center_hold_l + (center_hold_h - center_hold_l)*UNI;
	        }
            
            if (stim_delay_h == stim_delay_l) {
	            stim_delay = stim_delay_h;
	        } else {
	            stim_delay = stim_delay_l + (stim_delay_h - stim_delay_l)*UNI;
	        }            
            ssSetIWorkValue(S,14,stim_delay);
	        
			/* Setup the databurst */
			databurst[0] = 6 + 1 + 3*sizeof(float) + 1 + 9*sizeof(float);
            databurst[1] = DATABURST_VERSION;
			databurst[2] = BEHAVIOR_VERSION_MAJOR;
			databurst[3] = BEHAVIOR_VERSION_MINOR;
			databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
			databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            databurst[6] = training_mode;
			/* The offsets used in the calculation of the cursor location */
			uPtrs = ssGetInputPortRealSignalPtrs(S, 1); 
			databurst_offsets[0] = *uPtrs[0];
			databurst_offsets[1] = *uPtrs[1];
            databurst_target[0] = (int)first_target;
            databurst_target_size[0] = target_size;
            databurst_stim_delay[0] = stim_delay;
            databurst_bump_duration_1[0] = bump_duration_1;
            databurst_bump_duration_2[0] = bump_duration_2;
            
            databurst_stim_code_1[0] = stim_code_1;
            databurst_stim_code_2[0] = stim_code_2;
            databurst_bump_mag_1[0] = bump_magnitude_1;
            databurst_bump_mag_2[0] = bump_magnitude_2;
            databurst_bump_dir_1[0] = bump_direction_1;
            databurst_bump_dir_2[0] = bump_direction_2;      
     
			/* clear the counters */
            ssSetIWorkValue(S, 7, 0); /* Databurst counter */
            
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
            ssSetIWorkValue(S, 7, databurst_counter+1);
            break;
        case STATE_ORIGIN_ON:
            /* center target on */
            if (cursorInTarget(cursor, ct)) {
                new_state = STATE_CENTER_HOLD;
                reset_timer(); /* start center hold timer */
                state_changed();
            }
            break;
        case STATE_CENTER_HOLD:
            /* center hold */
            if (!cursorInTarget(cursor, ct)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > center_hold) {
                new_state = STATE_INTERVAL_1;
                reset_timer(); /* delay timer */
                state_changed();
            } 
            break;
        case STATE_INTERVAL_1:
            if (!cursorInTarget(cursor, ct)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > interval_length) {
                new_state = STATE_INTER_INTERVAL;
                reset_timer(); /* delay timer */
                state_changed();
            } 
            break;         
        case STATE_INTER_INTERVAL:
            if (!cursorInTarget(cursor, ct)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > interval_wait) {
                new_state = STATE_INTERVAL_2;
                reset_timer(); /* delay timer */
                state_changed();
            } 
            break;
        case STATE_INTERVAL_2:
            if (!cursorInTarget(cursor, ct)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > interval_length) {
                new_state = STATE_MOVEMENT;
                reset_timer(); /* delay timer */
                state_changed();
            } 
            break; 
        case STATE_MOVEMENT:           
            if (cursorInTarget(cursor, rt)) {
                new_state = STATE_REWARD;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (cursorInTarget(cursor, ft)) {
                new_state = STATE_FAIL;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > movement_time) {
                new_state = STATE_INCOMPLETE;
                reset_timer(); /* movement timer */
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
    
    /***********
     * Cleanup *
     ***********/
    
    /* write back new state */
    state_r[0] = new_state;
    
    /* Burn random number from stack */
    KISS;

    UNUSED_ARG(tid);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /********************
     *  Initialization
     ********************/
    int i;
        
    real_T ct[4];
    real_T rt[4];     /* reward outer target UL and LR coordinates */
    real_T ft[4];     /* fail outer target UL and LR coordinates */
    real_T ct_type;   /* type of center target 0=invisible 1=red square 2=lightning bolt (?) */
    real_T rt_type;   /* type of reward outer target 0=invisible 1=red square 2=lightning bolt (?) */
    real_T ft_type;   /* type of fail outer target 0=invisible 1=red square 2=lightning bolt (?) */
    real_T bump_direction_1;
    real_T bump_direction_2;
    real_T bump_duration_1;
    real_T bump_duration_2;
    int bump_duration;
    
    /* get trial type */
    int training_mode;
    int first_target;
    int bump_duration_counter;
    int interval_counter;
    real_T bump_magnitude_1;
    real_T bump_magnitude_2;
    real_T bump_magnitude;
    real_T bump_direction;
    
    int stim_code_1;
    int stim_code_2;
    int stim_code;
    
    int tone_cue_1;
    int tone_cue_2;
    
    int databurst_counter;
    byte* databurst;
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T force_in[2];
    
    /* allocate holders for outputs */
    real_T force_x, force_y, word, reward, tone_cnt, tone_id, pos_x, pos_y;
    real_T target_pos[45];
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
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)(state_r[0]);
    int new_state = ssGetIWorkValue(S, 0);
    ssSetIWorkValue(S, 0, 0); /* reset changed state each iteration */

    /* current trial type */
    first_target = ssGetIWorkValue(S, 9);
    bump_direction_1 = ssGetRWorkValue(S, 4);
    bump_direction_2 = ssGetRWorkValue(S, 5);
    training_mode = ssGetIWorkValue(S, 6);
            
    /* bump parameters */
    bump_duration_1 = 0;
    bump_duration_2 = 0;
    if (first_target == 1) {
        bump_duration_1 = t1_bump_duration;
        bump_duration_2 = t2_bump_duration;
        tone_cue_1 = t1_tone;        
        tone_cue_2 = t2_tone;
    } else {
        bump_duration_1 = t2_bump_duration;
        bump_duration_2 = t1_bump_duration;
        tone_cue_1 = t2_tone;
        tone_cue_2 = t1_tone;
    }
    bump_magnitude_1 = ssGetRWorkValue(S, 7);
    bump_magnitude_2 = ssGetRWorkValue(S, 8);
    bump_duration_counter = ssGetIWorkValue(S, 8);
   
    stim_code_1 = ssGetIWorkValue(S,10);
    stim_code_2 = ssGetIWorkValue(S,11);
    interval_counter = ssGetIWorkValue(S,14);
    
    /* apply appropriate stim/bump parameters */
    bump_magnitude = 0;
    bump_duration = 0;
    bump_direction = 0;
    stim_code = -1;
    if (state == STATE_INTERVAL_1){
        bump_magnitude = bump_magnitude_1;
        bump_duration = bump_duration_1;
        bump_direction = bump_direction_1;
        stim_code = stim_code_1;
    } else if (state == STATE_INTERVAL_2){
        bump_magnitude = bump_magnitude_2;
        bump_duration = bump_duration_2;
        bump_direction = bump_direction_2;
        stim_code = stim_code_2;
    }        
   
    /* get current tone counter */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);
    
    /* get target bounds */
    ct[0] = -target_size/2;
    ct[1] = target_size/2;
    ct[2] = target_size/2;
    ct[3] = -target_size/2;

    rt[0] = pow(-1,(float)first_target)*target_radius - target_size/2; /* reward target */
    rt[1] = target_size/2;
    rt[2] = pow(-1,(float)first_target)*target_radius + target_size/2;
    rt[3] = -target_size/2;

    ft[0] = pow(-1,(float)first_target+1)*target_radius - target_size/2; /* fail target */
    ft[1] = target_size/2;
    ft[2] = pow(-1,(float)first_target+1)*target_radius + target_size/2; 
    ft[3] = -target_size/2;   
        
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    force_in[0] = *uPtrs[0];
    force_in[1] = *uPtrs[1];
    
    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 7);
    databurst = (byte *)ssGetPWorkValue(S, 0);
    
    /********************
     * Calculate outputs
     ********************/
    
    if (state == STATE_INTERVAL_1 || state == STATE_INTERVAL_2){
        if (new_state){
            interval_counter = (int)stim_delay;
        } else {
            interval_counter--;           
        }
        ssSetIWorkValue(S,14,interval_counter);
    }
    
    /* force (0) */
    if (bump_magnitude) {
        if (bump_duration_counter > 0) {
            /* yes, so decrement the counter and maintain the bump */
            bump_duration_counter--;
            force_x = force_in[0] + cos(bump_direction)*bump_magnitude;
            force_y = force_in[1] + sin(bump_direction)*bump_magnitude;
        } else if ( (state == STATE_INTERVAL_1 || state == STATE_INTERVAL_2) && interval_counter == 0 ) {
            /* initiating a new bump */
            bump_duration_counter = (int)bump_duration;
            force_x = force_in[0] + cos(bump_direction)*bump_magnitude;
            force_y = force_in[1] + sin(bump_direction)*bump_magnitude;
        } else {
            force_x = force_in[0]; 
            force_y = force_in[1];
        }        
    } else {
        force_x = force_in[0]; 
        force_y = force_in[1];
    }
    
    /* status (1) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S,1, ssGetIWorkValue(S, 1)+1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, 3, ssGetIWorkValue(S, 3)+1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, 2, ssGetIWorkValue(S, 2)+1);
    if (state == STATE_INCOMPLETE && new_state)
        ssSetIWorkValue(S, 4, ssGetIWorkValue(S, 4)+1);
    
    
    status[0] = state;
    status[1] = ssGetIWorkValue(S, 1); /* num rewards     */
    status[2] = ssGetIWorkValue(S, 2); /* num fails       */
    status[3] = ssGetIWorkValue(S, 3); /* num aborts      */
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
            case STATE_ORIGIN_ON:
                word = WORD_CT_ON;
                break; 
            case STATE_INTERVAL_1:
                word = WORD_GO_CUE;
                break; 
            case STATE_MOVEMENT:
                word = WORD_GO_CUE;
                break;
            case STATE_INTERVAL_2:
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
            case STATE_INCOMPLETE:
                word = WORD_INCOMPLETE;
                break;
            default:
                word = 0;
        }

    } else {
        word = 0;
    }
    /* stim word (in the middle of interval states, bump start time can be calculated from stim delay*/
    if ((state == STATE_INTERVAL_1 || state == STATE_INTERVAL_2) && interval_counter == 0 && stim_code>-1){
        word = WORD_STIM(stim_code);    
    }
    if ((state == STATE_INTERVAL_1 && interval_counter == 0 && tone_cue_1) ||
        (state == STATE_INTERVAL_2 && interval_counter == 0 && tone_cue_2)){    	
        tone_cnt++;
        tone_id = TONE_GO; 
    }
       
    /* target_pos (3) */    
    /* start assuming no targets will be drawn */
    for (i = 0; i<15; i++)
        target_pos[i] = 0;
    
    if ( state == STATE_ORIGIN_ON || 
         state ==  STATE_CENTER_HOLD  ||
         state == STATE_INTER_INTERVAL)
    {
        /* center target on */
        target_pos[0] = 2;
        for (i=0; i<4; i++) {
           target_pos[i+1] = ct[i];
        }
    } else if (state == STATE_INTERVAL_1 ||
               state == STATE_INTERVAL_2) {
        /* center target on */
        if (ct_color_change){
            target_pos[0] = 3;  
        } else {
            target_pos[0] = 2;
        }
        for (i=0; i<4; i++) {
            target_pos[i+1] = ct[i];
        }
        
    } else if ( state == STATE_MOVEMENT) {
        /* center target off */
        target_pos[0] = 0;
        
        /* outer target(s) on */
        target_pos[5] = 2;
        for (i=0; i<4; i++) {
            target_pos[i+6] = rt[i];
        }
        if (!training_mode) {
            target_pos[10] = 2;
            for (i=0 ; i<4 ; i++){                
                target_pos[i+11] = ft[i];                
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

    /* pos (7) */
    if ( (state ==  STATE_INTERVAL_1 || state == STATE_INTERVAL_2) && sqrt(cursor[0]*cursor[0]+cursor[1]*cursor[1]) < window_size) {
        /* we are inside blocking window => draw cursor off screen */
        pos_x = 1E6;
        pos_y = 1E6;
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
    ssSetIWorkValue(S, 8, bump_duration_counter);
    
    status_p = ssGetOutputPortRealSignal(S,1);
    for (i=0; i<5; i++) 
        status_p[i] = status[i];
    
    word_p = ssGetOutputPortRealSignal(S,2);
    word_p[0] = word;
    
    target_p = ssGetOutputPortRealSignal(S,3);
    for (i=0; i<45; i++) {
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
