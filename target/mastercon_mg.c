/* mastercon_mg.c
 
 * Master Control block for behavior: multi-gadget
 */

#define S_FUNCTION_NAME mastercon_mg
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include "simstruc.h"

#define TASK_MG 1
#include "words.h"
#include "random_macros.h"

#define PI (3.141592654)

/* 
 * Current Databurst version: 4
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
 * byte 0: uchar => number of bytes to be transmitted
 * byte 1: uchar => version number (in this case one)
 * bytes 2 to 2+ N*16: where N is the number of targets whose position are output.
 *		contains 16 bytes per target representing four single precision floating point
 *		numbers in little-endian format representing UL x, UL y, LR x and LR y coordinates
 *		of the UL and LR corners of the target.
 *
 *		The position of only the current target is output at the begining of each trial
 *		in normal behavior, but in multiple target mode, all the targets
 *		are included in the databurst
 *
 *		In MVC mode, the current value of the MVC target is provided in the databurst
 *
 * Version 2 (0x02)
 * ----------------
 * byte 0: uchar => number of bytes to be transmitted
 * byte 1: uchar => version number (in this case one)
 * bytes 2 to 2+ N*16: where N is the number of targets whose position are output.
 *		contains 16 bytes per target representing four single precision floating point
 *		numbers in little-endian format representing UL x, UL y, LR x and LR y coordinates
 *		of the UL and LR corners of the target.
 *
 *		The position of only the current target is output at the begining of each trial
 *		in normal behavior, but in multiple target mode, all the targets
 *		are included in the databurst
 *
 *		In MVC mode, the current value of the MVC target is provided in the databurst
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
 * byte  0: uchar => number of bytes to be transmitted
 * byte  1: uchar => databurst version number (in this case four)
 * byte  2: uchar => model version major
 * byte  3: uchar => model version minor
 * bytes 4 to  5: short => model version micro
 * bytes 6 to 21: 16 bytes per target representing four single precision floating point
 *		numbers in little-endian format representing UL x, UL y, LR x and LR y coordinates
 *		of the UL and LR corners of the target.
 *
 *		The position of only the current target is output at the begining of each trial
 *		in normal behavior.
 *
 *		In MVC mode, the current value of the MVC target is provided in the databurst
 */

typedef unsigned char byte;
#define DATABURST_VERSION ((byte)0x04) 

/*
 * Tunable parameters
 */
static real_T num_targets = 8;      /* total number of targets from which to select */
#define param_num_targets mxGetScalar(ssGetSFcnParam(S,0)) 
 
static real_T touch_pad_hold_l = .5;
#define param_touch_pad_hold_l mxGetScalar(ssGetSFcnParam(S,1))
static real_T touch_pad_hold_h = .5;
#define param_touch_pad_hold_h mxGetScalar(ssGetSFcnParam(S,2))

static real_T touch_pad_delay_l = .5;
#define param_touch_pad_delay_l mxGetScalar(ssGetSFcnParam(S,3))
static real_T touch_pad_delay_h = .5;
#define param_touch_pad_delay_h mxGetScalar(ssGetSFcnParam(S,4))

static real_T reach_time = .5;          /* Time to reach AND hold target*/
#define param_reach_time mxGetScalar(ssGetSFcnParam(S,5))
static real_T target_hold_time = .5;
#define param_target_hold_time mxGetScalar(ssGetSFcnParam(S,6))

#define param_intertrial mxGetScalar(ssGetSFcnParam(S,7))
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T failure_timeout = 1.0;    /* delay after failure */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */

static real_T use_gadget_0 = 1.0;
#define param_use_gadget_0 mxGetScalar(ssGetSFcnParam(S,8))
static real_T use_gadget_1 = 1.0;
#define param_use_gadget_1 mxGetScalar(ssGetSFcnParam(S,9))
static real_T use_gadget_2 = 1.0;
#define param_use_gadget_2 mxGetScalar(ssGetSFcnParam(S,10))
static real_T use_gadget_3 = 1.0;
#define param_use_gadget_3 mxGetScalar(ssGetSFcnParam(S,11))

#define num_gadgets_in_use ( ( use_gadget_0 ? 1 : 0 ) + ( use_gadget_1 ? 1 : 0 ) + ( use_gadget_2 ? 1 : 0 ) + ( use_gadget_3 ? 1 : 0 ) )

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,12))

