// to do:  reward!, test drawSquareTarget stuff (if 2 red targets are shown during movement
// then it works.

#define S_FUNCTION_NAME mastercon_at
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "simstruc.h"

#define TASK_AT 1
#include "words.h"
#include "targets.h"
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
 * byte         0: uchar => number of bytes to be transmitted
 * byte         1: uchar => databurst version number (in this case one)
 * byte         2: uchar => model version major
 * byte         3: uchar => model version minor
 * bytes   4 to 5: short => model version micro
 * bytes   6 to 9: float => x offset (cm)
 * bytes 10 to 13: float => y offset (cm)
 * byte        14: uchar => trial type (0=visual, 1=proprioceptive, 2=control)
 * byte        15: uchar => training trial (1=yes, 0=no)
 * bytes 16 to 19: float => bump magnitude (N)
 * bytes 20 to 23: float => bump 1 angle (rad)
 * bytes 24 to 27: float => bump 2 angle (rad)
 * bytes 28 to 31: float => visual target 1 size (cm)
 * bytes 32 to 35: float => visual target 2 size (cm)
 * bytes 36 to 39: float => reward target angle (rad)
 * bytes 40 to 43: float => fail target angle (rad)
 * bytes 44 to 47: float => reward target size (cm)
 * bytes 48 to 51: float => fail target size (cm)
 * bytes 52 to 55: float => outer target delay after bump (ms, if -1 outer
 *                          targets visible during center hold)
 * byte        56: uchar => catch trial (1=yes, 0=no)
 */

typedef unsigned char byte;
#define DATABURST_VERSION (0x00) 

/*
 * Until we implement tunable parameters, these will act as defaults
 */
// Default parameter vector for Master Control box in model:
// 0 0 1 2 2 3 5 1 1 1 0.5 40 40 10 1 20 1 0.7 10 0.5 1.5 0.05 0.2 1 0.05 0.8 1.2 5 0.5 1 5 0.01 0.03 3 125 4 0 0.1 0.3 3 10 1 0

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,0))

/* Update counter */
static real_T master_update = 0.0;
#define param_master_update mxGetScalar(ssGetSFcnParam(S,1))

/* Timing parameters */
static real_T center_hold;
static real_T center_hold_l = 1.0;
#define param_center_hold_l mxGetScalar(ssGetSFcnParam(S,2))
static real_T center_hold_h = 2.0;
#define param_center_hold_h mxGetScalar(ssGetSFcnParam(S,3))

static real_T interbump_delay;
static real_T interbump_delay_l = 2.0;
#define param_interbump_delay_l mxGetScalar(ssGetSFcnParam(S,4));
static real_T interbump_delay_h = 3.0;
#define param_interbump_delay_h mxGetScalar(ssGetSFcnParam(S,5));
static real_T movement_time = 5.0;
#define param_movement_time mxGetScalar(ssGetSFcnParam(S,6))
static real_T reward_timeout = 1.0;
#define param_reward_timeout mxGetScalar(ssGetSFcnParam(S,7))
static real_T fail_timeout = 1.0;
#define param_fail_timeout mxGetScalar(ssGetSFcnParam(S,8))
static real_T abort_timeout = 1.0;
#define param_abort_timeout mxGetScalar(ssGetSFcnParam(S,9))
static real_T outer_target_delay = 0.5;
#define param_outer_target_delay mxGetScalar(ssGetSFcnParam(S,10))

/* Stimuli parameters */
static real_T percent_visual_trials = 40.0;
#define param_percent_visual_trials mxGetScalar(ssGetSFcnParam(S,11))
static real_T percent_proprio_trials = 40.0;
#define param_percent_proprio_trials mxGetScalar(ssGetSFcnParam(S,12))
static int trial_block_size = 10;
#define param_trial_block_size (int)mxGetScalar(ssGetSFcnParam(S,13))
static int blocked_parameters = 1;
#define param_blocked_parameters (int)mxGetScalar(ssGetSFcnParam(S,14))
static real_T percent_catch_trials = 20.0;
#define param_percent_catch_trials mxGetScalar(ssGetSFcnParam(S,15))
static int staircase = 1;
#define param_staircase (int)mxGetScalar(ssGetSFcnParam(S,16))
static real_T performance_objective = 0.7;
#define param_performance_objective mxGetScalar(ssGetSFcnParam(S,17))
static int staircase_length = 10;
#define param_staircase_length (int)mxGetScalar(ssGetSFcnParam(S,18))
static real_T visual_start_ratio_1 = 0.5;
#define param_visual_start_ratio_1 mxGetScalar(ssGetSFcnParam(S,19))
static real_T visual_start_ratio_2 = 1.5;
#define param_visual_start_ratio_2 mxGetScalar(ssGetSFcnParam(S,20))
static real_T visual_start_step_size = 0.05;
#define param_visual_start_step_size mxGetScalar(ssGetSFcnParam(S,21))
static real_T proprio_start_angle_1 = 0.2;
#define param_proprio_start_angle_1 mxGetScalar(ssGetSFcnParam(S,22))
static real_T proprio_start_angle_2 = 1;
#define param_proprio_start_angle_2 mxGetScalar(ssGetSFcnParam(S,23))
static real_T proprio_start_step_size = 0.05;
#define param_proprio_start_step_size mxGetScalar(ssGetSFcnParam(S,24))
static real_T visual_target_min_ratio = 0.8;
#define param_visual_target_min_ratio mxGetScalar(ssGetSFcnParam(S,25))
static real_T visual_target_max_ratio = 1.2;
#define param_visual_target_max_ratio mxGetScalar(ssGetSFcnParam(S,26))
static int visual_num_steps = 5;
#define param_visual_num_steps (int)mxGetScalar(ssGetSFcnParam(S,27))
static real_T proprio_target_min_angle = 0.5;
#define param_proprio_target_min_angle mxGetScalar(ssGetSFcnParam(S,28))
static real_T proprio_target_max_angle = 1.0;
#define param_proprio_target_max_angle mxGetScalar(ssGetSFcnParam(S,29))
static int proprio_num_steps = 5;
#define param_proprio_num_steps (int)mxGetScalar(ssGetSFcnParam(S,30))

