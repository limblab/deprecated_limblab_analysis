/* $Id: $
 *
 * Master Control block for behavior: attention
 */

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
 * byte         1: uchar => databurst version number (in this case zero)
 * byte         2: uchar => model version major
 * byte         3: uchar => model version minor
 * bytes   4 to 5: short => model version micro
 * bytes   6 to 9: float => x offset (cm)
 * bytes 10 to 13: float => y offset (cm)
 * byte        14: uchar => trial type (0=visual, 1=proprioceptive, 2=control)
 * byte		   15: uchar => staircase ID
 * byte        16: uchar => training mode (1=yes, 0=no)
 * byte        17: uchar => catch trial (1=yes, 0=no)
 * bytes 18 to 21: float => main direction (rad)
 * bytes 22 to 25: float => bump magnitude (N?)
 * bytes 26 to 29: float => bump direction (rad)
 * bytes 30 to 33: float => bump duration (s)
 * bytes 34 to 37: float => moving dots target size (cm)
 * bytes 38 to 41: float => dots coherence (0-100%)
 * bytes 42 to 45: float => dots direction (rad)
 * bytes 46 to 49: float => dots speed (cm/s)
 * byte		   50: uchar => number of dots
 * bytes 51 to 54: float => dot radius (cm)
 * byte        55: uchar => dot movement type (0=random walk, 1=Newsome)
 * bytes 56 to 59: float => reward target center x (cm)
 * bytes 60 to 63: float => reward target center y (cm)
 * bytes 64 to 67: float => bias force magnitude (N?)
 * bytes 68 to 71: float => bias force direction (rad)
 */

#define S_FUNCTION_NAME mastercon_attention
#define S_FUNCTION_LEVEL 2

// Our task code will be in the databurst
#define TASK_AT 1
#include "words.h"

#include "common_header.cpp"

/* Trial types */
#define VISUAL_TRIAL 0
#define PROPRIO_TRIAL 1
#define CONTROL_TRIAL 2

/*
 * State IDs
 */
#define STATE_PRETRIAL				 0
#define STATE_CENTER_TARGET_ON		 1
#define STATE_CENTER_HOLD			 2
#define STATE_STIMULI				 3
#define STATE_MOVEMENT				 4

/* 
 * STATE_REWARD STATE_ABORT STATE_FAIL STATE_INCOMPLETE STATE_DATA_BLOCK 
 * are all defined in Behavior.h Do not use state numbers above 64 (0x40)
 */

#define DATABURST_VERSION ((byte)0x00) 

// This must be custom defined for your behavior
struct LocalParams{
	real_T master_reset;

	// Timing
	real_T center_hold_l;
	real_T center_hold_h;
	real_T movement_time;
	real_T reward_timeout;
	real_T fail_timeout;
	real_T abort_timeout;

	// Target parameters
	real_T target_size;
	real_T target_radius;

	// Trial types
	real_T percent_visual_trials;
	real_T percent_proprio_trials;
	real_T trial_block_size;
	real_T percent_training_trials;
	real_T percent_training_step;
	real_T percent_catch_trials;
	real_T blocked_directions;
	real_T blocked_difficulty;
	real_T num_directions;
	real_T first_main_direction;
	
	// Stimuli
	// Moving dots
	real_T moving_dots_duration;
	real_T moving_dots_target_size;
	real_T moving_dots_coherence;
	real_T moving_dots_speed;
	real_T moving_dots_num_dots;
	real_T moving_dots_dot_radius;
	real_T moving_dots_movement_type;
	real_T moving_dots_num_steps;
	real_T moving_dots_easy_min_separation;
	real_T moving_dots_easy_max_separation;
	real_T moving_dots_hard_min_separation;
	real_T moving_dots_hard_max_separation;
	
	// Bumps
	real_T bump_duration;
	real_T bump_num_steps;
	real_T bump_easy_min_separation;
	real_T bump_easy_max_separation;	
	real_T bump_hard_min_separation;
	real_T bump_hard_max_separation;
	real_T bump_magnitude;
	
	real_T use_staircases;
	real_T staircase_reset;

	// Bias force
	real_T bias_force_magnitude;
	real_T bias_force_direction;
	real_T bias_force_ramp;
};

