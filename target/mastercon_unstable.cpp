/* $Id: $
 *
 * Master Control block for behavior: unstable field
 */

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
 * byte         0: uchar => number of bytes to be transmitted
 * byte         1: uchar => databurst version number (in this case zero)
 * byte         2: uchar => model version major
 * byte         3: uchar => model version minor
 * bytes   4 to 5: short => model version micro
 * bytes   6 to 9: float => x offset (cm)
 * bytes 10 to 13: float => y offset (cm)
 * bytes 14 to 17: float => bump magnitude (N?)
 * bytes 18 to 21: float => bump direction (rad)
 * bytes 22 to 25: float => negative stiffness (N/m?)
 * bytes 26 to 29: float => positive stiffness (N/m?)
 * bytes 30 to 33: float => force field angle (rad)
 * bytes 34 to 37: float => bias force magnitude (N?)
 * bytes 38 to 41: float => bias force angle (rad)
 *
 * * Version 1 (0x01)
 * ----------------
 * byte         0: uchar => number of bytes to be transmitted
 * byte         1: uchar => databurst version number (in this case zero)
 * byte         2: uchar => model version major
 * byte         3: uchar => model version minor
 * bytes   4 to 5: short => model version micro
 * bytes   6 to 9: float => x offset (cm)
 * bytes 10 to 13: float => y offset (cm)
 * bytes 14 to 17: float => bump magnitude (N?)
 * bytes 18 to 21: float => bump direction (rad)
 * bytes 22 to 25: float => bump duration (s)
 * bytes 26 to 29: float => negative stiffness (N/m?)
 * bytes 30 to 33: float => positive stiffness (N/m?)
 * bytes 34 to 37: float => force field angle (rad)
 * bytes 38 to 41: float => bias force magnitude (N?)
 * bytes 42 to 45: float => bias force angle (rad)
 */


#define S_FUNCTION_NAME mastercon_unstable
#define S_FUNCTION_LEVEL 2

// Our task code will be in the databurst
#define TASK_DB_DEFINED 1
#include "words.h"

#include "common_header.cpp"

/*
 * State IDs
 */
#define STATE_PRETRIAL				 0
#define STATE_CENTER_TARGET_ON		 1
#define STATE_FIELD_BUILD_UP		 2
#define STATE_HOLD_FIELD			 3
#define STATE_CT_HOLD				 4
#define STATE_BUMP					 5

/* 
 * STATE_REWARD STATE_ABORT STATE_FAIL STATE_INCOMPLETE STATE_DATA_BLOCK 
 * are all defined in Behavior.h Do not use state numbers above 64 (0x40)
 */

#define DATABURST_VERSION ((byte)0x01) 

// This must be custom defined for your behavior
struct LocalParams{
	real_T master_reset;

	// Timing
	real_T field_ramp_up;
	real_T field_hold_low;
	real_T field_hold_high;
	real_T reward_wait;
	real_T abort_wait;

	// Target and workspace
	real_T target_diameter;
	real_T workspace_diameter;

	// Unstable field
	real_T negative_stiffness;  // Must be a positive value
	real_T positive_stiffness;
	real_T first_field_angle;
	real_T x_position_offset;
	real_T y_position_offset;
	real_T bias_force_magnitude;
	real_T bias_force_angle;

	// Bumps
	real_T bump_duration;
	real_T bump_magnitude;
	real_T num_bump_directions;
	real_T first_bump_direction;
    
    // Unstable field again
    real_T num_field_orientations;
    real_T field_block_length;
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
	CircleTarget *centerTarget;	
	CircleTarget *workSpaceTarget;
	LocalParams *params;	

	real_T field_hold_time;
	real_T bump_direction;
	
	TrapBumpGenerator *bump;
	real_T x_force_at_bump_start;
	real_T y_force_at_bump_start;
    
    real_T x_vel;
    real_T y_vel;
    real_T vel;
    
    real_T field_angle;
    
    int trial_counter;
    int block_counter;
    int block_order [10];
    int *block_order_point [10];

	// any helper functions you need
	void doPreTrial(SimStruct *S);
};