/* Bump parameters */
static real_T bump_mag_min = 0.01;
#define param_bump_mag_min mxGetScalar(ssGetSFcnParam(S,31))
static real_T bump_mag_max = 0.03;
#define param_bump_mag_max mxGetScalar(ssGetSFcnParam(S,32))
static int num_bump_magnitudes = 3;
#define param_num_bump_magnitudes (int)mxGetScalar(ssGetSFcnParam(S,33))
static real_T bump_duration = 0.125;
#define param_bump_duration mxGetScalar(ssGetSFcnParam(S,34))
static int num_directions = 4;
#define param_num_directions (int)mxGetScalar(ssGetSFcnParam(S,35))
static real_T first_bump_direction = 0.0;
#define param_first_bump_direction mxGetScalar(ssGetSFcnParam(S,36))

/* Reward parameters */
static real_T min_reward = 0.1;
#define param_min_reward mxGetScalar(ssGetSFcnParam(S,37))
static real_T max_reward = 0.3;
#define param_max_reward mxGetScalar(ssGetSFcnParam(S,38))

/* Target parameters */
static real_T target_size = 3.0;
#define param_target_size mxGetScalar(ssGetSFcnParam(S,39))
static real_T target_radius = 10.0;
#define param_target_radius mxGetScalar(ssGetSFcnParam(S,40))
static real_T visual_target_duration = 1.0;
#define param_visual_target_duration mxGetScalar(ssGetSFcnParam(S,41))
static real_T inter_visual_target_delay = 1.0;
#define param_inter_visual_target_delay mxGetScalar(ssGetSFcnParam(S,43))

static real_T percent_training_trials = 0.0;
#define param_percent_training_trials mxGetScalar(ssGetSFcnParam(S,42))

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_CENTER_TARGET_ON 1
#define STATE_CENTER_HOLD 2
#define STATE_VISUAL_1 3
#define STATE_BUMP_1 4
#define STATE_INTERBUMP 5
#define STATE_CENTER_HOLD_2 6
#define STATE_BUMP_2 7
#define STATE_INTERVISUAL 8
#define STATE_VISUAL_2 9
#define STATE_OUTER_TARGET_DELAY 10
#define STATE_MOVEMENT 11
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3
#define TONE_MASK 5

/* 
 * RWorkVector Indexes
 */
#define rWorkBump1Direction 4
#define rWorkBump2Direction 5
#define rWorkBumpMagnitude 6
#define rWorkMasterUpdateCounter 7
#define rWorkMovementDuration 8
#define rWorkTargetSizeRatio 9
#define rWorkProprioStairAngles 10
#define rWorkVisualStairRatios 30
#define rWorkRewardTargetAngle 50
#define rWorkFailTargetAngle 51
#define rWorkVisualTarget1Size 52
#define rWorkVisualTarget2Size 53
#define rWorkAverageBumpDirection 54

/*
 * IWorkVector Indexes
 */
#define iWorkRewards 1
#define iWorkFailures 2
#define iWorkAborts 3
#define iWorkIncompletes 4
#define iWorkTrainingMode 5
#define iWorkProprioStairCounter 6
#define iWorkVisualStairCounter 7
#define iWorkProprioStairResponses 8
#define iWorkVisualStairResponses 28
#define iWorkDataburstCounter 48
#define iWorkBumpDurationCounter 49
#define iWorkBumpStep 50
#define iWorkTrialCounter 51
#define iWorkTrialType 52
#define iWorkBlockCount 53
#define iWorkCatchTrial 54

