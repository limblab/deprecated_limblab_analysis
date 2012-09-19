/* $Id: mastercon_bf.c 851 2012-04-04 22:52:59Z brian $
 *
 * Master Control block for behavior: bump follow task
 */

#define S_FUNCTION_NAME mastercon_bf
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "simstruc.h"

#define TASK_BF 1
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
 * byte 0: uchar => number of bytes to be transmitted (in this case 11)
 * byte 1: uchar => version number (in this case zero)
 * byte 2: uchar => training trial (1 if training, 0 if not)
 * bytes 3-6: float => target angle (rad)
 * bytes 7-10: float => bump magnitude (bump units?)
 *
 * Version 1 (0x01)
 * ----------------
 * byte   0: uchar => number of bytes to be transmitted
 * byte   1: uchar => databurst version number (in this case one)
 * byte   2: uchar => model version major
 * byte   3: uchar => model version minor
 * bytes  4 to  5: short => model version micro
 * byte   6: uchar => training trial (1 if training, 0 if not)
 * bytes  7 to 10: float => x offset
 * bytes 11 to 14: float => y offset
 * bytes 15 to 18: float => target angle (rad)
 * bytes 19 to 22: float => bump magnitude (bump units?)
 */

typedef unsigned char byte;
#define DATABURST_VERSION ((byte)0x01) 

/*
 * Until we implement tunable parameters, these will act as defaults
 */

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,0))

/* Target parameters */
static real_T arc_radius = 10.0; /* inner radius of target arc in cm */
#define param_arc_radius mxGetScalar(ssGetSFcnParam(S,1))
static real_T arc_thickness = 3.0;    /* thickness or arc in cm */
#define param_arc_thickness mxGetScalar(ssGetSFcnParam(S,2))
static real_T arc_length = 1.0; /* length of arc in radians */
#define param_arc_length mxGetScalar(ssGetSFcnParam(S,3))
static real_T center_target_size = 2.0; /* size of center target in cm*/
#define param_center_target_size mxGetScalar(ssGetSFcnParam(S,4))
static real_T window_size = 5.0;   /* diameter of blocking circle */
#define param_window_size mxGetScalar(ssGetSFcnParam(S,5))

/* Bump parameters */
#define param_bump_steps ((int)(mxGetScalar(ssGetSFcnParam(S,6))) <= 7 ? (int)(mxGetScalar(ssGetSFcnParam(S,6))) : 7)
static int bump_steps = 7;
#define param_bump_magnitude_min mxGetScalar(ssGetSFcnParam(S,7))
static real_T bump_magnitude_min = 0.0;
#define param_bump_magnitude_max mxGetScalar(ssGetSFcnParam(S,8))
static real_T bump_magnitude_max = 0.05;
#define param_bump_duration mxGetScalar(ssGetSFcnParam(S,9))
static real_T bump_duration = 125;

/* Timing parameters */
static real_T center_hold;
static real_T center_hold_l = 0.5; /* shortest delay between entry of ct and bump/stim */ 
#define param_center_hold_l mxGetScalar(ssGetSFcnParam(S,10))
static real_T center_hold_h = 1.0; /* longest delay between entry of ct and bump/stim */ 
#define param_center_hold_h mxGetScalar(ssGetSFcnParam(S,11))
static real_T movement_time = 10;  /* movement time */
#define param_movement_time mxGetScalar(ssGetSFcnParam(S,12))
#define param_intertrial mxGetScalar(ssGetSFcnParam(S,13)) /* time between trials*/
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T center_bump_timeout  = 1.0; 
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */

static real_T failure_timeout = 1.0;    /* delay after failure */
#define param_fail_intertrial mxGetScalar(ssGetSFcnParam(S,14)) /* time between trials*/

/* General parameters */
static real_T pct_training_trials = 0.0; /* true=show arc , false=show full circle  */
#define param_pct_training_trials mxGetScalar(ssGetSFcnParam(S,15))

/* Stimulation parameters */
static real_T pct_stim_trials = 0.0; /* percentage of trials to stimulate */
#define param_pct_stim_trials mxGetScalar(ssGetSFcnParam(S,16))