/**
 * This is the behavior class.  You must extend "Behavior" and implement
 * at least a constructor and the functions:
 *   void update(SimStruct *S)
 *   void calculateOutputs(SimStruct *S)
 *
 * You must also update the definition below with the name of your class
 */
#define MY_CLASS_NAME AttentionBehavior
class AttentionBehavior : public RobotBehavior {
public:
	// You must implement these three public methods
	AttentionBehavior(SimStruct *S);
	void update(SimStruct *S);
	void calculateOutputs(SimStruct *S);	

private:
	// Your behavior's instance variables
    
    MovingDotsTargetA *dotsTargetA;
    MovingDotsTargetB *dotsTargetB;
    
	SquareTarget *centerTarget;
	SquareTarget *leftResponseTarget;
	SquareTarget *rightResponseTarget;
	SquareTarget *rewardTarget; 
	SquareTarget *failTarget;

	real_T center_hold;

    Staircase *proprioStairs[16];
	Staircase *visualStairs[16];
	int staircase_id;
	int i_dir;
	
	int trial_type;	/* VISUAL_TRIAL, PROPRIO_TRIAL, CONTROL_TRIAL */
	int trial_counter;
	int training_mode;
	int catch_trial;
	int left_stim;

	int visual_color;
	int proprio_color;
	int control_color;
	int response_color;

	int debug_var;
	
	int easy_trial;
	real_T moving_dots_easy_step_size;	
	real_T moving_dots_hard_step_size;	
	real_T main_direction;
	real_T bump_direction;
	real_T bump_easy_step_size;
	real_T bump_hard_step_size;
	real_T total_bump_duration;
	real_T bump_direction_history[100];
	int bump_direction_read_index;
	int bump_direction_write_index;

	real_T current_percent_training_mode;

	TrapBumpGenerator *bump;
	TrapBumpGenerator *bias_force;

	LocalParams *params;
	real_T last_staircase_reset;

	// any helper functions you need
	void doPreTrial(SimStruct *S);
	void setupProprioStaircase(int i, double angle, double step, double fl, double bl);
	void setupVisualStaircase(int i, double angle, double step, double fl, double bl);
};

