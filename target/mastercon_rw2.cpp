/* $Id: mastercon_rw2.cpp 977 2012-08-22 18:33:34Z brian $
 *
 * Master Control block for behavior: random walk task 
 */

#define S_FUNCTION_NAME mastercon_rw2
#define S_FUNCTION_LEVEL 2

#define TASK_RW 1
#include "words.h"

#include "common_header.cpp"

/*
 * State IDs
 */
#define STATE_PRETRIAL 0
#define STATE_INITIAL_MOVEMENT 1
#define STATE_TARGET_HOLD 2
#define STATE_TARGET_DELAY 3
#define STATE_MOVEMENT 4
/* 
 * STATE_REWARD STATE_ABORT STATE_FAIL STATE_INCOMPLETE STATE_DATA_BLOCK 
 * are all defined in common_header.cpp Do not use state numbers above 64 (0x40)
 */

/* 
 * Current Databurst version: 2
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
#define DATABURST_VERSION ((byte)0x02) 

// This must be custom defined for your behavior
struct LocalParams {
	real_T num_targets;
	real_T target_size;
	real_T target_tolerance;
	real_T left_target_boundary;
	real_T right_target_boundary;
	real_T upper_target_boundary;
	real_T lower_target_boundary;
	real_T target_hold_l;
	real_T target_hold_h;
	real_T target_delay_l;
	real_T target_delay_h;
	real_T movement_time;
	real_T initial_movement_time;
	real_T intertrial;
	real_T minimum_distance;
	real_T maximum_distance;
	real_T percent_catch_trials;
	real_T master_reset;
	real_T disable_abort;
	real_T green_hold;
	real_T cumulative_hold;
};

/**
 * This is the behavior class.  You must extend "Behavior" and implement
 * at least a constructor and the functions:
 *   void update(SimStruct *S)
 *   void calculateOutputs(SimStruct *S)
 *
 * You must also update the definition below with the name of your class
 */
#define MY_CLASS_NAME RandomWalkBehavior
class RandomWalkBehavior : public RobotBehavior {
public:
	// You must implement these three public methods
	RandomWalkBehavior(SimStruct *S);
	void update(SimStruct *S);
	void calculateOutputs(SimStruct *S);	

private:
	// Your behavior's instance variables
	int target_index;
	SquareTarget *targets[128];
	Timer *cumulativeHoldTimer;
	double targetHoldTime;
	double delayTime;
	bool catchTrial;

	LocalParams *params;	

	// any helper functions you need
	void doPreTrial(SimStruct *S);
};

RandomWalkBehavior::RandomWalkBehavior(SimStruct *S) : RobotBehavior() {
    int i;

	/* 
	 * First, set up the parameters to be used 
	 */
	// Create your *params object
	params = new LocalParams();

	// Set up the number of parameters you'll be using
	this->setNumParams(21);

	// Identify each bound variable 
	this->bindParamId(&params->num_targets,				 0);
	this->bindParamId(&params->target_size,				 1);
	this->bindParamId(&params->target_tolerance,		 2);
	this->bindParamId(&params->left_target_boundary,	 3);
	this->bindParamId(&params->right_target_boundary,	 4);
	this->bindParamId(&params->upper_target_boundary,	 5);
	this->bindParamId(&params->lower_target_boundary,	 6);
	this->bindParamId(&params->target_hold_l,			 7);
	this->bindParamId(&params->target_hold_h,			 8);
	this->bindParamId(&params->target_delay_l,			 9);
	this->bindParamId(&params->target_delay_h,			10);
	this->bindParamId(&params->movement_time,			11);
	this->bindParamId(&params->initial_movement_time,	12);
	this->bindParamId(&params->intertrial,				13);
	this->bindParamId(&params->minimum_distance,		14);
	this->bindParamId(&params->maximum_distance,		15);
	this->bindParamId(&params->percent_catch_trials,	16);
	this->bindParamId(&params->master_reset,			17);
	this->bindParamId(&params->disable_abort,			18);
	this->bindParamId(&params->green_hold,				19);
	this->bindParamId(&params->cumulative_hold,			20);

	// declare which already defined parameter is our master reset 
	// (if you're using one) otherwise omit the following line
	this->setMasterResetParamId(17);

	// This function now fetches all of the parameters into the variables
	// as defined above.
	this->updateParameters(S);

    /* 
	 * Then do any behavior specific initialization 
	 */
	this->cumulativeHoldTimer = new Timer();

	/* set target index to indicate that we need to begin a new block */
	target_index = (int)params->num_targets-1;

	for (i = 0; i<128; i++) {
		targets[i] = new SquareTarget(0, 0, 0, 0);
	}

}