static void mdlCheckParameters(SimStruct *S)
{
    center_hold_l = param_center_hold_l;
    center_hold_h = param_center_hold_h;
    interbump_delay_l = param_interbump_delay_l;
    interbump_delay_h = param_interbump_delay_h;
    movement_time = param_movement_time;
    reward_timeout = param_reward_timeout;
    fail_timeout = param_fail_timeout;
    abort_timeout = param_abort_timeout;
    outer_target_delay = param_outer_target_delay;
    
    percent_visual_trials = param_percent_visual_trials;
    percent_proprio_trials = param_percent_proprio_trials;
    trial_block_size = param_trial_block_size;
    blocked_parameters = param_blocked_parameters;
    percent_catch_trials = param_percent_catch_trials;
    staircase = param_staircase;
    performance_objective = param_performance_objective;
    staircase_length = param_staircase_length;
    visual_start_ratio_1 = param_visual_start_ratio_1; 
    visual_start_ratio_2 = param_visual_start_ratio_2; 
    visual_start_step_size = param_visual_start_step_size; 
    proprio_start_angle_1 = param_proprio_start_angle_1; 
    proprio_start_angle_2 = param_proprio_start_angle_2;
    proprio_start_step_size = param_proprio_start_step_size; 
    visual_target_min_ratio = param_visual_target_min_ratio; 
    visual_target_max_ratio = param_visual_target_max_ratio; 
    visual_num_steps = param_visual_num_steps;
    proprio_target_min_angle = param_proprio_target_min_angle;
    proprio_target_max_angle = param_proprio_target_max_angle;
    proprio_num_steps = param_proprio_num_steps;
    
    bump_mag_min = param_bump_mag_min;
    bump_mag_max = param_bump_mag_max;
    num_bump_magnitudes = param_num_bump_magnitudes;
    bump_duration = param_bump_duration;
    num_directions = param_num_directions;
    first_bump_direction = param_first_bump_direction;
    
    min_reward = param_min_reward; 
    max_reward = param_max_reward; 
    
    target_size = param_target_size; 
    target_radius = param_target_radius; 
    visual_target_duration = param_visual_target_duration;
    inter_visual_target_delay = param_inter_visual_target_delay;
    
    percent_training_trials = param_percent_training_trials;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 44);
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
     *  target: 45 ( targets 1:9 (only 3 implemented): 
     *                  on/off, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)
     *  reward: 1
     *  reward pulse duration: 1
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
    ssSetNumRWork(S, 55);  /* 0: time of last timer reset 
                             1: tone counter (incremented each time a tone is played)
                             2: tone id
							 3: mastercon version
                             4: bump 1 direction
                             5: bump 2 direction
                             6: bump magnitude   
                             7: master update counter 
                             8: duration of movement (for calculating reward length)
                             9: target size ratio
                             10-29: proprioceptive staircase 1 bumps                             
                             30-49: visual staircase 1 ratios
                             50: reward target direction
                             51: fail target direction
                             52: visual target 1 size
                             53: visual target 2 size
                             54: average bump direction
                           */
    
    ssSetNumPWork(S, 1);   /* 0: pointer to databurst array
                           */
    
    ssSetNumIWork(S, 55);     /* 0: state_transition (true if state changed), 
                                1: successes
                                2: failures
                                3: aborts
                                4: incompletes   
                                5: training mode 
                                6: proprioceptive staircase counter                                
                                7: visual staircase counter                                
                                8-27: proprioceptive staircase responses                                                        
                                28-47: visual staircase responses                                
                                48: databurst counter
                                49: bump duration counter
                                50: bump step
                                51: test step (target separation for proprio trials or
                                    target size ratio for visual trials)
                                52: trial type (0=visual,1=proprio,2=control)
                                53: trial block count
                                54: catch trial
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
    int i;
    
    /* initialize state to zero */
    x0 = ssGetRealDiscStates(S);
    *x0 = 0.0;
    
    /* notify that we just entered this state */
    ssSetIWorkValue(S, 0, 1);
       
    /* set the tone counter to zero */
    ssSetRWorkValue(S, 1, 0.0);
        
    /* set trial counters to zero */
    ssSetIWorkValue(S, iWorkRewards, 0);
    ssSetIWorkValue(S, iWorkFailures, 0);
    ssSetIWorkValue(S, iWorkAborts, 0);
    ssSetIWorkValue(S, iWorkIncompletes, 0);
    
    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, iWorkDataburstCounter, 0);
    
    /* set staircase counters to zero*/
    ssSetIWorkValue(S,iWorkProprioStairCounter,0);    
    ssSetIWorkValue(S,iWorkVisualStairCounter,0);
    
    /* initialize block counter to zero */
    ssSetIWorkValue(S,iWorkTrialCounter,0);
    
    /* set the initial last update time to 0 */
    ssSetRWorkValue(S,rWorkMasterUpdateCounter,0.0); 
    
    /* set duration of movement to zero */
    ssSetRWorkValue(S,rWorkMovementDuration,0);
    
    /* initialize staircases (randomly?) */
    for (i=0; i<20; i++){
        ssSetRWorkValue(S,rWorkProprioStairAngles+i,UNI);
        ssSetRWorkValue(S,rWorkVisualStairRatios+i,0.5+UNI);
        ssSetIWorkValue(S,iWorkProprioStairResponses+i, UNI>0.5 ? 1:0);
        ssSetIWorkValue(S,iWorkVisualStairResponses+i, UNI>0.5 ? 1:0);
    }    
    