static real_T idiot_mode = 0.0;
#define param_idiot_mode mxGetScalar(ssGetSFcnParam(S,13))

static real_T multiple_targets = 0.0;
#define param_multiple_targets mxGetScalar(ssGetSFcnParam(S,14))

static real_T clear_MVC_tgts = 0.0;
#define param_clear_MVC_tgts mxGetScalar(ssGetSFcnParam(S,15))

static real_T catch_trials_pct = 0.0;
#define param_catch_trials_pct mxGetScalar(ssGetSFcnParam(S,16))

// static real_T master_update = 0.0;
// #define param_master_update mxGetScalar(ssGetSFcnParam(S,17))

#define set_catch_trial(x) ssSetIWorkValue(S, 134, (x))
#define get_catch_trial() ssGetIWorkValue(S, 134)


/*
 * State IDs
 */
#define STATE_PRETRIAL          0
#define STATE_TOUCH_PAD_ON      1
#define STATE_TOUCH_PAD_HOLD    2
#define STATE_DELAY             3
#define STATE_REACH             4
#define STATE_MOVEMENT          5
#define STATE_TARGET_HOLD       6  
#define STATE_CONTINUE_REACH    7
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

  touch_pad_hold_l = param_touch_pad_hold_l;
  touch_pad_hold_h = param_touch_pad_hold_h;

  touch_pad_delay_l = param_touch_pad_delay_l;
  touch_pad_delay_h = param_touch_pad_delay_h;

  reach_time = param_reach_time;
  target_hold_time = param_target_hold_time;

  abort_timeout      = param_intertrial;
  failure_timeout    = param_intertrial;
  incomplete_timeout = param_intertrial;
  reward_timeout     = param_intertrial;    

  use_gadget_0 = param_use_gadget_0;
  use_gadget_1 = param_use_gadget_1;
  use_gadget_2 = param_use_gadget_2;
  use_gadget_3 = param_use_gadget_3;

  idiot_mode = param_idiot_mode;
  multiple_targets = param_multiple_targets;
  catch_trials_pct = param_catch_trials_pct;
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
     * Block has 3 input ports
     *      input port 0: (touch pad) of width 1 (true if touchpad pressed)
     *      input port 1: (position) of width 2 (x, y)
     *      input port 2: (target) of width 6 (vertical displacement, height, horiz disp, width, x var, y var)
     */
    if (!ssSetNumInputPorts(S, 3)) return;
    ssSetInputPortWidth(S, 0, 1); /* touch pad */
    ssSetInputPortWidth(S, 1, 2); /* cursor position */
    ssSetInputPortWidth(S, 2, 5*16); /* target position */
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);
    
    /* 
     * Block has 10 output ports (reward, word, touch pad LED, gadget LED, gadget select, status, tone, target, MVC Target, version) of widths:
     * 0: reward:         1
     * 1: word:           1
     * 2: touch pad LED:  1
     * 3: gadget LED:     1
     * 4: gadget select:  1
     * 5: status:         4 ( 1: state, 2: rewards, 3: aborts 4: failures )
     * 6: tone:           2 ( 1: counter incemented for each new tone, 2: tone ID )     
     * 7: target: 10 ( target 1, 2: 
     *                  type, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)
	 * 8: MVC Target: 4 (MVC gadgets 1 to 4)
	 * 9:version : 4
     */
    if (!ssSetNumOutputPorts(S, 10)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortWidth(S, 2, 1);
    ssSetOutputPortWidth(S, 3, 1);
    ssSetOutputPortWidth(S, 4, 1);
    ssSetOutputPortWidth(S, 5, 4);
    ssSetOutputPortWidth(S, 6, 2);
    ssSetOutputPortWidth(S, 7, 10);
    ssSetOutputPortWidth(S, 8, 4);
    ssSetOutputPortWidth(S, 9, 4);
    
    ssSetNumSampleTimes(S, 1);
    
    /* work buffers */
    ssSetNumRWork(S, 37);  /*  0: time of last timer reset
                               1: time of last target hold timer reset 
                               2: tone counter (incremented each time a tone is played)
                               3: tone id
                               4: current touch pad hold time
                               5: current delay hold time
                                 // About Following MVC Target related buffers:
                                 // 1-4 subscripts refers to corresponding gadget number
                                 // i.e. one MVC target per gadget
                               6-13: User specified MVC targets [x1 x2 x3 x4 y1 y2 y3 y4]
                               14-21: Current MVC targets [x1 x2 x3 x4 y1 y2 y3 y4]
                               22-29: higher MVC targets reached [x1 x2 x3 x4 y1 y2 y3 y4]
                               30: mastercon version
                               31: Time of last update
							   32-36: The current target: [target_y, target_h, target_x, target_w, tgt_yVar_enabled]
                           */
    ssSetNumPWork(S, 1);   /*  0: Databurst array pointer
                           */ 
    ssSetNumIWork(S, 135); /*  0: state_transition (true if state changed), 
                               1: current target index (in sequence),
                               2: successes
                               3: aborts
                               4: failures 
                         [5-132]: trial list (target, gadget...)
                             133: success_flag
                             134: catch_trial_flag
                             135: datablock counter
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
    for (i=6; i<30; i++) {
	    ssSetRWorkValue(S, i, 0.0);
    }
    /* set the initial last update time to 0 */
    ssSetRWorkValue(S,31,0.0);
    
    /* initialize targets id lists at zero */
    for (i = 5 ; i<133 ; i++){
        ssSetIWorkValue(S, i, 0);
    }
    
    /* set trial counters to zero */
    ssSetIWorkValue(S, 2, 0);
    ssSetIWorkValue(S, 3, 0);
    ssSetIWorkValue(S, 4, 0);
    
    /* initialize success flag at zero */
    ssSetIWorkValue(S, 133, 0);
    
    /* set catch trial flag to zero */
    ssSetIWorkValue(S,134,0);
    
    /* set reset counter to zero */
    clear_MVC_tgts = 0.0;
    master_reset = 0.0;
    
    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 135, 0);
    
}