void RandomWalkBehavior::doPreTrial(SimStruct *S) {
	int i, j;
	double r, th;
	SquareTarget lastTarget = *targets[(int)params->num_targets];
	SquareTarget tmpTarget;

	/* initialize target positions */
	if (params->maximum_distance == 0) {
		/* uniform random positions */
		for (i = 0; i<params->num_targets; i++) {
			targets[i]->centerX = random->getDouble(params->left_target_boundary,  params->right_target_boundary);
			targets[i]->centerY = random->getDouble(params->lower_target_boundary, params->upper_target_boundary);
			targets[i]->width = params->target_size;
			targets[i]->color = Target::Color(255, 0, 0);
		}
	} else {
		/* set not-quite-random target distances 
		 * semi-random with max and min distances */

		for (i = 0; i<params->num_targets; i++) {
			// Foreach Target
			r = random->getDouble(params->minimum_distance, params->maximum_distance);
			th = random->getDouble(0, 2*PI);

			// Copy previous target as a starting point
			if (i==0) {
				*targets[i] = lastTarget;
			} else {
				*targets[i] = *targets[i-1];
			}
			tmpTarget = *targets[i];

			for (j=0; j<5; j++) {
				// Add the offset
				tmpTarget.centerX = targets[i]->centerX + r * cos(th);
				tmpTarget.centerY = targets[i]->centerY + r * sin(th);
				if (tmpTarget.centerX > params->left_target_boundary &&
					tmpTarget.centerX < params->right_target_boundary &&
					tmpTarget.centerY > params->lower_target_boundary &&
					tmpTarget.centerY < params->upper_target_boundary)
				{
					// Found a location that works
					break;
				}

				if (j==4) {
					// Give up and set at origin
					tmpTarget.centerX = 0.0;
					tmpTarget.centerY = 0.0;
					break;
				}

				th = th + PI/2;
				r = params->minimum_distance;
			}

            tmpTarget.width = params->target_size;
            tmpTarget.color = Target::Color(255, 0, 0);
			*targets[i] = tmpTarget;
		}
	}

	target_index = 0;
	catchTrial = false;

	/* setup the databurst */
	db->reset();
	db->addByte(DATABURST_VERSION);
	db->addByte(BEHAVIOR_VERSION_MAJOR);
    db->addByte(BEHAVIOR_VERSION_MINOR);
	db->addByte((BEHAVIOR_VERSION_MICRO & 0xFF00) >> 8);
	db->addByte(BEHAVIOR_VERSION_MICRO & 0x00FF);
	db->addFloat((float)(inputs->offsets.x));
	db->addFloat((float)(inputs->offsets.y));
	db->addFloat((float)params->target_tolerance + (float)params->target_size);
	for (i = 0; i<params->num_targets; i++) {
		db->addFloat((float)targets[i]->centerX);
		db->addFloat((float)targets[i]->centerY);
	}
    db->start();
}