/* Update counter */
static real_T master_update = 0.0;
#define param_master_update mxGetScalar(ssGetSFcnParam(S,17))

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_ORIGIN_ON 1
#define STATE_CENTER_HOLD 2
#define STATE_BUMP_STIM 3
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

static void mdlCheckParameters(SimStruct *S)
{
    arc_radius = param_arc_radius;
    arc_thickness = param_arc_thickness;
    arc_length = param_arc_length;
    center_target_size = param_center_target_size;
    window_size = param_window_size;
    
    bump_steps = (int)param_bump_steps;
    bump_magnitude_min = param_bump_magnitude_min;
    bump_magnitude_max = param_bump_magnitude_max;
    bump_duration = param_bump_duration;
    
    pct_training_trials = param_pct_training_trials;
    pct_stim_trials = param_pct_stim_trials;
    
    center_hold_l = param_center_hold_l;
    center_hold_h = param_center_hold_h;
    movement_time = param_movement_time;

    abort_timeout   = param_intertrial;    
    failure_timeout = param_fail_intertrial;
    reward_timeout  = param_intertrial;   
    incomplete_timeout = param_intertrial;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 18);
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
    if (!ssSetNumInputPorts(S, 5)) return;
    ssSetInputPortWidth(S, 0, 2);
    ssSetInputPortWidth(S, 1, 2);
    ssSetInputPortWidth(S, 2, 2);
	ssSetInputPortWidth(S, 3, 2);
    ssSetInputPortWidth(S, 4, 32);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);
    
    /* 
     * Block has 8 output ports (force, status, word, targets, reward, tone, version, pos) of widths:
     *  force: 2
     *  status: 5 ( block counter, successes, aborts, failures, incompletes )
     *  word:  1 (8 bits)
     *  target: 15 ( center target, full circle, arc: 
     *                  on/off, 
     *                  target UL corner x or arc first corner (CCW) inner x, 
     *                  target UL corner y or arc first corner inner y,
     *                  target LR corner x or arc second corner outer x, 
     *                  target LR corner y or arc second corner outer y)
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
    ssSetNumRWork(S, 7);  /* 0: time of last timer reset 
                             1: tone counter (incremented each time a tone is played)
                             2: tone id
							 3: mastercon version
                             4: bump direction
                             5: bump magnitude   
                             6: master update counter                        
                           */
    ssSetNumPWork(S, 1);   /* 0: pointer to databurst array
                            */
    
    ssSetNumIWork(S, 28);     /* 0: state_transition (true if state changed), 
                                1: successes
                                2: failures
                                3: aborts
                                4: incompletes   
                                5: bump step 
                                6: training mode
                                7: databurst counter
                                8: bump duration counter
                                9: stim trial
                                10: stim index
                                11-26: stim list
                                27: debugging info
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
    
    /* set stim index to 16 so that it gets reset in pretrial*/
    ssSetIWorkValue(S,10,16);    
    
    ssSetIWorkValue(S,27,-1);
    
    /* set the initial last update time to 0 */
    ssSetRWorkValue(S,6,0.0);    
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