/* macro for setting state changed */
#define state_changed() (ssSetIWorkValue(S, 0, 1))
/* macros for resetting timers */
#define reset_timer() (ssSetRWorkValue(S, 0, (real_T)ssGetT(S)))
#define reset_target_hold_timer() (ssSetRWorkValue(S, 1, (real_T)ssGetT(S)))

#define success_flag() (ssSetIWorkValue(S, 133, 1))
/* Macro for assigning random center hold time */

/* cursorInTarget
 * returns true (1) if the cursor is in the target and false (0) otherwise
 * cursor is specified as x, y = c[0], c[1]
 * target is specified by two corners: UL: x, y = t[0], t[1]
 *                                     LR: x, y = t[2], t[3]
 */
#define cursorInTarget(c, t) ( ((c)[0] > (t)[0]) && ((c)[1] < (t)[1]) && ((c)[0] < (t)[2]) && ((c)[1] > (t)[3]) )


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
    int target_id, gadget_id;
    int *target_list;
    int tgt_yVar_enabled;
    real_T target_x, target_y, target_h, target_w;
    real_T tgt[4];
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T touch_pad; // should be 0.0 if touch pad is not pressed, 1.0 if it is.
    real_T elapsed_timer_time;
    real_T elapsed_target_hold_time;
    real_T touch_pad_hold_timeout;
    real_T delay_timeout;    
    real_T success_flag;

    //holders for MVC targets variables (y_values only)
	real_T user_spec_MVC_targets[4];
    real_T current_MVC_targets[4];
    real_T higher_MVC_targets[4];
    
    int tmp_tgts[64];
    int tmp_gdgt[64];
    int tmp_i;
    double tmp_sort[64];
    double tmp_d;
        
    byte *databurst;
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
    
    /* touch pad state */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    touch_pad = *uPtrs[0];
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 1);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* Current target/gadget index */
    target_index = ssGetIWorkValue(S, 1);
    target_id = ssGetIWorkValue(S, 5 + target_index*2);
    gadget_id = ssGetIWorkValue(S, 6 + target_index*2);
    IWorkVector = ssGetIWork(S);
    target_list = IWorkVector+5;
    
    /* Success Flag */
    success_flag = ssGetIWorkValue(S, 133);
    
    /* Get the Current Target Location */
	target_y = ssGetRWorkValue(S,32);
    target_h = ssGetRWorkValue(S,33);
    target_x = ssGetRWorkValue(S,34);
    target_w = ssGetRWorkValue(S,35);
    tgt_yVar_enabled = (int)ssGetRWorkValue(S,36);
    
	/* Define the target corners */
	tgt[0] = target_x - target_w / 2.0;
	tgt[1] = target_y + target_h / 2.0;
	tgt[2] = target_x + target_w / 2.0;
	tgt[3] = target_y - target_h / 2.0;
	
    /*MVC Targets variables*/
    for (i=0; i<4; i++) {
	    user_spec_MVC_targets[i]= ssGetRWorkValue(S,i+10);
    	current_MVC_targets[i]  = ssGetRWorkValue(S,i+18);
    	higher_MVC_targets[i]   = ssGetRWorkValue(S,i+26);
	}  
              
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    elapsed_target_hold_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 1);

    /* read current timeouts */
    touch_pad_hold_timeout = ssGetRWorkValue(S, 4);
    delay_timeout = ssGetRWorkValue(S, 5);

    /* Setup the databurst pointers */
    databurst_counter = ssGetIWorkValue(S, 135);
    databurst = ssGetPWorkValue(S, 0);
    databurst_target_list = (float *)(databurst + 6);
    
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
	    for (i=6; i<30; i++) {
		    ssSetRWorkValue(S, i, 0.0); //clear all MVC target buffers
	    }
	}
     
    
    /************************
     * Calculate next state *
     ************************/
    
    /* execute one step of state machine */
    switch (state) {
        case STATE_PRETRIAL:
            /* Initialize the trial and then advance to STATE_DATA_BLOCK */
            
                /* Update parameters */        
            touch_pad_hold_l = param_touch_pad_hold_l;
            touch_pad_hold_h = param_touch_pad_hold_h;
            touch_pad_delay_l = param_touch_pad_delay_l;
            touch_pad_delay_h = param_touch_pad_delay_h;
            reach_time = param_reach_time;
            target_hold_time = param_target_hold_time;
            abort_timeout   = param_intertrial;    
            failure_timeout = param_intertrial;
        	reward_timeout = param_intertrial;
        
            catch_trials_pct = param_catch_trials_pct/100;
            idiot_mode = param_idiot_mode;
            

			/* intialize timers*/
            if (touch_pad_hold_l == touch_pad_hold_h) { 
                ssSetRWorkValue(S, 4, touch_pad_hold_l);
            } else {
                ssSetRWorkValue(S, 4, touch_pad_hold_l + UNI*(touch_pad_hold_h-touch_pad_hold_l));
            }
            if (touch_pad_delay_l == touch_pad_delay_h) { 
                ssSetRWorkValue(S, 5, touch_pad_delay_l);
            } else {
                ssSetRWorkValue(S, 5, touch_pad_delay_l + UNI*(touch_pad_delay_h-touch_pad_delay_l));
            }

            /* Only update these values if we've explicitly issued an update */
//             if ( param_master_update > master_update ) {
//                 master_update = param_master_update;
//                 ssSetRWorkValue(S, 30, ssGetT(S));
// 				reshuffle = 1;
//             }

            
			/* decide if this is going to be a catch trial */
            set_catch_trial( catch_trials_pct > (double)rand()/(double)RAND_MAX ? 1 : 0 );

            /***************************************/
			/* see if we have to update MVC_Target */
			/***************************************/
			if (success_flag) {
				if (tgt_yVar_enabled) {
					/* MVC Target reached! Increase it by 15% */
					ssSetRWorkValue(S, 18+gadget_id,target_y*1.15);
				}
				if (target_y > higher_MVC_targets[gadget_id]) {
					/* We have a new Max MVC!*/
					ssSetRWorkValue(S, 26+gadget_id,target_y);
				}
			} else { // last trial was not a success
				if (tgt_yVar_enabled) {
					/* Failed to reach and hold MVC Target, decrease y by 8% */
					ssSetRWorkValue(S, 18+gadget_id,target_y*0.92);
				}
			}
		
			/* To resuffle or not to reshuffle */       			
			//reshuffle if something has changed
			if (num_targets != param_num_targets   ||
				use_gadget_0 != param_use_gadget_0 ||
				use_gadget_1 != param_use_gadget_1 ||
				use_gadget_2 != param_use_gadget_2 ||
				use_gadget_3 != param_use_gadget_3 ||
				idiot_mode != param_idiot_mode ||
				multiple_targets != param_multiple_targets)
			{
				num_targets = param_num_targets;
				use_gadget_0 = param_use_gadget_0;
	            use_gadget_1 = param_use_gadget_1;
	            use_gadget_2 = param_use_gadget_2;
	            use_gadget_3 = param_use_gadget_3;
				idiot_mode = param_idiot_mode;
				multiple_targets = param_multiple_targets;
                reshuffle = 1;
            }

            //reshuffle every_new trial in multiple target mode
			if (multiple_targets) {
				reshuffle = 1;
			}
		
			// reshuffle by default if we reached the last target in the list, unless failure and idiot mode
			if (target_index == (num_targets*num_gadgets_in_use-1) && !(idiot_mode && success_flag == 0)) {
				reshuffle = 1;  
			}

            /* reshuffle target-gadget list*/
             if (reshuffle) { 
                // reshuffle
                j = 0;
                /* set up lists loop */
                for (i=0; i<num_targets; i++) {
                    if (use_gadget_0) {
                        tmp_tgts[j] = i;
                        tmp_sort[j] = rand();
                        tmp_gdgt[j++] = 0;
                    }
                    if (use_gadget_1) {
                        tmp_tgts[j] = i;
                        tmp_sort[j] = rand();
                        tmp_gdgt[j++] = 1;
                    }
                    if (use_gadget_2) {
                        tmp_tgts[j] = i;
                        tmp_sort[j] = rand();
                        tmp_gdgt[j++] = 2;
                    }
                    if (use_gadget_3) {
                        tmp_tgts[j] = i;
                        tmp_sort[j] = rand();
                        tmp_gdgt[j++] = 3;
                    }                      
                }
                /* shuffle lists loop */
                for (i=0; i<num_targets*num_gadgets_in_use-1; i++) {
                    for (j=0; j<num_targets*num_gadgets_in_use-1; j++) {
                        if (tmp_sort[j] < tmp_sort[j+1]) {
                            tmp_d = tmp_sort[j];
                            tmp_sort[j] = tmp_sort[j+1];
                            tmp_sort[j+1] = tmp_d;
                            
                            tmp_i = tmp_tgts[j];
                            tmp_tgts[j] = tmp_tgts[j+1];
                            tmp_tgts[j+1] = tmp_i;
                                    
                            tmp_i = tmp_gdgt[j];
                            tmp_gdgt[j] = tmp_gdgt[j+1];
                            tmp_gdgt[j+1] = tmp_i;
                        }
                    }
                }

				/* write lists back to work buffer loop */
                for (i=0; i<=num_targets*num_gadgets_in_use-1; i++) {
                    target_list[i*2] = tmp_tgts[i];
                    target_list[i*2+1] = tmp_gdgt[i];
                    ssSetIWorkValue(S, i*2+5, target_list[i*2]);
                    ssSetIWorkValue(S, i*2+6, target_list[i*2+1]);
                }

				/* sequential target-gadget list for testing */
/*                for (i=0; i<=num_targets-1; i++) {
	                for (j=0; j<=num_gadgets_in_use-1; j++) {
	                    target_list[i*num_gadgets_in_use*2+2*j] = i;
	                    target_list[i*num_gadgets_in_use*2+2*j+1] = j;
	                }
                }
                for (i=0; i<=num_targets*num_gadgets_in_use-1; i++) {
                    ssSetIWorkValue(S, i*2+5, target_list[i*2]);
                    ssSetIWorkValue(S, i*2+6, target_list[i*2+1]);
                }
*/
				
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
			target_id = ssGetIWorkValue(S, 5 + target_index*2);
			gadget_id = ssGetIWorkValue(S, 6 + target_index*2);

			/* Grab the (newly) selected target from the target table */
		    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
		    target_y = *uPtrs[0+(target_id*5)];
		    target_h = *uPtrs[1+(target_id*5)];
		    target_x = *uPtrs[2+(target_id*5)];
		    target_w = *uPtrs[3+(target_id*5)];
		    tgt_yVar_enabled = (int)*uPtrs[4+(target_id*5)];
		    
			/****************************************************************************/ 
		    /* if we are in MVC routine mode, we may want to override the target values */
		    /****************************************************************************/ 
			if (tgt_yVar_enabled) {
				if (current_MVC_targets[gadget_id]!=0) { // we have yVar enabled and a current y target value for this gadget
					if (target_y != user_spec_MVC_targets[gadget_id]) { //this gadget MVC target changed by user, we clear this current MVC target
						current_MVC_targets[gadget_id] = 0;
					} else {
						target_y = current_MVC_targets[gadget_id]; //override the y value for this gadget's MVC target
					}
				}
				if (current_MVC_targets[gadget_id] == 0) { //first occurence of this target, don't modify it
					user_spec_MVC_targets[gadget_id] = target_y;
					ssSetRWorkValue(S,10+gadget_id,user_spec_MVC_targets[gadget_id]);
					current_MVC_targets[gadget_id] = target_y; //set the current target to value provided by user
					ssSetRWorkValue(S,18+gadget_id,current_MVC_targets[gadget_id]);
				}
			}
		    /********************************/ 
		    /* End of MVC target overriding */
		    /********************************/ 
		    
			/* Write the target back to the RWork vector */
			ssSetRWorkValue(S,32,target_y);
			ssSetRWorkValue(S,33,target_h);
			ssSetRWorkValue(S,34,target_x);
			ssSetRWorkValue(S,35,target_w);
			ssSetRWorkValue(S,36,tgt_yVar_enabled);
			/* Update the target bounds */
		    tgt[0] = target_x - target_w / 2.0;
		    tgt[1] = target_y + target_h / 2.0;
		    tgt[2] = target_x + target_w / 2.0;
		    tgt[3] = target_y - target_h / 2.0;
			
            /* Copy target info into databursts */
            databurst[0] = 6 + 4*sizeof(float);
            databurst[1] = DATABURST_VERSION;
			databurst[2] = BEHAVIOR_VERSION_MAJOR;
			databurst[3] = BEHAVIOR_VERSION_MINOR;
			databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
			databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            for (i = 0; i < 4; i++) {
                databurst_target_list[i] = (float)tgt[i];
            }

            /* and reset the databurst counter */
            ssSetIWorkValue(S, 135, 0);
                        
            new_state = STATE_DATA_BLOCK;
			ssSetIWorkValue(S, 133, 0);	// clear success_flag
            state_changed();

            break;
        case STATE_DATA_BLOCK:
            if (databurst_counter > 2*(databurst[0]-1)) { 
               new_state = STATE_TOUCH_PAD_ON;
               state_changed();
            }
			ssSetIWorkValue(S, 135, databurst_counter+1);
            break;           
        case STATE_TOUCH_PAD_ON:
            if (touch_pad) {
                new_state = STATE_TOUCH_PAD_HOLD;
                state_changed();
                reset_timer();
            }
            break;
        case STATE_TOUCH_PAD_HOLD:
            if (elapsed_timer_time > touch_pad_hold_timeout) {
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
                new_state = STATE_REACH;
                state_changed();
                reset_timer();
            } else if (!touch_pad) {
                new_state = STATE_ABORT;
                state_changed();
                reset_timer();                
            }
            break;
        case STATE_REACH:
            if (elapsed_timer_time > reach_time) {
                new_state = STATE_FAIL;
                state_changed();
                reset_timer();
            } else if (!touch_pad) {
                new_state = STATE_MOVEMENT;
                state_changed();
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
                new_state = STATE_CONTINUE_REACH;
                state_changed();
            } else if (elapsed_target_hold_time > target_hold_time) {
				success_flag();
				new_state = STATE_REWARD;
				state_changed();
				reset_timer();
				// do not timeout if the cursor is in the target...
// 			} else if (elapsed_timer_time > reach_time) {
// 	            new_state = STATE_FAIL;
// 	            state_changed();
// 	            reset_timer();
            }
            break;
        case STATE_CONTINUE_REACH:
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
        } else if (new_state == STATE_REACH) {
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
     *  declaration
     ********************/
    int i;
    int target_index;
    int target_id;
    int gadget_id;
    real_T target_x, target_y, target_h, target_w;
    real_T tgt[4];
    real_T tone_cnt, tone_id;
    int new_state;
    byte* databurst;
    int databurst_counter;
    real_T higher_MVC_targets[4];
    
    /* holders for outputs */
    real_T reward, word, touch_pad_led, gadget_led, gadget_select;
	real_T status[4];
    real_T tone[2];	
    real_T target[10];
    real_T version[4];
       
    /* pointers to output buffers */
    real_T *reward_p;
    real_T *word_p;
    real_T *touch_pad_led_p;
    real_T *gadget_led_p;
    real_T *gadget_select_p;    
    real_T *status_p;
    real_T *tone_p;
    real_T *target_p;
    real_T *mvcTarget_p;
    real_T *version_p;
    
    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    new_state = ssGetIWorkValue(S, 0);
    
	/* Current target/gadget index */
    target_index = ssGetIWorkValue(S, 1);
    target_id = ssGetIWorkValue(S, 5 + target_index*2);
    gadget_id = ssGetIWorkValue(S, 6 + target_index*2);
    
    /* Get the Current Target Location */
	target_y = ssGetRWorkValue(S,32);
    target_h = ssGetRWorkValue(S,33);
    target_x = ssGetRWorkValue(S,34);
    target_w = ssGetRWorkValue(S,35);
    
	/* And define the target bounds */
	tgt[0] = target_x - target_w / 2.0;
	tgt[1] = target_y + target_h / 2.0;
	tgt[2] = target_x + target_w / 2.0;
	tgt[3] = target_y - target_h / 2.0;  
    
	/*MVC Targets variables*/
    for (i=0; i<4; i++) {
    	higher_MVC_targets[i]=ssGetRWorkValue(S,i+26);
	}  

    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 135);
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
            case STATE_TOUCH_PAD_HOLD:
                word = WORD_HAND_ON_TOUCH_PAD;
                break;
            case STATE_DELAY:
                word = WORD_GADGET_ON(gadget_id);
                break;                
            case STATE_REACH:
                if (get_catch_trial()) {
                    word = WORD_CATCH;
                } else {
                    word = WORD_GO_CUE;
                }
                break;
            case STATE_MOVEMENT:
                word = WORD_REACH(target_id);
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

    /* touch_pad_led (2) */
    if (state == STATE_TOUCH_PAD_ON || state == STATE_TOUCH_PAD_HOLD || state == STATE_DELAY) {
        touch_pad_led = 1.0;
    } else {
        touch_pad_led = 0.0;
    }
    
    /* gadget_led (3) */
    if (state == STATE_DELAY || state == STATE_REACH || state == STATE_MOVEMENT ||
        state == STATE_TARGET_HOLD || state == STATE_CONTINUE_REACH) 
    {
        gadget_led = 1.0;
    } else {
        gadget_led = 0.0;
    }
    
    /* gadget_select (4) */
    gadget_select = gadget_id;
        
    /* status (5) */
    status[0] = state;
    status[1] = ssGetIWorkValue(S,2); // num rewards
    status[2] = ssGetIWorkValue(S,3); // num aborts
    status[3] = ssGetIWorkValue(S,4); // num failures
    
    /* tones (6) */
    tone_cnt = ssGetRWorkValue(S, 2);
    tone_id  = ssGetRWorkValue(S, 3);
    
    /* targets (7) */
    for (i=0; i<4; i++) {
        target[i+1] = tgt[i];
    }
    if ( state == STATE_DELAY || 
         state == STATE_REACH || 
         state == STATE_MOVEMENT || 
         state == STATE_CONTINUE_REACH )
    {
        /* target red */
        target[0] = 1;
    } else if (state == STATE_TARGET_HOLD) {
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
	
	 /* MVC Target (8) */
     // = higher_MVC_target    

     /* Version (9) */
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
     for (i=0; i<4; i++) 
         status_p[i] = (real_T)status[i];
    
     tone_p = ssGetOutputPortRealSignal(S,6);
     tone_p[0] = tone_cnt;
     tone_p[1] = tone_id;
     
     target_p = ssGetOutputPortRealSignal(S,7);
     for (i=0; i<10; i++) 
         target_p[i] = target[i];
     
     mvcTarget_p = ssGetOutputPortRealSignal(S,8);
     for (i=0; i<4; i++) {
	     mvcTarget_p[i]  = higher_MVC_targets[i];
     }
     
     version_p = ssGetOutputPortRealSignal(S, 9);
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
