/* $Id: mastercon_un.c 851 2012-04-04 22:52:59Z brian $
 *
 * Master Control block for behavior: uncertainty task 
 */
#define S_FUNCTION_NAME mastercon_un
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "simstruc.h"

#define TASK_UN 1
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
 * byte   1: uchar => databurst version number (in this case zero)
 * bytes  2 to  5: float => displacement
 */

typedef unsigned char byte;
#define DATABURST_VERSION (0x00) 

/* target shapes */
#define TARGET_SHAPE_RECT 2
#define TARGET_SHAPE_ARC 1

/*
 * Until we implement tunable parameters, these will act as defaults
 */
static real_T num_targets = 8;      /* number of peripheral targets */
#define param_num_targets mxGetScalar(ssGetSFcnParam(S,0))
static real_T target_radius = 15.0; /* radius of target circle in cm */
#define param_target_radius mxGetScalar(ssGetSFcnParam(S,1))
static real_T target_size = 5.0;    /* width and height of targets in cm */
#define param_target_size mxGetScalar(ssGetSFcnParam(S,2))

static real_T center_hold;     /* dwell time in state 2 */
static real_T center_hold_l = .5;     
#define param_center_hold_l mxGetScalar(ssGetSFcnParam(S,3))
static real_T center_hold_h = 2.0;     
#define param_center_hold_h mxGetScalar(ssGetSFcnParam(S,4))

static real_T center_delay;     /* delay between outer target and go tone */
static real_T center_delay_l = 0.0;
#define param_center_delay_l mxGetScalar(ssGetSFcnParam(S,5))
static real_T center_delay_h = 0.0;
#define param_center_delay_h mxGetScalar(ssGetSFcnParam(S,6))

static real_T movement_time = 10.0;  /* movement time */
#define param_movement_time mxGetScalar(ssGetSFcnParam(S,7))

static real_T outer_hold;      /* outer target hold time */
static real_T outer_hold_l = 1.0;      
#define param_outer_hold_l mxGetScalar(ssGetSFcnParam(S,8))
static real_T outer_hold_h = 1.0; 
#define param_outer_hold_h mxGetScalar(ssGetSFcnParam(S,9))

#define param_intertrial mxGetScalar(ssGetSFcnParam(S,10))
static real_T abort_timeout   = 1.0;    /* delay after abort */
static real_T failure_timeout = 1.0;    /* delay after failure */
static real_T incomplete_timeout = 1.0; /* delay after incomplete */
static real_T center_bump_timeout  = 1.0; 
static real_T reward_timeout  = 1.0;    /* delay after reward before starting next trial
                                         * This is NOT the reward pulse length */

#define param_catch_trial_pct mxGetScalar(ssGetSFcnParam(S,11))
static real_T catch_trial_pct = 0.0;    /* fraction of catch trials 
                                         * used only on non-bump mode */
#define set_catch_trial(x) ssSetRWorkValue(S, 3, (x))
#define get_catch_trial() ssGetRWorkValue(S, 3)

#define param_mode mxGetScalar(ssGetSFcnParam(S,12))
static real_T mode;
#define MODE_NO_PERTURBATION 0
#define MODE_BLOCK_CATCH 1
#define MODE_BUMP 2

#define param_bump_magnitude mxGetScalar(ssGetSFcnParam(S,13))
static real_T bump_magnitude;

#define param_bump_duration mxGetScalar(ssGetSFcnParam(S,14))
static int bump_duration;

#define param_idiot_mode mxGetScalar(ssGetSFcnParam(S,15))
static int idiot_mode;

static int delay_bumps = 0;
#define param_delay_bumps mxGetScalar(ssGetSFcnParam(S,16))

static real_T displacement_mean = 0;
#define param_displacement_mean mxGetScalar(ssGetSFcnParam(S,17))

static real_T displacement_var = 2;
#define param_displacement_var mxGetScalar(ssGetSFcnParam(S,18))

static real_T beg_window = 0.4;   /* start of blocking window in fraction of target radius */
#define param_beg_window mxGetScalar(ssGetSFcnParam(S,19))

static real_T end_window = 0.6;   /* end of blocking window in fraction of target radius */
#define param_end_window mxGetScalar(ssGetSFcnParam(S,20))

static real_T beg_cue = 0.5; /* Start of cue window in fraction of radius */ 
#define param_beg_cue mxGetScalar(ssGetSFcnParam(S,21))

static real_T end_cue = 0.8; /* End of cue window in fraction of radius */
#define param_end_cue mxGetScalar(ssGetSFcnParam(S,22))

static real_T cue_var = 0.2; /* Variance of Cue 'cloud' */
#define param_cue_var mxGetScalar(ssGetSFcnParam(S,23))

static real_T cue_dot_size = 1; /* Size of dots in cue cloud */
#define param_cue_dot_size mxGetScalar(ssGetSFcnParam(S,24))

static real_T cue_dot_num = 10; /* Number of dots in cue cloud */
#define param_cue_dot_num mxGetScalar(ssGetSFcnParam(S,25))

static int window_type = 2; /* Type of blocking window. 1 (Circular) is default */
#define param_window_type mxGetScalar(ssGetSFcnParam(S,26))

static int displace_type = 2; /* Type of displacement. 1 (angular) is default */
#define param_displace_type mxGetScalar(ssGetSFcnParam(S,27))

static real_T CT_offset = 0; /* Y offset for center target (for 1D task) */
#define param_CT_offset mxGetScalar(ssGetSFcnParam(S,28))

static real_T master_reset = 0.0;
#define param_master_reset mxGetScalar(ssGetSFcnParam(S,29))