//     ssSetRWorkValue(S,iWorkRewardTargetSize,3);
//     ssSetRWorkValue(S,iWorkFailTargetSize,2);
    ssSetRWorkValue(S,rWorkRewardTargetAngle,0);
    ssSetRWorkValue(S,rWorkFailTargetAngle,PI);
    
    ssSetRWorkValue(S,rWorkBumpMagnitude,0);
    ssSetRWorkValue(S,rWorkBump1Direction,0);
    ssSetRWorkValue(S,rWorkBump2Direction,0);    
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
    int i;
    int j;
    int nshift;
    
    real_T ct[4];
    real_T rt[4];     /* reward target UL and LR coordinates */
    real_T ft[4];     /* fail target UL and LR coordinates */
    real_T previous_visual_stair_ratio;
    real_T new_visual_stair_ratio;
    real_T previous_proprio_stair_angle;
    real_T new_proprio_stair_angle;
    real_T bump_separation;
    real_T average_bump_direction;
    real_T temp_real;
    
    InputRealPtrsType uPtrs;
    real_T cursor[2];
    real_T elapsed_timer_time;
    int reset_block = 0;
    
    /* Trial parameters from IWorkVector*/
    int trial_type; /* 0=visual, 1=proprioceptive, 2=control */
    int trial_counter;
    int temp_int;
    int training_mode;
    int proprio_stair_counter;
    int visual_stair_counter;
    int proprio_stair_responses[20];
    int visual_stair_responses[20];
    int trial_block_count;
    int catch_trial;

    /* from RWorkVector */
    real_T bump_1_direction;
    real_T bump_2_direction;
    real_T bump_magnitude;
    real_T reward_target_angle;
    real_T fail_target_angle;
    real_T target_size_ratio;
    real_T proprio_stair_angles[20];
    real_T visual_stair_ratios[20];
    real_T visual_target_1_size;
    real_T visual_target_2_size;
    
    /* databurst variables */
    byte *databurst;
	float *databurst_offsets;
    byte *databurst_trial_type;
    byte *databurst_training;
    float *databurst_bump_mag;
    float *databurst_bump_1_direction;
    float *databurst_bump_2_direction;
    float *databurst_visual_target_1_size;
    float *databurst_visual_target_2_size;
    float *databurst_reward_target_angle;
    float *databurst_fail_target_angle;
    float *databurst_reward_target_size;
    float *databurst_fail_target_size;
    byte *databurst_catch_trial;
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
    
    if ( param_master_update > master_update ) {
        master_update = param_master_update;
        ssSetRWorkValue(S, 6, (real_T)ssGetT(S));
    }    
        
    /* Read staircase data */
    for (i=0 ; i<20 ; i++) {
        proprio_stair_responses[i] = ssGetIWorkValue(S,iWorkProprioStairResponses+i);
        visual_stair_responses[i] = ssGetIWorkValue(S,iWorkVisualStairResponses+i);
    
        proprio_stair_angles[i] = ssGetRWorkValue(S,rWorkProprioStairAngles+i);
        visual_stair_ratios[i] = ssGetRWorkValue(S,rWorkVisualStairRatios+i);
    }
    
    bump_1_direction = ssGetRWorkValue(S,rWorkBump1Direction);
    bump_2_direction = ssGetRWorkValue(S,rWorkBump2Direction);
    bump_magnitude = ssGetRWorkValue(S,rWorkBumpMagnitude);
    proprio_stair_counter = ssGetIWorkValue(S,iWorkProprioStairCounter);
    visual_stair_counter = ssGetIWorkValue(S,iWorkVisualStairCounter);
    
    visual_target_1_size = ssGetRWorkValue(S,rWorkVisualTarget1Size);
    visual_target_2_size = ssGetRWorkValue(S,rWorkVisualTarget2Size);
    
    reward_target_angle = ssGetRWorkValue(S,rWorkRewardTargetAngle);
    fail_target_angle = ssGetRWorkValue(S,rWorkFailTargetAngle);
    
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    
    /* get trial counter (in block) */
    trial_counter = ssGetIWorkValue(S,iWorkTrialCounter);
    
    /* get target bounds */
    ct[0] = -target_size/2;
    ct[1] = target_size/2;
    ct[2] = target_size/2;
    ct[3] = -target_size/2;
       
    rt[0] = target_radius*cos(reward_target_angle) - target_size/2; /* reward target */
    rt[1] = target_radius*sin(reward_target_angle) + target_size/2;
    rt[2] = target_radius*cos(reward_target_angle) + target_size/2;
    rt[3] = target_radius*sin(reward_target_angle) - target_size/2;

    ft[0] = target_radius*cos(fail_target_angle) - target_size/2; /* reward target */
    ft[1] = target_radius*sin(fail_target_angle) + target_size/2;
    ft[2] = target_radius*cos(fail_target_angle) + target_size/2;
    ft[3] = target_radius*sin(fail_target_angle) - target_size/2;   

    /* get trial type */
    trial_type = ssGetIWorkValue(S,iWorkTrialType);
    
    /* databurst pointers */
    databurst_counter = ssGetIWorkValue(S,iWorkDataburstCounter);
    databurst = ssGetPWorkValue(S,0);
    databurst_offsets = (float *)(databurst + 6);
    databurst_trial_type = (int *)(databurst_offsets + 2);
    databurst_training = (int *)(databurst_trial_type + 1);
    databurst_bump_mag = (float *)(databurst_training + 1);
    databurst_bump_1_direction = (float *)(databurst_bump_mag + 1);
    databurst_bump_2_direction = (float *)(databurst_bump_1_direction + 1);
    databurst_visual_target_1_size = (float *)(databurst_bump_2_direction + 1);
    databurst_visual_target_2_size = (float *)(databurst_visual_target_1_size + 1);
    databurst_reward_target_angle = (float *)(databurst_visual_target_2_size + 1);
    databurst_fail_target_angle = (float *)(databurst_reward_target_angle + 1);
    databurst_reward_target_size = (float *)(databurst_fail_target_angle + 1);
    databurst_fail_target_size = (float *)(databurst_reward_target_size + 1);
    databurst_catch_trial = (int *)(databurst_fail_target_size + 1);
    
     /*********************************
     * See if we have issued a reset *  
     *********************************/
    if (param_master_reset != master_reset) {
        master_reset = param_master_reset;
        ssSetIWorkValue(S, iWorkRewards, 0);
        ssSetIWorkValue(S, iWorkFailures, 0);
        ssSetIWorkValue(S, iWorkAborts, 0);
        ssSetIWorkValue(S, iWorkIncompletes, 0);
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
            center_hold_l = param_center_hold_l;
            center_hold_h = param_center_hold_h;
            interbump_delay_l = param_interbump_delay_l;
            interbump_delay_h = param_interbump_delay_h;
            movement_time = param_movement_time;
            reward_timeout = param_reward_timeout;
            fail_timeout = param_fail_timeout;
            abort_timeout = param_abort_timeout;
            outer_target_delay = param_outer_target_delay;

            percent_visual_trials = param_percent_visual_trials;
            percent_proprio_trials = param_percent_proprio_trials;
            trial_block_size = param_trial_block_size;
            blocked_parameters = param_blocked_parameters;
            percent_catch_trials = param_percent_catch_trials;
            staircase = param_staircase;
            performance_objective = param_performance_objective;
            staircase_length = param_staircase_length;
            visual_start_ratio_1 = param_visual_start_ratio_1; 
            visual_start_ratio_2 = param_visual_start_ratio_2; 
            visual_start_step_size = param_visual_start_step_size; 
            proprio_start_angle_1 = param_proprio_start_angle_1; 
            proprio_start_angle_2 = param_proprio_start_angle_2;
            proprio_start_step_size = param_proprio_start_step_size; 
            visual_target_min_ratio = param_visual_target_min_ratio; 
            visual_target_max_ratio = param_visual_target_max_ratio; 
            visual_num_steps = param_visual_num_steps;
            proprio_target_min_angle = param_proprio_target_min_angle;
            proprio_target_max_angle = param_proprio_target_max_angle;
            proprio_num_steps = param_proprio_num_steps;

            bump_mag_min = param_bump_mag_min;
            bump_mag_max = param_bump_mag_max;
            num_bump_magnitudes = param_num_bump_magnitudes;
            bump_duration = param_bump_duration;
            num_directions = param_num_directions;
            first_bump_direction = param_first_bump_direction;

            min_reward = param_min_reward; 
            max_reward = param_max_reward; 

            target_size = param_target_size; 
            target_radius = param_target_radius; 
            visual_target_duration = param_visual_target_duration;
            inter_visual_target_delay = param_inter_visual_target_delay;
            
            percent_training_trials = param_percent_training_trials;
             
            /* decide if it is a training trial */ 
            training_mode = (100*UNI<percent_training_trials) ? 1 : 0;
            ssSetIWorkValue(S,iWorkTrainingMode,training_mode); 
            
            /* advance block counter */
            trial_counter++;
            if (trial_counter > trial_block_size)
                trial_counter = 1;
                        
            ssSetIWorkValue(S,iWorkTrialCounter,trial_counter);
            
            /* decide if it is a visual trial */
            if (trial_block_size > 1){
                if (100*trial_counter/trial_block_size<percent_visual_trials){
                    trial_type = 0;
                } else if (100*trial_counter/trial_block_size<percent_visual_trials + percent_proprio_trials){
                    trial_type = 1;
                } else {
                    trial_type = 2;
                }
            } else {
                temp_real = 100*UNI;
                if (temp_real < percent_visual_trials){
                    trial_type = 0;
                } else if (temp_real < percent_visual_trials + percent_proprio_trials){
                    trial_type = 1;
                } else {
                    trial_type = 2;
                }
            }            
            ssSetIWorkValue(S,iWorkTrialType,trial_type); 
            
            /* decide if it is a catch trial */
            catch_trial = (100*UNI<percent_catch_trials) ? 1 : 0;
            ssSetIWorkValue(S,iWorkCatchTrial,catch_trial);
            
            /* timer lengths */
            if (center_hold_h == center_hold_l) {
	            center_hold = center_hold_h;
	        } else {
	            center_hold = center_hold_l + (center_hold_h - center_hold_l)*UNI;
	        }
            
            if (interbump_delay_h == interbump_delay_l) {
	            interbump_delay = interbump_delay_h;
	        } else {
	            interbump_delay = interbump_delay_l + (interbump_delay_h - interbump_delay_l)*UNI;
	        }
            
            /* update trial parameters if necessary */
            if (!blocked_parameters || trial_counter==1){                
                if (num_directions>0){
                    temp_int = (int)(UNI*num_directions);
                    average_bump_direction = temp_int*2*PI/num_directions + first_bump_direction;
                    average_bump_direction = fmod(average_bump_direction,2*PI);
                } else {
                    average_bump_direction = 2*PI*UNI;
                }
                ssSetRWorkValue(S,rWorkAverageBumpDirection,average_bump_direction);
            } else {
                average_bump_direction = ssGetRWorkValue(S,rWorkAverageBumpDirection);
            }
                
            /* pick a random bump magnitude */
            temp_int = (int)(UNI*num_bump_magnitudes);               
            bump_magnitude = bump_mag_min + ((float)temp_int)*(bump_mag_max-bump_mag_min)/((float)num_bump_magnitudes-1);
            if (num_bump_magnitudes < 2){  // Safety!
                bump_magnitude = bump_mag_min;
            }
            ssSetRWorkValue(S,rWorkBumpMagnitude,bump_magnitude);
            ssSetIWorkValue(S,iWorkBumpStep,temp_int);

            /* Bump directions - No staircases coded yet */
            if (UNI>0.5){
                temp_int = (int)(UNI*proprio_num_steps); 
                bump_separation = proprio_target_min_angle + ((float)temp_int)*(proprio_target_max_angle-proprio_target_min_angle)/((float)proprio_num_steps-1);
            } else {
                bump_separation = 0;
            }

            if (UNI>0.5) {
                temp_int = 1;
            } else {
                temp_int = -1;
            }                
            bump_1_direction = average_bump_direction + ((float)temp_int)*bump_separation/2;
            if (catch_trial){
                bump_2_direction = 2*PI*UNI; 
            } else {
                bump_2_direction = average_bump_direction - ((float)temp_int)*bump_separation/2; 
            }
            ssSetRWorkValue(S,rWorkBump1Direction,bump_1_direction);
            ssSetRWorkValue(S,rWorkBump2Direction,bump_2_direction);     

            /* Visual target sizes */
            temp_int = (int)(UNI*visual_num_steps);
            if (UNI>0.5){
                new_visual_stair_ratio = visual_target_min_ratio + ((float)temp_int)*(visual_target_max_ratio-visual_target_min_ratio)/((float)visual_num_steps-1); 
            } else {
                new_visual_stair_ratio = 1;
            }            
            if (UNI>0.5){                
                visual_target_1_size = target_size*new_visual_stair_ratio;
                visual_target_2_size = target_size;
            } else {
                visual_target_1_size = target_size;
                visual_target_2_size = target_size*new_visual_stair_ratio;
            }            
            ssSetRWorkValue(S,rWorkVisualTarget1Size,visual_target_1_size);
            ssSetRWorkValue(S,rWorkVisualTarget2Size,visual_target_2_size);
            
            /* Pick reward target direction */
            if ((trial_type == 0 && visual_target_1_size == visual_target_2_size) ||
                    (trial_type == 1 && bump_1_direction == bump_2_direction)){                   
                reward_target_angle = 0;
            } else {
                reward_target_angle = PI;
            }            
            ssSetRWorkValue(S,rWorkRewardTargetAngle,reward_target_angle);
            ssSetRWorkValue(S,rWorkFailTargetAngle,reward_target_angle+PI);
            
            /* Setup the databurst */
            databurst[0] = 6+4*sizeof(float)+2+8*sizeof(float)+1;
            databurst[1] = DATABURST_VERSION;
            databurst[2] = BEHAVIOR_VERSION_MAJOR;
			databurst[3] = BEHAVIOR_VERSION_MINOR;
			databurst[4] = (BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8;
			databurst[5] = (BEHAVIOR_VERSION_MICRO & 0x00FF);
            /* The offsets used in the calculation of the cursor location */
			uPtrs = ssGetInputPortRealSignalPtrs(S, 1); 
			databurst_offsets[0] = *uPtrs[0];
			databurst_offsets[1] = *uPtrs[1];
            databurst_trial_type[0] = trial_type;
            databurst_training[0] = training_mode;
            databurst_bump_mag[0] = bump_magnitude;
            databurst_bump_1_direction[0] = bump_1_direction;
            databurst_bump_2_direction[0] = bump_2_direction;           
            databurst_visual_target_1_size[0] = visual_target_1_size;
            databurst_visual_target_2_size[0] = visual_target_2_size;
            databurst_reward_target_angle[0] = reward_target_angle;
            databurst_fail_target_angle[0] = reward_target_angle+PI;
            databurst_reward_target_size[0] = target_size;
            databurst_fail_target_size[0] = target_size;
            databurst_catch_trial[0] = catch_trial;

            /* clear the counters */
            ssSetIWorkValue(S, iWorkDataburstCounter, 0); /* Databurst counter */
            
	        /* and advance */
	        new_state = STATE_DATA_BLOCK;
	        state_changed();
            break;
        case STATE_DATA_BLOCK:            
            if (databurst_counter > 2*(databurst[0]-1)) { 
                new_state = STATE_CENTER_TARGET_ON;
                reset_timer(); /* start timer for movement */
                state_changed();
            }                                    
            ssSetIWorkValue(S, iWorkDataburstCounter, databurst_counter+1);
            break;
        case STATE_CENTER_TARGET_ON:
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
            } else if ((elapsed_timer_time > center_hold) && trial_type != 0 ) {
                new_state = STATE_BUMP_1;
                reset_timer(); /* delay timer */
                state_changed();
            } else if ((elapsed_timer_time > center_hold) && trial_type == 0) {
                new_state = STATE_VISUAL_1;
                reset_timer();
                state_changed();
            } 
            break;
        case STATE_VISUAL_1:
            if (!cursorInTarget(cursor, ct)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > visual_target_duration) {
                new_state = STATE_BUMP_1;
                reset_timer(); 
                state_changed();
            }
            break;
        case STATE_BUMP_1:
            if (elapsed_timer_time > bump_duration) {
                if (trial_type == 0){
                    new_state = STATE_INTERVISUAL;
                } else if (trial_type == 1){
                    new_state = STATE_INTERBUMP;
                } else {
                    new_state = STATE_REWARD;
                }
                reset_timer();
                state_changed();
            }
            break;
        case STATE_INTERBUMP:
            if (elapsed_timer_time > interbump_delay && cursorInTarget(cursor, ct)) {
                new_state = STATE_CENTER_HOLD_2;
                reset_timer(); /* delay timer */
                state_changed();
            }
            break;
       case STATE_CENTER_HOLD_2:
            /* center hold */
            if (elapsed_timer_time > center_hold) {                
                new_state = STATE_BUMP_2;               
                reset_timer(); /* delay timer */
                state_changed();
            } else if (!cursorInTarget(cursor, ct)){
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } 
            break;
        case STATE_BUMP_2:
            if (elapsed_timer_time > bump_duration) {
                new_state = STATE_OUTER_TARGET_DELAY;
                reset_timer(); /* movement timer */
                state_changed();
            }
            break;    
        case STATE_INTERVISUAL:
            if (elapsed_timer_time + bump_duration > inter_visual_target_delay &&
                    cursorInTarget(cursor, ct)){
                new_state = STATE_VISUAL_2;
                reset_timer();
                state_changed();
            }
            break;
        case STATE_VISUAL_2:
            if (!cursorInTarget(cursor, ct)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > visual_target_duration) {
                new_state = STATE_OUTER_TARGET_DELAY;
                reset_timer(); /* movement timer */
                state_changed();
            }
            break;
        case STATE_OUTER_TARGET_DELAY:
            if (elapsed_timer_time > outer_target_delay) {
                new_state = STATE_MOVEMENT;
                reset_timer();
                state_changed();
            }
            break;
        case STATE_MOVEMENT:
            /* movement phase */
			if (cursorInTarget(cursor, rt)) {
				new_state = STATE_REWARD;
                reset_timer(); /* reward timeout */
                state_changed();			
			} else if (cursorInTarget(cursor, ft)) {			
                new_state = STATE_FAIL;
                reset_timer(); /* incomplete timeout */
                state_changed();				
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
            if (elapsed_timer_time > fail_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
            }
            break;
        case STATE_INCOMPLETE:
            /* incomplete */
            if (elapsed_timer_time > fail_timeout) {
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
    real_T vt1[4];
    real_T vt2[4];
    real_T rt[4];     /* reward outer target UL and LR coordinates */
    real_T ft[4];     /* fail outer target UL and LR coordinates */
    
    real_T bump_1_direction;
    real_T bump_2_direction;
    real_T bump_magnitude;
    
    /* get trial type */
    int training_mode;
    int trial_type;
    
    /* target sizes and angles*/
    real_T visual_target_1_size;
    real_T visual_target_2_size;
    real_T reward_target_angle;
    real_T fail_target_angle;
    
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
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)(state_r[0]);
    int new_state = ssGetIWorkValue(S, 0);
    ssSetIWorkValue(S, 0, 0); /* reset changed state each iteration */
    
    /* current trial type */
    training_mode = ssGetIWorkValue(S,iWorkTrainingMode);
    trial_type = ssGetIWorkValue(S,iWorkTrialType);
    bump_1_direction = ssGetRWorkValue(S,rWorkBump1Direction);
    bump_2_direction = ssGetRWorkValue(S,rWorkBump2Direction);
    bump_magnitude = ssGetRWorkValue(S,rWorkBumpMagnitude);        
    
    visual_target_1_size = ssGetRWorkValue(S,rWorkVisualTarget1Size);
    visual_target_2_size = ssGetRWorkValue(S,rWorkVisualTarget2Size);
    
    reward_target_angle = ssGetRWorkValue(S,rWorkRewardTargetAngle);
    fail_target_angle = ssGetRWorkValue(S,rWorkFailTargetAngle);
    
    /* get current tone counter */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);
    
    /* get target bounds */
    ct[0] = -target_size/2;
    ct[1] = target_size/2;
    ct[2] = target_size/2;
    ct[3] = -target_size/2;
       
    rt[0] = target_radius*cos(reward_target_angle) - target_size/2; /* reward target */
    rt[1] = target_radius*sin(reward_target_angle) + target_size/2;
    rt[2] = target_radius*cos(reward_target_angle) + target_size/2;
    rt[3] = target_radius*sin(reward_target_angle) - target_size/2;

    ft[0] = target_radius*cos(fail_target_angle) - target_size/2; /* reward target */
    ft[1] = target_radius*sin(fail_target_angle) + target_size/2;
    ft[2] = target_radius*cos(fail_target_angle) + target_size/2;
    ft[3] = target_radius*sin(fail_target_angle) - target_size/2;
    
    // vt1 and vt2 are circle targets [centerX, centerY, outerpointX, whatever]
    vt1[0] = 0;
    vt1[1] = target_radius;
    vt1[2] = visual_target_1_size/2;
	vt1[3] = 0;
    
    vt2[0] = 0;
    vt2[1] = target_radius;
    vt2[2] = visual_target_2_size/2;
    vt2[3] = 0;
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor[0] = *uPtrs[0];
    cursor[1] = *uPtrs[1];
    
    /* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    force_in[0] = *uPtrs[0];
    force_in[1] = *uPtrs[1];
    
    /* databurst */
    databurst_counter = ssGetIWorkValue(S, iWorkDataburstCounter);
    databurst = (byte *)ssGetPWorkValue(S, 0);
    
    /********************
     * Calculate outputs
     ********************/
    
    if (state == STATE_BUMP_1){
        force_x = force_in[0] + cos(bump_1_direction)*bump_magnitude;
        force_y = force_in[1] + sin(bump_1_direction)*bump_magnitude;
    } else if (state == STATE_BUMP_2){
        force_x = force_in[0] + cos(bump_2_direction)*bump_magnitude;
        force_y = force_in[1] + sin(bump_2_direction)*bump_magnitude;
    } else {
        force_x = force_in[0];
        force_y = force_in[1];
    }
    
    /* status (1) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S,iWorkRewards, ssGetIWorkValue(S, iWorkRewards)+1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, iWorkFailures, ssGetIWorkValue(S, iWorkFailures)+1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, iWorkAborts, ssGetIWorkValue(S, iWorkAborts)+1);
    if (state == STATE_INCOMPLETE && new_state)
        ssSetIWorkValue(S, iWorkIncompletes, ssGetIWorkValue(S, iWorkIncompletes)+1);
    
    status[0] = state;
    status[1] = ssGetIWorkValue(S, iWorkRewards); /* num rewards     */
    status[2] = ssGetIWorkValue(S, iWorkAborts); /* num aborts       */
    status[3] = ssGetIWorkValue(S, iWorkFailures); /* num fails      */
    status[4] = ssGetIWorkValue(S, iWorkIncompletes); /* num incompletes */
// debug
    status[4] = center_hold;
    
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
            case STATE_CENTER_TARGET_ON:
                word = WORD_CT_ON;
                break;
            case STATE_CENTER_HOLD:
                word = WORD_CENTER_TARGET_HOLD;
                break;
            case STATE_VISUAL_1:
                word = WORD_OT_ON(1);
                break;
            case STATE_BUMP_1:
                word = WORD_BUMP(1);
                break;
            case STATE_CENTER_HOLD_2:
                word = WORD_CENTER_TARGET_HOLD;
                break;
            case STATE_VISUAL_2:
                word = WORD_OT_ON(2);
                break;
            case STATE_BUMP_2:
                word = WORD_BUMP(2); 
                break;
            case STATE_MOVEMENT:
                word = WORD_OT_ON(3);
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
    for (i = 0; i<10; i++)
        target_pos[i] = 0;
    
    if (state == STATE_CENTER_TARGET_ON || state == STATE_CENTER_HOLD ||
            state == STATE_INTERBUMP || state == STATE_CENTER_HOLD_2 ||
            state == STATE_BUMP_1 || state == STATE_BUMP_2 ||
            state == STATE_VISUAL_1 || state == STATE_VISUAL_2 ||
            state == STATE_INTERVISUAL){
        
        if (trial_type==0){
            drawSquareTarget(target_pos, 0, ct, COLOR_BLUE);
        } else if (trial_type==1){
            drawSquareTarget(target_pos, 0, ct, COLOR_WHITE);
        } else {
            drawSquareTarget(target_pos, 0, ct, COLOR_GREEN);
        }
    }
    
    if (state == STATE_VISUAL_1){       
        drawCircleTarget(target_pos, 1, vt1, COLOR_BLUE);
    }
    
    if (state == STATE_VISUAL_2){        
        drawCircleTarget(target_pos, 1, vt2, COLOR_BLUE);
    }        
            
    if (state == STATE_MOVEMENT){
        drawSquareTarget(target_pos, 0, rt, COLOR_RED);
        if (!training_mode && trial_type!=2){
            drawSquareTarget(target_pos, 1, ft, COLOR_RED);
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
    if (state ==  STATE_BUMP_1 || state == STATE_BUMP_2) {
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

    UNUSED_ARG(tid);
}

static void mdlTerminate (SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE   /* Is this being compiled as a MEX-file? */
#include "simulink.c"    /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"     /* Code generation registration func */
#endif