static int cursorInArc(real_T *c, real_T *a)
{
    /* a[0] = arc center angle(rad), a[1] = arc length(rad) */
    if ( fmod(a[0]+a[1]/2+PI,2*PI) -PI >  fmod(a[0]-a[1]/2+PI,2*PI)-PI ) {
        return ( fmod(a[0]+a[1]/2+PI,2*PI)-PI > atan2(c[1],c[0]) && fmod(a[0]-a[1]/2+PI,2*PI)-PI < atan2(c[1],c[0]) );
    } else {
        return ( fmod(a[0]+a[1]/2+PI,2*PI)-PI > atan2(c[1],c[0]) || fmod(a[0]-a[1]/2+PI,2*PI)-PI < atan2(c[1],c[0]) );
    }    
}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
    /********************
     * Declarations     *
     ********************/
    
    /* stupidly declare all variables at the begining of the function */
    int i;
    int j;
    
    real_T ct[4];
    real_T ra[2];     /* reward arc center angle and arc length*/
        
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    int reset_block = 0;
    
    /* get trial parameters */
    real_T bump_magnitude;
    int bump_step;
    int training_mode;
    real_T bump_direction;
    
    /* stimulation parameters */
    int stim_index;
    int stim_codes[16];
    real_T pref_dirs[16];
    int num_stim_codes;
    int stim_trial;
    int tmp_sort[16];
    int tmp;
    int stim_code_list_tmp[16];
        
    /* databurst variables */
    byte *databurst;
	float *databurst_offsets;
    float *databurst_angle;
    float *databurst_bump_mag;
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
    bump_direction = ssGetRWorkValue(S,4);
    bump_step = ssGetIWorkValue(S,5);
    training_mode = ssGetIWorkValue(S,6);
    bump_magnitude = ssGetRWorkValue(S,5);    
    stim_trial = ssGetIWorkValue(S,9);
    stim_index = ssGetIWorkValue(S,10); 
    
    if ( param_master_update > master_update ) {
        master_update = param_master_update;
        ssSetRWorkValue(S, 6, (real_T)ssGetT(S));
        stim_index = 16;
    }
    
    /* get stimulation parameters */
    uPtrs = ssGetInputPortRealSignalPtrs(S,4);
    for (i=0 ; i<16 ; i++) { 
        stim_codes[i] = (int)*uPtrs[2*i];
        pref_dirs[i] = *uPtrs[2*i+1];
    }
                
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
        
    /* get target bounds */
    ct[0] = -center_target_size/2;
    ct[1] = center_target_size/2;
    ct[2] = center_target_size/2;
    ct[3] = -center_target_size/2;
       
    ra[0] = bump_direction+PI; /* reward arc */
    ra[1] = arc_length;    
        
    /* databurst pointers */
    databurst_counter = ssGetIWorkValue(S, 7);
    databurst = ssGetPWorkValue(S, 0);
	databurst_offsets  = (float *)(databurst + 7);
    databurst_angle    = databurst_offsets + 2;
    databurst_bump_mag = databurst_angle + 1;
    
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
            arc_radius = param_arc_radius;
            arc_thickness = param_arc_thickness;
            arc_length = param_arc_length;
            center_target_size = param_center_target_size;
            window_size = param_window_size;

            bump_steps = param_bump_steps;
            bump_magnitude_min = param_bump_magnitude_min;
            bump_magnitude_max = param_bump_magnitude_max;
            bump_duration = param_bump_duration;

            pct_training_trials = param_pct_training_trials;
            pct_stim_trials = param_pct_stim_trials;

            center_hold_l = param_center_hold_l;
            center_hold_h = param_center_hold_h;
            movement_time = param_movement_time;

            abort_timeout   = param_intertrial;    
            failure_timeout = param_fail_intertrial;
            reward_timeout  = param_intertrial;   
            incomplete_timeout = param_intertrial;
            
            /* decide if it is a training trial */
            training_mode = (UNI<pct_training_trials) ? 1 : 0;
            ssSetIWorkValue(S,6,training_mode);
            
            /* decide if it is a stim trial */
            stim_trial = (UNI<pct_stim_trials ? 1 : 0);
            ssSetIWorkValue(S,9,stim_trial);
                                    
            /* check how many valid stim codes there are */                       
            num_stim_codes = 0;
            for (i=0 ; i<16 ; i++) { 
                if (stim_codes[i] != -1) {
                    num_stim_codes++;
                } else {
                    break;
                }
            }
                        
            /* check if stimulation block needs to be reinitialized */
            if ( stim_index >= num_stim_codes-1 ) {
                /* reset stim index */
                stim_index = -1;
                ssSetIWorkValue(S,10,stim_index);
                /* block randomization of stims */
                for (i=0; i<num_stim_codes; i++) {                    
                    tmp_sort[i] = rand();
                    stim_code_list_tmp[i] = i; /*stim_codes[i];*/
                }
                
                for (i=0; i<num_stim_codes-1; i++) {
                    for (j=0; j<num_stim_codes-1; j++) { 
                        if (tmp_sort[j] < tmp_sort[j+1]) {   
                            tmp = tmp_sort[j];
                            tmp_sort[j] = tmp_sort[j+1];
                            tmp_sort[j+1] = tmp;
                            
                            tmp = stim_code_list_tmp[j];
                            stim_code_list_tmp[j] = stim_code_list_tmp[j+1];
                            stim_code_list_tmp[j+1] = tmp;
                        }
                    }
                }
                /* write them back */
                for (i=0; i<num_stim_codes; i++) {
                    ssSetIWorkValue(S,11+i,stim_code_list_tmp[i]);
	            }                                
            }         
            
            if (stim_trial){ 
                stim_index++;
                bump_direction = pref_dirs[ssGetIWorkValue(S,11+stim_index)];
                ssSetIWorkValue(S,10,stim_index);
            } else {
                /* give a random direction to next target */ 
                bump_direction = 2*PI*UNI;                
            }                       
            ssSetRWorkValue(S,4,bump_direction);
                                                                 
            /* get a random bump step */
            bump_step = (int)(UNI*bump_steps);
            ssSetIWorkValue(S,5,bump_step);
            
            bump_magnitude = bump_magnitude_min + ((float)bump_step)*(bump_magnitude_max-bump_magnitude_min)/((float)bump_steps-1);
            ssSetRWorkValue(S,5,bump_magnitude);
            
            /* In all cases, we need to decide on the random timer durations */
	        if (center_hold_h == center_hold_l) {
	            center_hold = center_hold_h;
	        } else {
	            center_hold = center_hold_l + (center_hold_h - center_hold_l)*UNI;
	        }
	                        
            /* Setup the databurst */
			databurst[0] = 6+1+4*sizeof(float);
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
            databurst_angle[0] = bump_direction;
            databurst_bump_mag[0] = bump_magnitude;
            
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
                new_state = STATE_BUMP_STIM;
                reset_timer(); /* delay timer */
                state_changed();
            } 
            break;
        case STATE_BUMP_STIM:
            /* stimulation */
            if (sqrt(cursor[0]*cursor[0]+cursor[1]*cursor[1]) > arc_radius) {
                if (cursorInArc(cursor, ra)) {            
                    new_state = STATE_REWARD;
                    reset_timer(); /* abort timeout */
                    state_changed();
                } else {
                    new_state = STATE_FAIL;
                    reset_timer(); /* abort timeout */
                    state_changed();
                }
            } else if (elapsed_timer_time > bump_duration/1000) {
                new_state = STATE_MOVEMENT;
                reset_timer(); /* movement timer */
                state_changed();
            }
            break;
        case STATE_MOVEMENT:
            /* movement phase (go tone on entry) */
            if (sqrt(cursor[0]*cursor[0]+cursor[1]*cursor[1]) > arc_radius) {
                if (cursorInArc(cursor, ra)) {
                    new_state = STATE_REWARD;
                    reset_timer(); /* reward timeout */
                    state_changed();			
                } else {			
                    new_state = STATE_FAIL;
                    reset_timer(); /* incomplete timeout */
                    state_changed();
                }
			} else if (elapsed_timer_time > movement_time) {
				new_state = STATE_INCOMPLETE;
                reset_timer(); /* incomplete timeout */
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
            if (bump_magnitude == 0 && !stim_trial && elapsed_timer_time > abort_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
            } else if (elapsed_timer_time > failure_timeout) {
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
    real_T ra[4];     /* Reward arc [CCWmost inner corner x and y, CWmost outer corner x and y]*/
    real_T fa[4];     /* Fail arc [CCWmost inner corner x and y, CWmost outer corner x and y]*/
    real_T ct_type;   /* type of center target 0=invisible 1=red square 2=lightning bolt (?) 5=arc */
    real_T rt_type;   /* type of left outer target 0=invisible 1=red square 2=lightning bolt (?) */
    real_T ft_type;   /* type of right outer target 0=invisible 1=red square 2=lightning bolt (?) */
    real_T bump_direction;
    
    /* get trial type */
    int training_mode;
    int stim_trial;
    int bump_duration_counter;
    real_T bump_magnitude;
    int bump_step;
    
    int stim_codes[16];
    real_T pref_dirs[16];
    int stim_index;
    int stim_code;
    real_T pref_dir;
    
    int databurst_counter;
    byte* databurst;
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T force_in[2];
    
    /* allocate holders for outputs */
    real_T force_x, force_y, word, reward, tone_cnt, tone_id, pos_x, pos_y;
    real_T target_pos[15];
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
    bump_direction = ssGetRWorkValue(S,4);
    training_mode = ssGetIWorkValue(S,6);
            
    /* bump parameters */
    bump_magnitude = ssGetRWorkValue(S,5);
    bump_duration_counter = ssGetIWorkValue(S, 8);
    bump_step = ssGetIWorkValue(S, 5);
    
    /* get stimulation parameters */
    uPtrs = ssGetInputPortRealSignalPtrs(S,4);
    for (i=0 ; i<16 ; i++) { 
        stim_codes[i] = *uPtrs[2*i];
        pref_dirs[i] = *uPtrs[2*i+1];
    }
    
    /* stim parameters */
    stim_trial = ssGetIWorkValue(S,9);
    stim_index = ssGetIWorkValue(S,10);
    stim_code = stim_codes[ssGetIWorkValue(S,11+stim_index)];
    pref_dir = pref_dirs[ssGetIWorkValue(S,11+stim_index)];
   
    /* get current tone counter */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);
    
    /* get target bounds */
    ct[0] = -center_target_size/2;
    ct[1] = center_target_size/2;
    ct[2] = center_target_size/2;
    ct[3] = -center_target_size/2;
    
    ra[0] = arc_radius*cos(bump_direction+PI-arc_length/2);
    ra[1] = arc_radius*sin(bump_direction+PI-arc_length/2);
    ra[2] = (arc_radius + arc_thickness)*cos(bump_direction+PI+arc_length/2);
    ra[3] = (arc_radius + arc_thickness)*sin(bump_direction+PI+arc_length/2);
    
    fa[0] = arc_radius*cos(bump_direction+PI+arc_length/2);
    fa[1] = arc_radius*sin(bump_direction+PI+arc_length/2);
    fa[2] = (arc_radius + arc_thickness)*cos(bump_direction+PI-arc_length/2);
    fa[3] = (arc_radius + arc_thickness)*sin(bump_direction+PI-arc_length/2);     
        
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
    
    /* force (0) */
    if (!stim_trial) {
        if (bump_duration_counter > 0) {
            /* yes, so decrement the counter and maintain the bump */
            bump_duration_counter--;
            force_x = force_in[0] + cos(bump_direction)*bump_magnitude;
            force_y = force_in[1] + sin(bump_direction)*bump_magnitude;
        } else if ( state == STATE_BUMP_STIM && new_state ) 
        {
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
            case STATE_BUMP_STIM:
                word = (stim_trial ? WORD_STIM(stim_code) : WORD_BUMP(bump_step)); 
                break;
            case STATE_MOVEMENT:
                /* toggle debugging var 
                ssSetIWorkValue(S,27,ssGetIWorkValue(S,27)+1); */
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
       
    /* target_pos (3) */    
    /* start assuming no targets will be drawn */
    for (i = 0; i<15; i++)
        target_pos[i] = 0;
    
    if ( state == STATE_ORIGIN_ON)
    {
        /* center target on */
        target_pos[0] = 2;
        for (i=0; i<4; i++) {
           target_pos[i+1] = ct[i];
        }
    } else if (state == STATE_CENTER_HOLD) {
        /* center target on */
        target_pos[0] = 2;
        for (i=0; i<4; i++) {
           target_pos[i+1] = ct[i];
        }
        /* outer target on */
        target_pos[5] =5; 
        for (i=0; i<4; i++) {
            target_pos[i+6] = ra[i];
        }
        if (!training_mode) {      
            target_pos[10] = 5; 
        }        
        for (i=0; i<4; i++) {
            target_pos[i+11] = fa[i];
        }
    } else if ( state == STATE_MOVEMENT  ||
         state == STATE_BUMP_STIM) {
        /* center target off */
        target_pos[0] = 0;
        for (i=0; i<4; i++) {
           target_pos[i+1] = ct[i];
        }
        /* outer target on */
        target_pos[5] = 5;    
        for (i=0; i<4; i++) {
            target_pos[i+6] = ra[i];
        }
        if (!training_mode) {                   
            target_pos[10] = 5; 
        }
        for (i=0; i<4; i++) {
            target_pos[i+11] = fa[i];
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
        } else if (state == STATE_BUMP_STIM) {
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
    if ( (state == STATE_BUMP_STIM || state == STATE_MOVEMENT) && sqrt(cursor[0]*cursor[0]+cursor[1]*cursor[1]) < window_size) {
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
    for (i=0; i<15; i++) {
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