/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_CT_ON 1
#define STATE_CENTER_HOLD 2
#define STATE_CENTER_DELAY 3
#define STATE_MOVEMENT 4
#define STATE_OUTER_HOLD 5
#define STATE_OUTER_HOLD_WRONG 6
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_CENTER_HOLD_BUMP 66 /* 66 = ASCII(B) = Bump */
#define STATE_DATA_BLOCK 255

#define TONE_GO 1
#define TONE_REWARD 2
#define TONE_ABORT 3

static void mdlCheckParameters(SimStruct *S)
{
    num_targets = param_num_targets;
    target_radius = param_target_radius;
    target_size = param_target_size;

    center_hold_l = param_center_hold_l;
    center_hold_h = param_center_hold_h;

    center_delay_l = param_center_delay_l;
    center_delay_h = param_center_delay_h;

    movement_time = param_movement_time;

    outer_hold_l = param_outer_hold_l;
    outer_hold_h = param_outer_hold_h;

    abort_timeout   = param_intertrial;    
    failure_timeout = param_intertrial;
    reward_timeout  = param_intertrial;   
    incomplete_timeout = param_intertrial;
    
    idiot_mode = (int)param_idiot_mode;
    
    delay_bumps = (int)param_delay_bumps;	
	
	displacement_mean = param_displacement_mean;
	displacement_var = param_displacement_var;	
	
	beg_window = param_beg_window;
	end_window = param_end_window;

	beg_cue = param_beg_cue;
	end_cue = param_end_cue;

	cue_var = param_cue_var;
	cue_dot_size = param_cue_dot_size;
	cue_dot_num = param_cue_dot_num;

	displace_type = (int)param_displace_type;
	window_type = (int)param_window_type;

	CT_offset = param_CT_offset;
}

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    
    ssSetNumSFcnParams(S, 30); 
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
     *  target: 70 ( target 1, 2: 
     *                  on/off, 
     *                  target UL corner x, 
     *                  target UL corner y,
     *                  target LR corner x, 
     *                  target LR corner y)
     *  reward: 1
     *  tone: 2     ( 1: counter incremented for each new tone, 2: tone ID )
     *  version: 1 ( the cvs revision of the current .c file )
     *  pos: 2 (x and y position of the cursor)
     */
    if (!ssSetNumOutputPorts(S, 8)) return;
    ssSetOutputPortWidth(S, 0, 2);   /* force   */
    ssSetOutputPortWidth(S, 1, 5);   /* status  */
    ssSetOutputPortWidth(S, 2, 1);   /* word    */
    ssSetOutputPortWidth(S, 3, 70);  /* target  */
    ssSetOutputPortWidth(S, 4, 1);   /* reward  */
    ssSetOutputPortWidth(S, 5, 2);   /* tone    */
    ssSetOutputPortWidth(S, 6, 4);   /* version */
    ssSetOutputPortWidth(S, 7, 2);   /* pos     */
    
    ssSetNumSampleTimes(S, 1);
    
    /* work buffers */
    ssSetNumRWork(S, 28);  /* 0: time of last timer reset 
                             1: tone counter (incremented each time a tone is played)
                             2: tone id
                             3: catch trial (1 for yes, 0 for no)
                             4: mastercon version
							 5: displacement (in radians)
							 [6-25]: positions of cue cloud points
							 [26-27]: x-y position of held cursor position

                           */
    ssSetNumPWork(S, 0);
    ssSetNumIWork(S, 586); /*    0: state_transition (true if state changed), 
                                 1: current target index,
                            [2-17]: target presentation sequence (block/catch mode) 
                           [2-579]: target presentation sequence (bump mode) 
                               580: bump duration counter 
                               581: successes
                               582: failures
                               583: aborts 
                               584: incompletes
                               585: databurst_counter */
    
    ssSetNumPWork(S, 1); /*    0: Databurst array pointer */
    
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
    
    /* set target index to indicate that we need to begin a new block */
    ssSetIWorkValue(S, 1, (int)num_targets-1);
    
    /* set the tone counter to zero */
    ssSetRWorkValue(S, 1, 0.0);
    
    /* set catch trial to zero (init only) */
    ssSetRWorkValue(S, 3, 0.0);

	/* set held cursor position to zero */
	ssSetRWorkValue(S, 26, 0.0);
	ssSetRWorkValue(S, 27, 0.0);
    
    /* set trial counters to zero */
    ssSetIWorkValue(S, 581, 0);
    ssSetIWorkValue(S, 582, 0);
    ssSetIWorkValue(S, 583, 0);
    ssSetIWorkValue(S, 584, 0);  

    /* setup databurst */
    databurst = malloc(256);
    ssSetPWorkValue(S, 0, databurst);
    ssSetIWorkValue(S, 585, 0);  
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
static int cursorInTarget(real_T *c, real_T *t, int shape)
{
	real_T rsq;

	if (shape == TARGET_SHAPE_RECT) {

		return ( (c[0] > t[0]) && (c[1] < t[1]) && (c[0] < t[2]) && (c[1] > t[3]) );

	} else if (shape == TARGET_SHAPE_ARC) {
		rsq = c[0]*c[0] + c[1]*c[1];
		return ( /* distance criterion */ ( t[0]*t[0]+t[1]*t[1] < rsq && rsq < t[2]*t[2]+t[3]*t[3] ) &&
			     /* angle criterion */    ( t[0]*c[1]-t[1]*c[0] > 0 && c[0]*t[3]-c[1]*t[2] > 0 ) );
	} else {
		/* unknown shape, return false by default */
		return false;
	}
}