AttentionBehavior::AttentionBehavior(SimStruct *S) : RobotBehavior() {
    int i;

	/* 
	 * First, set up the parameters to be used 
	 */
	// Create your *params object
	params = new LocalParams();

	// Set up the number of parameters you'll be using
	this->setNumParams(43);
	// Identify each bound variable 
	this->bindParamId(&params->master_reset,							 0);
	this->bindParamId(&params->center_hold_l,							 1);
	this->bindParamId(&params->center_hold_h,							 2);
	this->bindParamId(&params->movement_time,							 3);
	this->bindParamId(&params->reward_timeout,							 4);
	this->bindParamId(&params->fail_timeout,							 5);
    this->bindParamId(&params->abort_timeout,							 6);

	this->bindParamId(&params->target_size,								 7);
	this->bindParamId(&params->target_radius,							 8);

	this->bindParamId(&params->percent_visual_trials,					 9);
	this->bindParamId(&params->percent_proprio_trials,					10);
	this->bindParamId(&params->trial_block_size,						11);
	this->bindParamId(&params->percent_training_trials,					12);
	this->bindParamId(&params->percent_catch_trials,					13);
	this->bindParamId(&params->blocked_directions,						14);
	this->bindParamId(&params->blocked_difficulty,						15);
	this->bindParamId(&params->num_directions,							16);
	this->bindParamId(&params->first_main_direction,					17);

	this->bindParamId(&params->moving_dots_duration,					18);
	this->bindParamId(&params->moving_dots_target_size,					19);
	this->bindParamId(&params->moving_dots_coherence,					20);
	this->bindParamId(&params->moving_dots_speed,						21);
	this->bindParamId(&params->moving_dots_num_dots,					22);
	this->bindParamId(&params->moving_dots_dot_radius,					23);
	this->bindParamId(&params->moving_dots_movement_type,				24);
	this->bindParamId(&params->moving_dots_easy_min_separation,			25);
	this->bindParamId(&params->moving_dots_easy_max_separation,			26);
	this->bindParamId(&params->moving_dots_num_steps,					27);
	this->bindParamId(&params->moving_dots_hard_min_separation,			28);
	this->bindParamId(&params->moving_dots_hard_max_separation,			29);

	this->bindParamId(&params->bump_duration,							30);
	this->bindParamId(&params->bump_num_steps,							31);
	this->bindParamId(&params->bump_easy_min_separation,				32);
	this->bindParamId(&params->bump_easy_max_separation,				33);
	this->bindParamId(&params->bump_hard_min_separation,				34);
	this->bindParamId(&params->bump_hard_max_separation,				35);
	this->bindParamId(&params->bump_magnitude,							36);

	this->bindParamId(&params->use_staircases,							37);
	this->bindParamId(&params->staircase_reset,							38);
	this->bindParamId(&params->bias_force_magnitude,					39);
	this->bindParamId(&params->bias_force_direction,					40);
	this->bindParamId(&params->bias_force_ramp,							41);		

	this->bindParamId(&params->percent_training_step,					42);
    
    // default parameters:
    // 0 .5 1 5 1 1 1   3 10   40 30 20 20 20 1 1 4 0   1 10 80 1 50 .1 0 1.57 3.14 5 0 1.57   .3 5 1.57 3.14 0 1.57 .005   0 0 .003 0 .2
    
	// declare which already defined parameter is our master reset 
	// (if you're using one) otherwise omit the following line
	this->setMasterResetParamId(0);

	// This function now fetches all of the parameters into the variables
	// as defined above.
	//this->updateParameters(S);
	
	debug_var = -1;
	last_staircase_reset = -1; // force a staircase reset of first trial

	visual_color = Target::Color(50,50,255);
	proprio_color = Target::Color(255,180,0);
	control_color = Target::Color(50,200,50);
	response_color = Target::Color(255,0,0);
    
    dotsTargetA = new MovingDotsTargetA();
    dotsTargetB = new MovingDotsTargetB();

	centerTarget = new SquareTarget();

	leftResponseTarget = new SquareTarget(); 
	rightResponseTarget = new SquareTarget(); 

	rewardTarget = new SquareTarget(); 
	failTarget = new SquareTarget();

	leftResponseTarget->color = response_color;
	rightResponseTarget->color = response_color;

	for (i=0; i<16; i++) {
		proprioStairs[i] = new Staircase();		
		visualStairs[i] = new Staircase();
	}
		
	staircase_id = -1;
	trial_type = 0;
	trial_counter = 0;
	training_mode = false;
	catch_trial = false;
	left_stim = true;
	easy_trial = true;

	main_direction = 0.0;
	bump_direction = 0.0;

	for (i=0; i<100; i++){
		bump_direction_history[i] = -1;
	}
	bump_direction_read_index = 0;
	bump_direction_write_index = 0;

	current_percent_training_mode = -100;

	bump = new TrapBumpGenerator();
	bias_force = new TrapBumpGenerator();
}

void AttentionBehavior::setupProprioStaircase(
	int i, double start_magnitude, double step, double fl, double bl) 
{	
	proprioStairs[i]->setStartValue( start_magnitude );
	proprioStairs[i]->setRatio( 3 );
	proprioStairs[i]->setStep( step );
	proprioStairs[i]->setUseForwardLimit( 1 );
	proprioStairs[i]->setUseBackwardLimit( 1 );
	proprioStairs[i]->setForwardLimit( fl );
	proprioStairs[i]->setBackwardLimit( bl );
	proprioStairs[i]->restart();
}

void AttentionBehavior::setupVisualStaircase(
	int i, double start_size, double step, double fl, double bl) 
{	
	visualStairs[i]->setStartValue( start_size );
	visualStairs[i]->setRatio( 3 );
	visualStairs[i]->setStep( step );
	visualStairs[i]->setUseForwardLimit( 1 );
	visualStairs[i]->setUseBackwardLimit( 1 );
	visualStairs[i]->setForwardLimit( fl );
	visualStairs[i]->setBackwardLimit( bl );
	visualStairs[i]->restart();
}