AttentionBehavior::AttentionBehavior(SimStruct *S) : RobotBehavior() {

	/* 
	 * First, set up the parameters to be used 
	 */
	// Create your *params object
	params = new LocalParams();

	// Set up the number of parameters you'll be using
	this->setNumParams(21);
	// Identify each bound variable 
	this->bindParamId(&params->master_reset,							 0);
	this->bindParamId(&params->field_ramp_up,							 1);
	this->bindParamId(&params->field_hold_low,							 2);
	this->bindParamId(&params->field_hold_high,							 3);
	this->bindParamId(&params->reward_wait,								 4);
	this->bindParamId(&params->abort_wait,								 5);

	this->bindParamId(&params->target_diameter,							 6);
	this->bindParamId(&params->workspace_diameter,						 7);

	this->bindParamId(&params->negative_stiffness,						 8);
	this->bindParamId(&params->positive_stiffness,						 9);
	this->bindParamId(&params->first_field_angle,   					 10);
	this->bindParamId(&params->x_position_offset,						 11);
	this->bindParamId(&params->y_position_offset,						 12);
    this->bindParamId(&params->bias_force_magnitude,					 13);
	this->bindParamId(&params->bias_force_angle,						 14);

	this->bindParamId(&params->bump_duration,							 15);
	this->bindParamId(&params->bump_magnitude,							 16);
	this->bindParamId(&params->num_bump_directions,						 17);
	this->bindParamId(&params->first_bump_direction,					 18);
    
    this->bindParamId(&params->num_field_orientations,                   19);
    this->bindParamId(&params->field_block_length,                       20);
    
    // default parameters:
    // 1 1 2 1 1   5 10   5 5 0 0 0 1 1   .2 0 1 0   1 10
    
	// declare which already defined parameter is our master reset 
	// (if you're using one) otherwise omit the following line
	this->setMasterResetParamId(0);

	// This function now fetches all of the parameters into the variables
	// as defined above.
	//this->updateParameters(S);
		
	centerTarget = new CircleTarget();
	centerTarget->color = Target::Color(255,150,50);	

	workSpaceTarget = new CircleTarget();
	workSpaceTarget->color = Target::Color(60,60,60);

	field_hold_time = 0.0;
	bump_direction = 0.0;
	
	bump = new TrapBumpGenerator();
	x_force_at_bump_start = 0;
	y_force_at_bump_start = 0;
    
    block_counter = 10000; 
    trial_counter = 10000; // Stupidly large number so that the blocks are reset in first pretrial.
    field_angle = 0;
}