static void Corners(real_T *pos, real_T *corn, real_T width)
{
	/* Function takes the pointer to an array pos with position coordinates 
	[x1 y1 x2 y2 ...] and writes to an array corn size 2*pos with corner vales 
	[UL_X_(x1,y1) UL_Y_(x1,y1) LR_X_(x1,y1) LR_Y_(x1,y1) ...] */

	int i;
	for (i=0; i<cue_dot_num;i++){
		corn[4*i] = pos[2*i] - width/2;
		corn[4*i+1] = pos[2*i+1] + width/2;
		corn[4*i+2] = pos[2*i] + width/2;
		corn[4*i+3] = pos[2*i+1] - width/2;
	} 
}

/* gRand
 * returns a random gaussian number from the table that was set up during 
 * initialize_conditions
 */

static real_T gRand() {
	real_T r[2];
	real_T gRand;
	int i;

	for (i=0; i<2; i++) {
		r[i] = UNI;
	}

	gRand = sqrt(-2*log(r[0]))*cos(2*PI*r[1]);
	return ( gRand );

}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) 
{
    /********************
     * Declarations     *
     ********************/
    
    /* stupidly declare all variables at the begining of the function */
    int *IWorkVector; 
    int target_index;
    int *target_list;
    int target;
    int bump;
    real_T theta;
    real_T ct[4];
    real_T ot[4];
	real_T ot_w1[4], ot_w2[4];
    InputRealPtrsType uPtrs;
    real_T cursor_old[2];
	real_T cursor[2];
	real_T cursor_HOLD[2];
    real_T elapsed_timer_time;
	real_T rad_d,curs_rad, shifted_rad_d, shifted_curs_rad;
    real_T displace;
	real_T displace_RAND, cluster_RAND;
	
    int reset_block = 0;
        
    /* block initialization working variables */
    int tmp_tgts[256];
    int tmp_bump[256];
    int tmp_sort[256];
    int i, j, tmp;

    int databurst_counter;
    byte *databurst;
    float *databurst_displacement;

    /******************
     * Initialization *
     ******************/
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)state_r[0];
    int new_state = state;
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor_old[0] = *uPtrs[0];
    cursor_old[1] = *uPtrs[1];

    /* current target number */
    IWorkVector = ssGetIWork(S);
    target_index = IWorkVector[1];
    target_list = IWorkVector+2;
    if (mode == MODE_BLOCK_CATCH) {
        target = target_list[target_index];
    } else {
        /* mode == MODE_BUMP */
        target = target_list[target_index*2];
        bump = target_list[target_index*2+1];
    }
    
    /* get elapsed time since last timer reset */
    elapsed_timer_time = (real_T)(ssGetT(S)) - ssGetRWorkValue(S, 0);
    
    /* get target bounds */
	theta = PI/2 - target*2*PI/num_targets;
	
	/* correct targets */

	ct[0] = -target_size/2;
	ct[1] = target_size/2 - CT_offset;
	ct[2] = target_size/2;
	ct[3] = -target_size/2 - CT_offset;

	if( (int)displace_type == 2){

	    ot[0] = cos(theta)*target_radius-target_size/2;
		ot[1] = sin(theta)*target_radius+target_size/2;
		ot[2] = cos(theta)*target_radius+target_size/2;
		ot[3] = sin(theta)*target_radius-target_size/2;

	} else if( (int)displace_type == 1){
		
		ot[0] = (target_radius - target_size/2)*cos(theta-0.5*(target_size/(target_radius-target_size/2)));
		ot[1] = (target_radius - target_size/2)*sin(theta-0.5*(target_size/(target_radius-target_size/2)));
		ot[2] = (target_radius + target_size/2)*cos(theta+0.5*(target_size/(target_radius-target_size/2)));
		ot[3] = (target_radius + target_size/2)*sin(theta+0.5*(target_size/(target_radius-target_size/2)));

	}

	/* incorrect targets */
	if( (int)displace_type == 2){
	
		ot_w1[0] = -100;
		ot_w1[1] = ot[1];
		ot_w1[2] = ot[0];
		ot_w1[3] = ot[3];

		ot_w2[0] = ot[2];
		ot_w2[1] = ot[1];
		ot_w2[2] = 100;
		ot_w2[3] = ot[3];

	} else if( (int)displace_type == 1){
	
		ot_w1[0] = (target_radius - target_size/2)*cos(theta+0.5*(target_size/(target_radius-target_size/2)));
		ot_w1[1] = (target_radius - target_size/2)*sin(theta+0.5*(target_size/(target_radius-target_size/2)));
		ot_w1[2] = (target_radius + target_size/2)*cos(theta + PI/2);
		ot_w1[3] = (target_radius + target_size/2)*sin(theta + PI/2);

		ot_w2[0] = (target_radius - target_size/2)*cos(theta - PI/2);
		ot_w2[1] = (target_radius - target_size/2)*sin(theta - PI/2);
		ot_w2[2] = (target_radius + target_size/2)*cos(theta-0.5*(target_size/(target_radius-target_size/2)));
		ot_w2[3] = (target_radius + target_size/2)*sin(theta-0.5*(target_size/(target_radius-target_size/2)));
	
	}

	/* get displaced cursor location */

	displace = ssGetRWorkValue(S,5);
	
	rad_d = sqrt(cursor_old[0]*cursor_old[0] + cursor_old[1]*cursor_old[1]);
	curs_rad = cos(atan2(cursor_old[1],cursor_old[0])-theta)*rad_d;

	/* If displace type is type 1, then use angular displacement. If type 2, use linear displacement */
	if (state == STATE_MOVEMENT || state == STATE_OUTER_HOLD || state == STATE_OUTER_HOLD_WRONG){
		if((displace_type == 1)&&(rad_d > (beg_window*target_radius))){
			cursor[0] = rad_d * cos(atan2(cursor_old[1],cursor_old[0])+displace);
			cursor[1] = rad_d * sin(atan2(cursor_old[1],cursor_old[0])+displace);	
		}else if((displace_type == 2)&&(curs_rad > (beg_window*target_radius))){
			cursor[0] = cursor_old[0] + displace*sin(theta);
			cursor[1] = cursor_old[1] - displace*cos(theta);
		}else{
			cursor[0] = cursor_old[0];
			cursor[1] = cursor_old[1];
		}
	} else {
		cursor[0] = cursor_old[0];
		cursor[1] = cursor_old[1];
	}

	/* If window_type is type 2, use cosine (distance along ideal path to target), else use actual radius */
	if(window_type == 2){
		shifted_rad_d = sqrt(cursor[0]*cursor[0] + cursor[1]*cursor[1]);
		shifted_curs_rad = cos(atan2(cursor[1],cursor[0])-theta)*shifted_rad_d;
	} 
	else {
		shifted_rad_d = rad_d;
		shifted_curs_rad = rad_d;
	}

    databurst = ssGetPWorkValue(S,0);
    databurst_displacement = (float *)(databurst + 2);
    databurst_counter = ssGetIWorkValue(S, 585);

	/* Get cursor hold position */
	cursor_HOLD[0] = ssGetRWorkValue(S, 26);
	cursor_HOLD[1] = ssGetRWorkValue(S, 27);

    /*********************************
     * See if we have issued a reset *
     *********************************/
    if (param_master_reset != master_reset) {
        master_reset = param_master_reset;
        ssSetIWorkValue(S, 581, 0);
        ssSetIWorkValue(S, 582, 0);
        ssSetIWorkValue(S, 583, 0);
        ssSetIWorkValue(S, 584, 0);
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
            if (num_targets != param_num_targets) {
                num_targets = param_num_targets;
                reset_block = 1;
            }
            target_radius = param_target_radius;
            target_size = param_target_size;

            center_hold_l = param_center_hold_l;
            center_hold_h = param_center_hold_h;

            center_delay_l = param_center_delay_l;
            center_delay_h = param_center_delay_h;

            movement_time = param_movement_time;

            outer_hold_l = param_outer_hold_l;
            outer_hold_h = param_outer_hold_h;

            abort_timeout   = param_intertrial;    
            failure_timeout = param_intertrial;
            reward_timeout  = param_intertrial;
            incomplete_timeout = param_intertrial;
            center_bump_timeout = param_intertrial;
            
            catch_trial_pct = param_catch_trial_pct;
            
            bump_magnitude = param_bump_magnitude;
            bump_duration  = (int)param_bump_duration;
            
            idiot_mode = (int)param_idiot_mode;
            
            delay_bumps = (int)param_delay_bumps;

			displacement_mean = param_displacement_mean;
			displacement_var = param_displacement_var;
			
			beg_window = param_beg_window;
			end_window = param_end_window;

			beg_cue = param_beg_cue;
			end_cue = param_end_cue;

			cue_var = param_cue_var;
			cue_dot_size = param_cue_dot_size;
			cue_dot_num = param_cue_dot_num;
			displace_type = (int)param_displace_type;
			window_type = (int)param_window_type;

			CT_offset = param_CT_offset;

			/* get displacement of cursor drawn from normal distribution and save to work vector */
			displace_RAND = gRand();
			displace = (displacement_mean + (displace_RAND * displacement_var)); 
			ssSetRWorkValue(S,5,displace);

			/* get displacement of cue cloud drawn from normal distribution and save positions to work vector */
			for (i=0; i<20; i++){
				cluster_RAND = gRand();
				ssSetRWorkValue(S,6+i,(cluster_RAND*cue_var));
			}

            /* see if mode has changed.  If so we need a reset. */
            if (mode != param_mode) {
                reset_block = 1;
                mode = param_mode;
            }

			if (target_index == num_targets-1 || reset_block) {
                /* initialize the targets */
                for (i=0; i<num_targets; i++) {
                    tmp_tgts[i] = i;
                    tmp_sort[i] = rand();
                }
                for (i=0; i<num_targets-1; i++) {
                    for (j=0; j<num_targets-1; j++) {
                        if (tmp_sort[j] < tmp_sort[j+1]) {
                            tmp = tmp_sort[j];
                            tmp_sort[j] = tmp_sort[j+1];
                            tmp_sort[j+1] = tmp;
                            
                            tmp = tmp_tgts[j];
                            tmp_tgts[j] = tmp_tgts[j+1];
                            tmp_tgts[j+1] = tmp;
                        }
                    }
                }
                /* write them back */
                for (i=0; i<num_targets; i++) {
                    target_list[i] = tmp_tgts[i];
                }
				/* and reset the counter */
				ssSetIWorkValue(S, 1, 0);

			} else {
                /* just advance the counter */
                target_index++;
                /* and write it back */
                ssSetIWorkValue(S, 1, target_index);
                if (mode == MODE_BLOCK_CATCH) {
                    target = target_list[target_index];
                } else {
                    /* mode == MODE_BUMP */
                    target = target_list[target_index*2];
                }
            }
			
            /* In all cases, we need to decide on the random timer durations */
            if (center_hold_h == center_hold_l) {
                center_hold = center_hold_h;
            } else {
                center_hold = center_hold_l + (center_hold_h - center_hold_l)*((double)rand())/((double)RAND_MAX);
            }
            if (center_delay_h == center_delay_l) {
                center_delay = center_delay_h;
            } else {
                center_delay = center_delay_l + (center_delay_h - center_delay_l)*((double)rand())/((double)RAND_MAX);
            }
            if (outer_hold_h == outer_hold_l) {
                outer_hold = outer_hold_h;
            } else {
                outer_hold = outer_hold_l + (outer_hold_h - outer_hold_l)*((double)rand())/((double)RAND_MAX);
            }
            
            /* decide if this is a catch trial */
            if (mode == MODE_BLOCK_CATCH && catch_trial_pct > 0) {
                set_catch_trial( catch_trial_pct > (double)rand()/(double)RAND_MAX ? 1.0 : 0.0 );
            } else {
                set_catch_trial(0.0);
            }
            
            /* Setup the databurst */
            databurst[0] = 2+sizeof(float);
            databurst[1] = DATABURST_VERSION;
			databurst_displacement[0] = displace;
			
            /* reset counters */
            ssSetIWorkValue(S, 580, 0); /* clear the bump counter */
            ssSetIWorkValue(S, 585, 0); /* reset the databurst_counter */

            /* and advance */
            new_state = STATE_DATA_BLOCK;
            state_changed();

            /* skip target -1, bump -1 */
            if (target == -1 && bump == -1) {
                new_state = STATE_PRETRIAL;
            }

            break;
        case STATE_DATA_BLOCK:
            if (databurst_counter > 2*(databurst[0]-1)) { 
                new_state = STATE_CT_ON;
                state_changed();
            }
            ssSetIWorkValue(S, 585, databurst_counter+1);
            break;
        case STATE_CT_ON:
            /* center target on */
            if (cursorInTarget(cursor, ct, 2)) {
                new_state = STATE_CENTER_HOLD;
                reset_timer(); /* start center hold timer */
                state_changed();
            }
            break;
        case STATE_CENTER_HOLD:
            /* center hold */
            if (!cursorInTarget(cursor, ct,2)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > center_hold && target != -1) {
                new_state = STATE_CENTER_DELAY;
                reset_timer(); /* delay timer */
                state_changed();
            } else if (elapsed_timer_time > center_hold && target == -1) {
                new_state = STATE_CENTER_HOLD_BUMP;
                reset_timer();
                state_changed();
            }
            break;
        case STATE_CENTER_HOLD_BUMP:
            /* bump when holding in center, then sends back to pretrial */
            if (elapsed_timer_time > center_bump_timeout) {
                new_state = STATE_PRETRIAL;
                reset_timer();
                state_changed();
            }
            break;
        case STATE_CENTER_DELAY:
            /* center delay (outer target on) */
            if (!cursorInTarget(cursor, ct,2)) {
                new_state = STATE_ABORT;
                reset_timer(); /* abort timeout */
                state_changed();
            } else if (elapsed_timer_time > center_delay) {
                new_state = STATE_MOVEMENT;
                reset_timer(); /* movement timer */
                state_changed();
            }
            break;

       case STATE_MOVEMENT:
            /* movement phase (go tone on entry) */
			if (cursorInTarget(cursor,ot,(int)displace_type)){

				new_state = STATE_OUTER_HOLD;
				ssSetRWorkValue(S, 26, cursor[0]);
				ssSetRWorkValue(S, 27, cursor[1]);
				reset_timer(); /* outer hold timer */
				state_changed();

			} else if (cursorInTarget(cursor,ot_w1,(int)displace_type) ||
				cursorInTarget(cursor,ot_w2,(int)displace_type)){
			
				new_state = STATE_OUTER_HOLD_WRONG;
				ssSetRWorkValue(S, 26, cursor[0]);
				ssSetRWorkValue(S, 27, cursor[1]);
				reset_timer(); /* outer hold timer */
				state_changed();

			} else if (elapsed_timer_time > movement_time){
				new_state = STATE_INCOMPLETE;
				reset_timer(); /* failure timeout */
				state_changed();
			}
			break;

        case STATE_OUTER_HOLD:
            /* outer target hold phase */
			if (elapsed_timer_time > outer_hold_l) {
					new_state = STATE_REWARD;
					reset_timer(); /* reward (inter-trial) timeout */
					state_changed();
				if (idiot_mode) {
                    target_index--;
                    ssSetIWorkValue(S, 1, target_index);
                }
			}
            break;
		
		case STATE_OUTER_HOLD_WRONG:
			/* outer target hold phase */
			if (elapsed_timer_time > outer_hold_h) {
				new_state = STATE_FAIL;
				reset_timer(); /* Failure timeout */
				state_changed();	
				if (idiot_mode) {
                    target_index--;
                    ssSetIWorkValue(S, 1, target_index);
                }
			}
			break;

        case STATE_ABORT:
            /* abort */
            if (elapsed_timer_time > abort_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
                
                if (idiot_mode) {
                    target_index--;
                    ssSetIWorkValue(S, 1, target_index);
                }
            }
            break;
        case STATE_FAIL:
            /* failure */
            if (elapsed_timer_time > failure_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
                if (idiot_mode) {
                    target_index--;
                    ssSetIWorkValue(S, 1, target_index);
                }
            }
            break;
        case STATE_INCOMPLETE:
            /* incomplete */
            if (elapsed_timer_time > incomplete_timeout) {
                new_state = STATE_PRETRIAL;
                state_changed();
                if (idiot_mode) {
                    target_index--;
                    ssSetIWorkValue(S, 1, target_index);
                }
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
    
    UNUSED_ARG(tid);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /********************
     *  Initialization
     ********************/
    int i,j;
    int_T *IWorkVector; 
    int_T target_index;
    int_T *target_list;
    int target;
    int bump; /* direction of bump */
    int bump_duration_counter;
    real_T theta;
    real_T ct[4];
    real_T ot[4];
	real_T ot_w1[4], ot_w2[4];
    real_T displace, rad_d, curs_rad, shifted_rad_d, shifted_curs_rad;
    
    InputRealPtrsType uPtrs;
    real_T cursor_old[2];
    real_T cursor[2];
	real_T cursor_HOLD[2];
    real_T force_in[2];
    real_T catch_force_in[2];
    
    /* allocate holders for outputs */
    real_T force_x, force_y, word, reward, tone_cnt, tone_id, pos_x, pos_y;
    real_T target_pos[70];
	real_T cue_pos[40];
	real_T cue_cents[20];
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
    
    /* get current state */
    real_T *state_r = ssGetRealDiscStates(S);
    int state = (int)(state_r[0]);
    int new_state = ssGetIWorkValue(S, 0);
    ssSetIWorkValue(S, 0, 0); /* reset changed state each iteration */

    /* current target number */
    IWorkVector = ssGetIWork(S);
    target_index = IWorkVector[1];
    target_list = IWorkVector+2;    
    if (mode == MODE_BLOCK_CATCH) {
        target = target_list[target_index];
    } else {
        /* mode == MODE_BUMP */
        target = target_list[target_index*2];
        bump = target_list[target_index*2+1];
    }

    bump_duration_counter = ssGetIWorkValue(S, 580);
    
    /* get current tone counter */
    tone_cnt = ssGetRWorkValue(S, 1);
    tone_id = ssGetRWorkValue(S, 2);
    
    /* get target bounds */
	theta = PI/2 - target*2*PI/num_targets;
	
	/* correct targets */

	ct[0] = -target_size/2;
	ct[1] = target_size/2 - CT_offset;
	ct[2] = target_size/2;
	ct[3] = -target_size/2 - CT_offset;

	if( (int)displace_type == 2){

	    ot[0] = cos(theta)*target_radius-target_size/2;
		ot[1] = sin(theta)*target_radius+target_size/2;
		ot[2] = cos(theta)*target_radius+target_size/2;
		ot[3] = sin(theta)*target_radius-target_size/2;

	} else if( (int)displace_type == 1){
		
		ot[0] = (target_radius - target_size/2)*cos(theta-0.5*(target_size/(target_radius-target_size/2)));
		ot[1] = (target_radius - target_size/2)*sin(theta-0.5*(target_size/(target_radius-target_size/2)));
		ot[2] = (target_radius + target_size/2)*cos(theta+0.5*(target_size/(target_radius-target_size/2)));
		ot[3] = (target_radius + target_size/2)*sin(theta+0.5*(target_size/(target_radius-target_size/2)));

	}

	/* incorrect targets */
	if( (int)displace_type == 2){
	
		ot_w1[0] = -100;
		ot_w1[1] = ot[1];
		ot_w1[2] = ot[0];
		ot_w1[3] = ot[3];

		ot_w2[0] = ot[2];
		ot_w2[1] = ot[1];
		ot_w2[2] = 100;
		ot_w2[3] = ot[3];

	} else if( (int)displace_type == 1){
	
		ot_w1[0] = (target_radius - target_size/2)*cos(theta+0.5*(target_size/(target_radius-target_size/2)));
		ot_w1[1] = (target_radius - target_size/2)*sin(theta+0.5*(target_size/(target_radius-target_size/2)));
		ot_w1[2] = (target_radius + target_size/2)*cos(theta + PI/2);
		ot_w1[3] = (target_radius + target_size/2)*sin(theta + PI/2);

		ot_w2[0] = (target_radius - target_size/2)*cos(theta - PI/2);
		ot_w2[1] = (target_radius - target_size/2)*sin(theta - PI/2);
		ot_w2[2] = (target_radius + target_size/2)*cos(theta-0.5*(target_size/(target_radius-target_size/2)));
		ot_w2[3] = (target_radius + target_size/2)*sin(theta-0.5*(target_size/(target_radius-target_size/2)));
	
	}
    
    /* current cursor location */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
    cursor_old[0] = *uPtrs[0];
    cursor_old[1] = *uPtrs[1];
	
	displace = ssGetRWorkValue(S,5);
	
	rad_d = sqrt(cursor_old[0]*cursor_old[0] + cursor_old[1]*cursor_old[1]);
	curs_rad = cos(atan2(cursor_old[1],cursor_old[0])-theta)*rad_d;

	/* If displace type is type 1, then use angular displacement. If type 2, use linear displacement */
	if (state == STATE_MOVEMENT || state == STATE_OUTER_HOLD || state == STATE_OUTER_HOLD_WRONG){
		if((displace_type == 1)&&(rad_d > (beg_window*target_radius))){
			cursor[0] = rad_d * cos(atan2(cursor_old[1],cursor_old[0])+displace);
			cursor[1] = rad_d * sin(atan2(cursor_old[1],cursor_old[0])+displace);	
		}else if((displace_type == 2)&&(curs_rad > (beg_window*target_radius))){
			cursor[0] = cursor_old[0] + displace*sin(theta);
			cursor[1] = cursor_old[1] - displace*cos(theta);
		}else{
			cursor[0] = cursor_old[0];
			cursor[1] = cursor_old[1];
		}
	} else {
		cursor[0] = cursor_old[0];
		cursor[1] = cursor_old[1];
	}

	/* If window_type is type 2, use cosine (distance along ideal path to target), else use actual radius */
	if(window_type == 2){
		shifted_rad_d = sqrt(cursor[0]*cursor[0] + cursor[1]*cursor[1]);
		shifted_curs_rad = cos(atan2(cursor[1],cursor[0])-theta)*shifted_rad_d;
	} else {
		shifted_rad_d = rad_d;
		shifted_curs_rad = curs_rad;
	}
  
    /* input force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 2);
    force_in[0] = *uPtrs[0];
    force_in[1] = *uPtrs[1];
    
    /* input catch force */
    uPtrs = ssGetInputPortRealSignalPtrs(S, 3);
    catch_force_in[0] = *uPtrs[0];
    catch_force_in[1] = *uPtrs[1];
    
    /* databurst */
    databurst_counter = ssGetIWorkValue(S, 585);
    databurst = (byte *)ssGetPWorkValue(S, 0);
    
    /********************
     * Calculate outputs
     ********************/
    
    /* force (0) */
    if (mode == MODE_BLOCK_CATCH) {
        if (get_catch_trial() && (
                state == STATE_CENTER_DELAY ||
                state == STATE_MOVEMENT ||
                state == STATE_OUTER_HOLD
            )) 
        {
            force_x = catch_force_in[0];
            force_y = catch_force_in[1];
        } else {
            force_x = force_in[0]; 
            force_y = force_in[1]; 
        }
    } else {
        /* mode == MODE_BUMP */
        /* see if we are in a bump */
        if (bump_duration_counter > 0) {
            /* yes, so decrement the counter and maintain the bump */
            bump_duration_counter--;
            if (bump_duration_counter == 0)
                bump_duration_counter = -1; /* don't bump again */
            theta = PI/2 - bump*2*PI/num_targets;
            force_x = force_in[0] + cos(theta)*bump_magnitude;
            force_y = force_in[1] + sin(theta)*bump_magnitude;
        } else if ( bump != -1 && 
                    bump_duration_counter != -1 && 
                    ( 
                      (state==STATE_MOVEMENT && sqrt(cursor[0]*cursor[0]+cursor[1]*cursor[1]) > target_radius / 2) || 
                      (state==STATE_MOVEMENT && delay_bumps) ||
                      (state==STATE_CENTER_HOLD_BUMP) 
                    )
                  ) 
        {
            /* initiating a new mid-movement bump */
            bump_duration_counter = bump_duration;
            theta = PI/2 - bump*2*PI/num_targets;
            force_x = force_in[0] + cos(theta)*bump_magnitude;
            force_y = force_in[1] + sin(theta)*bump_magnitude;
        } else {
            force_x = force_in[0]; 
            force_y = force_in[1];
        }
    }
    
    /* status (1) */
    if (state == STATE_REWARD && new_state)
        ssSetIWorkValue(S, 581, ssGetIWorkValue(S, 581)+1);
    if (state == STATE_ABORT && new_state)
        ssSetIWorkValue(S, 582, ssGetIWorkValue(S, 582)+1);
    if (state == STATE_FAIL && new_state)
        ssSetIWorkValue(S, 583, ssGetIWorkValue(S, 583)+1);
    if (state == STATE_INCOMPLETE && new_state)
        ssSetIWorkValue(S, 584, ssGetIWorkValue(S, 584)+1);
       
    
    status[0] = state;
    status[1] = ssGetIWorkValue(S, 581); /* num rewards     */
    status[2] = ssGetIWorkValue(S, 582); /* num aborts      */
    status[3] = ssGetIWorkValue(S, 583); /* num fails       */
    status[4] = ssGetIWorkValue(S, 584); /* num incompletes */
    
    /* word (2) */
    if (state == STATE_DATA_BLOCK) {
        if (databurst_counter % 2 == 0) {
            word = databurst[databurst_counter / 2] | 0xF0; // low order bits
        } else {
            word = (databurst[(databurst_counter-1) / 2] >> 4) | 0xF0; /* high order bits */
        }
    } else if (new_state) {
        switch (state) {
            case STATE_PRETRIAL:
                word = WORD_START_TRIAL;
                break;
            case STATE_CT_ON:
                word = WORD_CT_ON;
                break;
            case STATE_CENTER_DELAY:
                word = WORD_OT_ON(target);
                break;
            case STATE_CENTER_HOLD_BUMP:
                word = WORD_BUMP(bump);
                break;
            case STATE_MOVEMENT:
                if (MODE_BLOCK_CATCH && get_catch_trial()) {
                    word = WORD_CATCH;
                } else {
                    word = WORD_GO_CUE;
                }
                break;
			case STATE_OUTER_HOLD:
				word = WORD_REWARD;
				break;
			case STATE_OUTER_HOLD_WRONG:
				word = WORD_FAIL;
				break;
            case STATE_ABORT:
                word = WORD_ABORT;
                break;
            case STATE_INCOMPLETE:
                word = WORD_INCOMPLETE;
                break;
            default:
                word = 0;
        }
    } else {
        /* not a new state, but maybe we have a mid-state event */
        if (bump != -1 && mode == MODE_BUMP && bump_duration_counter == bump_duration - 1) {
            /* just started a bump */
            word = WORD_BUMP(bump);
        } else {
            word = 0;
        }
    }
    
    /* target_pos (3) */
    if ( state == STATE_CT_ON || 
         state == STATE_CENTER_HOLD || 
         state == STATE_CENTER_HOLD_BUMP ||
         state == STATE_CENTER_DELAY )
    {
        /* center target on */
        target_pos[0] = 1;
        for (i=0; i<4; i++) {
            target_pos[i+1] = ct[i];
        }
    } else  {
        /* center target off */
        target_pos[0] = 0;
        for (i=0; i<4; i++) {
            target_pos[i+1] = 0;
        }
    }
    
    if ( state == STATE_CENTER_DELAY ||
         state == STATE_MOVEMENT ||
         state == STATE_OUTER_HOLD ||
		 state == STATE_OUTER_HOLD_WRONG)
    {
        /* outer targets on */
		if( (int)displace_type == 2){
			target_pos[5] = 1;
			target_pos[10] = 7;
			target_pos[15] = 7;
		} else if( (int)displace_type == 1){
			target_pos[5] = 5;
			target_pos[10] = 8;
			target_pos[15] = 8;
		}
		for (i=0; i<4; i++) {
			target_pos[i+6] = ot[i];
			target_pos[i+11] = ot_w1[i];
			target_pos[i+16] = ot_w2[i];
		}
    }  else {
       /* outer targets off */
		target_pos[5] = 0;
		target_pos[10] = 0;
		target_pos[15] = 0;
		for (i=0; i<4; i++) {
			target_pos[i+6] = 0;
			target_pos[i+11] = 0;
			target_pos[i+16] = 0;
		}
    }
	/* DRAW CUE CLUSTER */ 

	/* Get cue positions from work vector and save to cue_cents vector */
	for (i = 0; i<10; i++){
		cue_cents[2*i] = (cursor[0] + ssGetRWorkValue(S,6+i));
		cue_cents[2*i+1] = (cursor[1] + ssGetRWorkValue(S,7+i));
	}

	Corners(cue_cents,cue_pos,cue_dot_size);

	for (i = 0; i<cue_dot_num; i++){
		target_pos[20+5*i] = 16;
		target_pos[21+5*i] = cue_pos[0+4*i];
		target_pos[22+5*i] = cue_pos[1+4*i];
		target_pos[23+5*i] = cue_pos[2+4*i];
		target_pos[24+5*i] = cue_pos[3+4*i];
	}

	/* Display cue cloud when inside window */

	if((int)window_type == 2){
		if ((state != STATE_MOVEMENT) || 
			!((shifted_curs_rad > beg_cue*target_radius) && (shifted_curs_rad < end_cue*target_radius)))
		{
			for (i=0; i<cue_dot_num; i++){
				target_pos[20+5*i] = 0;
			}
		}
	}else{
		if ((state != STATE_MOVEMENT) || 
			!((rad_d > beg_cue*target_radius) && (rad_d < end_cue*target_radius)))
		{
			for (i=0; i<cue_dot_num; i++){
				target_pos[20+5*i] = 0;
			}
		}
	}

    /* reward (4) */
    if (new_state && state==STATE_OUTER_HOLD) {
        reward = 1;
    } else {
        reward = 0;
    }
    
    /* tone (5) */
    if (new_state) {
        if (state == STATE_ABORT) {
            tone_cnt++;
            tone_id = TONE_ABORT;
        } else if (state == STATE_MOVEMENT) {
            tone_cnt++;
            tone_id = TONE_GO;
        } else if (state == STATE_OUTER_HOLD) {
            tone_cnt++;
            tone_id = TONE_REWARD;
		} else if (state == STATE_OUTER_HOLD_WRONG) {
			tone_cnt++;
			tone_id = TONE_ABORT;
        }
    }
    
    /* version (6) */
    version[0] = BEHAVIOR_VERSION_MAJOR;
    version[1] = BEHAVIOR_VERSION_MINOR;
    version[2] = BEHAVIOR_VERSION_MICRO;
    version[3] = BEHAVIOR_VERSION_BUILD;
    
	
    /* pos (7) */
	cursor_HOLD[0] = ssGetRWorkValue(S,26);
	cursor_HOLD[1] = ssGetRWorkValue(S,27);

	if ((int)window_type == 2){
		if ((state == STATE_MOVEMENT) && 
			((shifted_curs_rad > beg_window*target_radius) && (shifted_curs_rad < end_window*target_radius))){
			/* We are inside the blocking window */
			pos_x = 1E6;
			pos_y = 1E6;
		} else if((state == STATE_OUTER_HOLD) || (state == STATE_OUTER_HOLD_WRONG)){
			pos_x = cursor_HOLD[0];
			pos_y = cursor_HOLD[1];
		} else{
			/* We are outside of the blocking window */
			pos_x = cursor[0];
			pos_y = cursor[1];
		}
	}else{
		if ((state == STATE_MOVEMENT) && 
			((rad_d > beg_window*target_radius) && (rad_d < end_window*target_radius))){
			/* We are inside the blocking window */
			pos_x = 1E6;
			pos_y = 1E6;
		}else if((state == STATE_OUTER_HOLD) || (state == STATE_OUTER_HOLD_WRONG)){
			pos_x = cursor_HOLD[0];
			pos_y = cursor_HOLD[1]; 
		}else{
			/* We are outside of the blocking window */
			pos_x = cursor[0];
			pos_y = cursor[1];
		}
	}

    /**********************************
     * Write outputs back to SimStruct
     **********************************/
    force_p = ssGetOutputPortRealSignal(S,0);
    force_p[0] = force_x;
    force_p[1] = force_y;
    ssSetIWorkValue(S, 580, bump_duration_counter);
    
    status_p = ssGetOutputPortRealSignal(S,1);
    for (i=0; i<5; i++) 
        status_p[i] = status[i];
    
    word_p = ssGetOutputPortRealSignal(S,2);
    word_p[0] = word;
    
    target_p = ssGetOutputPortRealSignal(S,3);
    for (i=0; i<70; i++) {
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