void AttentionBehavior::doPreTrial(SimStruct *S) {
	int i;
	real_T temp_real;
	real_T temp_real2;

	center_hold = this->random->getDouble(params->center_hold_l, params->center_hold_h);
	
	moving_dots_easy_step_size = (params->moving_dots_easy_max_separation - params->moving_dots_easy_min_separation)/(2*params->moving_dots_num_steps);
	bump_easy_step_size = (params->bump_easy_max_separation - params->bump_easy_min_separation)/(2*params->bump_num_steps);	
	moving_dots_hard_step_size = (params->moving_dots_hard_max_separation - params->moving_dots_hard_min_separation)/(2*params->moving_dots_num_steps);
	bump_hard_step_size = (params->bump_hard_max_separation - params->bump_hard_min_separation)/(2*params->bump_num_steps);
	
	real_T visual_stair_step_size = (params->moving_dots_easy_max_separation)/(2*params->moving_dots_num_steps);
	real_T bump_stair_step_size = (params->bump_easy_max_separation)/(2*params->bump_num_steps);

	if (last_staircase_reset != params->staircase_reset) {
		// load parameters to the staircases and reset them.
		last_staircase_reset = params->staircase_reset;
		for (i=0 ; i < params->num_directions ; i++){
			temp_real  = i * 2 * PI / (params->num_directions) + params->first_main_direction;
			temp_real2  = (params->moving_dots_easy_max_separation)/2;
			setupVisualStaircase(i*2, temp_real - temp_real2, visual_stair_step_size, temp_real, temp_real - temp_real2);
			setupVisualStaircase(i*2+1, temp_real + temp_real2, -visual_stair_step_size, temp_real, temp_real + temp_real2);			

			temp_real2  = (params->bump_easy_max_separation)/2;
			setupProprioStaircase(i*2, temp_real - temp_real2, bump_stair_step_size, temp_real, temp_real - temp_real2);
			setupProprioStaircase(i*2+1, temp_real + temp_real2, -bump_stair_step_size, temp_real, temp_real + temp_real2);						
		};
        // also reset trial blocks and bump direction history
        trial_counter = 0;
		for (i=0; i<100; i++)
			bump_direction_history[i] = -1;
		bump_direction_read_index = 200;
		bump_direction_write_index = 200;
		current_percent_training_mode = -100;
	}

	trial_counter++;
	if (trial_counter > params->trial_block_size)
		trial_counter = 1;

	// Select a trial type
	if (params->trial_block_size > 1){
		if ((100*trial_counter/params->trial_block_size) <= params->percent_proprio_trials){
			trial_type = PROPRIO_TRIAL;
		} else if ((100*trial_counter/params->trial_block_size) <= (params->percent_visual_trials + params->percent_proprio_trials)){
			trial_type = VISUAL_TRIAL;
		} else {
			trial_type = CONTROL_TRIAL;
		}
	} else {
		temp_real = random->getDouble(0,100);
		if (temp_real <= params->percent_visual_trials){
			trial_type = VISUAL_TRIAL;
		} else if (temp_real <= (params->percent_visual_trials + params->percent_proprio_trials)){
			trial_type = PROPRIO_TRIAL;
		} else {
			trial_type = CONTROL_TRIAL; 
		}
	}
		
	catch_trial = (this->random->getDouble(0,100) < params->percent_catch_trials) ? 1 : 0;
	
	if (current_percent_training_mode == -100){
		current_percent_training_mode = params->percent_training_trials;
	} 
	current_percent_training_mode = current_percent_training_mode > 100 ? 100 : current_percent_training_mode;
	current_percent_training_mode = current_percent_training_mode < 0 ? 0 : current_percent_training_mode;
	training_mode = (this->random->getDouble(0,100) < current_percent_training_mode) ? 1 : 0;
	
    dotsTargetA->width = params->moving_dots_target_size;
    dotsTargetA->centerX = 0;
    dotsTargetA->centerY = 0;
    dotsTargetA->coherence = params->moving_dots_coherence;
    
    dotsTargetB->speed = params->moving_dots_speed;
    dotsTargetB->num_dots = (int)(params->moving_dots_num_dots);
    dotsTargetB->dot_radius = params->moving_dots_dot_radius;
    dotsTargetB->newsome_dots = (int)(params->moving_dots_movement_type);
    
	// Set up target locations, etc.
	centerTarget->width = params->target_size;

	leftResponseTarget->width = params->target_size;
	rightResponseTarget->width = params->target_size;
	
	// Pick the main direction
	if (!params->blocked_directions || trial_counter==1){
        if (params->num_directions>0){
            i_dir = random->getInteger(0,(int)(params->num_directions-1));
            main_direction = fmod(i_dir * 2 * PI/params->num_directions + params->first_main_direction,2*PI);
        } else {
			i_dir = 0;
            main_direction = random->getDouble(0,2*PI);
        }
    }

	leftResponseTarget->centerX = params->target_radius*cos(main_direction+PI/2);
	leftResponseTarget->centerY = params->target_radius*sin(main_direction+PI/2);
	rightResponseTarget->centerX = params->target_radius*cos(main_direction-PI/2);
	rightResponseTarget->centerY = params->target_radius*sin(main_direction-PI/2);

	// Pick an easy or hard trial
	if (!params->blocked_difficulty || trial_counter==1){
		easy_trial = random->getBool();
	}

	// Pick a stimulus to the left or right
	left_stim = random->getBool();
	staircase_id = left_stim + i_dir*2; // right stim = even, left stim = odd.

	dotsTargetB->direction = 0;

	if (trial_type == VISUAL_TRIAL) {
		centerTarget->color = visual_color;
		leftResponseTarget->color = visual_color;
		rightResponseTarget->color = visual_color;	

		if (params->use_staircases){
			dotsTargetB->direction = visualStairs[staircase_id]->getValue();
		} else {
			i = random->getInteger(0,(int)(params->moving_dots_num_steps-1));
			if (easy_trial){
				 temp_real = (params->moving_dots_easy_min_separation + 
					i*(params->moving_dots_easy_max_separation - params->moving_dots_easy_min_separation)/(params->moving_dots_num_steps-1))/2;
				 dotsTargetB->direction = left_stim ? main_direction + temp_real : main_direction - temp_real;
			} else {
				 temp_real = (params->moving_dots_hard_min_separation + 
					i*(params->moving_dots_hard_max_separation - params->moving_dots_hard_min_separation)/(params->moving_dots_num_steps-1))/2;
				 dotsTargetB->direction = left_stim ? main_direction + temp_real : main_direction - temp_real;
			}	

		}

		//i = random->getInteger(0,(int)(params->num_directions-1));
		//bump_direction = i*2*PI/(params->num_directions) + params->first_main_direction;

		/*temp_real = (params->bump_hard_min_separation + 
					i*(params->bump_hard_max_separation - params->bump_hard_min_separation)/(params->bump_num_steps-1))/2;
		bump_direction = left_stim ? main_direction + temp_real : main_direction - temp_real;*/

		if (left_stim){
			rewardTarget = leftResponseTarget;
			failTarget = rightResponseTarget;
		} else {
            rewardTarget = rightResponseTarget;
			failTarget = leftResponseTarget;
        }

	} else if ( trial_type == PROPRIO_TRIAL ) {	
		centerTarget->color = proprio_color;
		leftResponseTarget->color = proprio_color;
		rightResponseTarget->color = proprio_color;

		if (params->use_staircases){
			bump_direction = proprioStairs[staircase_id]->getValue();
		} else {			
			i = random->getInteger(0,(int)(params->bump_num_steps-1));
			if (easy_trial){
				 temp_real = (params->bump_easy_min_separation + 
					i*(params->bump_easy_max_separation - params->bump_easy_min_separation)/(params->bump_num_steps-1))/2;
				 bump_direction = left_stim ? main_direction + temp_real : main_direction - temp_real;
			} else {
				 temp_real = (params->bump_hard_min_separation + 
					i*(params->bump_hard_max_separation - params->bump_hard_min_separation)/(params->bump_num_steps-1))/2;
				 bump_direction = left_stim ? main_direction + temp_real : main_direction - temp_real;
			}	
		}
		bump_direction_write_index >= 99 ? bump_direction_write_index = 0 : bump_direction_write_index++;
		bump_direction_history[bump_direction_write_index] = bump_direction;

		if (left_stim){
			rewardTarget = leftResponseTarget;
			failTarget = rightResponseTarget;
		} else {
            rewardTarget = rightResponseTarget;
			failTarget = leftResponseTarget;
        }

	} else {
		centerTarget->color = control_color;
		leftResponseTarget->color = 0;
		rightResponseTarget->color = 0;
		//bump_direction = main_direction;
	}	
	
	// Set up the bump direction history
	if (trial_type!=PROPRIO_TRIAL){
		if (bump_direction_history[0] == -1){
			bump_direction = main_direction;
		} else {
			(bump_direction_read_index >= 99 || bump_direction_read_index >= bump_direction_write_index) ?
				bump_direction_read_index = 0 : bump_direction_read_index++;
			bump_direction = bump_direction_history[bump_direction_read_index];
		}
	}

	if (training_mode)
		failTarget->width = 0;


	// Set up the bumps	
	total_bump_duration = params->bump_duration + params->bias_force_ramp + center_hold + 0.5;
	// replace "+ 0.5" with parameter?

	bump->hold_duration = params->bump_duration;
	bump->peak_magnitude = params->bump_magnitude;
	bump->rise_time = 0;
	if (catch_trial){
		if (params->num_directions>0){
            i = random->getInteger(0,(int)(params->num_directions-1));
            bump_direction = fmod(i * 2 * PI/params->num_directions + params->first_main_direction,2*PI);
		} else {
			bump_direction = random->getDouble(0,2*PI);
		}
	}
				
	bump->direction = bump_direction;

	bias_force->hold_duration = center_hold;
	bias_force->peak_magnitude = params->bias_force_magnitude;
	bias_force->rise_time = params->bias_force_ramp;
	bias_force->direction = params->bias_force_direction;

	/* setup the databurst */
	db->reset();
	db->addByte(DATABURST_VERSION);								// byte 1 -> Matlab idx 2
	db->addByte(BEHAVIOR_VERSION_MAJOR);						// byte 2 -> Matlab idx 3
    db->addByte(BEHAVIOR_VERSION_MINOR);						// byte 3 -> Matlab idx 4
	db->addByte((BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8);		// byte 4 -> Matlab idx 5
	db->addByte(BEHAVIOR_VERSION_MICRO & 0x00FF);				// byte 5 -> Matlab idx 6
	db->addFloat((float)(inputs->offsets.x));					// bytes 6 to 9 -> Matlab idx 7 to 10
	db->addFloat((float)(inputs->offsets.y));					// bytes 10 to 13 -> Matlab idx 11 to 14
	db->addByte(trial_type);									// byte 14 -> Matlab idx 15
	db->addByte(staircase_id);									// byte 15 -> Matlab idx 16
	db->addByte(training_mode);									// byte 16 -> Matlab idx 17
	db->addByte(catch_trial);									// byte 17 -> Matlab idx 18
	db->addFloat((float)(main_direction));						// bytes 18 to 21 -> Matlab idx 19 to 22
	db->addFloat((float)(params->bump_magnitude));				// bytes 22 to 25 -> Matlab idx 23 to 26 
	db->addFloat((float)(bump_direction));						// bytes 26 to 29 -> Matlab idx 27 to 30
	db->addFloat((float)(params->bump_duration));				// bytes 30 to 33 -> Matlab idx 31 to 34 
	db->addFloat((float)(params->moving_dots_target_size));		// bytes 34 to 37 -> Matlab idx 35 to 38 
	db->addFloat((float)(params->moving_dots_coherence));		// bytes 38 to 41 -> Matlab idx 39 to 42 
	db->addFloat((float)(dotsTargetB->direction));				// bytes 42 to 45 -> Matlab idx 43 to 46 
	db->addFloat((float)(params->moving_dots_speed));			// bytes 46 to 49 -> Matlab idx 47 to 50 
	db->addFloat((float)(params->moving_dots_num_dots));		// bytes 50 to 53 -> Matlab idx 51 to 54 
	db->addFloat((float)(params->moving_dots_dot_radius));		// bytes 54 to 57 -> Matlab idx 55 to 58 
	db->addFloat((float)(params->moving_dots_movement_type));	// bytes 58 to 61 -> Matlab idx 59 to 62 
	db->addFloat((float)(rewardTarget->centerX));				// bytes 62 to 65 -> Matlab idx 63 to 66 
	db->addFloat((float)(rewardTarget->centerY));				// bytes 66 to 69 -> Matlab idx 67 to 70 
	db->addFloat((float)(params->bias_force_magnitude));		// bytes 70 to 73 -> Matlab idx 71 to 74 
	db->addFloat((float)(params->bias_force_direction));		// bytes 74 to 77 -> Matlab idx 75 to 78 
	db->start();
}

void AttentionBehavior::update(SimStruct *S) {
	//int i;
	// State machine
	switch (this->getState()) {
		case STATE_PRETRIAL:
            updateParameters(S);
            doPreTrial(S);
            setState(STATE_DATA_BLOCK);
			break;
		case STATE_DATA_BLOCK:
			if (db->isDone()) {
				setState(STATE_CENTER_TARGET_ON);
			}
			break;
		case STATE_CENTER_TARGET_ON:
			/* first target on */
			if (centerTarget->cursorInTarget(inputs->cursor)) {
				bias_force->start(S);
				setState(STATE_CENTER_HOLD);
			}
			break;
		case STATE_CENTER_HOLD:
			if (stateTimer->elapsedTime(S) > (center_hold>params->bias_force_ramp ? 
				center_hold : params->bias_force_ramp)) {
				bump->start(S);
				setState(STATE_STIMULI);
			} else if (!centerTarget->cursorInTarget(inputs->cursor)) {
				playTone(TONE_ABORT);
				setState(STATE_ABORT);
			}
			break;		
		case STATE_STIMULI:
			if (stateTimer->elapsedTime(S) > params->bump_duration && 
					centerTarget->cursorInTarget(inputs->cursor)) {
				if (catch_trial){
					setState(STATE_INCOMPLETE);
				} else if (trial_type == VISUAL_TRIAL || trial_type == PROPRIO_TRIAL){
					setState(STATE_MOVEMENT);
				} else {
					playTone(TONE_REWARD);
					setState(STATE_REWARD);
				}
			}
			//if (!centerTarget->cursorInTarget(inputs->cursor)){
			//	setState(STATE_ABORT);
			//} else if (stateTimer->elapsedTime(S) > (total_bump_length && 
			//		centerTarget->cursorInTarget(inputs->cursor)) {
			//	if (catch_trial){
			//		setState(STATE_INCOMPLETE);
			//	} else if (trial_type == VISUAL_TRIAL || trial_type == PROPRIO_TRIAL){
			//		setState(STATE_MOVEMENT);
			//	} else {
			//		playTone(TONE_REWARD);
			//		setState(STATE_REWARD);
			//	}
			//}
			break;						
		case STATE_MOVEMENT:
			if (rewardTarget->cursorInTarget(inputs->cursor)){
				if (params->use_staircases){
					if (trial_type == VISUAL_TRIAL){
						visualStairs[staircase_id]->stepForward();						
					} else if (trial_type == PROPRIO_TRIAL){
						proprioStairs[staircase_id]->stepForward();
					}
				}			
				playTone(TONE_REWARD);
				setState(STATE_REWARD);
			} else if (failTarget->cursorInTarget(inputs->cursor)){
				if (params->use_staircases){
					if (trial_type == VISUAL_TRIAL){
						visualStairs[staircase_id]->stepBackward();
					} else if (trial_type == PROPRIO_TRIAL){
						proprioStairs[staircase_id]->stepBackward();
					}
				}
				playTone(TONE_ABORT);
				setState(STATE_FAIL);
			} else if (params->movement_time < 0) {
                // wait in this state forever
            } else if (stateTimer->elapsedTime(S) > params->movement_time){
				setState(STATE_INCOMPLETE);
			}
			break;
		case STATE_ABORT:			
			this->bump->stop();
			this->bias_force->stop();			
			if (stateTimer->elapsedTime(S) > params->abort_timeout) {
				trial_counter--;
				setState(STATE_PRETRIAL);
			}
			break;
        case STATE_REWARD:
			this->bump->stop();
			this->bias_force->stop();					
			if (stateTimer->elapsedTime(S) > params->reward_timeout) {
				current_percent_training_mode = current_percent_training_mode - params->percent_training_step;			
				setState(STATE_PRETRIAL);
			}
			break;
		case STATE_FAIL:
			this->bump->stop();
			this->bias_force->stop();					
			if (stateTimer->elapsedTime(S) > params->fail_timeout) {				
				current_percent_training_mode = current_percent_training_mode + 3*params->percent_training_step;
				setState(STATE_PRETRIAL);
			}
			break;
        case STATE_INCOMPLETE:
			this->bump->stop();
			this->bias_force->stop();
			if (stateTimer->elapsedTime(S) > params->reward_timeout) {
				setState(STATE_PRETRIAL);
			}
			break;
		default:
			setState(STATE_PRETRIAL);
	}
}

void AttentionBehavior::calculateOutputs(SimStruct *S) {

	Point bf;

	/* force (0) */
	outputs->force = inputs->force;

	if (bias_force->isRunning(S)){
		outputs->force += bias_force->getBumpForce(S);
	}

	if (bump->isRunning(S)) {
		outputs->force += bump->getBumpForce(S);		
	} 

	/* status (1) */
	outputs->status[0] = getState();
	outputs->status[1] = trialCounter->successes;
	outputs->status[2] = trialCounter->failures;
	outputs->status[3] = trialCounter->aborts;	
	//outputs->status[4] = trialCounter->incompletes;	
	//outputs->status[4] = debug_var;
	outputs->status[4] = current_percent_training_mode;
    
	/* word(2) */
	if (db->isRunning()) {
		outputs->word = db->getByte();
	} else if (isNewState()) {
		switch (getState()) {
			case STATE_PRETRIAL:
				outputs->word = WORD_START_TRIAL;
				break;
			case STATE_CENTER_TARGET_ON:
				outputs->word = WORD_CT_ON;
				break;
			case STATE_CENTER_HOLD:
				outputs->word = WORD_CENTER_TARGET_HOLD;
				break;			
			case STATE_STIMULI:
				outputs->word = WORD_BUMP(0);
				break;
			case STATE_MOVEMENT:
				outputs->word = WORD_OT_ON(0);
				break;
			case STATE_REWARD:
				outputs->word = WORD_REWARD;
				break;
			case STATE_ABORT:
				outputs->word = WORD_ABORT;
				break;
			case STATE_FAIL:
				outputs->word = WORD_FAIL;
				break;
			case STATE_INCOMPLETE:
				outputs->word = WORD_INCOMPLETE;
				break;
			default:
				outputs->word = 0;
		}
	} else {
		outputs->word = 0;
	}

 	/* target_pos (3) */
 	// Center Target
 	if (getState() == STATE_CENTER_TARGET_ON || 
 	    getState() == STATE_CENTER_HOLD) 
 	{
 		outputs->targets[0] = (Target *)centerTarget;
		outputs->targets[1] = nullTarget;
 	} else if (getState() == STATE_STIMULI) {
		if (trial_type == VISUAL_TRIAL && stateTimer->elapsedTime(S)<params->moving_dots_duration){
			outputs->targets[0] = (Target *)dotsTargetA;
			outputs->targets[1] = (Target *)dotsTargetB;
		} else {
 			outputs->targets[0] = (Target *)centerTarget;
			outputs->targets[1] = nullTarget;
		}
 	} else if (getState() == STATE_MOVEMENT) {
 		outputs->targets[0] = (Target *)rewardTarget;
 		if (!training_mode) {
 			outputs->targets[1] = (Target *)failTarget;
 		} else {
 			outputs->targets[1] = nullTarget;
 		}
 	} else {
 		outputs->targets[0] = nullTarget;
 		outputs->targets[1] = nullTarget;
 	}

	/* reward (4) */
	outputs->reward = (isNewState() && (getState() == STATE_REWARD));

	/* tone (5) */
	this->outputs->tone_counter = this->tone_counter;
	this->outputs->last_tone_id = this->last_tone_id;

	/* version (6) */
	outputs->version[0] = BEHAVIOR_VERSION_MAJOR;
	outputs->version[1] = BEHAVIOR_VERSION_MINOR;
	outputs->version[2] = BEHAVIOR_VERSION_MICRO;
	outputs->version[3] = BEHAVIOR_VERSION_BUILD;

	/* position (7) */
    if (getState() == STATE_STIMULI && stateTimer->elapsedTime(S)<(params->bump_duration + 0.5))
    {
        outputs->position = Point(1E6, 1E6);
    } else {
    	outputs->position = inputs->cursor;
    } 

}

/*
 * Include at bottom of your behavior code
 */
#include "common_footer.cpp"