void RandomWalkBehavior::update(SimStruct *S) {
    /* declarations */
	SquareTarget currentTarget;
	SquareTarget targetBounds;
	
	currentTarget = *targets[target_index];
	targetBounds = currentTarget;
    targetBounds.width = currentTarget.width + params->target_tolerance;

	// State machine
	switch (this->getState()) {
		case STATE_PRETRIAL:
			updateParameters(S);
			doPreTrial(S);
			setState(STATE_DATA_BLOCK);
			break;
		case STATE_DATA_BLOCK:
			if (db->isDone()) {
				cumulativeHoldTimer->stop(S);
				setState(STATE_INITIAL_MOVEMENT);
			}
			break;
		case STATE_INITIAL_MOVEMENT:
			/* first target on */
			if (targetBounds.cursorInTarget(inputs->cursor)) {
				cumulativeHoldTimer->start(S);
				setState(STATE_TARGET_HOLD);
			} else if (stateTimer->elapsedTime(S) > params->initial_movement_time) {
				setState(STATE_INCOMPLETE);
			}
			break;
		case STATE_MOVEMENT:
			if (targetBounds.cursorInTarget(inputs->cursor)) {
				cumulativeHoldTimer->start(S);
				setState(STATE_TARGET_HOLD);
			} else if (stateTimer->elapsedTime(S) > params->movement_time) {
				setState(STATE_FAIL);
			}
			break;
		case STATE_TARGET_HOLD:
			if (params->cumulative_hold && cumulativeHoldTimer->elapsedTime(S) > targetHoldTime) {
				/* next state depends on whether there are more targets */
				if (target_index == params->num_targets - 1) {
					/* no more targets */
					cumulativeHoldTimer->stop(S);
					playTone(TONE_REWARD);
					setState(STATE_REWARD);
				} else {
					/* more targets */
					cumulativeHoldTimer->stop(S);
					delayTime = random->getDouble(params->target_delay_l, params->target_delay_h);
					setState(STATE_TARGET_DELAY);
				}
			} else if (params->disable_abort && !targetBounds.cursorInTarget(inputs->cursor)) {
				cumulativeHoldTimer->pause(S);
				setState(STATE_MOVEMENT);
			} else if (!targetBounds.cursorInTarget(inputs->cursor)) {
				setState(STATE_ABORT);
			} else if (stateTimer->elapsedTime(S) > targetHoldTime) {
				/* next state depends on whether there are more targets */
				if (target_index == params->num_targets - 1) {
					/* no more targets */
					playTone(TONE_REWARD);
					setState(STATE_REWARD);
				} else {
					/* more targets */
					delayTime = random->getDouble(params->target_delay_l, params->target_delay_h);
					setState(STATE_TARGET_DELAY);
				}
			}
			break;
		case STATE_TARGET_DELAY:
			if (!targetBounds.cursorInTarget(inputs->cursor)) {
				playTone(TONE_ABORT);
				setState(STATE_ABORT);
			} else if (stateTimer->elapsedTime(S) > delayTime) {
				target_index++;
				catchTrial = ( random->getDouble() < params->percent_catch_trials );
				targetHoldTime = random->getDouble(params->target_hold_l, params->target_hold_h);
				playTone(TONE_GO);
				setState(STATE_MOVEMENT);
			}
			break;
		case STATE_ABORT:
        case STATE_REWARD:
		case STATE_FAIL:
        case STATE_INCOMPLETE:
			if (stateTimer->elapsedTime(S) > params->intertrial) {
				setState(STATE_PRETRIAL);
			}
			break;
		default:
			setState(STATE_PRETRIAL);
	}
}

void RandomWalkBehavior::calculateOutputs(SimStruct *S) {
    /* declarations */
    SquareTarget *currentTarget = targets[target_index];

	/* force (0) */
	if (catchTrial) {
		outputs->force = inputs->catchForce;
	} else {
		outputs->force = inputs->force;
	}

	/* status (1) */
	outputs->status[0] = getState();
	outputs->status[1] = trialCounter->successes;
	outputs->status[2] = trialCounter->aborts;
	outputs->status[3] = trialCounter->failures;
	outputs->status[4] = trialCounter->incompletes;

	/* word(2) */
	if (db->isRunning()) {
		outputs->word = db->getByte();
	} else if (isNewState()) {
		switch (getState()) {
			case STATE_PRETRIAL:
				outputs->word = WORD_START_TRIAL;
				break;
			case STATE_INITIAL_MOVEMENT:
				if (catchTrial) {
					outputs->word = WORD_CATCH;
				} else {
					outputs->word = WORD_GO_CUE;
				}
				break;
			case STATE_TARGET_HOLD:
				outputs->word = WORD_TARGET_HOLD;
				break;
			case STATE_MOVEMENT:
				if (catchTrial) {
					outputs->word = WORD_CATCH;
				} else {
					outputs->word = WORD_GO_CUE;
				}
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
	// Target 0
	if (getState() == STATE_TARGET_HOLD && params->green_hold) {
		currentTarget->color = Target::Color(0, 128, 0);
		outputs->targets[0] = (Target *)currentTarget;
	} else if (getState() == STATE_INITIAL_MOVEMENT || 
			   getState() == STATE_MOVEMENT || 
		       getState() == STATE_TARGET_HOLD ||
		       getState() == STATE_TARGET_DELAY) {
		currentTarget->color = Target::Color(255, 0, 0);
		outputs->targets[0] = (Target *)currentTarget;
	} else {
		outputs->targets[0] = nullTarget;
	}

	// Target 1
	if (getState() == STATE_TARGET_DELAY) {
		outputs->targets[1] = (Target *)(this->targets[target_index+1]);		
	} else {
		outputs->targets[1] = this->nullTarget;
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
	outputs->position = inputs->cursor;
}

/*
 * Include at bottom of your behavior code
 */
#include "common_footer.cpp"