void AttentionBehavior::doPreTrial(SimStruct *S) {	
	centerTarget->centerX = params->x_position_offset;
	centerTarget->centerY = params->y_position_offset;
	centerTarget->radius = params->target_diameter/2;

	workSpaceTarget->centerX = params->x_position_offset;
	workSpaceTarget->centerY = params->y_position_offset;
	workSpaceTarget->radius = params->workspace_diameter/2;

	field_hold_time = this->random->getDouble(params->field_hold_low,params->field_hold_high);

	int rand_i = this->random->getInteger(0,(int)(params->num_bump_directions-1));
	bump_direction = fmod(rand_i * 2 * PI/params->num_bump_directions + params->first_bump_direction,2*PI);

	bump->direction = bump_direction;
	bump->hold_duration = params->bump_duration;
	bump->peak_magnitude = params->bump_magnitude;
	bump->rise_time = 0;	
	x_force_at_bump_start = 0;
	y_force_at_bump_start = 0;
    
    if (trial_counter >= params->field_block_length-1){
        trial_counter = -1;
        block_counter++;
        if (block_counter >= params->num_field_orientations){
            block_counter = 0;
            for (int i=0; i < params->num_field_orientations; i++){
                block_order[i] = i;
                block_order_point[i] = &block_order[0] + i*sizeof(int);
            }
            random->permute((void **)block_order_point, params->num_field_orientations);            
        }
    }
    trial_counter++;

    field_angle = fmod(block_order[block_counter] * PI/(params->num_field_orientations) + 
        params->first_field_angle,2*PI);  


	/* setup the databurst */
	db->reset();
	db->addByte(DATABURST_VERSION);								// byte 1 -> Matlab idx 2
	db->addByte(BEHAVIOR_VERSION_MAJOR);						// byte 2 -> Matlab idx 3
    db->addByte(BEHAVIOR_VERSION_MINOR);						// byte 3 -> Matlab idx 4
	db->addByte((BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8);		// byte 4 -> Matlab idx 5
	db->addByte(BEHAVIOR_VERSION_MICRO & 0x00FF);				// byte 5 -> Matlab idx 6
	db->addFloat((float)(inputs->offsets.x));					// bytes 6 to 9 -> Matlab idx 7 to 10
	db->addFloat((float)(inputs->offsets.y));					// bytes 10 to 13 -> Matlab idx 11 to 14
	db->addFloat((float)params->bump_magnitude);				// bytes 14 to 17 -> Matlab idx 15 to 18
	db->addFloat((float)bump_direction);						// bytes 18 to 21 -> Matlab idx 19 to 22
    db->addFloat((float)params->bump_duration);                 // bytes 22 to 25 -> Matlab idx 23 to 26
	db->addFloat((float)params->negative_stiffness);			// bytes 26 to 29 -> Matlab idx 27 to 30
	db->addFloat((float)params->positive_stiffness);			// bytes 30 to 33 -> Matlab idx 31 to 34
	db->addFloat((float)field_angle);                           // bytes 34 to 37 -> Matlab idx 35 to 38
	db->addFloat((float)params->bias_force_magnitude);			// bytes 38 to 41 -> Matlab idx 39 to 42
	db->addFloat((float)params->bias_force_angle);				// bytes 38 to 41 -> Matlab idx 43 to 46
	db->start();

}

void AttentionBehavior::update(SimStruct *S) {
	// State machine
    switch (this->getState()) {
        case STATE_PRETRIAL:
            updateParameters(S);
            doPreTrial(S);
            setState(STATE_CENTER_TARGET_ON);
            break;		
        case STATE_CENTER_TARGET_ON:
            /* center target on */
            if (centerTarget->cursorInTarget(inputs->cursor)) {				
                setState(STATE_FIELD_BUILD_UP);
            }
            break;		
        case STATE_FIELD_BUILD_UP:
            if (stateTimer->elapsedTime(S) > params->field_ramp_up){
                setState(STATE_HOLD_FIELD);
            } else if (!workSpaceTarget->cursorInTarget(inputs->cursor)){
                setState(STATE_ABORT);
            }
            break;
        case STATE_HOLD_FIELD:
            if (!workSpaceTarget->cursorInTarget(inputs->cursor)){
                playTone(TONE_ABORT);
                setState(STATE_ABORT);				
            } else if (centerTarget->cursorInTarget(inputs->cursor)){
                setState(STATE_CT_HOLD);
            }
            break;
        case STATE_CT_HOLD:
            if (stateTimer->elapsedTime(S) > field_hold_time){
                bump->start(S);
                setState(STATE_BUMP);
            } else if (!centerTarget->cursorInTarget(inputs->cursor)){
                setState(STATE_HOLD_FIELD);
            }
            break;
        case STATE_BUMP:
            if (stateTimer->elapsedTime(S) > params->bump_duration){
                playTone(TONE_REWARD);
                setState(STATE_REWARD);
            }
            break;
        case STATE_REWARD:
            if (stateTimer->elapsedTime(S) > params->reward_wait){
                setState(STATE_PRETRIAL);
            }
            break;
        case STATE_ABORT:
            if (stateTimer->elapsedTime(S) > params->abort_wait){
                setState(STATE_PRETRIAL);
            }
            break;
        default:
            setState(STATE_PRETRIAL);
    }
    
}

void AttentionBehavior::calculateOutputs(SimStruct *S) {
    real_T b; // Damping coefficient
    b = 2*sqrt(0.5 * params->positive_stiffness);  // Assuming 0.5kg mass
    b = 0.01;
    
    //int i;
    x_vel = inputs->catchForce.x;
    y_vel = inputs->catchForce.y;
    vel = sqrt(x_vel*x_vel + y_vel*y_vel);     
    
    /* force (0) */
	real_T ratio_force;
    
    /*
     x_force_field = kn*((x - x_offset)*cos(field_angle) +...
                (y - y_offset)*sin(field_angle))*cos(field_angle) + ...
                kp*(-(x - x_offset)*sin(field_angle) + ...
                (y - y_offset)*cos(field_angle))*sin(field_angle) + bias_mag * cos(bias_angle) +...
                b*(-x_vel*sin(field_angle) + y_vel*cos(field_angle))*sin(field_angle);
                        
    y_force_field = kn*((x-x_offset)*cos(field_angle) + ...
                (y - y_offset)*sin(field_angle))*sin(field_angle) -...
                kp*(-(x - x_offset)*sin(field_angle) + ...
                (y-y_offset)*cos(field_angle))*cos(field_angle) + bias_mag * sin(bias_angle) -...
                b*(-x_vel*sin(field_angle) + y_vel*cos(field_angle))*cos(field_angle); */
    
    
    // Damped forces
    real_T x_force_field = params->negative_stiffness*((inputs->cursor.x - params->x_position_offset)*cos(field_angle) +
					    (inputs->cursor.y - params->y_position_offset)*sin(field_angle))*cos(field_angle) + 
						params->positive_stiffness*(-(inputs->cursor.x - params->x_position_offset)*sin(field_angle) + 
						(inputs->cursor.y - params->y_position_offset)*cos(field_angle))*sin(field_angle) + 
                        params->bias_force_magnitude * cos(params->bias_force_angle) +
                        b*(-x_vel*sin(field_angle) + y_vel*cos(field_angle))*sin(field_angle);

	real_T y_force_field = params->negative_stiffness*((inputs->cursor.x-params->x_position_offset)*cos(field_angle) + 
						(inputs->cursor.y - params->y_position_offset)*sin(field_angle))*sin(field_angle) -
						params->positive_stiffness*(-(inputs->cursor.x - params->x_position_offset)*sin(field_angle) + 
						(inputs->cursor.y-params->y_position_offset)*cos(field_angle))*cos(field_angle) + 
                        params->bias_force_magnitude * sin(params->bias_force_angle) -
                        b*(-x_vel*sin(field_angle) + y_vel*cos(field_angle))*cos(field_angle);


	if (isNewState() && getState() == STATE_BUMP){
		x_force_at_bump_start = x_force_field;
		y_force_at_bump_start = y_force_field;
	}

	switch (this->getState()){
		case STATE_FIELD_BUILD_UP:
			ratio_force = stateTimer->elapsedTime(S) / params->field_ramp_up;
			outputs->force.x = ratio_force * x_force_field;
			outputs->force.y = ratio_force * y_force_field;
			break;
		case STATE_HOLD_FIELD:
		case STATE_CT_HOLD:
			outputs->force.x = x_force_field;
			outputs->force.y = y_force_field;
			break;
		case STATE_BUMP:
			outputs->force = bump->getBumpForce(S);
			outputs->force.x += x_force_at_bump_start;
			outputs->force.y += y_force_at_bump_start;
			break;
        case STATE_REWARD:
        case STATE_ABORT:
            outputs->force.x = -x_vel*0.0005;
            outputs->force.y = -y_vel*0.0005;
            break;
		default:
			outputs->force = Point(0,0);
	}        
		
	/* status (1) */
	outputs->status[0] = getState();
	outputs->status[1] = trialCounter->successes;
	outputs->status[2] = trialCounter->aborts;
	outputs->status[3] = floor(1000*bump_direction);	
	outputs->status[4] = floor(1000*params->y_position_offset);

 	
	/* word (2) */
	if (db->isRunning()) {
		outputs->word = db->getByte();
	} else if (isNewState()) {
		switch (getState()) {
			case STATE_PRETRIAL:
				outputs->word = WORD_START_TRIAL;           // 0x1F = 31
				break;
			case STATE_CENTER_TARGET_ON:
				outputs->word = WORD_CT_ON;                 // 0x30 = 48
				break;
			case STATE_FIELD_BUILD_UP:
				outputs->word = WORD_FIELD_BUILDING_UP;     // 0x31 = 49
				break;
			case STATE_CT_HOLD:
				outputs->word = WORD_CENTER_TARGET_HOLD;    // 0xA0 = 160
				break;			
			case STATE_BUMP:
				outputs->word = WORD_BUMP(0);               // 0x50 = 80
				break;			
			case STATE_REWARD:
				outputs->word = WORD_REWARD;                // 0x20 = 32
				break;
			case STATE_ABORT:
				outputs->word = WORD_ABORT;                 // 0x21 = 33
				break;			
			default:
				outputs->word = 0;
		}
	} else {
		outputs->word = 0;
	}

	/* targets (3) */
	switch (this->getState()){
		case STATE_CENTER_TARGET_ON:
			outputs->targets[0] = (Target *)centerTarget;
			outputs->targets[1] = nullTarget;
			break;
		case STATE_FIELD_BUILD_UP:
		case STATE_HOLD_FIELD:
		case STATE_CT_HOLD:
			outputs->targets[0] = (Target *)workSpaceTarget;
			outputs->targets[1] = (Target *)centerTarget;
			break;
		default:
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
    if (getState() == STATE_BUMP)
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

